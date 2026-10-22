-- Reuse transient field-effect geometry; vertices remain engine-frame accurate.
local M={}
function M.new(create)
 local entries={};local self={}
 function self:get(key,vertices,indices)
  local row=entries[key]
  if row and row.count~=#vertices then row.mesh:release();entries[key]=nil;row=nil end
  if not row then
   local mesh,err=create(vertices,indices);if not mesh then return nil,err end
   row={mesh=mesh,count=#vertices};entries[key]=row
  else
   -- Our producer always emits the same sequential quad topology. Positions,
   -- source UVs, shading and terrain heights can still change every frame.
   row.mesh:setVertices(vertices)
  end
  return row.mesh
 end
 function self:clear()
  for _,row in pairs(entries)do row.mesh:release()end;entries={}
 end
 return self
end
return M
