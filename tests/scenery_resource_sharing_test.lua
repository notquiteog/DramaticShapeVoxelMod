-- Real cache ownership/accounting across provider aliases and active scenes.
local releasedImages,uploadedImages,uploadedMeshes=0,0,0
local hashes,nextHash={},0
local function png(w,h,paint)
 local function u(n)return string.char(math.floor(n/16777216)%256,math.floor(n/65536)%256,math.floor(n/256)%256,n%256)end
 return '\137PNG\13\10\26\10'..u(13)..'IHDR'..u(w)..u(h)..(paint or'')
end
local function object()
 return{setTexture=function(self,image)assert(not image.released);self.image=image end,
 release=function(self)assert(not self.released,'double GPU release');self.released=true end}
end
love={data={hash=function(algorithm,bytes)
 assert(algorithm=='sha256');if not hashes[bytes]then nextHash=nextHash+1;hashes[bytes]=string.format('%032d',nextHash)end;return hashes[bytes]
end},filesystem={newFileData=function(bytes)return{bytes=bytes,release=function()end}end},graphics={newImage=function(file)
 uploadedImages=uploadedImages+1;local bytes=file.bytes
 local function u(n)local a,b,c,d=bytes:byte(n,n+3);return((a*256+b)*256+c)*256+d end
 local image=object();function image:getDimensions()return u(17),u(21)end
 function image:setFilter()end;function image:setWrap(a,b)self.s,self.t=a,b end
 function image:release()assert(not self.released);self.released=true;releasedImages=releasedImages+1 end
 return image
end}}
local Shared=dofile('lib/SharedModelMesh.lua')
local V={require=function(n)
 if n=='SharedModelMesh'then return Shared elseif n=='ModelInstances'then return{new=function()return object()end}
 elseif n=='BuildBudget'then return{check=function()end}elseif n=='SceneryModelData'then return{}end;error(n)
end}
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
local def={parts={{texture='paint.png',vertices={{0,0,0,0,0,1},{1,0,0,1,0,1},{0,1,1,0,1,1}},indices={1,2,3}}}}
local same=png(512,512,'original paint')
local provider={read=function()return same end}
-- Eight aliases exactly fill the former8MiB cache. The ninth must reuse the
-- same original bytes, while catalog/prototype identity remains immutable.
for i=1,20 do
 local id='region_'..i;assert(S.register(id,def,provider));assert(S.image(id,'paint.png','repeat','repeat'))
end
local stats=S.stats();assert(stats.models==20 and stats.catalogModels==1 and stats.catalogVertices==3)
assert(stats.textures==1 and stats.textureBytes==512*512*4 and uploadedImages==1)
assert(S.vertices('region_1',{width=16,depth=16})==S.vertices('region_20',{width=16,depth=16}),'equal source aliases duplicated CPU prototypes')
-- Same path in a different provider can contain different paint. Samplers are
-- mutable Image state and also cannot alias across wrap modes.
assert(S.register('different_paint',def,{read=function()return png(512,512,'other provider')end}))
local other=assert(S.image('different_paint','paint.png','repeat','repeat'))
local wrapped={parts={{texture='paint.png',wrapS='clamp',vertices=def.parts[1].vertices,indices=def.parts[1].indices}}}
assert(S.register('different_wrap',wrapped,provider))
local wrap=assert(S.image('different_wrap','paint.png','clamp','repeat'))
assert(other~=wrap and S.stats().textures==3 and S.stats().catalogModels==2)
assert(not S.image('region_1','unauthorized.png','repeat','repeat'))
-- Input arrays remain copied. Mutating and re-registering the same source
-- table produces another normalized definition rather than stale geometry.
def.parts[1].vertices[2][1]=2
assert(S.register('changed_geometry',def,provider));assert(S.stats().catalogModels==3)
assert(S.info('region_1').bounds[4]==1 and S.info('changed_geometry').bounds[4]==2)
local function upload()uploadedMeshes=uploadedMeshes+1;return object()end
local parts=assert(S.buildBatches({{model='region_1',x=0,y=0,z=0,fit={width=16,depth=16}},
 {model='region_2',x=16,y=0,z=0,fit={width=16,depth=16}}},upload))
