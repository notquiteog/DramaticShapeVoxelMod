local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end return cache[n]end
local list=assert(loadfile('data/gen2_furniture.lua'))().TILESET_BATTLE_TOWER_INSIDE
for i=2,3 do
 local r=list[i];assert(r.tileRow==0,'offset hallway door incorrectly covered')
 local q=V.require('Gen2DesignedFurniture').build(r,nil,16,128,128)
 local rear=false
 for _,f in ipairs(q)do for _,p in ipairs(f)do
  assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16 and p[2]>=0 and p[2]<=16)
  assert(p[1]<=1 or p[1]>=15 or p[3]<=.53 or p[2]>=15,'door fills walking approach')
  if p[3]==.52 then rear=true end
 end end
 assert(rear,'native door face absent')
end
print('PASS Crystal Tower doors: rear face, closed frame and open native approach; offset drawing excluded')
