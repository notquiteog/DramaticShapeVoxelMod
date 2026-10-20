-- Native doubles via its public organic-encounter and partner-provider APIs.
return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 love.window.setMode(640,480,{vsync=0});local focus=love.window.hasFocus;love.window.hasFocus=function()return true end
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('UiBackplates').arenaFill:sync('OFF');require('src.render.Pipelines').setLevel('voxel',4)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 V.require('OverworldBattle').setting:setIndex(1,game);V.require('PokeballSettings').enabled:sync(false)
 V.require('BattleArt').setting:sync('rom');V.require('BattleArt').backPlacementSetting:sync('world')
 game.mods.modOptions.double_battles={wild_doubles='always',gen2_doubles=true,your_side='pair',modern_hud=false}
 local D=assert(game.mods.exports.double_battles);assert(D.registerPartnerSource({id='qa-native-pair',priority=-999,provide=function()return 'PIDGEY',8 end}))
 local Mon=require('src.battle.gen2.Mon')
 game.save.party={Mon.new(game.data,'CYNDAQUIL',20),Mon.new(game.data,'TOTODILE',20)}
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 D.tagOrganic();assert(game.world:startBattle({wild=Mon.new(game.data,'SENTRET',8)}))

 local Staged=V.require('Gen2Staged');local s
 local deadline=love.timer.getTime()+30
 while love.timer.getTime()<deadline do
  s=Staged.screenFor(game);if s and s.phase=='menu'then break end;U.tap(game,'a');U.wait(2)
 end
 assert(s and s.phase=='menu'and s.battle.doubles,'native pair missing')
 local Capture=V.require('Gen2Capture');local b=s.battle;local enemy=b.enemy;local partner=b.enemy2
 local oldHp=partner.hp;partner.hp=0 -- explicit last-foe presentation prerequisite
 U.wait(3);assert(Capture.targetReady(s))
 local settings=V.require('PokeballSettings');settings.audio:sync('ORIGINAL')
 local random=b.random;local calls=0;b.random=function()calls=calls+1;return 255 end
 local Ball=V.require('Pokeball');local draw=Ball.draw;local draws,seen,shot=0,false,false
 Ball.draw=function(self,...)draws=draws+1;return draw(self,...)end
 local clocks={}
 for pass=1,2 do
  settings.enabled:sync(pass==2);s.ballThrow={caught=false,rate=0,wobble=0};s.picHidden.enemy=false
  calls=0;draws=0;seen=false;shot=false
  assert(s:startBallAnim(s:ballAnimParam('POKE_BALL'),'POKE_BALL'))
  local runner=assert(s.anim);local ticks=0
  while not runner:done()do
   U.wait(1);ticks=ticks+1;assert(ticks<1800,'native ball runner timeout')
   if Capture.active(s,s.anim)then seen=true end
   if pass==2 and draws>4 and b.dramaticShape3DBallIntake and b.dramaticShape3DBallIntake.active and not shot then game.capturePath=dir..'/last-wild-intake.png';shot=true end
  end
  clocks[pass]={ticks,calls}
  assert(pass==1 and draws==0 and not seen or pass==2 and draws>0 and seen and shot,'shared last-foe ownership')
  Capture.finish();s.anim=nil;s.ballThrow=nil;s.picHidden.enemy=false;U.wait(3)
 end
 assert(clocks[1][1]==clocks[2][1]and clocks[1][2]==clocks[2][2],'native clock/RNG changed')
 b.random=random;partner.hp=oldHp;U.wait(3)
 -- Real public item command promotes the surviving partner before native catch.
 settings.enabled:sync(true);enemy.hp=0;partner.hp=oldHp
 game.save.inventory=game.save.inventory or{};game.save.inventory.MASTER_BALL=1
 local count=#game.save.party;s:useItem('MASTER_BALL')
 assert(b.enemy==partner and s:activeMon('enemy')==partner,'native partner promotion missing')
 assert(game.save.inventory.MASTER_BALL==nil and #game.save.party==count+1 and game.save.party[#game.save.party]==partner,'native item/storage ownership changed')
 local runner=assert(s.anim);draws=0;seen=false;shot=false
 local ticks=0
 while not runner:done()do
  U.wait(1);ticks=ticks+1;if ticks%6==0 then U.tap(game,'a')end
  if ticks==1799 then U.shot(game,dir..'/timeout.png');print('[capture wait]',s.phase,s.anim==runner,s.message,s.messageTimer)end
  assert(ticks<1800,'real native catch timeout')
  if Capture.active(s,s.anim)then seen=true end
  if draws>4 and b.dramaticShape3DBallIntake and b.dramaticShape3DBallIntake.active and not shot then game.capturePath=dir..'/promoted-partner-intake.png';shot=true end
 end
 assert(seen and draws>0 and shot,'promoted native capture did not use shared prop')
 Capture.finish();assert(not Capture.active(s,s.anim));settings.enabled:sync(false)
 Ball.draw=draw;D.unregisterPartnerSource('qa-native-pair');game.update=update;love.window.hasFocus=focus
 print('[PASS native GSC last-wild capture]',version,clocks[1][1],clocks[2][1],clocks[1][2],clocks[2][2],'original scripts/RNG/OFF; real partner promotion/item/storage')
 love.event.quit()
end
