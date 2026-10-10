local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local n=0
for _,s in ipairs(dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE)do if s.design=='gb_ship_bin'then
 n=n+1;assert(s.tiles[1][1]==72 and s.tiles[2][2]==89)
 local q=V.require('Gen2DesignedFurniture').build(s,nil,16,128,128)
 assert(#q==70,'outer bands/lip/inner walls/floor/base missing')
 local base,inside,lip=0,0,0
 for _,f in ipairs(q)do
  for _,p in ipairs(f)do assert(p[1]>=1.49 and p[1]<=14.51 and p[3]>=1.49 and p[3]<=14.51 and p[2]>=0 and p[2]<=9,'outside native blocked cell')end
  local y=f[1][2]
  if f[2][2]==y and f[3][2]==y and f[4][2]==y then
   if y==0 then base=base+1 elseif y==2 then inside=inside+1 elseif y==9 then lip=lip+1 end
  end
 end
 assert(base==10 and inside==10 and lip==10)
end end
assert(n==1)
print('PASS native ship bin, closed base/interior and one-cell footprint')
