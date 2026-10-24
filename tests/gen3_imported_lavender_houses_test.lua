local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),LavenderHouseData=dofile('lib/LavenderHouseData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3LavenderHouseDoors.lua'))(V);modules.Gen3LavenderHouseDoors=D
local H=assert(loadfile('lib/Gen3ImportedLavenderHouses.lua'))(V)
local rows={{648,649,650,651,652},{656,657,657,657,660},{664,665,666,667,668},{672,673,674,675,676}}
local g={cx=8,cy=28,width=5,depth=4,custom={},pair='general__rom_082d4b0c',family='lavender_house',groundHeight=3}
local cells={};for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={mid=mid,pair=g.pair,civic=g,base=3,collision=y==1 and 0 or(y==4 and x==3 and 0x71 or 7)}end end
assert(H.eligible(g,cells));local c=cells['8:28']
for _,k in ipairs{'boundary','stageHidden','prop'}do c[k]=true;assert(not H.eligible(g,cells),k);c[k]=nil end
for k,v in pairs{mid=0,collision=7,base=4,pair='viridian_outdoor',civic=false}do local old=c[k];c[k]=v;assert(not H.eligible(g,cells),k);c[k]=old end
local door=cells['10:31'];door.collision=7;assert(not H.eligible(g,cells));door.collision=0x71
assert(H.register());assert(not H.build(g,cells,function()error('unexpected upload without image')end,{}));assert(not g.importedLavenderHouse)
D.build=function(g,fit)g.importedLavenderDoors={};return true end;D.commit=function()end
S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);assert(p.x==128 and p.y==3 and p.z==464)
 local parts,fit=assert(S.vertices(p.model,p.fit));assert(math.abs(fit.anchors.door[1]-40)<1e-6 and math.abs(fit.anchors.door[3]-38.75)<1e-6)
 assert(fit.bounds[4]-fit.bounds[1]>68 and fit.bounds[4]-fit.bounds[1]<70,'source footprint must remain substantial')
 local base,rear,soffit=false,false,false
 for _,part in ipairs(parts)do
  assert(part.role~='source_shading'and part.role~='ground_shadow','baked illumination excluded')
  assert(part.role~='source_door','static door must not remain in body batch');base=base or part.name=='authored_closed_foundation';rear=rear or part.name=='authored_rear_wall';soffit=soffit or part.name=='authored_roof_soffit'
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6 and v[2]>=-.05-1e-6)end
 end
 assert(base and rear and soffit);return opts.parts
end
assert(H.build(g,cells,function()end,{}));assert(g.importedLavenderHouse)
assert(c.civic==g and door.collision==0x71,'source permissions and ownership unchanged')
print('PASS Lavender HGSS house exact drawing/permission/level/ownership guards, blocked fit, source door, unbaked geometry and upload fallback')
