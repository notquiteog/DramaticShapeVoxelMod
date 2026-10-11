-- Isolated Emerald QA only; native input drives catch, naming and return.
-- CAPTURE_OFF=1 selects stock ball, otherwise use the optional modeled prop.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 love.window.setMode(640,480,{resizable=false})
 local off=os.getenv('CAPTURE_OFF')=='1';local escape=os.getenv('CAPTURE_ESCAPE')=='1';local item=escape and 4 or 1
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='EM_ROUTE101',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(3,game);V.require('AntiAlias').setting:sync(0)
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
 V.require('Gen3Battle').setting:setIndex(1,game)
 V.require('BattleArt').backPlacementSetting:setIndex(2,game)
 V.require('PokeballSettings').enabled:setIndex(off and 1 or 2,game)
 if os.getenv('CAPTURE_DARK')=='1' then V.require('UiBackplates').hudColor:setIndex(2,game) end
 local Party=require('src.core.game3.party');game.session.name='TESTER';game.session.party={};assert(Party.giveMon(game.session,6,35))
 local Bag=require('src.core.game3.bag');game.session.bag=Bag.new();assert(Bag.add(game.session.bag,item,1))
 local B=require('src.core.game3.battle');local UI=require('src.core.game3.battle.ui')
 U.wait(40);print('CAPTURE fixture ready',B._phase)
 assert(require('src.core.game3.battle_bridge').startWild(nil,game,{species=19,level=3}))
 for i=1,500 do if B._phase=='command'then break end;if i%100==0 then print('CAPTURE waiting',i,B._phase)end;U.tap(game,'a');U.wait(2)end
 U.wait(15);assert(B._phase=='command')
 local Ball=V.require('Pokeball');local draw=Ball.draw;local draws=0;Ball.draw=function(self,...)
 draws=draws+1
 local f=V.require('Gen3Battle').frame
 if draws%30==1 then print('BALL',draws,self.phase,self.pos[2],self.scale,'floor',f and f.points and f.points[1]and f.points[1][2],'t',love.timer.getTime())end
 return draw(self,...)
 end
 if escape then B._st.rng=function(lo,hi)return hi end end
 local command=UI.takeCommand;UI.takeCommand=function()UI.takeCommand=command;UI._mode='none';return{kind='bag',itemId=item}end
 for i=1,300 do if B._phase=='catching'then break end;U.tap(game,'a');U.wait(2)end
 assert(B._phase=='catching','no native capture '..tostring(B._phase))
 for i=1,(off and 5 or 150)do if V.require('Gen3Capture').status().started then break end;U.tap(game,'a');U.wait(2)end
 for i=1,500 do
 if i%15==0 then U.tap(game,B._phase=='catch_nickname_prompt'and'b'or'a')end
 U.wait(1)
 if i%30==0 then local stage=require('src.core.game3.battle.anim').stage();local b=stage.ball
 print('NATIVEBALL',i,b and b.x,b and b.y,b and b.oy,b and b.visible,B._phase)
 end
 if i==60 or i==120 or i==200 or i==300 or i==450 then U.shot(game,dir..'/capture-'..i..'.png')end
 end
 for k,v in pairs(V.require('Gen3Capture').status())do print('QA capture',k,v)end
 print('QA state',B._st.wild,B._st.double,B._st.safari,V.require('PokeballSettings').active(),V.require('Gen3Battle').enabled())
 assert(off and draws==0 or not off and draws>0,'capture ownership mismatch');assert(not Bag.has(game.session.bag,item,1),'native inventory not consumed')
 print('[PASS Gen3 capture native inventory and draws]',draws,B._phase)
 local named=false;local last
 for i=1,2000 do
  if not B.isActive()then break end
  if last~=B._phase then print('FLOW',B._phase);last=B._phase end
  if B._phase=='catch_naming' then
   U.tap(game,'start');U.wait(3);named=true
   U.tap(game,'a')
  else U.tap(game,'a')end
  U.wait(3)
 end
 assert(named,'real nickname screen not reached')
 assert(not B.isActive(),'capture did not return to overworld: '..tostring(B._phase))
 assert(#game.session.party==2,'native caught Pokemon missing')
 U.wait(80);assert(V.require('Gen3Integration').active,'world renderer did not resume');assert(not V.require('Gen3Capture').status().pending,'capture state leaked into overworld')
 U.shot(game,dir..'/final.png');print('[PASS native naming and return]',B._phase,#game.session.party)
 Ball.draw=draw;love.event.quit()
end
