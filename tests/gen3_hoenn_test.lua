local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x10 end}
local V,cache={},{}
function V.require(name)if not cache[name]then cache[name]=assert(loadfile('lib/'..name..'.lua'))(V)end;return cache[name]end
local H=V.require('Gen3Hoenn');local S=V.require('Gen3TileShape');local F=V.require('Gen3Furniture')
assert(H.active());assert(S.of('general','petalburg',0x1dc,0,1).root)
assert(S.of('general','petalburg',0x14,0,1).kind=='flat','FRLG tree number must not leak into Emerald')
assert(S.of('general','petalburg',1,0x10,0).kind=='water')
local tree=S.of('general','petalburg',0x1dc,0,1)
assert(#tree.treeRows==2 and #tree.treeRows[1]==2 and tree.treeFamily=='round')
local count=0
for _,r in ipairs(H.recipes)do
 local cells={};for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary='building',ts={}}
 end end
 local props=F.extract(cells);assert(#props==1 and props[1].recipe==r,r.name)
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
