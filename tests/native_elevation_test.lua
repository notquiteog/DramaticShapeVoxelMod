local T=dofile('lib/TerrainLevels.lua');local data={}
local P={WALL=7,WATER=41,of=function(c)return c end}
package.loaded['src.world.gen2.Permissions']=P
local E=assert(loadfile('lib/Gen2Elevation.lua'))({require=function(n)assert(n=='TerrainLevels');return T end})
local m={width=2,height=2,tileset={id='TILESET_CAVE'}}
function m:tileAt(x,y)
 if y==2 or y==3 then return x%2==0 and 54 or 55 end
 return y<2 and 22 or 1
end
function m:cellCollision()return 0 end
function m:warpAtCell()return nil end
local f=E.field(m)
assert(E.at(m,8,8)==6 and E.at(m,8,56)==0)
assert(E.at(m,8,16)==6 and E.at(m,8,28)==1.5)
assert(E.step(m,0,1).low==0)
assert(E.field(m)==f,'map topology rebuilt each actor frame')
E.invalidate();assert(E.field(m)~=f)
-- Original Gen1 maps are untouched by the Gen2 adapter.
assert(E.field({tileset={id='CAVERN'}})==nil)
local native={{mid=1,coll=0,elev=3},{mid=2,coll=0,elev=0},{mid=3,coll=0,elev=4}}
local layout={width=1,height=3,pair='fixture',cells=native,overrides={}}
function layout:cellAt(x,y)return self.overrides[y*1024+x]or self.cells[y+1]end
local defs={out={id='CAVE',mapType=4,midLayout=layout},inside={id='CENTER',mapType=8,midLayout={width=1,height=1,pair='fixture',cells={},overrides={},cellAt=function()return{mid=1,coll=0,elev=4}end}}}
package.loaded['src.core.game3.scripting.interaction_scripts']={behaviors={fixture={[1]=0,[2]=42,[3]=0}}}
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
local modules={TerrainLevels=T,Gen3Tilesets={resolve=function(pair)return{primary='general',secondary=pair=='bridge_fixture' and 'fortree' or 'cave'}end,outdoor=function()return false end},
 Gen3TileShape={of=function(_,_,_,behavior)return{kind=behavior==42 and 'steps' or 'flat'}end},BuildBudget={tick=function()end}}
local G=assert(loadfile('lib/Gen3Elevation.lua'))({require=function(n)return assert(modules[n],n)end})
assert(G.at(defs.inside,8,8)==0,'collision layer raised Center floor')
assert(G.at(defs.out,8,8)==12 and G.at(defs.out,8,40)==6,'stair topology was replaced by numeric collision layers')
assert(native[1].elev==3 and native[3].elev==4,'native elevation mutated')
local old=G.field(defs.out);layout.overrides[1024]={mid=1,coll=0,elev=3}
assert(G.field(defs.out)~=old,'native edit did not invalidate floor field')
local v={{0,1,0,0,0,1,0,0,2}};G.lift(v,0,6);assert(v[1][2]==7 and v[1][9]==8,'tree billboard anchor not raised with vertices')
print('PASS Gen2 shelves, source floors, cache invalidation, Gen1 isolation, Gen3 collision-layer exclusions and native immutability')

local bridge={width=3,height=3,pair='bridge_fixture',cells={},overrides={}}
function bridge:cellAt(x,y)
 return{mid=1,coll=(x~=1 and y~=1)and 7 or 0,elev=y==1 and(x==1 and 15 or 4)or 3}
end
local b=G.field({id='EM_ROUTE119',mapType=3,midLayout=bridge})
assert(b.cells['0:1'].group==b.cells['2:1'].group,'bridge no longer joins banks')
assert(b.cells['1:0'].group~=b.cells['1:1'].group,'bridge swallowed the crossing underneath')
assert(b.cells['1:2'].group~=b.cells['1:1'].group,'bridge side flattened into the deck')
print('PASS native Fortree bridge bank connections stay separate from side crossings')
