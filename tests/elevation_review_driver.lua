return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'))
 local U=dofile('tests/drivers/util.lua');local dir=assert(os.getenv('SHOT_DIR'))
 local update=game.update;game.update=function(self,dt)return require('src.mods.Runtime').call('core.update',update,self,dt)end
 love.window.setMode(1440,900)
 local V=assert(game.mods.exports.BATTLE_ART_VOXEL_FORK).lib;local gen=V.require('Generation').number()
 local P=require('src.render.Pipelines')
 local f=assert(io.open(dir..'/coverage.tsv','w'));local total={maps=0,raised=0,flights=0,conflicts=0}
 if gen==3 then
  game:_handleBootAction({action='new_game',start={map='FR_PALLET_TOWN',x=10,y=9,facing='down'}})
  local Map=require('src.core.game3.map');local E=V.require('Gen3Elevation')
  for id,d in pairs(game.data.maps)do
   Map.ensureMidLayout(game,id,d)
   if d.midLayout then local field=E.field(d);local n=0;local max=0
    for _,c in pairs(field.cells)do if c.floor and c.height>0 then n=n+1;max=math.max(max,c.height)end end
    f:write(table.concat({id,n,max,#field.flights,#field.conflicts},'\t')..'\n');total.maps=total.maps+1;total.raised=total.raised+n;total.flights=total.flights+#field.flights;total.conflicts=total.conflicts+#field.conflicts
   end
  end
 else
  local Map=require('src.world.gen2.Map');local E=V.require('Gen2Elevation')
  for id,d in pairs(game.world.maps)do local m=Map.new(d,game.world.tilesets[d.tileset]);local field=E.field(m)
   local n,max,flights,conflicts=0,0,0,0
   if field then for _,c in pairs(field.cells)do if c.floor and c.height>0 then n=n+1;max=math.max(max,c.height)end end;flights=#field.flights;conflicts=#field.conflicts end
   f:write(table.concat({id,n,max,flights,conflicts},'\t')..'\n');total.maps=total.maps+1;total.raised=total.raised+n;total.flights=total.flights+flights;total.conflicts=total.conflicts+conflicts
  end
 end
 f:close();print('[elevation census]',total.maps,total.raised,total.flights,total.conflicts)
 local targets=gen==3 and {{'FR_VICTORY_ROAD_1F',10,10},{'FR_MT_EMBER_EXTERIOR',29,32},{'FR_SEVEN_ISLAND_SEVAULT_CANYON',15,18},{'FR_CERULEAN_CITY_GYM',9,9},{'FR_SSANNE_EXTERIOR',32,9},{'FR_OAKS_LAB',5,6}}or
  {{'DARK_CAVE_BLACKTHORN_ENTRANCE',19,8},{'BURNED_TOWER_B1F',10,8},{'BLACKTHORN_CITY',13,15},{'OLIVINE_PORT',10,10},{'DANCE_THEATER',1,5},{'VIOLET_GYM',4,9},{'BLACKTHORN_GYM_1F',6,8},{'GOLDENROD_MAGNET_TRAIN_STATION',9,11},{'ELMS_LAB',5,6}}
 for _,p in ipairs(targets)do
  game.input:reset();if game.stack then game.stack:clear()end
  if gen==3 then
   assert(require('src.core.game3.map').load(nil,game,p[1],{x=p[2],y=p[3],facing='up'}))
   require('src.ui.game3.map_preview_screen').reset()
   V.require('Gen3Integration').setLevel(3,game);U.wait(130)
   local C=V.require('Gen3Integration');assert(C.active,'voxel inactive: '..p[1]);assert(not C.lastError,tostring(C.lastError))
  else
   local w=game.world;w.trySceneScript=function()return false end;assert(w:setMap(p[1],p[2],p[3],'up'));w.vm=nil;w.textbox=nil
   P.setLevel('voxel',3);U.wait(200)
  end
  U.shot(game,dir..'/'..p[1]..'-overview.png')
  if gen==3 then local C=V.require('Gen3Integration');C.setLevel(6,game);C.yaw=0;C.pitch=.12
  else P.setLevel('voxel',6)end
  U.wait(24);U.shot(game,dir..'/'..p[1]..'-first.png')
 end
 print('[elevation review] captures complete');love.event.quit()
end
