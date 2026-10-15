-- Native event verification with a playback sink: optional Ember files are not
-- bundled. This proves routing/fallback and native switch behavior, not timbre.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();love.window.setMode(480,320,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(3,game)
 V.require('Gen3Battle').setting:sync(true);V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 local settings=V.require('PokeballSettings');settings.enabled:sync(true);settings.audio:sync('EMBER')
 game.session.party={};local Party=require('src.core.game3.party')
 assert(Party.giveMon(game.session,6,35));assert(Party.giveMon(game.session,9,35));game.session.party[2].isShiny=true
 local A=V.require('EmberLegacyAudio');local play,master=A.play,A.nativeMaster;local events={};local mode='played';local masterValue
 A.play=function(event,index,shiny)events[#events+1]={event=event,shiny=shiny,mode=mode};return mode=='played'end
 A.nativeMaster=function(st,read)masterValue=read();return master(st,read)end
 local Audio=require('src.core.game3.audio');local SE=require('src.core.game3.se_ids')
 local sound,stop=Audio.playSe,Audio._stopSePlayer;local originalCalls=0;local cues={}
 Audio._stopSePlayer=function(...)originalCalls=originalCalls+1;return stop(...)end
 Audio.playSe=function(id,...)
  local before,attempts=originalCalls,#events;local result=sound(id,...)
  if id==SE.SE_BALL_OPEN then cues[#cues+1]={mode=mode,attempts=#events-attempts,native=originalCalls-before}end
  return result
 end
 U.wait(75)
 local B=require('src.core.game3.battle');local UI=require('src.core.game3.battle.ui')
 B.start({playerParty=game.session.party,foe={species=19,level=3},wild=true,session=game.session,playerName=game.session.name or'QA'})
 local function command()
  for i=1,1200 do if B._phase=='command'then return end;U.tap(game,'a');U.wait(2)end
  error('native command not reached: '..tostring(B._phase))
 end
 command();assert(#events>0 and events[1].event=='sendout','initial native sendout not consumed')
 local function switch(slot,nextMode)
  mode=nextMode;local take=UI.takeCommand;local issued=false
  UI.takeCommand=function(...)
   if not issued then issued=true;UI._mode='none';return{kind='switch',slot=slot}end
   return take(...)
  end
  U.wait(3);command();UI.takeCommand=take
  assert(issued and B._st.player.partyIndex==slot,'native switch did not select intended party member')
 end
 switch(2,'played');assert(U.shot(game,dir..'/shiny-sendout.png'))
 local recall,shiny=false,false
 for _,e in ipairs(events)do recall=recall or e.event=='recall';shiny=shiny or(e.event=='sendout'and e.shiny)end
 assert(recall and shiny,'recall/shiny routing incomplete')
 switch(1,'failed')
 settings.enabled:sync(false);switch(2,'off');assert(U.shot(game,dir..'/off-native.png'))
 local successful,failed,off=0,0,0
 for _,c in ipairs(cues)do
  if c.mode=='played'and c.attempts>0 then assert(c.native==0,'replaced sound also played native');successful=successful+1
  elseif c.mode=='failed'and c.attempts>0 then assert(c.native>0,'failed replacement muted native');failed=failed+1
  elseif c.mode=='off'then assert(c.attempts==0 and c.native>0,'OFF sound ownership');off=off+1 end
 end
 assert(successful>=3 and failed>=2 and off>=2,'missing native switch audio cases')
 assert(type(masterValue)=='number'and #game.session.party==2,'native volume/party identity')
 B.abort('run');V.require('NativeGen3BallAudio').update()
 A.play,A.nativeMaster=play,master;Audio.playSe,Audio._stopSePlayer=sound,stop;game.update=update
 print('[PASS native ball audio]',version,successful,failed,off,'sendout/recall/shiny/fallback/OFF/native switch')
 love.event.quit()
end
