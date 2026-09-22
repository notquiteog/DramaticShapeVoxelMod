-- Native all-instance turntables for reviewed building families. A controlled
-- inspection camera calls the production renderer; it is confined to QA.
return function(game)
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local identity=love.filesystem.getIdentity();local crystal=identity=='battle-art-crossgen-qa'
 assert(crystal or identity=='firered-hd2d-qa')
 love.window.setMode(1280,720,{resizable=true})
 if not crystal then game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})end
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Map=require(crystal and 'src.world.gen2.Map' or 'src.core.game3.map')
 local R=V.require('Voxel3D');local project=R.viewProjection;local inspection
 R.viewProjection=function(cx,cy,w,h)
  if inspection then R.camera=inspection;cx,cy=inspection.focus[1],inspection.focus[3] end
  return project(cx,cy,w,h)
 end
 local maps=crystal and game.world.maps or game.data.maps
 local selected=os.getenv('QA_EXTERIOR_MAPS');local ids={}
 if selected then for id in selected:gmatch('[^,]+')do ids[#ids+1]=id end else for id in pairs(maps)do ids[#ids+1]=id end;table.sort(ids)end
 local completed={};local resume=os.getenv('QA_EXTERIOR_RESUME')=='1'
 if resume then
  local previous=assert(io.open(dir..'/views.csv','r'))
  for line in previous:lines()do local id,x,y=line:match('^([^,]+),(%d+),(%d+),');if id then completed[id..':'..x..':'..y]=true end end
  previous:close()
 end
 local report=assert(io.open(dir..'/views.csv',resume and 'a' or 'w'))
 if not resume then report:write('map,x,y,family,views\n')end
 local count,shots=0,0
 if crystal then game.world.trySceneScript=function()return false end;game.world.rollEncounter=function()return nil end;V.require('DayNight').setting:sync('day')end
 for _,id in ipairs(ids)do
  local def=assert(maps[id]);local list={}
  if crystal then
   if Map.isOutdoor(def)then list=V.require('Gen2Exteriors').placements(Map.new(def,assert(game.world.tilesets[def.tileset])))end
  else
   Map.ensureMidLayout(game,id,def)
   local spec=V.require('Gen3Tilesets').resolve(def.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS)
   if spec.primary=='general' and V.require('Gen3Tilesets').supports(def,spec)then
    local cells={}
    for y=0,def.height-1 do for x=0,def.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=def.midLayout:midAt(x,y),pair=def.midLayout.pair,primary=spec.primary}end end
    list=V.require('Gen3Civic').prepare(cells,V.require('Gen3Buildings').prepare(cells),V.data('gen3_exteriors'))
   end
  end
  table.sort(list,function(a,b)return (a.y or a.cy)==(b.y or b.cy) and (a.x or a.cx)<(b.x or b.cx) or (a.y or a.cy)<(b.y or b.cy)end)
  for _,g in ipairs(list)do if not completed[id..':'..(g.x or g.cx)..':'..(g.y or g.cy)] then
   local unit=crystal and 8 or 16;local x,y=g.x or g.cx,g.y or g.cy
   local W,D=g.width*unit,g.depth*unit
   local H=crystal and (g.depth-g.roofRows)*8 or V.require('Gen3Civic').profile(g).wall
   local px,py=math.floor((x*unit+W/2)/16),math.floor((y*unit+D)/16)+2
   if crystal then
    game.stack:clear();assert(game.world:setMap(id,px,py,'up'))
    require('src.render.Pipelines').setLevel('voxel',7);U.wait(25)
    for _=1,2400 do if V.require('ChunkMesher').pending()==0 and V.require('VoxelState').ready then break end;U.wait(1)end
    assert(V.require('ChunkMesher').pending()==0 and V.require('VoxelState').ready)
    local actual=V.require('Structures').forMap(game.world.map).exteriors;local found=false
    for _,p in ipairs(actual or {})do found=found or p.x==g.x and p.y==g.y end
    assert(found,'catalogued exterior was not built: '..id..':'..x..':'..y)
    game.stack:clear()
   else
    assert(Map.load(nil,game,id,{x=px,y=py,facing='up'}))
    local Collision=require('src.core.game3.collision');local best,position
    for yy=0,def.height-1 do for xx=0,def.width-1 do
     if Collision.isWalkable(xx,yy) and not Collision.warpAt(xx,yy) and not Collision.isWater(xx,yy)then
      local d=(xx-px)^2+(yy-py)^2;if not best or d<best then best,position=d,{xx,yy}end
     end
    end end
    assert(position);require('src.core.game3.player').reset(position[1],position[2],'up')
    game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.setLevel(7,game);U.wait(35)
    for _=1,240 do if game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.active then break end;U.wait(1)end
    assert(game.mods.exports.BATTLE_ART_VOXEL_FORK.firered.camera.active,'scene fell back: '..id)
   end
   local cx,cz=x*unit+W/2,y*unit+D/2
   local distance=math.max(W,D,H*1.5)*1.25+30
   for i,d in ipairs({{0,1},{1,0},{0,-1},{-1,0}})do
    inspection={eye={cx+d[1]*distance,H+distance*.42,cz+d[2]*distance},focus={cx,H*.5,cz},fov=math.rad(52),up={0,1,0},curve=0}
    U.wait(2)
    local name=('%s_%d_%d_%d.png'):format(id,x,y,i)
    assert(U.shot(game,dir..'/'..name));shots=shots+1
   end
   count=count+1;report:write(('%s,%d,%d,%s,4\n'):format(id,x,y,g.style or g.family or g.kind));report:flush()
  end
 end end
 R.viewProjection=project;report:close()
 print('[building turntables] PASS',count,'building placements',shots,'front/right/back/left captures')
 love.event.quit()
end
