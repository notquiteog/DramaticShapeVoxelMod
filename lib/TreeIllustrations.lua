-- The source sheet crosses quadrant boundaries in a few places. Keep the
-- main connected silhouette in each slot; those small detached fragments
-- are neighboring crowns, not leaves belonging to this tree.
local M={}
function M.isolate(data)
 local w,h=data:getDimensions()
 for row=0,1 do for col=0,1 do
  local x0,x1=math.floor(col*w/2),math.floor((col+1)*w/2)-1
  local y0,y1=math.floor(row*h/2),math.floor((row+1)*h/2)-1
  local pending={}
  for y=y0,y1 do for x=x0,x1 do
   local _,_,_,a=data:getPixel(x,y);if a>.05 then pending[y*w+x]=true end
  end end
  local largest={}
  while next(pending) do
   local first=next(pending);local queue={first};pending[first]=nil
   local i=1
   while i<=#queue do
    local at=queue[i];i=i+1;local x,y=at%w,math.floor(at/w)
    for dy=-1,1 do for dx=-1,1 do
     local nx,ny=x+dx,y+dy;local n=ny*w+nx
     if nx>=x0 and nx<=x1 and ny>=y0 and ny<=y1 and pending[n]then
      pending[n]=nil;queue[#queue+1]=n
     end
    end end
   end
   if #queue>#largest then largest=queue end
  end
  local keep={};for _,at in ipairs(largest)do keep[at]=true end
  for y=y0,y1 do for x=x0,x1 do
   if not keep[y*w+x]then data:setPixel(x,y,0,0,0,0)end
  end end
 end end
 return data
end
function M.image(V)
 local file=love.filesystem.newFileData(assert(V.mod:read('assets/crystal/depth-crowns-v2.png')),'depth-crowns-v2.png')
 local data=love.image.newImageData(file);file:release()
 M.isolate(data)
 local image=love.graphics.newImage(data,{mipmaps=true});data:release()
 image:setFilter('nearest','nearest');image:setMipmapFilter('linear')
 return image
end
return M
