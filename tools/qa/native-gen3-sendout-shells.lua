-- Native send-out shell rendering with original intro/switch sequencers.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local version=require('src.core.GameVersion').get();love.window.setMode(480,320,{vsync=0});print('[renderer]',love.graphics.getRendererInfo())
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(3,game)
 V.require('Gen3Battle').setting:sync(true);V.require('Shadows').setting:sync('high');V.require('RenderDistance').setting:sync(16)
 local settings=V.require('PokeballSettings');settings.enabled:sync(true);settings.audio:sync('EMBER')
 game.session.party={};local Party=require('src.core.game3.party')
 assert(Party.giveMon(game.session,6,35));assert(Party.giveMon(game.session,9,35));game.session.party[2].isShiny=true
 local Shell=V.require('NativeGen3SendoutShell');local draw=Shell.draw
 local counts={lit=0,shadow=0,off=0};local types={};local opened=false;local shots={};local mode='on';local observed
 Shell.draw=function(st,card,shadow)
  local native=require('src.core.game3.battle.anim').stage()
  local p=Shell.shell(st,card);local before=p and{p.pos[1],p.pos[2],p.pos[3]}
  local result=draw(st,card,shadow)
  if result then
   assert(mode=='on','OFF replaced a native card')
   counts[shadow and'shadow'or'lit']=counts[shadow and'shadow'or'lit']+1
   types[p.ball]=true;opened=opened or p.lid>0
   if not shadow then observed=p.lid>0 and'open'or'closed'end
   assert(p.pos[1]==before[1]and p.pos[2]==before[2]and p.pos[3]==before[3],'pass altered native placement')
  elseif card.ball and mode=='off'then counts.off=counts.off+1;observed='off'end
  return result
 end
 U.wait(75)
 local B=require('src.core.game3.battle');local UI=require('src.core.game3.battle.ui')
 B.start({playerParty=game.session.party,foe={species=19,level=3},wild=true,session=game.session,playerName=game.session.name or'QA'})
 local function command()
  for i=1,1200 do
   if observed and not shots[observed]then shots[observed]=true;assert(U.shot(game,dir..'/'..observed..'.png'))end
   if B._phase=='command'then return end
   U.tap(game,'a');U.wait(1)
  end
  error('native command missing')
 end
 command();V.require('Shadows').setting:sync('off')
 local function switch(slot)
  local take=UI.takeCommand;local issued=false
  UI.takeCommand=function(...)
   if not issued then issued=true;UI._mode='none';return{kind='switch',slot=slot}end
   return take(...)
  end
  U.wait(3);command();UI.takeCommand=take
  assert(issued and B._st.player.partyIndex==slot,'native switch identity');print('[switch]',version,slot,counts.lit,counts.shadow,counts.off)
 end
 local slot=1
 for _,item in ipairs({3,2,1,5})do slot=3-slot;game.session.party[slot].pokeball=item;switch(slot)end
 settings.enabled:sync(false);mode='off';switch(3-slot)
 assert(counts.lit>0 and counts.shadow>0 and counts.off>0 and opened,'native lit/shadow/open/OFF coverage')
 for _,name in ipairs({'POKE_BALL','GREAT_BALL','ULTRA_BALL','MASTER_BALL','SAFARI_BALL'})do assert(types[name],'missing '..name)end
 assert(shots.closed and shots.open and shots.off,'capture coverage')
 B.abort('run');Shell.clear();Shell.draw=draw;game.update=update
 print('[PASS native sendout shells]',version,counts.lit,counts.shadow,counts.off,'five types/native switches/open/closed/OFF')
 love.event.quit()
end
