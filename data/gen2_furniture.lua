-- Crystal furniture recipes. Coordinates refer to the player's source atlas;
-- no artwork or collision is bundled or changed. Whole drawings are claimed
-- before automatic wall folding so fronts become vertical faces only once.
local function item(id, tiles, floor, parts, support)
  return { id=id, tiles=tiles, groundTiles={{floor}}, parts=parts,
    support=support or 0, panes=false, roofRows=0, roofBack=0,
    roofFront=0, roofCycle={0,0}, slab=0, frontEave=0 }
end
local function upright(x0,x1,t0,t1,f0,f1,z,depth,rise)
  return {kind="upright",x={x0,x1},top={t0,t1},facade={f0,f1},
    z=z,depth=depth,rise=rise,stretch=true}
end
local house = {
  -- Claim the wall apron above the hob/sink together with the refrigerator;
  -- otherwise those half-cells become unrelated full-height wall blocks.
  item("crystal_kitchen", {{17,17,17,17,10,11},{80,81,67,69,26,27},{82,83,24,25,42,43}},1,
    {upright(0,15,8,15,16,23,8,16),
     upright(16,31,8,15,16,23,8,16),
     upright(32,47,0,6,7,23,8,12)},8),
  item("crystal_dining_table", {
    {35,34,34,36},{37,21,21,53},{37,21,21,53},{51,50,50,52},
    {28,64,64,29},{1,1,1,1}}, 1, {
      upright(0,31,0,27,28,30,0,32,3),
      {kind="upright",x={0,31},top={31,31},facade={32,34},z=2,depth=28,
       supports={fromRow=32,zones={
         {x={2,4},z={2,4}},{x={27,29},z={2,4}},
         {x={2,4},z={27,29}},{x={27,29},z={27,29}}}}}}, 6),
  -- The refrigerator's lid occupies the bottom half of the wall cell.
  -- Its door drawing folds onto the kitchen cell directly below it.
  item("crystal_fridge", {{10,11},{26,27},{42,43}},1,
    {upright(0,15,0,6,7,23,8,12)}),
  item("crystal_stove", {{80,81},{82,83}},1,
    {upright(0,15,0,7,8,15,0,16)},8),
  item("crystal_sink", {{67,69},{24,25}},1,
    {upright(0,15,0,7,8,15,0,16)},8),
  item("crystal_kitchen_counter", {{37,53},{37,53},{37,53},{37,53},{37,53},{51,52},{17,17},{17,17}},1,
    {upright(0,15,0,43,44,47,0,48,4)},8),
  item("crystal_television", {{6,7},{22,23},{8,9}},1,
    {upright(0,15,0,5,6,23,8,12)}),
  item("crystal_books", {{14,15},{58,59}},1,
    {upright(0,15,0,3,4,15,0,12)}),
  item("crystal_stool", {{2,3},{18,19}},1,
    {{kind="upright",x={2,13},top={2,8},facade={9,13},z=3,depth=10,
      stretch=true,supports={fromRow=11,zones={
        {x={3,4},z={4,5}},{x={11,12},z={4,5}},
        {x={3,4},z={10,11}},{x={11,12},z={10,11}}}}}},5),
}
local lab = {
  item("crystal_lab_shelves", {{5,7},{3,4},{3,4},{19,20}},16,
    {upright(0,15,0,5,6,31,20,12)}),
  item("crystal_starter_table", {
    {5,6,6,6,6,7},{21,22,22,22,22,23},{37,38,38,38,38,39},{16,16,16,16,16,16}},16,
    {upright(0,47,0,11,13,15,0,16,3),
     {kind="upright",x={0,47},top={16,16},facade={16,18},z=2,depth=12,
      supports={fromRow=16,zones={
        {x={2,4},z={2,4}},{x={43,45},z={2,4}},
        {x={2,4},z={11,13}},{x={43,45},z={11,13}}}}}},6),
  item("crystal_elm_desk", {{16,16,133,134},{129,130,131,132},{145,146,147,148},{161,162,163,164}},16,
    {upright(0,31,8,19,20,25,16,16),
     upright(16,31,0,1,2,7,16,6,6)},6),
  item("crystal_lab_computer", {{10,11,12,13},{26,27,28,29},{37,38,38,39},{16,16,16,16}},16,
    {upright(0,31,0,3,4,15,0,14,6),
     upright(0,31,16,16,16,21,0,16)},6),
  item("crystal_healing_machine", {{66,67,68,69},{82,83,84,85},{70,71,71,73},{86,87,88,89}},16,
    -- The mattress/control surface lies across the full two-cell bed. Only
    -- its shallow apron folds vertically; it is not a standing appliance.
    {upright(0,31,0,27,28,31,0,32,2)},6),
  {id="crystal_lab_bin",tiles={{14,15},{30,31}},groundTiles={{16}},model="bin",parts={},support=0},
}
-- Common house, shop and Center families are separate vocabularies: identical
-- numeric tile IDs across tilesets are never treated as the same object.
local function tableParts(width,depth)
  return {upright(0,width-1,0,22,23,25,0,depth,3),
    {kind="upright",x={0,width-1},top={26,26},facade={26,28},z=2,depth=depth-4,
     supports={fromRow=26,zones={
       {x={2,4},z={2,4}},{x={width-5,width-3},z={2,4}},
       {x={2,4},z={depth-5,depth-3}},
       {x={width-5,width-3},z={depth-5,depth-3}}}}}}
