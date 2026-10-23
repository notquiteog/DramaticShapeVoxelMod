-- Reuse one immutable model on the GPU; each placement stores only XYZ.
-- Unsupported drivers retain the ordinary merged-mesh path at build time.
local V=...
local M={}
local Cull
-- A prototype is shared by sun/main passes and sometimes adjacent maps.
-- Retain its immutable placement binding until another batch actually needs it.
local attached=setmetatable({},{__mode='k'})
local function detach(mesh)
 if attached[mesh] then mesh:detachAttribute('VertexInstanceOffset');attached[mesh]=nil end
end
function M.available()
 if not (love and love.graphics and type(love.graphics.drawInstanced)=='function')then return false end
 local supported=love.graphics.getSupported and love.graphics.getSupported()
 return not supported or supported.instancing~=false
end
function M.new(mesh,positions,withVisibility)
 if not M.available() or not mesh or not mesh.attachAttribute or not mesh.detachAttribute or #positions==0 then return end
 local ok,offsets=pcall(love.graphics.newMesh,{{'VertexInstanceOffset','float',3}},positions,'points','static')
 if not ok then return end
 detach(mesh)
 ok=pcall(mesh.attachAttribute,mesh,'VertexInstanceOffset',offsets,'perinstance')
 if not ok then offsets:release();return end
 mesh:detachAttribute('VertexInstanceOffset')
 -- Only physical scenery opting into camera filtering needs a CPU snapshot.
 local owned
 if withVisibility then
  owned={}
  for i,p in ipairs(positions)do owned[i]={p[1],p[2],p[3]}end
 end
 local batch={instanceMesh=mesh,offsets=offsets,count=#positions,_positions=owned}
 function batch:release()
  local view=self._visible
  if view and view.offsets then
   if attached[self.instanceMesh]==view.offsets then detach(self.instanceMesh)end
   view.offsets:release();view.offsets=nil
  end
  if attached[self.instanceMesh]==self.offsets then detach(self.instanceMesh)end
  self.offsets:release()
  self._positions=nil;self._visible=nil
 end
 return batch
end
-- Optional main-pass subset, owned by the full batch. Shadow draws continue
-- using the full batch. Only callers with undeformed physical bounds opt in.
function M.visible(batch,planes,localBounds)
 if type(batch)~='table'or not batch._positions or not planes or not localBounds or batch._viewFailed then return batch end
 Cull=Cull or(V and V.require('FrustumCull'))
 if not Cull then return batch end
 local view=batch._visible
 if not view then
  view={instanceMesh=batch.instanceMesh,count=0,_indices={},_selected={},_rows={},_base=batch}
  batch._visible=view
 end
 local count=0
 for i,p in ipairs(batch._positions)do
  if Cull.translated(planes,localBounds,p[1],p[2],p[3])then
   count=count+1;view._selected[count]=i
  end
 end
 if count==batch.count then return batch end
 if count==0 then view.count=0;return view end
 local changed=count~=view.count or not view.offsets
 if not changed then for i=1,count do if view._indices[i]~=view._selected[i]then changed=true;break end end end
 if not changed then return view end
 local ok=pcall(function()
  if not view.offsets then
   view.offsets=love.graphics.newMesh({{'VertexInstanceOffset','float',3}},batch.count,'points','dynamic')
   -- Validate the optional attribute buffer without losing the full batch.
   detach(batch.instanceMesh)
   batch.instanceMesh:attachAttribute('VertexInstanceOffset',view.offsets,'perinstance')
   attached[batch.instanceMesh]=view.offsets
   detach(batch.instanceMesh)
  end
  for i=1,count do view._rows[i]=batch._positions[view._selected[i]]end
  for i=#view._rows,count+1,-1 do view._rows[i]=nil end
  view.offsets:setVertices(view._rows,1)
 end)
 if not ok then
  -- Attribute validation can fail after touching native state.
  pcall(batch.instanceMesh.detachAttribute,batch.instanceMesh,'VertexInstanceOffset')
  attached[batch.instanceMesh]=nil
  if view.offsets then
   view.offsets:release();view.offsets=nil
  end
  batch._viewFailed=true
  return batch
 end
 for i=1,count do view._indices[i]=view._selected[i]end
 view.count=count
 return view
end
function M.mesh(batch)
 return type(batch)=='table' and batch.instanceMesh or batch
end
function M.draw(batch,shader)
 if type(batch)~='table' or not batch.instanceMesh then detach(batch);love.graphics.draw(batch);return end
 if batch.count==0 then return end
 local mesh=batch.instanceMesh
 if attached[mesh]~=batch.offsets then
  if batch._base then
   local ok=pcall(mesh.attachAttribute,mesh,'VertexInstanceOffset',batch.offsets,'perinstance')
   if not ok then
    pcall(mesh.detachAttribute,mesh,'VertexInstanceOffset');attached[mesh]=nil
    batch._base._viewFailed=true;return M.draw(batch._base,shader)
   end
  else mesh:attachAttribute('VertexInstanceOffset',batch.offsets,'perinstance')end
  attached[mesh]=batch.offsets
 end
 shader:send('sceneryInstances',1)
 local ok,err=pcall(love.graphics.drawInstanced,mesh,batch.count)
 shader:send('sceneryInstances',0)
 if not ok then
  detach(mesh)
  if batch._base then batch._base._viewFailed=true;return M.draw(batch._base,shader)end
  error(err,0)
 end
end
return M
