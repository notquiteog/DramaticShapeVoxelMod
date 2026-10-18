local version='emerald';package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
local V,cache={},{};function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
local S,O=V.require('Gen3TileShape'),V.require('Gen3Outdoor');local uv={{0,0},{1,0},{1,1},{0,1}}
for _,ed in ipairs{'emerald','ruby','sapphire'}do version=ed
 for _,mid in ipairs{0x23f,0x244,0x245,0x246,0x24c,0x254,0x264,0x265,0x266}do
  local s=S.of('general','petalburg',mid,0,7);assert(s.kind=='hedge')
  assert(S.of('general','petalburg',mid,0,0).kind~='hedge','walkable hedge grew a solid')
  assert(S.of('general','fortree',mid,0,7).kind~='hedge','hedge escaped its source tileset')
  local faces,top=0,0
  O.append({cx=3,cy=4,shape=s,mid=mid,ts={}},function(v,t)
   faces=faces+1;for i,p in ipairs(v)do
    assert(p[1]>=48 and p[1]<=64 and p[3]>=64 and p[3]<=80,'hedge escaped blocked cell')
    assert(p[2]>=0 and p[2]<=7);top=math.max(top,p[2]);assert(t[i][1]>=0 and t[i][1]<=1 and t[i][2]>=0 and t[i][2]<=1)
   end
  end,function()return uv end)
  assert(faces==9 and top==7,'hedge lacks a top and four closed shoulders/skirts')
 end
end
version='firered'
for _,mid in ipairs{0xea,0xf8,0xf9}do
 local s=S.of('general','pewter_city',mid,0,7);assert(s.kind=='fence' and #s.rails==0)
 assert(S.of('general','pewter_city',mid,0,0).kind~='fence')
 local count=0;O.append({cx=0,cy=0,shape=s,mid=mid,ts={}},function(v)
  count=count+1;for _,p in ipairs(v)do assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16 and p[2]<=9.6)end
 end,function()return uv end);assert(count==20,'native stake ends gained an invented connecting rail')
end
assert(S.of('general','viridian_city',0x285,0,7).kind=='shrub')
assert(S.of('general','viridian_city',0x285,0,0).kind~='shrub')
assert(S.of('building','lab',0x285,0,7).kind~='shrub')
assert(S.of('general','viridian_city',113,0,7).height==16)
assert(S.of('general','viridian_city',0x1f2,0,7).height==16)
version='emerald';assert(S.of('general','petalburg',0x71,0,7).height==16)
-- A shorter enclosure may not flatten an independently proven upper landing.
local T=V.require('Gen3Terrain');local cells={}
for y=-2,2 do for x=-2,2 do cells[x..':'..y]={cx=x,cy=y,base=x<0 and 0 or 24,shape={kind=x==0 and 'cliff'or'flat',height=16}}end end
assert(T.height(cells,8,8,16)==24,'short rock profile cut through an upper terrace')
for _,c in pairs(cells)do c.base=0 end;assert(T.height(cells,8,8,16)==16)
print('PASS three-edition hedge scope, native stake ends, blocked shrub bounds and terrace-preserving rock height')

local P=V.require('Gen3BoundaryProps');local joined={}
for x=0,1 do joined[x..':0']={cx=x,cy=0,shape={kind='hedge',height=7,bounds={0,0,16,16}}}end
P.prepare(joined);assert(joined['0:0'].hedgeJoin[2]and joined['1:0'].hedgeJoin[1])
local seam={}
for _,c in pairs(joined)do P.hedge(c,function(v)for _,p in ipairs(v)do if p[1]==16 and p[2]==7 then seam[p[3]]=(seam[p[3]]or 0)+1 end end end,uv)end
assert(seam[2]==4 and seam[14]==4,'joined hedge tops leave a two-pixel gap')
print('PASS contiguous native hedge tops share exact end coordinates')
