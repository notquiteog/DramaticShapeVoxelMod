-- Conservative world AABB rejection for undeformed, identity-model geometry.
-- Opt in only for the current main-pass VP with curve/pull/canopy deformation
-- disabled. Camera rejection must NEVER filter the shadow caster pass.
local M={}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end

-- Row-major clip coordinates, before perspective division. Using -w <= z <= w
-- also remains conservative on backends clipping z at zero instead of -w.
-- Prepare once per camera/pass; the snapshot never aliases a mutable VP.
function M.prepare(vp)
 if type(vp)~='table'then return end
 for i=1,16 do if not finite(vp[i])then return end end
 local planes={}
 for axis=0,2 do for sign=-1,1,2 do
  local p={}
  for c=1,4 do
   p[c]=vp[12+c]+sign*vp[axis*4+c]
   -- Bound original row magnitudes too: cancellation in extracted planes
   -- must not hide the float rounding of the shader's separate dot products.
   p[4+c]=math.abs(vp[12+c])+math.abs(vp[axis*4+c])
  end
  planes[#planes+1]=p
 end end
 return planes
end

-- bounds = {minX,minY,minZ,maxX,maxY,maxZ}, covering ALL placed vertices.
-- True means draw (including ambiguous/invalid inputs); false proves the box
-- is wholly outside at least one clip plane. No temporal or visibility cache.
function M.visible(planes,bounds)
 if not planes or type(bounds)~='table'then return true end
 for i=1,6 do if not finite(bounds[i])then return true end end
 local x,y,z,X,Y,Z=bounds[1],bounds[2],bounds[3],bounds[4],bounds[5],bounds[6]
 if x>X or y>Y or z>Z then return true end
 local ax,ay,az=math.max(math.abs(x),math.abs(X)),math.max(math.abs(y),math.abs(Y)),math.max(math.abs(z),math.abs(Z))
 for _,p in ipairs(planes)do
  local px,py,pz=p[1]>=0 and X or x,p[2]>=0 and Y or y,p[3]>=0 and Z or z
  local distance=p[1]*px+p[2]*py+p[3]*pz+p[4]
  -- Deliberately generous highp float margin; edge-touching geometry stays.
  local margin=1e-4*(p[5]*ax+p[6]*ay+p[7]*az+p[8]+1)
  if distance < -margin then return false end
 end
 return true
end
return M
