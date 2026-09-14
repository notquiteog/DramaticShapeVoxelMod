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
  item("crystal_kitchen_counter", {{37,53},{37,53},{37,53},{37,53},{37,53},{51,52}},1,
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
  item("crystal_house_table",{{38,39,39,41},{54,47,47,57},{5,47,47,21},{60,58,58,59}},1,
    tableParts(32,28),6),
  item("crystal_house_bookcase",{{14,15},{14,15},{30,31}},1,
    {upright(0,15,0,2,3,23,12,12)}),
  item("crystal_house_tv",{{6,7},{22,23},{30,31}},1,
    {upright(0,15,0,3,4,23,12,12)}),
  item("crystal_house_radio",{{12,13},{28,29},{30,31}},1,
    {upright(0,15,0,3,4,23,12,12)}),
  house[8], -- same complete stool drawing, including floor and leg zones
}
local mart={
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
  item("crystal_center_healer",{{28,29,30,31},{44,45,46,47},{60,61,61,63},{76,77,78,79}},17,
    {upright(0,31,0,7,8,31,16,16)}),
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
  item("crystal_bedroom_table",{{16,17,17,18},{32,33,33,34},{48,49,49,50}},1,
    {upright(0,31,0,17,18,20,0,24,3)},6),
  item("crystal_bedroom_books",{{5,6},{21,22},{37,38},{53,54}},1,
    {upright(0,15,0,5,6,31,20,12)}),
  item("crystal_bedroom_pc",{{11,12},{27,28},{43,44}},1,
    {upright(0,15,0,3,4,23,12,12)}),
  item("crystal_bed",{{59,60},{75,76},{91,92}},1,
    {upright(0,15,0,19,20,23,0,24,2)},6),
}
return {TILESET_PLAYERS_HOUSE=house,TILESET_LAB=lab,
  TILESET_HOUSE=commonHouse,TILESET_MART=mart,TILESET_POKECENTER=center,
  TILESET_PLAYERS_ROOM=bedroom}
