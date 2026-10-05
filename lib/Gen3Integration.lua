-- FireRed's native display bypasses Pipelines. Adapt its ordinary FieldView
-- method, leaving the engine's world/UI passes, battle renderer and callbacks
-- in charge. This file is deliberately loaded before any Gen1/2 patches.
local V=...
local M={yaw=0,pitch=.16,level=3,rendered=0,active=false}
local recovery=V.require('RenderRecovery').new()
M.recovery=recovery
local ModSetting=V.require('ModSetting')
local Trees=V.require('TreePresentation')
local Distance=V.require('RenderDistance')
local mode=ModSetting.new('fireredCamera','VOXEL',{0,1,2,3,4,5,6,7},
 {'OFF','FULL','15','35','50','75','1ST','3RD'},4)
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
 recovery:reset()
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
 local controls=V.require('Gen3CameraControls').new(M)
 local legendary=V.require('LegendaryVisualsPreset')
 local uninstallBattle=BattleStage.install()
 local uninstallCapture=V.require("Gen3Capture").install()
 V.require('KantoLifeAudio').install(mod)
 V.require('NativeCaveAudio').install(3,function()return M.level~=0 end)
 local draw,present,update=FieldView.draw,Display.present,Player.update
 local function ready(game)return recovery:ready(Scene.context and Scene.context()or game.session)end
 mode:read();M.level=mode:get();local schema=mod.options:define({Distance.setting:schema('Scenery distance: AUTO adapts to the platform; FULL includes the loaded connected maps. Distant scenery fades into the sky.'),BattleStage.setting:schema('Native battle sprites and attacks over the 2.5D field. Disable to use the original battle background.'),Trees.art:schema('Solid voxel trees carved from the original game art (default), original flat cards, or illustrated cards.'),Trees.setting:schema('For card trees: flat trunks follow the crown, or use modeled trunks. Original model trees are fully solid.'),mode:schema('Gen 3 2.5D camera. Press 3 to cycle; drag with the right mouse button to look in 1ST/rotating 3RD. Special field effects retain their original presentation.')})
 local fullPreset=V.require('Gen3FullPreset').new(M.level)
 local nativeArt=V.require('NativeBattleArt');nativeArt.install()
 local interfaceArt=V.require('NativeInterfaceArt')
 interfaceArt.crystal=V.require('NativeCrystalArt')
 local uninstallCrystalField=V.require('NativeCrystalField').install()
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)uninstallCrystalField();return next(...)end)
 local uninstallInterface=interfaceArt.install()
 local sharedSettings={V.require('CommunityVisuals').towerWall,V.require('CommunityVisuals').signs,V.require('CommunityVisuals').safari,V.require('CommunityVisuals').grass,legendary.setting,Trees.props,Trees.surfaces,V.require('ModernBattleUI').setting,V.require('CommunityVisuals').treeDetail,V.require('CommunityVisuals').caveSound,V.require('CommunityVisuals').kantoLife,
  V.require('Shadows').setting,V.require('WorldCurve').setting,V.require('VoxelGrid').setting}
 for _,setting in ipairs(V.require("Gen3Capture").settings())do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require("NativeAtmosphere").settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(SceneOptions.settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(interfaceArt.settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require('Gen3BattleOptions').settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require('Gen3BattleBackdrop').settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(sharedSettings)do
  schema[#schema+1]=setting:schema(setting.key=='spatialUpscale' and V.require('SpatialUpscale').description or 'Shared renderer option; applies immediately to the native Gen 3 presentation.')
 end
 for _,row in ipairs(V.require('NativeCrystalArt').schemas())do schema[#schema+1]=row end
 for _,setting in ipairs(nativeArt.settings())do schema[#schema+1]=setting:schema('Shared Battle Art sprite settings. ANIMATED uses installed atlases or bundled BW backs (dex 1–251); missing art falls back to static full-body images. ROM/MODDED preserves native/provider art.')end
 mod.options:define(schema)
 local Support=V.require('OptionSupport')
 local liveSettings={}
 for _,setting in ipairs(sharedSettings)do liveSettings[setting.key]=setting end
 V.require('InGameOptions').install(mod,Support.rows(schema,3),'BATTLE ART',V.require('OptionCategories'),liveSettings)
 mod.exports.optionSupport=Support.inventory(3)
 local function field(game)return game and game.phase=='field' and game.session and not Battle.isActive() end
 local function looking(game)
  if not(field(game) or game and game.phase=='quest_log')then return false end
  for _,name in ipairs({'start_menu','option_menu','controls_menu','bag_menu','party_menu','summary_menu','pokedex','pc_menu','shop_menu'})do
   for _,prefix in ipairs({'src.ui.game3.','src.ui.game3.rse.'})do
    local menu=package.loaded[prefix..name]
    if menu and menu.isOpen and menu.isOpen()then return false end
   end
  end
  return true
 end
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)V.require('KantoLifeAudio').dispose();V.require('KantoLife').invalidate();return next(...)end)
 local uninstallRecap=V.require('Gen3Recap').install(M)
 FieldView.draw=function(game,w,h,opts)
  M.active=false
  if M.level==0 or not field(game) or not ready(game) or Scene.nativeRequired(game) then return draw(game,w,h,opts) end
  local ok,result=pcall(Scene.draw,game,w,h,M)
  if not ok then
   recovery:failed(result);Scene.restore();Scene.invalidate()
   print('[Battle Art FireRed] scene fallback: '..tostring(result))
  end
  if ok and result then recovery:succeeded();M.active=true;M.rendered=M.rendered+1;return end
  return draw(game,w,h,opts)
 end
 -- Disable only the native tilt surrounding OUR field pass. The saved tilt
 -- setting and the original off-mode rendering remain intact.
 Display.present=function(game,...)
  if not field(game) then M.active=false end
  local battle=Battle.isActive() and BattleStage.enabled()
  if not battle and (M.level==0 or not field(game) or not ready(game) or Scene.nativeRequired(game)) then return present(game,...) end
  local level,angle=Tilt.level,Tilt.angle
  Tilt.level,Tilt.angle=0,0
  local ok,result=pcall(present,game,...)
  Tilt.level,Tilt.angle=level,angle
  if not ok then error(result,0) end
  return result
 end
 Player.update=function(game,input)
  if M.active and free() and field(game) and ready(game) and not Scene.nativeRequired(game) and input and input.isDown then
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
  local input=game and game.input
  local bound=input and (input.captureArmed or input.keyBindings and input.keyBindings[ev.key]~=nil)
  if not bound and looking(game) and M.active and M.level==7 and (ev.key=='q' or ev.key=='e')then
   if ev.phase=='pressed'then controls:step(ev.key=='q' and 1 or -1)end
   return true
  end
  if V.require('Gen3Hotkeys').handle(game,ev,M,SceneOptions,BattleStage,looking(game),field(game))then return true end
  return next(game,ev)
 end)
 local stick={x=0,y=0}
 local battleMouse
 mod.hooks:wrap('input.gamepad',function(next,game,ev)
  if ev.phase=='axis' then
   if ev.axis=='rightx'then stick.x=tonumber(ev.value)or 0 elseif ev.axis=='righty'then stick.y=tonumber(ev.value)or 0 end
  elseif ev.phase=='pressed' and looking(game) and M.active and M.level==7 and (ev.button=='leftstick' or ev.button=='rightstick')then
   controls:step(ev.button=='leftstick' and 1 or -1);return true
  elseif ev.phase=='removed'then stick.x,stick.y=0,0 end
  return next(game,ev)
 end)
 mod.hooks:wrap('core.update',function(next,game,dt,...)
  recovery:update(dt)
  BattleStage.update()
  legendary.migrate(game)
  fullPreset:update(M.level,game)
  SceneOptions.update(dt)
  controls:update(dt,looking(game) and M.active,love.mouse)
  if BattleStage.active and Battle.isActive()then
   local camera=V.require('BattleCam')
   camera.stickOrbit(stick.x,math.min(dt,.1));camera.stickPitch(stick.y,math.min(dt,.1))
   -- Game3 0.3.51 does not dispatch input.pointer. Read the secondary
   -- button without replacing any engine callback or consuming menu input.
   local mouse=love.mouse
   if mouse and mouse.isDown(2)then
    local x,y=mouse.getPosition()
    if battleMouse then camera.mouseOrbit(x-battleMouse[1]);camera.mousePitch(y-battleMouse[2])end
    battleMouse={x,y}
   else battleMouse=nil end
  else battleMouse=nil end
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
 mod.hooks:wrap('input.wheel',function(next,game,dy)
  if not dy or dy==0 then return next(game,dy)end
  if BattleStage.active and Battle.isActive()then V.require('BattleCam').stepZoom(dy>0 and -1 or 1);return true end
  if looking(game) and M.active and controls:step(dy>0 and -1 or dy<0 and 1 or 0)then return true end
  return next(game,dy)
 end)
 mod.hooks:wrap('input.pointer',function(next,game,ev)
  if ev.source=='mouse' and looking(game) and free() then
   if ev.button==2 then
    dragging=ev.phase=='pressed';return true
   end
   if ev.phase=='moved' and dragging then controls:pointer();M.look((ev.dx or 0)*.005,(ev.dy or 0)*.004);return true end
  else dragging=false end
  return next(game,ev)
 end)
 mod.events:on('mod.options_changed',function(payload)
  if payload and payload.mod==mod.id and payload.key==Distance.setting.key then Distance.setting:sync(payload.value);Scene.invalidate()end
  if payload and payload.mod==mod.id and payload.key==BattleStage.setting.key then BattleStage.setting:sync(payload.value) end
  if payload and payload.mod==mod.id then
   for _,setting in ipairs(sharedSettings)do if payload.key==setting.key then setting:sync(payload.value);Trees.changed(payload.key)end end
   if legendary.changed(payload.key)then Scene.invalidate()end
   for _,setting in ipairs(nativeArt.settings())do if payload.key==setting.key then setting:sync(payload.value)end end
   for _,setting in ipairs({Trees.setting,Trees.art})do if payload.key==setting.key then setting:sync(payload.value);Trees.changed(payload.key)end end
  end
  if payload and payload.mod==mod.id and payload.key==mode.key then
   recovery:reset()
   mode:sync(payload.value);M.level=mode:get()
  end
 end)
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)
  FieldView.draw,Display.present,Player.update=draw,present,update
  uninstallInterface();uninstallCapture();uninstallBattle();uninstallRecap();Scene.release();return next(...)
 end)
 mod.exports.version=mod.version;mod.exports.lib=V
 mod.exports.gen3Camera=M
 mod.exports.battleTheme=V.require('BattleTheme')
 mod.exports.battlePresentation={modernUIEnabled=V.require('ModernBattleUI').enabled,
  nativeHudOwned=function()return BattleStage.active and V.require('ModernBattleUI').enabled()end}
 mod.exports.firered={camera=M,outdoor=true,battles=BattleStage,presentation='beta'}
 -- Emerald shares this entire pipeline -- the camera, the battle stage and the
 -- presentation flags are all lineage-generic -- but the namespace was named
 -- after one cart, so a companion booting on Emerald found no Gen 3 namespace
 -- and fell back to no camera. Publish the same table under every Gen 3 cart
 -- id rather than renaming: eleven test drivers reach for exports.firered.
 local gen3Namespace=mod.exports.firered
 for _,cart in ipairs{'emerald'}do mod.exports[cart]=gen3Namespace end
 -- ...and once under the durable, cart-neutral name.
 mod.exports.gen3=gen3Namespace
 print('[Battle Art FireRed] native field and battle background adapters installed')
end
return M
