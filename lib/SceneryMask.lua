-- Background-connected alpha masks for native 2.5D scenery drawings.
local M={}
-- Remove only background connected to the border. Pale petals and highlights
-- enclosed by the native outline remain part of the object.
function M.mask(size,background,height)
 height=height or size
 local outside,queue={},{}
 local function visit(x,y)
  if x<0 or y<0 or x>=size or y>=height then return end
  local k=y*size+x
  -- false records a tested foreground pixel too. The old flood revisited
  -- each foreground edge up to four times and allocated a table per pixel.
  if outside[k]==nil then
   outside[k]=not not background(x,y)
   if outside[k]then queue[#queue+1]=k end
  end
 end
 for i=0,size-1 do visit(i,0);visit(i,height-1) end
 for i=0,height-1 do visit(0,i);visit(size-1,i) end
 local at=1
 while queue[at] do
  local k=queue[at];at=at+1
  local x,y=k%size,math.floor(k/size)
  visit(x+1,y);visit(x-1,y);visit(x,y+1);visit(x,y-1)
 end
 local mask={}
 for y=0,height-1 do for x=0,size-1 do mask[y*size+x]=not outside[y*size+x] end end
 return mask
end
return M
