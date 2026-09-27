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
