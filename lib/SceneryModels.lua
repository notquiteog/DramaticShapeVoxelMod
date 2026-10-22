-- Static, optional scenery catalog. Adapters own native eligibility, ground,
-- blocked footprints and portals. No automatic placement or gameplay hooks.
local V=...
local Instances=V.require('ModelInstances')
local Budget=V.require('BuildBudget')
local M={limits={models=64,parts=32,vertices=32768,indices=98304,variants=32,cachedVertices=262144,catalogVertices=262144,textures=64,textureBytes=8388608,placements=4096,fallbackVertices=262144,catalogBytes=10485760,cachedBytes=10485760}}
-- Explicit format avoids confusing source RGBA with the existing tree anchors.
M.COLOR_FORMAT={{"VertexPosition","float",3},{"VertexTexCoord","float",2},{"VertexShade","float",1},{"VertexColor","float",4}}
local definitions,images,failed,variants,order={},{},{},{},{}
local owners,imageSizes={},{}
local cachedVertices,imageBytes,imageCount,registeredVertices,cachedBytes,registeredBytes=0,0,0,0,0,0
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function path(p)return type(p)=='string'and #p<=240 and not p:find('\\',1,true)and not p:find('..',1,true)and not p:match('^/')and not p:find(':',1,true)end
local function clone(a)local r={};for i,v in ipairs(a)do r[i]=v end;return r end
local function rotate(x,z,r)if r==1 then return -z,x elseif r==2 then return -x,-z elseif r==3 then return z,-x end;return x,z end
local function clearVariants()variants,order={},{};cachedVertices=0;cachedBytes=0 end
local function validate(def)
 if type(def)~='table'or type(def.parts)~='table'or #def.parts==0 or #def.parts>M.limits.parts then return nil,'invalid scenery parts'end
 local out={parts={},anchors={},surfaces={},bounds={math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge},count=0,bytes=0}
 local ni=0
 for _,p in ipairs(def.parts)do
  if type(p)~='table'or not path(p.texture)or type(p.vertices)~='table'or #p.vertices<3 or type(p.indices)~='table'or #p.indices%3~=0 or #p.indices<3 then return nil,'invalid scenery material/geometry'end
  out.count=out.count+#p.vertices;ni=ni+#p.indices
  if out.count>M.limits.vertices or ni>M.limits.indices then return nil,'scenery geometry budget exceeded'end
  if p.colors~=nil and(type(p.colors)~='table'or #p.colors~=#p.vertices)then return nil,'scenery color count mismatch'end
  out.bytes=out.bytes+#p.vertices*(p.colors and 40 or 24)
  local part={name=p.name,material=p.material,texture=p.texture,role=p.role or'structure',alphaMode=p.alphaMode or'cutout',opacity=p.opacity or 1,wrapS=p.wrapS or'repeat',wrapT=p.wrapT or'repeat',vertices={},indices={}}
  part.diffuse=clone(p.diffuse or{1,1,1});if #part.diffuse~=3 then return nil,'invalid material diffuse'end
  for _,v in ipairs(part.diffuse)do if not finite(v)or v<0 or v>4 then return nil,'invalid material diffuse'end end
  if not finite(part.opacity)or part.opacity<0 or part.opacity>1 then return nil,'invalid material opacity'end
  for _,mode in ipairs{part.wrapS,part.wrapT}do if mode~='repeat'and mode~='clamp'and mode~='mirroredrepeat'and mode~='clampzero'then return nil,'unsupported sampler wrap'end end
  if p.colors then part.colors={} end
  for j,pv in ipairs(p.vertices)do
   if type(pv)~='table'or #pv~=6 then return nil,'scenery vertex must have XYZ UV shade'end
   for _,n in ipairs(pv)do if not finite(n)or math.abs(n)>1e7 then return nil,'nonfinite/unbounded scenery vertex'end end
   part.vertices[j]=clone(pv)
   if p.colors then
    local color=p.colors[j];if type(color)~='table'or #color~=4 then return nil,'scenery colors must be RGBA'end
    for _,n in ipairs(color)do if not finite(n)or n<0 or n>1 then return nil,'invalid scenery vertex color'end end
    part.colors[j]=clone(color)
   end
   for a=1,3 do out.bounds[a]=math.min(out.bounds[a],pv[a]);out.bounds[a+3]=math.max(out.bounds[a+3],pv[a])end
  end
  for j,n in ipairs(p.indices)do if not finite(n)or n%1~=0 or n<1 or n>#p.vertices then return nil,'invalid scenery index'end;part.indices[j]=n end
  out.parts[#out.parts+1]=part
 end
 if math.abs(out.bounds[2])>1e-6 or out.bounds[4]<=out.bounds[1]or out.bounds[6]<=out.bounds[3]then return nil,'scenery must be grounded with positive X/Z extent'end
 for name,p in pairs(def.anchors or{})do
  if type(name)~='string'or type(p)~='table'or #p~=3 then return nil,'invalid scenery anchor'end
  for _,n in ipairs(p)do if not finite(n)or math.abs(n)>1e7 then return nil,'invalid scenery anchor'end end
  out.anchors[name]=clone(p)
 end
 for name,s in pairs(def.surfaces or{})do
  if type(name)~='string'or type(s)~='table'or not finite(s.part)or s.part%1~=0 or not out.parts[s.part]or type(s.triangles)~='table'or #s.triangles==0 or #s.triangles>256 then return nil,'invalid authored scenery surface'end
  local q={part=s.part,triangles={},uvBounds=clone(s.uvBounds or{}),normal=clone(s.normal or{})}
  if #q.uvBounds~=4 or #q.normal~=3 then return nil,'invalid authored surface UV/normal'end
  for _,v in ipairs(q.uvBounds)do if not finite(v)then return nil,'invalid surface UV'end end
  for _,v in ipairs(q.normal)do if not finite(v)then return nil,'invalid surface normal'end end
  if q.uvBounds[3]<=q.uvBounds[1]or q.uvBounds[4]<=q.uvBounds[2]then return nil,'invalid surface UV bounds'end
  for i,n in ipairs(s.triangles)do if not finite(n)or n%1~=0 or n<1 or n*3>#out.parts[q.part].indices then return nil,'invalid authored surface triangle'end;q.triangles[i]=n end
  out.surfaces[name]=q
 end
 return out
end
-- Third-party authors register their own preprocessed definitions and public
-- byte reader. Reader paths are relative to that provider; no private files,
-- engine callbacks or companion requirements are used. Release scene batches
-- before unregistering or resetting resources. Input arrays are copied.
function M.register(id,def,provider)
 if type(id)~='string'or #id>64 or not id:match('^[%w_:.%-]+$')then return nil,'invalid scenery id'end
 if definitions[id]then return nil,'scenery id already registered'end
 local n=0;for _ in pairs(definitions)do n=n+1 end;if n>=M.limits.models then return nil,'scenery catalog budget exceeded'end
 if type(provider)~='table'or type(provider.read)~='function'then return nil,'scenery provider needs a public byte reader'end
 local d,err=validate(def);if not d then return nil,err end
 if registeredBytes+d.bytes>M.limits.catalogBytes then return nil,'scenery catalog byte budget exceeded'end
 if registeredVertices+d.count>M.limits.catalogVertices then return nil,'scenery catalog vertex budget exceeded'end
 d.read=provider.read;definitions[id]=d;registeredVertices=registeredVertices+d.count;registeredBytes=registeredBytes+d.bytes;return true
end
-- Read-only resource accounting for native streaming diagnostics.
function M.stats()
 local models,failures=0,0
 for _ in pairs(definitions)do models=models+1 end
 for _ in pairs(failed)do failures=failures+1 end
 return{models=models,catalogVertices=registeredVertices,catalogBytes=registeredBytes,
  textures=imageCount,textureBytes=imageBytes,failedImages=failures,
  variants=#order,cachedVertices=cachedVertices,cachedBytes=cachedBytes}
end
function M.info(id)
 local d=definitions[id];if not d then return end
 local anchors={};for k,p in pairs(d.anchors)do anchors[k]=clone(p)end
 local surfaces={};for name in pairs(d.surfaces)do surfaces[#surfaces+1]=name end;table.sort(surfaces)
 return{bounds=clone(d.bounds),anchors=anchors,surfaces=surfaces,parts=#d.parts,vertices=d.count,bytes=d.bytes}
end
-- Uniform scale only. Translation keeps every part within the native blocked
-- rectangle [0,width]x[0,depth]. Door alignment is explicit: provide an authored
-- anchor name plus targetX/targetZ, and fail if it would cross the bounds.
function M.fit(id,opts)
 local d=definitions[id];if not d then return nil,'unknown scenery model'end;opts=opts or{}
 local w,z=opts.width,opts.depth;local pad=opts.padding==nil and .25 or opts.padding;local r=opts.rotation or 0
 if not(finite(w)and finite(z)and finite(pad))or w<=0 or z<=0 or w>4096 or z>4096 or pad<0 or w<=2*pad or z<=2*pad then return nil,'invalid blocked scenery rectangle'end
 if not finite(r)or r%1~=0 then return nil,'scenery rotation must be a quarter turn'end;r=r%4
 local a,b,c,e=math.huge,math.huge,-math.huge,-math.huge
 for _,x in ipairs{d.bounds[1],d.bounds[4]}do for _,y in ipairs{d.bounds[3],d.bounds[6]}do local xx,zz=rotate(x,y,r);a,b,c,e=math.min(a,xx),math.min(b,zz),math.max(c,xx),math.max(e,zz)end end
 local scale=math.min((w-2*pad)/(c-a),(z-2*pad)/(e-b))
 if opts.height then if not finite(opts.height)or opts.height<=0 then return nil,'invalid scenery height cap'end;scale=math.min(scale,opts.height/math.max(1e-9,d.bounds[5]))end
 local tx,tz=w/2-(a+c)*scale/2,z/2-(b+e)*scale/2
 if opts.anchor then
  local p=d.anchors[opts.anchor];if not p then return nil,'unavailable authored scenery anchor'end
  if not finite(opts.targetX)or not finite(opts.targetZ)then return nil,'anchor target must be explicit'end
  local x,y=rotate(p[1],p[3],r)
  if opts.targetX<pad or opts.targetX>w-pad or opts.targetZ<pad or opts.targetZ>z-pad then return nil,'anchor target outside blocked footprint'end
  for _,c in ipairs{{x-a,opts.targetX-pad},{c-x,w-pad-opts.targetX},{y-b,opts.targetZ-pad},{e-y,z-pad-opts.targetZ}}do
   if c[1]>1e-9 then scale=math.min(scale,c[2]/c[1])end
  end
  if scale<=0 then return nil,'authored anchor exceeds blocked footprint'end
  tx,tz=opts.targetX-x*scale,opts.targetZ-y*scale
 end
 if a*scale+tx<pad-1e-6 or c*scale+tx>w-pad+1e-6 or b*scale+tz<pad-1e-6 or e*scale+tz>z-pad+1e-6 then return nil,'authored anchor exceeds blocked footprint'end
 local anchors={};for name,p in pairs(d.anchors)do local x,y=rotate(p[1],p[3],r);anchors[name]={x*scale+tx,p[2]*scale,y*scale+tz}end
 return{scale=scale,rotation=r,x=tx,z=tz,width=w,depth=z,anchors=anchors,bounds={a*scale+tx,0,b*scale+tz,c*scale+tx,d.bounds[5]*scale,e*scale+tz}}
end
-- Immutable, shared CPU prototypes; caller never mutates these arrays.
function M.vertices(id,opts)
 local fit,err=M.fit(id,opts);if not fit then return nil,err end
 local k=table.concat({id,fit.rotation,fit.scale,fit.x,fit.z},':');if variants[k]then return variants[k],fit end
 local d=definitions[id];local parts={}
 for i,p in ipairs(d.parts)do
  local q={vertices={},indices=p.indices,texture=p.texture,wrapS=p.wrapS,wrapT=p.wrapT,opacity=p.opacity,role=p.role,alphaMode=p.alphaMode,name=p.name,material=p.material,diffuse=p.diffuse}
  q.format=p.colors and M.COLOR_FORMAT or nil
  for j,v in ipairs(p.vertices)do
   local x,z=rotate(v[1],v[3],fit.rotation);local row={x*fit.scale+fit.x,v[2]*fit.scale,z*fit.scale+fit.z,v[4],v[5],v[6]}
   if p.colors then for _,n in ipairs(p.colors[j])do row[#row+1]=n end end
   q.vertices[j]=row
  end
  parts[i]=q
 end
 while #order>=M.limits.variants or cachedVertices+d.count>M.limits.cachedVertices or cachedBytes+d.bytes>M.limits.cachedBytes do local old=table.remove(order,1);if not old then break end;cachedVertices=cachedVertices-variants[old].count;cachedBytes=cachedBytes-variants[old].bytes;variants[old]=nil end
 parts.count=d.count;parts.bytes=d.bytes;variants[k]=parts;order[#order+1]=k;cachedVertices=cachedVertices+d.count;cachedBytes=cachedBytes+d.bytes;return parts,fit
end
-- Copy the authored face as ordinary sixfloat vertices with local0..1 UVs.
-- A native-art adapter can re-map these UVs to its own atlas and offset by
-- a tiny positive normal distance to avoid fighting the original face.
-- Neither the native art nor eligibility/interaction is changed here.
function M.surface(id,name,opts)
 local d=definitions[id];local s=d and d.surfaces[name];if not s then return nil,'unknown authored scenery surface'end
 local parts,fit=M.vertices(id,opts);if not parts then return nil,fit end
 local p=parts[s.part];local uv=s.uvBounds;local vertices,indices={},{}
 for _,tri in ipairs(s.triangles)do for j=tri*3-2,tri*3 do
  local v=clone(p.vertices[p.indices[j]]);for i=#v,7,-1 do v[i]=nil end;v[4]=(v[4]-uv[1])/(uv[3]-uv[1]);v[5]=(v[5]-uv[2])/(uv[4]-uv[2]);vertices[#vertices+1]=v;indices[#indices+1]=#vertices
 end end
 local nx,nz=rotate(s.normal[1],s.normal[3],fit.rotation)
 return vertices,indices,{nx,s.normal[2],nz}
end

function M.image(id,texture,wrapS,wrapT)
 local d=definitions[id];if not d then return nil,'unknown scenery model'end
 local allowed=false;for _,p in ipairs(d.parts)do if p.texture==texture and p.wrapS==wrapS and p.wrapT==wrapT then allowed=true;break end end
 if not allowed then return nil,'unregistered scenery texture/sampler'end
 local k=table.concat({id,texture,wrapS,wrapT},':');if images[k]then return images[k]end;if failed[k]then return nil,failed[k]end
 owners[k]=id
 local file,img
 local ok,err=pcall(function()
  assert(love and love.graphics and love.filesystem,'graphics unavailable')
  assert(imageCount<M.limits.textures,'scenery texture count budget exceeded')
  local bytes=assert(d.read(texture),'scenery texture unavailable');assert(type(bytes)=='string'and #bytes<=4194304,'scenery texture input budget exceeded')
  assert(bytes:sub(1,8)=='\137PNG\13\10\26\10'and bytes:sub(13,16)=='IHDR','processed scenery requires PNG textures')
  local function u32(n)local a,b,c,e=bytes:byte(n,n+3);assert(e,'truncated PNG header');return ((a*256+b)*256+c)*256+e end
  local pw,ph=u32(17),u32(21);assert(pw>0 and ph>0 and pw<=2048 and ph<=2048 and imageBytes+pw*ph*4<=M.limits.textureBytes,'scenery texture pixel budget exceeded')
  file=love.filesystem.newFileData(bytes,texture);img=love.graphics.newImage(file)
  local w,h=img:getDimensions();assert(w>0 and h>0 and w<=2048 and h<=2048 and imageBytes+w*h*4<=M.limits.textureBytes,'scenery texture pixel budget exceeded')
  img:setFilter('nearest','nearest');img:setWrap(wrapS,wrapT);imageBytes=imageBytes+w*h*4;imageCount=imageCount+1;images[k]=img;imageSizes[k]=w*h*4
 end)
 if file and file.release then file:release()end
 if not ok then if img and img.release then img:release()end;failed[k]=tostring(err);return nil,failed[k]end
 return img
end
-- A scene rebuild/provider notification may retry previously missing bytes.
-- Keep per-frame negative caching and every live scene-owned image intact.
function M.retryImages(id)
 if not definitions[id]then return false end
 for key,owner in pairs(owners)do if owner==id then failed[key]=nil end end
 return true
end
local function releaseParts(parts)
 for _,p in ipairs(parts)do if p.mesh and p.mesh.release then p.mesh:release()end;if p.model and p.model.release then p.model:release()end;p.mesh,p.model=nil,nil end
end
-- Placements {model,x,y,z,fit={width,depth,...}}. options.parts may be the
-- scene-owned destination; every part enters it before any resource/yield, so
-- cancellation can release an abandoned build. On failure only new parts unwind.
-- Caller supplies the ordinary
-- renderer uploader; returned image-bound parts retain source material metadata.
-- Draw with ModelInstances.draw. AlphaMode/opacity remain explicit so adapters
-- can schedule source shading in their correct pass or choose native shadows.
function M.buildBatches(placements,newMesh,options)
 if type(placements)~='table'or #placements>M.limits.placements or type(newMesh)~='function'then return nil,'invalid scenery batch'end
 local groups,keys={},{};local workVertices,workBytes=0,0
 for _,p in ipairs(placements)do
  if type(p)~='table'or not(finite(p.x)and finite(p.y)and finite(p.z))then return nil,'invalid scenery placement'end
  local parts,fit=M.vertices(p.model,p.fit);if not parts then return nil,fit end
  local key=table.concat({p.model,fit.rotation,fit.scale,fit.x,fit.z},':')
  if not groups[key]then
   workBytes=workBytes+parts.bytes;if workBytes>M.limits.cachedBytes then return nil,'scenery batch byte budget exceeded'end
   workVertices=workVertices+parts.count;if workVertices>M.limits.cachedVertices then return nil,'scenery batch prototype budget exceeded'end
   groups[key]={id=p.model,parts=parts,positions={}};keys[#keys+1]=key
  end
  local g=groups[key];g.positions[#g.positions+1]={p.x,p.y,p.z}
 end
 table.sort(keys);options=options or{};local out=options.parts or{}
 if type(out)~='table'then return nil,'scene-owned parts must be a table'end
 local first=#out+1
 local ok,err=pcall(function()
  for _,key in ipairs(keys)do local g=groups[key]
   for partIndex,p in ipairs(g.parts)do
    local part={modelId=g.id,part=partIndex,name=p.name,material=p.material,opacity=p.opacity,alphaMode=p.alphaMode,role=p.role,count=#g.positions,diffuse=p.diffuse};out[#out+1]=part
    local l,n,b,r,t,f=math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge
    for _,v in ipairs(p.vertices)do
     l,n,b=math.min(l,v[1]),math.min(n,v[2]),math.min(b,v[3])
     r,t,f=math.max(r,v[1]),math.max(t,v[2]),math.max(f,v[3])
    end
    local x,y,z=0,0,0
    for _,offset in ipairs(g.positions)do x,y,z=x+offset[1],y+offset[2],z+offset[3]end
    part.center={x/#g.positions+(l+r)/2,y/#g.positions+(n+t)/2,z/#g.positions+(b+f)/2}
    part.image=assert(M.image(g.id,p.texture,p.wrapS,p.wrapT),'scenery image unavailable')
    part.model=assert(newMesh(p.vertices,p.indices,p.format),'scenery prototype upload failed');part.model:setTexture(part.image)
    part.mesh=Instances.new(part.model,g.positions);part.instanced=part.mesh~=nil
    if not part.mesh then
     part.model:release();part.model=nil
     assert(#p.vertices*#g.positions<=M.limits.fallbackVertices,'scenery fallback vertex budget exceeded')
     assert(#p.vertices*#g.positions*(p.format and 40 or 24)<=M.limits.cachedBytes,'scenery fallback byte budget exceeded')
     local verts,indices={},{}
     for _,offset in ipairs(g.positions)do local base=#verts
      for _,v in ipairs(p.vertices)do local q=clone(v);q[1],q[2],q[3]=v[1]+offset[1],v[2]+offset[2],v[3]+offset[3];verts[#verts+1]=q end
      for _,n in ipairs(p.indices)do indices[#indices+1]=base+n end;Budget.check()
     end
     part.mesh=assert(newMesh(verts,indices,p.format),'scenery merged upload failed');part.mesh:setTexture(part.image)
    end
    Budget.check()
   end
  end
 end)
 if not ok then
  for i=#out,first,-1 do releaseParts({out[i]});out[i]=nil end
  return nil,tostring(err)
 end;return out
end
function M.releaseBatches(parts)releaseParts(parts or{})end
function M.release()
 for _,image in pairs(images)do if image.release then image:release()end end
 images,failed,owners,imageSizes={},{},{},{};imageBytes,imageCount=0,0;clearVariants()
end
function M.unregister(id)
 if not definitions[id]then return false end
 -- Only this provider's image ownership is released; other active providers
 -- keep their resources. Its own scene batches must be released first.
 for key,owner in pairs(owners)do if owner==id then
  if images[key]then images[key]:release();imageBytes=imageBytes-imageSizes[key];imageCount=imageCount-1 end
  images[key],imageSizes[key],failed[key],owners[key]=nil,nil,nil,nil
 end end
 clearVariants();registeredVertices=registeredVertices-definitions[id].count;registeredBytes=registeredBytes-definitions[id].bytes;definitions[id]=nil;return true
end
for id,def in pairs(V.require('SceneryModelData'))do
 assert(M.register(id,def,{read=function(path)return V.mod:read(path)end}))
end
-- Prepared source tree catalog is optional; native adapters retain their fallback.
local okTrees,treeData=pcall(V.require,'ImportedTreeData')
if okTrees and type(treeData)=='table'then for id,def in pairs(treeData)do
 assert(M.register(id,def,{read=function(path)return V.mod:read(path)end}))
end end
return M
