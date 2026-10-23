local clock=0
love={timer={getTime=function()clock=clock+.001;return clock end}}
local B=dofile('lib/BuildBudget.lua')
local fits,infos=0,0
local Models={info=function()infos=infos+1;error('placement must not clone model metadata')end,
 fit=function(id,o)
  fits=fits+1;if id=='absent'then return nil,'unknown scenery model'end
  return {bounds={.25,0,.25,o.width-.25,30,o.depth-.25},anchors={}}
 end}
local modules={BuildBudget=B,SceneryModels=Models,TreePresentation={voxel=function()return true end},
 CommunityVisuals={customTrees=function()return false end,customForest=function()return false end,customSafari=function()return false end}}
local T=assert(loadfile('lib/ImportedTrees.lua'))({require=function(n)return assert(modules[n],n)end})
local cells={}
for i=1,500 do
 local b={i*32,0,i*32+32,32}
 for y=0,1 do for x=i*2,i*2+1 do cells[x..':'..y]={cx=x,cy=y,base=0,collision=7,
  shape={kind='tree',root=x==i*2 and y==0,treeBounds=b,importedTreeModel=i==500 and'absent'or'present'}}end end
end
for i=1,3929 do cells['empty'..i]={cx=i,cy=4}end
local synchronous=T.gen3Placements(cells)
assert(#synchronous==499 and fits==500 and infos==0,'missing source fallback/fit count changed')
local result;local co=coroutine.create(function()result=T.gen3Placements(cells)end)
local yields=0
repeat
 B.begin(co,0)
 local ok,why=coroutine.resume(co);B.finish();assert(ok,why)
 if coroutine.status(co)~='dead'then
  assert(why=='budget'and result==nil,'partial list escaped cooperative scan');yields=yields+1
  for _,c in pairs(cells)do assert(c.importedTree==nil,'yield hid native fallback')end
 end
until coroutine.status(co)=='dead'
assert(yields>=185,'long scan did not split within32cells')
assert(#result==#synchronous and fits==1000 and infos==0)
for i,p in ipairs(result)do
 local q=synchronous[i]
 assert(p.source==q.source and p.x==q.x and p.z==q.z and p.model==q.model,'yield changed placement/order')
end
print(('PASS 5929-cell placement scan: %d budget yields, identical sorted placements, no metadata clones or premature ownership'):format(yields))
