-- Quarantine a broken scene, not the renderer for the rest of the session.
-- Transient provider/atlas failures get two bounded retries. Leaving the
-- scene or explicitly selecting a camera always permits a fresh attempt.
local M={}
function M.new()
 local self={failures=0,elapsed=0}
 function self:reset()self.context=nil;self.failures=0;self.elapsed=0;self.error=nil end
 function self:update(dt)self.elapsed=self.elapsed+math.max(0,tonumber(dt)or 0)end
 function self:ready(context)
  if self.context~=context then self:reset();self.context=context end
  return self.failures==0 or self.failures<3 and self.elapsed>=self.failures
 end
 function self:failed(err)self.failures=self.failures+1;self.elapsed=0;self.error=tostring(err)end
 function self:succeeded()self.failures=0;self.error=nil end
 return self
end
return M
