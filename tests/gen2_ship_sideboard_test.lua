local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local n=0
for _,s in ipairs(dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE)do if s.design=='gb_ship_sideboard'then
 n=n+1;assert(s.tiles[1][1]==2 and s.tiles[2][1]==9 and s.tiles[3][2]==26)
 local q=V.require('Gen2DesignedFurniture').build(s,nil,16,128,128)
 local wall,cup,body,border=false,false,false,false
 for _,f in ipairs(q)do
  if f[1][1]==7 and f[1][2]==8.02 and f[1][3]==30.0625 then
   local uv=f.uv[1];border=math.abs(uv[1]-40.5/128)<1e-6 and math.abs(uv[2]-31.5/128)<1e-6
  end
  for _,p in ipairs(f)do
  assert(p[1]>=0 and p[1]<=32 and p[3]>=0 and p[3]<=32 and p[2]>=0 and p[2]<=16,'outside four blocked cells')
  if p[3]>=16 then assert(p[2]<=10.520001,'cabinet inherited wall height')end
  wall=wall or p[2]==16;cup=cup or p[2]==10.5;body=body or(p[2]==0 and p[3]==31)
 end end
 assert(wall and cup and body and border,'native front border must continue beneath removed flat cup')
end end
assert(n==2)
print('PASS sideboard variants, low cabinet/raised cup/porthole wall and four-cell bounds')
