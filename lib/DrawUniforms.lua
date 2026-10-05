-- Reuse unchanged draw state within one pass. Matrix snapshots compare values,
-- including in-place edits; reset on beginScene and whenever shaders change.
local M={}
function M.new()
 local shader,values,matrices=nil,{},{}
 return {
  reset=function()shader=nil;values={};matrices={}end,
  matrix=function(sh,name,value)
   if shader~=sh then shader=sh;values={};matrices={}end
   local old=matrices[name]
   local same=old~=nil
   if same then for i=1,16 do if old[i]~=value[i]then same=false;break end end end
   if same then return end
   if pcall(sh.send,sh,name,'row',value)then
    old=old or {};matrices[name]=old
    for i=1,16 do old[i]=value[i]end
   else
    -- A failed call may have partially changed driver state. Retry next time.
    matrices[name]=nil
   end
  end,
  send=function(sh,name,value)
   if shader~=sh then shader=sh;values={};matrices={}end
   if values[name]==value then return end
   if pcall(sh.send,sh,name,value)then values[name]=value end
  end,
 }
end
return M
