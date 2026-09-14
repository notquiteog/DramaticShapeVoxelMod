local M=assert(loadfile('lib/Gen2FloorFinish.lua'))()
local count=0
for id,p in pairs(M.profiles) do
 local blocks={}
 for i=1,64 do blocks[i]={};for j=1,16 do blocks[i][j]=j%4 end end
 local ts={id=id,blocks=blocks,imageHeight=128,tilesPerRow=16}
 local f=assert(M.forTileset(ts),id)
 local source=p.tile or blocks[p.block+1][1]
 local seen={}
 for i,tile in ipairs(f.slots) do
  assert(tile>=128 and tile<256 and not seen[tile]);seen[tile]=true
  for y=0,31 do for x=0,31 do
   local r,g,b=M.color(f,i-1,x,y)
   assert(r>=0 and r<=1 and g>=0 and g<=1 and b>=0 and b<=1)
  end end
 end
 local map={tileset=ts}
 assert(M.tile(map,source,0,0,0)==f.slots[1])
 assert(M.tile(map,source,8,0,0)==f.slots[2])
 assert(M.tile(map,source,0,8,0)==f.slots[3])
 assert(M.tile(map,source,8,8,0)==f.slots[4])
 assert(M.tile(map,source,16,16,0)==f.slots[1])
 assert(M.tile(map,source,0,0,8)==source,'raised surface recoloured as floor')
 assert(M.tile(map,99,0,0,0)==99,'arrow/warp/object tile changed')
 count=count+1
end
assert(not M.forTileset({id='TILESET_ICE_PATH'}),'unreviewed ice floor changed')
print(count..' reviewed floor families: unused slots, world alignment, color and exclusions passed')
