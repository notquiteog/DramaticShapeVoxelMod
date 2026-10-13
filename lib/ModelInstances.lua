-- Reuse one immutable model on the GPU; each placement stores only XYZ.
-- Unsupported drivers retain the ordinary merged-mesh path at build time.
local M={}
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
function M.new(mesh,positions)
 if not M.available() or not mesh or not mesh.attachAttribute or not mesh.detachAttribute or #positions==0 then return end
 local ok,offsets=pcall(love.graphics.newMesh,{{'VertexInstanceOffset','float',3}},positions,'points','static')
 if not ok then return end
 detach(mesh)
 ok=pcall(mesh.attachAttribute,mesh,'VertexInstanceOffset',offsets,'perinstance')
 if not ok then offsets:release();return end
 mesh:detachAttribute('VertexInstanceOffset')
 local batch={instanceMesh=mesh,offsets=offsets,count=#positions}
 function batch:release()
  if attached[self.instanceMesh]==self.offsets then detach(self.instanceMesh)end
  self.offsets:release()
 end
 return batch
end
function M.mesh(batch)
 return type(batch)=='table' and batch.instanceMesh or batch
end
function M.draw(batch,shader)
 if type(batch)~='table' or not batch.instanceMesh then detach(batch);love.graphics.draw(batch);return end
 local mesh=batch.instanceMesh
 if attached[mesh]~=batch.offsets then
  mesh:attachAttribute('VertexInstanceOffset',batch.offsets,'perinstance')
  attached[mesh]=batch.offsets
 end
 shader:send('sceneryInstances',1)
 local ok,err=pcall(love.graphics.drawInstanced,mesh,batch.count)
 shader:send('sceneryInstances',0)
 if not ok then detach(mesh);error(err,0)end
end
return M
