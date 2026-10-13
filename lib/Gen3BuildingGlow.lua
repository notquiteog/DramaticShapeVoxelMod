-- Only source glass inside authored apertures or reviewed service facades.
-- Roof paint, frames, masonry and the duplicated roof atlas are never emissive.
local M={}
function M.build(g,p,data)
 local w,h=data:getDimensions();local pixels={};local count=0
 local areas={}
 for _,o in ipairs(g.custom and g.custom.openings or{})do areas[#areas+1]=o end
 if g.kind=='center' or g.kind=='mart' then
  areas[#areas+1]={2,p.wallTop or p.roofEnd,p.w-2,p.wallBottom}
 end
 for _,o in ipairs(areas)do
  for y=math.max(0,math.floor(o[2])),math.min(h-1,math.ceil(o[4])-1)do
   for x=math.max(0,math.floor(o[1])),math.min(p.w-1,math.ceil(o[3])-1)do
    local r,b,c,a=data:getPixel(x,y)
    -- Native cyan/blue glass, not its black sash or yellow/white surround.
    if a>.9 and c>r+.12 and b>r+.07 and b>.32 and c>.42 then
     local k=y*w+x;if not pixels[k]then pixels[k]=true;count=count+1 end
    end
   end
  end
 end
 local function read(x,y)return x>=0 and x<w and y>=0 and y<h and pixels[y*w+x]or false end
 if count==0 then return nil,nil end
 local mask=love.image.newImageData(w,h)
 for k in pairs(pixels)do mask:setPixel(k%w,math.floor(k/w),1,1,1,1)end
 local image=love.graphics.newImage(mask);image:setFilter('nearest','nearest');mask:release()
 return image,read
end
return M
