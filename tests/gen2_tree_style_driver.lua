return function(game)
 assert(love.filesystem.getIdentity()=='battle-art-crossgen-qa')
 local U=dofile('tests/drivers/util.lua');local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local P=require('src.render.Pipelines');local Style=V.require('TreePresentation')
 local Mesher,State=V.require('ChunkMesher'),V.require('VoxelState')
 local dir=assert(os.getenv('SHOT_DIR'));love.window.setMode(1600,900,{resizable=true})
 game.world.trySceneScript=function()return false end;game.world.rollEncounter=function()return nil end
 V.require('DayNight').setting:sync('day')
 game.stack:clear();assert(game.world:setMap('NEW_BARK_TOWN',7,8,'up'))
 assert(Style.flat(),'flat trunks not the default')
 for _,style in ipairs({'flat','solid','flat'})do
  Style.setting:sync(style);Style.changed(Style.setting.key);P.setLevel('voxel',3);U.wait(40)
  for _=1,2400 do if Mesher.pending()==0 and State.ready then break end U.wait(1)end
  assert(Mesher.pending()==0 and State.ready,'tree rebuild failed')
  game.stack:clear();game.world.mapSign=nil
  for _,level in ipairs({3,6,7})do
   P.setLevel('voxel',level);U.wait(25)
   if level>=6 then local F=V.require('FirstPerson');F.lookBy(.5-F.yaw,.12-F.pitch);U.wait(8)end
   assert(V.require('Voxel3D').canopyFacing==(level>=6))
   assert(U.shot(game,dir..'/crystal_'..style..'_'..level..'.png'))
  end
 end
 dofile('/home/admin/Projects/DramaticShapeVoxelMod/tests/canopy_billboard_gpu.lua')(V)
 print('[Crystal trunks] PASS live flat/solid/flat rebuilds, static/first/rotating third views and shared GPU transform')
 love.event.quit()
end
