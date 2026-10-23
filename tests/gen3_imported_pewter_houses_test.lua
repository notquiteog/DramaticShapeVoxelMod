local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),PewterHouseData=dofile('lib/PewterHouseData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3PewterHouseDoors.lua'))(V);modules.Gen3PewterHouseDoors=D
local H=assert(loadfile('lib/Gen3ImportedPewterHouses.lua'))(V)
local rows={{687,702,702,702,655},{695,710,688,689,663},{703,718,696,697,671}}
local g={cx=8,cy=28,width=5,depth=3,custom={},pair='pewter_outdoor',family='pewter_house',groundHeight=3}
local cells={};for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={mid=mid,pair=g.pair,civic=g,base=3,collision=y==3 and x==2 and 0x71 or 7}end end
assert(H.eligible(g,cells));local c=cells['8:28']
for _,k in ipairs{'boundary','stageHidden','prop'}do c[k]=true;assert(not H.eligible(g,cells),k);c[k]=nil end
for k,v in pairs{mid=0,collision=0,base=4,pair='viridian_outdoor',civic=false}do local old=c[k];c[k]=v;assert(not H.eligible(g,cells),k);c[k]=old end
local door=cells['9:30'];door.collision=7;assert(not H.eligible(g,cells));door.collision=0x71
assert(H.register());assert(not H.build(g,cells,function()error('unexpected upload without image')end,{}));assert(not g.importedPewterHouse)
D.build=function(g,fit)g.importedPewterDoors={};return true end;D.commit=function()end
S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);assert(p.x==128 and p.y==3 and p.z==448)
 local parts,fit=assert(S.vertices(p.model,p.fit));assert(math.abs(fit.anchors.door[1]-24)<1e-6 and math.abs(fit.anchors.door[3]-40)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>63 and fit.bounds[4]-fit.bounds[1]<64,'source footprint must remain substantial')
 local base,rear,soffit=false,false,false
 for _,part in ipairs(parts)do
  assert(part.role~='source_shading'and part.role~='ground_shadow','baked illumination excluded')
  assert(part.role~='source_door','static door must not remain in body batch');base=base or part.name=='authored_closed_foundation';rear=rear or part.name=='authored_rear_gable';soffit=soffit or part.name=='authored_pitched_roof_soffit'
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6 and v[2]>=-.05-1e-6)end
 end
 assert(base and rear and soffit);return opts.parts
end
assert(H.build(g,cells,function()end,{}));local d=assert(H.doorSurface(g,9,30));assert(d.w==14 and d.h==16 and d.base==3)
assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-152)<1e-6);assert(d.vertices[1][2]>d.vertices[4][2]);assert(not H.doorSurface(g,10,30));assert(H.chimney(g).y>40)
assert(c.civic==g and door.collision==0x71,'source permissions and ownership unchanged')
print('PASS Pewter HGSS house exact drawing/permission/level/ownership guards, blocked fit, source door, chimney, unbaked geometry and upload fallback')
