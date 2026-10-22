local tracked
local modules={SceneryModelData={},ImportedDewfordData=dofile('lib/ImportedDewfordData.lua'),
 ImportedDewfordDoorData=dofile('lib/ImportedDewfordDoorData.lua'),ModelInstances={},
 BuildBudget={check=function()end,track=function(o)assert(not tracked);tracked=o end,untrack=function(o)if tracked==o then tracked=nil end end}}
local V={mod={read=function()return nil end},require=function(n)return assert(modules[n],n)end}
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3DewfordDoors.lua'))(V);modules.Gen3DewfordDoors=D
local House=assert(loadfile('lib/Gen3ImportedDewford.lua'))(V);assert(House.register())
local data=modules.ImportedDewfordDoorData
assert(#data.parts==1 and #data.parts[1].indices==54 and #data.poses==3)
local g={cx=7,cy=5,width=4,depth=4,kind='house',pair='general__dewford',groundHeight=9,
 custom={family='rse',name='dewford_town_home'}}
local fit=assert(S.fit(House.id,{width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=43.05}));fit.model=House.id
local poses={}
for state=0,2 do
 local part=assert(D.geometry(g,fit,state));assert(#part.vertices==34 and #part.indices==54)
 poses[state+1]=part
 for i,v in ipairs(part.vertices)do
  local original=data.poses[state+1][i]
  assert(v[4]==original[4]and v[5]==original[5]and v[6]==1,'source UV or clean-lighting preference changed')
  assert(v[1]>=g.cx*16+.25 and v[1]<=g.cx*16+63.75 and v[3]>=(g.cy+1)*16+.25 and v[3]<=(g.cy+1)*16+47.75,'source hinge crosses native walking apron')
 end
end
local moved=false
for i,v in ipairs(poses[1].vertices)do
 local opened=poses[3].vertices[i]
 assert(v[2]==opened[2],'hinged door changed source height')
 if opened[3]<v[3]-1 then moved=true end
end
assert(moved,'source door never swung into its interior')
assert(not D.geometry(g,fit,3));local name=g.custom.name;g.custom.name='dewford_town_hall';assert(not D.geometry(g,fit,0));g.custom.name=name
assert(D.state(g,nil)==0 and D.state(g,{x=0,y=0,frame=2})==0)
for frame=0,2 do assert(D.state(g,{x=8,y=8,frame=frame})==frame)end
assert(D.state(g,{x=8,y=8,frame=0/0})==0)
local freed,uploads=0,0;local image={}
S.image=function(id,path)assert(id==D.id and path:match('oras%-dewford%-door'));return image end
local function upload(v,i)
 uploads=uploads+1
 return{vertices=v,indices=i,setTexture=function(_,im)assert(im==image)end,
  release=function(self)assert(not self.freed);self.freed=true;freed=freed+1 end}
end
local cache=assert(D.build(g,fit,upload));assert(#cache==3 and #cache.parts==3 and tracked)
D.commit(g);assert(not tracked and D.ownsDoor(g,8,8)and not D.ownsDoor(g,9,8))
local drawn
assert(D.draw(g,nil,function(mesh)drawn=mesh end)and drawn==cache[1].mesh,'idle closed source door absent')
assert(D.draw(g,{x=8,y=8,frame=1},function(mesh)drawn=mesh end)and drawn==cache[2].mesh)
D.release(g);assert(freed==3 and not tracked and not g.importedDewfordDoors)
local before,n=freed,0
assert(not D.build(g,fit,function(v,i)n=n+1;if n==2 then error('door upload failed')end;return upload(v,i)end))
assert(freed==before+1 and not tracked and not g._dewfordDoorPending)
before,n=freed,0
local co=coroutine.create(function()D.build(g,fit,function(v,i)n=n+1;if n==2 then coroutine.yield('upload')end;return upload(v,i)end)end)
local ok,why=coroutine.resume(co);assert(ok and why=='upload'and tracked and g._dewfordDoorPending)
tracked.release();assert(freed==before+1 and not tracked and not g._dewfordDoorPending)
-- Missing source door resources reject the complete modern house atomically.
local cells={};local rows=House.families[g.custom.name]
for y=0,3 do for x=0,3 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,pair=g.pair,mid=rows[y+1][x+1],
 collision=y==0 and(x>=2 and 7 or 0)or(y==3 and x==1 and 113 or 7),base=9}end end
local prior={};local parts={prior};S.image=function()return nil end;n=0
assert(not House.build(g,cells,function()n=n+1 end,parts)and n==0 and #parts==1 and not g.importedHoenn and not g.importedDewfordDoors)
S.image=function()return image end;before,n=freed,0
assert(not House.build(g,cells,function(v,i)n=n+1;if n==4 then error('structure upload failed')end;return upload(v,i)end,parts))
assert(freed==before+3 and #parts==1 and parts[1]==prior and not tracked and not g.importedDewfordDoors)
print('PASS authentic Dewford source hinge/UVs, idle door0/native1/2 states, complete body clearance and atomic missing/cancel/failure fallback')
