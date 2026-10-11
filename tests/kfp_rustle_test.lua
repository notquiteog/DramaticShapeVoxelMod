local time,draws,grass=0,0,true
love={timer={getTime=function()return time end},graphics={newMesh=function()return{setVertices=function()end,setDrawRange=function()end,release=function()end}end,newImage=function()return{setFilter=function()end,release=function()end}end},image={newImageData=function()return{setPixel=function()end,release=function()end}end}}
local map={inBounds=function()return true end,isGrassCell=function()return grass end,isWalkableCell=function()return true end,isWaterCell=function()return false end}
local M=assert(loadfile('lib/KfpSurfaceLife.lua'))({require=function(n)
 if n=='ModSetting'then return{new=function()return{get=function()return 'subtle'end}end}end
 if n=='KantoHabitat'then return{profile=function()return{}end,scan=function()return{green={{x=72,z=8}}}end}end
 if n=='NativeHabitat'then return{native=function()return true end}end
 if n=='VoxelScene'then return{groundAt=function()return 16 end}end
 if n=='Voxel3D'then return{draw=function()draws=draws+1 end}end
 error(n)
end})
math.random=function()error('ambient rustle uses gameplay RNG')end
local state={map=map,player={px=0,py=0}}
M.drawRustles(state);assert(M.lastRustleCount==5 and draws==1)
time=1;M.drawRustles(state);assert(M.lastRustleCount==0 and draws==1,'expired burst retained')
grass=false;time=3;M.drawRustles(state);assert(M.lastRustleCount==0,'non-grass emits seeds')
grass=true;time=6;M.drawRustles(state);assert(M.lastRustleCount==5)
M.invalidate()
print('PASS native ambient rustle isolation, five-particle limit, expiry and grass revalidation')
