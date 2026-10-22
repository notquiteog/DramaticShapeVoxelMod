local modules={SceneryModelData={},ImportedDewfordData=dofile('lib/ImportedDewfordData.lua'),ImportedDewfordDoorData=dofile('lib/ImportedDewfordDoorData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3DewfordDoors=assert(loadfile('lib/Gen3DewfordDoors.lua'))(V)
local D=assert(loadfile('lib/Gen3ImportedDewford.lua'))(V);modules.Gen3ImportedDewford=D
local H=assert(loadfile('lib/Gen3ImportedHoenn.lua'))(V)
assert(D.register());assert(S.info(D.id).parts==4)
local recipes={};for _,r in ipairs(dofile('data/gen3_hoenn_exteriors.lua'))do recipes[r.name]=r end
local build=S.buildBatches;local captured
for name,rows in pairs(D.families)do
 local r=assert(recipes[name]);r.family='rse';local cy=name=='dewford_town_home'and 5 or 11;local cx=cy==5 and 7 or 16
 local g={custom=r,pair=r.pair,cx=cx,cy=cy,width=4,depth=4,kind='house'}
 local cells={};for y=0,3 do for x=0,3 do
  assert(r.rows[y+1][x+1]==rows[y+1][x+1],'native recipe drift')
  local permission=y==0 and(cy==5 and x>=2 and 7 or 0)or(y==3 and x==1 and 113 or 7)
  cells[(cx+x)..':'..(cy+y)]={civic=g,pair=r.pair,mid=rows[y+1][x+1],collision=permission,base=0}
 end end
 assert(D.eligible(g,cells)and H.eligible(g,cells));local c=cells[(cx+3)..':'..(cy+1)]
 for _,field in ipairs{'mid','collision','pair','civic'}do local old=c[field];c[field]=nil;assert(not D.eligible(g,cells),field);c[field]=old end
 for _,field in ipairs{'boundary','stageHidden'}do c[field]=true;assert(not D.eligible(g,cells));c[field]=nil end
 c.base=1;assert(not D.eligible(g,cells));c.base=0
 local before={};assert(not H.build(g,cells,function()error('unexpected upload')end,before));assert(#before==0 and not g.importedHoenn)
 S.buildBatches=function(placements,_,opts)
  local p=placements[1];assert(p.model==D.id and p.x==cx*16 and p.z==(cy+1)*16)
  local parts,fit=assert(S.vertices(D.id,p.fit));captured=fit
  assert(fit.bounds[4]-fit.bounds[1]>57 and fit.bounds[4]-fit.bounds[1]<59)
  assert(fit.bounds[6]-fit.bounds[3]>47 and fit.bounds[6]-fit.bounds[3]<47.5)
  for _,q in ipairs(parts)do for _,v in ipairs(q.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=63.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6)end end
  assert(math.abs(fit.anchors.door[1]-24)<1e-6)
  return opts.parts
 end
 local oldImage=S.image;S.image=function()return{}end
 assert(H.build(g,cells,function()return{setTexture=function()end,release=function()end}end,{}));local door=assert(H.doorSurface(g,cx+1,cy+3));assert(not H.doorSurface(g,cx+2,cy+3))
 assert(g.importedDewfordDoors,'idle source door was omitted')
 assert(math.abs((door.vertices[1][1]+door.vertices[2][1])/2-((cx+1)*16+8))<1e-6)
 assert(door.vertices[3][2]>=0 and door.vertices[1][2]>door.vertices[3][2])
 for y=0,3 do for x=0,3 do assert(cells[(cx+x)..':'..(cy+y)].mid==r.rows[y+1][x+1])end end
 modules.Gen3DewfordDoors.release(g);S.image=oldImage;S.buildBatches=build
end
local hall={custom=recipes.dewford_town_hall,pair='general__dewford',kind='house',width=5,depth=4,cx=1,cy=0}
assert(not D.eligible(hall,{}),'wide hall incorrectly substituted')
print(('PASS both exact Dewford native recipes, separate wide-hall fallback, uniform source fit%.4fx%.4f within64x48, unchanged collision/warps and guarded missing-resource fallback'):format(captured.bounds[4]-captured.bounds[1],captured.bounds[6]-captured.bounds[3]))
