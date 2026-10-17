-- Public original animation-runner integration check with a playback sink.
-- This verifies cue ownership/fallback, not optional audio timbre or full turns.
return function(game)
 local U=dofile('tests/drivers/util.lua');assert(love.filesystem.getIdentity():match('%-qa$'))
 local version=require('src.core.GameVersion').get();love.window.setMode(480,432,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game.stack:clear();assert(game:startWorld());assert(game.world:warpToMapId('ROUTE_29',10,6,'down'))
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 V.require('UiBackplates').arenaFill:sync('OFF');require('src.render.Pipelines').setLevel('voxel',4)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 local Stage=V.require('OverworldBattle');Stage.setting:setIndex(1,game)
 local settings=V.require('PokeballSettings');settings.enabled:sync(true);settings.audio:sync('EMBER')
 local Mon=require('src.battle.gen2.Mon');game.save.party={Mon.new(game.data,'CYNDAQUIL',30)}
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen
 for i=1,700 do
  screen=V.require('Gen2Staged').screenFor(game)
  if screen and screen.phase=='menu'then break end
  U.tap(game,'a');U.wait(2)
 end
 assert(screen and screen.phase=='menu'and Stage.shot().canvas,'native staged menu missing')
 local A=V.require('EmberLegacyAudio');local play,ready=A.play,A.ready
 local Sound=require('src.core.Sound');local stereo=Sound.playStereo
 local events,natives,mode={},0,'played'
 A.ready=function()return true end
 A.play=function(event,index)events[#events+1]=event..':'..tostring(index);return mode=='played'end
 Sound.playStereo=function(...)natives=natives+1;return stereo(...)end
 local random=screen.battle.random;local randoms=0
 screen.battle.random=function()randoms=randoms+1;return 255 end
 local party=game.save.party;local enemy=screen.battle.enemy;local hp=enemy.hp
 local cases={{'LOVE_BALL'},{'PARK_BALL',contest=true},{'POKE_BALL',blocked=true},{'POKE_BALL'}}
 for _,case in ipairs(cases)do
  local baseline
  for _,m in ipairs({'off','played','failed'})do
   mode=m;settings.enabled:sync(m~='off');events={};natives=0;randoms=0
   screen.contest=case.contest;screen.battle.wild=not case.blocked
   screen.ballThrow=not case.blocked and{caught=false,rate=0,wobble=0}or nil
   screen.picHidden.enemy=false
   assert(screen:startBallAnim(case.blocked and 0 or screen:ballAnimParam(case[1]),case[1]))
   local runner=assert(screen.anim);local ticks=0
   repeat screen:stepAnim(nil);ticks=ticks+1 until runner:done()or ticks>=2000
   assert(ticks<2000,'native script did not finish')
   local record={ticks=ticks,randoms=randoms,natives=natives,attempts=#events}
   if m=='off'then baseline=record;assert(#events==0 and natives>0,'OFF native sounds')
   else
    assert(ticks==baseline.ticks and randoms==baseline.randoms,'native animation/RNG changed')
    assert(#events>0,'optional cues absent: '..case[1])
    if m=='failed'then assert(natives==baseline.natives,'failed playback lost original sound')
    else assert(natives<baseline.natives,'successful playback did not suppress original')end
   end
   assert(game.save.party==party and screen.battle.enemy==enemy and enemy.hp==hp,'native combat identity changed')
   print('[capture case]',version,case[1],case.blocked and'blocked'or case.contest and'contest'or'wild',m,ticks,randoms,natives,#events)
   V.require('Gen2Capture').finish();V.require('Gen2BallAudio').finish();screen.anim=nil
  end
 end
 A.play,A.ready=play,ready;Sound.playStereo=stereo;screen.battle.random=random
 screen.contest=nil;screen.battle.wild=true;screen.ballThrow=nil;screen.picHidden.enemy=false
 settings.enabled:sync(false);game.update=update
 print('[PASS native Gen2 capture audio]',version,'12 original-script runs; OFF/success/failure, native clocks/RNG/identity')
 love.event.quit()
end
