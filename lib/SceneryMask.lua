-- Background-connected alpha masks for native 2.5D scenery drawings.
local M={}
local dirs={{1,0},{-1,0},{0,1},{0,-1}}
-- Remove only background connected to the border. Pale petals and highlights
-- enclosed by the native outline remain part of the object.
function M.mask(size,background,height)
 height=height or size
 local outside,queue={},{}
 local function visit(x,y)
  if x<0 or y<0 or x>=size or y>=height then return end
  local k=y*size+x
  if not outside[k] and background(x,y) then outside[k]=true;queue[#queue+1]={x,y} end
 end
 for i=0,size-1 do visit(i,0);visit(i,height-1) end
 for i=0,height-1 do visit(0,i);visit(size-1,i) end
 local at=1
 while queue[at] do
  local p=queue[at];at=at+1
  for _,d in ipairs(dirs)do visit(p[1]+d[1],p[2]+d[2])end
 end
 local mask={}
 for y=0,height-1 do for x=0,size-1 do mask[y*size+x]=not outside[y*size+x] end end
 return mask
end
return M
