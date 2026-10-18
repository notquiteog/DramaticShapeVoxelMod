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
 for i=1,1000 do s=Staged.screenFor(game);if s and s.phase=='menu'then break end;U.tap(game,'a');U.wait(2)end
 assert(s and s.phase=='menu'and s.battle.doubles and s.battle.enemy2 and s.battle.player2,'native pair unavailable')
 U.wait(5)
 for _,slot in ipairs({'player','player2','enemy','enemy2'})do assert(Staged.drawn[slot]==s:activeMon(slot),'wrong native actor '..slot)end
 assert(U.shot(game,dir..'/native-pairs.png'))
 local b=s.battle;local outgoing=s:activeMon('enemy2');local replacement=Mon.new(game.data,'HOOTHOOT',8)
 local shown=s.shownMon.enemy2
 s.shownMon.enemy2=outgoing;b.enemy2=replacement -- explicit queue/core timing mismatch fixture
 U.wait(3)
 assert(s:activeMon('enemy2')==outgoing and Staged.drawn.enemy2==outgoing,'core replacement stole native shown partner')
 assert(U.shot(game,dir..'/shown-partner.png'))
 s.shownMon.enemy2=shown;b.enemy2=outgoing;U.wait(3)
 assert(Staged.drawn.enemy2==s:activeMon('enemy2'))
 if os.getenv('QA_PAIR_STATES')=='1'then
  local Stage=V.require('OverworldBattle');local mons={};local hp={}
  for _,slot in ipairs({'player','player2','enemy','enemy2'})do mons[slot]=s:activeMon(slot);hp[slot]=mons[slot].hp end
  for _,slot in ipairs({'player2','enemy2'})do
   local mon=mons[slot];local volatile=mon.volatile
   mon.volatile={substitute=10};U.wait(3)
   assert(Staged.drawn[slot]==mon and Staged.drawn[slot:gsub('2$','')]==mons[slot:gsub('2$','')])
   assert(U.shot(game,dir..'/doll-'..slot..'.png'));mon.volatile=volatile
   local hidden=s.picHidden[slot];s.picHidden[slot]=true;U.wait(3)
   assert(Staged.drawn[slot]==mon,'hidden partner lost its owned transparent slot')
   assert(U.shot(game,dir..'/hidden-'..slot..'.png'));s.picHidden[slot]=hidden
   local clocks={};local playerHud,enemyHud=s.showPlayerHud,s.showEnemyHud
   for pass=1,2 do
    Stage.setting:sync(pass==2);s.picHidden[slot]=false
    s.faintSlide={side=slot,frames=0} -- explicit presentation overlap; no gameplay KO
    local frames=0;local captured=false
    while s.faintSlide do
     U.wait(1);frames=frames+1;assert(frames<80,'native faint did not finish')
     if pass==2 and s:faintSink(slot)>0 and not captured then
      assert(Staged.drawn[slot]==mon,'faint crop lost partner identity')
      game.capturePath=dir..'/faint-'..slot..'.png';captured=true
     end
    end
    clocks[pass]=frames;if pass==2 then assert(captured)end
    s.picHidden[slot]=hidden;s.showPlayerHud=playerHud;s.showEnemyHud=enemyHud;s.phase='menu';U.wait(2)
   end
   assert(clocks[1]==clocks[2],'native paired faint clock changed')
   print('[pair faint frames]',slot,clocks[1],clocks[2])
  end
  for slot,mon in pairs(mons)do assert(s:activeMon(slot)==mon and mon.hp==hp[slot],'pair fixture changed identity/HP')end
  U.wait(3);assert(U.shot(game,dir..'/states-restored.png'))
 end
 D.unregisterPartnerSource('qa-native-pair');game.update=update;love.window.hasFocus=focus
 print('[PASS native GSC pair identity]',version,'four actors/public provider/queued partner preserved')
 love.event.quit()
end
