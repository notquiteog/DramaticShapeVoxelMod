-- Complete native drawings reviewed in Museum 1F, Silph 6F, the Power Plant
-- and Mansion B1F. These recipes describe public metatile IDs only; imported
-- artwork stays with the engine. Matching remains pair-local and all-or-none.
local recipes={}
local function cabinet(name,pair,rows,ground,facade,height,front,material)
 recipes[#recipes+1]={name=name,primary='building',pair='building__'..pair,rows=rows,
  kind='cabinet',ground=ground,h=height,depth=11,frontOffset=front,
  facade=facade,material=material}
end
local function plant(name,pair,rows,ground)
 recipes[#recipes+1]={name=name,primary='building',pair='building__'..pair,rows=rows,
  kind='plant',ground=ground,h=26,cutout=true}
end
local museum='rom_082d4c2c'
cabinet('museum_bookcase',museum,{{0x2CD,0x2CE},{0x2D5,0x2D6},{0x2DD,0x2DE}},
 0x281,{0,12,32,27},27,39,{1,12})
plant('museum_potted_tree',museum,{{0x2AE},{0x2B6}},0x281)
plant('museum_edge_potted_tree',museum,{{0x2CA},{0x2CB}},0x282)
recipes[#recipes+1]={name='museum_fossil_case',primary='building',pair='building__'..museum,
 rows={{0x283,0x284,0x285,0x286},{0x28B,0x28C,0x28D,0x28E},{0x288,0x296,0x289,0x28A}},
 kind='displayCase',ground=0x281,h=14,material={8,37}}
local function reception(name,rows,segments,material,trim)
 recipes[#recipes+1]={name='museum_reception_'..name,primary='building',pair='building__'..museum,
  rows=rows,kind='reception',ground=0x282,h=12,segments=segments,material=material,trim=trim}
end
reception('north',{{0x297},{0x293},{0x293},{0x293},{0x293}},
 {{3,14,16,80}},{8,24},{4,14})
reception('bend',{{0x29E,0x2A6,0x294},{0x2AC,0x29C,0x2A4}},
 {{3,0,16,22},{16,14,48,22},{32,22,48,32}},{8,5},{24,26})
reception('south',{{0x293},{0x29B}},{{0,0,16,27}},{8,5},{4,30})
local office='rom_082d4ecc'
cabinet('silph_server',office,{{0x37D},{0x385},{0x37E}},0x334,{0,12,16,28},28,40,{1,13})
cabinet('silph_tape_terminal',office,{{0x37B},{0x383}},0x334,{0,2,16,22},22,24,{1,3})
cabinet('silph_monitor_terminal',office,{{0x37C},{0x384}},0x334,{0,2,16,22},22,24,{1,3})
plant('silph_potted_plant',office,{{0x34D},{0x355}},0x334)
plant('silph_edge_potted_plant',office,{{0x34E},{0x356}},0x335)
local power='rom_082d4e9c'
cabinet('powerplant_tape_terminal',power,{{0x2EE},{0x2F6}},0x29F,{0,2,16,22},22,24,{1,3})
cabinet('powerplant_monitor_terminal',power,{{0x2EF},{0x2F7}},0x29F,{0,2,16,22},22,24,{1,3})
cabinet('powerplant_server',power,{{0x308},{0x310},{0x318}},0x29F,{0,10,16,30},30,40,{1,11})
local mansion='rom_082d4f2c'
cabinet('mansion_server',mansion,{{0x317},{0x31F},{0x36E}},0x286,{0,12,16,28},28,40,{1,13})
cabinet('mansion_tape_terminal',mansion,{{0x31D},{0x36C}},0x286,{0,2,16,22},22,24,{1,3})
cabinet('mansion_monitor_terminal',mansion,{{0x31E},{0x36D}},0x286,{0,2,16,22},22,24,{1,3})
plant('mansion_potted_tree',mansion,{{0x369},{0x361}},0x286)
return recipes
