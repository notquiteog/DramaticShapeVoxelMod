local M=assert(loadfile('lib/KfpTreeDetails.lua'))({require=function(n)if n=='ModSetting'then return{new=function()return{}end}end;error(n)end})
local map={isWalkableCell=function(_,x,z)return x==0 end}
M.record(map,8,0,8,25);M.record(map,24,16,24,45)
local a=M.select(map,24,24);assert(#a==1 and a[1].y==16,'decoration on walking cells')
local rng=math.random;math.random=function()error('global random')end
for t=0,30 do
 local v=M.vertices(a,t,true,true);assert(#v<=M.MAX_VERTICES)
 for _,p in ipairs(v)do assert(p[1]>16 and p[1]<32 and p[3]>16 and p[3]<32,'vine enters neighboring lane');assert(p[2]>15 and p[2]<47,'height invalid')end
end
math.random=rng
map.isWalkableCell=function()return true end;assert(#M.select(map,24,24)==0,'cut tree left floating vines')
for n=1,100 do M.record(map,n,0,n,30)end
map.isWalkableCell=function()return false end;assert(#M.select(map,24,24)<=M.MAX_TREES)
assert(#M.vertices(M.select(map,24,24),1,true,true)<=M.MAX_VERTICES)
print('PASS KFP tree details: explicit model registration, walkable exclusion, bounded foliage/cell footprint, elevations, isolated RNG')

local def={};local first={def=def,isWalkableCell=function()return false end}
M.record(first,24,0,24,30,3)
local rebuilt={def=def,isWalkableCell=first.isWalkableCell}
local native=M.select(rebuilt,24,24);assert(#native==1,'rebuilt map facade loses registered tree')
assert(#M.vertices(native,1,false,true)==0,'vines forced through low native foliage')
assert(#M.vertices(native,1,true,false)>0,'low foliage lost leaf fall')
