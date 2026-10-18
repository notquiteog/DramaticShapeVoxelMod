-- Original GSC animation scripts and public hidden/palette/frame readers.
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
 local counts={hidden=0,resize=0,frame=0,palette=0};local observed;local inside=false
 local Palette=require('src.render.GbcPalette');local with=Palette.with
 Palette.with=function(...)if inside then counts.palette=counts.palette+1 end;return with(...)end
 local S=require('src.ui.gen2.BattleState');local frame=S.frontAnimFrame
 S.frontAnimFrame=function(...)
  local image,quad,size=frame(...)
  if inside and quad then counts.frame=counts.frame+1 end
  return image,quad,size
 end
 Staged.sideTexture=function(g,side)
  inside=true;local result=sideTexture(g,side);inside=false
  local s=Staged.screenFor(g)
  if s and s:activeMon(side)then
   if s:picBoxCleared(side)then assert(not result and Staged.drawn[side]==nil,'hidden native actor remained in world');counts.hidden=counts.hidden+1;observed='hidden'
   else
    local p=s:animPicState(side)
    if result and p and p.size~=nil then counts.resize=counts.resize+1;observed='resize'end
   end
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
 assert(screen:startSendOut('enemy',enemy));finishAnimation();U.wait(80)
 -- Native command-script entry, not a complete two-turn move simulation.
 assert(screen:animForMove('FLY','player',0));finishAnimation()
 screen.picHidden.player=false;screen.picHidden.enemy=false;screen.vanishAnim=nil
 -- Public volatile-state reader must hide the airborne actor after its script.
 local mon=screen:activeMon('player');local volatile=screen.battle:volatile(mon)
 local before,seen=volatile.vanished,screen.vanishSeen.player;volatile.vanished=true;screen.vanishSeen.player=true
 U.wait(2);assert(Staged.sideTexture(game,'player')==nil,'airborne world actor remained');assert(U.shot(game,dir..'/airborne.png'))
 volatile.vanished=before;screen.vanishSeen.player=seen;U.wait(3);assert(Staged.sideTexture(game,'player'),'native return stayed hidden')
 assert(U.shot(game,dir..'/restored.png'))
 print('[counts]',counts.hidden,counts.resize,counts.palette,counts.frame,V.crystalSpritesActive);assert(counts.hidden>0 and counts.resize>0 and counts.palette>0,'native state/palette coverage')
 if version=='crystal'then assert(counts.frame>0,'native Crystal frame reader absent')end
 assert(game.save.party==party and screen.battle.enemy==enemy,'native combat identity changed')
 Staged.sideTexture=sideTexture;S.frontAnimFrame=frame;Palette.with=with;game.update=update
 print('[PASS native GSC staged effects]',version,counts.hidden,counts.resize,counts.palette,counts.frame,'native scripts/visibility/palettes/return')
 love.event.quit()
end
