-- Use the upper face for a comfortable first-person horizon. Literal chibi
-- eye rows placed the view too close to furniture/ground in all generations.
-- Retain visible-foot anchoring, provider scale and explicit authored rows.
local M={}
function M.height(generation,frameHeight,footAnchor,eyeRow)
 local reference=generation==3 and 32 or 16
 local h=tonumber(frameHeight)or reference
 local row=tonumber(eyeRow)or h*(generation==3 and 17.5/32 or .25)
 return math.max(.5,(tonumber(footAnchor)or h)-row)
end
return M
