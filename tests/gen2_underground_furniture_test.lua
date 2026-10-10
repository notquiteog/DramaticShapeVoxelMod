local V,cache={},{}
function V.require(n)
 if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end
 return cache[n]
end
local list=assert(loadfile('data/gen2_furniture.lua'))().TILESET_GATE
assert(#list==3,'walkable stools must remain native floor')
local counter=list[1]
assert(counter.tiles[1][1]==8 and counter.tiles[6][2]==37 and #counter.tiles==6)
local q=V.require('Gen2DesignedFurniture').build(counter,nil,16,128,128)
local cap=false
for _,face in ipairs(q)do for _,p in ipairs(face)do
 assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=48,'counter leaves its three blocked native cells')
 assert(p[2]>=0 and p[2]<=8,'stall exceeds authored working height')
 if p[3]==47 and p[1]==13 then cap=true end
end end
assert(cap,'whole stall lost its shaped end')
assert(list[2].model=='planter' and #list[2].tiles==4)
assert(list[3].model=='planter' and #list[3].tiles==2)
for _,r in ipairs(list)do assert(r.maps.GOLDENROD_UNDERGROUND,'unreviewed gate map claimed');assert(r.tiles[1][1]~=84,'native walkable stool became solid furniture')end
print('PASS underground full counter and plant patterns, bounded counter and no raised stools')
