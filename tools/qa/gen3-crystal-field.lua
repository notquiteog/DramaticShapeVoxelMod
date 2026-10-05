-- Crystal or FRLG isolated QA profile; tests real option/update wiring, not audible assets.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local gen=require('src.core.GameVersion').generation()
 if gen==3 then
  game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=7,y=8,facing='down'}})
  require('src.ui.game3.map_preview_screen').reset()
 else
  game.stack:clear();assert(game:startWorld())
  assert(game.world:warpToMapId('DARK_CAVE_VIOLET_ENTRANCE',3,3,'down'));U.wait(5)
 end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C
 if gen==3 then C=V.require('Gen3Integration')else
  local P=require('src.render.Pipelines');C={setLevel=function(level)P.setLevel('voxel',level)end}
 end
 local Crystal=V.require('NativeCrystalArt');local saved=Crystal.pack:read();Crystal.pack:setIndex(1,game)
 local opts=game.mods.modOptions[V.mod.id];local mode,portrait=opts.crystalTrainers,opts.crystalPlayerSprite
 opts.crystalTrainers='all';opts.crystalPlayerSprite='gold_flip.png'
 C.setLevel(3,game);U.wait(100)
 local Sp=require('src.core.game3.ow_sprites');local P=require('src.core.game3.player')
 local gid=Sp.playerGraphicsId(game);local hero=Sp.getDraw(gid);assert(hero and hero.crystalNative,'player did not adopt selected sheet')
 assert(hero.width==16 and hero.height==16)
 U.shot(game,os.getenv('SHOT_DIR')..'/crystal-gold-field.png')
 assert(Sp.getDraw(80).crystalNative,'Brock sheet not adapted')
 P.biking=true;local bike=Sp.getDraw(Sp.playerGraphicsId(game));assert(bike.crystalNative);P.biking=false
 opts.crystalTrainers='none';assert(not Sp.getDraw(gid).crystalNative,'NONE did not restore native')
 opts.crystalTrainers,opts.crystalPlayerSprite=mode,portrait;Crystal.pack:setIndex(saved,game)
 print('[PASS native Crystal field] player, bike, named trainer, dimensions and NONE')
 love.event.quit()
end
