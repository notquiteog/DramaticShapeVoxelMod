-- Radius of the opaque closed ball, not its padded native 16px frame.
-- Cache per live sheet/type; custom replacement artwork keeps its own bounds.
local M={};local cache=setmetatable({},{__mode='k'})
function M.radius(image,quad)
 if not(image and (type(quad)=='table'or type(quad)=='userdata')and quad.getViewport)then return 6 end
 local x,_,w,h=quad:getViewport();local key=x..':'..w..':'..h
 local by=cache[image];if not by then by={};cache[image]=by end
 if by[key]then return by[key]end
 local G=love.graphics;local canvas,data,q;local previous=G.getCanvas()
 G.push('all')
 local ok,radius=pcall(function()
  local iw,ih=image:getDimensions()
  -- Native sheet columns are ball types; row0 is their closed animation.
  q=G.newQuad(x,0,w,h,iw,ih)
  canvas=G.newCanvas(w,h,{dpiscale=1});G.setCanvas(canvas);G.origin();G.setShader();G.setScissor();G.setDepthMode()
  if G.setMeshCullMode then G.setMeshCullMode('none')end
  G.clear(0,0,0,0);G.setColor(1,1,1,1);G.setBlendMode('replace','premultiplied');G.draw(image,q)
  G.setCanvas(previous);data=canvas:newImageData()
  local bottom=0
  for y=0,h-1 do for px=0,w-1 do local _,_,_,a=data:getPixel(px,y);if a>.5 then bottom=math.max(bottom,y+1)end end end
  return bottom>0 and math.max(0,bottom-h/2)or h/2
 end)
 G.pop();G.setCanvas(previous)
 if data then data:release()end;if canvas then canvas:release()end;if q then q:release()end
 if ok then by[key]=radius;return radius end
 -- A transient readback failure must not freeze an incorrect custom radius.
 return 6
end
return M
