return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local off=os.getenv('CAPTURE_OFF')=='1';local escape=os.getenv('CAPTURE_ESCAPE')=='1';local item=escape and 4 or 1
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map='FR_ROUTE_1',x=7,y=8,facing='down'}})
 require('src.ui.game3.map_preview_screen').reset()
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('Gen3Integration').setLevel(3,game)
 local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end
 V.require('Gen3Battle').setting:setIndex(1,game)
 V.require('BattleArt').backPlacementSetting:setIndex(2,game)
 V.require('PokeballSettings').enabled:setIndex(off and 1 or 2,game)
 local Party=require('src.core.game3.party');game.session.party={};assert(Party.giveMon(game.session,6,35))
 local Bag=require('src.core.game3.bag');game.session.bag=Bag.new();assert(Bag.add(game.session.bag,item,1))
 local B=require('src.core.game3.battle');local UI=require('src.core.game3.battle.ui')
 B.start({playerParty=game.session.party,foe={species=19,level=3},wild=true,session=game.session})
 for i=1,500 do if B._phase=='command'then break end;U.tap(game,'a');U.wait(2)end
 U.wait(15);assert(B._phase=='command')
 local Ball=V.require('Pokeball');local draw=Ball.draw;local draws=0;Ball.draw=function(self,...)draws=draws+1;return draw(self,...)end
 if escape then B._st.rng=function(lo,hi)return hi end end
 local command=UI.takeCommand;UI.takeCommand=function()UI.takeCommand=command;UI._mode='none';return{kind='bag',itemId=item}end
 for i=1,300 do if B._phase=='catching'then break end;U.tap(game,'a');U.wait(2)end
 assert(B._phase=='catching','no native capture '..tostring(B._phase))
 for i=1,(off and 5 or 150)do if V.require('Gen3Capture').status().started then break end;U.tap(game,'a');U.wait(2)end
 for i=1,900 do U.wait(1);if i==250 or i==450 or i==750 then U.shot(game,dir..'/capture-'..i..'.png')end end
 for k,v in pairs(V.require('Gen3Capture').status())do print('QA capture',k,v)end
 print('QA state',B._st.wild,B._st.double,B._st.safari,V.require('PokeballSettings').active(),V.require('Gen3Battle').enabled())
 assert(off and draws==0 or not off and draws>0,'capture ownership mismatch');assert(not Bag.has(game.session.bag,item,1),'native inventory not consumed')
 print('[PASS Gen3 capture native inventory and draws]',draws,B._phase)
 for i=1,300 do if B._phase~='catching'then break end;U.tap(game,'a');U.wait(3)end
 U.shot(game,dir..'/final.png');print('QA final',B._phase)
 Ball.draw=draw;V.require('Gen3Capture').finish();love.event.quit()
end
