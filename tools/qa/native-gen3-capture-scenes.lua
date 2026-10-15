-- Isolated imported profiles only; native Safari counters and tutorial results.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local mode=os.getenv('CAPTURE_SCENE')or'safari';local off=os.getenv('CAPTURE_OFF')=='1'
 local version=require('src.core.GameVersion').get();love.window.setMode(480,320,{vsync=0})
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local map=({ruby='RU_LITTLEROOT_TOWN',sapphire='SA_LITTLEROOT_TOWN',emerald='EM_LITTLEROOT_TOWN'})[version]or'FR_PALLET_TOWN'
 game:_handleBootAction({action='new_game',start={map=map,x=7,y=8,facing='down'}})
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
 local vm=space.getVm();if vm then vm:halt(true)end
 require('src.ui.game3.message').reset();require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local verifyTint=os.getenv('VERIFY_CAPTURE_TINT')=='1';local tintCalls,tintShot=0,false
 local Tint=verifyTint and V.require('NativeGen3CaptureTint');local tintDraw=Tint and Tint.draw
 if Tint then Tint.draw=function(st,card,mesh,sun)
  local active=Tint.intake(st,card.id);local model,texture=card.model,card.tex
  local R=V.require('Voxel3D');local saved=R.tint
  if os.getenv('TINT_BYPASS')=='1'then R.draw(mesh,card.tex,card.model,0,sun)
  else tintDraw(st,card,mesh,sun)end
  assert(card.model==model and card.tex==texture and R.tint==saved,'intake changed native actor/render state')
  if active then tintCalls=tintCalls+1 end
 end end
 V.require('Gen3Integration').setLevel(3,game);V.require('Gen3Battle').setting:sync(true)
 V.require('Shadows').setting:sync('off');V.require('RenderDistance').setting:sync(16)
 V.require('PokeballSettings').enabled:sync(not off)
 V.require('BattleArt').backPlacementSetting:sync('world')
 game.session.party={};assert(require('src.core.game3.party').giveMon(game.session,6,35))
 local Bag=require('src.core.game3.bag');game.session.bag=Bag.new();Bag.add(game.session.bag,4,5)
 game.session.safari={active=true,balls=30}
 U.wait(75)
 local B=require('src.core.game3.battle');local UI=require('src.core.game3.battle.ui')
 local Seq=require('src.core.game3.battle.catch_seq')
 local Ball=V.require('Pokeball');local draw=Ball.draw;local draws,trainerSeen,started=0,false,false
 Ball.draw=function(self,...)draws=draws+1;return draw(self,...)end
 local opts={playerParty=game.session.party,foe={species=19,level=3},wild=true,session=game.session,playerName=game.session.name or'QA',rng=function(lo)return lo or 0 end}
 if mode=='safari'then opts.safari=true
 elseif mode=='oldman'then opts.oldManTutorial=true
 elseif mode=='wally'then opts.tutorialKind='wally'
 elseif mode=='pokedude'then opts.pokedude=true;opts.pdScriptNum=3;opts.playerGender=require('src.core.game3.battle.pokedude').BACK_PIC
  local party,foes=require('src.core.game3.battle.pokedude').build(3);opts.playerParty=party;opts.foe=foes[1]
 else error('unknown capture scene')end
 B.start(opts)
 local st=B._st
 -- Start Wally at his trainer-return command; retain his native throw setup.
 if mode=='wally'then st.wallyState=2 end
 local partyBefore=#game.session.party;local command=UI.takeCommand;local issued=false
 if mode=='safari'then
  UI.takeCommand=function(...)
   if not issued then issued=true;UI._mode='none';return{kind='safari',action='ball'}end
   return command(...)
  end
 end
 local age,shots=0,{}
 for i=1,1800 do
  U.wait(1)
  if i%6==0 then U.tap(game,'a')end
  -- Teachy TV's interactive instruction script is a separate test. Stage its
  -- native capture sequence once the original Pokedude scene is ready.
  if mode=='pokedude'and not issued and B._phase=='command'then
   issued=true;B._phase='catching';UI._mode='none';UI.clearLinger()
   Seq.begin(st,4,true,3,{session=game.session,pushMsg=function(text,wait,o)
    if o then UI.pushGated(text,o.gate,o.pause)
    elseif wait then UI.pushTimed(text,wait)else UI.push(text)end
   end})
  end
  local cap=V.require('Gen3Capture').status()
  if tintCalls>0 and not tintShot then tintShot=true;assert(U.shot(game,dir..'/intake-tint.png'))end
  if cap.started then started=true end
  local frame=V.require('Gen3Battle').frame
  trainerSeen=trainerSeen or(frame and frame.byId and frame.byId[4]~=nil)
  if Seq._ball then
   age=age+1
   for _,n in ipairs({12,45,110,260})do
    if age>=n and not shots[n]then shots[n]=true;assert(U.shot(game,dir..'/capture-'..n..'.png'))end
   end
  end
  if age>0 and not Seq.busy()then break end
 end
 assert(age>0 and not Seq.busy(),'native capture did not finish: '..tostring(B._phase))
 assert(trainerSeen or mode=='pokedude','native trainer was not rendered')
 assert(off and draws==0 and not started or not off and draws>0 and started,'presentation ownership')
 if verifyTint then assert(off and tintCalls==0 or not off and tintCalls>0 and tintShot,'native intake tint was not exercised')end
 if mode=='safari'then
  assert(game.session.safari.balls==29,'native Safari counter changed incorrectly')
  assert(#game.session.party==partyBefore+1,'native Safari result did not store exactly one Pokemon')
 else assert(#game.session.party==partyBefore,'tutorial stored a Pokemon')end
 assert(Bag.get(game.session.bag,4)==5,'native inventory consumption changed')
 assert(U.shot(game,dir..'/result.png'))
 Seq.reset();assert(not V.require('Gen3Capture').active(st),'reset retained capture')
 UI.takeCommand=command;Ball.draw=draw;game.update=update
 if Tint then Tint.draw=tintDraw end
 if verifyTint then print('[PASS native intake tint]',version,tintCalls,off and'OFF'or'ON')end
 print('[PASS native capture scenes]',version,mode,off and'OFF'or'ON',draws,'native counters/result/reset')
 love.event.quit()
end
