-- Portable XD mesh/pose consumer. Import/conversion happens outside the game.
-- No filesystem, process, FFI, desktop-only shader or other-mod dependency.
local V=...
local M={}
local FORMAT={{'VertexPosition','float',3},{'VertexTexCoord','float',2},
 {'VertexShade','float',1},{'VertexColor','float',4}}
local Instance={};Instance.__index=Instance
local function transform(m,x,y,z)
 return m[1]*x+m[2]*y+m[3]*z+m[4],
  m[5]*x+m[6]*y+m[7]*z+m[8],m[9]*x+m[10]*y+m[11]*z+m[12]
end
local ID={1,0,0,0,0,1,0,0,0,0,1,0}
local function normal(m,n)
 -- Inverse-transpose handles the source's animated nonuniform scales.
 local a,b,c,d,e,f,g,h,i=m[1],m[2],m[3],m[5],m[6],m[7],m[9],m[10],m[11]
 local det=a*(e*i-f*h)-b*(d*i-f*g)+c*(d*h-e*g)
 if math.abs(det)<1e-12 then return n[1],n[2],n[3]end
 return ((e*i-f*h)*n[1]+(f*g-d*i)*n[2]+(d*h-e*g)*n[3])/det,
  ((c*h-b*i)*n[1]+(a*i-c*g)*n[2]+(b*g-a*h)*n[3])/det,
  ((b*f-c*e)*n[1]+(c*d-a*f)*n[2]+(a*e-b*d)*n[3])/det
end
local function uvAt(tc,layer)
 if not layer then return tc[1],1-tc[2]end
 local s,r,t=layer.scale or{1,1,1},layer.rotation or{0,0,0},layer.translation or{0,0,0}
 local x,y=tc[1]*s[1],tc[2]*s[2]
 return math.cos(r[3])*x-math.sin(r[3])*y+t[1],
  1-(math.sin(r[3])*x+math.cos(r[3])*y+t[2])
end
local function chooseClip(clips,context)
 local words={idle='idle',attack='physical',attack_default='physical',
  special='special',damage='damage',faint='faint'}
 local word=words[context]or context
 for i,c in ipairs(clips)do
  if c.name:lower():find(word,1,true)then return i end
 end
