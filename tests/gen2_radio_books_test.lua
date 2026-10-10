local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_depth_furniture.lua').TILESET_RADIO_TOWER[1]
assert(s.design=='gb_radio_books' and s.block==10)
local q=V.require('Gen2DesignedFurniture').build({design=s.design,tiles={{48,49},{26,27},{26,27},{10,11}}},nil,16,128,128)
local backs,tiers=0,{}
for _,f in ipairs(q)do
 if f[1][3]==19.5 and f[2][3]==19.5 and f[3][3]==19.5 and f[4][3]==19.5 then backs=backs+1 end
 for _,p in ipairs(f)do
 assert(p[1]>=.5 and p[1]<=15.5 and p[3]>=19.5 and p[3]<=30.520001 and p[2]>=0 and p[2]<=24.600001,'outside lower blocked cell')
 if p[3]>29 and p[3]<30 then if math.abs(p[2]-20.8)<1e-6 then tiers[3]=true elseif math.abs(p[2]-12.8)<1e-6 then tiers[2]=true elseif math.abs(p[2]-6.2)<1e-6 then tiers[1]=true end end
 end
end
assert(backs==1 and tiers[1] and tiers[2] and tiers[3])
print('PASS radio bookcase native three tiers, closed back and lower-cell bounds')
