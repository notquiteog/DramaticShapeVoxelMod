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
local narrowTrees={}
for _,id in ipairs{0xe,0xf,0x1e,0x1f,0x2e,0x2f,0x3e,0x3f,0xc6,0xc7,0xce,0xcf}do narrowTrees[id]=true end
local fenceMauville={
 [0x280]={},[0x281]={},[0x291]={},[0x288]={axis=2},[0x282]={axis=2},[0x28a]={axis=14},
 [0x273]={axis=2,turn='north'},[0x290]={axis=2,turn='north'},
 [0x2b2]={axis=2,stop=true},[0x2ba]={axis=2,stop=true},
}
-- Ocean barrier rocks remain low, with their own water underlay. Resolve
-- before the engine's surfable behavior because the artwork includes water.
function M.surface(primary,mid,collision)
 if primary=='general' and collision==7 and (mid==0xc5 or mid==0x18c or mid==0x194)then
  return {kind='rock',ground=0x2d,height=6}
 end
end
function M.shape(primary,secondary,mid,behavior,collision)
 if secondary=='oceanic_museum' and collision==7 and (mid==0x204 or mid==0x20c)then
  return {kind='roomWall',ground=0x201}
 end
 if secondary=='facility' then
  if mid==0x373 or mid==0x374 then
   return {kind='fence',ground=0x2f0,material=mid,height=7,
    postWidth=1.8,postSample={3,4},rails={2,6},stop=mid==0x374}
  end
  -- Native Space Center window band and Devon office wallpaper. The
  -- bottom floor/shadow rows stay horizontal; no furniture is folded up.
  if collision==7 and (mid==0x2f8 or mid==0x300 or
    mid==0x388 or mid==0x389 or mid==0x390 or mid==0x391)then
   return {kind='roomWall',ground=mid>=0x380 and 0x380 or 0x2f0}
  end
  if mid==0x2f0 or mid==0x380 then return {kind='flat',reviewedSurface=true}end
 end
 if primary=='general' then
  -- Hoenn stairs use NORMAL behavior, not FRLG's 0x2A (seaweed here).
  -- Match native tread artwork and retain blocked copies as scenery.
  if collision~=7 and ((mid==0xaf or mid==0xcf) or
    secondary=='sootopolis' and (mid==0x244 or mid==0x245) or
    secondary=='lavaridge' and mid==0x2af or
    secondary=='meteor_falls' and mid==0x202) then
   return {kind='steps',height=6}
  end
  if trees[mid]then return {kind='tree',ground=1,root=roots[mid],anchorX=16,anchorZ=8,treeRows=treeRows,treeFamily='round',treeTrim=0}end
  if narrowTrees[mid]then
   return {kind='tree',ground=1,root=true,anchorX=8,anchorZ=8,
    treeRows={{0xe},{0xc7}},treeFamily='conifer',treeTrim=0}
  end
  if secondary=='dewford' and (mid==0x239 or mid==0x243 or mid==0x23a)then
   return {kind='tree',ground=0x124,root=true,anchorX=8,anchorZ=8,
    treeRows={{0x239},{0x23a}},treeFamily='conifer',treeTrim=0}
  end
  if secondary=='mauville' and fenceMauville[mid]then
   local out={kind='fence',ground=1,material=0x288,postSample={2,3},height=7}
   for k,v in pairs(fenceMauville[mid])do out[k]=v end
   return out
  end
  if secondary=='verdanturf' and mid==0x34d then
   return {kind='fence',ground=1,material=mid,height=7,postWidth=5.8,rails={6},
    postSamples={face={4,10},cap={3,5},rail={6,5}}}
  end
  if behavior and behavior>=0x38 and behavior<=0x3b and mid<0x200 then
   return {kind='ledge',ground=(mid>=0x10e and mid<=0x127) and 0x124 or 1,
    direction=({[0x38]='east',[0x39]='west',[0x3a]='north',[0x3b]='south'})[behavior]}
  end
  -- Reviewed native cliff band: 64/65 are house facades; 6D..6F,
  -- 7F and 8F are ground. Never turn blocked decorative ground into peaks.
  if collision==7 and ((mid>=0x66 and mid<=0x6c) or
    (mid>=0x70 and mid<=0x7e) or (mid>=0x80 and mid<=0x8e) or
    (mid>=0x90 and mid<=0x9e)) then
   return {kind='cliff',height=24,ground=1,cap=0x6c,side=0x71}
  end
  if collision==7 and behavior==0xc and mid<0x200 then
   return {kind='cliff',height=24,ground=1,cap=0x6c,side=0x71}
  end
  if mid==3 then return {kind='sign',height=12,ground=1,hoenn=true}end
  if mid==4 then return {kind='flowers',height=6,ground=1}end
  if mid==0xd or mid==0x25 or mid==0x1c6 or mid==0x1c7 then return {kind='grass',height=4,ground=1}end
 end
 return {kind='flat'}
