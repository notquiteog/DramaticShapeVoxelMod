-- Exact affine bounds of the native actor fallback card. Providers can draw
-- larger models, so call only AFTER all model providers have stood down.
-- Caller supplies current-pass planes (including reflected VP), or nil for
-- curved/deformed geometry. This helper does not filter shadow submissions.
local V=...
local Cull=V.require('FrustumCull')
local M={}
local bounds={}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
function M.visible(model,width,height,padding,planes)
 if not planes then return true end
 if type(model)~='table'or not(finite(width)and finite(height)and finite(padding))or width<0 or height<0 then return true end
 for i=1,16 do if not finite(model[i])then return true end end
 -- Perspective matrices and unknown transforms cannot use affine extrema.
 if model[13]~=0 or model[14]~=0 or model[15]~=0 or model[16]~=1 then return true end
 local halfWidth,halfHeight=width/2,height/2
 local centerY=halfHeight-padding
 -- Card vertices are (+/-width/2, {-padding,height-padding}, 0).
 -- Each transformed coordinate's extrema follow from the two signed axes;
 -- this also covers yaw, leaned/sheared cards, negative scale and reflection.
 for axis=0,2 do
  local row=axis*4+1
  local center=model[row+1]*centerY+model[row+3]
  local extent=math.abs(model[row])*halfWidth+math.abs(model[row+1])*halfHeight
  bounds[axis+1],bounds[axis+4]=center-extent,center+extent
 end
 return Cull.visible(planes,bounds)
end
return M
