-- Native substitute reader/script and actual attack/KO faint cropping.
return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 love.window.setMode(480,432,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('UiBackplates').arenaFill:sync('OFF');require('src.render.Pipelines').setLevel('voxel',4)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 local Stage=V.require('OverworldBattle');Stage.setting:setIndex(1,game)
 local settings=V.require('PokeballSettings');settings.enabled:sync(false);settings.audio:sync('ORIGINAL');V.require('BattleArt').setting:sync('rom');V.require('BattleArt').backPlacementSetting:sync('world')
 local Mon=require('src.battle.gen2.Mon')
 game.save.party={Mon.new(game.data,'CYNDAQUIL',30),Mon.new(game.data,'TOTODILE',30)}
 game.save.party[2].dvs={attack=10,defense=10,speed=10,special=10};game.save.party[2].shiny=true
 local Staged=V.require('Gen2Staged');local sideTexture=Staged.sideTexture
 local counts={faint=0,doll=0};local inside=false;local observed
 local S=require('src.ui.gen2.BattleState');local nativeDoll=S.substituteDoll
 S.substituteDoll=function(...)
  if inside then counts.doll=counts.doll+1 end
  return nativeDoll(...)
 end
 Staged.sideTexture=function(g,side)
  inside=true;local result=sideTexture(g,side);inside=false
  local screen=Staged.screenFor(g)
  if screen and screen:faintSink(side)>0 and not screen:picBoxCleared(side)then
   assert(result and Staged.drawn[side]==screen:activeMon(side),'faint returned to flat slot')
   counts.faint=counts.faint+1;observed='faint'
  end
  return result
 end
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen;local shots={}
 local function snapshot()
  if observed and not shots[observed]then shots[observed]=true;assert(U.shot(game,dir..'/'..observed..'.png'))end
 end
 for i=1,700 do
  screen=Staged.screenFor(game);snapshot()
  if screen and screen.phase=='menu'then break end
  U.tap(game,'a');U.wait(2)
 end
 assert(screen and screen.phase=='menu');assert(U.shot(game,dir..'/native-color.png'))
 local party,enemy=game.save.party,screen.battle.enemy
 local function finishAnimation()
  for i=1,1000 do
   U.wait(1);snapshot()
   if not screen.anim then return end
  end
  error('original animation did not finish')
 end
 local mon=screen:activeMon('player')
 assert(screen:animForMove('SUBSTITUTE','player',0));finishAnimation()
 local old=mon.volatile.substitute;mon.volatile.substitute=10
 U.wait(4);assert(Staged.drawn.player==mon,'substitute lost native actor identity')
 assert(U.shot(game,dir..'/doll-world.png'))
 Stage.setting:sync(false);U.wait(3)
 assert(not V.require('Gen2Battle').stagedMon(mon),'OFF retained staged ownership')
 assert(U.shot(game,dir..'/doll-off.png'))
 Stage.setting:sync(true);U.wait(30)
 mon.volatile.substitute=old;U.wait(3)
 assert(Staged.drawn.player==mon);assert(U.shot(game,dir..'/mon-restored.png'))
 -- An actual native attack/KO runs the original faint timer. The isolated
 -- fixture lowers only this wild opponent's HP; production never does so.
 enemy.hp=1
 local moveIndex
 for i,m in ipairs(screen:playerMoves())do
  local def=game.data.moves[m.id]
  if def and(tonumber(def.power)or 0)>0 then moveIndex=i;break end
 end
 assert(moveIndex,'native attacking move missing')
 for turn=1,3 do
  assert(screen.phase=='menu');assert(screen:chooseMenu('fight'));assert(screen:chooseMove(moveIndex))
  for i=1,800 do
   U.wait(1);snapshot()
   if not Staged.screenFor(game)then break end
   if screen.phase=='menu'then break end
   U.tap(game,'a')
  end
  if counts.faint>0 then break end
 end
 print('[composite counts]',counts.faint,counts.doll,enemy.hp,screen.phase)
 assert(counts.faint>0 and counts.doll>0,'native composite paths not observed')
 assert(game.save.party==party and screen.battle.enemy==enemy,'native combat identity changed')
 Staged.sideTexture=sideTexture;S.substituteDoll=nativeDoll;game.update=update
 print('[PASS native GSC world composites]',version,counts.faint,counts.doll,'native KO/substitute/OFF/restore')
 love.event.quit()
end
