-- Native field-effect frames, laid onto their terrain rather than triggering
-- the native 2D camera. The engine retains animation lifetime and timing.
local M={}
function M.supports(kind) return kind=='tracks' or kind=='ripple' end
function M.draw(fx,groundAt,emit)
 for i,a in ipairs(fx._anims or {})do
  if M.supports(a.kind) and a.cx and a.cy and (a.kind~='tracks' or a.visible)then
   local ripple=a.kind=='ripple'
   local sheet
   if ripple then sheet=fx.loadSheet('ripple',16,16,5)
   else sheet=fx.loadSheet(a.sheet)end
   local q=sheet and sheet.quads[a.frame or 0]
   if q then
    local x,z=a.cx*16,a.cy*16+(ripple and 6 or 0)
    emit('ground-fx-'..i,16,16,function()
     love.graphics.setColor(1,1,1,1)
     love.graphics.draw(sheet.image,q,a.hflip and 16 or 0,a.vflip and 16 or 0,
      0,a.hflip and -1 or 1,a.vflip and -1 or 1)
    end,{{x,.09,z},{x+16,.09,z},{x+16,.09,z+16},{x,.09,z+16}},groundAt(x+8,z+8))
   end
  end
 end
end
return M
