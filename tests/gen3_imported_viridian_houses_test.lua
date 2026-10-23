local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),ViridianHouseData=dofile('lib/ViridianHouseData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local H=assert(loadfile('lib/Gen3ImportedViridianHouses.lua'))(V)
local recipe;for _,r in ipairs(dofile('data/gen3_exteriors.lua'))do if r.name=='viridian_house'then recipe=r end end
local g={cx=24,cy=8,family=recipe.name,custom=recipe,width=5,depth=4,pair=recipe.pair,groundHeight=5};local cells={}
for y,row in ipairs(recipe.rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={civic=g,pair=g.pair,mid=mid,base=5,collision=y==1 and 0 or(y==4 and x==2 and 0x71 or 7)}end end
assert(H.eligible(g,cells));local c=cells['24:8']
c.collision=7;assert(not H.eligible(g,cells));c.collision=0
c.base=6;assert(not H.eligible(g,cells));c.base=5
c.mid=0;assert(not H.eligible(g,cells));c.mid=recipe.rows[1][1]
c.prop={};assert(not H.eligible(g,cells));c.prop=nil
c.boundary='mountain';assert(not H.eligible(g,cells));c.boundary=nil
g.family='viridian_flower_house';assert(not H.eligible(g,cells));g.family=recipe.name
assert(not H.build(g,cells,function()error('unexpected upload without PNG')end,{}));assert(not g.importedViridianHouse)
local old=S.buildBatches;S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);local parts,f=assert(S.vertices(p.model,p.fit));assert(p.y==5 and p.z==(g.cy+1)*16)
 local door,shade,gables,foundation=false,false,false,false
 for _,part in ipairs(parts)do
  door=door or part.role=='source_door';shade=shade or part.alphaMode=='blend' and math.abs(part.opacity-.2903226)<1e-6
  gables=gables or part.name=='authored_side_gables';foundation=foundation or part.name=='authored_closed_foundation'
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6 and v[2]>=0)end
 end
 assert(door and shade and gables and foundation)
 assert(f.bounds[4]-f.bounds[1]>64 and f.bounds[6]-f.bounds[3]>47)
 assert(math.abs(f.anchors.door[1]-24)<1e-6 and math.abs(f.anchors.door[3]-35.4)<1e-6)
 return opts.parts
end
assert(H.build(g,cells,function()end,{}));local d=assert(H.doorSurface(g,25,11));assert(d.base==5 and d.w==14 and d.h==16)
assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-(25*16+8))<1e-6)
assert(not H.doorSurface(g,26,11));local chimney=assert(H.chimney(g));assert(chimney.y>g.groundHeight+50)
assert(chimney.x>=g.cx*16 and chimney.x<=(g.cx+5)*16 and chimney.z>=(g.cy+1)*16 and chimney.z<=(g.cy+4)*16)
S.buildBatches=old
print('PASS ordinary Viridian exact source/permissions/elevation, no flower substitution, source door/alpha, roof/foundation closures, fit, portal and actual chimney')