end
local function add(name,pair,rows,kind,extra)
 local r={name=name,pair=pair,rows=rows,kind=kind,primary='building',family='rse',ground=pair=='building__shop' and 0x201 or 0x202}
 for k,v in pairs(extra or{})do r[k]=v end
 M.recipes[#M.recipes+1]=r
end
-- Complete native house fixtures. Pair-local patterns keep Hoenn IDs from
-- aliasing FRLG furniture; only the object's cells receive a floor replacement.
local house='building__generic_building'
local function home(name,rows,design,ground)
 add('hoenn_home_'..name,house,rows,'designed',{design=design,ground=ground or 0x223})
end
home('tv',{{0x286,0x287},{0x28e,0x28f},{0x296,0x297}},'em_home_tv')
home('books',{{0x279,0x27a},{0x281,0x282},{0x289,0x28a}},'em_home_books')
home('fridge',{{0x278},{0x280},{0x288}},'em_home_fridge')
home('kitchen_drawers',{{0x268},{0x270}},'em_home_drawers')
home('sink',{{0x26c,0x26d},{0x274,0x275}},'em_home_sink')
home('table_yellow',{{0x248,0x249},{0x250,0x251}},'em_home_table')
home('table_plain',{{0x24a,0x24b},{0x252,0x253}},'em_home_table')
home('table_rustic',{{0x24e,0x24f},{0x256,0x257}},'em_home_table',0x229)
for _,id in ipairs{0x22b,0x22c,0x2e2}do home('chair_'..id,{{id}},id==0x22b and 'em_home_chair_left' or 'em_home_chair_right')end
home('cushion',{{0x244}},'em_home_cushion',0x229)
add('hoenn_home_plant',house,{{0x290},{0x298}},'plant',{h=22,cutout=true,ground=0x223})
-- Rustic homes have their own timber furniture and floor palette.
home('rustic_tv',{{0x2b1,0x2b2},{0x2b9,0x2ba},{0x2c1,0x2c2}},'em_home_tv',0x229)
home('rustic_books',{{0x2be,0x2bf},{0x2c6,0x2c7},{0x2ce,0x2cf}},'em_home_books',0x229)
-- Oceanic Museum's complete displays retain the native cream/blue art.
local museum='building__oceanic_museum'
local function exhibit(name,rows,design)
 add('hoenn_museum_'..name,museum,rows,'designed',{design=design,ground=0x201})
end
exhibit('wall_case',{{0x208,0x209},{0x210,0x211},{0x218,0x219}},'em_museum_wall_case')
exhibit('tall_wall_case',{{0x226,0x227},{0x22e,0x22f},{0x236,0x237}},'em_museum_wall_case')
exhibit('divider',{{0x225},{0x225},{0x22d},{0x235}},'em_museum_divider')
exhibit('cylinder',{{0x220},{0x228}},'em_museum_cylinder')
exhibit('glass_case',{{0x221},{0x229}},'em_museum_glass')
exhibit('terminal',{{0x253,0x254},{0x25b,0x25c}},'em_museum_terminal')
exhibit('ship',{{0x22a,0x230,0x231,0x22c},{0x232,0x233,0x233,0x234}},'em_museum_ship')
exhibit('parts',{{0x238,0x239,0x240,0x22c},{0x232,0x233,0x233,0x234}},'em_museum_parts')
-- Space Center and Devon use the same complete equipment drawings in two
-- native atlas pairs. Match both editions of the floor, never arbitrary IDs.
for _,primary in ipairs({'general','building'})do
 local pair=primary..'__facility'
 local function facility(name,rows,design,ground,extra)
  local r={primary=primary,design=design,ground=ground}
  for k,v in pairs(extra or {})do r[k]=v end
  add('hoenn_facility_'..primary..'_'..name,pair,rows,'designed',r)
 end
 facility('space_controls',{{0x2ba,0x2b8,0x2b9},{0x377,0x375,0x376}},'em_space_controls',0x2f0)
 facility('space_controls_pair',{{0x2b8,0x2b9},{0x376,0x376}},'em_space_controls',0x2f0)
 facility('space_controls_end',{{0x2b9},{0x376}},'em_space_controls',0x2f0)
 facility('space_computer',{{0x363,0x364},{0x36b,0x36c}},'em_office_computer',0x2f0)
 facility('space_desk',{{0x362,0x364},{0x36a,0x36c}},'em_office_desk',0x2f0)
 facility('space_plans',{{0x368,0x369},{0x370,0x371}},'em_office_plans',0x2f0)
 facility('space_stool',{{0x361}},'em_office_stool',0x2f0,{seat={height=5,hips=4,z=8}})
 facility('devon_computer',{{0x3a3,0x3a4},{0x3ab,0x3ac}},'em_office_computer',0x380)
 facility('devon_plans',{{0x3a5,0x3a6},{0x3ad,0x3ae}},'em_office_plans',0x380)
 facility('devon_stool',{{0x3a7}},'em_office_stool',0x380,{seat={height=5,hips=4,z=8}})
end
-- Littleroot's furniture is separate from the generic Hoenn house atlas.
local startHouse='building__brendans_mays_house'
local function starting(name,rows,design,extra)
 extra=extra or {};extra.design=design;extra.ground=extra.ground or 0x201
 add('hoenn_start_'..name,startHouse,rows,'designed',extra)
end
starting('fridge',{{0x230},{0x238}},'em_start_fridge')
starting('sink_hob',{{0x231,0x232},{0x239,0x23a}},'em_start_kitchen')
starting('kitchen_cabinet',{{0x233,0x234},{0x23b,0x23c}},'em_start_cabinet')
starting('living_tv',{{0x240,0x241},{0x248,0x249}},'em_start_tv')
starting('living_drawers',{{0x242},{2},{0x24a}},'em_start_dresser')
starting('bedroom_drawers',{{0x256},{2},{0x25d}},'em_start_dresser')
starting('computer_left',{{0x252,0x254},{0x25a,0x25b},{0x262,0x263}},'em_start_pc_left')
starting('computer_right',{{0x254,0x251},{0x258,0x259},{0x260,0x261}},'em_start_pc_right')
starting('console_left',{{0x265},{0x266}},'em_start_console')
starting('console_right',{{0x257},{0x267}},'em_start_console')
starting('wall_picture',{{0x250},{0x255}},'em_start_picture')
starting('wall_clock_left',{{0x287},{0x28f}},'em_start_clock')
starting('wall_clock_right',{{0x227},{0x22f}},'em_start_clock')
starting('wall_window',{{0x21e},{0x226},{0x205}},'em_start_window')
starting('bed_left',{{0x27b,0x27c,0x27d},{0x283,0x284,0x285},{0x28b,0x28c,0x28d}},'em_start_bed')
starting('bed_right',{{0x280,0x281,0x282},{0x288,0x289,0x28a},{0x290,0x291,0x292}},'em_start_bed')
starting('dining_table',{{0x21a,0x21b},{0x222,0x223},{0x22a,0x22b}},'em_start_table',
 {ground=0x2a1,groundRows={{0x2a1,0x2a1},{0x2a1,0x2a1},{0x2a9,0x2a9}}})
for _,a in ipairs{{0x219,'left'},{0x221,'left'},{0x21c,'right'},{0x224,'right'}}do
 starting('dining_chair_'..a[1],{{a[1]}},'em_home_chair_'..a[2],{ground=0x2a1})
end
local center='building__pokemon_center'
local lab='building__lab'
add('birch_books',lab,{{0x210,0x211},{0x218,0x219},{0x220,0x221}},'designed',{design='em_lab_books'})
add('birch_free_books',lab,{{0x224,0x225},{0x22c,0x22d},{0x234,0x235}},'designed',{design='em_lab_books'})
add('birch_free_books_end',lab,{{0x236,0x237},{0x22c,0x22d},{0x234,0x235}},'designed',{design='em_lab_books'})
add('birch_computer',lab,{{0x212,0x213},{0x21a,0x21b},{0x222,0x223}},'designed',{design='em_lab_computer'})
add('birch_research_desk',lab,{{0x20b,0x20c,0x20d,0x20e},{0x222,0x233,0x222,0x233}},'designed',{design='em_lab_desk'})
add('birch_starter_desk',lab,{{0x229,0x23a},{0x231,0x242}},'designed',{design='em_lab_starter'})
add('birch_machine',lab,{{0x214,0x215},{0x21c,0x21d},{0x247,0x23f}},'labMachine',{h=25,topY=0,bodyY=24,panelY=26})
add('birch_server',lab,{{0x216},{0x21e},{0x292}},'designed',{design='em_lab_server'})
add('birch_plant',lab,{{0x23c},{0x244}},'plant',{h=20,cutout=true})
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
 {family='rse',name='littleroot_player_house',pair='general__petalburg',header=0,back=2,roofEnd=54,wallBottom=79,bevel=3,roofShape='gable',roofRise=16,openings={{48,57,65,78,door=true},{15,58,32,68}},rows={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x222,0x232,0x230,0x240,0x221},{0x22a,0x23a,0x238,0x248,0x229}}},
 {family='rse',name='littleroot_rival_house',pair='general__petalburg',header=0,back=2,roofEnd=54,wallBottom=79,bevel=3,roofShape='gable',roofRise=16,openings={{15,57,32,78,door=true},{48,58,65,68}},rows={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x220,0x240,0x231,0x232,0x223},{0x228,0x248,0x239,0x23a,0x22b}}},
 {family='rse',name='birch_lab',pair='general__petalburg',header=0,back=2,roofEnd=52,wallBottom=79,bevel=2,roofVent={16,0,48,32},openings={{64,57,79,78,door=true},{16,56,30,67},{32,56,46,67},{48,56,62,67}},rows={{0x20c,0x242,0x243,0x20d,0x20d,0x20d,0x20e},{0x214,0x24a,0x24b,0x215,0x215,0x215,0x216},{0x214,0x215,0x215,0x215,0x215,0x215,0x216},{0x21e,0x20f,0x20f,0x22c,0x241,0x22d,0x21f},{0x226,0x217,0x217,0x234,0x249,0x235,0x227}}},
 {family='rse',name='oldale_house',roofShape='gable',roofRise=13,openings={{17,42,29,62,door=true},{34,41,46,54}},pair='general__petalburg',header=2,back=2,roofEnd=33,wallBottom=63,bevel=3,rows={{0x26c,0x26d,0x26d,0x26e},{0x274,0x275,0x275,0x276},{0x27c,0x27f,0x27d,0x27e},{0x284,0x287,0x28f,0x286}}},
 {family='rse',kind='mart',name='oldale_mart',pair='general__petalburg',header=2,back=2,roofEnd=42,wallBottom=63,bevel=3,rows={{0x28,0x29,0x29,0x285},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}},
 {family='rse',kind='center',name='oldale_center',roofShape='barrel',roofRise=11,pair='general__petalburg',header=2,back=2,roofEnd=40,wallBottom=63,bevel=4,rows={{0x48,0x49,0x282,0x283},{0x50,0x51,0x52,0x53},{0x58,0x59,0x5a,0x5b},{0x60,0x61,0x62,0x63}}},
}
for _,r in ipairs(V and V.data and V.data('gen3_hoenn_exteriors') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/data/gen3_hoenn_exteriors.lua'))do r.family='rse';M.exteriors[#M.exteriors+1]=r end
return M
