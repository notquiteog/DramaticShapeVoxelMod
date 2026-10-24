-- Water.begin owns the shader for a contiguous mesh batch. Avoid resending
-- identical material/model uniforms between meshes: shader sends can flush
-- LÖVE's pending draw batch even when the value has not changed.
local M={}
function M.new()
 local entries,epoch,shader={},0,nil
 local self={}
 function self:begin(sh)shader=sh;epoch=epoch+1 end
 function self:send(name,value,row)
  local entry=entries[name]
  if not entry then entry={values={}};entries[name]=entry end
  local vector=type(value)=='table'
  local count=vector and #value or 0
  local same=entry.epoch==epoch and entry.row==row and entry.vector==vector
  if same then
   if vector then
    same=entry.count==count
    if same then for i=1,count do if entry.values[i]~=value[i]then same=false;break end end end
   else same=entry.value==value end
  end
  if same then return true end
  local ok
  if row then ok=pcall(shader.send,shader,name,'row',value)
  else ok=pcall(shader.send,shader,name,value)end
  if not ok then entry.epoch=nil;return false end
  entry.epoch,entry.row,entry.vector,entry.count=epoch,row,vector,count
  if vector then for i=1,count do entry.values[i]=value[i]end
  else entry.value=value end
  return true
 end
 return self
end
return M
