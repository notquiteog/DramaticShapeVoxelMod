local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_depth_furniture.lua').TILESET_FACILITY[7];assert(s.design=='gb_facility_sofa')
local q=V.require('Gen2DesignedFurniture').build({design=s.design,tiles={{35,36,36,37},{87,88,88,89}}},nil,16,128,128)
local arms,back,seat,bottom=0,0,0,false
for _,f in ipairs(q)do for _,p in ipairs(f)do
 assert(p[1]>=1 and p[1]<=31 and p[3]>=1 and p[3]<=15 and p[2]>=0 and p[2]<=12,'sofa exceeds two blocked cells')
 if p[2]==0 then bottom=true end
end
 if f[1][2]==8.02 and f[2][2]==8.02 then arms=arms+1 end
 if f[1][2]==5.52 and f[2][2]==5.52 then seat=seat+1 end
 if f[1][3]==4.52 and f[2][3]==4.52 then back=back+1 end
end
assert(arms==30 and seat==132 and back==120 and bottom,'native upholstery surfaces or closed feet lost')
print('PASS facility sofa: native upholstery, raised arms/back and bounded closed volume')
