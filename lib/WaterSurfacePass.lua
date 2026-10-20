-- A generation-neutral water pass using Battle Art's shared reflection shader.
-- Native adapters provide meshes and actor draws, never GB map objects.
local V=...
local R=V.require('Voxel3D')
local Water=V.require('Water')
local Grid=V.require('VoxelGrid')
local M={}
function M.draw(draws,cast,planarCast,options)
 if #draws==0 then return false end
 options=options or{}
 local curved=(R.curveK or 0)>0
 if curved then for _,d in ipairs(draws)do R.draw(d[1],d[2],d[3])end end
 local castTex
 if planarCast and Water.enabled() and Water.CAST_ALPHA>0 and R.depthReadable()then
  castTex=R.beginCast(options.plane or draws[1][4])
  if castTex then pcall(planarCast);R.endCast()end
 end
 local function context(mirror,depth)
  local w,h=R.size()
  return {reflect=mirror,depth=depth,cast=castTex,vp=R.vp,eye=R.eye,
   curve={R.curveX or 0,R.curveZ or 0,R.curveK or 0},screen={w,h},
   cell=R.cell,fov=R.fovY,skyEdge=R.skyEdge,grid=Grid.enabled(),
   lookFlat=R.lookFlat,descent=R.descent,nativeWater=options.nativeWater,
   underColor=options.underColor,underDepth=options.underDepth}
 end
 local reflected=false
 local function paint()
  for _,d in ipairs(draws)do Water.draw(d[1],d[2],d[3],d[5])end
  Water.finish();reflected=true
 end
 local full=not Water.level or Water.level()>=2
 if Water.enabled() and full and R.depthReadable()then
  local screenCast=cast
  if options.nativeWater and castTex then screenCast=nil end
  local mirror,depth=R.beginWater(screenCast)
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
