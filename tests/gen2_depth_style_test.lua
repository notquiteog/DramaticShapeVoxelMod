local modules={}
local V={require=function(name)return assert(modules[name],name)end}
modules.ModSetting=assert(loadfile('lib/ModSetting.lua'))(V)
local visuals=assert(loadfile('lib/CommunityVisuals.lua'))(V)
local map={tileset={id='TILESET_JOHTO',imageWidth=128,imageHeight=128},cellCollision=function()end}
assert(visuals.crystalStyle==nil,'retired scenery setting remains exposed')
assert(visuals.crystalHD(map) and visuals.crystalDepth(map),'Crystal must default to 2.5D')
assert(not visuals.crystalDepth({tileset={id='OVERWORLD'}}),'Crystal style leaked into Gen 1')
local Trees=assert(loadfile('lib/Gen2DepthTrees.lua'))()
for _,family in ipairs({'broadleaf','conifer','spreading','shrub'}) do
 local v,i={},{}
 Trees.append(v,i,0,0,0,0,family=='shrub' and 4 or 20,42,family)
 assert(#v>0 and #i<=216,'foliage cards must have a bounded budget')
 for _,p in ipairs(v) do
  assert(p[2]>=0 and p[2]<60,'invalid crown height')
  assert(p[4]>=0 and p[4]<=1 and p[5]>=0 and p[5]<=1,'invalid crown atlas UV')
 end
 for _,n in ipairs(i)do assert(v[n],'invalid card triangle')end
 assert(#v==4 and #i==6,'one tree must be one coherent illustrated card')
 for _,p in ipairs(v) do
  assert(#p==9 and p[9]>0,'card anchor must enable billboarding')
  assert(p[7]==0 and p[8]==0,'card must stay rooted at the tree position')
 end
end
local Grass=assert(loadfile('lib/Gen2DepthGrass.lua'))()
local shrub,sapling={},{}
Trees.append(shrub,{},0,0,0,0,3,42,'shrub')
Trees.append(sapling,{},0,0,0,0,4,42,'shrub')
local function bounds(vertices)
 local low,high,left,right=100,-100,100,-100
 for _,v in ipairs(vertices) do
  low,high=math.min(low,v[2]),math.max(high,v[2])
  left,right=math.min(left,v[1]),math.max(right,v[1])
 end
 return low,high,right-left
end
local low,high,wide=bounds(shrub)
local _,saplingHigh=bounds(sapling)
assert(low>=0 and low<1 and high<9 and wide>13,'shrub must be a low full-width mound')
assert(saplingHigh>high*1.5,'cut tree must retain its taller sapling silhouette')
local Trunks=assert(loadfile('lib/Gen2Trees.lua'))()
for _,lift in ipairs({4,16,20}) do
 local trunk,foliage={},{}
 Trunks.appendTrunk(trunk,{},0,0,0,0,lift,42)
 Trees.append(foliage,{},0,0,0,0,lift,42,'broadleaf')
 local _,tip=bounds(trunk)
 assert(tip>foliage[1][9]+3,'original upper trunk was shortened')
 for _,p in ipairs(trunk) do
  assert(p[9]==-foliage[1][9],'upper wood must share its foliage anchor')
 end
end
local pixels={getPixel=function(_,x,y) local v=(x%8>=2 and x%8<=5 and y%8>=2) and .3 or 1;return v,v,v,1 end}
local q={};assert(Grass.append(q,map,0,0,pixels,7,{}))
assert(#q>0,'native grass blades missing')
assert(Grass.groundTile(map)==5,'standing grass underlay must use meadow art')
-- Since 1.27.1 a grass patch emits TWO meshes per source run: the flat meadow
-- plate the blades stand on (z of .025, no canopy anchor) and the upright
-- blades themselves (z of 4, with one). This used to assert z==4 on every quad,
-- which the ground plate made false -- the assertion outlived the geometry, and
-- nothing was red because the suite had no runner. Both halves are pinned now:
-- the plate must stay flat and un-anchored, the blades must stay upright, and
-- each source run must contribute exactly one of each.
local plates,blades=0,0
for _,quad in ipairs(q) do
 assert(type(quad.shade)=='number','auxiliary mesh requires scalar shade')
 if quad.canopy then
  blades=blades+1
  assert(quad.canopy[3]>0,'grass has no camera anchor')
  for i=1,4 do local p=quad[i]
   assert(p[1]>=0 and p[1]<=8 and p[3]==4,'grass blades are no longer upright')
   assert(p[2]>=0 and p[2]<=8,'grass hides full player')
  end
 else
  plates=plates+1
  for i=1,4 do local p=quad[i]
   assert(p[2]==.025,'the grass ground plate must stay flat on the floor')
  end
 end
end
assert(plates>0 and plates==blades,
 ('every grass source run needs one ground plate and one blade (got %d/%d)'):format(plates,blades))
map.tileset.id='TILESET_LAB';assert(not Grass.append({},map,0,0),'indoor art used as grass')
print('2.5D default and style isolation, flat foliage budget and grass bounds passed')

local Shell=assert(loadfile('lib/Gen2InteriorShell.lua'))({require=function(name)
 assert(name=='Structures');return {forMap=function()return {furniture={{height=40}}}end}
end})
assert(Shell.geometry({def={environment='TOWN',width=10,height=9}})==nil)
assert(Shell.geometry({def={environment='ROUTE',width=10,height=9}})==nil)
assert(Shell.geometry({def={environment='CAVE',width=10,height=9}})==nil)
assert(Shell.geometry({def={environment='GATE',width=10,height=9}})==nil)
-- All 39 DUNGEON maps rendered a black void above the wall tops until this.
local dVertices,dIndices,dCeiling=Shell.geometry({def={environment='DUNGEON',width=10,height=9}})
assert(#dVertices==20 and #dIndices==30 and dCeiling>=48,
 'a DUNGEON map must get the same room enclosure as an INDOOR one')
local vertices,indices,ceiling=Shell.geometry({def={environment='INDOOR',width=5,height=4}})
assert(#vertices==20 and #indices==30 and ceiling>=56)
for _,p in ipairs(vertices) do
 assert(p[2]==0 or p[2]==ceiling)
 assert(p[1]<0 or p[1]>160 or p[3]<0 or p[3]>128,'room wall intrudes into map')
end
print('Ground-level room enclosure stays outside native map; overhead/outdoors excluded PASS')
