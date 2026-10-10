return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'));local P=require('src.render.Pipelines')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;local F=V.require('FirstPerson');local yaw=math.pi
 local update=game.update;game.update=function(self,dt)F.yaw=yaw;F.pitch=.05;return require('src.mods.Runtime').call('core.update',update,self,dt)end
 for _,v in ipairs{{'front',2,8,math.pi},{'rear',2,3,0},{'side',4,6,-math.pi/2}}do
  yaw=v[4];U.teleport(game,'CELADON_MANSION_ROOF',v[2],v[3],'up');P.setLevel('voxel',os.getenv('ROOF_ORBIT')=='1'and 7 or 6);U.wait(180)
  local map=game.stack:top().map
  assert(map.id=='CELADON_MANSION_ROOF')
  assert(V.require('VoxelScene').skyColor(map,1),'open-air rooftop must retain a sky')
  assert(V.require('InteriorDiorama').profile(map.def,1)==nil,'artificial room around roof')
  U.shot(game,dir..'/'..v[1]..'.png')
 end
 love.event.quit()
end
