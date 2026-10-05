local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x10 end}
local V,cache={},{}
function V.require(name)if not cache[name]then cache[name]=assert(loadfile('lib/'..name..'.lua'))(V)end;return cache[name]end
local H=V.require('Gen3Hoenn');local S=V.require('Gen3TileShape');local F=V.require('Gen3Furniture')
assert(H.active());assert(S.of('general','petalburg',0x1dc,0,1).root)
assert(S.of('general','petalburg',0x14,0,1).kind=='flat','FRLG tree number must not leak into Emerald')
assert(S.of('general','petalburg',1,0x10,0).kind=='water')
for _,mid in ipairs({0x3c9,0x3d1})do
 assert(S.of('building','generic_building',mid,0,7).kind=='roomWall')
 assert(S.of('building','generic_building',mid,0,0).kind=='flat','walkable Fortree tile folded')
 assert(S.of('building','shop',mid,0,7).kind=='flat','Fortree siding leaked to shop')
end
for _,mid in ipairs({0x268,0x269,0x26a,0x270,0x272,0x278,0x27a})do
 local cliff=S.of('general','fallarbor',mid,0,7)
 assert(cliff.kind=='cliff' and cliff.ground==0x279 and cliff.height==32)
 assert(S.of('general','fallarbor',mid,0,0).kind=='flat','walkable native floor raised')
 assert(S.of('general','petalburg',mid,0,7).kind=='flat','Fallarbor art leaked to another atlas')
end
for _,mid in ipairs({0x277,0x279,0x2fd,0x2c7})do
 assert(S.of('general','fallarbor',mid,0,7).kind=='flat','sand/decorations became rock wall')
