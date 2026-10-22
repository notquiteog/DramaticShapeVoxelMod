local Mat=dofile('lib/Mat4.lua')
local edition='emerald';local def={id='EM_LITTLEROOT_TOWN',midLayout={pair='general__petalburg'}}
package.loaded['src.core.GameVersion']={get=function()return edition end}
package.loaded['src.core.game3.map']={currentDef=function()return def end}
local modern,available,fail=true,true,false
local calls,uploads,registered,released={},0,0,0
local mesh,image={},{}
local Shadow={draw=function(...)calls[#calls+1]={...}end,snug=function(m)return m end}
local Models={info=function()return registered>0 and{}end,register=function()registered=registered+1;return true end}
function Models.buildBatches(p)
 uploads=uploads+1
 assert(p[1].model=='oras_opening_truck'and p[1].x==-24 and p[1].z==-18 and p[1].y==0)
 assert(p[1].fit.width==48 and p[1].fit.depth==36 and p[1].fit.padding==.25,'source truck was fitted as a trainer')
 if fail then return nil,'missing source texture'end
 return{{mesh=mesh,image=image,count=1,opacity=1}}
end
function Models.releaseBatches()released=released+1 end
local modules={Mat4=Mat,ShadowMap=Shadow,SceneryModels=Models,VisualStyles={modern=function(category)assert(category=='props');return modern end},Water={CAST_RAISE=.02},Voxel3D={newMesh=function()end}}
local V={mod={read=function()return'local selected source PNG'end}}
function V.require(name)
 if name=='ImportedTruckExteriorData'then if not available then error('missing source')end;return{}end
 return assert(modules[name],name)
end
local B=assert(loadfile('lib/Gen3TruckExterior.lua'))(V)
local spr={graphicsId=94,width=48,height=48,frameCount=1,inanimate=true}
local function draw(...)calls[#calls+1]={...}end
local function near(a,b)assert(math.abs(a-b)<1e-8,tostring(a)..' != '..tostring(b))end
for ed,prefix in pairs{emerald='EM_',ruby='RU_',sapphire='SA_'}do
 edition=ed;def.id=prefix..'LITTLEROOT_TOWN'
 assert(B.draw(94,32,160,3,spr,0,draw))
 local c=calls[#calls];assert(c[1]==mesh and c[2]==image);near(c[3][4],40);near(c[3][8],3);near(c[3][12],168)
end
assert(uploads==1 and registered==1,'native actor motion rebuilt immutable truck geometry')
assert(B.draw(94,33.5,161.25,4,spr,0,draw));near(calls[#calls][3][4],41.5);near(calls[#calls][3][12],169.25)
assert(B.draw(94,32,160,3,spr,0,draw,-4));near(calls[#calls][3][8],-10.98);assert(calls[#calls][3][6]==-1)
assert(B.draw(94,32,160,3,spr,0,Shadow.draw));near(calls[#calls][3][8],3)
local n=#calls;modern=false;assert(not B.draw(94,0,0,0,spr,0,draw));modern=true
assert(not B.draw(113,0,0,0,spr,0,draw));assert(not B.draw(94,0,0,0,spr,1,draw))
spr.width=64;assert(not B.draw(94,0,0,0,spr,0,draw));spr.width=48
local id=def.id;def.id='EM_OLDALE_TOWN';assert(not B.draw(94,0,0,0,spr,0,draw));def.id=id
edition='firered';assert(not B.draw(94,0,0,0,spr,0,draw));edition='emerald'
assert(not B.draw(94,0/0,0,0,spr,0,draw)and#calls==n,'unrelated art/style/nonfinite actor claimed')
B.clear();assert(released==1);fail=true;assert(not B.draw(94,0,0,0,spr,0,draw));local attempts=uploads
assert(not B.draw(94,0,0,0,spr,0,draw)and uploads==attempts and #calls==n,'partial or repeated failed-source draw')
B.clear();fail=false;registered=0;available=false;assert(not B.draw(94,0,0,0,spr,0,draw)and#calls==n)
B.clear();available=true;assert(B.draw(94,0,0,0,spr,0,draw));B.clear()
-- Processed physical source is independently registered and uniformly fitted.
local data=dofile('lib/ImportedTruckExteriorData.lua');local T=assert(loadfile('lib/SceneryModels.lua'))({require=function(n)if n=='BuildBudget'then return{check=function()end}end;return{}end})
assert(T.register(B.id,data,{read=function()return nil end}));local ps,fit=assert(T.vertices(B.id,{width=48,depth=36,padding=.25}))
assert(#ps==5 and fit.bounds[1]>=.25 and fit.bounds[4]<=47.75 and fit.bounds[3]>=.25 and fit.bounds[6]<=35.75)
local triangles=0;for i,p in ipairs(data.parts)do
 triangles=triangles+#p.indices/3
 for _,v in ipairs(p.vertices)do assert(#v==6 and v[6]==1,'source UV/clean shading format changed')end
 for _,c in ipairs(p.colors)do assert(c[1]==1 and c[2]==1 and c[3]==1,'source baked RGB lighting retained')end
 for _,ix in ipairs(p.indices)do assert(ix>=1 and ix<=#p.vertices)end
 if i>3 then assert(p.authored and #p.indices/3==(i==4 and 2 or 4))end
end
assert(triangles==2110,'source body, chassis, interior or exact underside closure lost')
print('PASS genuine ORAS truck topology/uniform fit, exact RSE native94 map/art guard, actor motion/reflection/shadow, style fallback, resource failure and cache release')
