-- Native front-facing player eyes are centered at row 8 in GB's 16px
-- drawings and row 21.5 in FRLG's padded 32px frames. Height is measured
-- from the same visible-foot anchor as the rendered card, not its hat.
local M={}
function M.height(generation,frameHeight,footAnchor,eyeRow)
 local reference=generation==3 and 32 or 16
 local h=tonumber(frameHeight)or reference
 local row=tonumber(eyeRow)or h*(generation==3 and 21.5/32 or .5)
 return math.max(.5,(tonumber(footAnchor)or h)-row)
end
return M
