-- Reuse unchanged scalar draw state inside one scene pass. Never cache mutable
-- matrices or texture data; reset on beginScene and whenever its shader changes.
local M={}
function M.new()
 local shader,values=nil,{}
 return {
  reset=function()shader=nil;values={}end,
  send=function(sh,name,value)
   if shader~=sh then shader=sh;values={}end
   if values[name]==value then return end
   if pcall(sh.send,sh,name,value)then values[name]=value end
  end,
 }
end
return M
