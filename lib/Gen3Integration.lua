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
 if V.require('CameraSettings').invertY:get() then dy=-dy end
 M.yaw=(M.yaw+dx)%(math.pi*2);M.pitch=math.max(-.6,math.min(.65,M.pitch+dy))
end
function M.isActive()return M.active and free()end
function M.moveVector(forward,right)
 forward,right=tonumber(forward) or 0,tonumber(right) or 0
 return math.sin(M.yaw)*forward+math.cos(M.yaw)*right,
  -math.cos(M.yaw)*forward+math.sin(M.yaw)*right
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
 local SceneOptions=V.require('Gen3SceneOptions')
 local BattleStage=V.require('Gen3Battle')
 local uninstallBattle=BattleStage.install()
 local draw,present,update=FieldView.draw,Display.present,Player.update
 local failed=false
 mode:read();M.level=mode:get();local schema=mod.options:define({Distance.setting:schema('Scenery distance: AUTO adapts to the platform; FULL includes the loaded connected maps. Distant scenery fades into the sky.'),BattleStage.setting:schema('Native battle sprites and attacks over the 2.5D field. Disable to use the original FireRed battle background.'),Trees.art:schema('Original game tree drawings or optional illustrated replacements.'),Trees.setting:schema('Flat illustrated trunks follow their leaf billboards; SOLID restores physical trunks.'),mode:schema('FireRed 2.5D camera. Press 3 to cycle; drag with the right mouse button to look in 1ST/rotating 3RD. Special field effects retain their original presentation.')})
 local nativeArt=V.require('NativeBattleArt');nativeArt.install()
 local interfaceArt=V.require('NativeInterfaceArt')
 local uninstallInterface=interfaceArt.install()
 local sharedSettings={V.require('ModernBattleUI').setting,
  V.require('Shadows').setting,V.require('WorldCurve').setting,V.require('VoxelGrid').setting}
 for _,setting in ipairs(SceneOptions.settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(interfaceArt.settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require('Gen3BattleOptions').settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require('Gen3BattleBackdrop').settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(sharedSettings)do
  schema[#schema+1]=setting:schema('Shared renderer option; applies immediately to the native Gen 3 presentation.')
 end
 for _,setting in ipairs(nativeArt.settings())do schema[#schema+1]=setting:schema('Shared Battle Art sprite settings. ANIMATED uses installed atlases or bundled BW backs (dex 1–251); missing art falls back to static full-body images. ROM/MODDED preserves native/provider art.')end
 mod.options:define(schema)
 local Support=V.require('OptionSupport')
 V.require('InGameOptions').install(mod,Support.rows(schema,3),'BATTLE ART')
 mod.exports.optionSupport=Support.inventory(3)
 local function field(game)return game and game.phase=='field' and game.session and not Battle.isActive() end
 local function looking(game)return field(game) or game and game.phase=='quest_log' end
 local uninstallRecap=V.require('Gen3Recap').install(M)
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
  if ev.key=='3' and looking(game) then
   if ev.phase=='pressed' then M.setLevel((M.level+1)%8,game) end
   return true
  end
  return next(game,ev)
 end)
 local stick={x=0,y=0}
 mod.hooks:wrap('input.gamepad',function(next,game,ev)
  if ev.phase=='axis' then
   if ev.axis=='rightx'then stick.x=tonumber(ev.value)or 0 elseif ev.axis=='righty'then stick.y=tonumber(ev.value)or 0 end
  elseif ev.phase=='removed'then stick.x,stick.y=0,0 end
  return next(game,ev)
 end)
 mod.hooks:wrap('core.update',function(next,game,dt,...)
  SceneOptions.update(dt)
  if looking(game) and free() then
   local function axis(v)return math.abs(v)>.18 and (v-(v>0 and .18 or -.18))/.82 or 0 end
   local elapsed=math.min(tonumber(dt)or 0,.1)
   M.look(axis(stick.x)*elapsed*2.2,axis(stick.y)*elapsed*1.5)
  end
  return next(game,dt,...)
 end)
 for _,event in ipairs({'save.loaded','save.created'})do
  mod.events:on(event,function()V.require('DayNight').restore()end)
 end
 mod.events:on('save.writing',function()V.require('DayNight').store()end)
 local dragging=false
 mod.hooks:wrap('input.pointer',function(next,game,ev)
  if ev.source=='mouse' and looking(game) and free() then
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
   for _,setting in ipairs(sharedSettings)do if payload.key==setting.key then setting:sync(payload.value)end end
   for _,setting in ipairs(nativeArt.settings())do if payload.key==setting.key then setting:sync(payload.value)end end
   for _,setting in ipairs({Trees.setting,Trees.art})do if payload.key==setting.key then setting:sync(payload.value);Trees.changed(payload.key)end end
  end
  if payload and payload.mod==mod.id and payload.key==mode.key then
   mode:sync(payload.value);M.level=mode:get()
  end
 end)
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)
  FieldView.draw,Display.present,Player.update=draw,present,update
  uninstallInterface();uninstallBattle();uninstallRecap();Scene.release();return next(...)
 end)
 mod.exports.version=mod.version;mod.exports.lib=V
 mod.exports.gen3Camera=M
 mod.exports.battleTheme=V.require('BattleTheme')
 mod.exports.battlePresentation={modernUIEnabled=V.require('ModernBattleUI').enabled,
  nativeHudOwned=function()return BattleStage.active and V.require('ModernBattleUI').enabled()end}
 mod.exports.firered={camera=M,outdoor=true,battles=BattleStage,presentation='beta'}
 print('[Battle Art FireRed] native field and battle background adapters installed')
end
return M
