-- Read-only native exterior catalogue. Art stays in the external QA directory;
-- only identifiers, counts and review status may enter source control.
return function(game)
 local U=dofile('tests/drivers/util.lua')
 local dir=assert(os.getenv('SHOT_DIR'))
 local identity=love.filesystem.getIdentity()
 assert(identity=='battle-art-crossgen-qa' or identity=='firered-hd2d-qa')
 local crystal=identity=='battle-art-crossgen-qa'
 -- This read-only fixture export needs no networking module/permission.
 local function encode(value)
  if type(value)=='string' then
   return '"'..value:gsub('[%z\1-\31\\"]',function(c)return ('\\u%04x'):format(c:byte())end)..'"'
  elseif type(value)=='number' or type(value)=='boolean' then return tostring(value)
  elseif type(value)=='table' then
   local parts={}
   if #value>0 then for _,v in ipairs(value)do parts[#parts+1]=encode(v)end;return '['..table.concat(parts,',')..']' end
   for k,v in pairs(value)do parts[#parts+1]=encode(tostring(k))..':'..encode(v)end
   return '{'..table.concat(parts,',')..'}'
  else return 'null' end
 end
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 if not crystal then game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})end
 local maps=crystal and game.world.maps or game.data.maps
 local ids={};for id in pairs(maps)do ids[#ids+1]=id end;table.sort(ids)
 local Map=require(crystal and 'src.world.gen2.Map' or 'src.core.game3.map')
 local inventory={};local tileSize=crystal and 8 or 16
 for _,id in ipairs(ids)do
  local def=maps[id]
  local outdoor=crystal and Map.isOutdoor(def) or not crystal and (def.mapType==1 or def.mapType==2 or def.mapType==3 or def.mapType==6)
  if outdoor then
   local image,tiles,w,h,ts,pair
   tiles={}
   if crystal then
    ts=assert(game.world.tilesets[def.tileset]);local map=Map.new(def,ts)
    image=assert(game.world:bakeMapImage(map,'DAY'))
    w,h=map.width*4,map.height*4
    for y=0,h-1 do local row={};tiles[y+1]=row;for x=0,w-1 do row[x+1]=map:tileAt(x,y)end end
   else
    Map.ensureMidLayout(game,id,def);pair=def.midLayout.pair
    ts=assert(require('src.core.game3.tileset_native').get(pair));w,h=def.width,def.height
    image=love.graphics.newCanvas(w*16,h*16)
    love.graphics.push('all');love.graphics.setCanvas(image);love.graphics.origin();love.graphics.setShader();love.graphics.setColor(1,1,1);love.graphics.clear()
    for y=0,h-1 do local row={};tiles[y+1]=row;for x=0,w-1 do
     local mid=def.midLayout:midAt(x,y);row[x+1]=mid;local slot=assert(ts.midToSlot[mid])
     local q=love.graphics.newQuad(slot%ts.cols*16,math.floor(slot/ts.cols)*16,16,16,ts.image:getDimensions())
     love.graphics.draw(ts.image,q,x*16,y*16);if ts.overImage then love.graphics.draw(ts.overImage,q,x*16,y*16)end;q:release()
    end end
    love.graphics.pop()
   end
   local pixels=image:newImageData();local blob=pixels:encode('png')
   local f=assert(io.open(dir..'/'..id..'.png','wb'));f:write(blob:getString());f:close();blob:release();pixels:release();image:release()
   inventory[#inventory+1]={id=id,tileset=crystal and ts.id or pair,environment=def.environment,mapType=def.mapType,
    width=w,height=h,tileSize=tileSize,tiles=tiles,warps=def.warps or {}}
   U.wait(1)
  end
 end
 local f=assert(io.open(dir..'/exteriors.json','w'));f:write(encode(inventory));f:close()
 print('[exterior inventory] PASS',#inventory,'outdoor maps catalogued, native art and warps unchanged')
 love.event.quit()
end
