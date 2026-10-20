-- Isolated native last-wild presentation; gameplay capture ownership stays native.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local multi=os.getenv('QA_MULTI_RELEASE')=='1'
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
 game.session.name=game.session.name or'QA';game.session.party={};local Party=require('src.core.game3.party')
 assert(Party.giveMon(game.session,6,35));assert(Party.giveMon(game.session,9,35));game.session.party[2].isShiny=true

 V.require('BattleArt').backPlacementSetting:sync('world')
 V.require('ModernBattleUI').setting:sync(false)
 game.mods.modOptions.MODERN_POKEMON_UI={modernBattleUI=false,modernInterfaceUI=false}
 game.mods.modOptions.double_battles={wild_doubles='always',your_side='pair',modern_hud=false}
 local D=assert(game.mods.exports.double_battles)
 assert(D.registerPartnerSource({id='qa-last-wild',priority=-999,provide=function()return 16,3 end}))
 U.wait(75)
 local B=require('src.core.game3.battle');local State=require('src.core.game3.battle.state')
 local UI=require('src.core.game3.battle.ui');local Seq=require('src.core.game3.battle.catch_seq')
 local Anim=require('src.core.game3.battle.anim');local Bag=require('src.core.game3.bag')
 game.session.bag=Bag.new();Bag.add(game.session.bag,4,5)
 local foe={species=19,level=3};assert(D.tagOrganic(foe,{terrain='land'}))
 assert(require('src.core.game3.battle_bridge').start(nil,game,foe,{wild=true}))
 local deadline=love.timer.getTime()+30
 while B._phase~='command'and love.timer.getTime()<deadline do U.tap(game,'a');U.wait(2)end
 if B._phase~='command'then U.shot(game,dir..'/intro-timeout.png')end
 assert(B._phase=='command','native pair command missing: '..tostring(B._phase))
 local st=assert(B.getState());assert(st.double and st.wild and #D.gen3Capture.livingTargets(st)==2)
 local identities={};for id=0,3 do local b=State.battler(st,id);identities[id]={b,b.mon.hp}end
 local Tint=V.require('NativeGen3CaptureTint');local tintDraw=Tint.draw;local target,enabled,seen,captured
 Tint.draw=function(owner,card,...)
  if Tint.intake(owner,card.id)then
   assert(enabled and card.id==target and owner==st,'wrong native capture target')
   seen=seen+1
   if not captured then game.capturePath=dir..'/intake-'..target..'.png';captured=true end
  end
  return tintDraw(owner,card,...)
 end
 local Capture=V.require('Gen3Capture');local clocks={}
 local originalEnemy=st.enemy
 -- Explicit last-foe/presentation fixtures: no fabricated gameplay KO or roll.
 -- Replay original zero-shake breakout clocks using the companion's view shape.
 for _,id in ipairs({1,3})do
  target=id;local other=id==1 and 3 or 1;st.absent[other]=true;st.absent[id]=false
  Anim.present(other).visible=false;Anim.present(id).visible=true
  local view={};for k,v in pairs(st)do view[k]=v end;view.enemy=State.battler(st,id)
  local count={}
  for pass=1,2 do
   enabled=pass==2;seen=0;captured=false;settings.enabled:sync(enabled);U.wait(3)
   Seq.begin(view,4,false,0,{target=id,session=game.session})
   local frames=0;local activeSeen=false
   while Seq.busy()do
    Seq.update();U.wait(1);frames=frames+1;assert(frames<1200,'capture presentation timed out')
    if Capture.active(st)then activeSeen=true;assert(Capture.target(st)==id)end
   end
   count[pass]=frames
   assert(enabled and activeSeen and seen>0 and captured or not enabled and not activeSeen and seen==0,'capture consumer ownership')
   assert(Seq.result()=='fail_catch','native breakout result changed')
   Seq.reset();assert(not Capture.active(st)and Capture.target(st)==nil)
   local Open=require('src.core.game3.battle.ball_open')
   for i=1,300 do if not Open.active()then break end;U.wait(1)end
   assert(not Open.active(),'native breakout particles did not finish')
   Anim.present(id).visible=true;Anim.present(id).scale=1;U.wait(3)
  end
  assert(count[1]==count[2],'native capture clock changed')
  clocks[#clocks+1]=table.concat(count,'/')
  st.absent[other]=false;Anim.present(other).visible=true
 end
 for id,prior in pairs(identities)do assert(State.battler(st,id)==prior[1]and prior[1].mon.hp==prior[2],'native identity/HP changed')end
 assert(st.enemy==originalEnemy and #game.session.party==2 and Bag.get(game.session.bag,4)==5,'presentation altered gameplay')
 settings.enabled:sync(false);U.wait(3);assert(U.shot(game,dir..'/restored.png'))
 -- One real companion command: native Master Ball odds, one item and storage.
 target=3;st.absent[1]=true;Anim.present(1).visible=false
 Bag.add(game.session.bag,1,1);enabled=true;seen=0;captured=true;settings.enabled:sync(true)
 assert(D.gen3Capture.choose({kind='bag',itemId=1,battler=0})==true,'public catch command refused')
 local untilTime=love.timer.getTime()+30
 while Seq.busy()and love.timer.getTime()<untilTime do U.wait(1);U.tap(game,'a')end
 assert(not Seq.busy()and Seq.result()=='catch','native catch did not finish')
 assert(Bag.get(game.session.bag,1)==0 and Bag.get(game.session.bag,4)==5,'native item consumption changed')
 assert(#game.session.party==3 and game.session.party[3].species==identities[3][1].species,'native caught partner not stored exactly once')
 assert(seen>0,'real capture did not use target material')
 Seq.reset();assert(not Capture.active(st))
 assert(U.shot(game,dir..'/caught-partner.png'))
 Tint.draw=tintDraw;D.unregisterPartnerSource('qa-last-wild');B.abort('run')
 game.update=update;love.window.hasFocus=actualFocus
 print('[PASS native GBA last-wild capture]',version,table.concat(clocks,','),'both targets/native clocks/identity/HP/OFF; real Master Ball item/storage')
 love.event.quit()
end
