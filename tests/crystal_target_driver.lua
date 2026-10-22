return function(game)
 io.stdout:setvbuf('no')
 local U=dofile('tests/drivers/util.lua');local R=require('src.mods.Runtime')
 local update=game.update;game.update=function(self,dt)return R.call('core.update',update,self,dt)end
 game:startNewGame({intro=false});game.overworld:setMap('ROUTE_1',10,6,'down')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 assert(V.crystalSpritesActive,'Crystal pack missing')
 local C=game.mods.exports.BATTLE_ART_VOXEL_FORK.crystalSprites
 local P=require('src.pokemon.Pokemon')
 game.save.party={P.new(game.data,'PIKACHU',40),P.new(game.data,'BULBASAUR',40),P.new(game.data,'CHARMANDER',40)}
 for _,m in ipairs(game.save.party)do m.moves={{id='TACKLE',pp=35,maxPp=35}}end
 require('src.render.Pipelines').setLevel('voxel',3)
 V.require('OverworldBattle').setting:sync(true)
 game.mods.modOptions.double_battles={wild_doubles='always',your_side='pair'}
 U.wait(60)
 assert(game.mods.exports.double_battles.startWildDouble('SPEAROW',20,'ZUBAT',20))
 local b
 for i=1,1200 do b=game.stack:top();if b and b.__double and b.phase=='menu'then break end;U.tap(game,'a');U.wait(2)end
 assert(b and b.__double and b.phase=='menu','double menu missing')
 b:resolveTurn({id='TACKLE'});assert(b.phase=='db_target','not target menu')
 local keys={'player','player2','enemy','enemy2'};local initial,changed={},{}
 for _,k in ipairs(keys)do assert(b[k] and b[k].sprite,k..' missing');initial[k]=b[k].sprite end
 local calls=0;local ex=game.mods.exports.BATTLE_ART_VOXEL_FORK;local refresh=ex.updateBattlePresentation
 -- Disable only the new public adapter to reproduce the prior pause bug.
 ex.updateBattlePresentation=nil
 U.wait(120)
 for _,k in ipairs(keys)do assert(b[k].sprite==initial[k],k..' unexpectedly animated without callback')end
 print('REPRODUCED prior frozen four-slot target presentation')
 ex.updateBattlePresentation=function(...)calls=calls+1;return refresh(...)end
 U.wait(4);assert(U.shot(game,os.getenv('SHOT_DIR')..'/target-before.png'))
 for i=1,180 do U.wait(1);assert(b.phase=='db_target','target advanced gameplay');for _,k in ipairs(keys)do if b[k].sprite~=initial[k]then changed[k]=true end end end
 assert(calls>=180,'presentation callback did not tick')
 for _,k in ipairs(keys)do assert(changed[k],k..' frame frozen')end
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/target-after.png'))
 print('PASS Yellow Crystal target: all four frame identities advance, target retains gameplay ownership',calls)
 U.tap(game,'b');U.wait(3)
 b:resolveSwitch(game.save.party[3]);assert(b.phase=='db_switch_target')
 initial,changed={},{};for _,k in ipairs(keys)do initial[k]=b[k].sprite end
 for i=1,180 do U.wait(1);assert(b.phase=='db_switch_target');for _,k in ipairs(keys)do if b[k].sprite~=initial[k]then changed[k]=true end end end
 for _,k in ipairs(keys)do assert(changed[k],k..' switch frame frozen')end
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/switch-after.png'))
 print('PASS Yellow switch target: all four frame identities advance with gameplay paused')
end
