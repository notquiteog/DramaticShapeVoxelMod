return function(game)
 local U=dofile('tests/drivers/util.lua')
 local P=require('src.render.Pipelines')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Smod,Mesher,State=V.require('Structures'),V.require('ChunkMesher'),V.require('VoxelState')
 local Disk,G=V.require('VoxelMeshDisk'),V.require('StaticGeometry')
 local dir=assert(os.getenv('SHOT_DIR'))
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 V.require('DayNight').setting:sync('day')
 V.require('RamPrecache').setting:sync('session')
 Disk.beginSession(true,true)
 P.setLevel('voxel',3)
 for _,row in ipairs({{'NATIONAL_PARK','crystal_depth_park_bench'},
  {'CHERRYGROVE_POKECENTER_1F','crystal_center_counter_ball'},
  {'RADIO_TOWER_4F','crystal_depth_radio_mixing_desk'},
  {'DARK_CAVE_VIOLET_ENTRANCE'}, {'NEW_BARK_TOWN'}}) do
  -- Locate the actual placed recipe, including the one-off radio desk.
  if row[2]=='crystal_depth_radio_mixing_desk' then
   for id,def in pairs(game.world.maps) do if def.tileset=='TILESET_RADIO_TOWER' then
    for _,b in ipairs(def.blocks) do if b==56 then row[1]=id end end
   end end
  end
  assert(game.world:setMap(row[1],7,5,'down'))
  local map=game.world.map
  assert(G.available() and Disk.staticEligible(map),'native map snapshot missing: '..row[1])
  local before={};for i,b in ipairs(map.def.blocks) do before[i]=b end
  local S=Smod.forMap(map)
  local target
  for _,f in ipairs(S.furniture or {}) do
   if f.id==row[2] then target=f;print('[reviewed prop]',row[1],f.id,f.height,f.x0,f.z0) end
  end
  if row[2] then assert(target,'recipe not placed: '..row[2]) end
  local x,y=target and math.floor((target.x0+target.x1)/32) or (row[1]=='DARK_CAVE_VIOLET_ENTRANCE' and 7 or 7),target and math.floor(target.z1/16)+2 or (row[1]=='DARK_CAVE_VIOLET_ENTRANCE' and 15 or 5)
  local pos
  for radius=0,8 do for dy=-radius,radius do for dx=-radius,radius do
   if not pos and map:inBounds(x+dx,y+dy) and map:isWalkableCell(x+dx,y+dy) then pos={x+dx,y+dy} end
  end end if pos then break end end
  assert(pos);assert(game.world:setMap(row[1],pos[1],pos[2],'up'))
  U.wait(5)
  for _=1,2400 do if Mesher.pending()==0 and State.ready then break end U.wait(1) end
  assert(Mesher.pending()==0 and State.ready,'scene failed to settle')
  U.wait(30);assert(U.shot(game,dir..'/'..row[1]..'.png'))
  for i,b in ipairs(before) do assert(map.def.blocks[i]==b,'scenery changed the map') end
  if row[1]=='NEW_BARK_TOWN' then
   for _,level in ipairs({2,5}) do P.setLevel('voxel',level);U.wait(60);assert(U.shot(game,dir..'/canopies_level_'..level..'.png')) end;P.setLevel('voxel',3)
  end
 end
 assert(Disk.ramStats().files>0,'native cache retained no geometry')
 local map=game.world.map
 assert(Disk.loadTerrain(map,'body')~=nil,'fresh terrain cache cannot be decoded')
 local got=Disk.loadAux(map);assert(got,'fresh decoration cache cannot be decoded')
 local files=Disk.ramStats().files
 Mesher.invalidate(nil,'known gaps warm cache check')
 U.wait(10)
 for _=1,2400 do if Mesher.pending()==0 and State.ready then break end U.wait(1) end
 assert(Mesher.pending()==0 and State.ready,'warm cache reload failed')
 assert(U.shot(game,dir..'/warm_cache.png'))
 for _,e in ipairs(game.mods.errors) do error('companion loader error: '..e) end
 print('[known gaps] PASS: reviewed props, cave, steep canopy, native collision, cache encode/decode/reload; '..files..' cached records')
 love.event.quit()
end
