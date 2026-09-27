-- Complete office/ship drawings. Native IDs are checked as a whole before
-- claiming any cells; collision, scripts and NPC placement stay native.
local recipes={}
local function add(name,pair,rows,design,floor,primary)
 recipes[#recipes+1]={name=name,pair=pair,rows=rows,kind='designed',design=design,
  ground=floor,primary=primary or 'building'}
end
local office='building__rom_082d4ecc'
-- Rocket's complete processing machine includes the tall vessel, radiator,
-- control cabinet and side fittings. Its wall strip is source context only.
add('rocket_processing_machine',office,{{0x2ad,0x2af,0x289},{0x2b5,0x2b6,0x2b7},{0x2bd,0x2be,0x2bf}},'fr_processing_machine',0x281)
-- Giovanni's low office desk uses its own shallow three-row drawing.
add('rocket_executive_desk',office,{{0x2b0,0x2b1,0x2b2},{0x2b8,0x2b9,0x2c4},{0x2c0,0x2c1,0x2c2}},'fr_office_table',0x281)
for _,mid in ipairs({0x2e3,0x2e4,0x312,0x31a,0x386})do
 add('office_stool_'..mid,office,{{mid}},'fr_stool',mid<0x300 and 0x281 or mid<0x330 and 0x2ed or 0x334)
end
add('office_sofa',office,{{0x320,0x321,0x322},{0x328,0x329,0x32a}},'fr_sofa',0x2ed)
local desks={
 {{0x313,0x315},{0x31b,0x31d},{0x32b,0x32d}},
 {{0x313,0x314,0x315},{0x31e,0x31f,0x31d},{0x323,0x324,0x325},{0x32b,0x32c,0x32d}},
 {{0x313,0x314,0x315},{0x31b,0x316,0x317},{0x323,0x324,0x325},{0x3e8,0x32c,0x32d}},
 {{0x313,0x314,0x315},{0x323,0x324,0x325},{0x32b,0x32c,0x32d}},
}
for i,rows in ipairs(desks)do add('office_desk_'..i,office,rows,'fr_office_table',0x281)end
add('office_president_sofa',office,{{0x39d,0x39e,0x39f},{0x328,0x329,0x32a}},'fr_sofa',0x334)
add('office_president_table',office,{{0x3a5,0x3a6,0x3a6,0x3a6,0x3a7},{0x3ad,0x3b6,0x3ae,0x3b6,0x3af},{0x3b5,0x3b6,0x3a8,0x3b6,0x3b7},{0x3bd,0x3be,0x3be,0x3be,0x3bf}},'fr_round_table',0x334)
for _,row in ipairs({{0x300,0x308},{0x301,0x309},{0x302,0x309},{0x34f,0x356}})do
 recipes[#recipes+1]={name='office_plant_'..row[1],pair=office,rows={{row[1]},{row[2]}},
  kind='plant',h=26,ground=row[1]>=0x34d and 0x334 or 0x2ed,cutout=true}
end
-- Gate houses reuse this complete plant on both light and dark floor edges.
for _,row in ipairs({{0x2e8,0x2f0},{0x2e9,0x2f1},{0x2ef,0x2f7}})do
 recipes[#recipes+1]={name='gate_plant_'..row[1],pair='house',rows={{row[1]},{row[2]}},
  kind='plant',h=26,ground=0x281,cutout=true}
end
local ship='general__rom_082d4d94'
add('ship_barrel',ship,{{0x289}},'fr_ship_barrel',0x298,'general')
add('ship_bin',ship,{{0x28a}},'fr_ship_bin',0x298,'general')
add('ship_porthole',ship,{{0x282}},'fr_ship_porthole',0x298,'general')
for _,row in ipairs({{0x308,0x309,0x30a,0x310,0x311,0x312},{0x328,0x329,0x32a,0x330,0x331,0x332}})do
 add('ship_bed_'..row[2],ship,{{row[1],row[2],row[3]},{row[4],row[5],row[6]}},'fr_ship_bed',row[1],'general')
end
for _,row in ipairs({{0x30b,0x313,0x308},{0x32b,0x333,0x31c}})do
 recipes[#recipes+1]={name='ship_plant_'..row[1],pair=ship,primary='general',rows={{row[1]},{row[2]}},
  kind='plant',h=26,ground=row[3],cutout=true}
end
for _,mid in ipairs({0x303,0x334,0x33c})do
 add('ship_chair_'..mid,ship,{{mid}},'fr_ship_chair',mid==0x334 and 0x31c or 0x308,'general')
 recipes[#recipes].reverse=mid==0x33c
end
add('ship_side_table',ship,{{0x338,0x339},{0x340,0x341},{0x348,0x349}},'fr_ship_side_table',0x31c,'general')
add('ship_books',ship,{{0x302}},'fr_native_books',0x298,'general')
recipes[#recipes].h=20;recipes[#recipes].depth=10;recipes[#recipes].facade={2,3,12,10}
add('ship_cabin_table',ship,{{0x305,0x306,0x307},{0x30d,0x30e,0x30f}},'fr_ship_table',0x308,'general')
-- Straight deck sections only. Corners/diagonals stay unclaimed until their
-- adjoining hull and stair geometry can be modeled as a complete assembly.
for _,mid in ipairs({0x35b,0x35c,0x376,0x3b0,0x3b1,0x3b2})do
 add('ship_rail_'..mid,ship,{{mid}},'fr_ship_rail',0x350,'general')
end
return recipes
