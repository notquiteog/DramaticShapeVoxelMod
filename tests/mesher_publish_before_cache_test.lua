-- Exercise the production scheduler/publication order, isolating geometry and GPU.
-- Internal substitutions are confined to this test; no native engine hooks.
local now=0
love={timer={getTime=function()return now end}}
package.loaded['src.render.Assets']={register=function()end}
local B=dofile('lib/BuildBudget.lua')
local saved,trees,meshes=0,0,{}
local Timings={wrap=function(_,f)return f end,resume=coroutine.resume,cancel=function()end,jobError=function()end}
local mods={BuildBudget=B,LoadTimings=Timings,CacheTrace={log=function()end},
 VoxelMeshDisk={available=function()return false end,loadTerrain=function()end,
  saveTerrain=function()saved=saved+1;return true end},
 CommunityFlora={requestCommunityTrees=function()trees=trees+1 end}}
local V={require=function(n)return mods[n]or{}end}
local M=assert(loadfile('lib/ChunkMesher.lua'))(V)
local function slot(fn,name,value)
 for i=1,100 do local k,v=debug.getupvalue(fn,i);if not k then break end
  if k==name then if value~=nil then debug.setupvalue(fn,i,value)end;return v end
 end
 error('missing fixture seam '..name)
end
local run=slot(M.pump,'runJob')
local entries={}
slot(run,'entry',function(id)
 entries[id]=entries[id]or{grass=false,flowers=false,figures=false};return entries[id]
end)
slot(run,'mapHasVisualObjects',function()return false end)
slot(run,'runGeometry',function()end)
slot(run,'newSink',function()
 local mesh={};meshes[#meshes+1]=mesh
 return{finish=function()return mesh end,raw=function()return{n=6,spans={}}end}
end)
local a={id='A'}
M.request(a,false,nil,true);M.pump(false)
assert(entries.A.full==meshes[1] and entries.A.fullWater==meshes[2])
assert(trees==1 and saved==0,'encoding blocked terrain/tree publication')
assert(M.pending()==1 and M.jobPriority('A',false)==1.99,'cache persistence lost lifecycle or foreground priority')
local background=false
M.requestWork({id='NEIGHBOR'},'far','one',1.9,function()background=true end)
local visible=false
M.requestWork({id='B'},'visible','one',2,function()visible=true;now=now+.01 end)
M.pump(false)
assert(visible and saved==0,'optional encoding ran ahead of visible neighbor work')
M.pump(false);assert(saved==1 and background and M.pending()==0,'deferred encoding did not finish')
-- A canceled/changed map must not persist stale geometry after publication.
local b={id='C'};M.request(b,false,nil,true);M.pump(false)
assert(saved==1 and entries.C.full)
slot(run,'gen').C=1
M.pump(false);assert(saved==1 and background and M.pending()==0,'changed map persisted stale geometry')
local d={id='D'};M.request(d,true,nil,true);M.pump(false)
M.request(d,false,nil,true)
assert(M.jobPriority('D',true)==1.99,'published body cache was promoted over full terrain')
B.pause() -- synchronous callers never yield
print('PASS publish complete terrain before cache, prioritize visible work, retain cancellation and synchronous contract')
