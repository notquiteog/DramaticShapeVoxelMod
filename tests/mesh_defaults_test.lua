local checks=0
local M=assert(loadfile('lib/MeshUpload.lua'))({require=function()return{check=function()checks=checks+1;coroutine.yield()end}end})
local vertices={}
for i=1,10001 do vertices[i]={i,2,3,4,5,6,i%2==0 and 7 or nil,8}end
local co=coroutine.create(function()M.treeDefaults(vertices)end)
assert(coroutine.resume(co));assert(checks==1 and vertices[2048][9]==0 and vertices[2049][9]==nil)
while coroutine.status(co)~='dead'do assert(coroutine.resume(co))end
assert(checks==5)
for i,v in ipairs(vertices)do
 assert(v[1]==i and v[6]==6 and v[7]==(i%2==0 and 7 or 0) and v[8]==8 and v[9]==0)
end
print('PASS large tree normalization yields in bounded slices and preserves all source values')
