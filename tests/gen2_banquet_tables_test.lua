local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local n=0
for _,s in ipairs(dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE)do if s.design=='gb_ship_banquet_table'then
 n=n+1;assert(#s.tiles==10 and #s.tiles[1]==4)
 assert(s.tiles[5][3]==26 and s.tiles[7][2]==64)
 local q=V.require('Gen2DesignedFurniture').build(s,nil,16,128,128)
 local feet,cups,plates,middleCup={}, {},false,false
 for _,f in ipairs(q)do for _,p in ipairs(f)do
  assert(p[1]>=0 and p[1]<=32 and p[3]>=0 and p[3]<=80 and p[2]>=0 and p[2]<=10.520001,'outside ten blocked native cells')
  if p[2]==0 then feet[p[3]]=true end
  if p[2]>10 then cups[p[1]]=true;middleCup=middleCup or (p[1]==18 and math.abs(p[3]-(13+34*65/69-2))<1e-6) end
  plates=plates or math.abs(p[2]-8.57)<1e-6
 end end
 assert(feet[14] and feet[44] and feet[75],'missing middle/end supports')
 assert(cups[10] and cups[18] and plates and middleCup,'native cups or raised platters missing/misaligned')
end end
assert(n==2)
print('PASS independent G/S and Crystal banquet patterns, supports, meals, blocked footprint')
