local V=...
local M={}
local Geometry=V and V.require('InteriorFurniture') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/InteriorFurniture.lua')
function M.install(recipes)
 local function add(name,pair,rows,design,ground)
  recipes[#recipes+1]={name=name,pair=pair,rows=rows,kind='designed',design=design,ground=ground or 1}
 end
 add('room_bed','player_house',{{0x283,0x284,0x285},{0x28b,0x28c,0x28d},{0x293,0x294,0x295}},'fr_bed')
 add('room_computer','player_house',{{0x287,0x20},{0x28f,0x86},{0x297,0x5a}},'fr_room_pc')
 add('room_wood_chair','player_house',{{0x30},{0x38}},'fr_wood_chair')
 add('room_console','player_house',{{0x35},{0x28e},{0x296}},'fr_console',0x45)
 add('room_television','player_house',{{0x2b,0x2c},{0x33,0x34},{0x3b,0x3c}},'fr_television')
 add('living_television','player_house',{{0x2d},{0x35},{0x3d}},'fr_living_tv')
 add('living_cupboard','player_house',{{0x2e,0x2f},{0x36,0x37},{0x3e,0x3f}},'fr_cupboard')
 add('lab_complete_books','oak_lab',{{0x73,0x74},{0x283,0x284}},'fr_lab_books',0x289)
 add('mart_complete_island','building__rom_082d4bcc',{{0x296,0x297},{0x29e,0x29f},{0x2a6,0x2a7},{0x2ae,0x2af}},'fr_mart_island',0x281)
 add('house_left_plant','player_house',{{0x57},{0x5f}},nil)
 recipes[#recipes].kind='plant';recipes[#recipes].h=24;recipes[#recipes].cutout=true
 add('mart_edge_island','building__rom_082d4bcc',{{0x296},{0x29e},{0x2a6},{0x2ae}},'fr_mart_sidecase',0x281)
 add('lab_free_books','oak_lab',{{0x28b,0x28c},{0x73,0x74},{0x283,0x284}},'fr_lab_free_books',0x289)
 local designs={kitchen_sink_hob='fr_kitchen',center_terminal='fr_center_pc',
  center_2f_terminal_758='fr_upper_pc',lab_computer='fr_lab_pc',
  lab_terminal='fr_lab_terminal',lab_server='fr_lab_server',mart_rear_books='fr_mart_cooler'}
 for _,r in ipairs(recipes)do
  if designs[r.name]then r.design=designs[r.name]end
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
  sample=sample,
  box=function(l,b,n,r,h,s,uv)
   box(l+x,b,n+z,r+x,h,s+z,uv)
   emit({{l+x,b,s+z},{r+x,b,s+z},{r+x,b,n+z},{l+x,b,n+z}},uv,.65)
  end,
  source=function(sx,sy,w,h,a,b,c,d)source(sx,sy,w,h,point(a),point(b),point(c),point(d))end})
end
return M
