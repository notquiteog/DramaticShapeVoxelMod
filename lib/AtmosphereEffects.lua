-- Generic private effect service. Authored GLSL/geometry stays in the extension.
local V=...
local Atmosphere=V.require('AtmosphereState')
local M={}
local PHASE={celestial_before_clouds=true,sky_deck=true,translucent_after_actors=true}
local RESERVED={vp=true,eye=true}
local LIMIT={materials=24,meshes=24,images=8,vertices=131072,bytes=16*1024*1024,uploads=8*1024*1024,draws=128}
local function plain(v)return type(v)=='table' and getmetatable(v)==nil end
local function finite(v,lo,hi)return type(v)=='number' and v==v and v>=lo and v<=hi end
local function copy(v)if type(v)~='table'then return v end;local r={};for k,x in pairs(v)do r[k]=copy(x)end;return r end
local function uniform(v)
 if type(v)=='boolean' or finite(v,-1048576,1048576)then return v end
 if not plain(v)then return nil,'invalid uniform' end
 local out,n={},0
 for k,x in pairs(v)do n=n+1;if n>16 or not finite(k,1,16)or k%1~=0 or not finite(x,-1048576,1048576)then return nil,'invalid uniform vector' end;out[k]=x end
 if n==0 or n~=#out then return nil,'invalid uniform vector length' end
 for i=1,n do if out[i]==nil then return nil,'uniform holes' end end
 return out
end
local function uniformMap(values)
 if not plain(values)then return nil,'uniforms must be plain data' end
 local out,n={},0
 for k,v in pairs(values)do
  n=n+1;if n>48 or type(k)~='string'or #k>64 or not k:match('^[%a_][%w_]*$')or RESERVED[k]then return nil,'invalid or reserved uniform' end
  local x,e=uniform(v);if e then return nil,e end;out[k]=x
 end
 return out
end
local function format(spec)
 if not plain(spec)or #spec<1 or #spec>8 then return nil,'invalid vertex format' end
 local out,seen,stride={}, {},0
 for i,attr in ipairs(spec)do
  if not plain(attr)or #attr~=3 or type(attr[1])~='string' or not attr[1]:match('^[%a_][%w_]*$') or #attr[1]>64 or seen[attr[1]] or attr[2]~='float' or not finite(attr[3],1,4)or attr[3]%1~=0 then return nil,'invalid vertex attribute' end
  seen[attr[1]]=true;stride=stride+attr[3];out[i]={attr[1],attr[2],attr[3]}
 end
 if not seen.VertexPosition or stride>32 then return nil,'position required / excessive stride' end
 return out,stride
