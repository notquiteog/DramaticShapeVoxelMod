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
 local function command()
  local deadline=love.timer.getTime()+40
  repeat U.tap(game,'a');U.wait(2)until B._phase=='command'or love.timer.getTime()>deadline
  assert(B._phase=='command','native paired intro timed out: '..tostring(B._phase))
 end
 local summaries={}
 for _,case in ipairs({{'normal',false,false,'played',true,2},{'shiny',true,true,'played',true,2},
  {'mixed',true,false,'played',true,1},{'failed',false,false,'failed',true,2},{'off',false,false,'off',false,0}})do
  mode=case[4];settings.enabled:sync(case[5]);events={};cues={}
  game.session.party[1].isShiny=case[2];game.session.party[2].isShiny=case[3]
  B.start({playerParty=game.session.party,foe={party={{species=19,level=3},{species=16,level=3}}},
   wild=false,double=true,trainerClassName='TRAINER',trainerName='QA',session=game.session,playerName='QA'})
  command()
  assert(#events==case[6],case[1]..' replacement count '..#events..' expected '..case[6])
  local replaced,native=0,0
  for _,c in ipairs(cues)do
   if c.attempts>0 and mode=='played'then assert(c.native==0,'native and replacement both played');replaced=replaced+1
   else assert(c.native>0,'native fallback suppressed');native=native+1 end
  end
  if case[1]=='shiny'then
   local saw=false;for _,e in ipairs(events)do saw=saw or e.shiny end;assert(saw,'unanimous shiny group lost variant')
  elseif case[1]=='mixed'then assert(replaced==1 and native==1,'mixed group did not retain native cue')end
  assert(U.shot(game,dir..'/'..case[1]..'.png'))
  summaries[#summaries+1]=case[1]..':'..#events..'/'..replaced..'/'..native
  B.abort('run');V.require('NativeGen3BallAudio').update();U.wait(10)
 end
 A.play,A.nativeMaster=play,master;Audio.playSe,Audio._stopSePlayer=sound,stop;game.update=update
 print('[PASS native paired ball audio]',version,table.concat(summaries,','),'original intro/cue count/mixed/failure/OFF')
 love.event.quit()
end
