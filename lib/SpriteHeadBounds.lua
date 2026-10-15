-- Read the bounds of a live provider image once. No art is changed or saved.
local V=...
local M={stats={cpu=0,fit=0,gpu=0}}
local cache=setmetatable({},{__mode='k'})
function M.fromData(data,w,h)
 local left,top,right,bottom=w,h,-1,-1
 for y=0,h-1 do for x=0,w-1 do
  local _,_,_,a=data:getPixel(x,y)
  if a>.5 then left=math.min(left,x);right=math.max(right,x);top=math.min(top,y);bottom=math.max(bottom,y)end
 end end
 return right>=left and {left,top,right+1,bottom+1}or {0,0,w,h}
end
-- Owned sprite ImageData is already retained by BattleArt. Reuse it rather
-- than synchronizing the GPU just to read those same alpha pixels back.
function M.rememberFit(image,data,size,mirror,scale)
 if not data then return false end
 local w,h=data:getDimensions()
 local left,top=(size-w*scale)/2,size-h*scale
 -- Sampling exactly between source texels is driver-rounding sensitive.
 -- Keep the existing GPU measurement for those fractional fits.
 for _,axis in ipairs({{left,w},{top,h}})do
  for pixel=0,size-1 do
   local sample=(pixel+.5-axis[1])/scale
   if sample>=0 and sample<axis[2] and math.abs(sample-math.floor(sample+.5))<.0001 then
    cache[image]=nil;return false
   end
  end
 end
 local sampler={getPixel=function(_,x,y)
  local sx,sy=(x+.5-left)/scale,(y+.5-top)/scale
  if sx<0 or sx>=w or sy<0 or sy>=h then return 0,0,0,0 end
  if mirror then sx=w-sx end
  return data:getPixel(math.min(w-1,math.floor(sx)),math.floor(sy))
 end}
 M.stats.fit=M.stats.fit+1
 cache[image]=M.fromData(sampler,size,size)
 return true
end
function M.get(image)
 if not image then return {0,0,64,64}end
 if cache[image]then return cache[image]end
 local Art=type(V)=='table' and V.require('BattleArt')
 local source=Art and Art.imageData and Art.imageData(image)
 if source then
  M.stats.cpu=M.stats.cpu+1
  local w,h=source:getDimensions();cache[image]=M.fromData(source,w,h)
  return cache[image]
 end
 M.stats.gpu=M.stats.gpu+1
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
function M.snapshot()return M.stats end
return M