end
local function vertices(data,stride)
 if not plain(data)or #data<3 or #data%3~=0 or #data>LIMIT.vertices then return nil,'triangles must contain 3..131072 vertices' end
 local out={}
 for i,row in ipairs(data)do
  if not plain(row)or #row~=stride then return nil,'vertex stride mismatch' end
  out[i]={};for j=1,stride do if not finite(row[j],-1048576,1048576)then return nil,'invalid vertex' end;out[i][j]=row[j]end
  for k in pairs(row)do if not finite(k,1,stride)or k%1~=0 then return nil,'extra vertex attribute' end end
 end
 for k in pairs(data)do if not finite(k,1,#data)or k%1~=0 then return nil,'invalid vertex index' end end
 return out
end
-- Keep the protected draw callable stable: packets already own validated data.
local function drawPacket(g,mat,mesh,img,q,vp,eye)
 g.setShader(mat.gpu);mat.gpu:send('vp','row',vp)
 if mat.hasEye then mat.gpu:send('eye',eye)end
 for k,v in pairs(mat.defaults)do local value=q.uniforms[k];if value==nil then value=v end;mat.gpu:send(k,value)end
 mesh.gpu:setTexture(img and img.gpu or nil)
 g.setDepthMode('lequal',false);g.setMeshCullMode('none');g.setBlendMode(q.blend,'alphamultiply');g.setColor(q.tint[1],q.tint[2],q.tint[3],q.tint[4]);g.draw(mesh.gpu)
end
local function clearQueue(r)for i=#r.queue,1,-1 do r.queue[i]=nil end end
function M.new()
 local service={};local records={};local sortedOwners
 local totalBytes,totalVerts,totalMaterials=0,0,0;local frame,eligible=0,false;local atmosphere=Atmosphere.new();local centerCamera={available=false,reason="no_completed_center_camera"}
 local function drop(r)
  if not r.live then return end;r.live=false
  if r.lease then r.lease.dispose()end
  for _,res in pairs(r.resources)do if res.gpu and res.gpu.release then pcall(res.gpu.release,res.gpu)end end
  totalBytes=totalBytes-r.bytes;totalVerts=totalVerts-r.verts;totalMaterials=totalMaterials-r.counts.material
  r.resources={};r.queue={};records[r.owner]=nil;sortedOwners=nil
 end
 function service.owner(owner)
  if records[owner]then return records[owner].api end
  local r={owner=owner,live=true,resources={},queue={},bytes=0,uploads=0,verts=0,counts={material=0,mesh=0,image=0}}
  records[owner]=r;sortedOwners=nil;local api={};r.api=api
  local function valid()return r.live and records[owner]==r end
  local function resource(key,kind)local v=r.resources[key];return v and v.kind==kind and v or nil end
  local function add(kind,gpu,extra)
   local key={};extra=extra or {};extra.kind,extra.gpu=kind,gpu;r.resources[key]=extra;r.counts[kind]=r.counts[kind]+1;return key
  end
  function api:camera()if not valid()then return nil,"revoked owner" end;return copy(centerCamera)end
  function api:material(spec)
   if not valid()then return nil,'revoked owner' end
   if not plain(spec)or type(spec.source)~='string'or #spec.source>65536 or #spec.source==0 or (r.counts.material>=LIMIT.materials or totalMaterials>=32) then return nil,'invalid material or budget' end
   local defaults,e=uniformMap(spec.uniforms or {});if not defaults then return nil,e end
   local source=spec.source
   if spec.skyDepth==true then
    source='#define position extension_position\n'..source..'\n#undef position\n#ifdef VERTEX\nvec4 position(mat4 m, vec4 v){vec4 c=extension_position(m,v);if(c.w>0.0)c.z=min(c.z,c.w*0.99999);return c;}\n#endif\n'
   end
   local ok,sh=pcall(love.graphics.newShader,source);if not ok then return nil,tostring(sh)end
   for name,value in pairs(defaults)do
    if not sh:hasUniform(name)then sh:release();return nil,'unused or missing uniform: '..name end
    local sent,err=pcall(sh.send,sh,name,value);if not sent then sh:release();return nil,tostring(err)end
   end
   if not sh:hasUniform('vp')then sh:release();return nil,'material must consume host vp' end
   totalMaterials=totalMaterials+1
   return add('material',sh,{defaults=defaults,hasEye=sh:hasUniform('eye'),skyDepth=spec.skyDepth==true})
  end
  function api:mesh(spec)
   if not valid()then return nil,'revoked owner'end
   if not plain(spec)or r.counts.mesh>=LIMIT.meshes then return nil,'mesh budget'end
   local fmt,stride=format(spec.format);if not fmt then return nil,stride end
   local data,e=vertices(spec.vertices,stride);if not data then return nil,e end
   local bytes=#data*stride*4
   if r.bytes+bytes>LIMIT.bytes or r.uploads+bytes>LIMIT.uploads or r.verts+#data>LIMIT.vertices or totalBytes+bytes>32*1024*1024 or totalVerts+#data>262144 then return nil,'vertex budget'end
   local ok,gpu=pcall(love.graphics.newMesh,fmt,data,'triangles','stream');if not ok then return nil,tostring(gpu)end
   totalBytes,totalVerts=totalBytes+bytes,totalVerts+#data
   r.bytes,r.uploads,r.verts=r.bytes+bytes,r.uploads+bytes,r.verts+#data
   return add('mesh',gpu,{format=fmt,stride=stride,count=#data,bytes=bytes})
  end
  function api:updateMesh(key,data)
   if not valid()then return nil,'revoked owner'end
   local res=resource(key,'mesh');if not res then return nil,'foreign or missing mesh'end
   local v,e=vertices(data,res.stride);if not v then return nil,e end
   if #v~=res.count then return nil,'update must preserve vertex count'end
   if r.uploads+res.bytes>LIMIT.uploads then return nil,'upload budget'end
   local ok,err=pcall(res.gpu.setVertices,res.gpu,v);if not ok then return nil,tostring(err)end
   r.uploads=r.uploads+res.bytes;return true
  end
  function api:image(spec)
   if not valid()then return nil,'revoked owner'end
   if plain(spec) and spec.wrap~=nil and spec.wrap~='clamp' and spec.wrap~='repeat' then return nil,'invalid image wrap' end
   if not plain(spec)or not finite(spec.width,1,2048)or not finite(spec.height,1,2048)or spec.width%1~=0 or spec.height%1~=0 or type(spec.rgba)~='string'or #spec.rgba~=spec.width*spec.height*4 then return nil,'invalid rgba image'end
   local bytes=#spec.rgba;if r.counts.image>=LIMIT.images or r.bytes+bytes>LIMIT.bytes or r.uploads+bytes>LIMIT.uploads or totalBytes+bytes>32*1024*1024 then return nil,'image budget'end
   local ok,data=pcall(love.image.newImageData,spec.width,spec.height,'rgba8',spec.rgba);if not ok then return nil,tostring(data)end
   local made,gpu=pcall(love.graphics.newImage,data);data:release();if not made then return nil,tostring(gpu)end
   gpu:setFilter('nearest','nearest');gpu:setWrap(spec.wrap or 'repeat',spec.wrap or 'repeat')
   totalBytes=totalBytes+bytes
   r.bytes,r.uploads=r.bytes+bytes,r.uploads+bytes;return add('image',gpu,{bytes=bytes})
  end
  function api:release(key)
   if not valid()then return nil,'revoked owner'end
   local res=r.resources[key];if not res then return nil,'foreign resource'end
   totalBytes=totalBytes-(res.bytes or 0);totalVerts=totalVerts-(res.count or 0);if res.kind=='material'then totalMaterials=totalMaterials-1 end
   res.gpu:release();r.resources[key]=nil;r.counts[res.kind]=r.counts[res.kind]-1;r.bytes=r.bytes-(res.bytes or 0);r.verts=r.verts-(res.count or 0);return true
  end
  function api:enqueue(packet)
   if not valid()then return nil,'revoked owner'end
   if not eligible then return nil,'ineligible world frame'end
   if not plain(packet)or not PHASE[packet.phase] or #r.queue>=LIMIT.draws then return nil,'phase or draw budget'end
   if packet.blend~=nil and packet.blend~='alpha' and packet.blend~='add' then return nil,'invalid blend mode' end
   local tint={1,1,1,1}
   if packet.tint~=nil then
    if not plain(packet.tint)then return nil,'invalid tint' end
    local count=0
    for k,v in pairs(packet.tint)do
     count=count+1
     if count>4 or not finite(k,1,4)or k%1~=0 or not finite(v,0,1)then return nil,'invalid tint component' end
     tint[k]=v
    end
    if count~=4 then return nil,'tint requires four components' end
   end
   local mat,mesh=resource(packet.material,'material'),resource(packet.mesh,'mesh')
   if not mat or mat.kind~='material' or not mesh or mesh.kind~='mesh' then return nil,'foreign or missing material/mesh'end
   if mat.skyDepth and packet.phase=='translucent_after_actors' then return nil,'sky-depth material requires sky phase'end
   local image=packet.image and resource(packet.image,'image');if packet.image and not image then return nil,'foreign image'end
   local uniforms,e=uniformMap(packet.uniforms or {});if not uniforms then return nil,e end
   for k in pairs(uniforms)do if mat.defaults[k]==nil then return nil,'undeclared uniform: '..k end end
   r.queue[#r.queue+1]={phase=packet.phase,material=packet.material,mesh=packet.mesh,image=packet.image,uniforms=uniforms,blend=packet.blend or 'alpha',tint=tint};return true
  end
  function api:submitAtmosphere(packet)
   if not valid()then return nil,'revoked owner'end
   r.wantsCelestials=false
   if type(packet)=='table' and type(packet.sky)=='table' and (packet.sky.dither~=nil or packet.sky.smooth~=nil) then if r.lease then r.lease.clear()end;return nil,'draft does not yet support celestial replacement/style overrides' end
   if type(packet)=='table' and (packet.cloud~=nil or packet.front~=nil or packet.lightning~=nil)then if r.lease then r.lease.clear()end;return nil,'submit cloud/front/lightning through owned material uniforms' end
   if not r.lease then local lease,err=atmosphere.acquire(owner);if not lease then return nil,err end;r.lease=lease end
   local ok,err=r.lease.submit(packet,frame);r.wantsCelestials=ok and packet.sky and packet.sky.replaceCelestials==true or false;return ok,err
  end
  function api:clear()r.wantsCelestials=false;if not valid()then return nil,'revoked owner'end;clearQueue(r);if r.lease then r.lease.clear()end;return true end
  return api
 end
 function service.beginFrame(id,allowed,camera)
  frame,eligible=id,allowed==true;atmosphere.beginFrame(id,eligible)
  centerCamera=eligible and copy(camera or {available=false,reason="no_completed_center_camera",currentFrame=id}) or {available=false,reason="ineligible_world_frame",currentFrame=id}
  for _,r in pairs(records)do clearQueue(r);r.uploads=0;r.wantsCelestials=false;r.celestialDrawn=false end
 end
 function service.revoke(owner)local r=records[owner];if r then drop(r)end end
 function service.reset()centerCamera={available=false,reason="host_reset"};local list={};for _,r in pairs(records)do list[#list+1]=r end;for _,r in ipairs(list)do drop(r)end;atmosphere.reset()end
 function service.wantsCelestials()
  if not eligible then return false end
  for _,r in pairs(records)do if r.wantsCelestials then
   for _,q in ipairs(r.queue)do if q.phase=='celestial_before_clouds' and r.resources[q.material] and r.resources[q.mesh] and(not q.image or r.resources[q.image])then return true end end
  end end
  return false
 end
 function service.celestialsDrawn()
  for _,r in pairs(records)do if r.wantsCelestials and r.celestialDrawn then return true end end
  return false
 end
 function service.snapshot()return atmosphere.snapshot()end
 function service.clearState(owner)local r=records[owner];if r and r.lease then r.lease.clear()end end
 function service.draw(phase,vp,eye,allowed)
  if not eligible or not allowed or not PHASE[phase]then return true end
  local g=love.graphics;local problems
  if phase=='celestial_before_clouds'then for _,r in pairs(records)do r.celestialDrawn=false end end
  if not sortedOwners then
   sortedOwners={};for owner in pairs(records)do sortedOwners[#sortedOwners+1]=owner end;table.sort(sortedOwners)
  end
  local owners=sortedOwners
  for _,owner in ipairs(owners)do local r=records[owner];local drew=false;local startErrors=problems and #problems or 0
   for _,q in ipairs(r.queue)do if q.phase==phase then
    local mat,mesh,img=r.resources[q.material],r.resources[q.mesh],q.image and r.resources[q.image]
    if not mat or not mesh or(q.image and not img)then problems=problems or {};problems[#problems+1]='released queued resource';break end
    g.push('all')
    local ok,err=pcall(drawPacket,g,mat,mesh,img,q,vp,eye)
    g.pop()
    if not ok then problems=problems or {};problems[#problems+1]=tostring(err);break end;drew=true
   end end
   if (problems and #problems or 0)>startErrors then drop(r)elseif phase=='celestial_before_clouds'then r.celestialDrawn=drew;atmosphere.celestialStatus(owner,drew)end
  end
  if problems then return nil,table.concat(problems,'\n')end;return true
 end
 return service
end
return M
