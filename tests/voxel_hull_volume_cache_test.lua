-- Geometry/material identity and bounded shape-cache ownership across palettes.
local file=assert(io.open('lib/VoxelHull.lua'));local source=file:read('*a');file:close()
local Trees=dofile('lib/NativeTreeModels.lua');local calls=0;local part=Trees.part
Trees.part=function(...)calls=calls+1;return part(...)end
local function loader(name)
 if name=='NativeTreeModels'then return Trees end
 assert(name=='BuildBudget');return {tick=function()end,check=function()end}
end
local V={require=loader}
local H=assert(loadstring(source))(V)
local original=assert(loadstring((source:gsub("local volume=organic=='tree' and family and treeVolume%(family,w,h,step,bottom,nx,ny,nz%)",'local volume=nil'))))(V)
local function sample(palette)return function(x,y)
 return .08+(x%3)*.01,.5+(y%5)*.01,.13,1,(x+palette)/128,(y+palette)/128
end end
local function same(a,b)
 assert(#a==#b)
 for i,q in ipairs(a)do
  local r=b[i];assert(q.u==r.u and q.v==r.v and q.shade==r.shade)
  for k,p in ipairs(q)do for n=1,3 do assert(p[n]==r[k][n])end end
 end
end
for _,family in ipairs({'conifer','tiered','broad','mossdeep','round','ash','sapling'})do
 for _,step in ipairs({1,2})do
  local expected=original.build(16,24,sample(0),step,2,nil,'tree',family)
  same(H.build(16,24,sample(0),step,2,nil,'tree',family),expected)
  local before=calls;local second=H.build(16,24,sample(9),step,2,nil,'tree',family)
  assert(calls==before,'same occupancy reevaluated for new palette/UV')
  same(second,original.build(16,24,sample(9),step,2,nil,'tree',family))
 end
end
local before=calls
same(H.build(16,24,sample(0),1,2,nil,'tree','conifer'),original.build(16,24,sample(0),1,2,nil,'tree','conifer'))
assert(calls-before>16*24*16,'old mask not evicted from bounded cache')
for _,dims in ipairs({{16,32,2,0},{32,16,2,2},{16,24,1,0}})do
 same(H.build(dims[1],dims[2],sample(3),dims[3],dims[4],nil,'tree','conifer'),original.build(dims[1],dims[2],sample(3),dims[3],dims[4],nil,'tree','conifer'))
end
print('PASS cached native occupancy exactly preserves geometry, per-source UV/shading, dimensions and bounded eviction')
