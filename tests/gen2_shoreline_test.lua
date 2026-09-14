local M=assert(loadfile('lib/Gen2Shoreline.lua'))({require=function()
 return {forTileset=function()return {slot=128}end}
end})
local function uv(u,v,w)return {u/8,w}end
local a=M.patch(0,0,{s=true},-2,uv)
local b=M.patch(1,0,{s=true},-2,uv)
assert(#a==64 and #b==64)
for row=0,7 do
 for _,ends in ipairs({{2,1},{3,4}}) do
  local p,q=a[row*8+8][ends[1]],b[row*8+1][ends[2]]
  for i=1,3 do assert(math.abs(p[i]-q[i])<1e-8,'shore tile seam') end
 end
end
local minZ,maxZ=100,-100
for _,q in ipairs(a) do for i=1,4 do local p=q[i]
 assert(p[1]>=0 and p[1]<=8 and p[2]>=-2 and p[2]<=0)
 assert(p[3]>=0 and p[3]<10,'shore apron exceeded two pixels')
 if p[2]<-1.9 then minZ,maxZ=math.min(minZ,p[3]),math.max(maxZ,p[3]) end
end end
assert(maxZ-minZ>.1,'shore boundary remained straight')
local ts={id='TILESET_JOHTO',blocks={{6,5,129}},imageHeight=128}
local profile=M.forTileset(ts)
assert(profile.slot==130,'shore overwrote flowers or source art')
assert(not M.forTileset({id='TILESET_ICE_PATH'}),'unreviewed coast changed')
print('shoreline continuity, bounded slope, natural edge and atlas isolation passed')
