-- Pure boundary selection. Real map rectangles always win. Fill consults the
-- nearest actual edge, never camera heading or a frame-dependent random seed.
local M={}
local function clamp(n,a,b)return math.max(a,math.min(b,n))end
function M.owner(regions,x,y)
 local nearest,best,nx,ny
 for _,r in ipairs(regions)do
  local xx,yy=clamp(x,r.x,r.x+r.w-1),clamp(y,r.y,r.y+r.h-1)
  local d=(xx-x)^2+(yy-y)^2
  if d==0 then return r,x-r.x,y-r.y,true end
  if not best or d<best then nearest,best,nx,ny=r,d,xx,yy end
 end
 if nearest then return nearest,nx-nearest.x,ny-nearest.y,false end
end
function M.resolve(regions,x,y,sample)
 local r,cx,cy,real=M.owner(regions,x,y)
 if not r then return end
 if real then return sample(r,cx,cy),true end
 local cache=r.boundaryCache or {};r.boundaryCache=cache
 local key=cx..':'..cy
 if cache[key]then return cache[key],false end
 local best,score
 -- Look along and a little behind the edge. A road exiting into a connected
 -- map is resolved above; a road ending at void must not repeat buildings.
 for dy=-3,3 do for dx=-3,3 do
  local xx,yy=cx+dx,cy+dy
  if xx>=0 and yy>=0 and xx<r.w and yy<r.h then
   local c=sample(r,xx,yy)
   if c and (c.biome=='water' or c.biome=='forest' or c.biome=='mountain')then
    local d=dx*dx+dy*dy
    if not score or d<score then best,score=c,d end
   end
  end
 end end
 best=best or sample(r,cx,cy)
 cache[key]=best
 return best,false
end
function M.bounds(regions,padding)
 local x0,y0,x1,y1=math.huge,math.huge,-math.huge,-math.huge
 for _,r in ipairs(regions)do
  x0,y0=math.min(x0,r.x),math.min(y0,r.y)
  x1,y1=math.max(x1,r.x+r.w),math.max(y1,r.y+r.h)
 end
 padding=padding or 0
 return x0-padding,y0-padding,x1+padding,y1+padding
end
return M
