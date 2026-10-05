-- Keep native emote art/timing; convert only its presentation coordinates.
local M = {}
function M.supports(kind)
 return kind=='emote' or kind=='exclamation'
end
function M.draw(fx,cam,groundAt,emit)
 local hasEmote=false
 for _,a in ipairs(fx._anims or {})do
  if type(a)=='table' and M.supports(a.kind)then hasEmote=true;break end
 end
 if not hasEmote then return end
 local actors={};fx.collectActors(actors)
 local yaw=cam and cam.level>=6 and cam.yaw or 0
 local dx,dz=8*math.cos(yaw),8*math.sin(yaw)
 for _,a in ipairs(actors)do if a.kind=='field_effect_emote' then
  -- The collector already resolves the native animation's frame and bounce.
  -- sortY is the target's native foot-row, with its +0.5 sorting bias.
  local z=a.sortY-.5+16
  local x=a.x+8
  local top=z-a.y
  emit('emote-'..a.i,16,16,function()a:draw(a.x,a.y)end,
   {{x-dx,top,z-dz},{x+dx,top,z+dz},
    {x+dx,top-16,z+dz},{x-dx,top-16,z-dz}},
   groundAt(x,z-.001,a.elevation))
 end end
end
return M
