local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end return cache[n]end
local list=assert(loadfile('data/gen2_furniture.lua'))().TILESET_BATTLE_TOWER_INSIDE
local r=list[4];assert(r.id=='crystal_battle_elevator_entry' and r.maps.BATTLE_TOWER_HALLWAY and not r.maps.BATTLE_TOWER_1F)
local q=V.require('Gen2DesignedFurniture').build(r,nil,16,128,128)
for _,f in ipairs(q)do for _,p in ipairs(f)do
 assert(p[1]>=0 and p[1]<=32 and p[3]>=0 and p[3]<=16 and p[2]>=0 and p[2]<=16.021,'solid geometry enters lower native walking/warp row')
 if p[1]>17 and p[1]<31 then assert(p[3]<=.53 or p[2]>=15,'door blocks upper walking approach')end
end end
print('PASS Crystal elevator entry: blocked-cell wall and open lower row/native warp approach')
