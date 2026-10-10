local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_depth_furniture.lua').TILESET_FACILITY[5];assert(s.design=='gb_facility_workstation')
local q=V.require('Gen2DesignedFurniture').build({design=s.design,tiles={{2,3,4,5},{18,19,20,21}}},nil,16,128,128)
local monitor,underside,screen=false,false,false
for _,f in ipairs(q)do
 for _,p in ipairs(f)do
  assert(p[1]>=.999999 and p[1]<=31.000001 and p[3]>=.999999 and p[3]<=15.000001 and p[2]>=0 and p[2]<=17.000001,'workstation exceeds native two-cell footprint')
  if p[2]==17 then monitor=true end;if p[2]==5.8 then underside=true end
 end
 if f[1][3]==8.99 then screen=true;assert(f[1][2]==16 and f[3][2]==9,'upright original display')end
 for _,uv in ipairs(f.uv)do assert(uv[1]>=0 and uv[1]<1 and uv[2]>=0 and uv[2]<1)end
end
assert(monitor and underside and screen)
print('PASS Facility workstation: raised closed CRT, native display, complete desk underside and bounded footprint')
