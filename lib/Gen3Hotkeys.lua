-- Native key ownership: settings use the same ladders as the options menu.
-- Camera look/cycling remains available during dialogue and quest playback.
local V=...
local M={}
function M.handle(game,ev,camera,scene,stage,looking,field)
 if not ev then return false end
 local input=game and game.input
 -- Rebinding and explicit gameplay bindings take priority over shortcuts.
 if input and (input.captureArmed or input.keyBindings and input.keyBindings[ev.key]~=nil)then return false end
 if ev.phase~='pressed' and ev.phase~='released'then return false end
 if ev.key=='3' and looking then
  if ev.phase=='pressed'then camera.setLevel(camera.level==0 and 2 or camera.level==1 and 4 or (camera.level+1)%8,game)end
  return true
 end
 if ev.key=='6' and (looking or stage.active)then
  if ev.phase=='pressed'then scene.tilt:cycle(game,1)end
  return true
 end
 local names={['5']='VoxelGrid',['7']='WorldCurve',['9']='Water'}
 if ev.key~='8' and not names[ev.key]then return false end
 -- Scenery/battle-mode switches are field-only, like Gen1. In particular
 -- do not change the selected battle renderer while a fight owns the field.
 if not field or game.zoomGateOK and not game:zoomGateOK()then return false end
 if ev.phase=='pressed'then
  local setting=ev.key=='8' and stage.setting or V.require(names[ev.key]).setting
  setting:cycle(game,1)
 end
 return true
end
return M
