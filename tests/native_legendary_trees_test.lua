local F=dofile('tests/legendary_tree_fixture.lua')
local before=#F.meshes;local registry=F.M.TRUNK.registry
local parts,x,z=F.flora.nativeTreeTemplate(1)
assert(#parts>0 and #F.meshes==before and F.M.TRUNK.registry==registry,'CPU template changed live resources')
local count=0
for _,p in ipairs(parts)do for _,key in ipairs{'tV','cV','dV'}do for _,v in ipairs(p[key])do assert(v[1]==v[1]and v[2]==v[2]and v[3]==v[3]);count=count+1 end end end
assert(count>1000 and x==40 and z==24)
assert(F.M.TRUNK.saplingHistory.__BAV_NATIVE_TREE_1==nil,'template history leaked')
local co=coroutine.create(function()F.flora.nativeTreeTemplate(2)end);local resumed=0
local Budget=F.V.require('BuildBudget')
while coroutine.status(co)~='dead'do Budget.begin(co,.0001,4);local ok,err=coroutine.resume(co);Budget.finish();assert(ok,err);resumed=resumed+1 end
assert(resumed>1 and F.M.treeContexts[co]==nil,'native templates bypassed cooperative budget or leaked context')
F.mods.TreePresentation.original=function()return true end
F.mods.ModelInstances={new=function()return nil end}
local M=assert(loadfile('lib/NativeLegendaryTrees.lua'))(F.V)
local cells={};for y=0,5 do for x=0,5 do cells[x..':'..y]={collision=7}end end
local groups={};local c={cx=2,cy=2,collision=7};assert(M.add({w=32,h=40},c,cells,groups,40,0,40))
assert(next(groups),'no real shared template')
local first=next(groups);for _,group in ipairs(first.groups)do for _,v in ipairs(group.vertices)do assert(math.abs(v[1])<=16.001 and math.abs(v[3])<=16.001 and v[2]>=0 and v[2]<=40.001)end end
for _,cell in pairs(cells)do cell.collision=0 end
assert(not M.add({w=32,h=40},c,cells,{},40,0,40),'walkable footprint claimed')
assert(not M.add({w=32,h=40,legendaryForest=true},c,cells,{},40,0,40),'forest override stolen')
F.mods.CommunityVisuals.customTrees=function()return false end
assert(not M.add({w=32,h=40},c,cells,{},40,0,40),'OFF consumed')
print('PASS actual Gen1 CPU templates, no live cache/GPU mutation, native bounds, collision/forest/OFF guards')
