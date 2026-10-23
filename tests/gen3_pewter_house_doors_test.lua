local data=dofile('lib/PewterHouseData.lua');local modules={PewterHouseData=data,SceneryModelData=dofile('lib/SceneryModelData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3PewterHouseDoors.lua'))(V)
assert(S.register('hgss_pewter_house',data.hgss_pewter_house,{read=function()end}))
local fit=assert(S.fit('hgss_pewter_house',{width=80,depth=48,padding=.25,anchor='door',targetX=24,targetZ=40}))
local g={family='pewter_house',pair='pewter_outdoor',width=5,depth=3,cx=8,cy=28,groundHeight=3}
local geometries={};for state=0,2 do
 geometries[state]=assert(D.geometry(g,fit,state));local n=0
 for _,p in ipairs(geometries[state])do n=n+#p.indices/3;for _,v in ipairs(p.vertices)do assert(v[1]>=128.25 and v[1]<=207.75 and v[3]>=448.25 and v[3]<=495.75 and v[2]>=3)end end
 assert(n==8,'retain all original source door triangles')
end
assert(geometries[0][1].vertices[1][1]~=geometries[2][1].vertices[1][1],'source panel must open')
assert(not D.geometry(g,fit,3));g.pair='other';assert(not D.geometry(g,fit,0));g.pair='pewter_outdoor'
assert(not D.build(g,fit,function()error('no upload with missing image')end));assert(not g.importedPewterDoors)
local live,released=0,0;S.image=function()return {}end
local function mesh()live=live+1;return{setTexture=function()end,release=function()live=live-1;released=released+1 end}end
local calls=0;assert(not D.build(g,fit,function()calls=calls+1;if calls==2 then return nil end;return mesh()end));assert(live==0 and released==1,'late failure must unwind prior frame')
assert(D.build(g,fit,mesh));assert(live==3 and D.ownsDoor(g,9,30)and not D.ownsDoor(g,10,30))
assert(D.state(g,{x=9,y=30,frame=2})==2 and D.state(g,{x=10,y=30,frame=2})==0)
local drawn=0;D.draw(g,{x=9,y=30,frame=2},function()drawn=drawn+1 end);assert(drawn==1)
D.release(g);assert(live==0 and not D.ownsDoor(g,9,30));print('PASS Pewter original-panel hinge frames, native ownership, bounded poses, image/late-upload fallback and resource release')
