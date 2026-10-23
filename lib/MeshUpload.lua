-- Keep large public table uploads cooperative. The mesh is never returned
-- until every vertex is uploaded; failure releases the partial GPU allocation.
local V=...
local Budget=V.require('BuildBudget')
local M={}
-- Tree anchors are optional in mixed scenery batches. Normalize in slices
-- too: this CPU pass can contain many more vertices than one GPU upload.
function M.treeDefaults(vertices)
 for first=1,#vertices,2048 do
  for i=first,math.min(first+2047,#vertices)do
   local v=vertices[i];v[7],v[8],v[9]=v[7] or 0,v[8] or 0,v[9] or 0
  end
  Budget.check()
 end
end
function M.new(format,vertices)
 local mesh
 local ok,err=pcall(function()
  mesh=love.graphics.newMesh(format,#vertices,'triangles','static')
  Budget.track(mesh)
  Budget.check()
  for first=1,#vertices,2048 do
   local slice={}
   for i=first,math.min(first+2047,#vertices)do slice[#slice+1]=vertices[i]end
   mesh:setVertices(slice,first)
   Budget.check()
  end
 end)
 if mesh then Budget.untrack(mesh)end
 if not ok then if mesh then mesh:release()end;return nil,tostring(err)end
 return mesh
end
return M
