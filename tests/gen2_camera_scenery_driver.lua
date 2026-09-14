-- Native 1440p camera review. Requires the disposable engine driver launcher.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local P=require('src.render.Pipelines')
 local M,S,F=V.require('ChunkMesher'),V.require('VoxelState'),V.require('FirstPerson')
 local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(2560,1440,{resizable=true})
 V.require('DayNight').setting:sync('day')
 game.mods.modOptions.overworld_wild_spawns.catch_hud_size=0
 -- Visual-only fixture: keep conversations/encounters from taking the camera.
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 for _,row in ipairs({{'NEW_BARK_TOWN',7,5},{'CHERRYGROVE_POKECENTER_1F',2,3},
   {'ELMS_LAB',4,9},{'PLAYERS_HOUSE_1F',3,5},{'ROUTE_29',10,7}}) do
  game.stack:clear()
  assert(game.world:setMap(row[1],row[2],row[3],'up'))
  assert(game.world.map:isWalkableCell(row[2],row[3]),'camera fixture is inside a solid cell: '..row[1])
  P.setLevel('voxel',3);U.wait(150)
  for _=1,2400 do if M.pending()==0 and S.ready then break end U.wait(1) end
  assert(M.pending()==0 and S.ready,'scene did not settle')
  for _,level in ipairs({6,7}) do
   P.setLevel('voxel',level);U.wait(45)
   assert(F.engaged() and F.driving(),'first/third-person camera did not accept input')
   for i,yaw in ipairs({math.pi,math.pi*.5,0,-math.pi*.5}) do
    F.lookBy(yaw-F.yaw,.14-F.pitch);U.wait(8)
    assert(math.abs(math.sin(F.yaw-yaw))<.01,'camera yaw did not hold')
    assert(U.shot(game,dir..'/'..row[1]..'_'..level..'_'..i..'.png'))
   end
  end
 end
 print('[camera scenery] PASS: five maps, first and third person, four headings, 40 views')
 love.event.quit()
end
