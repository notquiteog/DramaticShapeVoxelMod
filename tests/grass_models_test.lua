local V,cache={},{}
function V.require(n)if not cache[n]then cache[n]=assert(loadfile('lib/'..n..'.lua'))(V)end;return cache[n]end
cache.BuildBudget={check=function()end}
local G=V.require('GrassModels')
local checked=0
for _,name in ipairs{'oras_green','oras_dry','oras_tall'}do
 local info=assert(G.info(name))
 assert(info.triangles==(name=='oras_tall'and 24 or 16)and info.doubleSided)
 for _,extent in ipairs{8,16}do for rotation=0,3 do
  local v,i=G.vertices(name,extent,rotation);local low,high=math.huge,-math.huge
  assert(#i==info.triangles*3)
  for _,p in ipairs(v)do
   assert(p[1]>=.019*extent and p[1]<=.981*extent and p[3]>=.019*extent and p[3]<=.981*extent,'imported blade escaped native square')
   -- Source green/dry leaves deliberately wrap slightly beyond the image U.
   assert(p[4]>=-.06 and p[4]<=1.023 and p[5]>=0 and p[5]<=1,'source UV lost')
   low,high=math.min(low,p[2]),math.max(high,p[2]);checked=checked+1
  end
  assert(math.abs(low)<1e-8 and math.abs(high-info.heightPerExtent*extent)<1e-8,'bind-pose grounding/proportions changed')
  for _,n in ipairs(i)do assert(n>=1 and n<=#v and n%1==0)end
  assert(G.vertices(name,extent,rotation)==v,'prototype not reused')
  local r=G.vertices(name,extent,rotation+1)
  for k,p in ipairs(v)do assert(math.abs(r[k][1]-(extent-p[3]))<1e-9 and math.abs(r[k][3]-p[1])<1e-9,'quarter-turn changed source shape')end
 end end
end
assert(not G.vertices('absent',16,0)and not G.vertices('oras_green',7,0)and not G.vertices('oras_green',8,.5))
local instancing,failUpload=true,false
local meshes={}
local function mesh(vertices)
 local m={vertices=vertices}
 function m:release()assert(not self.released,'double-release');self.released=true end
 function m:setTexture(image)self.texture=image end
 function m:attachAttribute(_,offsets)self.offsets=offsets end
 function m:detachAttribute()self.offsets=nil end
 function m:setVertices(vertices)self.vertices=vertices end
 function m:setVertexMap(indices)self.indices=indices end
 meshes[#meshes+1]=m;return m
end
local fileReleases,imageReleases=0,0
love={filesystem={newFileData=function(bytes)
 assert(bytes=='original PNG');return{release=function()fileReleases=fileReleases+1 end}
end},graphics={getSupported=function()return{instancing=instancing}end,
 newMesh=function(_,positions)return mesh(positions)end,
 newImage=function()return{setFilter=function()end,setWrap=function()end,release=function()imageReleases=imageReleases+1 end}end,
 drawInstanced=function(m,count)assert(m.offsets and #m.offsets.vertices==count)end,
 draw=function(m)assert(not m.offsets)end}}
V.mod={read=function()return'original PNG'end}
local function upload(v,i)
 if failUpload then return end
 local m=mesh(v);m.indices=i;return m
end
local placements={{model='oras_green',extent=8,rotation=0,x=16,y=7,z=24},
 {model='oras_green',extent=8,rotation=0,x=32,y=-3,z=40}}
local parts=assert(G.buildBatches(placements,upload));assert(#parts==1 and parts[1].instanced and parts[1].count==2)
local prototype=parts[1].model
assert(prototype.texture==parts[1].image and #prototype.vertices==33 and #parts[1].mesh.offsets.vertices==2)
local uniforms={};local shader={send=function(_,k,v)uniforms[k]=v end}
V.require('ModelInstances').draw(parts[1].mesh,shader);assert(uniforms.sceneryInstances==0)
local instancePositions=parts[1].mesh.offsets.vertices
instancing=false
local fallback=assert(G.buildBatches(placements,upload));assert(not fallback[1].instanced and fallback[1].model==nil)
local f=fallback[1].mesh
for j,offset in ipairs(instancePositions)do for k,v in ipairs(prototype.vertices)do
 local p=f.vertices[(j-1)*#prototype.vertices+k]
 for axis=1,3 do assert(p[axis]==v[axis]+offset[axis],'ordinary mesh and instance placement differ')end
 for axis=4,6 do assert(p[axis]==v[axis],'ordinary mesh changed original UV/shade')end
end end
assert(fileReleases==1,'source PNG was reloaded for identical placements')
assert(G.hideRect(parts,16,24,24,32)==1 and parts[1].count==1 and parts[1].mesh.count==1)
assert(parts[1].positions[1][1]==32 and parts[1].mesh.offsets.vertices[1][2]==-3,'Cut did not compact GPU placement offsets')
assert(G.hideRect(fallback,16,24,24,32)==1 and fallback[1].count==1)
assert(f.indices[1]>#prototype.vertices,'Cut fallback still draws removed vertex slot')
assert(G.hideRect(parts,32,40,40,48)==1 and parts[1].count==0 and parts[1].mesh.count==0)
assert(G.hideRect(fallback,32,40,40,48)==1 and fallback[1].count==0)
G.releaseBatches(parts);assert(prototype.released)
G.releaseBatches(fallback);assert(f.released)
local many={};for i=1,700 do many[i]={model='oras_green',extent=8,rotation=0,x=i*8,y=0,z=0}end
local chunks=assert(G.buildBatches(many,upload));local count=0
for _,part in ipairs(chunks)do assert(#part.mesh.vertices<=G.FALLBACK_VERTEX_LIMIT);count=count+part.count end
assert(#chunks==3 and count==700,'fallback uploads are not bounded')
G.releaseBatches(chunks)
instancing=true
local before=#meshes;local cancelled=0;local owned={}
local result,reason=G.buildBatches(placements,upload,{parts=owned,cancelled=function()
 cancelled=cancelled+1
 if cancelled>=2 then assert(#owned==1 and owned[1].model and owned[1].mesh,'yielding resources were not scene-owned');return true end
end})
assert(not result and reason:find('cancelled'))
assert(#owned==1 and owned[1].model==nil and owned[1].mesh==nil and owned[1].count==0,'cancelled scene-owned parts not cleared')
for i=before+1,#meshes do assert(meshes[i].released,'cancelled build leaked GPU resource')end
instancing=false
before=#meshes;cancelled=0
result,reason=G.buildBatches(many,upload,{cancelled=function()cancelled=cancelled+1;return cancelled>=260 end})
assert(not result and reason:find('cancelled'))
for i=before+1,#meshes do assert(meshes[i].released,'cancelled chunked fallback leaked GPU resource')end
failUpload=true;assert(not G.buildBatches(placements,upload),'upload failure did not preserve native fallback')
assert(not G.buildBatches({{model='oras_green',extent=8,x=0,y=0/0,z=0}},upload))
assert(not G.buildBatches({{model='oras_green',extent=8,x=0,y=0}},upload))
G.release();assert(imageReleases==1)
V.mod.read=function()return nil end
assert(not G.image('oras_green'),'missing source asset must leave native path available')
assert(fileReleases==1)
V.mod.read=function()return'original PNG'end
assert(G.image('oras_green')and fileReleases==2,'late asset availability did not retry')
G.release();assert(imageReleases==2)
print('PASS '..checked..' imported source vertex checks,24 bounded bind-pose/rotation variants, source UVs, shared GPU mesh/fallback parity,700-placement bounded fallback, native Cut, cancellation cleanup and late-asset retry')
