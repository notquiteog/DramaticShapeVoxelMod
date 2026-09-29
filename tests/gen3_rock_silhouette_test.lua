local mask={}
-- Pewter mid0x2A4: two dark full-width floor rows, one gap, then rock.
for y=0,1 do for x=0,15 do mask[y*16+x]=true end end
for y=4,14 do for x=4,11 do mask[y*16+x]=true end end
-- Separate dirt speckles must not widen or raise the boulder.
mask[3*16+1]=true;mask[15*16+14]=true
-- Gen3Cave.rock carves the mask with VoxelHull, so that has to resolve too.
-- Both are real modules with no engine dependency, so load them off disk
-- rather than stubbing a hull out -- a fake hull would not actually test
-- whether the boulder is cut into voxels at all.
local V
V={require=function(name)
  if name=='Gen3Outdoor' then return {mask=function()return mask end} end
  return assert(loadfile('lib/'..name..'.lua'))(V)
end}
-- TreePresentation builds its setting rows when required, and ModSetting wants
-- an owner to log through.
V.mod={log={warn=function()end,info=function()end}}
V.data=function(name) return assert(loadfile('data/'..name..'.lua'))(V) end
local C=assert(loadfile('lib/Gen3Cave.lua'))(V)
-- Gen3Cave.rock reads the UV slot off the tileset and samples the drawing
-- through imageData. This fixture passed ts={}, which worked while the drawing
-- was reached another way and stopped when it was not. The identity slot
-- mapping matches gen3_outdoor_test, and the pixels are a flat opaque fill:
-- this test is about the SILHOUETTE, which comes from the mask above, not from
-- the colours -- the uv assertions below are what check the sampling.
local TS={
  cols=256,
  midToSlot=setmetatable({},{__index=function(_,id)return id end}),
  imageData={getPixel=function()return .5,.5,.5,1 end},
}
local vertices=0
C.rock({cx=0,cy=0,mid=0x2A4,ts=TS,shape={ground=0x294,height=14}},function(v,uv)
 for i,p in ipairs(v)do
  vertices=vertices+1
  assert(p[1]>=4 and p[1]<=12,'floor stripe or dirt widened rock geometry')
  assert(uv[i][2]>=4/16 and uv[i][2]<=15/16,'disconnected floor artwork sampled on boulder')
 end
end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
assert(vertices>0,'boulder removed along with floor decoration')
-- The foreground mask belongs to the art provider and must not be changed.
assert(mask[0] and mask[31] and mask[3*16+1] and mask[15*16+14])
print('PASS rock silhouette excludes disconnected floor stripes/grit and preserves provider mask')
