local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local s=dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE
assert(s[1].maps.OLIVINE_LIGHTHOUSE_6F and s[4].maps.OLIVINE_LIGHTHOUSE_6F)
assert(s[2].design==s[5].design and s[2].design=='gb_ship_dining_table')
assert(s[1].design==s[4].design and s[1].design=='gb_lighthouse_beacon')
for y=1,4 do for x=1,4 do assert(s[1].tiles[y][x]==s[4].tiles[y][x])end end
assert(s[1].tiles[5][2]==130 and s[4].tiles[5][2]==44)
assert(s[1].tiles[6][2]==128 and s[4].tiles[6][2]==59)
for _,i in ipairs{1,2,4,5}do
 local q=V.require('Gen2DesignedFurniture').build(s[i],nil,16,128,128)
 local low,high,tableCaps,discSides,discCaps=false,false,0,0,0
 for _,f in ipairs(q)do
  local a,b,d=f[1],f[2],f[3]
  if a[1]==16 and a[3]==31 and f[4][1]==a[1] and f[4][2]==a[2] and f[4][3]==a[3] then
   local ny=(b[3]-a[3])*(d[1]-a[1])-(b[1]-a[1])*(d[3]-a[3])
   local upper=({[14]=true,[17]=true,[20]=true,[23]=true,[26]=true})[a[2]]
   assert(upper and ny>0 or not upper and ny<0,'lens top/underside winding incorrect')
   discCaps=discCaps+1
  end
  if a[2]==b[2] and d[2]>a[2] and math.abs(b[1]-a[1])>1e-6 and math.abs(b[3]-a[3])>1e-6 then
   local nx=-(b[3]-a[3])*(d[2]-a[2]);local nz=(b[1]-a[1])*(d[2]-a[2])
   assert(nx*((a[1]+b[1])/2-16)+nz*((a[3]+b[3])/2-31)>0,'lens band winding points inward')
   discSides=discSides+1
  end
  if f[1][2]==8 and f[2][2]==8 and f[3][2]==8 and f[4][2]==8 then tableCaps=tableCaps+1 end
  for _,p in ipairs(f)do
  assert(p[1]>=0 and p[1]<=32 and p[3]>=0 and p[3]<=48 and p[2]>=0 and p[2]<=((i==1 or i==4)and 32 or 8.020001),'outside six blocked native cells')
  if p[2]==0 then low=true end;if p[2]>7 then high=true end
 end end
 assert(low and high,'closed supports or elevated subject lost')
 if i==2 or i==5 then assert(tableCaps==1,'coincident tabletop faces would flicker')else assert(discSides==20 and discCaps==80,'closed octagonal lens sides or caps lost')end
end
print('PASS G/S and Crystal complete dining/beacon layouts and six-cell geometry bounds')
