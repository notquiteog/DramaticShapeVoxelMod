return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local update=game.update
 game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local gen=V.require('Generation').number();love.window.setMode(1280,720)
 assert(gen==2 or gen==3)
 local player,ground
 if gen==3 then
  game:_handleBootAction({action='new_game',start={map='FR_MT_EMBER_EXTERIOR',x=29,y=32,facing='up'}})
  require('src.ui.game3.map_preview_screen').reset();V.require('Gen3Integration').setLevel(3,game)
  player=require('src.core.game3.player');ground=function()return V.require('Gen3Scene').groundAt(player.px+8,player.py+16-.001)end
 else
  local w=game.world;w.noWildEncounters=true;w.trySceneScript=function()return false end
  game.stack:clear();assert(w:setMap('DANCE_THEATER',1,5,'up'));w.vm=nil;w.textbox=nil
  require('src.render.Pipelines').setLevel('voxel',3);player=w.player
  ground=function()return V.require('VoxelScene').groundAt(w.map,player.cellX,player.cellY,player.px,player.py)end
 end
 U.wait(160);local low=ground();local startY=player.py;local maxStep=0;local last=low
 for i=1,55 do
  U.hold(game,'up',1);local h=ground();maxStep=math.max(maxStep,math.abs(h-last));last=h
 end
 game.input:reset();U.wait(18);local high=ground()
 print('[elevation walk]',gen,startY,player.py,low,high,'max delta',maxStep)
 assert(player.py<startY and high>low,'did not walk onto the higher floor')
 assert(maxStep<=1.51,'contact snapped instead of following treads')
 U.shot(game,os.getenv('SHOT_DIR')..'/upper-floor.png')
 if gen==3 then
  local C=V.require('Gen3Integration');C.setLevel(6,game);C.yaw=0;C.pitch=0;U.wait(24)
  local R=V.require('Voxel3D');local eye=V.require('Gen3SpriteAnchor').eyeHeight(require('src.core.game3.ow_sprites').getDraw(require('src.core.game3.ow_sprites').playerGraphicsId(game)))
  assert(math.abs(R.camera.eye[2]-high-eye)<.01,'camera did not follow raised floor')
  print('[elevation camera]',R.camera.eye[2],high,eye)
 else require('src.render.Pipelines').setLevel('voxel',6);U.wait(40)end
 U.shot(game,os.getenv('SHOT_DIR')..'/upper-first.png');love.event.quit()
end
