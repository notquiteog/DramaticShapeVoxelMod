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
  for _,src in ipairs(model.meshes)do
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
    local vertices,map={},{}
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
       vertices[#vertices+1]={p[1],p[2],p[3],tc[1],1-tc[2],1,
        vc[1]*diffuse[1],vc[2]*diffuse[2],vc[3]*diffuse[3],
        (vc[4]or 1)*(material.alpha or 1)}
       map[#map+1]=vi
       for axis=1,3 do
        bounds[axis]=math.min(bounds[axis],p[axis])
        bounds[axis+3]=math.max(bounds[axis+3],p[axis])
       end
      end
     end
     corner=corner+#face
    end
    if #vertices>0 then
     local entry={source=src,vertices=vertices,map=map,weights=weights}
     self.meshes[#self.meshes+1]=entry
     entry.mesh=love.graphics.newMesh(FORMAT,vertices,'triangles','dynamic')
     entry.texture=layer and assets.image(layer.image.path)or assets.white()
     assert(entry.texture,'Missing XD texture')
    end
   end
  end
 end)
 if not ok then self:release();return nil,err end
 if #self.meshes==0 or bounds[5]<=bounds[2]then
  self:release();return nil,'Empty XD geometry'
 end
 self.bounds=bounds
 self:playContext('idle',true)
 return self
end
function Instance:metrics()
 local b=self.bounds
 return {height=b[5]-b[2],floor=b[2],width=b[4]-b[1],depth=b[6]-b[3]}
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
  end
  entry.mesh:setVertices(entry.vertices)
 end
 self.frame=frame
 return true
end
function Instance:drawWith(draw,matrix)
 if self.released then return false end
 for _,entry in ipairs(self.meshes)do draw(entry.mesh,entry.texture,matrix)end
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
