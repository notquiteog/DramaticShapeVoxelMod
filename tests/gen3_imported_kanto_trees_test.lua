local K=dofile('lib/Gen3ImportedKantoTrees.lua')
local function fixture()
 return{mid=0x24,pair='pallet_outdoor',primary='general',region={def={id='FR_PALLET_TOWN'}},
  shape={kind='tree',root=true,treeBounds={16,32,48,64}}}
end
local c=fixture();local s=c.shape;assert(K.select(c)==K.model)
assert(not c.importedTree and not s.importedTreeModel,'source selection must not claim native cells')
for _,size in ipairs{{32,16},{16,32},{16,16},{48,32},{48,48}}do
 local q=fixture();q.shape.treeBounds={0,0,size[1],size[2]}
 assert(not K.select(q),'cropped or different family footprint selected')
end
for _,field in ipairs{'treeRows','spacing','treePalette','importedTreeModel'}do
 local q=fixture();q.shape[field]=true;assert(not K.select(q),field..'source override ignored')
end
for _,family in ipairs{'round','broad','sapling','ash','tiered','mossdeep'}do
 local q=fixture();q.shape.treeFamily=family;assert(not K.select(q),'foreign source family selected')
end
c=fixture();c.shape.treeFamily='conifer';assert(K.select(c)==K.model)
c=fixture();c.mid=0x289;assert(not K.select(c),'Berry Forest uses different source art')
c=fixture();c.pair='general__third_party';assert(not K.select(c),'unknown pair selected by numeric mid')
c=fixture();c.primary='building';assert(not K.select(c),'interior source selected')
c=fixture();c.shape.root=false;assert(not K.select(c),'non-owner selected')
c=fixture();c.region.def.id='EM_OLDALE_TOWN';assert(not K.select(c),'Hoenn source selected')
c=fixture();c.region.def.id='SEVII_ONE_ISLAND';assert(K.select(c)==K.model)
c=fixture();c.region={mapId='FR_ROUTE_1'};assert(K.select(c)==K.model,'connected-map identity lost')
c=fixture();c.region=nil;assert(K.select(c,{mapId='FR_VIRIDIAN_CITY'})==K.model)
assert(not K.select(c));assert(K.select(c,{region='kanto'})==K.model)
-- The existing uploader's complete-cell safeguards still gate this explicit
-- source. A selector result by itself never hides the original solid model.
local modules={TreePresentation={voxel=function()return true end},CommunityVisuals={customTrees=function()return false end,customForest=function()return false end,customSafari=function()return false end},
 SceneryModels={info=function(id)return id==K.model end,fit=function(_,o)return{bounds={.25,0,.25,o.width-.25,39,o.depth-.25},anchors={}}end}}
local T=assert(loadfile('lib/ImportedTrees.lua'))({require=function(n)return assert(modules[n],n)end})
local b={16,32,48,64};local cells={}
for y=2,3 do for x=1,2 do cells[x..':'..y]={cx=x,cy=y,mid=0x24,collision=7,base=0,shape={kind='tree',root=x==1 and y==2,treeBounds=b,importedTreeModel=K.model},region={def={id='FR_PALLET_TOWN'}}}end end
local root=cells['1:2'];assert(T.gen3Placement(root,cells))
cells['2:3'].collision=0;assert(not T.gen3Placement(root,cells),'native walking corner covered')
cells['2:3'].collision=7;cells['2:3'].base=6;assert(not T.gen3Placement(root,cells),'native elevation flattened')
assert(not root.importedTree,'selection/failed fit hid native fallback')
print('PASS exact Kanto General art, native full32x32 owners, fragment/foreign-family standdown, connected context and existing blocked/elevation guards')
