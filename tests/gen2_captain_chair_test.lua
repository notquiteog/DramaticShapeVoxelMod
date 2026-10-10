local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local n=0
for _,s in ipairs(dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE)do if s.design=='gb_ship_captain_chair'then
 n=n+1;assert(s.supportBounds[2]==16 and s.supportBounds[4]==32)
 assert(s.support==5.5 and s.tiles[3][1]==66 and s.tiles[2][1]==84)
 local q=V.require('Gen2DesignedFurniture').build(s,nil,16,128,128)
 local wall,seat,feet=false,false,false
 for _,f in ipairs(q)do for _,p in ipairs(f)do
  assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=32 and p[2]>=0 and p[2]<=16,'outside two blocked cells')
  if p[3]>16 then assert(p[2]<=14,'chair must not inherit tall wall height')end
  wall=wall or p[2]==16;seat=seat or p[2]==5.5;feet=feet or(p[2]==0 and p[3]>=18)
 end end
 assert(wall and seat and feet)
end end
assert(n==1)
print('PASS captain chair native wall/back/seat and two-cell bounds; sprite support is seat height')
