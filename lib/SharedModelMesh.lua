-- Immutable prototypes shared only while scenes hold leases. No idle GPU cache:
-- the last scene releases the mesh, including cancellation and failed uploads.
local M={}
local entries=setmetatable({},{__mode='k'})
function M.acquire(vertices,indices,format,create,texture)
 local rows=entries[vertices]
 if rows then for _,row in ipairs(rows)do
  if row.indices==indices and row.format==format and row.create==create and row.texture==texture then
   row.refs=row.refs+1;return row.mesh,row
  end
 end end
 local mesh,err=create(vertices,indices,format)
 if not mesh then return nil,nil,err end
 -- The uploader may yield. Re-read after it returns; another suspended scene
 -- can have acquired this prototype in the meantime.
 rows=entries[vertices]
 if rows then for _,row in ipairs(rows)do
  if row.indices==indices and row.format==format and row.create==create and row.texture==texture then
   mesh:release();row.refs=row.refs+1;return row.mesh,row
  end
 end end
 rows=rows or{};entries[vertices]=rows
 local row={vertices=vertices,indices=indices,format=format,create=create,texture=texture,mesh=mesh,refs=1}
 rows[#rows+1]=row;return mesh,row
end
function M.release(row)
 if not row or row.refs<=0 then return end
 row.refs=row.refs-1;if row.refs>0 then return end
 local rows=entries[row.vertices]
 if rows then
  for i,r in ipairs(rows)do if r==row then table.remove(rows,i);break end end
  if #rows==0 then entries[row.vertices]=nil end
 end
 row.mesh:release();row.mesh=nil
end
return M
