-- FireRed's native display bypasses Pipelines. Adapt its ordinary FieldView
-- method, leaving the engine's world/UI passes, battle renderer and callbacks
-- in charge. This file is deliberately loaded before any Gen1/2 patches.
local V=...
local M={yaw=0,pitch=math.rad(10),level=3,rendered=0,active=false}
local Look=V.require('CameraLook')
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
 M.yaw=(M.yaw+dx)%(math.pi*2);M.pitch=math.max(Look.UP,math.min(Look.DOWN,M.pitch+dy))
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
 -- Native artwork remains the default in newly supported editions; saved
 -- upstream BUILDING STYLE values still win through the shared setting.
 V.require('CommunityVisuals').buildings.defaultIndex=1
 V.require("KfpAtmosphere").install(function()return (M.level or 0)>0 end)
 local mod=V.mod
 V.require("Gen3CacheMenu").install()
 local FieldView=require('src.core.game3.field_view')
 local Display=require('src.core.game3.display')
 local Player=require('src.core.game3.player')
 local Battle=require('src.core.game3.battle')
 local Tilt=require('src.render.Tilt')
 local Scene=V.require('Gen3Scene')
 local SceneOptions=V.require('Gen3SceneOptions')
 local BattleStage=V.require('Gen3Battle')
 local controls=V.require('Gen3CameraControls').new(M)
 local touch=V.require('CameraTouch').new()
 local game3Ok,game3=pcall(require,'src.core.Game3')
 local platOk,platMod=pcall(require,'src.core.Platform')
 local gcHeadroom=V.require('SceneGcHeadroom').new(game3Ok and type(game3)=='table' and game3 or {},platOk and type(platMod)=='table' and platMod.detect and platMod.detect()or nil)
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)gcHeadroom:dispose();return next(...)end)
 local legendary=V.require('LegendaryVisualsPreset')
 local uninstallBattle=BattleStage.install()
 local uninstallCapture=V.require("Gen3Capture").install()
 local ballAudio=V.require("NativeGen3BallAudio")
 local uninstallBallAudio=ballAudio.install()
 V.require('KantoLifeAudio').install(mod)
 V.require('NativeCaveAudio').install(3,function()return M.level~=0 end)
 local draw,present,update=FieldView.draw,Display.present,Player.update
 local nativeWalk=V.require('NativeFreeMove')
 local walkPhase=Player.walkPhase
 Player.walkPhase=function()return nativeWalk.phase(Player)or walkPhase()end
 local function ready(game)return recovery:ready(Scene.context and Scene.context()or game.session)end
 mode:read();M.level=mode:get();local schema=mod.options:define({Distance.setting:schema('Scenery distance: AUTO adapts to the platform; FULL includes the loaded connected maps. Distant scenery fades into the sky.'),BattleStage.setting:schema('Native battle sprites and attacks over the 2.5D field. Disable to use the original battle background.'),Trees.art:schema('Solid voxel trees carved from the original game art (default), original flat cards, or illustrated cards.'),Trees.setting:schema('For card trees: flat trunks follow the crown, or use modeled trunks. Original model trees are fully solid.'),mode:schema('Gen 3 2.5D camera. Press 3 to cycle; Look with the right stick, a right-mouse drag or a touch drag in 1ST/rotating 3RD. Pinch to zoom 3RD; native field effects retain their original presentation.')})
 local fullPreset=V.require('Gen3FullPreset').new(M.level)
 local nativeArt=V.require('NativeBattleArt');nativeArt.install()
 local interfaceArt=V.require('NativeInterfaceArt')
 interfaceArt.crystal=V.require('NativeCrystalArt')
 local uninstallCrystalField=V.require('NativeCrystalField').install()
 mod.hooks:wrap('core.quit_to_launcher',function(next,...)uninstallCrystalField();return next(...)end)
 local uninstallInterface=interfaceArt.install()
 local uninstallShiny=V.require('NativeCrystalShiny').install()
 local sharedSettings={V.require('ItemPokeballs').setting,V.require('CommunityVisuals').trees,V.require('CommunityVisuals').casino,V.require('CommunityVisuals').courtyards,V.require('CommunityVisuals').prizeRoom,V.require('RamPrecache').setting,V.require('CommunityVisuals').buildings,V.require('CommunityVisuals').tunnels,V.require('CommunityVisuals').cityGround,V.require('CommunityVisuals').walls,V.require('CommunityVisuals').masonry,V.require('StandingTrainer').setting,V.require('CommunityVisuals').pillars,V.require('CommunityVisuals').roads,V.require('CommunityVisuals').rocket,V.require('CommunityVisuals').elevator,V.require('CommunityVisuals').cutTrees,V.require('CommunityVisuals').towerWall,V.require('CommunityVisuals').signs,V.require('CommunityVisuals').safari,V.require('CommunityVisuals').grass,legendary.setting,Trees.props,Trees.surfaces,V.require('ModernBattleUI').setting,V.require('CommunityVisuals').treeDetail,V.require('CommunityVisuals').caveSound,V.require('CommunityVisuals').kantoLife,
  V.require('Shadows').setting,V.require('WorldCurve').setting,V.require('VoxelGrid').setting}
 for _,setting in ipairs(V.require("Gen3Capture").settings())do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require("NativeAtmosphere").settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(SceneOptions.settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(interfaceArt.settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require('Gen3BattleOptions').settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(V.require('Gen3BattleBackdrop').settings)do sharedSettings[#sharedSettings+1]=setting end
 for _,setting in ipairs(sharedSettings)do
  schema[#schema+1]=setting:schema(setting.key=='movementMode' and V.require('MovementMode').description or setting.key=='spatialUpscale' and V.require('SpatialUpscale').description or 'Shared renderer option; applies immediately to the native Gen 3 presentation.')
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
 local stackOk,nativeStack=pcall(require,'src.ui.game3.stack')
 local function menuOpen()
  -- Public native stack also covers Ruby/Sapphire and extension menus; engine
  -- modules are not guaranteed to appear in the mod sandbox package cache.
  if stackOk and nativeStack.top then
   local top=nativeStack.top()
   if top and top.isMenu then return true end
  end
  for _,name in ipairs({'start_menu','option_menu','controls_menu','bag_menu','party_menu','summary_menu','pokedex','pc_menu','shop_menu'})do
   for _,prefix in ipairs({'src.ui.game3.','src.ui.game3.rse.','src.ui.game3.rs.'})do
    local menu=package.loaded[prefix..name]
    if menu and menu.isOpen and menu.isOpen()then return true end
   end
  end
  return false
 end
 local function looking(game)
  return Look.focused(love.window) and not menuOpen() and(field(game) or game and game.phase=='quest_log')
 end
 local function battleLooking()
  return BattleStage.active and Battle.isActive() and Look.focused(love.window) and not menuOpen()
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
  local enabled=M.active and free() and field(game) and ready(game) and not Scene.nativeRequired(game)
  if enabled and input and input.isDown and V.require('MovementMode').free()then
   local right,forward=nativeWalk.intent(input)
   local x,z=M.moveVector(forward,right)
   if nativeWalk.gen3(game,input,Player,update,x,z)then return end
  else nativeWalk.drop(Player,true)end
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
  if not bound and looking(game) and M.level==7 and (ev.key=='q' or ev.key=='e')then
   if ev.phase=='pressed'then controls:step(ev.key=='q' and 1 or -1)end
   return true
  end
  if V.require('Gen3Hotkeys').handle(game,ev,M,SceneOptions,BattleStage,looking(game),field(game))then return true end
  return next(game,ev)
 end)
 local stick={x=0,y=0}
 local battleMouse
 -- Whether a camera reads the right stick right now: a free-camera rung
 -- (1ST look / 3RD boom) or a steerable staged battle lens. While claimed,
 -- the axis never reaches the engine's own translation -- 0.3.73 maps
 -- rightstick_* onto up/down/left/right (Input.STICK_DEFAULT_BINDINGS), so
 -- unclaimed a throw would turn the camera AND walk the player. The stick
 -- is camera-only; with the rungs off and no staged lens the engine's new
 -- twin-stick walk is preserved untouched.
 local function stickClaimed(game)
  if free() and looking(game)then return true end
  return BattleStage.active and Battle.isActive()
 end
 mod.hooks:wrap('input.gamepad',function(next,game,ev)
  if ev.phase=='axis' then
   if ev.axis=='rightx' or ev.axis=='righty'then stick.controller=ev.joystick end
   if ev.axis=='rightx'then stick.x=tonumber(ev.value)or 0 elseif ev.axis=='righty'then stick.y=tonumber(ev.value)or 0 end
   if (ev.axis=='rightx' or ev.axis=='righty') and stickClaimed(game) then
    return true
   end
  elseif ev.phase=='pressed' and looking(game) and M.level==7 and (ev.button=='leftstick' or ev.button=='rightstick')then
   controls:step(ev.button=='leftstick' and 1 or -1);return true
  elseif ev.phase=='removed'then stick.x,stick.y=0,0 end
  return next(game,ev)
 end)
 mod.hooks:wrap('core.update',function(next,game,dt,...)
  M.cameraDelta=math.max(0,math.min(.1,tonumber(dt)or 0))
  gcHeadroom:update(M.level~=0)
  recovery:update(dt)
  BattleStage.update()
  ballAudio.update()
  legendary.migrate(game)
  fullPreset:update(M.level,game)
  SceneOptions.update(dt)
  -- Native fly/teleport/flash presentations temporarily own drawing, not the
  -- chosen look direction. Continue mouse/boom input so returning to the
  -- voxel field resumes exactly where the player aimed. Menus still own input.
  Look.resetLost(stick,love.window)
  local canLook=looking(game) and free()
  controls:update(dt,canLook,love.mouse)
  local battleLook=battleLooking()
  local touchMode=battleLook and 'battle' or canLook and M.level or nil
  local width,height=1280,720
  if love.graphics and love.graphics.getDimensions then width,height=love.graphics.getDimensions()end
  local battleCam=battleLook and V.require('BattleCam')
  touch:update(love.touch,game.touchControls,touchMode,width,height,
   function(x,y)
    if battleCam then battleCam.dragOrbit(x);battleCam.dragPitch(-y)
    else M.look(x*Look.TOUCH,y*height/math.max(320,width)*Look.TOUCH)end
   end,
   (battleLook or canLook and M.level==7) and function(factor)
    if battleCam then battleCam.stepZoom(math.log(1/factor)/math.log(battleCam.ZOOM_STEP))
    else controls:scale(1/factor)end
   end or nil)
  if battleLook then
   local camera=V.require('BattleCam')
   camera.stickOrbit(stick.x,math.min(dt,.1));camera.stickPitch(-stick.y,math.min(dt,.1))
   -- Game3 0.3.51 does not dispatch input.pointer. Read the secondary
   -- button without replacing any engine callback or consuming menu input.
   local mouse=love.mouse
   if Look.focused(love.window) and mouse and mouse.isDown(2)then
    local x,y=mouse.getPosition()
    if battleMouse then camera.mouseOrbit(math.max(-40,math.min(40,x-battleMouse[1])));camera.mousePitch(math.max(-40,math.min(40,y-battleMouse[2])))end
    battleMouse={x,y}
   else battleMouse=nil end
  else battleMouse=nil end
  if looking(game) and free() then
   local elapsed=math.min(tonumber(dt)or 0,.1)
   M.look(Look.axis(stick.x)*elapsed*Look.YAW,Look.axis(stick.y)*elapsed*Look.PITCH)
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
  if battleLooking()then V.require('BattleCam').stepZoom(dy>0 and -1 or 1);return true end
  if looking(game) and free() and controls:step(dy>0 and -1 or dy<0 and 1 or 0)then return true end
  return next(game,dy)
 end)
 mod.hooks:wrap('input.pointer',function(next,game,ev)
  if ev.source=='mouse' and looking(game) and free() then
   if ev.button==2 then
    dragging=ev.phase=='pressed';return true
   end
   if ev.phase=='moved' and dragging then controls:pointer();M.look(math.max(-40,math.min(40,ev.dx or 0))*Look.MOUSE,math.max(-40,math.min(40,ev.dy or 0))*Look.MOUSE);return true end
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
  nativeWalk.drop(Player,true)
  FieldView.draw,Display.present,Player.update,Player.walkPhase=draw,present,update,walkPhase
  uninstallShiny();uninstallInterface();uninstallBallAudio();uninstallCapture();uninstallBattle();uninstallRecap();Scene.release();return next(...)
 end)
 mod.exports.version=mod.version;mod.exports.lib=V
 mod.exports.performance=V.require("PerformanceExport").export(mod.exports.version)
 mod.exports.gen3Camera=M
 mod.exports.battleTheme=V.require('BattleTheme')
 mod.exports.battlePresentation={modernUIEnabled=V.require('ModernBattleUI').enabled,
  nativeHudOwned=function()return BattleStage.active and V.require('ModernBattleUI').providerEnabled()end}
 mod.exports.firered={camera=M,outdoor=true,battles=BattleStage,presentation='beta'}
 -- Emerald shares this entire pipeline -- the camera, the battle stage and the
 -- presentation flags are all lineage-generic -- but the namespace was named
 -- after one cart, so a companion booting on Emerald found no Gen 3 namespace
 -- and fell back to no camera. Publish the same table under every Gen 3 cart
 -- id rather than renaming: eleven test drivers reach for exports.firered.
 local gen3Namespace=mod.exports.firered
 for _,cart in ipairs{'leafgreen','ruby','sapphire','emerald'}do mod.exports[cart]=gen3Namespace end
 -- ...and once under the durable, cart-neutral name.
 mod.exports.gen3=gen3Namespace
 gen3Namespace.scenery={apiVersion=1,registerTilesetAlias=function(pair,target)
  local dispose,err=V.require('Gen3Tilesets').registerAlias(pair,target)
  if not dispose then return nil,err end
  V.require('Gen3Scene').invalidate()
  return function()
   local removed=dispose()
   if removed then V.require('Gen3Scene').invalidate() end
   return removed
  end
 end}
 print('[Battle Art FireRed] native field and battle background adapters installed')
end
return M