assert(#parts==2 and uploadedMeshes==1 and parts[1].image==parts[2].image,'aliases did not share physical image/mesh')
local live=parts[1].image
-- Unregistering one provider, then clearing all idle caches, cannot release
-- an image or prototype still leased by either current/streamed scene part.
assert(S.unregister('region_1'));assert(not live.released and S.info('region_2'))
S.release();assert(not live.released and other.released and wrap.released)
assert(S.stats().textures==1 and S.stats().textureBytes==512*512*4)
S.releaseBatches({parts[1]});assert(not live.released and S.stats().textures==1)
local reloaded=assert(loadfile('lib/SceneryModels.lua'))(V)
reloaded.releaseBatches({parts[2]});assert(live.released and S.stats().textures==0 and S.stats().textureBytes==0)
S.releaseBatches(parts);assert(releasedImages==3,'batch cleanup double-released a shared image')
-- A still registered alias can load again after global idle-cache cleanup.
assert(S.image('region_2','paint.png','repeat','repeat'));assert(uploadedImages==4)
for i=2,20 do assert(S.unregister('region_'..i))end
assert(S.stats().catalogModels==3,'catalog alias unregistration removed another definition')
S.unregister('different_paint');S.unregister('different_wrap');S.unregister('changed_geometry')
assert(S.stats().models==0 and S.stats().catalogModels==0 and S.stats().catalogVertices==0 and S.stats().catalogBytes==0)
assert(S.stats().textures==0 and releasedImages==4)
-- ID-dependent default lighting must normalize before interning one source.
local colored={parts={{texture='paint.png',vertices=def.parts[1].vertices,indices={1,2,3},colors={{.4,.5,.6,1},{.4,.5,.6,1},{.4,.5,.6,1}}}}}
assert(S.register('oras_opening_truck',colored,provider));assert(S.register('paint_provider',colored,provider))
assert(S.stats().catalogModels==2)
assert(S.vertices('oras_opening_truck',{width=16,depth=16})[1].vertices[1][7]==1)
assert(S.vertices('paint_provider',{width=16,depth=16})[1].vertices[1][7]==.4)
S.unregister('oras_opening_truck');S.unregister('paint_provider')
-- Physical unique textures still obey the existing8MiB ceiling; duplicates
-- can reuse a resource at the exact ceiling without allocating past it.
def.parts[1].vertices[2][1]=1
for i=1,8 do
 assert(S.register('unique_'..i,def,{read=function()return png(512,512,'unique'..i)end}))
 assert(S.image('unique_'..i,'paint.png','repeat','repeat'))
end
assert(S.stats().textureBytes==8388608)
assert(S.register('at_cap_duplicate',def,{read=function()return png(512,512,'unique1')end}))
assert(S.image('at_cap_duplicate','paint.png','repeat','repeat'))
assert(S.register('over_cap_unique',def,{read=function()return png(512,512,'unique9')end}))
assert(not S.image('over_cap_unique','paint.png','repeat','repeat'))
assert(S.stats().textureBytes==8388608 and S.stats().textures==8)
S.release();assert(S.stats().textureBytes==0)
assert(S.limits.models==256 and S.limits.textures==256 and S.limits.textureBytes==8388608)
assert(S.limits.catalogVertices==262144 and S.limits.catalogBytes==10485760 and S.limits.cachedBytes==10485760)
-- The model-ID cap remains separate from shared immutable payload accounting.
for i=1,246 do assert(S.register('id_cap_'..i,def,provider))end
assert(S.stats().models==256 and not S.register('one_id_too_many',def,provider))
for i=1,246 do S.unregister('id_cap_'..i)end
for i=1,8 do S.unregister('unique_'..i)end
S.unregister('at_cap_duplicate');S.unregister('over_cap_unique')
-- Eight distinct full-size colored models reach both existing catalog ceilings.
local originals={}
for n=1,8 do
 local vertices,colors={},{}
 for i=1,32768 do vertices[i]={i%2+n*2,i%2,i%3,0,0,1};colors[i]={1,1,1,1}end
 local original={parts={{texture='paint.png',vertices=vertices,indices={1,2,3},colors=colors}}}
 originals[n]=original;assert(S.register('full_catalog_'..n,original,provider))
end
assert(S.stats().catalogVertices==262144 and S.stats().catalogBytes==10485760)
assert(S.register('full_catalog_alias',originals[1],provider),'equal source alias could not reuse a full bounded catalog')
assert(not S.register('full_catalog_unique',def,provider),'unique geometry escaped catalog ceiling')
S.unregister('full_catalog_1');assert(S.stats().catalogVertices==262144,'shared alias freed a live catalog definition')
S.unregister('full_catalog_alias');assert(S.stats().catalogVertices==7*32768)
for i=2,8 do S.unregister('full_catalog_'..i)end
assert(S.stats().catalogVertices==0 and S.stats().catalogBytes==0)
-- The physical sampler/image count cap also remains hard at256.
local countDefs={}
for n=1,8 do
 local parts={}
 for i=1,32 do parts[i]={texture='part'..i..'.png',vertices=def.parts[1].vertices,indices={1,2,3}}end
 countDefs[n]={parts=parts}
 assert(S.register('count_cap_'..n,countDefs[n],{read=function(path)return png(1,1,n..path)end}))
 for i=1,32 do assert(S.image('count_cap_'..n,'part'..i..'.png','repeat','repeat'))end
end
assert(S.stats().textures==256)
assert(S.register('count_cap_alias',countDefs[1],{read=function(path)return png(1,1,'1'..path)end}))
assert(S.image('count_cap_alias','part1.png','repeat','repeat'))
assert(S.register('count_cap_unique',def,{read=function()return png(1,1,'unique beyond count')end}))
assert(not S.image('count_cap_unique','paint.png','repeat','repeat'))
local before=releasedImages;S.release();assert(S.stats().textures==0 and releasedImages==before+256)
print('PASS exact source/sampler dedup, mutated-source isolation, shared mesh/image live leases, provider/global cleanup and unchanged hard ceilings')
