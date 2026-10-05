-- Native General cliff masses. Raised rock caps and their steep bevels share
-- a continuous boundary height, so adjacent tiles cannot leave open cracks.
-- Only reviewed cliff artwork is raised; this is not a collision heightmap.
local M={}
local function solid(c)
 if not c or c.shape and (c.shape.kind=='cliff' or c.shape.kind=='caveWall') then return true end
 local g=c.civic
 return g and g.custom and g.custom.geometry=='tower' and c.cy>=g.cy+(g.northRows or 0)
end
function M.height(cells,x,z,height)
 local cx,cy=math.floor(x/16),math.floor(z/16)
 local distance,boundary=4,0
 local low,high=math.huge,-math.huge
 for y=cy-2,cy+2 do for xx=cx-2,cx+2 do
  local c=cells[xx..':'..y]
  if c and not solid(c) then
   local h=c.floorHigh or c.base or 0
   low,high=math.min(low,h),math.max(high,h)
  end
 end end
 local top=height or 32
 if high>-math.huge then
  -- A retaining face meets the upper terrace. An outer enclosure above a
  -- single floor keeps its full wall height relative to that floor.
  top=high>low and high or high+top
 end
 for y=cy-1,cy+1 do for xx=cx-1,cx+1 do
  local c=cells[xx..':'..y]
  if not solid(c)then
   local dx=math.max(xx*16-x,0,x-(xx+1)*16)
   local dz=math.max(y*16-z,0,z-(y+1)*16)
   local d=math.sqrt(dx*dx+dz*dz)
   local h=c.base or 0
   if c.floor and c.floor.high then
    local t=math.max(0,math.min(1,(z-y*16)/16))
    if c.floor.reverse then t=1-t end
    h=(c.floorHigh or c.floor.high)-(c.floor.high-c.floor.low)*t
   end
   if d<distance then distance,boundary=d,h
   elseif d==distance then boundary=math.max(boundary,h)end
  end
 end end
 return boundary+(top-boundary)*math.min(1,distance/4)
end
function M.append(cells,c,emit,uvFor)
 local x,z=c.cx*16,c.cy*16;local height=c.shape.height or 32
 local cap=assert(uvFor(c.ts,c.shape.cap or 113));local cliff=assert(uvFor(c.ts,c.shape.side or 121))
 local function sub(uv,a,b,u,v)
  local l,r=uv[1][1],uv[2][1];local t,d=uv[1][2],uv[3][2]
  local function p(xx,zz)return {l+(r-l)*xx/16,t+(d-t)*zz/16}end
  return {p(a,b),p(u,b),p(u,v),p(a,v)}
 end
 for iz=0,3 do for ix=0,3 do
  local a,b=ix*4,iz*4;local u,v=a+4,b+4
  local h1,h2=M.height(cells,x+a,z+b,height),M.height(cells,x+u,z+b,height)
  local h3,h4=M.height(cells,x+u,z+v,height),M.height(cells,x+a,z+v,height)
  local flat=h1==h2 and h2==h3 and h3==h4 and h1~=0
  local tex
  if flat then tex=sub(cap,a,b,u,v)
  else
   -- Follow the cliff's horizontal tangent on either axis. Using each
   -- quad's U=0..1 compressed four repetitions into every source tile.
   local alongZ=math.abs(h1-h2)+math.abs(h4-h3)>math.abs(h1-h4)+math.abs(h2-h3)
   local function side(xx,zz,h)
    return {cliff[1][1]+((alongZ and zz or xx)/16)*(cliff[2][1]-cliff[1][1]),
     cliff[1][2]+(1-math.max(0,math.min(1,h/height)))*(cliff[3][2]-cliff[1][2])}
   end
   tex={side(a,b,h1),side(u,b,h2),side(u,v,h3),side(a,v,h4)}
  end
  emit({{x+a,h1,z+b},{x+u,h2,z+b},{x+u,h3,z+v},{x+a,h4,z+v}},tex,flat and 1 or .84)
 end end
end
return M
