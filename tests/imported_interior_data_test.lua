local data=dofile('lib/ImportedInteriorData.lua')
local V={mod={read=function(path)local f=io.open(path,'rb');if not f then return end;local s=f:read('*a');f:close();return s end}}
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end}}
V.require=function(name)return assert(modules[name],name)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
assert(S.register('oras_center_pc',data.oras_center_pc,{read=V.mod.read}))
local info=S.info('oras_center_pc');assert(info.parts==4)
local vertices,fit=S.vertices('oras_center_pc',{width=16,depth=16,height=24,padding=.25})
assert(#vertices==4 and fit.bounds[5]<=24)
local triangles,shaded,transparent=0,false,false
for _,part in ipairs(data.oras_center_pc.parts)do
 assert(part.colors and #part.colors==#part.vertices)
 local f=assert(io.open(part.texture,'rb'));local bytes=f:read('*a');f:close();assert(bytes:sub(1,8)=='\137PNG\r\n\26\n')
 triangles=triangles+#part.indices/3
 for _,c in ipairs(part.colors)do shaded=shaded or c[1]<1;transparent=transparent or c[4]<1 end
end
assert(triangles==202 and shaded and transparent,'source topology/RGBA lost')
for _,part in ipairs(vertices)do
 assert(part.format==S.COLOR_FORMAT)
 for _,v in ipairs(part.vertices)do
  assert(#v==10 and v[1]>=.25 and v[1]<=15.75 and v[3]>=.25 and v[3]<=15.75)
  assert(v[2]>=0 and v[2]<=24.000001)
 end
end
assert(fit.bounds[4]-fit.bounds[1]>13,'public terminal underfills blocked native width')
print('PASS selected source PC geometry, all PNGs, original RGBA and bounded uniform native footprint')
