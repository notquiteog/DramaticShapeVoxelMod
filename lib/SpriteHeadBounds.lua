-- Read the bounds of a live provider image once. No art is changed or saved.
local M={}
local cache=setmetatable({},{__mode='k'})
function M.fromData(data,w,h)
 local left,top,right,bottom=w,h,-1,-1
 for y=0,h-1 do for x=0,w-1 do
  local _,_,_,a=data:getPixel(x,y)
  if a>.5 then left=math.min(left,x);right=math.max(right,x);top=math.min(top,y);bottom=math.max(bottom,y)end
 end end
 return right>=left and {left,top,right+1,bottom+1}or {0,0,w,h}
end
function M.get(image)
 if not image then return {0,0,64,64}end
 if cache[image]then return cache[image]end
 local G=love.graphics;local w,h=image:getDimensions();local canvas,data;local previous=G.getCanvas()
 G.push('all')
 local ok,bounds=pcall(function()
  canvas=G.newCanvas(w,h,{dpiscale=1});G.setCanvas(canvas);G.origin();G.setShader();G.setScissor()
  G.clear(0,0,0,0);G.setColor(1,1,1,1);G.setBlendMode('replace','premultiplied');G.draw(image)
  G.setCanvas(previous);data=canvas:newImageData();return M.fromData(data,w,h)
 end)
 G.pop();G.setCanvas(previous)
 if data then data:release()end;if canvas then canvas:release()end
 cache[image]=ok and bounds or {0,0,w,h}
 return cache[image]
end
return M
