-- Keep large public table uploads cooperative. The mesh is never returned
-- until every vertex is uploaded; failure releases the partial GPU allocation.
local V=...
local Budget=V.require('BuildBudget')
local M={}
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
