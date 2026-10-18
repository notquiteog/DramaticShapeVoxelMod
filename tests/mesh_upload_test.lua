local now=0
love={timer={getTime=function()return now end},graphics={}}
local B=dofile('lib/BuildBudget.lua')
local M=assert(loadfile('lib/MeshUpload.lua'))({require=function()return B end})
local made,released,maxCount=0,0,0
love.graphics.newMesh=function(format,n)
 made=made+1;local mesh={format=format,count=n,vertices={}}
 function mesh:setVertices(rows,first)
  maxCount=math.max(maxCount,#rows);now=now+.002
  for i,v in ipairs(rows)do self.vertices[first+i-1]=v end
 end
 function mesh:release()released=released+1 end
 return mesh
end
local vertices={};for i=1,8193 do vertices[i]={i,i*.5,i*.25,.2,.3,.8,1,2,3}end
local format={{'VertexPosition','float',3}}
local result
local co=coroutine.create(function()result=assert(M.new(format,vertices))end)
local slices=0
repeat
 B.begin(co,.001,4);local ok,err=coroutine.resume(co);B.finish();assert(ok,err)
 slices=slices+1
 if coroutine.status(co)~='dead'then assert(result==nil,'partial mesh published')end
until coroutine.status(co)=='dead'
assert(slices==6 and maxCount==2048 and result.count==#vertices and result.format==format)
for i,v in ipairs(vertices)do assert(result.vertices[i]==v,'vertex index/fields changed')end
result:release();assert(released==1)
local native=love.graphics.newMesh
love.graphics.newMesh=function(...)
 local mesh=native(...);mesh.setVertices=function()error('driver upload failed')end;return mesh
end
local failed,err=M.new(format,vertices)
assert(not failed and err:find('driver upload failed')and released==2,'partial GPU allocation leaked')
love.graphics.newMesh=native
local sync=assert(M.new(format,vertices));assert(sync.vertices[8193]==vertices[8193]);sync:release()
print('PASS exact ordered vertices, bounded cooperative writes, atomic publication, GPU failure cleanup and synchronous callers')

local abandoned=coroutine.create(function()M.new(format,vertices)end)
B.begin(abandoned,.001,4);assert(coroutine.resume(abandoned));B.finish()
local prior=released;B.cancel(abandoned);assert(released==prior+1)
B.cancel(abandoned);assert(released==prior+1,'cancel released partial mesh twice')
print('PASS canceled coroutine immediately releases its unpublished mesh')
