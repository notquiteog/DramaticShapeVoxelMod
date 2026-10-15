local V,cache={},{}
package.loaded['src.core.GameVersion']={get=function()return'emerald'end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
package.loaded['src.core.game3.scripting.interaction_scripts']={behaviors={}}
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
function V.data(n)return dofile('data/'..n..'.lua')end
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
cache.Gen3Tilesets={resolve=function()return{primary='general',secondary='lilycove'}end,outdoor=function()return true end}
local recipe
for _,r in ipairs(V.data('gen3_hoenn_exteriors'))do if r.landmark=='museum'then recipe=r end end
local layout={width=16,height=12,pair='general__lilycove',overrides={},cells={}}
function layout:cellAt(x,y)return self.overrides[x..':'..y]or self.cells[x..':'..y]end
local ox=3
for y=0,11 do for x=0,15 do layout.cells[x..':'..y]={mid=1,coll=y==0 and 7 or 0,elev=4}end end
local function put(x,y,mid,coll)layout.cells[(ox+x)..':'..y]={mid=mid,coll=coll,elev=4}end
for y,row in ipairs(recipe.rows)do for x,mid in ipairs(row)do put(x-1,y-1,mid,recipe.permissions[y][x])end end
local rows={{0x7c,0x79,0x79,0x219,0x21a,0x21b,0x21c,0x79,0x79,0x79},
 {0x89,0x23b,0x23b,0x221,0x222,0x223,0x224,0x22b,0x23b,0x23b}}
local permissions={{7,7,7,7,0,0,7,7,7,7},{7,0,0,7,0,0,7,0,0,0}}
for y,row in ipairs(rows)do for x,mid in ipairs(row)do put(x-1,y+6,mid,permissions[y][x])end end
for _,p in ipairs{{-2,1,0x68},{11,1,0x6a},{-2,7,0x78},{-1,7,0x7c},{10,7,0x79},{11,7,0x7a}}do put(p[1],p[2],p[3],7)end
for y=2,6 do put(-2,y,0x70,7);put(11,y,0x72,7)end
local E=V.require('Gen3Elevation');local def={id='EM_THIRD_PARTY_MUSEUM',mapType=3,midLayout=layout}
local f=E.field(def);assert(#f.conflicts==0)
assert(E.at(def,7*16+8,9*16+8)==6,'lower datum changed')
assert(E.at(def,7*16+8,6*16+8)==18,'museum landing not raised above path')
assert(E.at(def,2*16+8,4*16+8)==18,'garden detached from upper landing')
for x=7,8 do
 assert(f.cells[x..':7'].high==18 and f.cells[x..':7'].low==12)
 assert(f.cells[x..':8'].high==12 and f.cells[x..':8'].low==6)
 for z=112,143 do
  local h=E.at(def,x*16+8,z);local nextH=E.at(def,x*16+8,z+1)
  assert(h>=nextH and h-nextH<=1.5,'contact does not follow physical treads')
 end
end
local cells={}
for y=0,11 do for x=0,15 do local raw=layout:cellAt(x,y)
 cells[x..':'..y]={cx=x,cy=y,mid=raw.mid,collision=raw.coll,pair=layout.pair,primary='general',secondary='lilycove',shape={kind='flat'},ts={}}
end end
local g=assert(V.require('Gen3Civic').prepare(cells,{},{} )[1]);assert(g.foundationCell)
E.bind(cells,{{x=0,y=0,w=16,h=12,def=def}})
assert(g.groundHeight==18 and g.foundationDepth==12,'foundation sampled middle of flight')
assert(cells['7:6'].base==18 and cells['5:0'].base==18,'rear garden and landing height differ')
local uv={{0,0},{1,0},{1,1},{0,1}};local count=0
for y=7,8 do for x=6,9 do local c=cells[x..':'..y]
 V.require('Gen3Stairs').append(c,function(v)
  count=count+1
  for _,p in ipairs(v)do
   assert(p[1]>=x*16 and p[1]<=x*16+16 and p[3]>=y*16 and p[3]<=y*16+16,'stair/rail crosses source cell')
   assert(p[2]+c.base>=6 and p[2]+c.base<=21,'open/high stair foundation')
  end
 end,function()return uv end)
end end
assert(count>=100,'stair and rail shells missing')
-- Changed flank permissions or cliff art invalidate both terrain and models.
layout.overrides['6:8']={mid=0x221,coll=0,elev=4}
assert(E.field(def)~=f and not E.field(def).cells['7:7'].step,'new route still receives raised stairs')
layout.overrides={['1:4']={mid=1,coll=0,elev=4}}
assert(not E.field(def).cells['7:7'].step,'opened terrace boundary still raises other floor groups')
assert(layout.cells['7:7'].elev==4 and layout.cells['7:7'].coll==0,'native data changed')
print('Museum terrace/garden ties, translated topology, treads/contact, closed bounds, native edits and landing/foundation PASS')
