return function(game)
  local U=dofile('tests/drivers/util.lua')
  local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
  assert(require('src.core.Version').engine=='0.2.73','wrong QA engine')
  assert(require('src.core.SaveData').getCart()=='johto_diorama','cart scope missing')
  dofile('/home/admin/Projects/DramaticShapeVoxelMod/tests/canopy_billboard_gpu.lua')(V)
  local P=require('src.render.Pipelines')
  local F,M,S=V.require('FirstPerson'),V.require('ChunkMesher'),V.require('VoxelState')
  love.window.setMode(2560,1440,{resizable=true})
  V.require('DayNight').setting:sync('day')
  game.world.trySceneScript=function()return false end
  game.world.rollEncounter=function()return nil end
  local dir=assert(os.getenv('SHOT_DIR'))
  for _,row in ipairs({{'NEW_BARK_TOWN',7,8},{'ROUTE_29',12,6}}) do
    game.stack:clear();assert(game.world:setMap(row[1],row[2],row[3],'up'))
    assert(game.world.map:isWalkableCell(row[2],row[3]))
    P.setLevel('voxel',3);U.wait(150)
    for _=1,2400 do if M.pending()==0 and S.ready then break end U.wait(1) end
    assert(M.pending()==0 and S.ready,'scene failed to settle')
    game.stack:clear()
    assert(U.shot(game,dir..'/'..row[1]..'_diorama.png'))
    for _,level in ipairs({6,7}) do
      P.setLevel('voxel',level);U.wait(40)
      assert(F.engaged() and F.driving())
      for i,yaw in ipairs({math.pi,math.pi*.5,0,-math.pi*.5}) do
        F.lookBy(yaw-F.yaw,.14-F.pitch);U.wait(8)
        assert(U.shot(game,dir..'/'..row[1]..'_'..level..'_'..i..'.png'))
      end
    end
  end
  -- Retaining the 1ST setting must not lose foliage when the battle rig owns
  -- the eye. The battle sprite provider regression checks its animation too.
  P.setLevel('voxel',6);U.wait(40)
  dofile('/home/admin/Projects/DramaticShapeVoxelMod/tests/gen2_full_body_driver.lua')(game,{keepCamera=true})
end
