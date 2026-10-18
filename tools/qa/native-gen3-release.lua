-- Isolated original send-out presentation; no gameplay switch is synthesized.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();love.window.setMode(480,320,{vsync=0})
 local actualFocus=love.window.hasFocus;love.window.hasFocus=function()return true end -- deterministic foreground fixture
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(3,game)
 V.require('Gen3Battle').setting:sync(true);V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 local settings=V.require('PokeballSettings');settings.enabled:sync(true);settings.audio:sync('ORIGINAL')
 game.session.party={};local Party=require('src.core.game3.party')
 assert(Party.giveMon(game.session,6,35));assert(Party.giveMon(game.session,9,35));game.session.party[2].isShiny=true
 local Release=V.require('NativeGen3Release');local draw,subject=Release.draw,Release.subject
 local off=true;local volumes,subjects=0,0;local captured=false;local peak=false
 Release.draw=function(frame)
  local result=draw(frame)
  if result then
   assert(not off,'OFF emitted volume');volumes=volumes+1
   if not captured then game.capturePath=dir..'/release.png';captured=true
   elseif not peak and frame.releasePose.pose.timer>.5 and not game.capturePath then
    game.capturePath=dir..'/release-peak.png';peak=true
   end
  end
  return result
 end
 Release.subject=function(frame,card,mesh)
  local result=subject(frame,card,mesh)
  if result then assert(not off,'OFF emitted subject material');subjects=subjects+1 end
  return result
 end
 U.wait(75)
 local B=require('src.core.game3.battle');local Anim=require('src.core.game3.battle.anim')
 settings.enabled:sync(false)
 B.start({playerParty=game.session.party,foe={species=19,level=3},wild=true,session=game.session,playerName=game.session.name or'QA'})
 for i=1,1200 do if B._phase=='command'then break end;U.tap(game,'a');U.wait(2)end
 assert(B._phase=='command','native command not reached: '..tostring(B._phase));local st=B._st;local player=st.player;local hp=player.mon.hp
 local function run(active)
  off=not active;settings.enabled:sync(active);U.wait(3)
  local p=Anim.present(0);p.visible=false
  local done=false;local frames=0;Anim.sendOutMon(0,{onComplete=function()done=true end})
  while not done do U.wait(1);frames=frames+1;assert(frames<100)end
  assert(p.visible and p.scale==1,'native reveal did not complete');
  local Open=require('src.core.game3.battle.ball_open')
  for i=1,300 do if not Open.active()then break end;U.wait(1)end
  assert(not Open.active(),'native particles/fade failed to settle')
  return frames
 end
 local original=run(false);local shared=run(true)
 assert(original==shared,'native reveal duration changed')
 assert(volumes>0 and subjects>0 and captured,'shared native material absent')
 local f=assert(io.open(dir..'/release.png','rb'));f:close()
 settings.enabled:sync(false);off=true;U.wait(3)
 assert(not V.require('Gen3Battle').frame.releasePose,'OFF retained release')
 assert(st==B._st and st.player==player and player.mon.hp==hp,'native identity/HP changed')
 assert(U.shot(game,dir..'/off.png'))
 B.abort('run');U.wait(2);Release.draw,Release.subject=draw,subject;game.update=update;love.window.hasFocus=actualFocus
 print('[PASS native GBA shared release]',version,original,shared,volumes,subjects,'native clock/identity/OFF')
 love.event.quit()
end
