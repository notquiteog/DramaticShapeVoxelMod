local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_depth_furniture.lua').TILESET_TRADITIONAL_HOUSE[3];assert(s.design=='gb_traditional_picture' and s.kind=='cabinet')
local q=V.require('Gen2DesignedFurniture').build({design=s.design,tiles={{71,72,73,74},{87,88,89,90}}},nil,16,128,128)
local art,back=0,false
for _,f in ipairs(q)do
 for _,p in ipairs(f)do
  assert(p[1]>=0 and p[1]<=32 and p[3]>=0 and p[3]<=1.500001 and p[2]>=16 and p[2]<=32,'frame/backing enters the native walking apron')
  if p[3]==0 then back=true end
 end
 if math.abs(f[1][3]-1.02)<1e-6 and f[1][2]>=16 and f[2][2]==f[1][2] and f[3][2]<f[1][2] then art=art+1 end
end
assert(art>=512 and back,'complete upright native picture or closed rear lost')
print('PASS native framed picture: upright complete art, closed frame/backing and empty walking apron')
