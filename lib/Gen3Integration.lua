-- FireRed's native display bypasses Pipelines. Adapt its ordinary FieldView
-- method, leaving the engine's world/UI passes, battle renderer and callbacks
-- in charge. This file is deliberately loaded before any Gen1/2 patches.
local V=...
local M={yaw=0,pitch=.16,level=3,rendered=0,active=false}
local ModSetting=V.require('ModSetting')
local Trees=V.require('TreePresentation')
local Distance=V.require('RenderDistance')
local mode=ModSetting.new('fireredCamera','2.5D CAMERA',{0,1,2,3,4,5,6,7},
 {'OFF','FULL','15','35','50','75','1ST','ROTATING 3RD'},4)
local function free()return M.level>=6 end
local dirs={'up','right','down','left'}
function M.worldDirection(dir,yaw)
 local offset=math.floor((yaw or 0)/(math.pi*.5)+.5)
 for i,d in ipairs(dirs)do if d==dir then return dirs[(i-1+offset)%4+1] end end
 return dir
end
function M.look(dx,dy)
 M.yaw=(M.yaw+dx)%(math.pi*2);M.pitch=math.max(-.6,math.min(.65,M.pitch+dy))
end
function M.setLevel(level,game)
 mode:setIndex(level+1,game);M.level=mode:get()
end
function M.install()
 local mod=V.mod
 local FieldView=require('src.core.game3.field_view')
 local Display=require('src.core.game3.display')
 local Player=require('src.core.game3.player')
 local Battle=require('src.core.game3.battle')
 local Tilt=require('src.render.Tilt')
 local Scene=V.require('Gen3Scene')
 local BattleStage=V.require('Gen3Battle')
 local uninstallBattle=BattleStage.install()
 local draw,present,update=FieldView.draw,Display.present,Player.update
 local failed=false
 mode:read();M.level=mode:get();local schema=mod.options:define({Distance.setting:schema('Scenery distance: AUTO adapts to the platform; FULL includes the loaded connected maps. Distant scenery fades into the sky.'),BattleStage.setting:schema('Native battle sprites and attacks over the 2.5D field. Disable to use the original FireRed battle background.'),Trees.art:schema('Original game tree drawings or optional illustrated replacements.'),Trees.setting:schema('Flat illustrated trunks follow their leaf billboards; SOLID restores physical trunks.'),mode:schema('FireRed 2.5D camera. Press 3 to cycle; drag with the right mouse button to look in 1ST/rotating 3RD. Special field effects retain their original presentation.')})
 V.require('InGameOptions').install(mod,schema,'BATTLE ART')
 local function field(game)return game and game.phase=='field' and game.session and not Battle.isActive() end
 FieldView.draw=function(game,w,h,opts)
  M.active=false
  if failed or M.level==0 or not field(game) or Scene.nativeRequired(game) then return draw(game,w,h,opts) end
  local ok,result=pcall(Scene.draw,game,w,h,M)
  if not ok then
   failed=true;Scene.restore();print('[Battle Art FireRed] native fallback: '..tostring(result))
  end
  if ok and result then M.active=true;M.rendered=M.rendered+1;return end
  return draw(game,w,h,opts)
 end
 -- Disable only the native tilt surrounding OUR field pass. The saved tilt
 -- setting and the original off-mode rendering remain intact.
 Display.present=function(game,...)
  if not field(game) then M.active=false end
  local battle=Battle.isActive() and BattleStage.enabled()
  if not battle and (M.level==0 or failed or not field(game) or Scene.nativeRequired(game)) then return present(game,...) end
  local level,angle=Tilt.level,Tilt.angle
  Tilt.level,Tilt.angle=0,0
  local ok,result=pcall(present,game,...)
  Tilt.level,Tilt.angle=level,angle
  if not ok then error(result,0) end
  return result
 end
 Player.update=function(game,input)
  if M.active and free() and not failed and field(game) and not Scene.nativeRequired(game) and input and input.isDown then
   local proxy=setmetatable({}, {__index=input})
   -- Game3 prefers freshly pressed directions over held directions. Rotate
   -- both views of the SAME intent, or each new press defeats the camera.
   for _,method in ipairs({'isDown','wasPressed'})do
    if input[method] then
     local read=input[method]
     proxy[method]=function(_,key)
      for _,dir in ipairs(dirs)do if M.worldDirection(dir,M.yaw)==key then return read(input,dir) end end
      return read(input,key)
     end
    end
   end
   return update(game,proxy)
  end
  return update(game,input)
 end
 mod.hooks:wrap('input.key',function(next,game,ev)
  if ev.key=='3' and field(game) then
   if ev.phase=='pressed' then M.setLevel((M.level+1)%8,game) end
   return true
  end
  return next(game,ev)
 end)
 local dragging=false
 mod.hooks:wrap('input.pointer',function(next,game,ev)
  if ev.source=='mouse' and field(game) and free() then
   if ev.button==2 then
    dragging=ev.phase=='pressed';return true
   end
   if ev.phase=='moved' and dragging then M.look((ev.dx or 0)*.005,(ev.dy or 0)*.004);return true end
  else dragging=false end
  return next(game,ev)
 end)
 mod.events:on('mod.options_changed',function(payload)
  if payload and payload.mod==mod.id and payload.key==Distance.setting.key then Distance.setting:sync(payload.value);Scene.invalidate()end
  if payload and payload.mod==mod.id and payload.key==BattleStage.setting.key then BattleStage.setting:sync(payload.value) end
  if payload and payload.mod==mod.id then
   for _,setting in ipairs({Trees.setting,Trees.art})do if payload.key==setting.key then setting:sync(payload.value);Trees.changed(payload.key)end end
  end
  if payload and payload.mod==mod.id and payload.key==mode.key then
   mode:sync(payload.value);M.level=mode:get()
  end
 end)
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)
  FieldView.draw,Display.present,Player.update=draw,present,update
  uninstallBattle();Scene.release();return next(...)
 end)
 mod.exports.version=mod.version;mod.exports.lib=V
 mod.exports.battleTheme=V.require('BattleTheme')
 mod.exports.firered={camera=M,outdoor=true,battles=BattleStage,presentation='beta'}
 print('[Battle Art FireRed] native field and battle background adapters installed')
end
return M
