local state={angle=0,FOCAL=1,isFirstPerson=function()return true end,isThirdPerson=function()return false end}
-- VoxelState is a fixture, and Mat4/AtmosphereCamera are real. Everything else
-- resolves off disk rather than becoming an empty table: `return {}` is why
-- this suite died on a nil `shader` concat inside Voxel3D instead of on the
-- camera projection it exists to check. See tests/modload.lua.
local MODLOAD=assert(loadfile('tests/modload.lua'))()
local V={require=function(name)
 if name=='VoxelState'then return state end
 return MODLOAD.load(name)
end}
local R=assert(loadfile('lib/Voxel3D.lua'))(V)
R.camera={eye={0,5,10},focus={0,5,0},up={0,1,0},fov=1}
R.viewProjection(0,0,100,100)
assert(R.atmosphereCameraCandidate.far==4136 and R.atmosphereCameraCandidate.near==1)
assert(R.atmosphereCameraCandidate.mode=='first_person' and R.atmosphereCameraCandidate.overhead)
R.camera.eye[1]=2;assert(R.atmosphereCameraCandidate.eye[1]==0)
R.camera.view={};R.viewProjection(0,0,100,100);assert(R.atmosphereCameraCandidate==nil,'external eye published as center')
R.camera=nil;state.isFirstPerson=function()return false end
R.viewProjection(0,0,100,100)
assert(R.atmosphereCameraCandidate.far==4496 and not R.atmosphereCameraCandidate.overhead)
assert(R.atmosphereCameraCandidate.up[3]==-1)
print('PASS actual Voxel3D placed/orbit projection facts and external-eye exclusion')
