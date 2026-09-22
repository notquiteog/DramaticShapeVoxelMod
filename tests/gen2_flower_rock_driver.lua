-- Real imported Crystal maps: flower silhouettes, rock ground continuity,
-- shoreline variation and unchanged native tiles/collision. Disposable profile.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Map=require('src.world.gen2.Map')
 local Permission=require('src.world.gen2.Permissions')
 local mesher,voxel=V.require('ChunkMesher'),V.require('VoxelState')
 local Shape,Structures=V.require('TileShape'),V.require('Structures')
 local flowers=V.require('Gen2Flowers')
 local dir=assert(os.getenv('SHOT_DIR'))
 love.window.setMode(1920,1080,{resizable=true})
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 if game.mods.modOptions.overworld_wild_spawns then game.mods.modOptions.overworld_wild_spawns.catch_hud_size=0 end
 require('src.render.Pipelines').setLevel('voxel',3)
 assert(V.require('CommunityVisuals').crystalDepth(game.world.map),'HD-2D must be default')
 V.require('DayNight').setting:sync('day')
 local ids={};for id in pairs(game.world.maps) do ids[#ids+1]=id end;table.sort(ids)
 local cases,best={},{}
 for _,id in ipairs(ids) do
  local def=game.world.maps[id];local ts=game.world.tilesets[def.tileset]
  local map=Map.new(def,ts)
  local profile=flowers.forTileset(ts)
  if profile then
   local n,fx,fy=0
   for y=0,def.height*4-1 do for x=0,def.width*4-1 do
    if map:tileAt(x,y)==3 then n=n+1;fx,fy=fx or x,fy or y end
   end end
   if n>0 and (not best[ts.id] or n>best[ts.id].count) then
    best[ts.id]={id=id,x=math.floor(fx/2),y=math.floor(fy/2),name=ts.id..'_flowers',count=n}
   end
  end
 end
 for _,ts in ipairs({'TILESET_JOHTO','TILESET_JOHTO_MODERN','TILESET_FOREST','TILESET_PARK','TILESET_KANTO'}) do
  if best[ts] then cases[#cases+1]=best[ts] end
 end
 for _,c in ipairs({{id='CHERRYGROVE_CITY',x=5,y=12,name='coastal_rocks'},
   {id='ROUTE_46',x=6,y=9,name='land_boulders'},
   {id='ROUTE_14',x=9,y=10,name='kanto_rocks'}}) do cases[#cases+1]=c end
 local flowerCount=0
 for _,c in ipairs(cases) do
  local def=game.world.maps[c.id];local map=Map.new(def,game.world.tilesets[def.tileset])
  local px,py,dist
  for y=1,map.heightCells-2 do for x=1,map.widthCells-2 do
   if Permission.of(map:cellCollision(x,y))==Permission.LAND then
    local d=(x-c.x)^2+(y-c.y-2)^2
    if not dist or d<dist then px,py,dist=x,y,d end
   end
  end end
  assert(px,'no camera ground')
  assert(game.world:setMap(c.id,px,py,'up'))
  local before={}
  for y=0,def.height*4-1 do for x=0,def.width*4-1 do before[#before+1]=game.world.map:tileAt(x,y) end end
  V.require('CommunityVisuals').invalidate()
  U.wait(8)
  for _=1,2400 do if mesher.pending()==0 and voxel.ready then break end;U.wait(1) end
  assert(mesher.pending()==0 and voxel.ready,'scene failed '..c.id)
  U.wait(140);game.world.mapSign=nil
  local S=Structures.forMap(game.world.map)
  local function key(x,y)return (y+64)*4096+x+64 end
  if map.tileset.id=='TILESET_PARK' then
   local rims=0
   for y=0,def.height*4-1 do for x=0,def.width*4-1 do
    if flowers.bedAt(game.world.map,x,y) then
     local tile=game.world.map:tileAt(x,y)
     if tile~=1 and tile~=3 then
      local s=S.shapeAt[key(x,y)]
      assert(s.class=='gardenrim' and s.h==3,'flowerbed still folds into wall: '..x..','..y..' '..tostring(s.class))
      rims=rims+1
     end
    end
   end end
   assert(rims>0,'native Park bed not recognized')
  end
  if c.count then
   local profile=flowers.forTileset(map.tileset)
   local claimed=0
   for y=0,def.height*4-1 do for x=0,def.width*4-1 do
    if map:tileAt(x,y)==3 then
     assert(S.skip[key(x,y)] and S.ground[key(x,y)]==profile.ground,'flat flower patch remained')
     claimed=claimed+1
    end
   end end
   assert(#S.flowerQuads==claimed,'expected one flat native card per flower tile')
   assert(mesher.flowers(game.world.map),'flower mesh never uploaded')
   flowerCount=flowerCount+claimed
  end
  local n=0
  for y=0,def.height*4-1 do for x=0,def.width*4-1 do n=n+1;assert(before[n]==game.world.map:tileAt(x,y),'source map mutated') end end
  assert(U.shot(game,dir..'/'..c.name..'.png'))
  if c.count then
   for _,level in ipairs({6,7})do
    require('src.render.Pipelines').setLevel('voxel',level);U.wait(20)
    local F=V.require('FirstPerson');F.lookBy(.45-F.yaw,.25-F.pitch);U.wait(8)
    assert(V.require('Voxel3D').canopyFacing,'plant camera facing disabled')
    assert(U.shot(game,dir..'/'..c.name..'_'..level..'.png'))
   end
   require('src.render.Pipelines').setLevel('voxel',3);U.wait(8)
   local q=S.flowerQuads[1];local mesh=assert(mesher.flowers(game.world.map))
   local vertex={mesh:getVertex(1)}
   assert(#vertex==9 and vertex[9]>0,'GPU flower lost its camera anchor')
   assert(mesher.dropBlock(c.id,math.floor(q[1][1]/32),math.floor(q[1][3]/32))>0,'Cut did not clear the plant mesh')
   for i=1,4 do for _,v in ipairs({mesh:getVertex(i)})do assert(v==0,'Cut left an anchored vertex visible')end end
  end
  print('[flowers/rocks]',c.id,c.name,px,py,#S.flowerQuads)
 end
 assert(flowerCount>0,'no native flowers exercised')
 print('[flowers/rocks] PASS:',#cases,'scenes,',flowerCount,'source flower tiles replaced')
 love.event.quit()
end
