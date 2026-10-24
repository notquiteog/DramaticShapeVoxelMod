local modules={SceneryModelData={},HGSSCenterData=dofile('lib/HGSSCenterData.lua'),SharedModelMesh=dofile('lib/SharedModelMesh.lua'),Voxel3D={withSceneryMaterial=function(_,fn)fn()end},ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end},require=function(n)return assert(modules[n],n)end}
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local D=assert(loadfile('lib/Gen3KantoCenterDoors.lua'))(V);modules.Gen3KantoCenterDoors=D
modules.Gen3ImportedKantoCenters=assert(loadfile('lib/Gen3ImportedKantoCenters.lua'))(V)
local H=assert(loadfile('lib/Gen3ImportedOneIslandCenter.lua'))(V)
local rows={{704,706,706,707,708,708,710},{712,714,714,715,716,716,718},{720,714,722,723,724,716,726},{728,729,730,731,732,733,734},{736,737,738,739,740,741,742},{744,745,746,747,748,749,750}}
local g={cx=20,cy=7,width=7,depth=6,kind='center',family='one_island_center',custom={name='one_island_center'},pair='sevii_outdoor',groundHeight=16}
local region={x=9,y=7,def={id='SEVII_ONE_ISLAND'}};local cells={}
for y,row in ipairs(rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={mid=mid,collision=y==6 and x==4 and 113 or 7,civic=g,pair=g.pair,base=16,region=region}end end
cells[(g.cx+2)..':'..(g.cy+6)]={cx=g.cx+2,cy=g.cy+6,mid=721,collision=0,civic=g,pair=g.pair,base=16,region=region}
assert(H.eligible(g,cells));assert(not modules.Gen3ImportedKantoCenters.eligible(g,cells))
for k,v in pairs{family='center',width=5,depth=5,pair='pewter_outdoor',stageHidden=true}do local old=g[k];g[k]=v;assert(not H.eligible(g,cells));g[k]=old end
region.def.id='FR_THREE_ISLAND';assert(not H.eligible(g,cells));region.def.id='SEVII_ONE_ISLAND'
local c=cells['20:7']
for k,v in pairs{mid=0,collision=0,base=15,prop=true,boundary=true,stageHidden=true,civic=false}do local old=c[k];c[k]=v;assert(not H.eligible(g,cells),k);c[k]=old end
local door=cells['23:12'];door.collision=7;assert(not H.eligible(g,cells));door.collision=113
assert(not H.build(g,cells,function()error('missing source image must prevent upload')end,{}));assert(not g.importedOneIslandCenter and not g.importedKantoCenterDoors)
local extra=cells[(g.cx+2)..':'..(g.cy+6)];extra.mid=720;assert(not H.eligible(g,cells));extra.mid=721
local oldImage,oldBuild=S.image,S.buildBatches;local live=0
S.image=function()return{}end
local function mesh()live=live+1;return{setTexture=function()end,release=function()live=live-1 end}end
S.buildBatches=function(placements,_,options)
 local p=placements[1];assert(p.x==320 and p.y==16 and p.z==112,'wider Center cannot inherit standard two-row Z shift')
 local parts,fit=assert(S.vertices(p.model,p.fit));assert(fit.bounds[4]-fit.bounds[1]>104 and fit.bounds[6]-fit.bounds[3]>80)
 assert(math.abs(fit.anchors.door[1]-56)<1e-7 and math.abs(fit.anchors.door[3]-83)<1e-7)
 for _,part in ipairs(parts)do assert(part.role~='source_door');for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=111.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=95.75+1e-6 and v[2]>=-.05)end end
 assert(D.clearance(g,cells,parts),'whole original6-row body must own source footprint')
 return options.parts
end
assert(H.build(g,cells,mesh,{}));assert(live==6 and g.importedOneIslandCenter.model==H.id)
local f=g.importedOneIslandCenter
assert(D.ownsDoor(g,23,12)and not D.ownsDoor(g,22,12));assert(H.doorSurface(g,23,12)and not H.doorSurface(g,22,12))
for state=0,2 do
 local parts=assert(D.geometry(g,f,state));assert(#parts==2)
 for _,p in ipairs(parts)do
  assert(p.opacity==.8709677 and p.alphaMode=='blend')
  local q={vertices={},indices=p.indices}
  for _,v in ipairs(p.vertices)do q.vertices[#q.vertices+1]={v[1]-g.cx*16,v[2],v[3]-g.cy*16}end
  assert(D.clearance(g,cells,{q}),'sliding source leaf left native mask')
 end
end
D.release(g);assert(live==0)
local calls=0;assert(not D.build(g,f,function()calls=calls+1;if calls==3 then return nil end;return mesh()end,cells));assert(live==0,'partial source leaf upload leaked')
g.importedOneIslandCenter=nil;S.buildBatches=function()return nil,'body refusal'end
assert(not H.build(g,cells,mesh,{}));assert(live==0 and not g.importedKantoCenterDoors and not g.importedOneIslandCenter)
S.image,S.buildBatches=oldImage,oldBuild
print('PASS exact wider native Center/full6-row fit, original source datum/portal, all sliding states, native-grid guards and atomic optional-source failure')
