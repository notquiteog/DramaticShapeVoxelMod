local Mat=dofile('lib/Mat4.lua')
local edition='emerald'
package.loaded['src.core.GameVersion']={get=function()return edition end}
local modern,available,fail=true,true,false
local calls,uploads,registered,released={},0,0,0
local mesh,image={},{}
local Shadow={draw=function(...)calls[#calls+1]={...}end,snug=function(m)return m end}
local Models={}
function Models.info()return registered>0 and{}end
function Models.register()registered=registered+1;return true end
function Models.fit()return{anchors={waterline={16,1.5,16}}}end
function Models.buildBatches(p,newMesh)
 uploads=uploads+1
 assert(p[1].x==-16 and p[1].z==-16 and p[1].y==-1.5,'boat fit detached from authored waterline')
 if fail then return nil,'missing source texture'end
 return{{mesh=mesh,image=image,count=1,opacity=1}}
end
function Models.releaseBatches()released=released+1 end
local modules={Mat4=Mat,ShadowMap=Shadow,SceneryModels=Models,
 VisualStyles={modern=function()return modern end},Water={CAST_RAISE=.02},Voxel3D={newMesh=function()end}}
local V={mod={read=function()return'public source bytes'end}}
function V.require(name)
 if name=='OrasBoatData'then if not available then error('missing source')end;return{}end
 return assert(modules[name],name)
end
local B=assert(loadfile('lib/Gen3Boats.lua'))(V)
local function draw(...)calls[#calls+1]={...}end
local function point(m,x,y,z)return m[1]*x+m[2]*y+m[3]*z+m[4],m[5]*x+m[6]*y+m[7]*z+m[8],m[9]*x+m[10]*y+m[11]*z+m[12]end
local function near(a,b)assert(math.abs(a-b)<1e-8,tostring(a)..' != '..tostring(b))end
for _,ed in ipairs{'emerald','ruby','sapphire'}do edition=ed
 for direction,axis in pairs{down={0,1},right={1,0},up={0,-1},left={-1,0}}do
  assert(B.draw(88,32,64,-4,direction,draw))
  local c=calls[#calls];assert(c[1]==mesh and c[2]==image)
  local x,y,z=point(c[3],0,0,0);near(x,40);near(y,-4);near(z,72)
  x,y,z=point(c[3],0,0,1);near(x,40+axis[1]);near(y,-4);near(z,72+axis[2])
 end
end
assert(uploads==1 and registered==1,'moving boat rebuilt immutable source meshes')
assert(B.draw(88,33.5,65.25,-3.5,'right',draw,-4))
local x,y,z=point(calls[#calls][3],0,2,0);near(x,41.5);near(y,-6.48);near(z,73.25)
assert(B.draw(88,32,64,-4,'up',Shadow.draw));assert(calls[#calls][3][8]==-4)
local n=#calls
modern=false;assert(not B.draw(88,0,0,0,'down',draw));modern=true
edition='firered';assert(not B.draw(88,0,0,0,'down',draw));edition='emerald'
assert(not B.draw(113,0,0,0,'down',draw)and#calls==n,'unrelated actor/style claimed')
B.clear();assert(released==1)
fail=true;assert(not B.draw(88,0,0,-4,'down',draw));local attempts=uploads
assert(not B.draw(88,0,0,-4,'down',draw)and uploads==attempts,'failed source upload retried every frame')
assert(#calls==n,'partial boat drawn on failure')
B.clear();fail=false;assert(B.draw(88,0,0,-4,'down',draw));B.clear()
print('PASS RSE boat identity, world headings, authored waterline, moving position, reflection/shadow, source cache, style/actor isolation and atomic failure')
