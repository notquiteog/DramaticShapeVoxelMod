-- Native send-out routing with an injected playback sink; no bundled audio is
-- required, and this fixture does not claim audible pack/timbre verification.
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
 local settings=V.require('PokeballSettings');settings.enabled:sync(true);settings.audio:sync('EMBER')
 local Mon=require('src.battle.gen2.Mon')
 game.save.party={Mon.new(game.data,'CYNDAQUIL',30),Mon.new(game.data,'TOTODILE',30)}
 game.save.party[2].dvs={attack=10,defense=10,speed=10,special=10};game.save.party[2].shiny=true
 local A=V.require('EmberLegacyAudio');local play,master=A.play,A.nativeMaster;local events={};local mode='played';local masterValue
 A.play=function(event,index,shiny)events[#events+1]={event=event,shiny=shiny,mode=mode};return mode=='played'end
 A.nativeMaster=function(b,read)masterValue=read();return master(b,read)end
 local S=require('src.ui.gen2.BattleState');local animate=S.animForId;local cues={}
 S.animForId=function(self,id,side,param,...)
  local result=animate(self,id,side,param,...)
  if result and id=='ANIM_SEND_OUT_MON'and(param==nil or param==0)then
   local sound=self.anim.hooks.sound
   self.anim.hooks.sound=function(name,...)
    local key=tostring(name):upper():gsub('_',''):gsub('^SFX','')
    local before=#events;local result=sound(name,...)
    if key=='BALLPOOF'then cues[#cues+1]={mode=mode,attempts=#events-before}end
    return result
   end
  end
  return result
 end
 local Sound=require('src.core.Sound');local stereo=Sound.playStereo;local natives={played=0,failed=0,off=0}
 Sound.playStereo=function(data,name,...)
  if tostring(name):upper():gsub('_',''):gsub('^SFX','')=='BALLPOOF'then natives[mode]=natives[mode]+1 end
  return stereo(data,name,...)
 end
 U.wait(90);game.world.fade=nil;game.world.fadeHold=nil;game.world.fadeLevel=nil
 game.world:startBattle({wild=Mon.new(game.data,'SENTRET',3)})
 local screen
 local function command()
  for i=1,700 do
   screen=V.require('Gen2Staged').screenFor(game)
   if screen and screen.phase=='menu'then return end
   U.tap(game,'a');U.wait(2)
  end
  error('native command unavailable: '..tostring(screen and screen.phase))
 end
 command();assert(Stage.shot()and Stage.shot().canvas,'stage missing')
 assert(#events>0,'initial sendout was not consumed')
 local function switch(index,nextMode)
  mode=nextMode;screen:submit({kind='switch',index=index});U.wait(2);command()
  assert(screen:activeMon('player')==game.save.party[index],'native switch identity')
 end
 switch(2,'played');assert(U.shot(game,dir..'/shiny-sendout.png'))
 local shiny=false;for _,e in ipairs(events)do assert(e.event=='sendout');shiny=shiny or e.shiny end
 assert(shiny,'native shiny identity lost')
 switch(1,'failed');settings.enabled:sync(false);switch(2,'off')
 assert(U.shot(game,dir..'/off-native.png'))
 local successful,failed,off=0,0,0
 for _,c in ipairs(cues)do
  if c.mode=='played'and c.attempts>0 then successful=successful+1
  elseif c.mode=='failed'and c.attempts>0 then failed=failed+1
  elseif c.mode=='off'then assert(c.attempts==0);off=off+1 end
 end
 assert(successful>=2 and failed>=1 and off>=1,'native sendout coverage incomplete')
 assert(natives.played==0 and natives.failed>=1 and natives.off>=1,'native suppression/fallback failed')
 assert(type(masterValue)=='number'and #game.save.party==2,'volume/party changed')
 V.require('Gen2BallAudio').finish();A.play,A.nativeMaster=play,master;S.animForId=animate;Sound.playStereo=stereo;game.update=update
 print('[PASS native Gen2 ball audio]',version,successful,failed,off,'sendout/shiny/fallback/OFF/native switch')
 love.event.quit()
end
