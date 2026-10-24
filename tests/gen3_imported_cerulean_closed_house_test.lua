local modules={SceneryModelData={},CeruleanClosedHouseData=dofile('lib/CeruleanClosedHouseData.lua'),SharedModelMesh=dofile('lib/SharedModelMesh.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end},require=function(n)return assert(modules[n],n)end}
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local H=assert(loadfile('lib/Gen3ImportedCeruleanClosedHouse.lua'))(V)
local rows={{672,673,665,673,674},{680,681,681,681,682},{688,689,689,689,690},{696,694,704,703,698}}
local g={cx=40,cy=32,width=5,depth=4,family='cerulean_house_short',pair='general__rom_082d4af4',groundHeight=2}
local region={x=9,y=7,def={id='FR_CERULEAN_CITY'}};local cells={}
for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={mid=mid,collision=y==1 and 0 or 7,civic=g,pair=g.pair,base=y==1 and 9 or 2,region=region}end end
assert(H.eligible(g,cells))
for key,value in pairs{family='cerulean_house_north',width=6,depth=5,pair='general__rom_082d4b9c',cx=41,stageHidden=true}do local old=g[key];g[key]=value;assert(not H.eligible(g,cells),key);g[key]=old end
local c=cells['40:33']
for key,value in pairs{mid=0,collision=113,base=3,boundary=true,stageHidden=true,prop=true,civic=false}do local old=c[key];c[key]=value;assert(not H.eligible(g,cells),key);c[key]=old end
region.def.id='FR_SAFFRON_CITY';assert(not H.eligible(g,cells));region.def.id='FR_CERULEAN_CITY'
assert(H.register());assert(not H.build(g,cells,function()error('no source bytes must prevent upload')end,{}));assert(not g.importedCeruleanClosedHouse)
local original=S.buildBatches
S.buildBatches=function(placements,_,opts)
 local p=placements[1];assert(p.x==g.cx*16 and p.z==(g.cy+1)*16 and p.y==2)
 local parts,fit=assert(S.vertices(p.model,p.fit));assert(fit.bounds[4]-fit.bounds[1]>63 and fit.bounds[6]-fit.bounds[3]>47)
 local seen={};local triangles=0
 for _,part in ipairs(parts)do
  seen[part.name]=true;assert(part.role~='source_shading'and part.role~='source_door');triangles=triangles+#part.indices/3
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25 and v[1]<=79.75 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6 and v[2]>=-.05-1e-6)end
 end
 for _,name in ipairs{'rear_siding','rear_beam','rear_beam_return','rear_inner_gable','rear_roof_fascia','roof_soffit','closed_foundation'}do assert(seen['authored_'..name],name)end
 assert(triangles==206,'source/closure triangle count changed')
 assert(modules.Gen3ImportedGyms.clearance(g,cells,parts))
 return opts.parts
end
assert(H.build(g,cells,function()end,{}));assert(g.importedCeruleanClosedHouse.model==H.id)
S.buildBatches=function()return nil,'simulated GPU failure'end;g.importedCeruleanClosedHouse=nil
assert(not H.build(g,cells,function()end,{}));assert(not g.importedCeruleanClosedHouse)
S.buildBatches=original
local recipes=dofile('data/gen3_exteriors.lua');local recipe
for _,r in ipairs(recipes)do if r.name=='cerulean_house_short'then recipe=r end end
assert(recipe and recipe.ground==1 and recipe.rows[4][1]==696 and recipe.rows[4][5]==698,'native lawn foundation proof lost')
print('PASS exact closed Cerulean map/drawing/support/mask, uniform substantial fit, unbaked closed source and atomic fallback')
