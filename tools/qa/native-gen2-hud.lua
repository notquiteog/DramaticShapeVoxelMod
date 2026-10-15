-- Isolated Gen2 profiles; native battle controls and records remain original.
return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 love.window.setMode(480,432,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local UI=V.require('UiBackplates');UI.arenaFill:sync('OFF')
 require('src.render.Pipelines').setLevel('voxel',4)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 local Stage=V.require('OverworldBattle');Stage.setting:setIndex(1,game)
 local Mode=V.require('ModernBattleUI');assert(Mode.providerEnabled(),'real Modern UI provider missing');Mode.setting:sync(false)
 local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,'CYNDAQUIL',10)}
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen
 for i=1,450 do screen=V.require('Gen2Staged').screenFor(game);if screen and screen.phase=='menu'then break end;U.tap(game,'a');U.wait(2)end
 assert(screen and screen.phase=='menu','native battle not at command');U.wait(15)
 assert(Stage.shot()and Stage.shot().canvas,'voxel stage unavailable')
 assert(game.mods.exports.BATTLE_ART_VOXEL_FORK.battlePresentation.nativeHudOwned(),'original HUD ownership not published')
 local Layer=V.require('NativeHudLayer');local draw=Layer.draw;local calls=0
 Layer.draw=function(...)calls=calls+1;return draw(...)end
 local mon=screen:activeMon('player');local hp=mon.hp
 local function shot(name,want)
  calls=0;U.wait(2);assert(U.shot(game,dir..'/'..name..'.png'))
  assert((calls>0)==want,name..': native layer ownership')
  assert(screen:activeMon('player')==mon and mon.hp==hp,'HUD changed native mon/HP')
 end
 Stage.hudScaleSetting:sync('og');UI.hudColor:sync('COLOR');shot('original-color',false)
 Stage.hudScaleSetting:sync('scaled');shot('compact-color',true)
 UI.hudColor:sync('INVERTED');shot('compact-inverted',true)
 Stage.hudScaleSetting:sync('og');shot('original-inverted',false)
 game.mods.modOptions.MODERN_POKEMON_UI=game.mods.modOptions.MODERN_POKEMON_UI or{}
 local provider=game.mods.modOptions.MODERN_POKEMON_UI;local prior=provider.modernBattleUI
 Stage.hudScaleSetting:sync('scaled');provider.modernBattleUI=false;shot('provider-off-native',false);provider.modernBattleUI=prior
 Mode.setting:sync(true);shot('modern',false);Mode.setting:sync(false)
 local priorIndex=screen.menuIndex;U.tap(game,'right');U.wait(2)
 assert(screen.menuIndex~=priorIndex,'original command navigation failed')
 Layer.draw=draw;game.update=update
 print('[PASS native Gen2 original HUD]',version,'OG/compact/COLOR/INVERTED/provider-off/modern/navigation')
 love.event.quit()
end
