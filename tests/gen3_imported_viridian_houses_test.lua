local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),ViridianHouseData=dofile('lib/ViridianHouseData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local D=assert(loadfile('lib/Gen3ViridianFlowerHouseDoors.lua'))(V);modules.Gen3ViridianFlowerHouseDoors=D
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
local old,image=S.buildBatches,S.image;local live=0;S.image=function()return{}end;local function mesh()live=live+1;return{setTexture=function()end,release=function()live=live-1 end}end;S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);local parts,f=assert(S.vertices(p.model,p.fit));assert(p.y==5 and p.z==(g.cy+1)*16)
 local door,shade,gables,foundation=false,false,false,false
 for _,part in ipairs(parts)do
  door=door or part.role=='source_door';shade=shade or part.alphaMode=='blend' and math.abs(part.opacity-.2903226)<1e-6
  gables=gables or part.name=='authored_side_gables';foundation=foundation or part.name=='authored_closed_foundation'
  for _,v in ipairs(part.vertices)do assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6 and v[2]>=-.05)end
 end
 assert(not door and shade and gables and foundation,'static source body must not retain closed door')
 assert(f.bounds[4]-f.bounds[1]>64 and f.bounds[6]-f.bounds[3]>47)
 assert(math.abs(f.anchors.door[1]-24)<1e-6 and math.abs(f.anchors.door[3]-35.4)<1e-6)
 return opts.parts
end
assert(H.build(g,cells,mesh,{}));assert(live==6 and D.ownsDoor(g,25,11))
for state=0,2 do local parts=assert(D.geometry(g,g.importedViridianHouse,state));local count=0;for _,p in ipairs(parts)do count=count+#p.indices/3;local q={vertices={},indices=p.indices};for _,v in ipairs(p.vertices)do q.vertices[#q.vertices+1]={v[1]-g.cx*16,v[2],v[3]-(g.cy+1)*16}end;assert(modules.Gen3ImportedGyms.clearance(g,cells,{q}))end;assert(count==12,'original8 triangles plus closed back and underside');local edges={};local function point(v)return string.format('%.6f:%.6f:%.6f',v[1],v[2],v[3])end;for _,p in ipairs(parts)do for i=1,#p.indices,3 do for j=0,2 do local a,b=point(p.vertices[p.indices[i+j]]),point(p.vertices[p.indices[i+(j+1)%3]]);if a>b then a,b=b,a end;local k=a..'/'..b;edges[k]=(edges[k]or 0)+1 end end end;for _,n in pairs(edges)do assert(n==2,'source door must close every edge in every pose')end end;D.release(g);assert(live==0);
local d=assert(H.doorSurface(g,25,11));assert(d.base==5 and d.w==14 and d.h==16)
assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-(25*16+8))<1e-6)
assert(not H.doorSurface(g,26,11));local chimney=assert(H.chimney(g));assert(chimney.y>g.groundHeight+50)
assert(chimney.x>=g.cx*16 and chimney.x<=(g.cx+5)*16 and chimney.z>=(g.cy+1)*16 and chimney.z<=(g.cy+4)*16)
local calls=0;assert(not D.build(g,g.importedViridianHouse,function()calls=calls+1;if calls==2 then return nil end;return mesh()end));assert(live==0 and not g.importedViridianFlowerDoors,'late door upload must unwind first original part')
S.buildBatches=function()return nil,'late body failure'end;g.importedViridianHouse=nil;assert(not H.build(g,cells,mesh,{}));assert(live==0 and not g.importedViridianFlowerDoors);S.buildBatches,S.image=old,image
print('PASS ordinary Viridian exact source/permissions/elevation, no flower substitution, source door/alpha, roof/foundation closures, fit, portal and actual chimney')
