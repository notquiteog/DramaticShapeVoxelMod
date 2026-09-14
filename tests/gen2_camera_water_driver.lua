return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local P=require('src.render.Pipelines')
 local FP=V.require('FirstPerson')
 local Voxel=V.require('VoxelState')
 local Mesher=V.require('ChunkMesher')
 local dir=assert(os.getenv('SHOT_DIR'))
 game.world.trySceneScript=function()return false end
 game.world.tryWildEncounter=function()return false end
 local function settle()
  U.wait(20)
  for _=1,2400 do if Mesher.pending()==0 and Voxel.ready then break end U.wait(1) end
  U.wait(100)
 end
 assert(game.world:setMap('CHERRYGROVE_CITY',5,12,'down'))
 P.setLevel('voxel',3);P.setLevel('tiltshift',0);V.require('DayNight').setting:sync('day')
 local Anim=V.require('Gen2AtlasAnimation')
 local Water=V.require('Water')
 local originalApply,originalDraw=Anim.apply,Water.draw
 local selected,drawn={},{}
 Anim.apply=function(map,base,data)
  local image=originalApply(map,base,data)
  if map.id=='CHERRYGROVE_CITY' then assert(image~=base,'native animation never replaced the static atlas');selected[image]=true end
  return image
 end
 Water.draw=function(mesh,texture,...)
  if selected[texture] then drawn[texture]=true end
  return originalDraw(mesh,texture,...)
 end
 settle()
 U.wait(180)
 local count=0;for _ in pairs(drawn)do count=count+1 end
 assert(count>=4,'fewer than four native atlas frames reached drawn water: '..count)
 assert(U.shot(game,dir..'/CRYSTAL_water.png'))
 print('[animation] real water draw consumed '..count..' atlas frames')
 Anim.apply,Water.draw=originalApply,originalDraw
 assert(game.world:setMap('ELMS_LAB',4,4,'down'));settle()
 assert(U.shot(game,dir..'/ELMS_LAB_small_balls.png'))
 assert(game.world:setMap('NEW_BARK_TOWN',7,5,'down'));settle()
 assert(Voxel.freeCamAvailable(),'native camera walk unavailable')
 for _,level in ipairs({6,7}) do
  assert(game.world:setMap('NEW_BARK_TOWN',7,5,'down'))
  P.setLevel('voxel',level);U.wait(90)
  assert(Voxel.level==level and FP.driving(),'first/third person not driving')
  -- Turn the camera east. Forward must move east through normal grid steps.
  FP.yaw=math.pi/2
  local player=game.world.player
  local x,y=player.cellX,player.cellY
  U.hold(game,'up',24);U.wait(24)
  assert(player.cellX>x and player.cellY==y,'camera-relative forward did not follow east yaw: '..x..','..y..' -> '..player.cellX..','..player.cellY..' yaw='..FP.yaw..' held='..tostring(game.world.heldDir))
  assert(player.px==player.cellX*16 and player.py==player.cellY*16,'native landing failed to snap to grid')
  assert(U.shot(game,dir..(level==6 and '/CRYSTAL_first_person.png' or '/CRYSTAL_third_person.png')))
  print('[camera] rung '..level..' walked native grid from '..x..','..y..' to '..player.cellX..','..player.cellY)
 end
 P.setLevel('voxel',3);U.wait(60)
 assert(not FP.driving(),'camera input retained after exit')
 print('[camera/water] PASS: actual rendered water frames, small lab balls, both camera rungs and native steps')
end
