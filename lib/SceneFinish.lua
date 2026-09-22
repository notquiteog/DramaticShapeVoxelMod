-- Optional 2.5D highlight bloom and gentle warm/cool grading. Only the world
-- canvas is filtered; menus, dialogue and battle HUD compose afterward.
local V=...
local M={level=0,LABELS={'OFF','SOFT LIGHT','CINEMA'}}
local bright,blur,finish
local small,ping,glow,output,width,height
local BRIGHT=[[
 uniform float threshold;
 vec4 effect(vec4 color,Image tex,vec2 uv,vec2 sc) {
  vec3 c=Texel(tex,uv).rgb;
  float l=dot(c,vec3(.2126,.7152,.0722));
  return vec4(c*smoothstep(threshold,1.0,l),1.0);
 }
]]
local BLUR=[[
 uniform vec2 direction;
 vec4 effect(vec4 color,Image tex,vec2 uv,vec2 sc) {
  vec4 c=Texel(tex,uv)*.227027;
  c+=(Texel(tex,clamp(uv+direction*1.384615,vec2(0),vec2(1)))
    +Texel(tex,clamp(uv-direction*1.384615,vec2(0),vec2(1))))*.316216;
  c+=(Texel(tex,clamp(uv+direction*3.230769,vec2(0),vec2(1)))
    +Texel(tex,clamp(uv-direction*3.230769,vec2(0),vec2(1))))*.070270;
  return c;
 }
]]
local FINISH=[[
 uniform Image glow;
 uniform float strength;
 vec4 effect(vec4 color,Image tex,vec2 uv,vec2 sc) {
  vec4 source=Texel(tex,uv);
  float l=dot(source.rgb,vec3(.2126,.7152,.0722));
  vec3 tint=mix(vec3(-.01,.004,.014),vec3(.018,.009,-.008),smoothstep(.2,.8,l));
  vec3 base=source.rgb+tint*strength*2.0;
  // Add light only to highlights; the original detail is never blurred.
  vec3 c=1.0-(1.0-base)*(1.0-Texel(glow,uv).rgb*strength);
  return vec4(clamp(c,vec3(0),vec3(1)),source.a)*color;
 }
]]
function M.invalidate()
 for _,c in pairs({small,ping,glow,output}) do c:release() end
 small,ping,glow,output,width,height=nil,nil,nil,nil,nil,nil
end
local function prepare(w,h)
 if bright==nil then
  local ok,a,b,c=pcall(function()
   return love.graphics.newShader(BRIGHT),love.graphics.newShader(BLUR),love.graphics.newShader(FINISH)
  end)
  if not ok then bright=false;return false end
  bright,blur,finish=a,b,c
 end
 if not bright then return false end
 if width==w and height==h and output then return true end
 M.invalidate()
 local sw,sh=math.max(1,math.ceil(w/4)),math.max(1,math.ceil(h/4))
 local allocated={}
 for i=1,4 do
  local ok,c=V.require('PixelCanvas').new(i==4 and w or sw,i==4 and h or sh)
  if not ok then for _,v in ipairs(allocated) do v:release() end;return false end
  c:setFilter('linear','linear');allocated[i]=c
 end
 small,ping,glow,output=unpack(allocated);width,height=w,h
 return true
end
function M.apply(canvas,ctx)
 M.lastApplied=false
 local map=ctx and ctx.state and ctx.state.map
 if M.level==0 or not canvas or not V.require('VoxelState').active()
    or not V.require('CommunityVisuals').crystalDepth(map) then return canvas end
 local w,h=canvas:getDimensions()
 if not prepare(w,h) then return canvas end
 local sw,sh=small:getDimensions()
 local min,mag,aniso=canvas:getFilter()
 local g=love.graphics
 g.push('all')
 local ok=pcall(function()
  canvas:setFilter('linear','linear')
  g.origin();g.setDepthMode();g.setScissor();g.setColor(1,1,1,1)
  g.setBlendMode('replace','premultiplied')
  g.setShader(bright);bright:send('threshold',M.level==1 and .70 or .60)
  g.setCanvas(small);g.draw(canvas,0,0,0,sw/w,sh/h)
  g.setShader(blur);blur:send('direction',{1/sw,0})
  g.setCanvas(ping);g.draw(small)
  blur:send('direction',{0,1/sh});g.setCanvas(glow);g.draw(ping)
  g.setShader(finish);finish:send('glow',glow);finish:send('strength',M.level==1 and .15 or .28)
  g.setCanvas(output);g.draw(canvas)
 end)
 g.pop();canvas:setFilter(min,mag,aniso)
 M.lastApplied=ok
 return ok and output or canvas
end
return M
