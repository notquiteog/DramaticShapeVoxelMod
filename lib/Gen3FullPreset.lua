-- Game3's FULL rung applies the same supported presentation choices as the
-- GB preset. Entering FULL is an action, not a per-frame reset of user edits.
local V=...
local M={}
function M.new(initial)
 local previous=initial
 return {update=function(_,level,game)
  local entered=level==1 and previous~=1
  previous=level
  if entered then
   local tilt=V.require('Gen3SceneOptions').tilt
   tilt:setIndex(#tilt.values,game)
   V.require('WorldCurve').setting:setIndex(1,game)
   V.require('Water').setting:setIndex(1,game)
   V.require('Gen3Battle').setting:setIndex(1,game)
   V.require('BattleArt').viewSetting:setIndex(2,game)
  end
  -- Like Gen1, FULL pins the day clock, but leaves battle/art choices editable.
  if level==1 then V.require('DayNight').forceSync(game)end
  return entered
 end}
end
return M
