local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local specs=dofile('data/gen2_depth_furniture.lua').TILESET_FACILITY
for _,open in ipairs({false,true})do
 local s=specs[open and 8 or 4];assert(s.design==(open and 'gb_facility_books_open' or 'gb_facility_books'))
 local r={design=s.design,tiles={{64,66},{40,41},{40,41},open and{40,41}or{42,43}}}
 local q=V.require('Gen2DesignedFurniture').build(r,nil,16,128,128);local spines,cap,back=0,false,false
 for _,f in ipairs(q)do for _,p in ipairs(f)do
  assert(p[1]>=.499999 and p[1]<=15.500001 and p[3]>=19.499999 and p[3]<=30.500001 and p[2]>=0 and p[2]<=24.520001,'rack exceeds blocked lower cell')
  if math.abs(p[2]-24.52)<1e-6 then cap=true end;if p[3]==20 then back=true end
 end
 if math.abs(f[1][3]-29.52)<1e-6 and math.abs(f[2][3]-29.52)<1e-6 then spines=spines+1 end
 end
 assert(spines==(open and 126 or 84)and cap and back,'native four-spine shelves or complete cap/back lost')
end
print('PASS facility bookcase variants: two tiers/storage or three open tiers, native spines and closed bounded bodies')
