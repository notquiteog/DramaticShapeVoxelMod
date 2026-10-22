-- Pipeline contexts describe the active playfield in LOVE units. Retain
-- drawable resolution without accidentally rendering the surrounding skin.
local M={}
function M.pixels(ctx)
  local g=love and love.graphics
  local w,h=ctx.width,ctx.height
  if g and g.getPixelDimensions and g.getDimensions then
    local ww,wh=g.getDimensions()
    local pw,ph=g.getPixelDimensions()
    if ww and wh and pw and ph and ww>0 and wh>0 and pw>0 and ph>0 then
      return math.max(1,math.floor(w*pw/ww+.5)),math.max(1,math.floor(h*ph/wh+.5))
    end
  end
  return w,h
end
return M
