local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end return cache[n]end
local p=assert(loadfile('data/gen2_furniture.lua'))().TILESET_BATTLE_TOWER_INSIDE[1]
assert(p.maps.BATTLE_TOWER_1F and #p.tiles==4 and p.tiles[1][1]==8 and p.tiles[4][2]==29,'partial Tower PC crop returned')
assert(p.design=='gb_battle_tower_pc','integrated kiosk turned into desktop PC')
local q=V.require('Gen2DesignedFurniture').build(p,nil,16,128,128)
for _,f in ipairs(q)do for _,v in ipairs(f)do assert(v[1]>=0 and v[1]<=16 and v[3]>=0 and v[3]<=32,'Tower PC crosses blocked drawing')end end
local list=assert(loadfile('data/gen2_depth_furniture.lua'))().TILESET_BATTLE_TOWER_INSIDE
local seat
for _,s in ipairs(list)do
 assert(s.block~=5 and s.block~=28,'partial PC or walking-floor crop returned')
 if s.block==7 then seat=s end
end
assert(seat and seat.design=='gb_seat')
q=V.require('Gen2DesignedFurniture').build({tiles={{14,15},{30,31}},design=seat.design},nil,16,128,128)
for _,f in ipairs(q)do for _,v in ipairs(f)do assert(v[1]>=0 and v[1]<=16 and v[3]>=0 and v[3]<=16 and v[2]<=2.53,'native cushion became table')end end
print('PASS Crystal Battle Tower: complete PC crop, low cushions and no floor-as-furniture patterns')
