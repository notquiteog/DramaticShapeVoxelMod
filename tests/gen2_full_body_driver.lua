return function(game)
 local U=dofile('/home/admin/Apps/Gen1Recomp/source/tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Mon=require('src.battle.gen2.Mon');local P=require('src.render.Pipelines')
 local E=assert(game.mods.exports.crystal_animated_sprites_with_shiny_visuals)
 game.mods.modOptions.crystal_animated_sprites_with_shiny_visuals={full_body_backs=true}
 local w=game.world;w.trySceneScript=function()return false end;w.noWildEncounters=true
 assert(w:setMap('ROUTE_29',12,6,'down'));P.setLevel('voxel',3)
 V.require('DayNight').setting:sync('day');love.window.setMode(2560,1440,{resizable=true})
 local lead=Mon.new(game.data,'CYNDAQUIL',18);game.save.party={lead}
 U.wait(180);game.stack:clear()
 local first=assert(E.stagedPokemonSprite(lead,true));assert(first.fullBody and first.quad)
 local changed=false
 for _=1,20 do U.wait(2);if E.stagedPokemonSprite(lead,true).frame~=first.frame then changed=true end end
 assert(changed,'full-body animation frozen')
 assert(not E.stagedPokemonSprite(lead,false),'front art unexpectedly replaced')
 lead.shiny=true;local shiny=assert(E.stagedPokemonSprite(lead,true));assert(shiny.variant=='shiny' and shiny.image~=first.image);lead.shiny=false
 assert(w:startBattle({wild=Mon.new(game.data,'SENTRET',20)}))
 local s
 for _=1,1200 do s=game.stack:top();if s and s.battle and s.phase=='menu' then break end;U.tap(game,'a');U.wait(3) end
 assert(s and s.phase=='menu')
 local stage=V.require('Gen2Staged')
 local img,iw,ih,quad=stage.picFor(game,s,lead,true)
 assert(img==first.image and iw==first.width and ih==first.height and quad,'stage ignored public provider')
 for _,species in ipairs({'CYNDAQUIL','TOTODILE','CHIKORITA','RAIKOU','HO_OH'}) do
  lead.species=species;U.wait(60)
  assert(stage.drawn.player==lead,'staged player missing')
  assert(U.shot(game,assert(os.getenv('SHOT_DIR'))..'/'..species..'.png'))
 end
 lead.species='CYNDAQUIL'
 game.mods.modOptions.crystal_animated_sprites_with_shiny_visuals.full_body_backs=false
 assert(not E.stagedPokemonSprite(lead,true),'option did not restore Crystal backs')
 local _,_,_,fallback=stage.picFor(game,s,lead,true);assert(not fallback,'fallback retained full-body atlas')
 print('[full body] PASS animated public provider, shiny routing, five staged species, opt-out fallback')
 love.event.quit()
end
