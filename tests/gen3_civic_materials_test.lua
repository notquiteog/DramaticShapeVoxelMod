local builds,releases=0,0
local function image()return {release=function()releases=releases+1 end}end
local civic={profile=function(g)return {w=g.width*16,h=g.depth*16}end,
 material=function()builds=builds+1;return image(),image(),function()return true end end}
local canonical=assert(loadfile('lib/NativeGeometryCache.lua'))({require=function()return {}end}).canonical
local M=assert(loadfile('lib/Gen3CivicMaterials.lua'))({require=function(n)
 if n=='Gen3Civic'then return civic end
 assert(n=='NativeGeometryCache');return {canonical=canonical}
end})
local source,over={},{}
local g={kind='mart',width=2,depth=2,rows={{1,2},{3,4}},custom={openings={{2,3,4,5}}},
 ts={imageData=source,overImageData=over,cols=2,rows=2,midToSlot={[1]=0,[2]=1,[3]=2,[4]=3}}}
local a=M.acquire(g)
g.cx=12;g.cy=20;g.groundHeight=6
local b=M.acquire(g)
assert(a==b and builds==1 and a.refs==2,'translated scene rebuilt identical source material')
M.release(a);assert(releases==0 and b.read(),'retired scene released shared texture')
g.custom.openings[1][1]=3
local c=M.acquire(g);assert(c~=b and builds==2,'changed aperture reused old glow mask')
g.ts.midToSlot[1]=3
local d=M.acquire(g);assert(d~=c and builds==3,'slot relocation reused stale pixels')
g.ts.imageData={}
local e=M.acquire(g);assert(e~=d and builds==4,'palette/source replacement reused stale texture')
g.ts.overImageData={}
local f=M.acquire(g);assert(f~=e and builds==5,'overlay replacement reused stale texture')
M.invalidate();local h=M.acquire(g)
assert(h~=f and builds==6 and releases==0,'explicit invalidation destroyed active leases or retained stale source')
for _,v in ipairs{b,c,d,e,f,h}do M.release(v)end
assert(releases==12,'scene-owned textures leaked or were released twice')
M.release(h);assert(releases==12)
local fresh=M.acquire(g);assert(builds==7,'idle GPU material retained after last scene')
M.release(fresh)
-- Extension descriptors that cannot be fingerprinted keep normal ownership.
g.custom.callback=function()end
local x,y=M.acquire(g),M.acquire(g)
assert(x~=y and builds==9);M.release(x);M.release(y)
assert(releases==18)
print('PASS civic materials: shared scene leases, source/recipe/slot invalidation, no idle GPU retention, extension fallback')
