return function(game)
 assert(love.filesystem.getIdentity():match('%-qa$'),'isolated QA profile required')
 local U=dofile('tests/drivers/util.lua');local dir=os.getenv('SHOT_DIR');local version=require('src.core.GameVersion').get()
 local update=game.update;game.update=function(self,dt)self.input:reset();return require('src.mods.Runtime').call('core.update',update,self,dt)end
 game:_handleBootAction({action='new_game',start={map=version=='emerald'and'EM_OLDALE_TOWN'or'FR_PALLET_TOWN',x=7,y=8,facing='down'}})
 local V=game.mods.exports.BATTLE_ART_VOXEL_FORK.lib;V.require('VoxelGrid').set(false,game);local Map=require('src.core.game3.map');local Player=require('src.core.game3.player');local C=V.require('Gen3Integration')
 local maps=version=='emerald'and{'EM_OLDALE_TOWN_MART','EM_RUSTBORO_CITY_HOUSE3','EM_FORTREE_CITY_HOUSE3','EM_LITTLEROOT_TOWN_PROFESSOR_BIRCHS_LAB'}or{'FR_VIRIDIAN_CITY_POKEMON_CENTER_1F','FR_CERULEAN_CITY_MART','FR_ROUTE_2_HOUSE'}
 if version=='emerald' and os.getenv('QA_INSTITUTIONS')=='1'then maps={'EM_SLATEPORT_CITY_OCEANIC_MUSEUM_1F','EM_MOSSDEEP_CITY_SPACE_CENTER_1F','EM_MOSSDEEP_CITY_SPACE_CENTER_2F','EM_RUSTBORO_CITY_HOUSE1'}end
 if version~='emerald' and os.getenv('QA_OFFICES')=='1'then maps={'FR_SILPH_CO_2F','FR_SILPH_CO_10F','FR_CELADON_CITY_CONDOMINIUMS_2F','FR_CELADON_CITY_CONDOMINIUMS_3F','FR_OAKS_LAB'}end
 if version~='emerald' and os.getenv('QA_RETAIL')=='1'then maps={'FR_CELADON_CITY_POKEMON_CENTER_1F','FR_PEWTER_CITY_MUSEUM_1F','FR_CELADON_CITY_DEPARTMENT_STORE_2F','FR_CELADON_CITY_DEPARTMENT_STORE_5F','FR_FOUR_ISLAND_POKEMON_DAY_CARE'}end
 if version~='emerald' and os.getenv('QA_HOMES')=='1'then maps={'FR_PLAYERS_HOUSE_2F','FR_CELADON_CITY_CONDOMINIUMS_ROOF_ROOM','FR_SEVEN_ISLAND_HOUSE_ROOM1','FR_FOUR_ISLAND_LORELEIS_HOUSE','FR_ROCKET_HIDEOUT_B4F','FR_FIVE_ISLAND_ROCKET_WAREHOUSE'}end
 if version~='emerald' and os.getenv('QA_SEATS')=='1'then maps={'FR_POKEMON_LEAGUE_AGATHAS_ROOM','FR_BATTLE_COLOSSEUM_2P','FR_CELADON_CITY_GAME_CORNER','FR_SSANNE_1F_ROOM1'}end
 if version~='emerald' and os.getenv('QA_LEAGUE')=='1'then maps={'FR_POKEMON_LEAGUE_LORELEIS_ROOM','FR_POKEMON_LEAGUE_BRUNOS_ROOM','FR_POKEMON_LEAGUE_AGATHAS_ROOM','FR_POKEMON_LEAGUE_LANCES_ROOM','FR_POKEMON_LEAGUE_CHAMPIONS_ROOM'}end
 if version~='emerald' and os.getenv('QA_BEDS')=='1'then maps={'FR_PLAYERS_HOUSE_2F','FR_FOUR_ISLAND_LORELEIS_HOUSE','FR_PLAYERS_HOUSE_1F'}end
 for _,id in ipairs(maps)do
  local d=assert(game.data.maps[id]);Map.ensureMidLayout(game,id,d)
  local px,py
  for y=d.height-2,2,-1 do for x=math.floor(d.width/2),d.width-2 do if not px and d.midLayout:collAt(x,y)==0 then px,py=x,y end end end
  assert(px,'no walkable viewing cell');assert(Map.load(nil,game,id,{x=px,y=py,facing='up'}));U.wait(20)
  local space=require('src.core.game3.scripting.space');space.runOnFrame=function()end;local vm=space.getVm();if vm then vm:halt(true)end;require('src.ui.game3.message').reset()
  Player.reset(px,py,'up');Player.setVisible(true)
  -- Map.load applies native story/door collision; compare only after it settles.
  local native={};for y=0,d.height-1 do for x=0,d.width-1 do native[#native+1]=d.midLayout:collAt(x,y)end end
  local FF=V.require('Gen3Furniture');local PP=V.require('Gen3Tilesets');local pair=PP.canonical(d.midLayout.pair);local spec=PP.resolve(d.midLayout.pair,require('src.import.gba.versions').TILESET_PAIRS);local cells={}
  for y=0,d.height-1 do for x=0,d.width-1 do cells[x..':'..y]={cx=x,cy=y,mid=d.midLayout:midAt(x,y),collision=d.midLayout:collAt(x,y),primary=spec.primary,secondary=spec.secondary,pair=pair,ts={}}end end
  local props=FF.extract(cells)
  if id=='FR_POKEMON_LEAGUE_LANCES_ROOM' then local count=0;for _,p in ipairs(props)do if p.recipe.kind=='statue'then count=count+1 end end;assert(count==10,'expected all ten native League statues');print('[statues]',count)end
  for _,p in ipairs(props)do if p.recipe.design or p.recipe.kind=='statue' then
   local rows={};for y=p.cy-1,p.cy+#p.recipe.rows do local row={};for x=p.cx,p.cx+#p.recipe.rows[1]-1 do row[#row+1]=tostring(d.midLayout:collAt(x,y))end;rows[#rows+1]=table.concat(row,',')end
   print('[prop]',id,p.recipe.design or p.recipe.kind,p.cx,p.cy,table.concat(rows,' / '))
  end end
  C.setLevel(0,game);U.wait(3);U.shot(game,dir..'/'..id..'-native.png')
  C.setLevel(3,game);U.wait(100);U.shot(game,dir..'/'..id..'-overview.png')
  local views={FR_POKEMON_LEAGUE_LANCES_ROOM={8,19},FR_PLAYERS_HOUSE_2F={2,3},FR_CELADON_CITY_CONDOMINIUMS_ROOF_ROOM={5,6},FR_SEVEN_ISLAND_HOUSE_ROOM1={4,3},FR_FOUR_ISLAND_LORELEIS_HOUSE={10,6},FR_ROCKET_HIDEOUT_B4F={19,9},FR_FIVE_ISLAND_ROCKET_WAREHOUSE={17,7},FR_CELADON_CITY_POKEMON_CENTER_1F={3,4},FR_PEWTER_CITY_MUSEUM_1F={18,4},FR_CELADON_CITY_DEPARTMENT_STORE_2F={8,13},FR_CELADON_CITY_DEPARTMENT_STORE_5F={8,10},FR_FOUR_ISLAND_POKEMON_DAY_CARE={8,6},FR_OAKS_LAB={3,4},FR_CELADON_CITY_CONDOMINIUMS_3F={2,10},FR_CELADON_CITY_CONDOMINIUMS_2F={2,11},FR_SILPH_CO_2F={34,18},FR_SILPH_CO_10F={16,16},EM_FORTREE_CITY_HOUSE3={1,4},EM_RUSTBORO_CITY_HOUSE3={8,3},EM_LITTLEROOT_TOWN_PROFESSOR_BIRCHS_LAB={3,3}};local pos=views[id];if pos and d.midLayout:collAt(pos[1],pos[2])==0 then Player.reset(pos[1],pos[2],'up')end
  if os.getenv('QA_BEDS')=='1' then
   local bedView=({FR_PLAYERS_HOUSE_2F={2,8},FR_FOUR_ISLAND_LORELEIS_HOUSE={1,5}})[id]
   if bedView then assert(d.midLayout:collAt(bedView[1],bedView[2])==0);Player.reset(bedView[1],bedView[2],'up')end
  end
  C.setLevel(6,game);C.yaw=0;C.pitch=0;U.wait(15);U.shot(game,dir..'/'..id..'-first.png')
  if id=='FR_POKEMON_LEAGUE_LANCES_ROOM' then Player.reset(6,17,'right');C.yaw=math.pi/2;U.wait(15);U.shot(game,dir..'/'..id..'-statue-side.png')end
  local n=0;for y=0,d.height-1 do for x=0,d.width-1 do n=n+1;assert(native[n]==d.midLayout:collAt(x,y),'renderer changed native collision')end end
  assert(not C.lastError,tostring(C.lastError));print('[PASS]',id,px,py)
 end
 love.event.quit()
end
