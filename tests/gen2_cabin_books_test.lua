local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local t=dofile('data/gen2_depth_furniture.lua').TILESET_LIGHTHOUSE[2];assert(t.design=='gb_cabin_books')
local q=V.require('Gen2DesignedFurniture').build({design=t.design,tiles={{19,62},{54,43},{54,43},{59,60}}},nil,16,128,128)
local art,back,cap=0,false,false
for _,f in ipairs(q)do for _,p in ipairs(f)do
 assert(p[1]>=.499999 and p[1]<=15.500001 and p[3]>=19.499999 and p[3]<=30.500001 and p[2]>=-1e-6 and p[2]<=24.520001,'case exceeds native lower blocked cell')
 if p[3]==20 then back=true end;if math.abs(p[2]-24.52)<1e-6 then cap=true end
end
 if math.abs(f[1][3]-29.52)<1e-6 and math.abs(f[2][3]-29.52)<1e-6 then art=art+1;for _,p in ipairs(f)do assert(p[2]<=19,'short native spines stretched')end end
end
assert(art==36 and back and cap,'native four-group shelves or complete shell lost')
print('PASS cabin bookcase: two native short-spine tiers, storage base and closed shell')
