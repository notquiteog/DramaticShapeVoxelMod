local data=dofile('lib/LavenderHouseData.lua');local modules={LavenderHouseData=data,SceneryModelData=dofile('lib/SceneryModelData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3LavenderHouseDoors.lua'))(V)
assert(S.register('hgss_lavender_house',data.hgss_lavender_house,{read=function()end}))
local fit=assert(S.fit('hgss_lavender_house',{width=80,depth=48,padding=.25,anchor='door',targetX=40,targetZ=38.75}))
local g={family='lavender_house',pair='general__rom_082d4b0c',width=5,depth=4,cx=8,cy=28,groundHeight=3}
local geometries={};for state=0,2 do
 geometries[state]=assert(D.geometry(g,fit,state));local n=0
 for _,p in ipairs(geometries[state])do n=n+#p.indices/3;for _,v in ipairs(p.vertices)do assert(v[1]>=128.25 and v[1]<=207.75 and v[3]>=464.25 and v[3]<=511.75 and v[2]>=3)end end
 assert(n==8,'retain all original source door triangles')
end
local moved=false;for i,a in ipairs(geometries[0][1].vertices)do local b=geometries[2][1].vertices[i];moved=moved or math.abs(a[1]-b[1])+math.abs(a[3]-b[3])>1e-6 end;assert(moved,'source panel must open around its fixed hinge')
assert(not D.geometry(g,fit,3));g.pair='other';assert(not D.geometry(g,fit,0));g.pair='general__rom_082d4b0c'
assert(not D.build(g,fit,function()error('no upload with missing image')end));assert(not g.importedLavenderDoors)
local live,released=0,0;S.image=function()return {}end
local function mesh()live=live+1;return{setTexture=function()end,release=function()live=live-1;released=released+1 end}end
local calls=0;assert(not D.build(g,fit,function()calls=calls+1;if calls==2 then return nil end;return mesh()end));assert(live==0 and released==1,'late failure must unwind prior frame')
assert(D.build(g,fit,mesh));assert(live==3 and D.ownsDoor(g,10,31)and not D.ownsDoor(g,11,31))
assert(D.state(g,{x=10,y=31,frame=2})==2 and D.state(g,{x=11,y=31,frame=2})==0)
local drawn=0;D.draw(g,{x=10,y=31,frame=2},function()drawn=drawn+1 end);assert(drawn==1)
D.release(g);assert(live==0 and not D.ownsDoor(g,10,31));print('PASS Lavender original-panel hinge frames, native ownership, bounded poses, image/late-upload fallback and resource release')
