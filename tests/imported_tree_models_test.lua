-- Optional source RGBA uses an explicit format; old six-float assets stay exact.
local Tree=assert(loadfile('lib/ImportedTreeData.lua'))()
local Data=assert(loadfile('lib/SceneryModelData.lua'))()
local instanced=true;local allocated={}
local function object()local o={release=function(self)assert(not self.released);self.released=true end,setTexture=function(self,t)self.image=t end};allocated[#allocated+1]=o;return o end
local modules={SceneryModelData=Data,ImportedTreeData=Tree,BuildBudget={check=function()end},ModelInstances={new=function(mesh,pos)if not instanced then return end;local o=object();o.instanceMesh,o.positions=mesh,pos;return o end}}
local V={require=function(n)return assert(modules[n],n)end,mod={read=function(_,path)local f=assert(io.open(path,'rb'));local b=f:read('*a');f:close();return b end}}
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
local id='oras_route104_broadleaf';local info=assert(S.info(id));assert(info.parts==5 and info.anchors.canopyBottom[2]>0)
for r=0,3 do
 local parts,fit=assert(S.vertices(id,{width=32,depth=32,rotation=r,padding=.25}))
 assert(fit.anchors.canopyBottom[2]>0 and fit.bounds[5]>27 and fit.bounds[5]<30)
 for i,p in ipairs(parts)do
  assert(p.format==S.COLOR_FORMAT and p.format[4][1]=='VertexColor')
  for j,v in ipairs(p.vertices)do
   assert(#v==10 and v[1]>=.25-1e-6 and v[1]<=31.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=31.75+1e-6)
   assert(v[7]==1 and v[8]==1 and v[9]==1 and v[10]==Tree[id].parts[i].colors[j][4],'tree lighting retained or alpha lost')
  end
 end
end
local old=assert(S.vertices('bw2_sign01',{width=16,depth=16}))
assert(old[1].format==nil and #old[1].vertices[1]==6,'old six-float layout changed')
local first=Tree[id].parts[1];local def={parts={{texture=first.texture,vertices=first.vertices,indices=first.indices,colors={}}}}
assert(not S.register('bad_colors',def,{read=function()end}),'missing source colors accepted')
def.parts[1].colors=first.colors;local max=S.limits.catalogBytes;S.limits.catalogBytes=0
assert(not S.register('byte_budget',def,{read=function()end}),'RGBA source bypassed byte budget');S.limits.catalogBytes=max
local function upload(vs,ix,fmt)local o=object();o.vertices,o.indices,o.format=vs,ix,fmt;return o end
love={filesystem={newFileData=function(bytes)return{release=function()end}end},graphics={newImage=function()local o=object();function o:getDimensions()return 256,256 end;function o:setFilter()end;function o:setWrap()end;return o end}}
local placements={{model=id,x=10,y=3,z=20,fit={width=32,depth=32}},{model=id,x=42,y=5,z=20,fit={width=32,depth=32}}}
local prototype=assert(S.vertices(id,placements[1].fit))
local batches=assert(S.buildBatches(placements,upload));assert(#batches==5)
for _,p in ipairs(batches)do assert(p.instanced and p.model.format==S.COLOR_FORMAT and #p.model.vertices[1]==10)end
S.releaseBatches(batches)
instanced=false;batches=assert(S.buildBatches(placements,upload))
for i,p in ipairs(batches)do
 assert(not p.instanced and p.mesh.format==S.COLOR_FORMAT)
 local source=prototype[i].vertices;assert(#p.mesh.vertices==#source*2)
 for j,v in ipairs(source)do
  local q=p.mesh.vertices[j];assert(q[1]==v[1]+10 and q[2]==v[2]+3 and q[3]==v[3]+20)
  for k=4,10 do assert(q[k]==v[k],'merged fallback dropped UV/shade/RGBA')end
 end
end
S.releaseBatches(batches)
local ready=false
local borrowed={parts={{texture=first.texture,vertices=first.vertices,indices=first.indices}}}
assert(S.register('late_tree',borrowed,{read=function(path)if ready then return V.mod:read(path)end end}))
assert(not S.image('late_tree',first.texture,'repeat','repeat'));ready=true
assert(not S.image('late_tree',first.texture,'repeat','repeat'),'negative cache bypassed without notification')
local held=assert(S.image(id,first.texture,'repeat','repeat'))
assert(S.retryImages('late_tree')and S.image('late_tree',first.texture,'repeat','repeat'),'late reader bytes not retried')
assert(not held.released and S.image(id,first.texture,'repeat','repeat')==held,'retry invalidated another active provider')
S.release()
print('PASS imported ORAS tree lighting cleanup/alpha, unchanged six-float models, bounded fits, canopy anchor, explicit instance/merged formats and byte budgets')
