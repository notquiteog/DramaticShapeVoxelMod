local mode,mirror,cast,screenActors,planarActors,paint,restore,seen='full',0,0,0,0,0,0,nil
local R={curveK=0,vp={},eye={},size=function()return 640,360 end,depthReadable=function()return true end,
 draw=function()paint=paint+1 end,beginCast=function(plane)assert(plane==6.05);cast=cast+1;return 'cast'end,
 endCast=function()end,beginWater=function(fn)mirror=mirror+1;if fn then fn()end;return 'mirror','depth'end,
 endWater=function()restore=restore+1 end}
local water={CAST_ALPHA=.5,level=function()return mode=='full'and 2 or mode=='sky'and 1 or 0 end,
 enabled=function()return mode~='off'end,begin=function(ctx,sky)seen={ctx,sky};return true end,
 draw=function()paint=paint+1 end,finish=function()end}
local Pass=assert(loadfile('lib/WaterSurfacePass.lua'))({require=function(n)return assert(({Voxel3D=R,Water=water,VoxelGrid={enabled=function()return false end}})[n])end})
local function run()return Pass.draw({{'mesh','image',nil,6.05}},function()screenActors=screenActors+1 end,function()planarActors=planarActors+1 end,{nativeWater=true,plane=6.05,underDepth='opaqueDepth'})end
assert(run()and mirror==1 and cast==1 and planarActors==1 and screenActors==0)
assert(seen[1].nativeWater and seen[1].underDepth=='opaqueDepth'and not seen[2])
mode='sky';assert(run()and mirror==1 and cast==2 and planarActors==2 and seen[2],'SKY copied a full reflection frame')
mode='off';assert(not run()and mirror==1 and cast==2 and paint==3,'OFF allocated water passes or lost native fallback')
assert(restore==2)
print('PASS native water plane binding, shared depth context, single actor reflection, cheap SKY and flat OFF state lifecycle')
