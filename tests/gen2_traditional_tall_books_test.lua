local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_depth_furniture.lua').TILESET_TRADITIONAL_HOUSE[2];assert(s.design=='gb_traditional_tall_books')
local q=V.require('Gen2DesignedFurniture').build({design=s.design,tiles={{35,36},{62,63},{62,63},{24,25}}},nil,16,128,128)
local spines,cap,back=0,false,false
for _,f in ipairs(q)do
 for _,p in ipairs(f)do
  assert(p[1]>=.499999 and p[1]<=15.500001 and p[3]>=19.499999 and p[3]<=30.500001 and p[2]>=0 and p[2]<=24.520001,'bookcase crosses its native lower cell')
  if math.abs(p[2]-24.52)<1e-6 then cap=true end;if p[3]==20 then back=true end
 end
 if math.abs(f[1][3]-29.52)<1e-6 and math.abs(f[2][3]-29.52)<1e-6 then spines=spines+1 end
end
assert(spines==60 and cap and back,'two complete five-spine rows, cap or back lost')
print('PASS traditional tall racks: two original five-book tiers, closed cap/back and blocked-cell footprint')