end
local tree=S.of('general','petalburg',0x1dc,0,1)
assert(#tree.treeRows==2 and #tree.treeRows[1]==2 and tree.treeFamily=='round')
local count=0
for _,r in ipairs(H.recipes)do
 local cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary=r.primary or 'building',ts={}}
 end end
 local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,r.name)
 if r.design=='em_lilycove_gallery' then
  local blocked={};for key,c in pairs(cells)do local q={};for k,v in pairs(c)do if k~='prop'then q[k]=v end end;q.collision=q.cy==2 and 7 or 0;blocked[key]=q end
  assert(#F.extract(blocked)==1,'complete gallery lost its blocked base')
  for _,c in pairs(blocked)do c.prop=nil end
  blocked['2:2'].collision=0
  assert(#F.extract(blocked)==0,'gallery occupied native walking space')
 end
 if r.design=='em_fortree_support'then
  assert(#r.rows==4 and #r.rows[1]==2 and r.ground==0x3d9,'support lost its full native drawing')
  local missing={};for key,c in pairs(cells)do
   local copy={};for k,v in pairs(c)do if k~='prop'then copy[k]=v end end
   missing[key]=copy
  end
  missing['1:3']=nil
  assert(#F.extract(missing)==0,'partial support became a truncated tree')
 end
 version='firered';assert(#F.extract(cells)==0,'Hoenn recipe claimed FRLG art: '..r.name);version='emerald'
 count=count+1
end
cache.BuildBudget={tick=function()end,check=function()end}
local Civic=V.require('Gen3Civic')
for _,r in ipairs(H.exteriors)do
 local cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary='general',ts={}}
 end end
 local found=Civic.prepare(cells,{},{});assert(#found==1 and found[1].family==r.name,r.name)
 local p=Civic.profile(found[1]);assert(p.wall>0 and p.wallBottom<=#r.rows*16,'roof/wall extent includes outside ground')
end
version='leafgreen';assert(not H.active());assert(S.of('general','pallet_town',0x14,0,1).kind=='tree')
print('PASS '..count..' native Hoenn furniture recipes, family isolation and four-cell tree artwork')

version='emerald'
assert(S.of('general','mauville',0x288,0,7).kind=='fence')
assert(S.of('general','petalburg',0x288,0,7).kind=='flat','secondary fence alias leaked')
assert(S.of('general','petalburg',0xc5,0x10,7).kind=='rock','ocean rock swallowed by surfable water')
assert(S.of('general','petalburg',0xc5,0x10,0).kind=='water','walkable water blocked by scenery')
assert(S.of('general','petalburg',0x85,0x39,7).direction=='west')
assert(S.of('general','petalburg',0x86,0x38,7).direction=='east')
assert(S.of('general','petalburg',0x71,0xc,7).kind=='cliff')
assert(S.of('general','petalburg',0x71,0xc,0).kind=='flat','walkable floor became a cliff')
local F=V.require('Gen3Furniture')
local carpet={recipe={ground=1,groundRows={{2,3},{4,5}}},cx=8,cy=9}
assert(F.groundAt({prop=carpet,cx=9,cy=10})==5,'carpet border lost beneath fixture')
print('PASS Hoenn scenery scope, water/rock ownership, native ledge directions and carpet underlays')

local fence=S.of('general','verdanturf',0x34d,0,7)
assert(fence.kind=='fence' and fence.postWidth==5.8 and #fence.rails==1)
assert(S.of('general','mossdeep',0x34d,0,7).kind=='flat','Verdanturf fence borrowed another town tile')
print('PASS '..#H.exteriors..' complete Hoenn exterior patterns and native Verdanturf fence scope')

for _,id in ipairs{0x64,0x65,0x6d,0x6e,0x6f,0x7f,0x8f}do
 assert(S.of("general","mossdeep",id,0,7).kind~="cliff","ground or house became a cliff")
end
assert(S.of("general","mossdeep",0x9e,0,7).cap==0x6c,"cliff cap borrowed a grassy slope")

for _,id in ipairs{0xaf,0xcf}do
 assert(S.of('general','mossdeep',id,0,0).kind=='steps','Hoenn normal-behavior stairs flattened')
end
assert(S.of('general','sootopolis',0x244,0,0).kind=='steps')
assert(S.of('general','lavaridge',0x2af,0,0).kind=='steps')
assert(S.of('general','mossdeep',0x244,0,0).kind~='steps','local stair ID leaked')
assert(S.of('general','mossdeep',0xcf,0,7).kind=='tree','blocked tree artwork became stairs')
assert(S.of('general','mossdeep',0x100,0x2a,0).kind~='steps','Emerald seaweed became stairs')

assert(S.of('general','meteor_falls',0x202,8,43).kind=='steps','cave encounter stairs flattened')
assert(S.of('general','mossdeep',0x202,8,43).kind~='steps','Meteor Falls stairs leaked')

for _,primary in ipairs({'general','building'})do
 for _,mid in ipairs({0x2f8,0x300,0x388,0x389,0x390,0x391})do
  assert(S.of(primary,'facility',mid,0,7).kind=='roomWall')
  assert(S.of(primary,'facility',mid,0,0).kind=='flat','walkable wallpaper folded up')
  assert(S.of(primary,'generic_building',mid,0,7).kind~='roomWall','facility wall alias leaked')
 end
 for _,mid in ipairs({0x373,0x374})do
  assert(S.of(primary,'facility',mid,0,7).kind=='fence')
  assert(S.of(primary,'generic_building',mid,0,7).kind~='fence','facility railing alias leaked')
 end
end
print('PASS science-room wall/fence scope and walkable artwork exclusions')

for _,mid in ipairs({0x204,0x20c})do
 assert(S.of('building','oceanic_museum',mid,0,7).kind=='roomWall')
 assert(S.of('building','oceanic_museum',mid,0,0).kind=='flat','walkable museum copy folded up')
 assert(S.of('building','generic_building',mid,0,7).kind=='flat','museum wall escaped atlas scope')
end

local museumFaces=0
V.require('InteriorFurniture').draw('em_museum_wall_case',{
 box=function()end,sample=function()return{}end,
 source=function(x,y,w,h)assert(y+h<=40,'museum carpet wrapped onto upright glass cabinet');museumFaces=museumFaces+1 end})
assert(museumFaces>0)

for _,mid in ipairs{0x222,0x244}do
 assert(H.shape('building','shop',mid,0,7).kind=='roomWall','clock wallpaper became a floor prop')
 assert(H.shape('building','shop',mid,0,0).kind=='flat','walkable clock alias became solid')
end
for _,r in ipairs(H.recipes)do assert(r.name~='hoenn_mart_return','wallpaper/floor claimed as checkout')end
