-- Native presentation/command/HP checks, isolated from the user's save.
return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
 love.window.setMode(2560,1440,{resizable=true})
 local E=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK)
 local C,S=E.firered.camera,E.firered.battles
 game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
 C.setLevel(3,game);U.wait(60);assert(C.active)
 local Party=require('src.core.game3.party');assert(Party.giveMon(game.session,1,12,'BULBASAUR'))
 local Bridge=require('src.core.game3.battle_bridge');local Battle=require('src.core.game3.battle')
 local Ui=require('src.core.game3.battle.ui');local Player=require('src.core.game3.player')
 local px,py=Player.px,Player.py
 assert(Bridge.startWild(nil,game,{species=19,level=10},{fade=true}))
 for _=1,80 do U.tap(game,'a');U.wait(8);if Battle._phase=='command' and Ui._mode=='menu' then break end end
 assert(Battle._phase=='command' and S.active and S.rendered>0)
 U.wait(2);assert(S.hud.drawn>0 and S.hud.cards[0] and S.hud.cards[1])
 local Pokemon=require('src.core.game3.pokemon')
 local bounds=E.lib.require('SpriteHeadBounds').get(Pokemon.frontPic(19).image)
 print('[FR stage] Rattata native bounds',unpack(bounds))
 assert(bounds[2]>0,'head anchor fell back to empty sprite padding')
 assert(U.shot(game,dir..'/commands-1440p.png'))
 -- Right from FIGHT is PKMN in the requested layout, down is ITEMS. The
 -- original controller still owns selection/confirmation and all actions.
 U.tap(game,'right');assert(Ui._menuIndex==3,'right did not select PKMN')
 U.tap(game,'left');assert(Ui._menuIndex==1)
 U.tap(game,'down');assert(Ui._menuIndex==2,'down did not select ITEMS')
 U.tap(game,'up');assert(Ui._menuIndex==1)
 U.tap(game,'a');U.wait(3);assert(Ui._mode=='moves')
 assert(U.shot(game,dir..'/moves-1440p.png'))
 local before=Battle._st.enemy.mon.hp
 U.tap(game,'a');local acted,shot=false,false
 for _=1,160 do
  U.wait(6)
  if Battle._phase~='command' then
   acted=true;assert(S.active,'stage disappeared before battle ended')
   if not shot then assert(U.shot(game,dir..'/attack-1440p.png'));shot=true end
  end
  if Battle._st and Battle._st.enemy.mon.hp<before and Battle._phase=='command' then break end
  U.tap(game,'a')
 end
 assert(acted and Battle._st and Battle._st.enemy.mon.hp<before,'native damage did not reach opponent')
 print('[FR stage] native HP',before,Battle._st.enemy.mon.hp)
 assert(Player.px==px and Player.py==py,'presentation moved overworld player')
 Battle.abort('run');U.wait(120)
 assert(not Battle.isActive() and C.active)
 assert(U.shot(game,dir..'/returned-field.png'))
 print('[FR stage] PASS: 1440p head cards, directional menu, move selection, native damage, stage lifetime and return')
 love.event.quit()
end
