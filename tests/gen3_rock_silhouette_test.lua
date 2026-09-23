local mask={}
-- Pewter mid0x2A4: two dark full-width floor rows, one gap, then rock.
for y=0,1 do for x=0,15 do mask[y*16+x]=true end end
for y=4,14 do for x=4,11 do mask[y*16+x]=true end end
-- Separate dirt speckles must not widen or raise the boulder.
mask[3*16+1]=true;mask[15*16+14]=true
local C=assert(loadfile('lib/Gen3Cave.lua'))({require=function(name)
 assert(name=='Gen3Outdoor');return {mask=function()return mask end}
end})
local vertices=0
C.rock({cx=0,cy=0,mid=0x2A4,ts={},shape={ground=0x294,height=14}},function(v,uv)
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
