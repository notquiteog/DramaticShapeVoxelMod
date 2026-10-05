local T=dofile('lib/TerrainLevels.lua')
local function read(x,y)
 return {floor=y%3~=1,step=y%3==1,layer=3}
end
local f=T.build(2,9,read,nil,6)
assert(T.at(f,8,8)==18 and T.at(f,8,8*16+8)==0,'cumulative terraces flattened')
assert(T.at(f,8,16)==18 and T.at(f,8,16+12)==13.5,'first flight does not meet its two floors')
assert(T.at(f,24,16)==T.at(f,8,16),'parallel flights disagree')
assert(#f.conflicts==0)
local landing=T.build(1,3,function(x,y)return {floor=y~=1,step=y==1}end,nil,6)
assert(T.at(landing,8,8)==6 and T.at(landing,8,40)==0)
-- Same-floor stairs are landings; no invented pit if the floor runs around them.
local flat=T.build(2,3,function(x,y)return {floor=x==1 or y~=1,step=x==0 and y==1,seed=6}end,nil,6)
assert(T.at(flat,8,16)==6 and T.at(flat,8,28)==6)
local blocked=T.build(3,1,function(x)return {floor=x~=1,seed=x==2 and 6 or 0}end)
assert(T.at(blocked,8,8)==0 and T.at(blocked,40,8)==6 and T.at(blocked,24,8)==0)
assert(T.at(blocked,-1,8)==0,'off-map border raised the actor')
print('PASS cumulative terraces, stair contact, parallel columns, level landings, stable prop support, borders')
local seeded=T.build(1,3,function(x,y)return{floor=y~=1,step=y==1,seed=6}end,nil,6)
assert(T.at(seeded,8,8)==12 and T.at(seeded,8,40)==6,'same-art shelves lost their minimum datum')
local function room(height)return T.build(2,2,function()return{floor=true,seed=height}end)end
local a={x=0,y=0,w=2,h=2,floorField=room(6)}
local b={x=2,y=0,w=2,h=2,floorField=room(0)}
local c={x=2,y=2,w=2,h=2,floorField=room(12)}
T.align({a,b,c});assert(a.floorOffset==0 and b.floorOffset==6 and c.floorOffset==-6,'connected maps have different seam heights')
T.align({c,b,a});assert(c.floorOffset==0 and b.floorOffset==12 and a.floorOffset==6,'map-origin reversal changed relative ground levels')

-- A short flight and a longer flight can reach the same two terraces.
-- The shorter flight must meet the common landing rather than tear a seam.
local unequal=T.build(3,4,function(x,y)
 return {floor=y==0 or y==3 or x==0 and y==1,
  step=x==0 and y==2 or x==2 and (y==1 or y==2)}
end,nil,6)
assert(#unequal.conflicts==0)
assert(T.at(unequal,8,8)==12 and T.at(unequal,40,8)==12)
assert(unequal.cells['0:2'].high==12 and unequal.cells['0:2'].low==0)
assert(unequal.cells['2:1'].high==12 and unequal.cells['2:2'].low==0)
print('PASS unequal-length stair flights share closed upper/lower landings')

local reverse=T.build(1,4,function(x,y)return{floor=y==0 or y==3,step=y==1 or y==2,stairUpper=y==3}end,nil,6)
assert(T.at(reverse,8,8)==0 and T.at(reverse,8,56)==12)
assert(T.at(reverse,8,16)==1.5 and T.at(reverse,8,44)==12)
assert(reverse.cells['0:1'].reverse and reverse.cells['0:2'].low==6)
print('PASS south-up mound access uses the same tread heights as actor support')
