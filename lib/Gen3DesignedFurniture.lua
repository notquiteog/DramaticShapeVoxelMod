local V=...
local M={}
local Geometry=V and V.require('InteriorFurniture') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/InteriorFurniture.lua')
function M.install(recipes)
 local function add(name,pair,rows,design,ground)
  recipes[#recipes+1]={name=name,pair=pair,rows=rows,kind='designed',design=design,ground=ground or 1}
 end
 -- Celadon's console demos sit on one continuous low island, with raised
 -- screens and game units. Preserve the native gaps beneath the counter.
 add('department_game_demo','building__rom_082d4e6c',{
  {0x2f2,0x30b,0x30c,0x2e9,0x30b,0x30c,0x2ea},
  {0x2eb,0x313,0x314,0x2d4,0x313,0x314,0x2ee}},'fr_department_game_demo',0x2c0)
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
 add('room_television','player_house',{{0x2b,0x2c},{0x33,0x34},{0x3b,0x3c}},'fr_home_bookcase')
 add('living_television','player_house',{{0x2d},{0x35},{0x3d}},'fr_living_tv')
 add('living_cupboard','player_house',{{0x2e,0x2f},{0x36,0x37},{0x3e,0x3f}},'fr_cupboard')
 add('neighbor_wall_picture','house',{{0x184},{0x185}},'fr_wall_picture')
 add('lab_complete_books','oak_lab',{{0x73,0x74},{0x283,0x284}},'fr_lab_books',0x289)
 -- Oak's lab machine bank: a clean 3x2 run of cabinet halves, each pair a
 -- distinct machine. Identified off the native sheet for oak_lab, where
 -- 0x2ed-0x2f2 are blue cases carrying orange canisters.
 add('lab_centrifuge_bank','oak_lab',{
  {0x2ed,0x2ee,0x2ef},{0x2f0,0x2f1,0x2f2}},'fr_lab_centrifuge',1)
 -- Agatha's 0x2a1 is floor-border artwork, not a pedestal.
 add('elite_column','building__rom_082d50c4',{{0x354},{0x355}},'fr_elite_column',0x2f0)
 for _,mid in ipairs{0x362,0x363}do
  add('elite_wall_column_'..mid,'building__rom_082d50c4',{{mid},{0x356},{0x360}},'fr_elite_column',0x2f0)
  recipes[#recipes].faceY=16
 end
 -- Celadon condominium rooms contain sofas, shared desks and tables, not
 -- beds/kitchens. Complete source drawings replace former wall-ID guesses.
 local condo='building__rom_082d4f8c'
 for _,top in ipairs{0x295,0x2f3}do
  add('condo_workstation_'..top,condo,{{top,0x296,0x297},{0x29d,0x29e,0x29f},{0x2a5,0x2a6,0x2a7}},'fr_condo_workstation',0x281)
 end
 add('condo_meeting_table',condo,{{0x2c5,0x2c6,0x2c6,0x2c7},{0x2cd,0x2ce,0x2ce,0x2cf},{0x2d5,0x2d6,0x2d6,0x2d7},{0x2dd,0x2de,0x2de,0x2df}},'fr_condo_meeting_table',0x281)
 add('condo_meeting_table_single_book',condo,{{0x2c5,0x2c6,0x2c6,0x2c7},{0x2cd,0x2d6,0x2ce,0x2cf},{0x2d5,0x2d6,0x2d6,0x2d7},{0x2dd,0x2de,0x2de,0x2df}},'fr_condo_meeting_table',0x281)
 add('condo_sofa_wide',condo,{{0x2e5,0x2e6,0x2e6,0x2e7},{0x2e0,0x2e1,0x2e1,0x2e2}},'fr_condo_sofa',0x281)
 add('condo_sofa',condo,{{0x2e5,0x2e6,0x2e7},{0x2e0,0x2e1,0x2e2}},'fr_condo_sofa',0x281)
 add('condo_books',condo,{{0x2ed,0x2ee},{0x2f5,0x2f6},{0x2ef,0x2f7}},'fr_condo_books',0x281)
 for _,a in ipairs{{0x2c9,0x2d1},{0x2ca,0x2d1},{0x2c8,0x2d0}}do
  add('condo_planter_'..a[1],condo,{{a[1]},{a[2]}},nil,0x281)
  recipes[#recipes].kind='plant';recipes[#recipes].h=24;recipes[#recipes].cutout=true
 end
 -- Celadon Hotel is a lobby. Preserve its red carpet under cushions,
 -- tables and sofa instead of interpreting wallpaper/floor IDs as beds.
 local hotel='building__rom_082d4f44'
 add('hotel_lobby_table',hotel,{{0x292,0x293},{0x29a,0x29b}},'fr_hotel_table',0x29e)
 add('hotel_lobby_cushion',hotel,{{0x29f}},'gb_seat',0x29e)
 add('hotel_lobby_sofa',hotel,{{0x2b0},{0x2b8},{0x2c0}},'fr_hotel_sofa',0x29e)
 add('hotel_lobby_plant',hotel,{{0x281},{0x289}},nil,0x29e)
 recipes[#recipes].kind='plant';recipes[#recipes].h=24;recipes[#recipes].cutout=true
 -- Tanoby's relief is stone masonry, never bookshelves. Complete horizontal
 -- masonry courses keep the source frieze upright with a closed stone cap.
 for _,middle in ipairs{0x2b9,0x2d6}do
  add('tanoby_masonry_'..middle,'building__rom_082d5034',{{0x2a1},{middle},{0x2bc}},'fr_tanoby_masonry',0x288)
 end
 -- Lorelei's orange rug is floor, not a line of miniature tables.
 local lorelei='building__rom_082d4f14'
 add('lorelei_native_bed',lorelei,{{0x2e8,0x2e9,0x2ea},{0x2f0,0x2f1,0x2f2}},'fr_lorelei_bed',0x286)
 add('lorelei_native_table',lorelei,{{0x2eb,0x2ec},{0x2f3,0x2f4}},'fr_lorelei_table',0x2e5)
 add('lorelei_bookcase',lorelei,{{0x2fa,0x2fb},{0x2fc,0x2fd},{0x2fe,0x2ff}},'fr_condo_books',0x286)
 add('lorelei_display_case',lorelei,{{0x2ed,0x2ee},{0x2f5,0x2f6},{0x2ef,0x2f7}},'fr_lorelei_display',0x286)
 -- Complete Celadon displays; 0x2c0 is bare parquet, never stock.
 add('department_glass_case','building__rom_082d4e6c',{
  {0x317,0x317},{0x31f,0x31f},{0x327,0x327}},'fr_department_glass',0x2c0)
 add('department_stock_island','building__rom_082d4e6c',{
  {0x318,0x319},{0x320,0x321},{0x328,0x329},{0x330,0x331}},'fr_department_stock',0x2c0)
 -- Tower boundary tiles are walls; grave markers are handled above.
 local roofRoom='building__rom_082d4f5c'
 add('roof_room_books',roofRoom,{{0x2a1,0x2a1},{0x29b,0x29c},{0x2a3,0x2a4}},'fr_roof_room_books',0x29e)
 add('roof_room_desk',roofRoom,{{0x291,0x292},{0x299,0x29a}},'fr_roof_room_desk',0x29e)
 add('roof_room_stool',roofRoom,{{0x288},{0x290}},'fr_roof_room_stool',0x29e)
 for _,rows in ipairs{{{0x281},{0x289}},{{0x282},{0x28a}}}do
  add('roof_room_plant_'..rows[1][1],roofRoom,rows,nil,0x29e)
  recipes[#recipes].kind='plant';recipes[#recipes].h=24;recipes[#recipes].cutout=true
 end
 -- Cerulean's robbed house and Seven Island: 14f is the entrance rug,
 -- 285 wallpaper/bookcase art and 14d a shelf foot. None is a bed.
 local sevii='building__rom_082d4e24'
 add('sevii_bookcase',sevii,{{0x13d,0x13e},{0x145,0x146},{0x14d,0x14e}},'fr_home_bookcase',0x109)
 add('sevii_wardrobe',sevii,{{0x17b,0x17c,0x17d},{0x181,0x181,0x181},{0x182,0x182,0x182}},'fr_sevii_wardrobe',0x109)
 add('sevii_planter',sevii,{{0x156},{0x15e}},nil,0x109)
 recipes[#recipes].kind='plant';recipes[#recipes].h=24;recipes[#recipes].cutout=true
 add('sevii_dining_table',sevii,{{0x165,0x166},{0x16d,0x16e}},'fr_lorelei_table',0x109)
 for _,mid in ipairs{0x16f,0x167}do
  add('sevii_dining_chair_'..mid,sevii,{{mid}},'fr_sevii_chair',0x109)
  recipes[#recipes].east=mid==0x167
 end
 add('tower_reception_elbow','building__rom_082d4efc',{
  {0x2c9,0x2ca,0x2ca,0x2ca,0x2ca,0x2ca},
  {0x2d1,0x2d2,0x2d2,0x2d3,0x2d2,0x2d2}},'fr_tower_reception',0x282)
 add('tower_reception_return','building__rom_082d4efc',{{0x2d4},{0x2c8},{0x2c8},{0x2d0}},'fr_tower_reception_return',0x282)
 -- Saffron has fluted columns and square floor teleport pads, not consoles
 -- and circular plinths. Complete columns include their cap, shaft and foot.
 add('saffron_column','building__rom_082d4d64',{{0x297},{0x29f},{0x2a7}},'fr_saffron_column',0x281)
 add('saffron_telepad','building__rom_082d4d64',{{0x293}},'fr_saffron_telepad',0x281)
 -- Cinnabar's quiz hardware is two cells wide and two cells tall. 2b0 is
 -- vertical partition artwork, never a free-standing quiz console.
 for _,top in ipairs{{0x2c8,0x2c9},{0x290,0x2a0}}do
  add('cinnabar_quiz_'..top[1],'building__rom_082d4d7c',{top,{0x298,0x2a8}},'fr_cinnabar_quiz',0x281)
 end
 -- Cerulean 2ae, Viridian 291 and Celadon 284 are wall/window artwork;
 -- keep them out of furniture recipes. Celadon shrubs need whole drawings.
 -- These wall-vent cells are not switch consoles. The puzzle objects are
 -- the fifteen separate native bins at 2b8.
 add('vermilion_puzzle_bin','building__rom_082d4d34',{{0x2b8}},'fr_vermilion_bin',0x281)
 add('vermilion_electric_gate','building__rom_082d4d34',{{0x2a9,0x2aa,0x285,0x2ab,0x2ac},{0x2b1,0x2b2,0x28d,0x2b3,0x2b4}},'fr_vermilion_gate',0x281)
 -- Whole paired cabinets preserve the narrow back-to-back island. Adjacent
 -- blue cells are individual stools, not additional slot machines.
 add('corner_pair','building__rom_082d4cec',{{0x2b8,0x2b9}},'fr_corner_pair',0x291)
 add('corner_pair_end','building__rom_082d4cec',{{0x2c0,0x2c1},{0x2c8,0x2c9}},'fr_corner_pair_end',0x291)
 -- 0x2a8/0x2a9 are untouched carpet immediately behind the cabinets.
 for _,east in ipairs{false,true}do
  local suffix=east and 'east' or 'west'
  add('corner_half_'..suffix,'building__rom_082d4cec',{{east and 0x2b9 or 0x2b8}},'fr_corner_half_'..suffix,0x291)
  add('corner_half_end_'..suffix,'building__rom_082d4cec',{{east and 0x2c1 or 0x2c0},{east and 0x2c9 or 0x2c8}},'fr_corner_half_'..suffix,0x291)
 end
 for _,mid in ipairs{0x2aa,0x2ab,0x2b2,0x2b3,0x2ba,0x2bb}do
  add('corner_stool_'..mid,'building__rom_082d4cec',{{mid}},'fr_corner_chair',0x291)
  recipes[#recipes].backEast=mid%2==1
 end
 -- Colosseum 0x30a is floor; 0x2f6/0x2fa are wall art, not stands.
 -- Native walkable Day Care cushions, not merchandise racks.
 add('daycare_cushion','building__rom_082d4f74',{{0x309}},'fr_daycare_cushion',0x309)
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
 local designs={museum_bookcase='fr_museum_bookcase',center_vending='fr_center_storage',kitchen_sink_hob='fr_kitchen',center_terminal='fr_center_pc',
  center_2f_terminal_758='fr_upper_pc',lab_computer='fr_lab_pc',
  lab_terminal='fr_lab_terminal',lab_server='fr_lab_server',mart_rear_books='fr_mart_cooler',mart_checkout_return='fr_mart_register',mart_checkout='fr_mart_counter',mart_checkout_end='fr_mart_counter_end'}
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
