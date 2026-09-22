-- Inventory every imported Crystal map and render one representative of each
-- tileset. A coverage report records generic cells; it does not call them
-- finished models or claim visual parity from classification alone.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib
 local Map=require('src.world.gen2.Map')
 local Permissions=require('src.world.gen2.Permissions')
 local Shape=V.require('TileShape')
 local visuals=V.require('CommunityVisuals')
 local mesher=V.require('ChunkMesher')
 local voxel=V.require('VoxelState')
 local recipes=V.data('gen2_furniture')
 local depthRecipes=V.data('gen2_depth_furniture')
 local resolved,recipeStats={},{}
 local floorFinish=V.require('Gen2FloorFinish')
 local function templates(ts)
  if resolved[ts.id] then return resolved[ts.id] end
  local list={}
  for _,t in ipairs(recipes[ts.id] or {}) do list[#list+1]=t end
  for _,spec in ipairs(depthRecipes[ts.id] or {}) do
   list[#list+1]=assert(V.require('Gen2FurnitureTemplates').resolve(ts,spec),spec.id)
  end
  for _,t in ipairs(list) do recipeStats[t.id]={tileset=ts.id,count=0} end
  resolved[ts.id]=list
  if floorFinish.profiles[ts.id] then
   assert(floorFinish.forTileset(ts),'no unused atlas space for floor: '..ts.id)
  end
  return list
 end
 -- Use the complete drawing and the production first-claim priority. A
 -- single tile ID is never proof that a cell belongs to a furniture model.
 local function placements(map,list)
  local claimed,n={},0
  local tw,th=map.def.width*4,map.def.height*4
  for _,t in ipairs(list) do
   local w,h=#t.tiles[1],#t.tiles
   for y=0,th-h do for x=0,tw-w do
    local match=map:tileAt(x,y)==t.tiles[1][1]
    if match then
     for dy=0,h-1 do for dx=0,w-1 do
      if claimed[(y+dy)*tw+x+dx] or map:tileAt(x+dx,y+dy)~=t.tiles[dy+1][dx+1] then match=false end
     end end
    end
    if match then
     for dy=0,h-1 do for dx=0,w-1 do claimed[(y+dy)*tw+x+dx]=true end end
     local row=recipeStats[t.id];row.count=row.count+1
     if not row.map then row.map=map.id;row.x=x;row.y=y end
     n=n+1
    end
   end end
  end
  return claimed,n
 end
 local dir=assert(os.getenv('SHOT_DIR'))
 local groups,signatures,sprites={},{},{}
 local out=assert(io.open(dir..'/maps.csv','w'))
 out:write('map,tileset,environment,cells,generic_wall_cells,furniture_placements\n')
 local count=0
 local mapIds={};for id in pairs(game.world.maps) do mapIds[#mapIds+1]=id end;table.sort(mapIds)
 for _,id in ipairs(mapIds) do
  local def=game.world.maps[id]
  local ts=game.world.tilesets[def.tileset]
  if ts then
   local map=Map.new(def,ts)
   local shapes=Shape.forMap(map)
   local list=templates(ts)
   local claimed,placed=placements(map,list)
   local generic=0
   for cy=0,map.heightCells-1 do for cx=0,map.widthCells-1 do
    local tx,ty=cx*2,cy*2
    local shape=Shape.at(map,shapes,map:tileAt(tx,ty),tx,ty)
    if shape.class=='wall' and not (claimed[ty*def.width*4+tx] and claimed[ty*def.width*4+tx+1]
      and claimed[(ty+1)*def.width*4+tx] and claimed[(ty+1)*def.width*4+tx+1]) then
     generic=generic+1
     local sig=table.concat({map:tileAt(tx,ty),map:tileAt(tx+1,ty),map:tileAt(tx,ty+1),map:tileAt(tx+1,ty+1)},':')
     signatures[def.tileset]=signatures[def.tileset] or {}
     local rows=signatures[def.tileset]
     local row=rows[sig] or {count=0,map=id,x=cx,y=cy};rows[sig]=row;row.count=row.count+1
    end
   end end
   local cells=map.widthCells*map.heightCells
   out:write(('%s,%s,%s,%d,%d,%d\n'):format(id,def.tileset,def.environment,cells,generic,placed))
   for _,obj in ipairs(def.objects or {}) do sprites[obj.sprite]=(sprites[obj.sprite] or 0)+1 end
   local group=groups[def.tileset] or {maps=0};groups[def.tileset]=group;group.maps=group.maps+1
   local score=generic+#(def.objects or {})*4
   if not group.score or score>group.score then group.id=id;group.score=score end
   count=count+1
  end
 end
 out:close()
 out=assert(io.open(dir..'/generic-walls.csv','w'));out:write('tileset,tiles,count,example_map,x,y\n')
 for ts,rows in pairs(signatures) do for sig,row in pairs(rows) do
  out:write(('%s,%s,%d,%s,%d,%d\n'):format(ts,sig,row.count,row.map,row.x,row.y))
 end end
 out:close()
 out=assert(io.open(dir..'/actors.csv','w'));out:write('sprite,count\n')
 for id,n in pairs(sprites) do out:write(tostring(id)..','..n..'\n') end;out:close()
 out=assert(io.open(dir..'/furniture.csv','w'));out:write('recipe,tileset,placements,example_map,x,y\n')
 local recipeIds={};for id in pairs(recipeStats) do recipeIds[#recipeIds+1]=id end;table.sort(recipeIds)
 for _,id in ipairs(recipeIds) do local row=recipeStats[id]
  out:write(('%s,%s,%d,%s,%s,%s\n'):format(id,row.tileset,row.count,row.map or '',row.x or '',row.y or ''))
 end
 out:close()
 print('[coverage] inventoried maps',count)
 if os.getenv('QA_INVENTORY_ONLY')=='1' then love.event.quit();return end
 love.window.setMode(2560,1440,{resizable=true})
 game.world.trySceneScript=function()return false end
 game.world.rollEncounter=function()return nil end
 game.mods.modOptions.overworld_wild_spawns.catch_hud_size=0
 require('src.render.Pipelines').setLevel('voxel',3)
 assert(visuals.crystalDepth(game.world.map),'HD-2D must be default')
 V.require('DayNight').setting:sync('day')
 local ids={};for id in pairs(groups) do ids[#ids+1]=id end;table.sort(ids)
 local views={}
 for _,ts in ipairs(ids) do views[#views+1]={ts=ts,id=groups[ts].id,name=ts} end
 if os.getenv('QA_ALL_MAPS')=='1' then
  views={};for _,id in ipairs(mapIds) do views[#views+1]={ts=game.world.maps[id].tileset,id=id,name=id} end
 elseif os.getenv('QA_RECIPES')=='1' then
  local seen={};for _,view in ipairs(views) do seen[view.id]=true end
  for _,id in ipairs(recipeIds) do local row=recipeStats[id]
   if row.map and not seen[row.map] then
    seen[row.map]=true;views[#views+1]={ts=row.tileset,id=row.map,name=row.map}
   end
  end
 end
 local rendered,unavailable=0,0
 for i,view in ipairs(views) do
  if i >= (tonumber(os.getenv('QA_FROM')) or 1) then
  local ts,group=view.ts,{id=view.id,maps=groups[view.ts].maps}
  local map=Map.new(game.world.maps[group.id],game.world.tilesets[ts])
  local px,py,dist
  for cy=1,map.heightCells-2 do for cx=1,map.widthCells-2 do
   if Permissions.of(map:cellCollision(cx,cy))==Permissions.LAND then
    local d=(cx-map.widthCells*.5)^2+(cy-map.heightCells*.55)^2
    if not dist or d<dist then px,py,dist=cx,cy,d end
   end
  end end
  if px then
   print('[coverage view]',i,#views,ts,group.id,group.maps,'maps')
   game.stack:clear()
   assert(game.world:setMap(group.id,px,py,'down'))
   require('src.render.Pipelines').setLevel('voxel',3)
   U.wait(8)
   for _=1,2400 do if mesher.pending()==0 and voxel.ready then break end U.wait(1) end
   assert(mesher.pending()==0 and voxel.ready,'coverage scene failed: '..group.id)
   U.wait(140)
   game.stack:clear()
   game.world.mapSign=nil
   local S=V.require('Structures').forMap(game.world.map)
   for _,f in ipairs(S.furniture or {}) do
    assert(f.height>0 and f.x1>f.x0 and f.z1>f.z0,'empty furniture: '..f.id)
    assert((f.support or 0)<=8,'excessive furniture support: '..f.id)
   end
   assert(U.shot(game,dir..'/'..view.name..'.png'))
   rendered=rendered+1
  else unavailable=unavailable+1;print('[coverage view unavailable]',ts,group.id) end
  end
 end
 print('[coverage] PASS:',rendered,'native map views;',unavailable,'without a walkable camera; review furniture.csv and generic-walls.csv for coverage gaps')
 love.event.quit()
end
