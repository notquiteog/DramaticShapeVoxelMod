local C=dofile('lib/ActorFrameCache.lua').new()
local actors={};for i=1,265 do actors[i]={x=i}end
local queries,providers=0,0
local function prepare(row,gid,x,z,frame,padding)
 queries=queries+1;row.gid,row.x,row.z,row.frame,row.padding=gid,x,z,frame,padding
 row.ready=gid~=0;return row.ready
end
assert(not pcall(C.get,C,actors[1],prepare,1,1,0,0,0),'cache used without render boundary')
C:begin()
for pass=1,6 do for _,a in ipairs(actors)do
 local row=assert(C:get(a,prepare,1,a.x,0,2,3))
 assert(row.x==a.x and row.frame==2 and row.padding==3)
 providers=providers+1 -- Pass-specific hooks still run, even on cache hits.
end end
assert(queries==265 and providers==1590,'preparation or provider frequency changed')
local first=C:get(actors[1],prepare,1,1,0,2,3)
-- Another render without a gameplay update MUST refresh, but reuses storage.
C:begin();assert(C:get(actors[1],prepare,1,1,0,2,3)==first and queries==266)
assert(C:get(actors[1],prepare,1,1,16,2,3).z==16 and queries==267,'ghost/map context reused old pose')
assert(C:get(actors[1],prepare,1,1,16,2,4).padding==4 and queries==268,'flattened mutable option missed')
local missing={};assert(not C:get(missing,prepare,0,0,0,0,0));local count=queries
assert(not C:get(missing,prepare,0,0,0,0,0)and queries==count,'nil result was not cached')
C:begin();assert(not C:get(missing,prepare,0,0,0,0,0)and queries==count+1,'missing source persisted across renders')
local fail=true;local attempts=0
local function fragile(row,x)
 attempts=attempts+1;if fail then error('source unavailable')end;row.x=x;return true
end
assert(not pcall(C.get,C,actors[1],fragile,3))
assert(not pcall(C.get,C,actors[1],fragile,3)and attempts==2,'producer error incorrectly cached')
fail=false;assert(C:get(actors[1],fragile,3).x==3 and attempts==3)
-- Different arity (including trailing nil) is different preparation context.
local arities={};local function arity(row,...)arities[#arities+1]=select('#',...);return true end
C:get(actors[1],arity,1);C:get(actors[1],arity,1,nil);C:get(actors[1],arity,1,nil)
assert(#arities==2 and arities[1]==1 and arities[2]==2)
C:clear();assert(not pcall(C.get,C,actors[1],prepare,1,1,0,2,3))
C:begin();assert(C:get(actors[1],prepare,1,1,0,2,3)~=first,'reset retained old render storage')
print('PASS 265actors/6passes:1590 preparations->265; provider calls preserved; render/context refresh, nil/error handling, record reuse and reset')
