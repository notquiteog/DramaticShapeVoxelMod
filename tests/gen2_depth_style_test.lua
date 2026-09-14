local modules={}
local V={require=function(name)return assert(modules[name],name)end}
modules.ModSetting=assert(loadfile('lib/ModSetting.lua'))(V)
local visuals=assert(loadfile('lib/CommunityVisuals.lua'))(V)
local map={tileset={id='TILESET_JOHTO',imageWidth=128,imageHeight=128},cellCollision=function()end}
assert(visuals.crystalStyle==nil,'retired scenery setting remains exposed')
assert(visuals.crystalHD(map) and visuals.crystalDepth(map),'Crystal must default to HD-2D')
assert(not visuals.crystalDepth({tileset={id='OVERWORLD'}}),'Crystal style leaked into Gen 1')
local Trees=assert(loadfile('lib/Gen2DepthTrees.lua'))()
for _,family in ipairs({'broadleaf','conifer','spreading','shrub'}) do
 local v,i={},{}
 Trees.append(v,i,0,0,0,0,family=='shrub' and 4 or 20,42,family)
 assert(#v>0 and #i<=168,'layered trees and crown cap must have a bounded budget')
 for _,p in ipairs(v) do
  assert(p[2]>=0 and p[2]<60,'invalid crown height')
  assert(p[4]>=0 and p[4]<=1 and p[5]>=0 and p[5]<=1,'invalid crown atlas UV')
 end
 for _,n in ipairs(i)do assert(v[n],'invalid card triangle')end
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
local q={};assert(Grass.append(q,map,0,0))
assert(#q==16,'unexpected grass density')
assert(Grass.groundTile(map)==5,'standing grass underlay must use meadow art')
for _,quad in ipairs(q) do
 assert(type(quad.shade)=='number','auxiliary mesh requires scalar shade')
 for i=1,4 do local p=quad[i]
  assert(p[1]>=0 and p[1]<=8 and p[3]>=0 and p[3]<=8)
  assert(p[2]>=0 and p[2]<8,'grass hides full player')
 end
end
map.tileset.id='TILESET_LAB';assert(not Grass.append({},map,0,0),'indoor art used as grass')
print('HD-2D default and style isolation, layered crown budget and grass bounds passed')
