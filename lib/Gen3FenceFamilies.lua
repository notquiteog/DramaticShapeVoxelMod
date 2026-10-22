-- Explicit R/S/E source-art matches. A failed model upload leaves complete
-- native art; only a successful adapter owns the clean original lower layer.
local M={}
function M.shape(primary,secondary,mid,behavior,collision)
 if primary=='general'and mid==0x149 and collision==7 then
  return{kind='flat',reviewedSurface=true,nativeFence='rural149',ground=mid}
 end
end
return M
