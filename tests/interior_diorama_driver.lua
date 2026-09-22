return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local generation=os.getenv('POKEPORT_VERSION');local fr=generation=='firered'
 assert(love.filesystem.getIdentity()==(fr and 'firered-hd2d-qa' or 'battle-art-crossgen-qa'))
 love.window.setMode(1280,960,{resizable=true})
 if fr then game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})end
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local R=V.require('Voxel3D');local projection=R.viewProjection;local inspection
 R.viewProjection=function(cx,cz,w,h)if inspection then R.camera=inspection;cx,cz=inspection.focus[1],inspection.focus[3]end;return projection(cx,cz,w,h)end
 if os.getenv('QA_INVENTORY')=='1' then
  local Interior=V.require('InteriorDiorama');local maps=fr and game.data.maps or generation=='crystal' and game.world.maps or game.data.maps
  local report=assert(io.open(dir..'/coverage.csv','w'));report:write('map,tileset_or_pair,room_frame,hd_scene\n')
  local total,rooms,hd=0,0,0
  for id,def in pairs(maps)do
   if fr then require('src.core.game3.map').ensureMidLayout(game,id,def)end
   local profile=Interior.forMap(def,fr and 3 or generation=='crystal' and 2 or 1)
   local pair=fr and def.midLayout and def.midLayout.pair
   local enabled=not fr or V.require('Gen3Tilesets').supports(def,V.require('Gen3Tilesets').resolve(pair,require('src.import.gba.versions').TILESET_PAIRS))
   total=total+1;if profile then rooms=rooms+1;if enabled then hd=hd+1 end end
   report:write(('%s,%s,%s,%s\n'):format(id,pair or def.tileset or '',tostring(profile~=nil),tostring(enabled)))
  end
  report:close();print('[interior coverage]',generation,total,rooms,hd)
 end
 local list=fr and {'FR_PLAYERS_HOUSE_1F','FR_OAKS_LAB','FR_VIRIDIAN_CITY_MART','FR_VIRIDIAN_CITY_POKEMON_CENTER_1F'} or generation=='crystal' and {'PLAYERS_HOUSE_1F','ELMS_LAB','CHERRYGROVE_MART','CHERRYGROVE_POKECENTER_1F'} or {'REDS_HOUSE_1F','OAKS_LAB','VIRIDIAN_MART','VIRIDIAN_POKECENTER'}
 if os.getenv('QA_INTERIORS')then list={};for id in os.getenv('QA_INTERIORS'):gmatch('[^,]+')do list[#list+1]=id end end
 if generation=='crystal' then game.world.trySceneScript=function()return false end;game.world.noWildEncounters=true;V.require('DayNight').setting:sync('day')end
 for _,id in ipairs(list)do
  inspection=nil
  local def,W,D
  if fr then
   local Map=require('src.core.game3.map');assert(Map.load(nil,game,id,{x=4,y=5,facing='down'}));def=Map.currentDef();W,D=def.width*16,def.height*16
   game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.setLevel(3,game)
   print('[room]',id,def.midLayout.pair,def.width,def.height,def.environment,def.mapType)
  else
   if generation=='crystal' then game.stack:clear();assert(game.world:setMap(id,3,4,'down'))else U.teleport(game,id,3,4,'down')end;def=(generation=='crystal' and game.world.map or game.stack:top().map).def;W,D=def.width*32,def.height*32
   require('src.render.Pipelines').setLevel('voxel',3)
   print('[room]',id,def.tileset,def.width,def.height,def.environment)
  end
  -- Choose a walkable, dry, non-warp cell near the room's southern center.
  -- Never put a first-person camera into a countertop for a visual fixture.
  local current=not fr and (generation=='crystal' and game.world.map or game.stack:top().map)
  local cols,rows=def.width*(fr and 1 or 2),def.height*(fr and 1 or 2)
  local best,position;local Collision=fr and require('src.core.game3.collision')
  for y=1,rows-2 do for x=1,cols-2 do
   local free
   if fr then free=Collision.isWalkable(x,y) and not Collision.isWater(x,y) and not Collision.warpAt(x,y)
   else free=current:isWalkableCell(x,y) and not current:isWaterCell(x,y) and not current:warpAtCell(x,y)end
   local score=(x-cols*.5)^2+(y-rows*.75)^2
   if free and (not best or score<best)then best,position=score,{x,y}end
  end end
  assert(position,'no safe camera cell: '..id)
  if fr then require('src.core.game3.player').reset(position[1],position[2],'up')
  elseif generation=='crystal' then assert(game.world:setMap(id,position[1],position[2],'up'))
  else U.teleport(game,id,position[1],position[2],'up')end
  if fr then
   local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end
   local vm=space.getVm();if vm then vm:halt(true)end
   require('src.ui.game3.message').reset()
  end
  U.wait(180);if generation=='crystal' then game.stack:clear()end
  if not fr then for _=1,2400 do if V.require('ChunkMesher').pending()==0 and V.require('VoxelState').ready then break end;U.wait(1)end end
  local dist=math.max(W,D)*1.35
  inspection={eye={W/2,dist*.9,D/2+dist},focus={W/2,4,D/2},fov=math.rad(48),up={0,1,0},curve=0}
  U.wait(4);assert(U.shot(game,dir..'/'..id..'.png'))
  if fr then assert(game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.active,'native fallback: '..id)end
  if os.getenv('QA_GAMEPLAY')=='1' then
   inspection=nil;U.wait(6);assert(U.shot(game,dir..'/'..id..'_gameplay.png'))
   for _,level in ipairs({6,7})do
    if fr then local c=game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera;c.setLevel(level,game);c.yaw=0;c.pitch=.1
    else require('src.render.Pipelines').setLevel('voxel',level);U.wait(20);local fp=V.require('FirstPerson');fp.yaw=math.pi;fp.pitch=.1 end
    U.wait(25);assert(U.shot(game,dir..'/'..id..'_camera'..level..'.png'))
   end
   if fr then game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.setLevel(3,game)else require('src.render.Pipelines').setLevel('voxel',3)end
  end
  if os.getenv('QA_VIEWS')=='1' then
   for _,view in ipairs({{'side',{W/2+dist,dist*.6,D/2}}, {'back',{W/2,dist*.6,D/2-dist}}, {'inside',{W/2,23,D*.75}}})do
    inspection={eye=view[2],focus={W/2,12,view[1]=='inside' and 0 or D/2},fov=math.rad(60),up={0,1,0},curve=0}
    U.wait(3);assert(U.shot(game,dir..'/'..id..'_'..view[1]..'.png'))
   end
  end
 end
 inspection=nil;R.viewProjection=projection
 local outside=fr and 'FR_PALLET_TOWN' or generation=='crystal' and 'NEW_BARK_TOWN' or 'PALLET_TOWN'
 if fr then
  assert(require('src.core.game3.map').load(nil,game,outside,{x=10,y=9,facing='down'}));game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.setLevel(3,game)
 elseif generation=='crystal' then
  assert(game.world:setMap(outside,6,7,'down'));game.stack:clear();require('src.render.Pipelines').setLevel('voxel',3)
 else U.teleport(game,outside,8,8,'down');require('src.render.Pipelines').setLevel('voxel',3)end
 U.wait(180)
 assert(R.interior==nil,'interior lighting escaped its scene')
 assert(U.shot(game,dir..'/returned-field.png'))
 print('[interiors] PASS',generation,#list,'rooms, native camera/turntables and field return');love.event.quit()
end
