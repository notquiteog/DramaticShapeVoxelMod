-- Optional camera-depth blur. Runs before HUD composition and uses the voxel
-- scene's actual readable depth, with a sharp region around camera focus.
local V=...
local M={level=0,LABELS={"OFF","SUBTLE","CINEMATIC"}}
local shader,ping,pong,width,height
function M.inverse(matrix)
  if not matrix then return nil end
  local a={}
  for y=1,4 do
    a[y]={}
    for x=1,4 do a[y][x]=matrix[(y-1)*4+x];a[y][x+4]=x==y and 1 or 0 end
  end
  for x=1,4 do
    local pivot=x
    for y=x+1,4 do if math.abs(a[y][x])>math.abs(a[pivot][x]) then pivot=y end end
    if math.abs(a[pivot][x])<1e-10 then return nil end
    a[x],a[pivot]=a[pivot],a[x]
    local d=a[x][x]
    for j=1,8 do a[x][j]=a[x][j]/d end
    for y=1,4 do if y~=x then
      local k=a[y][x]
      for j=1,8 do a[y][j]=a[y][j]-k*a[x][j] end
    end end
  end
  local out={}
  for y=1,4 do for x=1,4 do out[#out+1]=a[y][x+4] end end
  return out
end
local SOURCE=[[
  uniform Image sceneDepth;
  uniform mat4 inverseVP;
  uniform vec3 focus;
  uniform vec3 forward;
  uniform vec2 direction;
  uniform float strength;
  uniform float focusBand;
  uniform float focusRange;
  float distanceFromFocus(vec2 uv) {
    float depth=Texel(sceneDepth,uv).r;
    if(depth>=0.99999) return 10000.0;
    vec4 p=inverseVP*vec4(uv*2.0-1.0,depth*2.0-1.0,1.0);
    return dot(p.xyz/p.w-focus,forward);
  }
  vec4 effect(vec4 color,Image tex,vec2 uv,vec2 sc) {
    float depth=distanceFromFocus(uv);
    float coc=smoothstep(focusBand,focusRange,abs(depth));
    vec2 stepUV=direction*coc*strength;
    vec4 sum=Texel(tex,uv)*0.24;
    float weights=0.24;
    for(int i=1;i<=4;i++) {
      float w=0.21-float(i)*0.035;
      for(int side=-1;side<=1;side+=2) {
        vec2 sampleUV=clamp(uv+stepUV*float(i*side),vec2(0.0),vec2(1.0));
        float other=distanceFromFocus(sampleUV);
        // A nearby silhouette must not leak far scenery into its own edges.
        float accept=1.0-smoothstep(24.0,96.0,abs(other-depth));
        sum+=Texel(tex,sampleUV)*(w*accept);
        weights+=w*accept;
      }
    }
    return (sum/weights)*color;
  }
]]
function M.invalidate()
  if ping then ping:release() end
  if pong then pong:release() end
  ping,pong,width,height=nil,nil,nil,nil
end
function M.apply(canvas)
  M.lastApplied=false
  if M.level==0 or not canvas or not V.require("VoxelState").active() then return canvas end
  local voxel=V.require("Voxel3D")
  local depth=voxel.depthTexture()
  local focus,eye=voxel.focus,voxel.eye
  local inverse=M.inverse(voxel.vp)
  if not (depth and focus and eye and inverse) then return canvas end
  local w,h=canvas:getDimensions()
  local dw,dh=depth:getDimensions()
  if math.abs(w/h-dw/dh)>.01 then return canvas end
  if shader==nil then
    local ok,s=pcall(love.graphics.newShader,SOURCE);shader=ok and s or false
  end
  if not shader then return canvas end
  if not ping or width~=w or height~=h then
    M.invalidate()
    local ok,a=V.require("PixelCanvas").new(w,h)
    if not ok then return canvas end
    local okB,b=V.require("PixelCanvas").new(w,h)
    if not okB then a:release();return canvas end
    ping,pong,width,height=a,b,w,h
    ping:setFilter("linear","linear");pong:setFilter("linear","linear")
  end
  local forward={focus[1]-eye[1],focus[2]-eye[2],focus[3]-eye[3]}
  local n=math.sqrt(forward[1]^2+forward[2]^2+forward[3]^2)
  if n<.001 then return canvas end
  for i=1,3 do forward[i]=forward[i]/n end
  local min,mag,aniso=canvas:getFilter()
  love.graphics.push("all")
  local ok=pcall(function()
    canvas:setFilter("linear","linear")
    love.graphics.origin()
    love.graphics.setDepthMode()
    love.graphics.setScissor()
    love.graphics.setColor(1,1,1,1)
    love.graphics.setBlendMode("replace","premultiplied")
    love.graphics.setShader(shader)
    shader:send("sceneDepth",depth)
    shader:send("inverseVP","row",inverse)
    shader:send("focus",focus);shader:send("forward",forward)
    shader:send("strength",math.min(5,h*(M.level==1 and .0015 or .0045)))
    shader:send("focusBand",M.level==1 and 32 or 20)
    shader:send("focusRange",M.level==1 and 150 or 85)
    shader:send("direction",{1/w,0})
    love.graphics.setCanvas(ping);love.graphics.draw(canvas)
    shader:send("direction",{0,1/h})
    love.graphics.setCanvas(pong);love.graphics.draw(ping)
  end)
  love.graphics.pop()
  canvas:setFilter(min,mag,aniso)
  M.lastApplied=ok
  return ok and pong or canvas
end
return M
