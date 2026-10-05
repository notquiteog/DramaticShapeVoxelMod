-- Crystal or FRLG isolated QA profile; tests real option/update wiring, not audible assets.
return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua')
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 local gen=require('src.core.GameVersion').generation()
 if gen==3 then
  game:_handleBootAction({action='new_game',start={map='FR_ROCK_TUNNEL_1F',x=7,y=8,facing='down'}})
  require('src.ui.game3.map_preview_screen').reset()
 else
  game.stack:clear();assert(game:startWorld())
  assert(game.world:warpToMapId('DARK_CAVE_VIOLET_ENTRANCE',3,3,'down'));U.wait(5)
 end
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local C
 if gen==3 then C=V.require('Gen3Integration')else
  local P=require('src.render.Pipelines');C={setLevel=function(level)P.setLevel('voxel',level)end}
 end
 local A=V.require('NativeCaveAudio').current;assert(A,'native audio not installed')
 local S=V.require('CommunityVisuals').caveSound;local before=S:read()
 C.setLevel(3,game);S:setIndex(2,game);U.wait(90)
 assert(A.map and A.volume>0,'cave option did not reach update consumer')
 assert(A.sources['amb-cave.mp3']==false and A.errors['amb-cave.mp3'],'missing audio must fail silently')
 S:setIndex(1,game);U.wait(90);assert(A.volume==0 and A.map==nil,'OFF failed')
 S:setIndex(3,game);U.wait(50);assert(A.volume>0)
 C.setLevel(0,game);U.wait(90);assert(A.volume==0,'2D camera did not fade audio')
 S:setIndex(before,game)
 print('[PASS cave audio]',require('src.core.GameVersion').get(),'native option, cave identity, missing assets, OFF and camera fade')
 love.event.quit()
end
