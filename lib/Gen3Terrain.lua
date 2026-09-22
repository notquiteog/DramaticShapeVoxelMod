-- Native General cliff masses. Raised rock caps and their steep bevels share
-- a continuous boundary height, so adjacent tiles cannot leave open cracks.
-- Only reviewed cliff artwork is raised; this is not a collision heightmap.
local M={}
local function solid(c)
 if not c or c.shape and c.shape.kind=='cliff' then return true end
 local g=c.civic
 return g and g.custom and g.custom.geometry=='tower' and c.cy>=g.cy+(g.northRows or 0)
end
function M.height(cells,x,z,height)
 local cx,cy=math.floor(x/16),math.floor(z/16)
 local distance=4
 for y=cy-1,cy+1 do for xx=cx-1,cx+1 do
  if not solid(cells[xx..':'..y])then
   local dx=math.max(xx*16-x,0,x-(xx+1)*16)
   local dz=math.max(y*16-z,0,z-(y+1)*16)
   distance=math.min(distance,math.sqrt(dx*dx+dz*dz))
  end
 end end
 return (height or 32)*math.min(1,distance/4)
end
function M.append(cells,c,emit,uvFor)
 local x,z=c.cx*16,c.cy*16;local height=c.shape.height or 32
 local cap=assert(uvFor(c.ts,113));local cliff=assert(uvFor(c.ts,121))
 local function sub(uv,a,b,u,v)
  local l,r=uv[1][1],uv[2][1];local t,d=uv[1][2],uv[3][2]
  local function p(xx,zz)return {l+(r-l)*xx/16,t+(d-t)*zz/16}end
  return {p(a,b),p(u,b),p(u,v),p(a,v)}
 end
 for iz=0,3 do for ix=0,3 do
  local a,b=ix*4,iz*4;local u,v=a+4,b+4
  local h1,h2=M.height(cells,x+a,z+b,height),M.height(cells,x+u,z+b,height)
  local h3,h4=M.height(cells,x+u,z+v,height),M.height(cells,x+a,z+v,height)
  local flat=h1==height and h2==height and h3==height and h4==height
  local tex
  if flat then tex=sub(cap,a,b,u,v)
  else
   -- Follow the cliff's horizontal tangent on either axis. Using each
   -- quad's U=0..1 compressed four repetitions into every source tile.
   local alongZ=math.abs(h1-h2)+math.abs(h4-h3)>math.abs(h1-h4)+math.abs(h2-h3)
   local function side(xx,zz,h)
    return {cliff[1][1]+((alongZ and zz or xx)/16)*(cliff[2][1]-cliff[1][1]),
     cliff[1][2]+(1-h/height)*(cliff[3][2]-cliff[1][2])}
   end
   tex={side(a,b,h1),side(u,b,h2),side(u,v,h3),side(a,v,h4)}
  end
  emit({{x+a,h1,z+b},{x+u,h2,z+b},{x+u,h3,z+v},{x+a,h4,z+v}},tex,flat and 1 or .84)
 end end
end
return M
