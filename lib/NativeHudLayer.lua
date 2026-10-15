-- Capture a complete native HUD before scaling: native pixel scissors and
-- palette/flash shaders must execute in their original logical coordinates.
local M={}
local canvases,shader,palette={},nil,nil
local owners={}
function M.begin(owner)
 local state=owners[owner]or{items={}};owners[owner]=state;state.count=0
end
local SHADER=[[
extern vec3 ink;
extern vec3 paper;
extern vec3 shadow;
bool same(vec3 a, vec3 b) { return all(lessThan(abs(a-b),vec3(0.003))); }
vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen) {
 vec4 c=Texel(tex,uv);
 if(c.a>0.0) {
  vec3 rgb=c.rgb/c.a;
  if(same(rgb,ink)) rgb=vec3(0.96,0.98,1.0);
  else if(same(rgb,paper)) rgb=vec3(0.07,0.10,0.13);
  else if(same(rgb,shadow)) rgb=vec3(0.20,0.25,0.30);
  c.rgb=rgb*c.a;
 }
 return c*color;
}
]]
function M.scale(mode,rect)
 if mode=='og'then return 1 end
 local fit=math.min(tonumber(rect.Ux)or 1,tonumber(rect.Uy)or 1)
 if fit<=1 then return 1 end
 return math.max(1,math.floor(fit)-1)/fit
end
local function rgb(value)
 local function c(n)return math.floor(n*255/31+.5)/255 end
 return{c(value%32),c(math.floor(value/32)%32),c(math.floor(value/1024)%32)}
end
local function invert(pal)
 if not(pal and type(pal[2])=='number'and type(pal[3])=='number'and type(pal[4])=='number')then return end
 if shader==nil then local ok,s=pcall(love.graphics.newShader,SHADER);shader=ok and s or false end
 if not shader then return end
 if palette~=pal then
  shader:send('ink',rgb(pal[2]));shader:send('paper',rgb(pal[3]));shader:send('shadow',rgb(pal[4]));palette=pal
 end
 return shader
end
function M.draw(owner,w,h,scale,x,y,pal,fn,...)
 local effect=pal and invert(pal)
 if scale==1 and not effect then return fn(...)end
 local g=love.graphics
 local queued=scale<1
 if not owners[owner]then M.begin(owner)end
 local state=owners[owner];local slot=queued and state.count+1 or 0
 local key=owner..':'..w..':'..h..':'..slot
 if canvases[key]==nil then
  local ok,c=pcall(g.newCanvas,w,h,{dpiscale=1});canvases[key]=ok and c or false
  if ok and c then c:setFilter('nearest','nearest')end
 end
 local canvas=canvases[key];if not canvas then return fn(...)end
 g.push('all');g.setCanvas(canvas);g.origin();g.setShader();g.setScissor();g.setDepthMode()
 g.setBlendMode('alpha','alphamultiply');g.clear(0,0,0,0);g.setColor(1,1,1,1)
 local result={pcall(fn,...)};g.pop()
 if not result[1]then error(result[2],0)end
 if queued then
  state.count=slot;local item=state.items[slot]or{};state.items[slot]=item
  item.canvas,item.scale,item.x,item.y,item.pal=canvas,scale,x,y,pal
  return unpack(result,2)
 end
 g.push('all');g.setShader(effect);g.setColor(1,1,1,1);g.setBlendMode('alpha','premultiplied')
 local ok,err=pcall(g.draw,canvas,x*(1-scale),y*(1-scale),0,scale,scale)
 g.pop();if not ok then error(err,0)end
 return unpack(result,2)
end
-- Compact HUDs must be composed at window resolution. Shrinking into the
-- low-resolution native UI canvas first discards glyph pixels permanently.
function M.paint(owner,rect)
 local state=owners[owner];if not state or state.count==0 then return end
 local g=love.graphics;g.push('all');g.origin();g.setScissor();g.setDepthMode()
 g.setColor(1,1,1,1);g.setBlendMode('alpha','premultiplied')
 local ok,err=pcall(function()
  for i=1,state.count do
   local item=state.items[i];local sx,sy=item.scale*rect.Ux,item.scale*rect.Uy
   g.setShader(item.pal and invert(item.pal))
   g.draw(item.canvas,rect.uox+item.x*(rect.Ux-sx),rect.uoy+item.y*(rect.Uy-sy),0,sx,sy)
  end
 end)
 g.pop();if not ok then error(err,0)end
end
require('src.render.Assets').register({release=function()
 for _,c in pairs(canvases)do if c then c:release()end end
 if shader then shader:release()end
 canvases,shader,palette,owners={},nil,nil,{}
end})
return M
