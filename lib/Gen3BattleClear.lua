-- Whole-object visibility for a battle clearing and its camera corridor.
-- Never touch source map cells or collision; the field rebuild restores them.
local M={}
function M.hits(camera,x0,z0,x1,z1)
 if not (camera and camera.battle and camera.center)then return false end
 local x,z=camera.center[1],camera.center[2]
 local nx,nz=math.max(x0,math.min(x1,x)),math.max(z0,math.min(z1,z))
 if (nx-x)^2+(nz-z)^2<48^2 then return true end
 local dx,dz=math.sin(camera.yaw),-math.cos(camera.yaw)
 local ax,az=x-dx*80,z-dz*80
 local bx,bz=x+dx*24,z+dz*24
 -- Segment versus an expanded footprint: the full camera corridor clears
 -- fences, complete buildings and trees, rather than slicing their triangles.
 local lo,hi=0,1
 for _,a in ipairs({{ax,bx-ax,x0-22,x1+22},{az,bz-az,z0-22,z1+22}})do
  if math.abs(a[2])<1e-7 then
   if a[1]<a[3] or a[1]>a[4]then return false end
  else
   local t,u=(a[3]-a[1])/a[2],(a[4]-a[1])/a[2]
   lo,hi=math.max(lo,math.min(t,u)),math.min(hi,math.max(t,u))
   if lo>hi then return false end
  end
 end
 return true
end
return M
