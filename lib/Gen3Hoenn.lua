-- Emerald's native drawings use their own metatile vocabulary. These recipes
-- were measured from the engine's composited Oldale maps; no ROM pixels ship.
local V=...
local M={recipes={},exteriors={}}
function M.active()
 local ok,GV=pcall(require,'src.core.GameVersion')
 return ok and GV.get()=='emerald'
end
local trees={}
for _,id in ipairs{0x1ce,0x1cf,0x1d4,0x1d5,0x1d6,0x1d7,0x1dc,0x1dd,0x1e4,0x1e5,0x1e6,0x1e7}do trees[id]=true end
local roots={[0x1dc]=true,[0x1e4]=true,[0x1e6]=true}
local treeRows={{0x1d4,0x1d5},{0x1dc,0x1dd}}
function M.shape(primary,secondary,mid,behavior,collision)
 if primary=='general' then
  if trees[mid]then return {kind='tree',ground=1,root=roots[mid],anchorX=16,anchorZ=8,treeRows=treeRows,treeFamily='round',treeTrim=0}end
  if mid==3 then return {kind='sign',height=12,ground=1}end
  if mid==4 then return {kind='flowers',height=10,ground=1}end
  if mid==0xd or mid==0x15 then return {kind='grass',height=4,ground=1}end
 end
 return {kind='flat'}
end
local function add(name,pair,rows,kind,extra)
 local r={name=name,pair=pair,rows=rows,kind=kind,primary='building',family='rse',ground=pair=='building__shop' and 0x201 or 0x202}
 for k,v in pairs(extra or{})do r[k]=v end
 M.recipes[#M.recipes+1]=r
end
local center='building__pokemon_center'
add('center_healer',center,{{0x222,0x223},{0x22a,0x22b}},'centerHealer',{h=13})
add('center_screen',center,{{0x24a,0x24b},{0x252,0x253}},'cabinet',{h=28,base=12,depth=1.5,frontOffset=32.2,facade={2,10,28,16}})
add('hoenn_center_front_desk',center,{{0x258,0x221,0x221,0x205,0x221,0x259}},'centerCounter',{h=7})
add('hoenn_center_left',center,{{0x248},{0x250}},'centerWing',{h=7})
add('hoenn_center_right',center,{{0x249},{0x251}},'centerWing',{h=7})
add('hoenn_center_pc',center,{{0x20c},{4},{0x224}},'designed',{design='fr_center_pc'})
add('hoenn_center_map',center,{{0x20d,0x20e},{0x215,0x216}},'cabinet',{h=27,base=11,depth=1.5,frontOffset=32.2,facade={0,13,32,17}})
add('hoenn_center_medicine',center,{{0x269,0x26a},{0x271,0x272},{0x279,0x27a}},'designed',{design='em_center_medicine'})
add('hoenn_center_terminal',center,{{0x25b}},'designed',{design='em_center_terminal'})
add('hoenn_center_table',center,{{0x23d,0x23e},{0x245,0x246}},'table',{h=7,top=26})
for _,mid in ipairs{0x226,0x234}do add('hoenn_cushion_'..mid,center,{{mid}},'centerSeat',{h=2.5})end
add('hoenn_center_plant',center,{{0x209},{0x211},{0x219}},'plant',{h=26,cutout=true})
add('hoenn_link_plant',center,{{0x25e},{0x266}},'plant',{h=24,cutout=true})
for _,a in ipairs{{0x208,0x210},{0x20b,0x213},{0x20f,0x217},{0x23f,0x247},{0x25c,0x264}}do
 add('hoenn_center_wall_'..a[2],center,{{a[1]},{a[2]}},'centerWall')
end
-- Escalator frames share a complete three-row opening. Match every frame
-- explicitly; FRLG's numeric aliases have different meanings here.
for frame=0,2 do
 add('hoenn_escalator_up_'..frame,center,{{0x280+frame*2,0x281+frame*2},{0x288+frame*2,0x289+frame*2},{0x290,0x291}},'escalator',{noGround=true})
 add('hoenn_escalator_down_'..frame,center,{{0x298,0x299},{0x2a0+frame*2,0x2a1+frame*2},{0x2a8+frame*2,0x2a9}},'escalator',{noGround=true,down=true})
end
for _,a in ipairs{{0x2d8,0x2d6},{0x2d9,0x2e0},{0x2cf,0x2d7},{0x2cd,0x2d5}}do
 add('hoenn_link_counter_'..a[1],center,{{a[1]},{a[2]}},'centerUpperCounter')
end
add('hoenn_link_pc',center,{{0x2a6},{4},{0x2b6}},'designed',{design='fr_upper_pc'})
for _,a in ipairs{{0x2db,0x2e3},{0x2da,0x2e2}}do
 add('hoenn_link_keys_'..a[2],center,{{0x24f},{a[1]},{a[2]}},'designed',{design='fr_upper_pc'})
end
add('hoenn_link_gate',center,{{0x25d}},'centerGate')
local mart='building__shop'
add('hoenn_mart_island',mart,{{0x22b,0x22c},{0x233,0x234},{0x23b,0x23c}},'designed',{design='em_mart_island'})
add('hoenn_mart_sidecase',mart,{{0x22b},{0x233},{0x23b}},'designed',{design='em_mart_sidecase'})
for _,a in ipairs{{0x230,0x231},{0x221,0x231}}do
 add('hoenn_mart_stock_'..a[1],mart,{{0x223,0x224},{0x228,0x229},a},'designed',{design='em_mart_stock'})
end
add('hoenn_mart_glass',mart,{{0x213,0x213,0x213},{0x21b,0x21b,0x21b}},'designed',{design='em_mart_glass'})
add('hoenn_mart_counter',mart,{{0x318,0x239,0x23a},{0x320,0x241,0x242}},'counter',{h=7,top=16,join=true})
add('hoenn_mart_return',mart,{{0x244},{0x208}},'designed',{design='em_mart_return'})
add('hoenn_mart_plant',mart,{{0x215},{0x21d},{0x225}},'plant',{h=26,cutout=true})
-- Whole native roof headers, walls and doors; the floor apron is excluded.
M.exteriors={
 {family='rse',name='oldale_house',pair='general__petalburg',header=2,back=2,roofEnd=33,wallBottom=63,bevel=3,rows={{0x26c,0x26d,0x26d,0x26e},{0x274,0x275,0x275,0x276},{0x27c,0x27f,0x27d,0x27e},{0x284,0x287,0x28f,0x286}}},
 {family='rse',kind='mart',name='oldale_mart',pair='general__petalburg',header=2,back=2,roofEnd=42,wallBottom=63,bevel=3,rows={{0x28,0x29,0x29,0x285},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}},
 {family='rse',kind='center',name='oldale_center',pair='general__petalburg',header=2,back=2,roofEnd=40,wallBottom=63,bevel=4,rows={{0x48,0x49,0x282,0x283},{0x50,0x51,0x52,0x53},{0x58,0x59,0x5a,0x5b},{0x60,0x61,0x62,0x63}}},
}
return M
