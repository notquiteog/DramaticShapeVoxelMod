local heightCalls=0
local function grassMap(gen)
 return {nativeGeneration=gen,nativeDef={},inBounds=function(_,x,z)return x>=0 and z>=0 end,
 isGrassCell=function(_,x,z)return x==1 and z==1 end,isWalkableCell=function()return true end,isWaterCell=function()return false end}
end
local M=assert(loadfile('lib/KfpSurfaceLife.lua'))({require=function(n)
 if n=='ModSetting'then return{new=function()return{}end}end
 if n=='VoxelScene'then return{groundAt=function()heightCalls=heightCalls+1;return 24 end}end
 if n=='Gen3Elevation'then return{at=function()heightCalls=heightCalls+1;return 32 end}end
 error(n)
end})
local map=grassMap();local f=M.facts({map=map,player={px=16,py=16}})
assert(f.grass and f.height==24 and f.x==24 and f.minX==18)
f=M.facts({map=map,player={px=0,py=0}});assert(not f.grass and heightCalls==1)
map.isWalkableCell=function()return false end
assert(not M.facts({map=map,player={px=16,py=16}}).grass,'blocked decoration accepted')
map.isWalkableCell=function()return true end;map.isWaterCell=function()return true end
assert(not M.facts({map=map,player={px=16,py=16}}).grass,'water grass must never seed')
package.preload['src.core.game3.collision']=function()return{isGrass=function()return true end,isWalkable=function()return true end,isWater=function()return false end}end
assert(M.facts({map=grassMap(3),player={px=16,py=16}}).height==32)
assert(M.facts({map=grassMap(3),player={px=16,py=16,jumpSpriteY=function()return -4 end}}).airborne,'native ledge hop function ignored')
local a,b=M.new(),M.new();local facts={map='a',x=0,z=0,grass=true,height=24,minX=-2,maxX=2,minZ=-2,maxZ=2}
local random=math.random;math.random=function()error('global RNG touched')end
for i=0,30 do facts.x=i;a:update(facts,i/60,'lively');b:update(facts,i/60,'lively')end
math.random=random
assert(#a.particles>0 and #a.particles<=M.MAX_PARTICLES)
for i,p in ipairs(a.particles)do assert(p.y>=24.8 and p.y<=26.8 and p.size<=.8 and p.x>=-2 and p.x<=2 and p.x==b.particles[i].x)end
local verts=M.vertices(a.particles,.5);assert(#verts<=M.MAX_VERTICES and #verts>0)
local n=#a.particles;facts.x=200;a:update(facts,.51,'lively');assert(#a.particles==n,'teleport emission')
facts.map='b';a:update(facts,.52,'lively');assert(#a.particles==0,'map transition retained particles')
facts.x=201;facts.airborne=true;a:update(facts,.53,'lively');assert(#a.particles==0)
facts.airborne=false;facts.grass=false;facts.x=207;a:update(facts,.54,'lively');assert(#a.particles==0)
a:update(facts,2,'off');assert(#a.particles==0)
local full=M.new();facts.map='cap';facts.grass=true
for i=1,100 do facts.x=i*11;full:update(facts,i/1000,'lively')end
assert(#full.particles==M.MAX_PARTICLES and #M.vertices(full.particles,.1)<=M.MAX_VERTICES,'high-rate pool cap failed')
print('PASS KFP seeds native collision/height, independent RNG, bounded mesh, warp/air/water/default exclusion')
