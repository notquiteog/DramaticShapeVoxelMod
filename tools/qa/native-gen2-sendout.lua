-- Calls original send-out presentation on an isolated native wild encounter.
return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local dir=assert(os.getenv('SHOT_DIR'));local version=require('src.core.GameVersion').get()
 love.window.setMode(480,432,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('UiBackplates').arenaFill:sync('OFF');require('src.render.Pipelines').setLevel('voxel',4)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 V.require('OverworldBattle').setting:setIndex(1,game)
 local settings=V.require('PokeballSettings');settings.enabled:sync(false);settings.audio:sync('ORIGINAL')
 V.require('BattleArt').setting:sync('rom');V.require('BattleArt').backPlacementSetting:sync('world')
 local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,'CYNDAQUIL',30)}
 local mon=game.save.party[1];mon.shiny=true;mon.dvs={attack=10,defense=10,speed=10,special=10}
 local Staged=V.require('Gen2Staged');local Q=V.require('q57/Adapter');local prepare=Q.prepare
 local entries,seen={},{};local off=true;local count=0
 Q.prepare=function(b,a,g,n,e)
  local result=prepare(b,a,g,n,e)
  for side,p in pairs(b.legendaryQ57 or{})do
   if p.entry then
    assert(not off,'OFF emitted release');assert(side=='player','wild enemy release')
    entries[side]=p.entry;seen[p.entry.started]=true;count=count+1
   end
  end
  return result
 end
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen
 for i=1,700 do screen=Staged.screenFor(game);if screen and screen.phase=='menu'then break end;U.tap(game,'a');U.wait(2)end
 assert(screen and screen.phase=='menu');local hp=mon.hp;local core=screen.battle
 local function run(active,label)
  off=not active;settings.enabled:sync(active);entries={};seen={};count=0
  U.wait(5);assert(screen:startSendOut('player',mon));local frames=0;local shot=false;local normalShot=false;local runners={}
  while screen.afterSendOut do
   frames=frames+1;runners[screen.anim]=true;U.wait(1)
   if active and entries.player and screen.anim and screen.anim.param==0 and entries.player.age>.02 and not normalShot then
    normalShot=true;assert(U.shot(game,dir..'/'..label..'-normal.png'))
   end
   if active and entries.player and entries.player.age>.16 and not shot then
    shot=true;assert(U.shot(game,dir..'/'..label..'.png'))
   end
   assert(frames<500,'native sendout stuck')
  end
  if active then
   assert(count>0 and shot,'shared release absent');local n=0;for _ in pairs(seen)do n=n+1 end
   assert(n==1,'shiny arm duplicated release')
  else assert(count==0)end
  local nativeFrames=0;for runner in pairs(runners)do nativeFrames=nativeFrames+runner.frames end
  U.wait(100);return nativeFrames
 end
 local original=run(false,'off');local shared=run(true,'release');assert(original==shared,'native frame count changed')
 assert(screen:startSendOut('player',mon));U.wait(5);assert(screen.afterSendOut)
 screen:stepAnim({wasPressed=function(_,key)return key=='b'end});U.wait(2)
 assert(not screen.afterSendOut and not next(screen.legendaryQ57 or{}),'native cancellation retained release')
 settings.enabled:sync(false);off=true;U.wait(5)
 assert(not next(screen.legendaryQ57 or{}),'OFF left release pose')
 assert(screen.battle==core and core.player==mon and mon.hp==hp,'native combat identity/HP changed')
 assert(U.shot(game,dir..'/restored-off.png'))
 Q.prepare=prepare;game.update=update
 print('[PASS native GSC Legendary release]',version,'frames',original,shared,'identity/shiny/cancel/OFF')
 love.event.quit()
end
