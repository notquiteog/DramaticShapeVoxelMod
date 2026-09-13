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
    {upright(0,31,0,11,12,31,16,16)}),
  item("crystal_lab_device", {{14,15},{30,31}},16,
    {upright(0,15,0,4,5,15,0,12)}),
}
return {TILESET_PLAYERS_HOUSE=house,TILESET_LAB=lab}
