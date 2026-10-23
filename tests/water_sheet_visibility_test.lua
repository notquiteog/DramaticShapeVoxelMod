local planes=assert(dofile('lib/FrustumCull.lua').prepare({1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}))
local cast,copies,draws=0,0,{}
local R={curveK=0,size=function()return 640,360 end,depthReadable=function()return true end,
 beginCast=function()cast=cast+1;return {}end,endCast=function()end,
 beginWater=function()copies=copies+1;return {},{}end,endWater=function()end,
 draw=function(mesh)draws[#draws+1]=mesh end}
local W={CAST_ALPHA=1,enabled=function()return true end,level=function()return 2 end,
 begin=function()return true end,finish=function()end,draw=R.draw}
local modules={Voxel3D=R,Water=W,VoxelGrid={enabled=function()return false end},FrustumCull=dofile('lib/FrustumCull.lua')}
local P=assert(loadfile('lib/WaterSurfacePass.lua'))({require=function(n)return assert(modules[n],n)end})
local options={frustum=planes,nativeWater=true,plane=0}
local left={'left',{},nil,0,bounds={-4,0,-.5,-2,0,.5}}
local right={'right',{},nil,0,bounds={2,0,-.5,4,0,.5}}
local inside={'inside',{},nil,0,bounds={-.5,0,-.5,.5,0,.5}}
local function run(list)return P.draw(list,nil,function()end,options)end
assert(not run({left,right})and cast==0 and copies==0 and #draws==0,'empty visible union still paid reflection passes')
assert(run({left,inside,right})and cast==1 and copies==1 and #draws==1 and draws[1]=='inside')
local unknown={'unknown',{},nil,0};local transformed={'model',{}, {},0,bounds=left.bounds}
assert(run({unknown,transformed})and draws[2]=='unknown'and draws[3]=='model','unknown/transformed sheet incorrectly rejected')
R.curveK=.001;local old=#draws
assert(run({left,right})and #draws==old+4,'curve needs both original prepass and water sheets')
R.curveK=0;options.frustum=nil;R.vp=nil;old=#draws
assert(run({left,right})and #draws==old+2,'invalid camera must fail open')
assert(left[1]=='left'and right[1]=='right','cached source draw list mutated')
print('PASS disjoint water sheet rejection avoids entire offscreen reflection passes; order, unknown bounds/model, curve and invalid-camera fallbacks')
