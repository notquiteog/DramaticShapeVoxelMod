local Pool=dofile('lib/EffectMeshPool.lua')
local created,updated,released=0,0,0
local p=Pool.new(function(v,i)
 created=created+1
 return {setVertices=function(self,verts)updated=updated+1;self.vertices=verts end,
 release=function(self)assert(not self.dead);self.dead=true;released=released+1 end}
end)
local v={{1},{2},{3},{4}};local i={1,2,3,1,3,4}
local first=p:get('splash',v,i)
for n=1,100 do v[1][1]=n;assert(p:get('splash',v,i)==first)end
assert(created==1 and updated==100 and first.vertices[1][1]==100)
local second=p:get('door',v,i);assert(second~=first and created==2)
v[5]={5};assert(p:get('splash',v,i)~=first and first.dead and released==1)
p:clear();p:clear();assert(released==3)
print('PASS effect GPU reuse, live coordinates, independent effects, resize and idempotent cleanup')
