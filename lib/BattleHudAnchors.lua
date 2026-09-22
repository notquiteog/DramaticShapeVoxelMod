-- Project the same card/model matrices that draw the Pokémon. Coordinates
-- stay normalized so window resizing/DPI never changes which head owns a HUD.
local M={}
function M.project(cards,vp)
 local out={}
 for _,card in ipairs(cards)do
  local tw,th=card.tex:getWidth(),card.tex:getHeight()
  for slot,p in pairs(card.hudAnchors or {})do
   local x,y=p[1]/tw-.5,1-p[2]/th
   local m=card.model
   local wx,wy,wz=m[1]*x+m[2]*y+m[4],m[5]*x+m[6]*y+m[8],m[9]*x+m[10]*y+m[12]
   local px=vp[1]*wx+vp[2]*wy+vp[3]*wz+vp[4]
   local py=vp[5]*wx+vp[6]*wy+vp[7]*wz+vp[8]
   local pw=vp[13]*wx+vp[14]*wy+vp[15]*wz+vp[16]
   if pw>0 then out[slot]={px/pw*.5+.5,py/pw*.5+.5}end
  end
 end
 return out
end
return M
