local Data=assert(loadfile('lib/SceneryModelData.lua'))()
local instances=true;local onBudget;local released=0;local allocations=0;local failAt
local function object()return{setTexture=function(self,i)self.image=i end,release=function(self)self.released=true;released=released+1 end}end
local I={new=function(mesh,positions)if not instances then return nil end;local b=object();b.instanceMesh=mesh;b.positions=positions;return b end}
local V={require=function(n)if n=='SharedModelMesh'then return dofile('lib/SharedModelMesh.lua')elseif n=='ModelInstances'then return I elseif n=='BuildBudget'then return{check=function()if onBudget then onBudget()end end}elseif n=='SceneryModelData'then return Data end;error(n)end,mod={read=function(_,path)local f=assert(io.open(path,'rb'));local b=f:read('*a');f:close();return b end}}
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
for id,d in pairs(Data)do
 local info=assert(S.info(id));assert(info.parts==#d.parts and info.vertices>0)
 for rotation=0,3 do
  local parts,fit=assert(S.vertices(id,{width=48,depth=32,rotation=rotation,height=40}))
  local count=0
  for j,p in ipairs(parts)do
   assert(p.texture==d.parts[j].texture and #p.indices==#d.parts[j].indices)
   for k,v in ipairs(p.vertices)do
    assert(v[1]>=.25-1e-6 and v[1]<=47.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=31.75+1e-6 and v[2]>=-1e-6 and v[2]<=40+1e-6)
    local src=d.parts[j].vertices[k];assert(v[4]==src[4]and v[5]==src[5]and v[6]==1,'source UV changed or baked shade retained');count=count+1
   end
  end
  assert(count==info.vertices and fit.bounds[5]<=40)
  local again=S.vertices(id,{width=48,depth=32,rotation=rotation,height=40});assert(parts==again,'prototype not cached')
 end
end
for rotation=0,3 do
 local face,indices,n=S.surface('bw2_sign01','message',{width=16,depth=16,rotation=rotation});assert(#face==6 and #indices==6 and math.abs(n[1])+math.abs(n[3])==1)
 for _,v in ipairs(face)do assert(v[4]>=0 and v[4]<=1 and v[5]>=0 and v[5]<=1)end
end
assert(not S.vertices('missing',{width=16,depth=16}));assert(not S.fit('bw2_sign01',{width=16,depth=16,rotation=.1}))
local def={parts={{texture='model.png',vertices={{-.5,0,-.25,0,0,1},{.5,0,-.25,1,0,1},{0,1,.25,.5,1,1}},indices={1,2,3}}},anchors={door={0,0,.25}}}
local function png(w,h)return '\137PNG\13\10\26\10'..string.char(0,0,0,13)..'IHDR'..string.char(0,0,math.floor(w/256),w%256,0,0,math.floor(h/256),h%256)end
assert(S.register('third_party:house',def,{read=function()return png(8,8)end}));def.parts[1].vertices[1][1]=-999
local parts,fit=S.vertices('third_party:house',{width=16,depth=16,padding=0,anchor='door',targetX=8,targetZ=12})
assert(parts and fit.anchors.door[1]==8 and fit.anchors.door[3]==12,'authored portal anchor not aligned')
local recessed,recessFit=S.vertices('third_party:house',{width=16,depth=16,padding=0,anchor='door',targetX=8,targetZ=12,groundInset=.05})
assert(recessed~=parts and recessFit.bounds[2]==-.05 and recessFit.anchors.door[2]==fit.anchors.door[2])
for i,v in ipairs(recessed[1].vertices)do
 local original=parts[1].vertices[i]
 assert(v[1]==original[1]and v[3]==original[3]and v[4]==original[4]and v[5]==original[5])
 assert(v[2]==(original[2]==0 and -.05 or original[2]),'only contact ring may move')
end
assert(S.vertices('third_party:house',{width=16,depth=16,padding=0,anchor='door',targetX=8,targetZ=12})==parts,'ground inset poisoned default prototype')
assert(not S.fit('third_party:house',{width=16,depth=16,groundInset=-1}))
assert(not S.fit('third_party:house',{width=16,depth=16,groundInset=.26}))
local lab=assert(S.fit('hgss_oaks_lab',{width=48,depth=32,anchor='door',targetX=24,targetZ=25}));assert(lab.anchors.door[1]==24 and lab.anchors.door[3]==25,'asymmetric source shadow defeated center doorway alignment')
assert(not S.fit('third_party:house',{width=16,depth=16,anchor='door',targetX=0,targetZ=16}),'out-of-footprint door accepted')
assert(not S.register('third_party:house',def,{read=function()end}));assert(not S.register('bad',{parts={}},{read=function()end}))
love={filesystem={newFileData=function(bytes)return{bytes=bytes,release=function()end}end},graphics={newImage=function(file)allocations=allocations+1;if failAt and allocations==failAt then error('image failure')end;local o=object();function o:getDimensions()return 8,8 end;function o:setFilter()end;function o:setWrap()end;return o end}}
local function upload(vertices,indices)local o=object();o.vertices=vertices;o.indices=indices;return o end
local placements={{model='third_party:house',x=0,y=2,z=0,fit={width=16,depth=16}},{model='third_party:house',x=16,y=4,z=0,fit={width=16,depth=16}}}
local originalVertices=S.vertices;local fits=0
S.vertices=function(...)fits=fits+1;return originalVertices(...)end
local repeated={}
for i=1,1000 do repeated[i]={model='third_party:house',x=i*16,y=0,z=0,fit={width=16,depth=16}}end
local many=assert(S.buildBatches(repeated,upload));assert(fits==1,'identical tree placements refitted per instance');S.releaseBatches(many)
fits=0;repeated[500].fit.rotation=1
many=assert(S.buildBatches(repeated,upload));assert(fits==3,'changed fit reused stale geometry');S.releaseBatches(many)
S.vertices=originalVertices
local batches=assert(S.buildBatches(placements,upload));assert(#batches==1 and batches[1].instanced and batches[1].count==2 and allocations==1);S.releaseBatches(batches)
instances=false;batches=assert(S.buildBatches(placements,upload));assert(not batches[1].instanced and #batches[1].mesh.vertices==6 and #batches[1].mesh.indices==6);assert(batches[1].mesh.vertices[1][2]==2 and batches[1].mesh.vertices[4][1]==16.25);S.releaseBatches(batches)
-- Adjacent equal fits may have different contact-ring policies. The touring
-- fast path must not share either prototype or draw group across that boundary.
instances=true
local mixed=assert(S.buildBatches({
 {model='third_party:house',x=0,y=0,z=0,fit={width=16,depth=16}},
 {model='third_party:house',x=16,y=0,z=0,fit={width=16,depth=16,groundInset=.05}},
},upload))
assert(#mixed==2,'contact inset lost in repeated-fit batch cache')
local lows={};for _,part in ipairs(mixed)do lows[part.model.vertices[1][2]]=true end
assert(lows[0]and lows[-.05],'separate contact policies shared one prototype')
S.releaseBatches(mixed);instances=false
local count=0;local partial,err=S.buildBatches(placements,function(...)count=count+1;if count==2 then error('upload failure')end;return upload(...)end);assert(not partial and err:find('upload failure',1,true),'partial upload failed to fall back')
S.release();local before=allocations;failAt=before+1;assert(not S.image('third_party:house','model.png','repeat','repeat'));assert(not S.image('third_party:house','model.png','repeat','repeat')and allocations==before+1,'failed image retried each frame')
assert(not S.image('third_party:house','../other.png','repeat','repeat'));failAt=nil
-- Native Scene cancellation abandons a suspended build coroutine. Its GPU
-- parts must already be visible in the scene-owned destination before yield.
S.release();local owned={};instances=true;onBudget=function()coroutine.yield('budget')end
local co=coroutine.create(function()assert(S.buildBatches(placements,upload,{parts=owned}))end)
local ok,reason=coroutine.resume(co);assert(ok and reason=='budget'and #owned==1 and owned[1].model and owned[1].mesh)
local model,batch=owned[1].model,owned[1].mesh;local before=released;S.releaseBatches(owned);assert(released==before+2 and owned[1].model==nil and owned[1].mesh==nil,'cancelled scene build leaked GPU resources');co=nil;onBudget=nil
-- A failed append leaves older scene-owned parts alone.
local prior=object();local target={{mesh=prior}};local n=0
assert(not S.buildBatches(placements,function(...)n=n+1;error('upload failed')end,{parts=target}))
assert(#target==1 and target[1].mesh==prior,'failed append destroyed earlier scene resources')
local other={parts={{texture='other.png',vertices={{-.5,0,-.25,0,0,1},{.5,0,-.25,1,0,1},{0,1,.25,.5,1,1}},indices={1,2,3}}}}
assert(S.register('other_provider:model',other,{read=function()return png(8,8)end}))
local retained=assert(S.image('other_provider:model','other.png','repeat','repeat'))
assert(S.unregister('third_party:house')and not S.info('third_party:house'));assert(not retained.released and S.image('other_provider:model','other.png','repeat','repeat')==retained,'unregister invalidated another provider');S.unregister('other_provider:model')
print('PASS source multipart/UV preservation, uniform bounded fits/door alignment, copied third-party registration, cached resources, instancing/merged fallback, cleanup and negative cache')
