local art,custom,forest,safari='modeled',false,false,false
local success=true;local calls=0
local Models={}
function Models.info(id)assert(id=='oras_route104_broadleaf');return{bounds={0,0,0,10,20,10}}end
function Models.fit(id,opts)
 return{bounds={.25,0,.25,opts.width-.25,2*math.min(opts.width,opts.depth),opts.depth-.25},anchors={canopyBottom={0,12,0}}}
end
function Models.buildBatches(list,upload,opts)
 calls=calls+1;assert(type(upload)=='function'and type(opts.parts)=='table')
 if not success then return nil,'missing texture'end
 return opts.parts
end
local modules={BuildBudget={check=function()end},SceneryModels=Models,TreePresentation={voxel=function()return art=='modeled'end},CommunityVisuals={
 customTrees=function()return custom end,customForest=function()return forest end,customSafari=function()return safari end}}
local T=assert(loadfile('lib/ImportedTrees.lua'))({require=function(name)return assert(modules[name],name)end})
local function fixture(w,d,id,family)
 local cells={};local b={32,48,32+w*16,48+d*16};local region={def={id=id or'EM_OLDALE_TOWN'}}
 for y=3,3+d-1 do for x=2,2+w-1 do cells[x..':'..y]={cx=x,cy=y,base=6,collision=7,region=region,mid=28,
  shape={kind='tree',root=x==2 and y==3,treeBounds=b,treeFamily=family,ground=1}}
 end end
 return cells,cells['2:3']
end
local cells,c=fixture(2,2)
local p=assert(T.gen3Placement(c,cells));assert(p.x==32 and p.y==6 and p.z==48 and p.fit.width==32 and p.fit.depth==32)
assert(p.treeInfo.height==64 and p.treeInfo.canopyBottom==12)
local owned={};assert(T.buildGen3(cells,function()end,owned)==owned and c.importedTree==p.treeInfo or c.importedTree.height==64)
local fit=Models.fit;Models.fit=function()return{bounds={.25,0,.25,31.75,14.1,15.75},anchors={}}end
assert(not T.fitPlacement({0,0,32,16},0,0),'mature source model shrank into a tiny fragment tree')
Models.fit=fit
local mid,coll,base=c.mid,c.collision,c.base
cells,c=fixture(2,2);success=false;assert(not T.buildGen3(cells,function()end,{})and not c.importedTree)
success=true;assert(c.mid==mid and c.collision==coll and c.base==base,'native data mutated')
for _,key in ipairs{'prop','civic','stageHidden'}do c[key]=true;assert(not T.gen3Placement(c,cells),key..'claimed');c[key]=nil end
for _,coll in ipairs{0,24,41}do cells['3:4'].collision=coll;assert(not T.gen3Placement(c,cells),'walkable corner claimed')end
cells['3:4'].collision=7;cells['3:4'].base=10;assert(not T.gen3Placement(c,cells),'uneven owner levels flattened');cells['3:4'].base=6
local q=cells['3:4'];cells['3:4']=nil;assert(not T.gen3Placement(c,cells),'missing corner claimed');cells['3:4']=q
q.stageHidden=true;assert(not T.gen3Placement(c,cells),'battle-cleared corner claimed');q.stageHidden=nil
q.shape.treeBounds={32,48,64,80};assert(not T.gen3Placement(c,cells),'foreign tree owner claimed');q.shape.treeBounds=c.shape.treeBounds
custom=true;assert(#T.gen3Placements(cells)==0,'explicit tree family replaced');custom=false
for _,mode in ipairs{'original','illustrated'}do art=mode;assert(#T.gen3Placements(cells)==0,'card optout ignored')end;art='modeled'
cells,c=fixture(1,1);assert(not T.gen3Placement(c,cells),'fragment made miniature imported tree')
cells,c=fixture(2,1);assert(T.gen3Placement(c,cells),'complete two-cell owner rejected')
cells,c=fixture(4,1);assert(not T.gen3Placement(c,cells),'thin elongated tree distorted')
cells,c=fixture(2,2,'FR_VIRIDIAN_CITY');assert(not T.gen3Placement(c,cells),'Kanto conifer changed family')
cells,c=fixture(2,2,'FR_VIRIDIAN_CITY','round');assert(T.gen3Placement(c,cells),'matching Kanto round family rejected')
cells,c=fixture(3,2,'FR_VIRIDIAN_FOREST','broad');forest=true;assert(not T.gen3Placement(c,cells),'custom forest stolen');forest=false
cells,c=fixture(3,2,'FR_VIRIDIAN_FOREST','broad');for _,q in pairs(cells)do q.region=nil end
forest=true;assert(not T.gen3Placement(c,cells,{mapId='FR_VIRIDIAN_FOREST'}),'synthetic tree ignored fallback map override');forest=false
cells,c=fixture(3,2,'FR_VIRIDIAN_FOREST','broad');c.region.def.id=nil;c.region.mapId='FR_VIRIDIAN_FOREST'
forest=true;assert(not T.gen3Placement(c,cells,{mapId='FR_ROUTE_2'}),'neighbor forest used the current map override');forest=false
cells,c=fixture(3,2,'FR_SAFARI_ZONE_CENTER','broad');safari=true;assert(not T.gen3Placement(c,cells),'custom safari stolen');safari=false
for _,family in ipairs{'ash','sapling'}do cells,c=fixture(2,2,'EM_OLDALE_TOWN',family);assert(not T.gen3Placement(c,cells))end
cells,c=fixture(2,2);c.shape.root=false;assert(not T.gen3Placement(c,cells),'projected native crown gained trunk')
cells,c=fixture(2,2);for _,n in pairs(cells)do n.collision=nil;n.boundary='forest'end;assert(T.gen3Placement(c,cells),'approved synthetic forest rejected')
c.collision=0;assert(not T.gen3Placement(c,cells),'boundary label overrode real walkable permission')
cells,c=fixture(2,2,'THIRD_PARTY_REGION');assert(T.gen3Placement(c,cells,{region='hoenn'}),'third-party region context rejected')
print('PASS imported-tree native blocked rectangle, slope/corner/owner guards, explicit cards/custom families, fragments and safe asset failure')
