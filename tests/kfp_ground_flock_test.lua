local M=assert(loadfile('lib/KfpGroundFlock.lua'))({require=function(n)assert(n=='ModSetting');return{new=function()return{}end}end})
local function dry()return{walk=true,water=false,y=24}end
local birds=M.find(dry,0,0);assert(#birds==3)
for _,b in ipairs(birds)do assert(b.y==24)end
assert(not M.find(function()return{walk=true,water=true,y=0}end,0,0),'water flock')
assert(not M.find(function(x,z)return{walk=true,water=false,y=x%2*16}end,0,0),'stair flock')
local safe=M.find(function(x,z)if x==0 and z==-2 then return end;return dry()end,0,0)
assert(safe and safe[1].x>64,'flock placed across occupied corridor')
local a=M.new();local first=a:update('map',dry,0,0,0,true);assert(#first==3)
local x,z=first[1].x,first[1].z
a:update('map',dry,x,z,1,true);local flying=a:update('map',dry,x,z,2,true)
assert(flying[1].y>24 and math.abs(flying[1].x-x)+math.abs(flying[1].z-z)>10,'approach never flushes')
assert(#a:update('map',dry,x,z,5,true)==0,'flushed flock never expires')
assert(#a:update('other',dry,0,0,6,true)==3 and not a.flushed,'map transition keeps old flight')
assert(#a:update('other',dry,0,0,7,false)==0,'OFF keeps birds')
assert(#a:update('third',function()return{water=false,walk=false,y=0}end,0,0,8,true)==0,'solid terrain flock')
math.random=function()error('global random')end
assert(#a:update('fourth',dry,0,0,9,true)==3)
print('PASS KFP ground flock dry/flat placement, native elevation, approach flush, expiry, map/OFF reset and isolated timing')
