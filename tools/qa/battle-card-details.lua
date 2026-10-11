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
 V.require('ModernBattleUI').setting:sync(true)
 U.wait(20);assert(U.shot(game,dir..'/battle-cards.png'));local H=V.require('Gen3BattleHud');assert(H.drawn>0,'cards not drawn');for id,c in pairs(H.cards)do print('CARD',id,c.gender,c.caught,c.exp)end;print('PASS native battle cards');love.event.quit()
end
