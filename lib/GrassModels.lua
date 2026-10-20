-- Optional imported scenery only. Native adapters retain grass/cut predicates,
-- source ground, local elevation, encounters and all gameplay ownership.
-- Original ORAS art/credits: assets/scenery/oras-grass/provenance.json.
local V=...
local Data=V.require('GrassModelData')
local Instances=V.require('ModelInstances')
local Budget=V.require('BuildBudget')
local M={FALLBACK_VERTEX_LIMIT=8192}
local variants,images={},{}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
local function key(name,extent,rotation)
 if not Data[name]then return nil,'unknown grass model'end
 if extent~=8 and extent~=16 then return nil,'grass extent must match an 8px subtile or 16px cell'end
 if not finite(rotation)or rotation%1~=0 then return nil,'grass rotation must be an integer quarter-turn'end
 rotation=rotation%4
 return name..':'..extent..':'..rotation,rotation
end
-- Returned arrays are immutable shared prototypes. X/Z occupy [0,extent],
-- Y starts at zero. A placement's x/y/z is the cell origin/local ground.
-- Quarter turns are baked once; the existing XYZ-only instance format stays
-- unchanged. Rotation never expands the native square footprint.
function M.vertices(name,extent,rotation)
 local k,r=key(name,extent,rotation or 0)
 if not k then return nil,r end
 if variants[k]then return variants[k].vertices,variants[k].indices end
 local source=Data[name];local vertices,indices={},{}
 for _,p in ipairs(source.vertices)do
  local x,z=p[1],p[3]
  if r==1 then x,z=-z,x elseif r==2 then x,z=-x,-z elseif r==3 then x,z=z,-x end
  vertices[#vertices+1]={extent*(x+.5),extent*p[2],extent*(z+.5),p[4],p[5],p[6]}
 end
 for i,n in ipairs(source.indices)do indices[i]=n end
 variants[k]={vertices=vertices,indices=indices}
 return vertices,indices
end
function M.info(name)
 local d=Data[name];if not d then return end
 return{texture=d.texture,triangles=d.triangles,doubleSided=true,heightPerExtent=d.height,footprint=.96}
end
function M.image(name)
 if images[name]then return images[name]end
 local d=Data[name]
 if not d or not(V.mod and V.mod.read and love and love.graphics and love.filesystem)then return end
 local file,created
 local ok,image=pcall(function()
  file=love.filesystem.newFileData(assert(V.mod:read(d.texture)),d.texture)
  created=love.graphics.newImage(file)
  created:setFilter('nearest','nearest');created:setWrap(d.wrapS,d.wrapT)
  return created
 end)
 if file and file.release then file:release()end
 if not ok then if created and created.release then created:release()end;return nil,tostring(image)end
 images[name]=image;return image
end
local function releaseParts(parts)
 for _,part in ipairs(parts)do
  if part.mesh and part.mesh.release then part.mesh:release()end
  if part.model and part.model.release then part.model:release()end
  part.mesh,part.model,part.count,part.positions=nil,nil,0,{}
 end
end
-- placements: {model='oras_green',extent=8|16,rotation=0..3,x,y,z}.
-- Caller supplies the ordinary Voxel3D.newMesh uploader and owns returned parts.
-- Draw with ModelInstances.draw(part.mesh,shader); image is already bound.
-- Existing opaque/alpha-cutout shader and cull='none' are appropriate to the
-- source's two-sided blades. No wind or synthetic blades are introduced.
-- On any unavailable asset/upload, returns nil,error after releasing partial
-- batches, allowing adapters to retain the native grass cards unchanged.
function M.buildBatches(placements,newMesh,options)
 if type(placements)~='table'or type(newMesh)~='function'then return nil,'grass batch needs placements and uploader'end
 local groups,keys={},{}
 for _,p in ipairs(placements)do
  if type(p)~='table'or not(finite(p.x)and finite(p.y)and finite(p.z))then return nil,'invalid grass placement'end
  local k,r=key(p.model,p.extent,p.rotation or 0);if not k then return nil,r end
  local g=groups[k]
  if not g then g={model=p.model,extent=p.extent,rotation=r,positions={}};groups[k]=g;keys[#keys+1]=k end
  g.positions[#g.positions+1]={p.x,p.y,p.z}
 end
 table.sort(keys)
 -- The scene can register this destination before invoking a yielding build.
 -- Each part enters it before the first upload/check that can yield, so an
 -- abandoned scene job still owns and can release all completed resources.
 local parts=options and options.parts or{}
 if type(parts)~='table'or #parts>0 then return nil,'grass output must be an empty scene-owned table'end
 local function check()
  if options and options.cancelled and options.cancelled()then error('grass build cancelled',0)end
  Budget.check()
 end
 local ok,err=pcall(function()
  for _,k in ipairs(keys)do
   check()
   local g=groups[k];local image=assert(M.image(g.model),'grass texture unavailable')
   local vertices,indices=M.vertices(g.model,g.extent,g.rotation)
   local function newPart(positions)
    local part={image=image,count=#positions,positions=positions,modelId=g.model,extent=g.extent,rotation=g.rotation}
    parts[#parts+1]=part;return part
   end
   local part=newPart(g.positions)
   part.model=assert(newMesh(vertices,indices),'grass prototype upload failed')
   part.model:setTexture(image)
   part.mesh=Instances.new(part.model,g.positions)
   part.instanced=part.mesh~=nil
   if not part.mesh then
    part.model:release();part.model=nil
    -- Keep fallback uploads bounded on drivers without instancing. Each part
    -- retains its exact placement/vertex slots for immediate native Cut edits.
    local limit=math.max(1,math.floor(M.FALLBACK_VERTEX_LIMIT/#vertices))
    for first=1,#g.positions,limit do
     if first>1 then part=newPart({})else part.positions={}end
     local merged,map,slots={},{},{}
     for j=first,math.min(first+limit-1,#g.positions)do
      check()
      local offset=g.positions[j];local base=#merged
      part.positions[#part.positions+1]=offset;slots[#slots+1]=#slots+1
      for _,p in ipairs(vertices)do
       merged[#merged+1]={p[1]+offset[1],p[2]+offset[2],p[3]+offset[3],p[4],p[5],p[6]}
      end
      for _,i in ipairs(indices)do map[#map+1]=base+i end
     end
     part.mesh=assert(newMesh(merged,map),'grass fallback upload failed')
     part.mesh:setTexture(image)
     part.count=#part.positions;part.slots=slots;part.verticesPerPlacement=#vertices;part.sourceIndices=indices
    end
   end
   check()
  end
 end)
 if not ok then releaseParts(parts);return nil,tostring(err)end
 return parts
end
-- Native Cut can hide a source rectangle immediately while the async scene
-- rebuild catches up. Bounds are half-open world X/Z coordinates. Adapters
-- must skip parts with count==0. This never changes source/native map data.
function M.hideRect(parts,x0,z0,x1,z1)
 if not(finite(x0)and finite(z0)and finite(x1)and finite(z1))or x1<=x0 or z1<=z0 then return 0 end
 local removed=0
 for _,part in ipairs(parts or{})do
  local keep,slots={},{}
  for i,p in ipairs(part.positions or{})do
   if p[1]<x1 and p[1]+part.extent>x0 and p[3]<z1 and p[3]+part.extent>z0 then removed=removed+1
   else keep[#keep+1]=p;slots[#slots+1]=part.slots and part.slots[i]or i end
  end
  if #keep<part.count then
   local ok=true
   if #keep>0 then
    if part.instanced then
     ok=pcall(part.mesh.offsets.setVertices,part.mesh.offsets,keep)
    else
     local map={}
     for _,slot in ipairs(slots)do for _,index in ipairs(part.sourceIndices)do
      map[#map+1]=(slot-1)*part.verticesPerPlacement+index
     end end
     ok=pcall(part.mesh.setVertexMap,part.mesh,map)
    end
   end
   if not ok then
    -- A device rejecting an in-place update must not leave cut grass visible.
    -- Hide this part until its normal scene rebuild can recover the survivors.
    keep,slots={},{}
   end
   part.positions,part.count,part.slots=keep,#keep,slots
   if part.instanced then part.mesh.count=#keep end
  end
 end
 return removed
end
function M.releaseBatches(parts)releaseParts(parts or {})end
-- Call after releasing all scene-owned batches, on renderer/provider reset.
function M.release()
 for _,image in pairs(images)do if image.release then image:release()end end
 variants,images={},{}
end
return M
