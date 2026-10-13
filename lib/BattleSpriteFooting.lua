-- Visible foot bounds for staged battle images. Providers may expose a shared
-- animation ground row; that retains pose motion while removing atlas padding.
local V=...
local M={}
local cache=setmetatable({},{__mode='k'})
function M.bounds(image,quad)
 local B=V.require('SpriteHeadBounds')
 if not quad then return B.get(image)end
 local frames=cache[image]
 if not frames then frames=setmetatable({},{__mode='k'});cache[image]=frames end
 if frames[quad]then return frames[quad]end
 local _,_,w,h=quad:getViewport();local g=love.graphics
 local c=g.newCanvas(w,h,{dpiscale=1})
 g.push('all');g.setCanvas(c);g.origin();g.setShader();g.setScissor();g.setDepthMode()
 g.clear(0,0,0,0);g.setColor(1,1,1,1);g.setBlendMode('replace','premultiplied')
 g.draw(image,quad,0,0);g.pop()
 local data=c:newImageData();local b=B.fromData(data,w,h);data:release();c:release()
 frames[quad]=b;return b
end
function M.union(data,quads)
 local bottom=0
 for _,quad in ipairs(quads)do
  local x,y,w,h=quad:getViewport()
  for row=h-1,bottom,-1 do
   local found=false
   for col=0,w-1 do local _,_,_,a=data:getPixel(x+col,y+row);if a>.5 then found=true;break end end
   if found then bottom=row+1;break end
  end
 end
 return bottom
end
function M.animationGround(image,quads)
 local g=love.graphics;local w,h=image:getDimensions();local c=g.newCanvas(w,h,{dpiscale=1})
 g.push('all');g.setCanvas(c);g.origin();g.setShader();g.setScissor();g.setDepthMode()
 g.clear(0,0,0,0);g.setColor(1,1,1,1);g.setBlendMode('replace','premultiplied');g.draw(image);g.pop()
 local data=c:newImageData();local bottom=M.union(data,quads);data:release();c:release()
 local _,_,_,frameHeight=quads[1]:getViewport()
 return bottom>0 and bottom or frameHeight
end
return M
