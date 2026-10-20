local mode,custom,walk,height,available='modeled',false,false,0,true
local fail,yieldUpload=false,false;local released,draws,ambient=0,0,0
package.loaded['src.world.gen2.Permissions']={WALL='wall',of=function(c)return c==7 and'wall'or c==41 and'water'or'land'end}
local Models={info=function()return available and{}or nil end,
 fit=function(_,o)return{bounds={.25,0,.25,o.width-.25,28.7,o.depth-.25},anchors={canopyBottom={0,7,0}}}end,
 retryImages=function()end,
 releaseBatches=function(parts)for _,p in ipairs(parts)do if p.mesh then p.mesh:release();p.mesh=nil end end end}
function Models.buildBatches(list,upload,opts)
 assert(#list==1 and opts.parts and type(upload)=='function')
 opts.parts[1]={mesh={release=function()released=released+1 end},image={},count=1}
 if yieldUpload then coroutine.yield()end
 if fail then Models.releaseBatches(opts.parts);opts.parts[1]=nil;return nil,'unavailable'end
 return opts.parts
end
local modules={SceneryModels=Models,TreePresentation={voxel=function()return mode=='modeled'end},
 CommunityVisuals={customTrees=function()return custom end,customForest=function()return false end,customSafari=function()return false end},
 Gen2Elevation={at=function(_,x,z)return x==56 and z==40 and height or 0 end},
 KfpTreeDetails={record=function()ambient=ambient+1 end},NativeTreeArt={
 appendModel=function(card,v,i,_,x,y,z)v[#v+1]={x,y,z};i[#i+1]=#v end,foliageFloor=function()return 4 end}}
local T=assert(loadfile('lib/ImportedTrees.lua'))({require=function(n)return assert(modules[n],n)end})
local map={id='ILEX_FOREST',width=8,height=8,def={width=8,height=8},cells={}}
function map:cellCollision(x,y)return self.cells[x..':'..y]or 7 end
function map:isWalkableCell()return walk end
local card={w=32,h=48,bottom=2}
local function part()return{dV={},dI={}}end
local p=assert(T.gbPlacement(map,2,3,20,6));assert(p.x==32 and p.z==32 and p.y==6 and p.treeInfo.height==28.7)
assert(not T.gbPlacement(map,2,3,10,6),'one-cell round tree forced to miniature imported style')
assert(not T.gbPlacement(map,2,0,20,6),'outside-map owner claimed')
for _,c in ipairs{0,24,41}do map.cells['3:2']=c;assert(not T.gbPlacement(map,2,3,20,6),'walkable/water corner claimed')end;map.cells={}
walk=true;assert(not T.gbPlacement(map,2,3,20,6));walk=false
height=6;assert(not T.gbPlacement(map,2,3,20,6),'native height transition flattened');height=0
for _,a in ipairs{'original','illustrated'}do mode=a;assert(not T.gbPlacement(map,2,3,20,6))end;mode='modeled'
custom=true;assert(not T.gbPlacement(map,2,3,20,6));custom=false
available=false;assert(not T.gbPlacement(map,2,3,20,6));available=true
local section=part();assert(T.queueGB(section,map,2,3,20,6,card,48,48))
local resources={};T.buildGB(section,function()end,resources)
assert(section.importedTreeParts and section.importedTreeOwner and next(resources),'built resources unowned')
T.drawGB(section,function(mesh,image,model)assert(mesh and image and model=='neighbor');draws=draws+1 end,'neighbor')
assert(draws==1 and ambient==1 and #section.dV==0)
T.releaseGB(section,resources);assert(not next(resources)and not section.importedTreeParts and released==1)
T.releaseGB(section,resources);assert(released==1,'resource released twice')
fail=true;section=part();assert(T.queueGB(section,map,2,3,20,6,card,48,48));T.buildGB(section,function()end,resources)
assert(#section.dV==1 and #section.dI==1 and not section.importedTreeOwner and not next(resources),'missing texture failed to restore original closed 3D model')
fail=false;yieldUpload=true;section=part();T.queueGB(section,map,2,3,20,6,card,48,48)
local co=coroutine.create(function()T.buildGB(section,function()end,resources)end)
assert(coroutine.resume(co)and coroutine.status(co)=='suspended')
local owner=next(resources);assert(owner and owner.parts[1].mesh,'partial upload not owned before yield')
owner:release();resources[owner]=nil;assert(not owner.parts,'cancellation retained GPU geometry')
print('PASS GB broad-tree native bounds/levels, water/card/custom standdown, per-section source batches, late failure fallback and cancellation ownership')
