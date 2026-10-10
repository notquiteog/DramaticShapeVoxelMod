local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local list=dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE
local n=0
for _,s in ipairs(list)do if s.design=='gb_ship_square_table'then
 n=n+1;assert(#s.tiles==4 and #s.tiles[1]==4)
 assert(s.tiles[2][2]==26 and (s.tiles[3][2]==130 or s.tiles[3][2]==44))
 local q=V.require('Gen2DesignedFurniture').build(s,nil,16,128,128)
 local feet,cup,underside=false,false,false
 for _,f in ipairs(q)do
  for _,p in ipairs(f)do
   assert(p[1]>=0 and p[1]<=32 and p[3]>=0 and p[3]<=32 and p[2]>=0 and p[2]<=10.520001,'outside four blocked native cells')
   feet=feet or p[2]==0;cup=cup or p[2]>10
  end
  if f[1][2]==6.5 and f[2][2]==6.5 and f[3][2]==6.5 and f[4][2]==6.5 then underside=true end
 end
 assert(feet and cup and underside,'legs, cup or closed underside missing')
end end
assert(n==2,'must cover independent Crystal and G/S patterns')
print('PASS two native square-table variants, closed supports/cup and blocked-cell bounds')
