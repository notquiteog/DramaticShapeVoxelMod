return function(game)
 io.stdout:setvbuf('no')
 local U=dofile('tests/drivers/util.lua');local gen=require('src.core.GameVersion').generation()
 local E=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK);local V=E.lib;local C=assert(E.crystalSprites,'pack did not install')
 assert(V.crystalSpritesActive and not V.require('BattleArt').ownsSpeciesArt(),'two sprite owners')
 assert(not game.mods.exports.crystal_animated_sprites_with_shiny_visuals,'separate mod still loaded')
 assert(game.mods.optionSchemas.BATTLE_ART_VOXEL_FORK and #game.mods.optionSchemas.BATTLE_ART_VOXEL_FORK>75,'schema replaced')
 local Mon=require(gen==2 and 'src.battle.gen2.Mon' or 'src.pokemon.Pokemon')
 local lead=Mon.new(game.data,gen==2 and'CYNDAQUIL'or'BULBASAUR',25)
 game.save.party={lead}
 if gen==2 then
  game.phase='play';game.world.trySceneScript=function()return false end;game.world.noWildEncounters=true
  assert(game.world:setMap('ROUTE_29',12,6,'down'));game.stack:clear()
 else U.teleport(game,'ROUTE_1',8,12,'down')end
 require('src.render.Pipelines').setLevel('voxel',3)
 V.require('OverworldBattle').setting:sync(true)
 U.wait(180)
 local first=assert(C.stagedPokemonSprite(lead,true));assert(first.fullBody)
 local changed=false
 for _=1,40 do U.wait(2);if C.stagedPokemonSprite(lead,true).frame~=first.frame then changed=true end end
 assert(changed,'full body animation frozen')
 if gen==2 then lead.shiny=true else lead.dvs={attack=10,defense=10,speed=10,special=10}end
 local shiny=assert(C.stagedPokemonSprite(lead,true));assert(shiny.variant=='shiny' and shiny.image~=first.image,'shiny fallback wrong')
 if gen==2 then lead.shiny=false else lead.dvs={attack=15,defense=15,speed=15,special=15}end
 if gen==2 then assert(game.world:startBattle({wild=Mon.new(game.data,'SENTRET',20)}))
 else game.stack:top():pushBattle(require('src.battle.BattleState').newWild(game,'RATTATA',20))end
 local b
 for _=1,1200 do b=game.stack:top();if b and b.phase=='menu' then break end;U.tap(game,'a');U.wait(3)end
 assert(b and b.phase=='menu','battle menu did not start')
 local image
 if gen==2 then image=b:pic(b.battle.enemy,false)else image=b.enemy.sprite end
 local animated=false
 for _=1,90 do U.wait(2);local nextImage=gen==2 and b:pic(b.battle.enemy,false)or b.enemy.sprite;if image~=nextImage then animated=true;break end end
 assert(animated,'Crystal front animation frozen')
 if gen==1 then
  assert(b.player.__crystalFullBodyImage==b.player.sprite,'full body player not attached')
  assert(V.require('AnimatedBattleArt').hasWorldBack(b.player),'world back ownership missing')
  assert(not V.require('OverworldBattle').backPinned(),'duplicate UI back active')
 else
  local image,w,h,q=V.require('Gen2Staged').picFor(game,b,lead,true);assert(q and image==first.image,'stage did not use integrated provider')
 end
 assert(U.shot(game,os.getenv('SHOT_DIR')..'/integrated-crystal-battle.png'))
 game.mods.modOptions.BATTLE_ART_VOXEL_FORK.full_body_backs=false;U.wait(5)
 assert(not C.stagedPokemonSprite(lead,true),'full body opt-out broken')
 if gen==1 then assert(not b.player.__crystalFullBodyImage,'stale full body after opt-out')end
 local schema=game.mods.optionSchemas.BATTLE_ART_VOXEL_FORK
 local found={};for _,row in ipairs(schema)do found[row.key]=true end
 for _,key in ipairs({'crystalFront','crystalTrainers','crystalPlayerSprite','crystalBattlePic','crystalAnimations'})do assert(found[key],key..' absent from manager')end
 require('src.mods.Runtime').emit('mod.options_changed',{mod='BATTLE_ART_VOXEL_FORK',key='crystalAnimations',value='once'})
 assert(game.save.options.crystalAnimations=='once','manager option not applied')
 local rows=V.require('Crystal/options_screen').makeRows(game,gen==2)
 for _,r in ipairs(rows)do assert(r.step(game,1)~=false,r.id);assert(r.step(game,-1)~=false,r.id)end
 assert(game.mods.modOptions.BATTLE_ART_VOXEL_FORK.crystalAnimations==game.save.options.crystalAnimations,'legacy menu diverged from manager')
 print('[integrated Crystal] PASS',gen,'single owner, full body frames, shiny route, front animation, option controls, opt-out')
end
