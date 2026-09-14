local M=assert(loadfile('lib/Gen2Flowers.lua'))()
local ts={id='TILESET_JOHTO',tilesPerRow=16,imageWidth=128,imageHeight=128,
 blocks={{5,3,5,3}},anim={frames={{func='AnimateFlowerTile'},{func='AnimateWaterTile',tile=20}}}}
local p=assert(M.forTileset(ts));assert(p.ground==5 and p.slot>=128)
for y=0,31 do for x=0,31 do
 local r,g,b=M.color(x,y);assert(r>=0 and r<=1 and g>=0 and g<=1 and b>=0 and b<=1)
end end
for y=-2,8 do for x=-2,8 do
 local q={};assert(M.append(q,{tileset=ts},x,y));assert(#q==30)
 for _,f in ipairs(q) do for i=1,4 do local v=f[i]
  assert(v[1]>=x*8 and v[1]<x*8+8 and v[3]>=y*8 and v[3]<y*8+8,'flower crosses footprint')
  assert(v[2]>=0 and v[2]<5.3,'flowers hide the player')
  assert(f.uv[i][1]>=0 and f.uv[i][1]<=1 and f.uv[i][2]>=0 and f.uv[i][2]<=1)
 end end
end end
assert(not M.forTileset({id='TILESET_JOHTO',blocks={},anim={frames={}}}),'unrelated tile 3 changed')
assert(not M.forTileset({id='TILESET_LAB',blocks={},anim=ts.anim}),'interior flowers invented')
print('native flower declaration, small petal/leaf geometry, atlas slots and footprint isolation passed')
