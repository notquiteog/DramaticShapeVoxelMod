-- A generation-neutral water pass using Battle Art's shared reflection shader.
-- Native adapters provide meshes and actor draws, never GB map objects.
local V=...
local R=V.require('Voxel3D')
local Water=V.require('Water')
local Grid=V.require('VoxelGrid')
local M={}
function M.draw(draws,cast,planarCast)
 if #draws==0 then return false end
 local curved=(R.curveK or 0)>0
 if curved then for _,d in ipairs(draws)do R.draw(d[1],d[2],d[3])end end
 local castTex
 if planarCast and Water.enabled() and Water.CAST_ALPHA>0 and R.depthReadable()then
  castTex=R.beginCast()
  if castTex then pcall(planarCast);R.endCast()end
 end
 local function context(mirror,depth)
  local w,h=R.size()
  return {reflect=mirror,depth=depth,cast=castTex,vp=R.vp,eye=R.eye,
   curve={R.curveX or 0,R.curveZ or 0,R.curveK or 0},screen={w,h},
   cell=R.cell,fov=R.fovY,skyEdge=R.skyEdge,grid=Grid.enabled(),
   lookFlat=R.lookFlat,descent=R.descent}
 end
 local reflected=false
 local function paint()
  for _,d in ipairs(draws)do Water.draw(d[1],d[2],d[3])end
  Water.finish();reflected=true
 end
 if Water.enabled() and R.depthReadable()then
  local mirror,depth=R.beginWater(cast)
  if mirror and depth and Water.begin(context(mirror,depth),false)then paint()end
  R.endWater()
 end
 if Water.enabled() and not reflected and Water.begin(context(),true)then
  paint();R.endWater()
 end
 if not reflected and not curved then
  for _,d in ipairs(draws)do R.draw(d[1],d[2],d[3])end
 end
 return reflected
end
return M