end
local commonHouse={
  {id='crystal_house_planter',tiles={{10,11},{8,9},{26,27},{24,25}},groundTiles={{1}},model='planter',parts={},support=0},
  {id='crystal_house_tall_books',tiles={{50,51},{48,49},{14,15},{60,59}},groundTiles={{1}},design='gb_house_tall_books',parts={},support=0},
  {id='crystal_house_wall_picture',tiles={{45,46},{61,62}},groundTiles={{1}},design='gb_picture',parts={},support=0},
  {id='crystal_house_wall_clock',tiles={{36,74},{52,44}},groundTiles={{1}},design='gb_picture',parts={},support=0},
  item("crystal_house_table",{{38,39,39,41},{54,47,47,57},{5,47,47,21},{60,58,58,59}},1,
    tableParts(32,28),6),
  item("crystal_house_bookcase",{{14,15},{14,15},{30,31}},1,
    {upright(0,15,0,2,3,23,12,12)}),
  item("crystal_house_tv",{{6,7},{22,23},{30,31}},1,
    {upright(0,15,0,3,4,23,12,12)}),
  item("crystal_house_radio",{{12,13},{28,29},{30,31}},1,
    {upright(0,15,0,3,4,23,12,12)}),
  house[#house], -- same complete stool drawing, including floor and leg zones
}
local mart={
  {id='crystal_department_directory',tiles={{44,45},{60,61}},groundTiles={{1}},design='gb_department_directory',parts={},support=0},
  {id='crystal_department_register',tiles={{32,33},{48,49}},groundTiles={{1}},design='gb_department_register',parts={},support=7},
  {id='crystal_department_counter_window',tiles={{14,15},{42,43}},groundTiles={{1}},design='gb_department_counter_window',parts={},support=0},
  {id='crystal_department_elevator',tiles={{6,7,10,17},{22,23,73,73}},groundTiles={{1}},design='gb_department_elevator',parts={},support=0},
  {id='crystal_department_window',tiles={{14,15},{28,29}},groundTiles={{1}},design='gb_department_window',parts={},support=0},
  {id='crystal_department_bench',tiles={{34,35},{50,51},{36,37},{52,53}},groundTiles={{1}},design='gb_department_bench',parts={},support=4},
  {id='crystal_department_vending',tiles={{12,13},{76,77},{76,77},{78,79}},groundTiles={{1}},design='gb_department_vending',parts={},support=0},
  item("crystal_mart_cooler",{{12,13},{86,87},{88,89},{90,91}},72,
    {upright(0,15,0,5,6,31,20,12)}),
  item("crystal_mart_shelf",{{12,13},{80,81},{80,81},{94,95}},72,
    {upright(0,15,0,5,6,31,20,12)}),
  item("crystal_mart_display",{{64,65,66,43},{80,81,82,69},{67,68,92,93},{83,84,31,85}},72,
    {upright(0,31,0,7,8,31,16,16)}),
  item("crystal_mart_bench",{{38,39},{54,55},{40,41},{56,57}},72,
    {upright(0,15,0,26,27,31,0,32)},5),
  item("crystal_mart_counter",{{62,63},{62,63}},72,
    {upright(0,15,0,11,12,15,0,16,4)},8),
}
local center={
  {id='crystal_link_controls',tiles={{8,9,34,35},{24,25,50,51}},groundTiles={{17}},design='gb_link_controls',parts={},support=0},
  {id='crystal_trade_controls',tiles={{38,39,34,35},{40,41,50,51}},groundTiles={{17}},design='gb_link_controls',parts={},support=0},
  item("crystal_center_healer",{{28,29,30,31},{44,45,46,47},{60,61,61,63},{76,77,78,79}},17,
    {upright(0,31,0,27,28,31,0,32,2)},6),
  item("crystal_center_terminal",{{32,33},{48,49},{64,65}},17,
    {upright(0,15,0,4,5,23,12,12)}),
  item("crystal_center_receiver",{{3,37},{19,53},{70,71}},17,
    {upright(0,15,0,4,5,23,8,16)}),
  item("crystal_center_seat",{{72,73},{88,89}},17,
    {upright(1,14,0,10,11,15,1,14)},5),
  item("crystal_center_counter",{{52,52},{36,36}},17,
    {upright(0,15,0,7,8,15,0,16)},8),
  item("crystal_center_counter_ball",{{52,12},{36,36}},17,
    {upright(0,15,0,7,8,15,0,16)},8),
  item("crystal_center_counter_balls",{{12,12},{36,36}},17,
    {upright(0,15,0,7,8,15,0,16)},8),
  {id="crystal_center_bin",tiles={{68,69},{84,85}},groundTiles={{17}},model="bin",parts={},support=0},
}
local bedroom={
  {id='crystal_bedroom_picture',tiles={{68,69},{84,85}},groundTiles={{1}},design='gb_picture',parts={},support=0},
  {id='crystal_actual_bed',tiles={{3,4},{19,20},{35,36},{51,52}},groundTiles={{1}},design='gb_bed',parts={},support=0},
  {id="crystal_bedroom_workstation",model="room_desk",support=6,
   tiles={{11,12,2,2},{27,28,66,67},{43,44,82,83},{48,49,49,50}},
   groundTiles={{1}},parts={}},
  item("crystal_bedroom_table",{{16,17,17,18},{32,33,33,34},{48,49,49,50}},1,
    {upright(0,31,0,17,18,20,0,24,3)},6),
  item("crystal_bedroom_books",{{5,6},{21,22},{37,38},{53,54}},1,
    {upright(0,15,0,5,6,31,20,12)}),
  item("crystal_bedroom_pc",{{11,12},{27,28},{43,44}},1,
    {upright(0,15,0,3,4,23,12,12)}),
  item("crystal_bed",{{59,60},{75,76},{91,92}},1,
    {upright(0,15,0,19,20,23,0,24,2)},6),
}
-- Traditional rooms use complete hutches and low tatami furniture. These
-- native drawings differ from the modern-house atlas despite shared numbers.
local tatami={{68,69,69,70},{84,85,85,86},{69,70,68,69},{85,86,84,85}}
local traditional={
 {id='crystal_traditional_hutch',tiles={{35,36},{41,42},{57,58},{82,83}},design='gb_traditional_hutch'},
 {id='crystal_traditional_drawers',tiles={{35,36},{30,31},{46,47},{24,25}},design='gb_traditional_drawers'},
 {id='crystal_traditional_books',tiles={{35,36},{62,63},{24,25}},design='gb_traditional_books'},
 {id='crystal_traditional_cupboard',tiles={{35,36},{8,9},{82,83}},design='gb_traditional_cupboard'},
 {id='crystal_traditional_radio',tiles={{10,11},{26,27}},design='gb_traditional_radio'},
 {id='crystal_traditional_cushion',tiles={{2,3},{18,19}},design='gb_seat',support=2.5},
 {id='crystal_traditional_table',tiles={{35,34,34,36},{66,21,21,67},{66,21,21,67},{51,50,50,52},{37,81,81,38}},design='gb_traditional_table',support=5},
}
for _,t in ipairs(traditional)do t.groundTiles=tatami;t.groundAligned=true;t.parts={};t.support=t.support or 0 end
local designs={
 crystal_kitchen='gb_kitchen',crystal_bedroom_workstation='gb_desk',
 crystal_television='gb_tv',crystal_books='gb_short_books',crystal_bed='gb_tv',crystal_bedroom_pc='gb_pc',crystal_center_terminal='gb_pc',
 crystal_bedroom_books='gb_books',crystal_lab_shelves='gb_books',
 crystal_lab_computer='gb_lab_pc',crystal_elm_desk='gb_elm_desk',
 crystal_mart_shelf='gb_mart_shelf',crystal_mart_cooler='gb_mart_cooler',
 crystal_mart_display='gb_mart_display',crystal_center_seat='gb_seat',
 crystal_center_receiver='gb_receiver',crystal_bedroom_table='gb_table',
 crystal_center_counter='gb_counter',crystal_center_counter_ball='gb_counter',crystal_center_counter_balls='gb_counter',
 crystal_healing_machine='gb_healer',crystal_center_healer='gb_healer',
 crystal_house_tv='gb_tv',crystal_house_radio='gb_radio',
 crystal_house_bookcase='gb_house_books',crystal_house_table='gb_table',
}
for _,list in ipairs({house,lab,commonHouse,mart,center,bedroom})do
 for _,t in ipairs(list)do
  if designs[t.id]then t.design=designs[t.id];t.parts={} end
  if t.id=='crystal_bed' then t.id='crystal_bedroom_tv';t.support=0 end
  if t.design=='gb_seat' then t.support=2.5 end
  if t.design=='gb_counter'then t.support=7;t.supportBounds={0,8.5,16,15.5}end
  if t.design=='gb_table' or t.design=='gb_desk' or t.design=='gb_healer'then
   t.supportBounds={0,8,32,24}
  end
 end
end
-- Only unclaimed native wall rows become a thin backing. Identical tile IDs
-- elsewhere (floors, furniture, other tilesets) retain their authored role.
local function wall(list,tile,row,front,floor)
 local t=item('wall_'..tile..'_'..row,{{tile}},floor,{},0)
 t.design='wall';t.tileRow=row;t.wallFront=front-row*8
 t.wallHigh=front==24 and (32-row*8) or (24-row*12)
 t.wallLow=row==(front==24 and 2 or 1) and 0 or t.wallHigh-(front==24 and 8 or 12)
 list[#list+1]=t
end
wall(house,17,0,16,1);wall(house,17,1,16,1)
wall(bedroom,2,0,16,1);wall(bedroom,2,1,16,1)
wall(lab,1,0,16,16);wall(lab,17,1,16,16)
wall(center,2,0,16,17);wall(center,2,1,16,17)
for row=0,3 do
 local tile=row<2 and 17 or 80
 local t=item('traditional_wall_'..row,{{tile}},1,{},0)
 t.design='wall';t.tileRow=row;t.wallFront=32-row*8
 t.wallHigh=32-row*8;t.wallLow=t.wallHigh-8
 t.groundTiles=tatami;t.groundAligned=true;traditional[#traditional+1]=t
end
local tower={item('crystal_tower_timber',{
 {45,46,46,47},{61,62,62,63},{60,62,1,44},{77,78,78,79},{77,78,78,79},{93,94,94,95}},2,{},0)}
tower[1].design='gb_tower_timber'
local lighthouse={item('crystal_lighthouse_beacon',{
 {9,10,10,12},{25,26,44,28},{25,64,65,28},{25,80,81,28},{20,130,130,53},{11,128,129,11}},13,{},0)}
lighthouse[1].design='gb_lighthouse_beacon'
lighthouse[1].maps={OLIVINE_LIGHTHOUSE_6F=true}
lighthouse[1].groundTiles={{13,29},{29,13}};lighthouse[1].groundAligned=true
-- The same tiles are a dining table aboard the Fast Ship. Geometry follows
-- the location's subject as well as the source drawing.
lighthouse[2]=item('crystal_ship_dining_table',lighthouse[1].tiles,13,{},0)
lighthouse[2].design='gb_ship_dining_table'
lighthouse[2].groundTiles=lighthouse[1].groundTiles;lighthouse[2].groundAligned=true
-- Complete machinery sections, ahead of the old facility cabinet crops.
-- The narrow brass conduit belongs to the machine, not a shelf of books.
local facility={
 item('crystal_facility_generator',{{69,69,70,69},{85,85,86,85},{10,11,75,10},{26,27,91,26}},28,{},0),
 item('crystal_facility_generator_end',{{69,70,69,59},{85,86,85,59},{74,75,74,59},{90,91,90,59}},28,{},0),
 item('crystal_facility_rack',{{64,66},{10,11},{10,11},{26,27}},28,{},0),
 item('crystal_facility_cable_tray',{{12,13},{12,13}},28,{},0),
}
facility[1].design='gb_facility_generator'
facility[2].design='gb_facility_generator_end'
facility[3].design='gb_facility_rack'
facility[4].design='gb_facility_cable_tray'
local radio={
 item('crystal_broadcast_studio_desk',{{86,87,1,1,1,1},{88,89,7,7,7,36},{76,77,23,23,23,22}},1,{},0),
}
radio[1].design='gb_broadcast_studio'
-- Complete native Goldenrod/Celadon paired cabinets and separate stools.
-- Keep their checkerboard floor; the old block crops folded seats into desks.
local corner={
 item('crystal_corner_pair',{{160,161,162,163},{144,145,146,147}},1,{},0),
 item('crystal_corner_cap',{{128,129,130,131},{144,145,146,147}},1,{},0),
 item('crystal_corner_end',{{176,177,178,179},{192,193,194,195}},1,{},0),
 item('crystal_corner_stool',{{10,11},{26,27}},1,{},0),
}
for i,r in ipairs(corner)do
 r.design=({'gb_corner_pair','gb_corner_cap','gb_corner_end','fr_corner_stool'})[i]
 r.groundTiles={{1,16},{17,18}};r.groundAligned=true
end
local station={
 item('crystal_station_seat',{{64,65},{66,67}},61,{},0),
 item('crystal_station_platform_fence',{{8},{24}},62,{},0),
 item('crystal_station_entry_rail',{{53,54},{55,56},{57,58},{59,60}},62,{},0),
}
for i,r in ipairs(station)do
 r.design=({'gb_station_seat','gb_station_fence','gb_station_entry'})[i]
 r.groundTiles={{i==1 and 61 or 62}};r.groundAligned=true
end
local underground={
 {id='crystal_underground_stall_counter',tiles={{8,9},{24,25},{24,25},{24,25},{24,25},{36,37}},groundTiles={{1}},design='gb_underground_stall_counter',parts={},support=8},
 {id='crystal_underground_tall_plant',tiles={{56,57},{5,6},{5,6},{21,22}},groundTiles={{1}},model='planter',parts={},support=0},
 {id='crystal_underground_small_plant',tiles={{56,57},{21,22}},groundTiles={{1}},model='planter',parts={},support=0},
}
-- The neighboring stool drawings are native WALKABLE floor, so they are not
-- raised into models that would visually block the narrow shopping aisle.
for _,r in ipairs(underground)do r.maps={GOLDENROD_UNDERGROUND=true} end
return {TILESET_UNDERGROUND={{id='crystal_warehouse_crate',tiles={{67,68},{83,84}},groundTiles={{16}},design='gb_warehouse_crate',parts={},support=12,maps={GOLDENROD_UNDERGROUND_WAREHOUSE=true,GOLDENROD_DEPT_STORE_B1F=true,TEAM_ROCKET_BASE_B1F=true}}},TILESET_GATE=underground,TILESET_TRAIN_STATION=station,TILESET_GAME_CORNER=corner,TILESET_RADIO_TOWER=radio,TILESET_FACILITY=facility,TILESET_TOWER=tower,TILESET_LIGHTHOUSE=lighthouse,TILESET_PLAYERS_HOUSE=house,TILESET_LAB=lab,
  TILESET_HOUSE=commonHouse,TILESET_TRADITIONAL_HOUSE=traditional,TILESET_MART=mart,TILESET_POKECENTER=center,
  TILESET_PLAYERS_ROOM=bedroom}
