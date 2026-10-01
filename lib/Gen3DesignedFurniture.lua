local V=...
local M={}
local Geometry=V and V.require('InteriorFurniture') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/InteriorFurniture.lua')
function M.install(recipes)
 local function add(name,pair,rows,design,ground)
  recipes[#recipes+1]={name=name,pair=pair,rows=rows,kind='designed',design=design,ground=ground or 1}
 end
 add('museum_space_exhibit','building__rom_082d4c2c',{{0x290,0x291,0x292},{0x298,0x299,0x29a}},'fr_space_exhibit',0x281)
 add('power_plant_generator','building__rom_082d4e9c',{
  {0x2e8,0x2e9,0x2ea},{0x2f0,0x2f1,0x2f2},
  {0x2f8,0x2f9,0x2fa},{0x300,0x301,0x302}},'fr_generator',0x29f)
 recipes[#recipes].generatorGrating=true
 add('power_plant_generator_floor','building__rom_082d4e9c',{
  {0x2eb,0x2ec,0x2ed},{0x2f3,0x2f4,0x2f5},
  {0x2fb,0x2fc,0x2fd},{0x303,0x304,0x305}},'fr_generator',0x29f)
 -- In the native perspective drawing each middle cell contains the base of
 -- one canister and the lid of the next. Claim the whole column, then build
 -- one separate drum per original lid, never a wall or a stretched cylinder.
 for _,cap in ipairs({0x2d0,0x2d1})do for middle=0,2 do
  local rows={{cap}}
  for i=1,middle do rows[#rows+1]={0x2d8}end
  rows[#rows+1]={0x2d9}
  add('power_plant_drums_'..cap..'_'..middle,'building__rom_082d4e9c',rows,'fr_industrial_drums',0x29f)
 end end
 add('power_plant_rubble','building__rom_082d4e9c',{{0x2b6}},'fr_industrial_rubble',0x29f)
 recipes[#recipes].spriteAlternative='rock';recipes[#recipes].cutout=true
 -- Complete single-cell grave drawings, including the boundary variants.
 -- Pair-local matching leaves identical numeric IDs in other rooms alone.
 for _,mid in ipairs({0x291,0x293,0x2be,0x2bf,0x2d8,0x2d9})do
  add('tower_grave_'..mid,'building__rom_082d4efc',{{mid}},'fr_tower_grave',0x282)
 end
 add('room_bed','player_house',{{0x283,0x284,0x285},{0x28b,0x28c,0x28d},{0x293,0x294,0x295}},'fr_bed')
 add('room_computer','player_house',{{0x287,0x20},{0x28f,0x86},{0x297,0x5a}},'fr_room_pc')
 add('room_dresser','player_house',{{0x30},{0x38}},'fr_room_dresser')
 add('room_console','player_house',{{0x35},{0x28e},{0x296}},'fr_console',0x45)
 add('room_television','player_house',{{0x2b,0x2c},{0x33,0x34},{0x3b,0x3c}},'fr_television')
 add('living_television','player_house',{{0x2d},{0x35},{0x3d}},'fr_living_tv')
 add('living_cupboard','player_house',{{0x2e,0x2f},{0x36,0x37},{0x3e,0x3f}},'fr_cupboard')
 add('neighbor_wall_picture','house',{{0x184},{0x185}},'fr_wall_picture')
 add('lab_complete_books','oak_lab',{{0x73,0x74},{0x283,0x284}},'fr_lab_books',0x289)
 -- Oak's lab machine bank: a clean 3x2 run of cabinet halves, each pair a
 -- distinct machine. Identified off the native sheet for oak_lab, where
 -- 0x2ed-0x2f2 are blue cases carrying orange canisters.
 add('lab_centrifuge_bank','oak_lab',{
  {0x2ed,0x2ee,0x2ef},{0x2f0,0x2f1,0x2f2}},'fr_lab_centrifuge',1)
 -- Naval Rock, FireRed's Team Rocket base, on general__rom_082d501c -- 26
 -- maps and the largest Gen 3 tileset with no recipe at all. 0x289/0x28a are
 -- hazard-striped machinery and 0x282/0x283 the blue console units, read off the
 -- native sheet and intersected with FR_NAVEL_ROCK_1F's own midLayout.
 add('rocket_hazard_cabinet','general__rom_082d501c',{{0x289}},'fr_rocket_hazard_cabinet',1)
 add('rocket_hazard_cabinet_b','general__rom_082d501c',{{0x28a}},'fr_rocket_hazard_cabinet',1)
 add('rocket_console','general__rom_082d501c',{{0x282}},'fr_rocket_console',1)
 add('rocket_console_b','general__rom_082d501c',{{0x283}},'fr_rocket_console',1)
 -- Elite Four chambers, building__rom_082d50c4: 317 distinct metatiles over 5
 -- maps and no recipe at all. 0x2a1 is the single cell that breaks the floor
 -- pattern -- the chamber's centrepiece -- read off the native sheet and
 -- confirmed against FR_POKEMON_LEAGUE_AGATHAS_ROOM's own midLayout.
 add('elite_pedestal','building__rom_082d50c4',{{0x2a1}},'fr_elite_pedestal',1)
 -- Celadon Condominiums, building__rom_082d4f8c, 4 maps and no recipe. A
 -- genuinely furnished interior: kitchen runs, beds, wardrobes and plants, all
 -- read off the native sheet against FR_CELADON_CITY_CONDOMINIUMS_1F's layout.
 add('room_bed_a','building__rom_082d4f8c',{{0x289}},'fr_room_bed',1)
 add('room_bed_b','building__rom_082d4f8c',{{0x28c}},'fr_room_bed',1)
 add('condo_wardrobe_a','building__rom_082d4f8c',{{0x290}},'fr_condo_wardrobe',1)
 add('condo_wardrobe_b','building__rom_082d4f8c',{{0x291}},'fr_condo_wardrobe',1)
 add('condo_wardrobe_c','building__rom_082d4f8c',{{0x294}},'fr_condo_wardrobe',1)
 add('condo_kitchen_a','building__rom_082d4f8c',{{0x283}},'fr_condo_kitchen',1)
 add('condo_kitchen_b','building__rom_082d4f8c',{{0x285}},'fr_condo_kitchen',1)
 add('condo_plant','building__rom_082d4f8c',{{0x2a1}},'fr_condo_plant',1)
 -- Celadon Hotel, building__rom_082d4f44. The room beds are the same drawing
 -- as the Condominiums', so they reuse that design rather than duplicating it.
 add('hotel_bed_a','building__rom_082d4f44',{{0x28e}},'fr_room_bed',1)
 add('hotel_bed_b','building__rom_082d4f44',{{0x29d}},'fr_room_bed',1)
 add('hotel_bed_c','building__rom_082d4f44',{{0x29f}},'fr_room_bed',1)
 add('hotel_bed_d','building__rom_082d4f44',{{0x2a3}},'fr_room_bed',1)
 -- Tanoby Ruins, building__rom_082d5034, 7 maps. Dilford Chamber carries
 -- bookcases at 0x287/0x288, read off the native sheet against
 -- FR_SEVEN_ISLAND_TANOBY_RUINS_DILFORD_CHAMBER's layout.
 add('ruins_shelf_a','building__rom_082d5034',{{0x287}},'fr_ruins_shelf',1)
 add('ruins_shelf_b','building__rom_082d5034',{{0x288}},'fr_ruins_shelf',1)
 -- Four Island, building__rom_082d4f14, 8 maps. Lorelei's house draws a
 -- wooden table at 0x2e4/0x2e5/0x2e6 and a bed at 0x2ed.
 add('lorelei_table_a','building__rom_082d4f14',{{0x2e4}},'fr_house_table',1)
 add('lorelei_table_b','building__rom_082d4f14',{{0x2e5}},'fr_house_table',1)
 add('lorelei_table_c','building__rom_082d4f14',{{0x2e6}},'fr_house_table',1)
 add('lorelei_bed','building__rom_082d4f14',{{0x2ed}},'fr_room_bed',1)
 -- Celadon Department Store, building__rom_082d4e6c, 6 maps. Stocked
 -- racking at 0x2c0/0x2cc/0x2d4/0x2da/0x2dc/0x2e5, read off the native sheet
 -- against FR_CELADON_CITY_DEPARTMENT_STORE_1F's layout.
 add('store_goods_rack','building__rom_082d4e6c',{{0x2c0}},'fr_store_goods_rack',1)
 add('store_shelf_a','building__rom_082d4e6c',{{0x2cc}},'fr_store_shelf',1)
 add('store_shelf_b','building__rom_082d4e6c',{{0x2d4}},'fr_store_shelf',1)
 add('store_shelf_c','building__rom_082d4e6c',{{0x2da}},'fr_store_shelf',1)
 add('store_shelf_d','building__rom_082d4e6c',{{0x2dc}},'fr_store_shelf',1)
 add('store_shelf_e','building__rom_082d4e6c',{{0x2e5}},'fr_store_shelf',1)
 -- Pokemon Tower, building__rom_082d4efc, 12 maps. It already carries the
 -- grave recipes; its bookcases and plants had none. Both objects are the same
 -- as ones authored elsewhere, so these reuse fr_ruins_shelf and fr_condo_plant
 -- rather than duplicating geometry.
 add('tower_bookcase_a','building__rom_082d4efc',{{0x288}},'fr_ruins_shelf',0x281)
 add('tower_bookcase_b','building__rom_082d4efc',{{0x28c}},'fr_ruins_shelf',0x281)
 add('tower_bookcase_c','building__rom_082d4efc',{{0x292}},'fr_ruins_shelf',0x281)
 add('tower_plant','building__rom_082d4efc',{{0x2a0}},'fr_condo_plant',1)
 -- Celadon Condominiums roof room, building__rom_082d4f5c, 2 maps. Rooftop
 -- plant at 0x288/0x28e, read off the native sheet against
 -- FR_CELADON_CITY_CONDOMINIUMS_ROOF_ROOM's layout.
 add('roof_ac_unit_a','building__rom_082d4f5c',{{0x288}},'fr_roof_ac_unit',1)
 add('roof_ac_unit_b','building__rom_082d4f5c',{{0x28e}},'fr_roof_ac_unit',1)
 -- Remaining furnished houses, all reusing fr_room_bed.
 -- Cerulean House 2, building__rom_082d4fa4: beds at 0x14f and 0x285.
 -- Seven Island house, building__rom_082d4e24: a bed at 0x14d.
 add('cerulean_house_bed_a','building__rom_082d4fa4',{{0x14f}},'fr_room_bed',1)
 add('cerulean_house_bed_b','building__rom_082d4fa4',{{0x285}},'fr_room_bed',1)
 add('sevii_house_bed','building__rom_082d4e24',{{0x14d}},'fr_room_bed',1)
 -- Saffron Gym, building__rom_082d4d64. A switch console at 0x2a7 and low
 -- round plinths at 0x293/0x294, read off the native sheet against
 -- FR_SAFFRON_CITY_GYM's layout.
 add('gym_switch_panel','building__rom_082d4d64',{{0x2a7}},'fr_gym_switch_panel',1)
 add('gym_disc_a','building__rom_082d4d64',{{0x293}},'fr_gym_disc',1)
 add('gym_disc_b','building__rom_082d4d64',{{0x294}},'fr_gym_disc',1)
 -- Cinnabar Gym, building__rom_082d4d7c: the same switch console as Saffron,
 -- at 0x2b0 rather than 0x2a7. Read off the native sheet against
 -- FR_CINNABAR_ISLAND_GYM's layout.
 add('cinnabar_gym_switch','building__rom_082d4d7c',{{0x2b0}},'fr_gym_switch_panel',1)
 -- The four remaining gyms, each read off its own native sheet and intersected
 -- with that gym's midLayout. Every gym has a distinct signature fixture.
 -- Cerulean (rom_082d4d1c) 0x2ae, Vermilion (rom_082d4d34) 0x2c8/0x2c9: switch
 --   hardware, reusing fr_gym_switch_panel.
 -- Viridian (rom_082d4cbc) 0x291: a potted tree.
 -- Celadon (rom_082d4d4c) 0x284/0x285: plant racks.
 add('cerulean_gym_switch','building__rom_082d4d1c',{{0x2ae}},'fr_gym_switch_panel',1)
 add('vermilion_gym_switch_a','building__rom_082d4d34',{{0x2c8}},'fr_gym_switch_panel',1)
 add('vermilion_gym_switch_b','building__rom_082d4d34',{{0x2c9}},'fr_gym_switch_panel',1)
 add('viridian_gym_plant','building__rom_082d4cbc',{{0x291}},'fr_gym_plant',1)
 add('celadon_gym_rack_a','building__rom_082d4d4c',{{0x284}},'fr_gym_plant_rack',1)
 add('celadon_gym_rack_b','building__rom_082d4d4c',{{0x285}},'fr_gym_plant_rack',1)
 -- Celadon Game Corner, building__rom_082d4cec, 3 maps, no recipe. Slot
 -- machines at 0x2b8/0x2b9/0x2ba/0x2bb, read off the native sheet against
 -- FR_CELADON_CITY_GAME_CORNER's layout.
 add('corner_slot_a','building__rom_082d4cec',{{0x2b8}},'fr_slot_machine',1)
 add('corner_slot_b','building__rom_082d4cec',{{0x2b9}},'fr_slot_machine',1)
 add('corner_slot_c','building__rom_082d4cec',{{0x2ba}},'fr_slot_machine',1)
 add('corner_slot_d','building__rom_082d4cec',{{0x2bb}},'fr_slot_machine',1)
 -- Battle Colosseum, building__rom_082d4c44, 4 maps. Seating at 0x30a
 -- (upper tier) and 0x2f6/0x2fa (lower), read off the native sheet against
 -- FR_BATTLE_COLOSSEUM_2P's layout.
 add('colosseum_stand_a','building__rom_082d4c44',{{0x30a}},'fr_stadium_stand',1)
 add('colosseum_stand_b','building__rom_082d4c44',{{0x2f6}},'fr_stadium_stand',1)
 add('colosseum_stand_c','building__rom_082d4c44',{{0x2fa}},'fr_stadium_stand',1)
 -- Four Island Day Care, building__rom_082d4f74, 5 maps. Toy racking at
 -- 0x309, read off the native sheet against
 -- FR_FOUR_ISLAND_POKEMON_DAY_CARE's layout.
 add('daycare_toy_rack','building__rom_082d4f74',{{0x309}},'fr_store_shelf',1)
 add('mart_complete_island','building__rom_082d4bcc',{{0x296,0x297},{0x29e,0x29f},{0x2a6,0x2a7},{0x2ae,0x2af}},'fr_mart_island',0x281)
 add('house_left_plant','player_house',{{0x57},{0x5f}},nil)
 recipes[#recipes].kind='plant';recipes[#recipes].h=24;recipes[#recipes].cutout=true
 add('house_right_plant','player_house',{{0x47},{0x4f}},nil)
 recipes[#recipes].kind='plant';recipes[#recipes].h=24;recipes[#recipes].cutout=true
 -- The rival's house shares the complete living-room drawings but has a
 -- different secondary atlas. Match all source cells before reusing models.
 local count=#recipes
 for i=1,count do
  local r=recipes[i]
  if r.pair=='player_house' and (r.name:match('^living_') or r.name=='room_television' or r.kind=='plant')then
   local other={};for k,v in pairs(r)do other[k]=v end
   other.name='neighbor_'..r.name;other.pair='house';recipes[#recipes+1]=other
  end
 end
 add('mart_edge_island','building__rom_082d4bcc',{{0x296},{0x29e},{0x2a6},{0x2ae}},'fr_mart_sidecase',0x281)
 add('lab_free_books','oak_lab',{{0x28b,0x28c},{0x73,0x74},{0x283,0x284}},'fr_lab_free_books',0x289)
 local designs={kitchen_sink_hob='fr_kitchen',center_terminal='fr_center_pc',
  center_2f_terminal_758='fr_upper_pc',lab_computer='fr_lab_pc',
  lab_terminal='fr_lab_terminal',lab_server='fr_lab_server',mart_rear_books='fr_mart_cooler'}
 for _,r in ipairs(recipes)do
  if designs[r.name]then r.design=designs[r.name]end
  if r.kind=='cabinet' and not r.design then r.design='fr_native_cabinet' end
  if r.design=='fr_native_cabinet' then
   if r.name:find('books') or r.name:find('stock') or r.name=='museum_bookcase' or r.name=='cabinet' then r.design='fr_native_books'
   elseif r.name:find('monitor_terminal') then r.design='fr_native_monitor'
   elseif r.name:find('server') or r.name:find('tape_terminal') then r.design='fr_native_rack' end
  end
  if r.kind=='centerUpperTerminal'then r.design='fr_upper_pc'end
  if r.name=='kitchen_sink_hob'then r.h=8 end
  if r.name=='mart_rear_display'then r.depth=1.5;r.frontOffset=32.2;r.base=12 end
  if r.name:find('mart_checkout',1,true)then r.h=7;r.join=true end
 end
end
function M.append(p,source,box,sample,emit)
 if not p.recipe.design then return false end
 local x,z=p.cx*16,p.cy*16
 local function point(a)return {a[1]+x,a[2],a[3]+z}end
 return Geometry.draw(p.recipe.design,{
  sample=sample,recipe=p.recipe,width=p.w,height=p.d,
  face=function(vertices,uv,shade)
   local points={};for i,a in ipairs(vertices)do points[i]=point(a)end
   emit(points,uv,shade or 1)
  end,
  box=function(l,b,n,r,h,s,uv)
   box(l+x,b,n+z,r+x,h,s+z,uv)
   emit({{l+x,b,s+z},{r+x,b,s+z},{r+x,b,n+z},{l+x,b,n+z}},uv,.65)
  end,
  source=function(sx,sy,w,h,a,b,c,d)source(sx,sy,w,h,point(a),point(b),point(c),point(d))end})
end
return M
