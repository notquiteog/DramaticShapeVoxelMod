local version='ruby'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x10 end}
local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local H,S,C=V.require('Gen3Hoenn'),V.require('Gen3TileShape'),V.require('Gen3Civic')
for _,game in ipairs({'ruby','sapphire'})do
 version=game;assert(H.active());local recipes=H.exteriorRecipes();assert(#recipes==9)
 assert(S.of('general','petalburg',0x1dc,0,7).kind=='tree')
 assert(S.of('general','petalburg',0x14,0,7).kind=='flat','Kanto trees leaked')
 assert(S.of('general','petalburg',0x66,0,7).kind=='flat','unreviewed Emerald terrain leaked')
 assert(S.of('general','petalburg',1,0x10,0).kind=='water')
 assert(S.of('general','petalburg',0x2a,0x2a,0).kind=='flat','seaweed became Kanto stairs')
 assert(S.of('building','facility',0x2f8,0,7).kind=='flat','unreviewed Emerald interior leaked')
 for _,r in ipairs(H.recipes)do assert(not H.recipeActive(r))end
 assert(not H.recipeActive({family='frlg'}),'Kanto furniture leaked')
 for _,r in ipairs(recipes)do
  assert(r.header==#r.rows)
  if r.name=='birch_lab' then assert(r.ventShape=='rectangular')end
  local cells={}
  for iy,row in ipairs(r.rows)do for ix,mid in ipairs(row)do
   local x,y=ix-1,iy-1;cells[x..':'..y]={cx=x,cy=y,mid=mid,pair=r.pair,primary='general',collision=(iy==1 and r.name~='petalburg_city_gym') and 0 or 7,shape={kind='flat'},ts={}}
  end end
  local list=C.prepare(cells,{},{});assert(#list==1);local g=list[1];local count=0
  C.append(g,function(v)
   count=count+1
   for _,q in ipairs(v)do if q[2]>1.5 and q[2]<16 then assert(q[3]>=(r.name=='petalburg_city_gym' and 0 or 16),'RS rear lane blocked')end end
  end)
  assert(count>20)
  for _,c in pairs(cells)do c.civic=nil end
  cells['1:2'].mid=1;assert(#C.prepare(cells,{}, {})==0,'partial RS facade claimed')
 end
end
version='emerald';assert(#H.exteriorRecipes()>3 and H.recipeActive(H.recipes[1]))
version='firered';assert(not H.active() and H.recipeActive({}) and not H.recipeActive({family='rse'}))
print('Ruby/Sapphire checked-family dispatch, full source matches, native rear lanes and edition isolation PASS')
