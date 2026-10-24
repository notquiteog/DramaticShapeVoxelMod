local tracked
local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),ImportedCenterDoorData=dofile('lib/ImportedCenterDoorData.lua'),ModelInstances={new=function()return nil end},BuildBudget={check=function()end,track=function(o)assert(not tracked);tracked=o end,untrack=function(o)if tracked==o then tracked=nil end end}}
local V={mod={read=function()return nil end},require=function(n)return assert(modules[n],n)end}
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3CenterDoors.lua'))(V);modules.Gen3CenterDoors=D
local C=assert(loadfile('lib/Gen3ImportedCenters.lua'))(V);assert(C.register())
local g={cx=5,cy=13,width=4,depth=4,kind='center',groundHeight=9,custom={family='rse',centerRoof=true}}
local fit=assert(S.fit(C.id,{width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=47}))
local data=modules.ImportedCenterDoorData
assert(#data.parts==4 and data.poses[1].left==0 and data.poses[3].left==-15)
local closed=assert(D.geometry(g,fit,0));local half=assert(D.geometry(g,fit,1));local opened=assert(D.geometry(g,fit,2))
for i,p in ipairs(closed)do
 assert(#p.vertices==4 and #p.indices==6)
 for j,v in ipairs(p.vertices)do
  local original=data.parts[i].vertices[j]
  assert(v[4]==original[4]and v[5]==original[5]and v[6]==original[6],'original ORAS UV/shade changed')
  for _,pose in ipairs{half,opened}do
   local q=pose[i].vertices[j];assert(q[2]==v[2]and q[3]==v[3],'door slid in wrong axis')
   assert(p.leaf=='left'and q[1]<v[1]or p.leaf=='right'and q[1]>v[1],'panel slid inward')
   assert(q[1]>=g.cx*16+.25 and q[1]<=g.cx*16+63.75 and q[3]>=(g.cy+1)*16+.25 and q[3]<=(g.cy+1)*16+47.75,'sliding panel crosses native body')
  end
 end
end
assert(not D.geometry(g,fit,3));assert(D.state(g,nil)==0 and D.state(g,{x=0,y=0,frame=2})==0)
for f=0,2 do assert(D.state(g,{x=6,y=16,frame=f})==f)end
local freed,uploaded=0,0;local image={release=function()error('scene released shared source texture')end}
S.image=function(id,texture)assert(id==D.id and texture:match('oras%-center%-doors'));return image end
local function upload(v,i)uploaded=uploaded+1;return{vertices=v,indices=i,setTexture=function(_,im)assert(im==image)end,release=function(self)assert(not self.freed);self.freed=true;freed=freed+1 end}end
local cache=assert(D.build(g,fit,upload));assert(cache==g.importedCenterDoors and #cache==3 and #cache.parts==12 and tracked and not g._importedCenterDoorPending)
D.commit(g);assert(not tracked)
local calls={};assert(D.draw(g,nil,function(mesh)calls[#calls+1]=mesh end));assert(#calls==4 and calls[1]==cache[1][1].mesh)
calls={};assert(D.draw(g,{x=6,y=16,frame=1},function(mesh)calls[#calls+1]=mesh end));assert(calls[1]==cache[2][1].mesh)
D.release(g);assert(freed==12 and not g.importedCenterDoors and not tracked);D.release(g);assert(freed==12)
-- Any partial upload unwinds all source states before the native fallback.
local n=0;local before=freed
assert(not D.build(g,fit,function(v,i)n=n+1;if n==5 then error('panel upload failed')end;return upload(v,i)end))
assert(freed==before+4 and not g.importedCenterDoors and not g._importedCenterDoorPending and not tracked)
-- The pending cache is owned before any cooperative upload can yield.
n=0;before=freed
local co=coroutine.create(function()D.build(g,fit,function(v,i)n=n+1;if n==2 then coroutine.yield('upload')end;return upload(v,i)end)end)
local ok,reason=coroutine.resume(co);assert(ok and reason=='upload'and tracked and g._importedCenterDoorPending and not g.importedCenterDoors)
tracked.release();assert(freed==before+1 and not tracked and not g._importedCenterDoorPending)
-- Door resources are also unwound when the later Center structure fails.
local cells={};for y=0,3 do for x=0,3 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,base=9,collision=y==0 and 0 or(y==3 and x==1 and 113 or 7)}end end
local prior={mesh={release=function()error('released older scene part')end}};local parts={prior};n=0;before=freed
S.image=function(id)assert(id==D.id or id==C.id);return image end
local built,err=C.build(g,cells,function(v,i)n=n+1;if n==13 then error('structure upload failed')end;return upload(v,i)end,parts)
assert(not built and err:find('structure upload failed',1,true)and #parts==1 and parts[1]==prior and freed==before+12 and not tracked and not g.importedCenter and not g.importedCenterDoors)
-- Missing genuine door texture rejects the whole modern building before any structure upload.
S.image=function()return nil end;n=0
assert(not C.build(g,cells,function()n=n+1;error('unexpected upload')end,parts));assert(n==0 and #parts==1 and not g.importedCenter and not g.importedCenterDoors)
for y=0,3 do for x=0,3 do local q=cells[(g.cx+x)..':'..(g.cy+y)];assert(q.collision==(y==0 and 0 or(y==3 and x==1 and 113 or 7)))end end
print('PASS genuine ORAS panel UVs/XY fit, original source opening direction, cached native0/1/2 draw states, partial/cancel cleanup, shared texture ownership and atomic native Center fallback')
