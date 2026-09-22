-- Actual Crystal recipe priority and free-camera check, disposable profile only.
return function(game)
 assert(love.filesystem.getIdentity()=='battle-art-crossgen-qa')
 local U=dofile('tests/drivers/util.lua')
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local P=require('src.render.Pipelines')
 local Mesher,State=V.require('ChunkMesher'),V.require('VoxelState')
 local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(1600,900,{resizable=true})
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 V.require('DayNight').setting:sync('day')
 for _,case in ipairs({{'RADIO_TOWER_1F','crystal_depth_radio_desk_terminal'},
  {'RADIO_TOWER_5F','crystal_depth_radio_equipment'},
  {'LAV_RADIO_TOWER_1F','crystal_depth_radio_mixing_desk'}})do
  game.stack:clear();assert(game.world:setMap(case[1],7,5,'up'))
  local map=game.world.map
  local blocks={};for i,b in ipairs(map.def.blocks)do blocks[i]=b end
  local S=V.require('Structures').forMap(map);local target
  for _,f in ipairs(S.furniture or {})do if f.id==case[2]then assert(not target,'duplicate model');target=f end end
  assert(target,'whole object recipe did not place: '..case[2])
  if case[1]=='RADIO_TOWER_1F' then
   assert(target.x1-target.x0==32,'desk lost its adjoining counter')
   assert(target.height<=18,'reception desk became a tall cabinet')
  end
  local tx,ty=math.floor((target.x0+target.x1)/32),math.floor(target.z1/16)+2
  local pos,best
  for y=1,map.heightCells-2 do for x=1,map.widthCells-2 do
   if map:isWalkableCell(x,y) and not map._warpAt[y*1024+x] then
    local d=(x-tx)^2+(y-ty)^2;if not best or d<best then pos,best={x,y},d end
   end
  end end
  assert(pos);assert(game.world:setMap(case[1],pos[1],pos[2],'up'))
  P.setLevel('voxel',3);U.wait(20)
  for _=1,2400 do if Mesher.pending()==0 and State.ready then break end U.wait(1)end
  assert(Mesher.pending()==0 and State.ready)
  game.stack:clear();game.world.mapSign=nil
  for _,level in ipairs({3,6,7})do
   P.setLevel('voxel',level);U.wait(35)
   if level>=6 then local F=V.require('FirstPerson');F.lookBy(-F.yaw,.12-F.pitch);U.wait(8)end
   assert(U.shot(game,dir..'/'..case[1]..'_'..level..'.png'))
  end
  for i,b in ipairs(blocks)do assert(map.def.blocks[i]==b,'model changed map data')end
 end
 print('[radio desk] PASS whole desk, independent equipment and mixing desk, nine native camera views, unchanged map data')
 love.event.quit()
end