end
function M.new(data,assets)
 assert(type(data)=='table'and data.version==1 and data.model,'Invalid XD model data')
 local self=setmetatable({data=data,assets=assets,meshes={},time=0,clip=nil,frame=-1,
  finished=false,loop=true,released=false},Instance)
 local model=data.model
 local names={}
 for i,b in ipairs(model.bones)do names[b.name]=i end
 local bounds={math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge}
 local ok,err=pcall(function()
  for sourceIndex,src in ipairs(model.meshes)do
   if not src.is_hidden then
    local weights={}
    local bw=src.bone_weights
    if bw and bw.type=='WEIGHTED'then
     for _,a in ipairs(bw.assignments or{})do
      local row={}
      for _,pair in ipairs(a[2])do
       assert(names[pair[1]],'Unknown XD skin bone')
       row[#row+1]={names[pair[1]],pair[2]}
      end
      weights[a[1]+1]=row
     end
    else
     local bone=bw and names[bw.bone_name]or(src.parent_bone_index or 0)+1
     for i=1,#src.vertices do weights[i]={{bone,1}}end
    end
    local vertices,map,normals,uvs,vertexColors={},{},{},{},{}
    local material=src.material or{}
    local layer=material.texture_layers and material.texture_layers[1]
    local uv=src.uv_layers and src.uv_layers[(layer and layer.uv_index or 0)+1]
    local colors=src.color_layers and src.color_layers[1]
    local diffuse=material.diffuse_color or{1,1,1,1}
    local corner=0
    for _,face in ipairs(src.faces)do
     for t=2,#face-1 do
      for _,j in ipairs({1,t,t+1})do
       local vi=face[j]+1;local p=src.vertices[vi]
       local tc=uv and uv.uvs[corner+j]or{0,0}
       local vc=colors and colors.colors[corner+j]or{1,1,1,1}
       local u,v=uvAt(tc,layer)
       vertices[#vertices+1]={p[1],p[2],p[3],u,v,1,
        vc[1]*diffuse[1],vc[2]*diffuse[2],vc[3]*diffuse[3],
        (vc[4]or 1)*(material.alpha or 1)}
       map[#map+1]=vi
       uvs[#map]=tc;vertexColors[#map]=vc
       local n=src.normals and src.normals[corner+j]
       if n and bw and bw.type~='WEIGHTED'then
        local bone=model.bones[(src.parent_bone_index or 0)+1]
        local bm=bone.world_matrix
        n={normal({bm[1][1],bm[1][2],bm[1][3],bm[1][4],
          bm[2][1],bm[2][2],bm[2][3],bm[2][4],
          bm[3][1],bm[3][2],bm[3][3],bm[3][4]},n)}
       end
       normals[#map]=n or false
       for axis=1,3 do
        bounds[axis]=math.min(bounds[axis],p[axis])
        bounds[axis+3]=math.max(bounds[axis+3],p[axis])
       end
      end
     end
     corner=corner+#face
    end
    if #vertices>0 then
     local key=src.id or ('mesh_%0'..#tostring(math.max(0,#model.meshes-1))..'d_%s')
      :format(sourceIndex-1,model.bones[(src.parent_bone_index or 0)+1].name)
     local entry={source=src,vertices=vertices,map=map,weights=weights,normals=normals,
      key=key,uvs=uvs,vertexColors=vertexColors,layer=layer}
     self.meshes[#self.meshes+1]=entry
     entry.mesh=love.graphics.newMesh(FORMAT,vertices,'triangles','dynamic')
     entry.texture=layer and assets.image(layer.image.path)or assets.white()
     assert(entry.texture,'Missing XD texture')
     if layer then
      local wraps={CLAMP='clamp',REPEAT='repeat',MIRROR='mirroredrepeat'}
      entry.wrapS,entry.wrapT=wraps[layer.wrap_s]or'clamp',wraps[layer.wrap_t]or'clamp'
     end
    end
   end
  end
 end)
 if not ok then self:release();return nil,err end
 if #self.meshes==0 or bounds[5]<=bounds[2]then
  self:release();return nil,'Empty XD geometry'
 end
 self.bounds=bounds
 local ready,reason=pcall(self.playContext,self,'idle',true)
 if not ready or not reason then
  self:release();return nil,'XD idle animation unavailable'
 end
 return self
end
function Instance:metrics()
 local b=self.bounds
 return {height=b[5]-b[2],floor=b[2],width=b[4]-b[1],depth=b[6]-b[3],units='meters'}
end
function Instance:playContext(name,loop)
 local index=chooseClip(self.data.clips,name)
 if not index then return false end
 if self.clip==index and self.context==name and self.loop==loop then return true end
 local clip=self.data.clips[index]
 local bytes=self.assets.read(clip.path)
 if not bytes then return false end
 local ok,raw=pcall(love.data.decompress,'string','zlib',bytes)
 if not ok or #raw~=clip.frames*clip.bones*48 then return false end
 self.clip,self.poseBytes,self.context,self.loop=index,raw,name,loop==true
 self.time,self.frame,self.finished=0,-1,false
 return self:update(0)
end
function Instance:playMove(move,loop)
 return self:playContext('attack',loop)
end
function Instance:isFinished()return self.finished end
function Instance:update(dt)
 if self.released then return false end
 local clip=self.clip and self.data.clips[self.clip]
 if not clip then return true end
 self.time=self.time+math.max(0,tonumber(dt)or 0)
 local frame=math.floor(self.time*clip.fps)
 if self.loop then frame=frame%clip.frames
 else self.finished=frame>=clip.frames-1;frame=math.min(frame,clip.frames-1)end
 if frame==self.frame then return true end
 local matrices={}
 for bone=1,clip.bones do
  local offset=(frame*clip.bones+bone-1)*48+1
  matrices[bone]={love.data.unpack('<ffffffffffff',self.poseBytes,offset)}
 end
 for _,entry in ipairs(self.meshes)do
  local animated=clip.materials and clip.materials[frame+1]
  animated=animated and animated[entry.key]
  local posed={}
  for i,p in ipairs(entry.source.vertices)do
   local x,y,z=0,0,0
   local weights=entry.weights[i]or{}
   if #weights==0 then weights={{0,1}}end
   for _,w in ipairs(weights)do
    local a,b,c=transform(matrices[w[1]]or ID,p[1],p[2],p[3])
    x,y,z=x+a*w[2],y+b*w[2],z+c*w[2]
   end
   posed[i]={x,y,z}
  end
  for i,vi in ipairs(entry.map)do
   local p,v=posed[vi],entry.vertices[i];v[1],v[2],v[3]=p[1],p[2],p[3]
   local base=entry.source.material or{}
   local color=animated and animated.diffuse or base.diffuse_color or{1,1,1}
   local alpha=animated and animated.alpha or base.alpha or 1
   local vc=entry.vertexColors[i]
   v[7],v[8],v[9],v[10]=vc[1]*color[1],vc[2]*color[2],vc[3]*color[3],(vc[4]or 1)*alpha
   local layer=animated and animated.layers and animated.layers['0']or entry.layer
   v[4],v[5]=uvAt(entry.uvs[i],layer)
   local n=entry.normals[i]
   if n then
    local nx,ny,nz=0,0,0
    for _,w in ipairs(entry.weights[vi]or{{0,1}})do
     local a,b,c=normal(matrices[w[1]]or ID,n)
     nx,ny,nz=nx+a*w[2],ny+b*w[2],nz+c*w[2]
    end
    local len=math.sqrt(nx*nx+ny*ny+nz*nz)
    v[6]=len>1e-10 and .65+.35*math.max(0,(nx*.3+ny*.8+nz*.5)/len)or .8
   end
  end
  -- Recompute geometric face lighting after skinning; never bake a fixed
  -- rest-pose shade onto a limb that turns during an attack.
  for i=1,#entry.vertices,3 do
   local a,b,c=entry.vertices[i],entry.vertices[i+1],entry.vertices[i+2]
   local ux,uy,uz=b[1]-a[1],b[2]-a[2],b[3]-a[3]
   local vx,vy,vz=c[1]-a[1],c[2]-a[2],c[3]-a[3]
   local nx,ny,nz=uy*vz-uz*vy,uz*vx-ux*vz,ux*vy-uy*vx
   local len=math.sqrt(nx*nx+ny*ny+nz*nz)
   local shade=len>1e-10 and .65+.35*math.max(0,(nx*.3+ny*.8+nz*.5)/len)or .8
   if not entry.normals[i]then a[6]=shade end
   if not entry.normals[i+1]then b[6]=shade end
   if not entry.normals[i+2]then c[6]=shade end
  end
  entry.mesh:setVertices(entry.vertices)
 end
 self.frame=frame
 return true
end
function Instance:drawWith(draw,matrix)
 if self.released then return false end
 for _,entry in ipairs(self.meshes)do
  local s,t=entry.texture:getWrap()
  if entry.wrapS then entry.texture:setWrap(entry.wrapS,entry.wrapT)end
  local ok,err=pcall(draw,entry.mesh,entry.texture,matrix)
  entry.texture:setWrap(s,t)
  if not ok then error(err,0)end
 end
 return true
end
function Instance:draw(options)
 if options.pass=='additive'then return true end
 return self:drawWith(V.require('Voxel3D').draw,options.modelMatrix)
end
function Instance:drawShadow(options)
 return self:drawWith(V.require('ShadowMap').draw,options.modelMatrix)
end
function Instance:release()
 if self.released then return end
 for _,entry in ipairs(self.meshes)do
  if entry.mesh then entry.mesh:release()end
 end
 self.meshes={};self.poseBytes=nil;self.released=true
end
return M
