-- Isolated public-driver camera review; synthetic input, not hardware certification.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local gen=V.require('Generation').number();local version=require('src.core.GameVersion').get()
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 love.window.setMode(2560,1440,{vsync=0,fullscreen=true,fullscreentype='desktop'})
 local actualFocus=love.window.hasFocus;local focused=true;love.window.hasFocus=function()return focused end
 V.require('RenderDistance').setting:sync('auto');V.require('AntiAlias').setting:sync(0);V.require('SpatialUpscale').setting:sync(1)
 local C,P,world,set,active,pose,enter,box,unbox
 if gen==3 then
  C=V.require('Gen3Integration');P=require('src.core.game3.player')
  local start=version=='firered' or version=='leafgreen';start=start and 'FR_PALLET_TOWN' or(version=='ruby'and'RU_PETALBURG_CITY'or version=='sapphire'and'SA_PETALBURG_CITY'or'EM_PETALBURG_CITY')
  game:_handleBootAction({action='new_game',start={map=start,x=10,y=12,facing='up'}})
  local sp=require('src.core.game3.scripting.space');sp.runOnFrame=function()end
  local vm=sp.getVm();if vm then vm:halt(true)end
  require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
  set=function(n)C.setLevel(n,game)end;active=function()return C.active end
  pose=function()return C end
  box=function()require('src.ui.game3.message').show('Camera review: movement remains native.')end
  unbox=function()require('src.ui.game3.message').reset()end
 else
  local pipes=require('src.render.Pipelines');C=V.require('FirstPerson')
  game.stack:clear()
  if gen==2 then
   world=game.world;world.noWildEncounters=true;world.trySceneScript=function()return false end
   assert(world:setMap('NEW_BARK_TOWN',7,5,'down'));world.vm=nil;world.textbox=nil;world.stayedTextBox=nil
  else game.stack:push(require('src.world.OverworldController'),'PALLET_TOWN',8,9,'down');world=game.overworld end
  P=world.player
  set=function(n)pipes.setLevel('voxel',n)end
  active=function()return V.require('VoxelState').active() and V.require('Voxel3D').available()end
  pose=function()return C end
  box=function()game.stack:push(require('src.render.TextBox').new(game,'Camera review: movement remains native.'))end
  unbox=function()if game.stack:top()~=world then game.stack:pop()end end
 end
 for _,level in ipairs({3,1,2,4,5,6,7})do
  set(level);U.wait(level==3 and 200 or 70)
  assert(active(),'camera unavailable '..level)
  if level>=6 then
   local before=pose().yaw
   game:gamepadaxis(nil,'rightx',.7);U.wait(12);game:gamepadaxis(nil,'rightx',0)
   assert(math.abs(pose().yaw-before)>.001,'right stick failed '..level)
   local rig=V.require('Voxel3D').camera;assert(rig,'placed camera missing '..level)
   assert(rig.eye[1]==rig.eye[1] and rig.eye[2]==rig.eye[2],'nonfinite camera')
   if level==7 then
    box();U.wait(3);before=pose().yaw
    game:gamepadaxis(nil,'rightx',.7);U.wait(8);game:gamepadaxis(nil,'rightx',0)
    assert(math.abs(pose().yaw-before)>.001,'dialogue took look');unbox();U.wait(5)
   end
  end
  if level==1 or level==3 or level>=6 then assert(U.shot(game,os.getenv('SHOT_DIR')..'/mode-'..level..'.png'))end
  print('[camera mode]',version,level,'PASS')
 end
 -- Actual public input events exercise disconnect handling without physical
 -- hardware; one source cannot keep spinning after its connection is lost.
 local connected=true;local controller={isConnected=function()return connected end}
 game:gamepadaxis(controller,'rightx',1);U.wait(3);connected=false;U.wait(2)
 local before=pose().yaw;U.wait(10);assert(pose().yaw==before,'disconnected controller kept turning')
 game:gamepadaxis(nil,'rightx',1);U.wait(2);focused=false;U.wait(2)
 before=pose().yaw;U.wait(10);assert(pose().yaw==before,'background camera kept turning');focused=true
 if gen==3 then
  local getTouches,getPosition=love.touch.getTouches,love.touch.getPosition
  local points={};love.touch.getTouches=function()local a={};for id in pairs(points)do a[#a+1]=id end;return a end
  love.touch.getPosition=function(id)return points[id][1],points[id][2]end
  points.qa={1280,300};U.wait(2);before=C.yaw;points.qa={1380,320};U.wait(2)
  assert(math.abs(C.yaw-before)>.01,'Gen3 public touch polling failed')
  points.zoom={1600,320};U.wait(2);local zoom=C.boomZoom;points.zoom={1800,320};U.wait(10)
  assert(C.boomZoom<zoom,'Gen3 pinch did not zoom in')
  points={};U.wait(2);love.touch.getTouches,love.touch.getPosition=getTouches,getPosition
 end
 set(0);U.wait(90);assert(not active(),'OFF did not restore native rendering')
 love.window.hasFocus=actualFocus
 print('[camera verification] PASS',version,'all modes, dialogue, input lifetime, OFF');love.event.quit()
end
