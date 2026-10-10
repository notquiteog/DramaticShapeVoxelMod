return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib
 local Map=require('src.world.gen2.Map')
 local chosen={crystal_department_window=true,crystal_department_counter_window=true,crystal_department_elevator=true,crystal_department_register=true,crystal_department_directory=true}
 local recipes=V.data('gen2_furniture').TILESET_MART
 local totals={}
 for id,d in pairs(game.world.maps)do if d.tileset=='TILESET_MART' then
  local m=Map.new(d,game.world.tilesets[d.tileset])
  for _,r in ipairs(recipes)do if chosen[r.id] then
   for y=0,d.height*4-#r.tiles do for x=0,d.width*4-#r.tiles[1]do
    local match=true
    for dy,row in ipairs(r.tiles)do for dx,t in ipairs(row)do if m:tileAt(x+dx-1,y+dy-1)~=t then match=false end end end
    if match then
     assert(x%2==0 and y%2==0,'new fixture straddles collision cells: '..id..' '..r.id)
     local cx,cy=x/2,y/2
     if r.id=='crystal_department_elevator' then
      assert(m:isWalkable(cx,cy) and not m:isWalkable(cx+1,cy),'elevator approach/control-wall collision changed')
     else assert(not m:isWalkable(cx,cy),'new fixture occupies native walking lane: '..id..' '..r.id)end
     totals[r.id]=(totals[r.id]or 0)+1
    end
   end end
  end end
 end end
 for id,n in pairs(totals)do print('[native-footprint]',require('src.core.GameVersion').get(),id,n)end
 love.event.quit()
end
