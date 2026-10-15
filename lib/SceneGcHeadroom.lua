-- Gen 3's public GC ceiling otherwise forces a full collection while the old,
-- candidate and connected voxel scenes coexist. Allow bounded construction
-- headroom; keep the engine's incremental GC and all existing limits intact.
-- Never overwrite another mod's subsequent policy or its larger ceiling.
local M={}
function M.new(engine,caps)
 caps=caps or {}
 local constrained=caps.mobile or caps.console or caps.nx
 local original,owned,lost
 local self={}
 function self:update(enabled)
  if not enabled then
   if owned and engine.GC_CEILING_KB==owned then engine.GC_CEILING_KB=original end
   original,owned,lost=nil,nil,nil;return
  end
  if owned then
   if engine.GC_CEILING_KB~=owned then owned=nil;lost=true end
   return
  end
  if lost or constrained then return end
  local current=engine.GC_CEILING_KB
  if type(current)~='number' or current<=0 or current>=512*1024 then return end
  original,owned=current,512*1024;engine.GC_CEILING_KB=owned
 end
 function self:dispose()self:update(false)end
 return self
end
return M
