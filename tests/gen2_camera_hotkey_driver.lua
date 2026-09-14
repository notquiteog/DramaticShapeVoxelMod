-- Real input routing with all cart companions. No direct pipeline changes
-- after the starting preset: every camera transition goes through the 3 key.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local P=require('src.render.Pipelines')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 assert(game.world:setMap('NEW_BARK_TOWN',7,5,'down'))
 U.wait(120)
 P.setLevel('voxel',1)
 assert(P.maxLevel('voxel')==7,'first/third person unavailable')
 for _,level in ipairs({4,5,6,7,0,2,3,4}) do
  love.keypressed('3','3',false);love.keyreleased('3','3')
  assert(P.level('voxel')==level,'3 failed to reach camera level '..level..' (got '..P.level('voxel')..')')
  assert(game.options.pipelines.voxel==level,'camera choice was not persisted')
  U.wait(45)
  if level==6 then
   assert(V.require('FirstPerson').driving(),'first-person camera never activated')
   if os.getenv('SHOT_DIR') then assert(U.shot(game,os.getenv('SHOT_DIR')..'/first_person.png')) end
  end
 end
 local before=P.level('voxel')
 game:openStartMenu();U.wait(3)
 love.keypressed('3','3',false);love.keyreleased('3','3')
 assert(P.level('voxel')==before,'camera key changed view through a menu')
 print('[camera keys] PASS: full angle cycle, first/third person, persisted choice and menu gate')
 love.event.quit()
end
