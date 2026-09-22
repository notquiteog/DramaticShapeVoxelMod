-- Real 0.2.73 GPU checks; run only against the isolated QA profiles.
return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local E=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK);local V=E.lib
 local D=V.require('RenderDistance');local total={forest=0,water=0,mountain=0}
 love.window.setMode(1280,720,{resizable=true})
 local gen3=V.require('Generation').isGen3()
 local maps=gen3 and {'FR_PALLET_TOWN','FR_CINNABAR_ISLAND','FR_ROUTE_3','FR_VIRIDIAN_FOREST'} or {'CHERRYGROVE_CITY','ROUTE_29','BLACKTHORN_CITY','ILEX_FOREST'}
 local S=V.require(gen3 and 'Gen3Scene' or 'Gen2Boundary')
 local function camera(level,yaw)
  if gen3 then E.firered.camera.setLevel(level,game);E.firered.camera.yaw=yaw or 0;E.firered.camera.pitch=.15
  else
   require('src.render.Pipelines').setLevel('voxel',level)
  end
 end
 if gen3 then
  assert(love.filesystem.getIdentity()=='firered-hd2d-qa')
  game:_handleBootAction({action='new_game',start={map=maps[1],x=10,y=9,facing='down'}})
 else
  assert(love.filesystem.getIdentity()=='battle-art-crossgen-qa')
  game.world.trySceneScript=function()return false end;game.world.noWildEncounters=true
  V.require('DayNight').setting:sync('day')
 end
 for _,id in ipairs(maps)do
  if gen3 then assert(require('src.core.game3.map').load(nil,game,id,{x=8,y=8,facing='up'}))
  else assert(game.world:setMap(id,8,8,'up'));game.stack:clear()end
  -- Inspect from an actual walkable cell, never from a roof, tree or lake.
  local map=not gen3 and game.world.map
  local def=gen3 and require('src.core.game3.map').currentDef() or map.def
  local w,h=def.width*(gen3 and 1 or 2),def.height*(gen3 and 1 or 2)
  local Collision=gen3 and require('src.core.game3.collision')
  local target,best
  for y=1,h-2 do for x=1,w-2 do
   local free=gen3 and Collision.isWalkable(x,y) and not Collision.isWater(x,y) and not Collision.warpAt(x,y)
    or not gen3 and map:isWalkableCell(x,y) and not map:isWaterCell(x,y) and not map:warpAtCell(x,y)
   local score=(x-w*.5)^2+(y-h*.5)^2
   if free and (not best or score<best) then target,best={x,y},score end
  end end
  assert(target,'no safe scenery fixture')
  if gen3 then require('src.core.game3.player').reset(target[1],target[2],'up')
  else assert(game.world:setMap(id,target[1],target[2],'up'));game.stack:clear()end
  if gen3 then
   require('src.ui.game3.map_preview_screen').dismiss()
   require('src.ui.game3.map_name_popup').dismiss()
  end
  D.setting:sync(32);camera(3);U.wait(15)
  if not gen3 then
   for _=1,240 do if S.map==game.world.map then break end;U.wait(1)end
   assert(S.map==game.world.map,"boundary scene did not finish building")
  end
  if not gen3 then
   local Mesher=V.require('ChunkMesher')
   for _=1,1800 do if Mesher.pending()==0 and V.require('VoxelState').ready then break end;U.wait(1)end
   assert(Mesher.pending()==0 and V.require('VoxelState').ready,'scene queue unfinished')
   game.world.mapSign=nil
  end
  U.wait(3)
  if gen3 then assert(E.firered.camera.active,'native fallback')end
  local counts=gen3 and S.fillCounts or S.counts
  for k in pairs(total)do total[k]=total[k]+(counts[k]or 0)end
  print('[boundary map]',id,counts.forest,counts.water,counts.mountain,counts.ground,'builds',S.builds)
  assert((counts.forest or 0)+(counts.water or 0)+(counts.mountain or 0)>0,'no contextual fill')
  assert(U.shot(game,dir..'/'..id..'_static.png'))
  local n=S.builds;camera(6,1.2);U.wait(35)
  if not gen3 then local F=V.require('FirstPerson');F.lookBy(1.2-F.yaw,.15-F.pitch);U.wait(4)end
  assert(S.builds==n,'first-person rebuilt stable scenery')
  assert(U.shot(game,dir..'/'..id..'_first.png'))
  camera(7,1.2);U.wait(35)
  if not gen3 then local F=V.require('FirstPerson');F.lookBy(1.2-F.yaw,.15-F.pitch);U.wait(4)end
  assert(S.builds==n,'rotation rebuilt stable scenery')
  assert(U.shot(game,dir..'/'..id..'_rotate.png'))
 end
 local farRegions
 for _,value in ipairs({'auto',16,32,64,false})do
  D.setting:sync(value);camera(3);U.wait(4)
  local expected=value=='auto' and 512 or value and value*16 or nil
  assert(D.radius()==expected,'distance option not read')
  if gen3 then assert(S.distance.full==(value==false));if value~=false then assert(S.distance.radius==expected/16)end end
  if gen3 and value==64 then farRegions=S.distance.regions end
  if gen3 and value==false then assert(S.distance.regions>=farRegions,'FULL dropped FAR connected maps')end
  assert(U.shot(game,dir..'/distance_'..tostring(value)..'.png'))
  print('[boundary distance]',tostring(value),'builds',S.builds)
 end
 assert(total.forest>0 and total.water>0 and total.mountain>0,'missing biome coverage')
 assert(V.require('Voxel3D').fog==nil,'fog leaked beyond scene')
 print('[boundary QA] PASS native coast, forest, mountain, static/rotating views and all five distances',gen3 and 'FireRed' or 'Crystal')
 love.event.quit()
end
