-- Semantic crops of Crystal metatiles. The runtime resolves tile IDs from the
-- imported tileset; these are object layouts, never bundled ROM artwork.
-- Crop is {tileX,tileY,width,height} within one 32px metatile. Only complete
-- drawings are listed: walls, stairs, rugs and puzzle tiles remain native.
local function prop(id,block,crop,kind,floor)
 return {id='crystal_depth_'..id,block=block,crop=crop,kind=kind,groundBlock=floor}
end
local full={0,0,4,4}
local left={0,0,2,4}
local top={0,0,4,2}
return {
 -- Reviewed from the original Crystal atlases and isolated map inventory.
 -- Only complete solid object drawings are claimed. Puzzle floor patterns,
 -- whirlpools, holes, stairs and continuous room/sea walls are left native.
 TILESET_ELITE_FOUR_ROOM={
  prop('gym_orb_plinth',38,left,'orb_plinth',2),
  prop('gym_potted_shrub',11,{0,2,2,2},'planter',2),
 },
 TILESET_CHAMPIONS_ROOM={
  prop('champion_sculpted_column',53,left,'monument',49),
  prop('champion_orb_plinth',26,left,'orb_plinth',16),
  prop('bike_shop_display',12,top,'bicycle',18),
  prop('champion_cave_boulder',17,{0,0,2,2},'boulder',16),
 },
 TILESET_PORT={
  prop('harbor_gym_plinth',50,left,'monument',4),
 },
 TILESET_TOWER={
  prop('tower_gym_plinth',18,left,'orb_plinth',9),
  prop('tower_guardian',25,left,'monument',9),
  prop('tower_round_brazier',48,left,'orb_plinth',9),
  prop('tower_stone',50,{0,0,2,2},'boulder',9),
 },
 TILESET_CAVE={
  prop('cave_boulder',40,{0,0,2,2},'boulder',36),
 },
 TILESET_DARK_CAVE={
  prop('dark_cave_boulder',40,{0,0,2,2},'boulder',36),
 },
 TILESET_ICE_PATH={
  prop('ice_path_rounded_rock',32,{0,0,2,2},'boulder',2),
  prop('ice_path_faceted_rock',34,{2,0,2,2},'boulder',2),
 },
 TILESET_PARK={
  prop('park_bench',14,{0,0,4,3},'bench',1),
  prop('park_bin',15,{0,0,2,2},'bin',1),
 },
 TILESET_TRADITIONAL_HOUSE={
  prop('traditional_shelves',2,full,'cabinet',4),
  prop('traditional_drawers',26,left,'cabinet',4),
  prop('traditional_low_table',20,top,'table',4),
 },
 TILESET_FACILITY={
  prop('facility_server',2,left,'cabinet',3),
  prop('facility_machine_bank_left',18,full,'cabinet',3),
  prop('facility_machine_bank_right',19,full,'cabinet',3),
  prop('facility_books',6,left,'cabinet',3),
  prop('facility_console',8,top,'console',3),
  prop('facility_planter',9,left,'planter',3),
  prop('facility_bench',25,{0,2,4,2},'seat',3),
 },
 TILESET_RADIO_TOWER={
  prop('radio_shelves',10,left,'cabinet',1),
  prop('radio_planter',11,left,'planter',1),
  prop('radio_terminal',18,left,'machine',1),
  -- Match the whole reception desk before the taller equipment recipe. Its
  -- monitor pixels recur in the machine, but the desk's left counter does not.
  prop('radio_desk_terminal',43,{0,2,4,2},'console',1),
  prop('radio_equipment',28,{2,0,2,4},'machine',1),
  prop('radio_mixing_desk',56,{0,2,4,2},'console',1),
  prop('radio_chair',20,{0,0,2,2},'seat',1),
 },
 TILESET_GAME_CORNER={
  prop('game_corner_planter',18,left,'planter',1),
  prop('game_corner_arcade',14,left,'machine',1),
  prop('game_corner_slots',11,left,'console',1),
  prop('game_corner_slots_gold',11,{2,0,2,4},'console',1),
  prop('game_corner_prize_shelf',4,top,'cabinet',1),
  prop('game_corner_statue',29,{2,0,2,4},'statue',1),
 },
 TILESET_TRAIN_STATION={
  prop('station_seat',1,{0,0,2,2},'seat',3),
  prop('station_flower_box',12,left,'planter',3),
  prop('station_tree_planter',26,left,'planter',25),
  prop('station_statue',29,left,'statue',28),
 },
 TILESET_BATTLE_TOWER_INSIDE={
  prop('battle_tower_terminal',5,left,'machine',1),
  prop('battle_tower_table',7,{0,0,2,2},'table',1),
  prop('battle_tower_reception',28,top,'console',1),
  prop('battle_tower_statue',11,{0,0,2,2},'statue',10),
 },
 TILESET_MANSION={
  prop('mansion_books',15,left,'cabinet',3),
  prop('mansion_clock',15,{2,0,2,4},'cabinet',3),
  prop('mansion_planter',17,{2,2,2,2},'planter',3),
  prop('mansion_desk',18,{0,2,4,2},'console',3),
  prop('mansion_bed',20,left,'bed',3),
 },
 TILESET_LIGHTHOUSE={
  prop('ship_cabin_bed',24,{2,0,2,4},'bed',4),
  prop('ship_cabin_books',47,{2,0,2,4},'cabinet',4),
  prop('ship_cabin_chair',7,{2,2,2,2},'seat',4),
 },
 TILESET_GATE={
  prop('gate_chair',33,{0,0,2,2},'seat',1),
  prop('gate_terminal',44,{2,0,2,4},'machine',1),
 },
 TILESET_POKECOM_CENTER={
  prop('pokecom_healer',5,full,'bed',1),
  prop('pokecom_terminal',7,{2,0,2,4},'machine',1),
  prop('pokecom_call_terminal',36,left,'machine',1),
  prop('pokecom_seat',46,{0,0,2,2},'seat',1),
 },
}
