return function(game)
 local U=dofile('tests/drivers/util.lua')
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
 local C=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).firered.camera
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 C.setLevel(3,game);U.wait(60);assert(C.active)
 local Party=require('src.core.game3.party')
 assert(Party.giveMon(game.session,1,12,'BULBASAUR'))
 local Bridge=require('src.core.game3.battle_bridge')
 local Battle=require('src.core.game3.battle')
 assert(Bridge.startWild(nil,game,{species=19,level=3},{fade=true}))
 for _=1,40 do U.tap(game,'a');U.wait(12);if Battle._phase=='command' then break end end
 print('[FR battle]',Battle.isActive(),Battle._phase)
 assert(Battle.isActive())
 assert(U.shot(game,'/tmp/firered-hd2d/native-battle.png'))
 -- QA teardown uses the engine's explicit abort, not a fabricated win.
 Battle.abort('run');U.wait(120)
 assert(not Battle.isActive() and C.active,'HD2D did not return after native battle')
 assert(U.shot(game,'/tmp/firered-hd2d/after-native-battle.png'))
 print('[FR battle] PASS native entry/render/abort/field return; no combat-logic claim')
 love.event.quit()
end
