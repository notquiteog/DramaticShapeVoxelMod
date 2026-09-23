return function(game)
 local U=dofile('tests/drivers/util.lua');local gen=require('src.core.GameVersion').generation()
 local C=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK.crystalSprites)
 C.applyOption('crystalAnimations','loop')
 local Mon=require(gen==2 and'src.battle.gen2.Mon'or'src.pokemon.Pokemon')
 local mon=Mon.new(game.data,gen==2 and'CYNDAQUIL'or'BULBASAUR',16)
 game.save.party={mon}
 if gen==2 then game.phase='play';game.world.trySceneScript=function()return false end;game.world.noWildEncounters=true;game.world:setMap('NEW_BARK_TOWN',9,8,'down');game.stack:clear()
 else U.teleport(game,'PALLET_TOWN',9,8,'down')end
 U.wait(90)
 local Summary=require(gen==2 and'src.ui.gen2.SummaryMenu'or'src.ui.SummaryMenu')
 local s=Summary.new(game,gen==2 and{mon=mon}or mon);game.stack:push(s);U.wait(45)
 local function pic()return gen==2 and s:picFor(mon)or s.sprite end
 local first=assert(pic());local changed=false
 for _=1,120 do U.wait(2);if pic()~=first then changed=true;break end end
 assert(changed,'summary animation frozen');assert(U.shot(game,os.getenv('SHOT_DIR')..'/crystal-summary.png'))
 game.stack:pop();U.wait(15)
 local E=require(gen==2 and'src.ui.gen2.EvolutionAnim'or'src.ui.EvolutionState')
 local evo=gen==2 and E.new(game,{mon=mon,entry={into='QUILAVA'},force=true})or E.new(game,mon,'IVYSAUR')
 game.stack:push(evo)
 for _=1,1200 do
  if (gen==2 and (evo.phase=='picAnim' or evo.phase=='congrats')) or (gen==1 and evo.done) then break end
  U.tap(game,'a');U.wait(3)
 end
 assert((gen==2 and (evo.phase=='picAnim' or evo.phase=='congrats')) or (gen==1 and evo.done),'evolution never revealed new form')
 U.wait(4);assert(U.shot(game,os.getenv('SHOT_DIR')..'/crystal-evolution.png'))
 print('[Crystal menus] PASS',gen,'summary frames advance; summary and evolution rendered')
end
