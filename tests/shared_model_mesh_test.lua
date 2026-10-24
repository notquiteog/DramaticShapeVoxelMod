local S=dofile('lib/SharedModelMesh.lua')
local uploads,releases=0,0
local function create()
 uploads=uploads+1
 return{release=function(self)assert(not self.dead);self.dead=true;releases=releases+1 end}
end
local v,i,format,image={},{},{},{}
local a,la=S.acquire(v,i,format,create,image)
local b,lb=S.acquire(v,i,format,create,image)
assert(a==b and uploads==1)
S.release(la);assert(not b.dead)
S.release(lb);assert(b.dead and releases==1)
local c,lc=S.acquire(v,i,format,create,image);assert(c~=a and uploads==2)
local d,ld=S.acquire(v,{},format,create,image);assert(c~=d)
local e,le=S.acquire(v,i,{},create,image);assert(c~=e)
local f,lf=S.acquire(v,i,format,create,{});assert(c~=f)
for _,l in ipairs{lc,ld,le,lf}do S.release(l)end
assert(uploads==releases,'idle prototype survived final owner')
assert(not S.acquire(v,i,format,function()return nil,'device failure'end,image))
local suspended=false
local function yielding()
 local mesh=create()
 if not suspended then suspended=true;coroutine.yield()end
 return mesh
end
local p,lp
local co=coroutine.create(function()p,lp=S.acquire(v,i,format,yielding,image)end)
assert(coroutine.resume(co))
local q,lq=S.acquire(v,i,format,yielding,image)
assert(coroutine.resume(co));assert(p==q,'overlapping builds published duplicate prototype')
S.release(lp);assert(not q.dead);S.release(lq)
assert(uploads==releases,'yield race leaked prototype')
print('PASS live scene sharing, dependency isolation, upload failure, final release and overlapping build publication')
