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
 D.unregisterPartnerSource('qa-native-pair');game.update=update;love.window.hasFocus=focus
 print('[PASS native GSC pair identity]',version,'four actors/public provider/queued partner preserved')
 love.event.quit()
end
