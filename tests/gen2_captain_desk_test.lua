local V,c={},{};function V.require(n)c[n]=c[n]or assert(loadfile('lib/'..n..'.lua'))(V);return c[n]end
local n=0
for _,s in ipairs(dofile('data/gen2_furniture.lua').TILESET_LIGHTHOUSE)do if s.design=='gb_ship_captain_desk'then
 n=n+1;assert(#s.tiles==4 and #s.tiles[1]==6 and s.tiles[2][3]==68)
 local q=V.require('Gen2DesignedFurniture').build(s,nil,16,128,128)
 local book,knee=false,true
 for _,f in ipairs(q)do for _,p in ipairs(f)do
  assert(p[1]>=0 and p[1]<=48 and p[3]>=0 and p[3]<=32 and p[2]>=0 and p[2]<=9.500001,'outside native six blocked cells')
  book=book or p[2]==9.5
  if p[2]>0 and p[2]<6.5 and p[1]>15 and p[1]<33 then knee=false end
 end end
 assert(book and knee,'raised open book or knee space lost')
end end
assert(n==2)
print('PASS captain desk native variants, open book, knee gap and six-cell bounds')
