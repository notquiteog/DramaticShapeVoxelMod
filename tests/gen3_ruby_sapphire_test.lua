local version='ruby'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x10 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local H,S,C=V.require('Gen3Hoenn'),V.require('Gen3TileShape'),V.require('Gen3Civic')
for _,game in ipairs({'ruby','sapphire'})do
 version=game;assert(H.active());local recipes=H.exteriorRecipes();assert(#recipes==11)
 assert(S.of('general','petalburg',0x1dc,0,7).kind=='tree')
 assert(S.of('general','petalburg',0x14,0,7).kind=='flat','Kanto trees leaked')
 assert(S.of('general','petalburg',0x66,0,7).kind=='flat','unreviewed Emerald terrain leaked')
 assert(S.of('general','petalburg',1,0x10,0).kind=='water')
 assert(S.of('general','petalburg',0x2a,0x2a,0).kind=='flat','seaweed became Kanto stairs')
 assert(S.of('building','facility',0x2f8,0,7).kind=='flat','unreviewed Emerald interior leaked')
 local approved=0;for _,r in ipairs(H.recipes)do if H.recipeActive(r)then approved=approved+1;assert(r.pair=='building__pokemon_center')end end;assert(approved==21)
 assert(not H.recipeActive({family='frlg'}),'Kanto furniture leaked')
 for _,r in ipairs(recipes)do
  assert(r.header==#r.rows)
  if r.name=='birch_lab' then assert(r.ventShape=='rectangular')end
  if r.name:match('^littleroot_') then assert(r.roofShape=='littleroot_tiered')end
  local cells={}
  for iy,row in ipairs(r.rows)do for ix,mid in ipairs(row)do
   local x,y=ix-1,iy-1;cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=r.pair,primary='general',collision=(iy==1 and r.name~='petalburg_city_gym') and 0 or 7,shape={kind='flat'},ts={}}
  end end
  local list=C.prepare(cells,{},{});assert(#list==1);local g=list[1];local count=0
  C.append(g,function(v)
   count=count+1
   for _,q in ipairs(v)do if r.name:match('^littleroot_') and q[2]>=25 then assert(q[3]>=14.5,'tiered roof projects beyond rear wall')end;if q[2]>1.5 and q[2]<16 then assert(q[3]>=(r.name=='petalburg_city_gym' and 0 or 16),'RS rear lane blocked')end end
  end)
  assert(count>20)
  for _,c in pairs(cells)do c.civic=nil end
  cells['1:2'].mid=1;assert(#C.prepare(cells,{}, {})==0,'partial RS facade claimed')
 end
end
-- Projected plant aprons and floor cushions must remain traversable.
local F=V.require('Gen3Furniture')
for _,game in ipairs({'ruby','sapphire','emerald'})do
 version=game
 for _,r in ipairs(H.recipes)do if r.name=='hoenn_center_plant' or r.kind=='centerSeat' then
  local cells={};for yy,row in ipairs(r.rows)do for xx,mid in ipairs(row)do cells[(xx-1)..':'..(yy-1)]={cx=xx-1,cy=yy-1,mid=mid,pair=r.pair,primary='building',ts={}}end end
  local list=F.extract(cells);assert(#list==1)
  F.append(list[1],function(v)for _,q in ipairs(v)do
   if r.kind=='centerSeat' then assert(q[2]<=1.5,'floor cushion blocks walking cell')else assert(q[3]<32,'plant blocks projected apron')end
  end end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
 end end
end
for _,r in ipairs(H.recipes)do if r.kind=='escalator' then
 F.append({cx=0,cy=0,w=32,d=48,recipe=r,ts={}},function(v)
  local high=-math.huge;for _,q in ipairs(v)do high=math.max(high,q[2])end
  if high>1.5 then for _,q in ipairs(v)do assert(q[3]>=16 and q[3]<33,'Hoenn flight occupies walking apron')end end
 end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
end end
-- Native RS booths must leave their two open rear lanes and front apron clear.
for _,r in ipairs(V.require('Gen3RubySapphire').recipes)do
 for _,game in ipairs({'ruby','sapphire'})do
  version=game;local cells={}
  for yy,row in ipairs(r.rows)do for xx,mid in ipairs(row)do cells[(xx-1)..':'..(yy-1)]={cx=xx-1,cy=yy-1,mid=mid,pair=r.pair,primary='building',ts={}}end end
  local list=F.extract(cells);assert(#list==1 and list[1].recipe==r)
  local underside=false
  F.append(list[1],function(v)
   local lo,hi=math.huge,-math.huge;for _,q in ipairs(v)do
    assert(q[3]>=15 and q[3]<80,'booth intrudes front apron')
    lo=math.min(lo,q[2]);hi=math.max(hi,q[2])
    if q[1]>=20 and q[1]<=44 and q[2]<24 then assert(q[3]<20 or q[3]>=48,'booth intrudes open clerk/warp lane')end
   end
   if lo==28 and hi==28 then underside=true end
  end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
  assert(underside,'open partition/lintel underside')
  version='emerald';assert(not H.recipeActive(r),'RS-only booth leaked into Emerald')
 end
end
version='emerald';assert(#H.exteriorRecipes()>3 and H.recipeActive(H.recipes[1]))
version='firered';assert(not H.active() and H.recipeActive({}) and not H.recipeActive({family='rse'}))
print('Ruby/Sapphire checked-family dispatch, full source matches, native rear lanes and edition isolation PASS')
