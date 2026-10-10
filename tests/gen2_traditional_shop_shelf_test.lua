local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_depth_furniture.lua').TILESET_TRADITIONAL_HOUSE[1]
assert(s.design=='gb_traditional_shop_shelf' and s.block==2)
local t={design=s.design,tiles={{6,7,7,32},{22,23,23,48},{33,39,39,40},{49,55,55,56}}}
local q=V.require('Gen2DesignedFurniture').build(t,nil,16,128,128)
local tiers={};local backs=0
for _,f in ipairs(q)do
 if f[1][3]==19.5 and f[2][3]==19.5 and f[3][3]==19.5 and f[4][3]==19.5 then backs=backs+1 end
 for _,p in ipairs(f)do
 assert(p[1]>=.5 and p[1]<=31.5 and p[3]>=19.5 and p[3]<=30.500001 and p[2]>=0 and p[2]<=24.600001,'outside lower blocked source cells')
 if p[3]>=29 and p[3]<30 and p[2]>.6 then tiers[math.floor((p[2]-.6)/6)]=true end
end end
for i=0,3 do assert(tiers[i],'stock tier missing')end
assert(backs==1,'shelves must not overlap the rear shell')
print('PASS traditional shop shelf native four stock tiers, closed body and lower-cell bounds')
