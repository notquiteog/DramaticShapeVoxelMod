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
  prop('radio_equipment',28,{2,0,2,4},'machine',1),
  prop('radio_mixing_desk',22,{0,1,4,3},'console',1),
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
  prop('pokecom_healer',5,full,'machine',1),
  prop('pokecom_terminal',7,{2,0,2,4},'machine',1),
  prop('pokecom_call_terminal',36,left,'machine',1),
  prop('pokecom_seat',46,{0,0,2,2},'seat',1),
 },
}
