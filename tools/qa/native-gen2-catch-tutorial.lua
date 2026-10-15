-- Run the original DUDE auto-input/menu/pack/catch sequence on an isolated save.
return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 local enabled=os.getenv('CAPTURE_OFF')~='1';love.window.setMode(480,432,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('UiBackplates').arenaFill:sync('OFF');require('src.render.Pipelines').setLevel('voxel',4)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 V.require('OverworldBattle').setting:setIndex(1,game)
 V.require('PokeballSettings').enabled:sync(enabled)
 local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,'CYNDAQUIL',10)}
 game.save.inventory={POKE_BALL=7,POTION=3};game.save.player.name='PARITY';game.options.textSpeed='FAST'
 local party,inventory=game.save.party,game.save.inventory
 local dex=game.save.pokedex;local caughtBefore=dex and dex.caught and dex.caught.RATTATA
 local scene=V.require('BattleScene');local start,event,caught,finish=scene.startNormalBall,scene.normalBallAnimEvent,scene.normalBallCaughtEvent,scene.finishNormalBattleBall
 local starts,poofs,catches,finishes=0,0,0,0
 scene.startNormalBall=function(id,...)
  assert(id=='POKE_BALL');starts=starts+1;return start(id,...)
 end
 scene.normalBallAnimEvent=function(id,...)
  if id=='POOF_ANIM'then poofs=poofs+1 end;return event(id,...)
 end
 scene.normalBallCaughtEvent=function(...)catches=catches+1;return caught(...)end
 scene.finishNormalBattleBall=function(...)finishes=finishes+1;return finish(...)end
 local S=require('src.ui.gen2.BattleState');local nativeStart=S.startBallAnim;local nativeThrows=0
 S.startBallAnim=function(self,...)
  nativeThrows=nativeThrows+1;assert(self.tutorial and self.showPlayerTrainer and not self.battle.player,'tutorial identity changed')
  return nativeStart(self,...)
 end
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 local done=false;local T=require('src.core.gen2.CatchTutorial')
 assert(game.autoInput:start(T.BATTLE_STREAM,game.input))
 assert(game.world:startCatchTutorial({species=assert(game.data.pokemon.RATTATA.index),level=5},T.BATTLETYPE_TUTORIAL,function()done=true end))
 local snap=false;local screen
 for i=1,2400 do
  screen=V.require('Gen2Staged').screenFor(game)
  if not snap and((enabled and poofs>0)or(not enabled and nativeThrows>0))then
   U.wait(3);assert(U.shot(game,dir..'/capture.png'));snap=true
  end
  if done then break end
  U.wait(1)
 end
 assert(done,'native tutorial did not finish: '..tostring(screen and screen.phase))
 game.autoInput:stop(game.input);U.wait(90)
 assert(nativeThrows==1 and snap,'missing native throw')
 assert((enabled and starts==1 and poofs>=1 and catches==1)or(not enabled and starts==0 and poofs==0 and catches==0),'capture ownership')
 assert(game.save.party==party and #party==1 and game.save.inventory==inventory and inventory.POKE_BALL==7 and inventory.POTION==3,'tutorial changed real party/bag')
 assert(game.save.player.name=='PARITY'and game.options.textSpeed=='FAST','native temporary state not restored')
 assert((game.save.pokedex and game.save.pokedex.caught and game.save.pokedex.caught.RATTATA)==caughtBefore,'tutorial caught dex record')
 assert(not V.require('Gen2Staged').screenFor(game),'native tutorial screen remained')
 assert(U.shot(game,dir..'/returned.png'))
 scene.startNormalBall,scene.normalBallAnimEvent,scene.normalBallCaughtEvent,scene.finishNormalBattleBall=start,event,caught,finish
 S.startBallAnim=nativeStart;game.update=update
 print('[PASS native Gen2 tutorial capture]',version,enabled,starts,poofs,catches,finishes,'native auto-input/pack/throw/restoration')
 love.event.quit()
end
