-- Reuse unchanged draw state within one pass. Matrix snapshots compare values,
-- including in-place edits; reset on beginScene and whenever shaders change.
local M={}
function M.new()
 local shader,values,matrices,vectors=nil,{},{},{}
 return {
  reset=function()shader=nil;values={};matrices={};vectors={}end,
  matrix=function(sh,name,value)
   if shader~=sh then shader=sh;values={};matrices={};vectors={}end
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
  vector=function(sh,name,value)
   if shader~=sh then shader=sh;values={};matrices={};vectors={}end
   local old=vectors[name]
   local same=old~=nil and #old==#value
   if same then for i=1,#value do if old[i]~=value[i]then same=false;break end end end
   if same then return end
   if pcall(sh.send,sh,name,value)then
    local copy={};for i=1,#value do copy[i]=value[i]end;vectors[name]=copy
   else vectors[name]=nil end
  end,
  send=function(sh,name,value)
   if shader~=sh then shader=sh;values={};matrices={};vectors={}end
   if values[name]==value then return end
   if pcall(sh.send,sh,name,value)then values[name]=value end
  end,
 }
end
return M
