return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local P=require('src.render.Pipelines');local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 for _,p in ipairs{{'SS_ANNE_BOW',6,7},{'SS_ANNE_3F',5,3},{'CELADON_MART_ROOF',5,5}}do
  if game.data.maps[p[1]]then
   U.teleport(game,p[1],p[2],p[3],'up');P.setLevel('voxel',0);U.wait(40);U.shot(game,dir..'/'..p[1]..'-native.png')
   P.setLevel('voxel',4);U.wait(150);U.shot(game,dir..'/'..p[1]..'-model.png')
  else print('MISSING',p[1])end
 end
 love.event.quit()
end
