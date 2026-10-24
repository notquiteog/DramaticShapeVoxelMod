local source=dofile('lib/CeladonShortHouseData.lua')
local modules={SceneryModelData={},CeladonShortHouseData=source,SharedModelMesh=dofile('lib/SharedModelMesh.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end},require=function(n)return assert(modules[n],n)end}
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local F=assert(loadfile('lib/Gen3CeladonShortHouseFlowers.lua'))(V);modules.Gen3CeladonShortHouseFlowers=F
local H=assert(loadfile('lib/Gen3ImportedCeladonShortHouse.lua'))(V)
local rows={{729,730,730,774},{736,737,737,740},{744,745,747,748},{784,785,786,787}}
local g={cx=29,cy=33,width=4,depth=4,family='celadon_short_block',pair='general__rom_082d4b3c',groundHeight=2}
local region={x=9,y=7,def={id='FR_CELADON_CITY'}};local cells={}
for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={mid=mid,collision=y==1 and 0 or 7,civic=g,pair=g.pair,base=y==1 and 9 or 2,region=region}end end
assert(H.eligible(g,cells))
for key,value in pairs{family='celadon_tall_block',width=5,depth=5,pair='general__rom_082d4b9c',cx=30,stageHidden=true}do local old=g[key];g[key]=value;assert(not H.eligible(g,cells),key);g[key]=old end
local c=cells['29:34']
for key,value in pairs{mid=0,collision=113,base=3,boundary=true,stageHidden=true,prop=true,civic=false}do local old=c[key];c[key]=value;assert(not H.eligible(g,cells),key);c[key]=old end
region.def.id='FR_SAFFRON_CITY';assert(not H.eligible(g,cells));region.def.id='FR_CELADON_CITY'
assert(H.register());assert(not H.build(g,cells,function()error('missing owned source must prevent upload')end,{}));assert(not g.importedCeladonShortHouse)
local original=S.buildBatches;local released=0
S.buildBatches=function(placements,_,opts)
 local p=placements[1];assert(p.x==g.cx*16 and p.z==(g.cy+1)*16 and p.y==2)
 local parts,fit=assert(S.vertices(p.model,p.fit));assert(fit.bounds[4]-fit.bounds[1]>51 and fit.bounds[6]-fit.bounds[3]>47)
 local seen,triangles={},0
 for _,part in ipairs(parts)do
  seen[part.name]=true;assert(part.role~='source_shading'and part.role~='source_door');triangles=triangles+#part.indices/3
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25 and v[1]<=63.75 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6 and v[2]>=-.05-1e-6)end
 end
 for _,name in ipairs{'rear_wall','rear_roof_fascia','roof_soffit','closed_foundation'}do assert(seen['authored_'..name],name)end
 assert(triangles==140 and modules.Gen3ImportedGyms.clearance(g,cells,parts))
 local vertices,indices=F.geometry(g,fit);assert(#indices==72 and #vertices==72)
 for _,v in ipairs(vertices)do
  assert(#v==13 and v[3]==v[12],'flowers must be flat source cards')
  local radius=math.abs(v[1]-v[11]);local ax,az=v[11]-g.cx*16,v[12]-(g.cy+1)*16
  assert(ax-radius>=.25-1e-6 and ax+radius<=63.75+1e-6 and az-radius>=.25-1e-6 and az+radius<=47.75+1e-6,'billboard yaw crossed original blocked footprint')
 end
 opts.parts[#opts.parts+1]={mesh={release=function()released=released+1 end}}
 return opts.parts
end
S.image=function()return{}end
local parts={};assert(H.build(g,cells,function(v,i,format)assert(format==F.FORMAT and #i==72);return{setTexture=function()end,release=function()released=released+1 end}end,parts));assert(#parts==2 and parts[2].role=='hd2d_flower_cards'and parts[2].count==8 and g.importedCeladonShortHouse.model==H.id)
-- Failed flower upload rolls back the complete architectural placement.
g.importedCeladonShortHouse=nil;parts={};assert(not H.build(g,cells,function()return nil end,parts));assert(#parts==0 and released==1 and not g.importedCeladonShortHouse)
S.buildBatches=original
local recipe;for _,r in ipairs(dofile('data/gen3_exteriors.lua'))do if r.name=='celadon_short_block'then recipe=r end end
assert(recipe and not recipe.ground,'existing local native lawn donors must remain unchanged')
print('PASS exact Celadon short drawing/uniform fit/closed source, eight HD2D groups/full-yaw containment and failed-card atomic fallback')
