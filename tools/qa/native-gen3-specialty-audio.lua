-- Original native capture-sequencer integration with an explicit audio sink.
-- No optional recording, full item turn or visual parity claim.
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
 U.wait(75)
 local B=require('src.core.game3.battle');local UI=require('src.core.game3.battle.ui')
 B.start({playerParty=game.session.party,foe={species=19,level=3},wild=true,session=game.session,playerName=game.session.name or'QA'})
 for i=1,1200 do if B._phase=='command'then break end;U.tap(game,'a');U.wait(2)end
 assert(B._phase=='command','native command missing')
 local st=B._st;local party=game.session.party;local hp=st.enemy.hp
 local Seq=require('src.core.game3.battle.catch_seq');local Anim=require('src.core.game3.battle.anim')
 local A=V.require('EmberLegacyAudio');local play,ready=A.play,A.ready
 local Audio=require('src.core.game3.audio');local stop=Audio._stopSePlayer
 local mode,natives,events='off',0,{}
 A.ready=function()return true end
 A.play=function(event,index)events[#events+1]=event..':'..tostring(index);return mode=='played'end
 Audio._stopSePlayer=function(...)natives=natives+1;return stop(...)end
 for _,item in ipairs({6,7,8,9,10,11,12,4})do
  local ghost=item==4;local baseline
  for _,m in ipairs({'off','played','failed'})do
   mode=m;settings.enabled:sync(m~='off');events={};natives=0
   Seq.reset();Anim.reset();Anim.Coords.bind(st);UI.clearLinger()
   Anim.present(0).visible=true;Anim.present(1).visible=true
   Seq.begin(st,item,false,2,{ghostDodge=ghost,session=game.session})
   local ticks=0
   repeat Anim.update(1/60);Seq.update();ticks=ticks+1 until not Seq.busy()or ticks>=3000
   assert(ticks<3000,'native sequence did not finish')
   assert(not V.require('Gen3Capture').active(st),'audio-only path claimed native geometry')
   if m=='off'then baseline={ticks=ticks,natives=natives};assert(#events==0 and natives>0,'OFF native sounds')
   else
    assert(ticks==baseline.ticks,'native clocks changed')
    assert(#events>0,'missing optional audio')
    assert((m=='failed'and natives==baseline.natives)or(m=='played'and natives<baseline.natives),'native suppression/fallback')
   end
   assert(game.session.party==party and st.enemy.hp==hp,'native combat identity changed')
   print('[native capture case]',version,item,ghost and'ghost'or'specialty',m,ticks,natives,#events)
  end
 end
 Seq.reset();assert(not V.require('Gen3Capture').status().pending,'reset retained owner')
 A.play,A.ready=play,ready;Audio._stopSePlayer=stop;B.abort('run');game.update=update
 print('[PASS native Gen3 specialty audio]',version,'24 original sequences; OFF/success/failure/native clock/identity/reset')
 love.event.quit()
end
