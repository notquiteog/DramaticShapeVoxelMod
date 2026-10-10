-- Emerald's native drawings use their own metatile vocabulary. These recipes
-- were measured from the engine's composited Oldale maps; no ROM pixels ship.
local V=...
local M={recipes={},exteriors={}}
local function version()
 local ok,GV=pcall(require,'src.core.GameVersion')
 return ok and GV.get() or nil
end
local function rubySapphire()local v=version();return v=='ruby' or v=='sapphire'end
local function RS()return V and V.require('Gen3RubySapphire') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/lib/Gen3RubySapphire.lua')end
function M.active()
 local v=version();return v=='emerald' or v=='ruby' or v=='sapphire'
end
function M.exteriorRecipes()return rubySapphire() and RS().exteriors(M.exteriors) or M.exteriors end
function M.recipeActive(r)
 -- RS interiors opt in only after their own source/render batches.
 if rubySapphire() then return RS().recipeActive(r) end
 if r.edition=='rs' then return false end
 return M.active()==(r.family=='rse')
end
local trees={}
for _,id in ipairs{0x1ce,0x1cf,0x1d4,0x1d5,0x1d6,0x1d7,0x1dc,0x1dd,0x1e4,0x1e5,0x1e6,0x1e7}do trees[id]=true end
local roots={[0x1dc]=true,[0x1e4]=true,[0x1e6]=true}
-- Fallarbor/Route 114 brown rock bands, also used by the Fossil Maniac's
-- tunnel. Sand, rock-on-sand decorations and the blank border stay separate.
local fallarborWalls={ [0x268]=true,[0x269]=true,[0x26a]=true,
 [0x270]=true,[0x272]=true,[0x278]=true,[0x27a]=true }
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
 if rubySapphire() then return end
 if primary=='general' and collision==7 and (mid==0xc5 or mid==0x18c or mid==0x194)then
  return {kind='rock',ground=0x2d,height=6}
 end
end
-- Complete Mossdeep tree drawings. Composite cliff artwork uses the native
-- floor elevations and stone retaining faces, not an extra raised column.
function M.prepareTrees(cells)
 if rubySapphire() then return end
 local rows={{0x302,0x303,0x304},{0x30a,0x30b,0x30c},{0x312,0x313,0x314}}
 local variants={
  {rows=rows},
  {rows={{0x2f2,0x2f3,0x2f4},{0x301,0x30b,0x305},{0x312,0x313,0x314}},northCliff=true},
  {rows={{0x2fa,0x2fb,0x304},{0x30a,0x30b,0x30c},{0x312,0x313,0x314}},cornerCliff=true},
 }
 local count=0
 for _,root in pairs(cells)do
  if root.primary=='general' and root.secondary=='mossdeep' and root.mid==0x313 and root.collision==7 then
   local x,y=root.cx-1,root.cy-2
   for _,variant in ipairs(variants)do
   local complete=true
   for iy,row in ipairs(variant.rows)do for ix,mid in ipairs(row)do
    local c=cells[(x+ix-1)..':'..(y+iy-1)]
    if not c or c.pair~=root.pair or c.mid~=mid or (variant.northCliff and iy==1 and c.collision~=7) then complete=false end
   end end
   if complete then
    for iy,row in ipairs(rows)do for ix in ipairs(row)do
     local c=cells[(x+ix-1)..':'..(y+iy-1)]
     if variant.northCliff and iy==1 then
      c.shape={kind='tree',ground=0x6c,retaining=0x71,root=false}
     else
      c.shape={kind='tree',ground=1,root=c==root,anchorX=8,anchorZ=8,
       treeRows=rows,treeFamily='mossdeep',treeTrim=0}
      if variant.cornerCliff and iy==1 and ix<=2 then c.shape.retaining=0x71 end
     end
    end end
    count=count+1;break
   end
   end
  end
 end
 return count
end
function M.shape(primary,secondary,mid,behavior,collision)
 if rubySapphire() then return RS().shape(primary,secondary,mid,behavior,collision)end
 if primary=='building' and secondary=='shop' and collision==7 and (mid==0x222 or mid==0x244)then
  return {kind='roomWall',ground=0x201}
 end
 if secondary=="inside_of_truck"then return {kind="flat",reviewedSurface=true}end
 if primary=='building' and secondary=='generic_building' and collision==7
   and (mid==0x3c9 or mid==0x3d1 or mid==0x215 or mid==0x21d)then
  return {kind='roomWall',ground=mid>=0x3c9 and 0x3d9 or 0x229}
 end
 if primary=='general' and secondary=='fallarbor' and collision==7 and fallarborWalls[mid]then
  return {kind='cliff',height=32,ground=0x279,cap=0x269,side=0x270}
 end
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
home('rustic_glass_cabinet',{{0x2be,0x2bf},{0x2c6,0x2c7},{0x2ce,0x2cf}},'em_home_glass_tall',0x229)
home('rustic_bookcase',{{0x316,0x317},{0x2ae,0x2af},{0x2b6,0x2b7}},'em_home_rustic_books',0x229)
home('rustic_glass_low',{{0x306,0x307},{0x30e,0x30f}},'em_home_glass_low',0x229)
home('rustic_appliance',{{0x21e},{0x240}},'em_home_appliance',0x229)
home('table_rustic_empty',{{0x24e,0x25f},{0x256,0x257}},'em_home_table',0x229)
-- Complete two-row wallpaper/window drawings. The pane sits behind a real
-- frame; the native circle and crossbars are preserved rather than replaced.
home('round_window',{{0x217},{0x21f}},'em_home_round_window',0x229)
home('wallpaper',{{0x215},{0x21d}},'em_home_wallpaper',0x229)
home('tunnel_entrance',{{0x2ed,0x2ee,0x2ef},{0x2f5,0x2f6,0x2f7}},'em_home_tunnel_entrance',0x229)
-- Sootopolis's pale stone homes use their own tiled floor and furnishings.
home('sootopolis_table',{{0x3f3,0x3f4},{0x3fb,0x3fc}},'em_home_table',0x3fe)
home('sootopolis_chair_left',{{0x2dd}},'em_home_chair_left',0x3fe)
home('sootopolis_chair_right',{{0x2de}},'em_home_chair_right',0x3fe)
home('sootopolis_drawers',{{0x2cd},{0x2d5}},'em_fortree_drawers',0x3fe)
home('sootopolis_fridge',{{0x230},{0x002},{0x2b5}},'em_home_fridge',0x3fe)
home('sootopolis_books',{{0x2c8,0x2c9},{0x276,0x277},{0x2d8,0x2d9}},'em_home_rustic_books',0x3fe)
home('sootopolis_sofa',{{0x292,0x293},{0x29a,0x29b}},'em_home_sofa',0x3fe)
home('sootopolis_sink',{{0x2bb,0x2bc},{0x2c3,0x2c4}},'em_home_sink',0x3fe)
home('sootopolis_low_appliance',{{0x2bd},{0x2c5}},'em_home_appliance',0x3fe)
-- Rustboro has the same furniture functions but different source drawings.
home('rustboro_sofa',{{0x354,0x355},{0x35c,0x35d}},'em_home_sofa',0x32c)
home('rustboro_sink',{{0x356,0x357},{0x35e,0x35f}},'em_home_sink',0x32c)
home('rustboro_appliance',{{0x21e},{0x336}},'em_home_appliance',0x32c)
home('rustboro_table',{{0x37e,0x37f,0x38e},{0x386,0x387,0x38f}},'em_home_wide_table',0x32c)
home('rustboro_small_table',{{0x36a,0x36b},{0x372,0x373}},'em_home_table',0x32c)
home('rustboro_chair_left',{{0x344}},'em_home_chair_left',0x32c)
home('rustboro_chair_right',{{0x345}},'em_home_chair_right',0x32c)
home('safari_table',{{0x2e8,0x2ea},{0x2f0,0x2f2}},'em_home_table',0x223)
-- Fortree rooms use a separate timber palette and a real central trunk.
-- Match the whole support so its repeated artwork is not four small trees.
home('fortree_support',{{0x3be,0x3bf},{0x3be,0x3bf},{0x3be,0x3bf},{0x3c6,0x3c7}},'em_fortree_support',0x3d9)
home('fortree_drawers',{{0x3e0},{0x3e8}},'em_fortree_drawers',0x3d9)
home('fortree_cabinet',{{0x3e3,0x3e4},{0x3eb,0x3ec}},'em_fortree_cabinet',0x3d9)
home('fortree_appliance',{{0x21e},{0x3d3}},'em_home_appliance',0x3d9)
home('fortree_counter_left',{{0x3ed,0x3ee,0x3cf},{0x3f5,0x3f6,0x3d7}},'em_fortree_counter',0x3d9)
home('fortree_counter_right',{{0x3ce,0x3ee,0x3ef},{0x3d6,0x3f6,0x3f7}},'em_fortree_counter',0x3d9)
-- Oceanic Museum's complete displays retain the native cream/blue art.
-- Lilycove's five upstairs gallery partitions: complete native drawing,
-- including its projected cap and floor shadow. Only the base row is solid.
add('hoenn_lilycove_gallery','building__lilycove_museum',{
 {0x264,0x265,0x266,0x267},{0x286,0x26e,0x26e,0x26f},
 {0x28e,0x258,0x259,0x277},{0x27c,0x27d,0x27e,0x27f}},'designed',{
 design='em_lilycove_gallery',ground=0x268,blockedRows={[3]=true},
 groundRows={{0x268,0x269,0x268,0x269},{0x269,0x268,0x269,0x268},
 {0x268,0x269,0x268,0x269},{0x269,0x268,0x269,0x268}}})
-- Native stepped rear wall: two-row middle, deeper wings and corner joins.
for _,spec in ipairs{
 {name='rear',rows={{0x281},{0x289}}},
 {name='wing',rows={{0x279},{0x281},{0x289}}},
 {name='left_corner',rows={{0x27a},{0x282},{0x28a}}},
 {name='right_corner',rows={{0x278},{0x280},{0x288}}},
}do
 add('hoenn_lilycove_upper_'..spec.name,'building__lilycove_museum',spec.rows,'designed',{
  design='em_lilycove_upper_wall',ground=0x270,blockedRows={[1]=true,[2]=true,[3]=#spec.rows==3},
  corner=spec.name:match('corner')~=nil})
end
for _,pair in ipairs{{0x284,0x28c},{0x285,0x28d}}do
 add('hoenn_lilycove_statue_'..pair[1],'building__lilycove_museum',{{pair[1]},{pair[2]}},'carvedStatue',{
  ground=0x270,groundRows={{0x289},{0x270}},blockedRows={[2]=true}})
end
for _,rows in ipairs{
 {{0x20b},{0x213}},{{0x218,0x219},{0x220,0x221}},{{0x21a,0x21b},{0x222,0x223}},
 {{0x21c},{0x224}},{{0x21d},{0x225}},{{0x21e,0x21f},{0x226,0x227}},
 {{0x22d,0x22e},{0x235,0x236}},{{0x22f},{0x237}},
}do
 add('hoenn_lilycove_picture_wall_'..rows[1][1],'building__lilycove_museum',rows,'designed',{
  design='em_lilycove_picture_wall',ground=0x203,blockedRows={[2]=true},
  wallSample={0,({[0x21c]=16,[0x21d]=16,[0x22f]=24})[rows[1][1]]or 2}})
end
for _,spec in ipairs{
 {name='north_return',rows={{0x211},{0x211},{0x204},{0x20c},{0x214}},collision={{7},{7},{0x90},{7},{7}},foot=0},
 {name='partition_return',rows={{0x212},{0x28b},{0x204},{0x20c},{0x214}},collision={{0},{7},{0x90},{7},{7}},foot=16},
}do
 add('hoenn_lilycove_'..spec.name,'building__lilycove_museum',spec.rows,'designed',{
  design='em_lilycove_wall_return',ground=0x203,collisionRows=spec.collision,foot=spec.foot})
end
add('hoenn_lilycove_floor_statue','building__lilycove_museum',{{0x22b},{0x233}},'carvedStatue',{
 ground=0x202,backgroundMids={0x202,0x203},blockedRows={[2]=true}})
add('hoenn_lilycove_small_sculpture','building__lilycove_museum',{{0x22c}},'designed',{
 design='em_lilycove_ball_sculpture',ground=0x202,blockedRows={[1]=true}})
-- Complete display and hollow counter preserve their native walking cells.
add('hoenn_lilycove_stone_display','building__lilycove_museum',{
 {0x23a,0x23b,0x23b,0x23b,0x23c},
 {0x242,0x228,0x229,0x22a,0x244},
 {0x24a,0x230,0x231,0x232,0x24c},
 {0x252,0x253,0x253,0x253,0x254}},'designed',{
 design='em_lilycove_stone_display',ground=0x202,
 collisionRows={{0,0,0,0,0},{7,7,7,7,7},{7,7,7,7,7},{7,0x90,0x90,0x90,7}}})
add('hoenn_lilycove_counter','building__lilycove_museum',{
 {0x23a,0x23b,0x23b,0x23b,0x23b,0x23c},
 {0x248,0x253,0x241,0x253,0x240,0x249},
 {0x210,0x24d,0x23f,0x23f,0x23f,0x210},
 {0x238,0x234,0x23b,0x23b,0x23b,0x239},
 {0x252,0x253,0x253,0x253,0x253,0x254}},'designed',{
 design='em_lilycove_counter',ground=0x202,
 collisionRows={{0,0,0,0,0,0},{7,0x90,0x90,0x90,0x90,7},
 {0x90,0,0,0,0,0x90},{0x90,0,0,0,0,0x90},{7,0x90,0x90,0x90,0x90,7}}})
for _,pair in ipairs{{0x20e,0x216},{0x20f,0x217}}do
 add('hoenn_mauville_wall_machine_'..pair[1],'building__mauville_game_corner',{{pair[1]},{pair[2]}},'designed',{
  design='em_game_corner_machine',ground=0x202,blockedRows={[1]=true,[2]=true}})
end
for _,mid in ipairs{0x22e,0x236}do
 add('hoenn_mauville_bin_'..mid,'building__mauville_game_corner',{{mid}},'designed',{
  design='em_game_corner_bin',ground=0x202,blockedRows={[1]=true}})
end
add('hoenn_mauville_slot_bank','building__mauville_game_corner',{
 {0x224,0x225},{0x22c,0x22d},{0x22c,0x22d},{0x22c,0x22d},{0x234,0x235}},'designed',{
 design='em_slot_bank',ground=0x202,
 collisionRows={{0,0},{7,7},{7,7},{7,7},{7,7}}})
add('hoenn_mauville_roulette','building__mauville_game_corner',{
 {0x222,0x223},{0x22a,0x22b},{0x232,0x233}},'designed',{
 design='em_roulette_table',ground=0x202,blockedRows={[1]=true,[2]=true,[3]=true}})
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
-- The moving truck uses cargo art, not the general atlas's house objects.
add('hoenn_truck_cargo','general__inside_of_truck',{
 {0x201,0x202,0x203,0x204,0x205},{0x209,0x20a,0x20b,0x20c,0x208},
 {0x211,0x212,0x213,0x214,0x210},{0x219,0x21a,0x21b,0x21c,0x218},
 {0x221,0x222,0x223,0x224,0x220}},'designed',{
 primary='general',design='em_truck_cargo',ground=0x214,
 groundRows={{0x214,0x214,0x214,0x214,0x214},{0x214,0x214,0x214,0x214,0x208},
 {0x214,0x214,0x214,0x214,0x210},{0x214,0x214,0x214,0x214,0x218},
 {0x214,0x214,0x214,0x214,0x214}}})
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
starting('living_drawers_variant',{{0x242},{3},{0x24a}},'em_start_dresser')
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
 starting('dining_chair_'..a[1],{{a[1]}},'em_start_seat_pad',{ground=0x2a1})
end
local center='building__pokemon_center'
local lab='building__lab'
add('birch_south_book_stacks',lab,{{0x248},{0x248}},'labStacks')
add('birch_side_cupboard',lab,{{0x23a},{0x242}},'labSideCabinet')
add('birch_southeast_workstation',lab,{{0x23b},{0x243},{0x24b}},'labWorkstation',{faceLeft=true})
add('birch_south_workstation',lab,{{0x230},{0x238},{0x240}},'labWorkstation')
add('birch_books',lab,{{0x210,0x211},{0x218,0x219},{0x220,0x221}},'designed',{design='em_lab_books'})
add('birch_free_books',lab,{{0x224,0x225},{0x22c,0x22d},{0x234,0x235}},'designed',{design='em_lab_books'})
add('birch_free_books_end',lab,{{0x236,0x237},{0x22c,0x22d},{0x234,0x235}},'designed',{design='em_lab_books'})
add('birch_computer',lab,{{0x212,0x213},{0x21a,0x21b},{0x222,0x223}},'designed',{design='em_lab_computer'})
add('birch_research_desk',lab,{{0x20b,0x20c,0x20d,0x20e},{0x222,0x233,0x222,0x233}},'designed',{design='em_lab_desk'})
add('birch_starter_desk',lab,{{0x229,0x23a},{0x231,0x242}},'designed',{design='em_lab_starter'})
add('birch_machine',lab,{{0x214,0x215},{0x21c,0x21d},{0x247,0x23f}},'labMachine',{h=25,topY=0,bodyY=24,panelY=26,depthOffset=-16})
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
for _,mid in ipairs{0x226,0x234}do add('hoenn_cushion_'..mid,center,{{mid}},'centerSeat',{h=1.25,walkablePad=true})end
add('hoenn_center_plant',center,{{0x209},{0x211},{0x219}},'plant',{h=26,cutout=true,depthOffset=-16})
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
add('hoenn_mart_counter',mart,{{0x318,0x239,0x23a},{0x320,0x241,0x242}},'martCheckout',{h=7})
-- 244 is the clock's lower wallpaper row; 208 is walkable floor.
-- Leave both to the native wall/floor renderer, never invent a counter.
add('hoenn_mart_register',mart,{{0x22a},{0x232}},'martRegister')
add('hoenn_mart_plant',mart,{{0x215},{0x21d},{0x225}},'plant',{h=26,cutout=true,depthOffset=-16})
-- Whole native roof headers, walls and doors; the floor apron is excluded.
M.exteriors={
 {family='rse',name='littleroot_player_house',pair='general__petalburg',header=0,back=2,roofEnd=54,wallBottom=79,bevel=3,roofShape='littleroot_tiered',roofRise=16,openings={{48,57,65,78,door=true},{15,58,32,68}},rows={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x222,0x232,0x230,0x240,0x221},{0x22a,0x23a,0x238,0x248,0x229}}},
 {family='rse',name='littleroot_rival_house',pair='general__petalburg',header=0,back=2,roofEnd=54,wallBottom=79,bevel=3,roofShape='littleroot_tiered',roofRise=16,openings={{15,57,32,78,door=true},{48,58,65,68}},rows={{0x208,0x209,0x209,0x209,0x20a},{0x210,0x211,0x211,0x211,0x212},{0x218,0x219,0x219,0x219,0x21a},{0x220,0x240,0x231,0x232,0x223},{0x228,0x248,0x239,0x23a,0x22b}}},
 {family='rse',name='birch_lab',pair='general__petalburg',header=0,back=2,roofEnd=52,wallBottom=79,bevel=2,roofVent={16,0,48,32},openings={{64,57,79,78,door=true},{16,56,30,67},{32,56,46,67},{48,56,62,67}},rows={{0x20c,0x242,0x243,0x20d,0x20d,0x20d,0x20e},{0x214,0x24a,0x24b,0x215,0x215,0x215,0x216},{0x214,0x215,0x215,0x215,0x215,0x215,0x216},{0x21e,0x20f,0x20f,0x22c,0x241,0x22d,0x21f},{0x226,0x217,0x217,0x234,0x249,0x235,0x227}}},
 {family='rse',name='oldale_house',roofShape='gable',roofRise=13,openings={{17,42,29,62,door=true},{34,41,46,54}},pair='general__petalburg',header=2,back=2,roofEnd=33,wallBottom=63,bevel=3,rows={{0x26c,0x26d,0x26d,0x26e},{0x274,0x275,0x275,0x276},{0x27c,0x27f,0x27d,0x27e},{0x284,0x287,0x28f,0x286}}},
 {family='rse',kind='mart',name='oldale_mart',martRoof=true,bodyBack=16,wallSample={8,55},trimSample={7,41},pair='general__petalburg',header=2,back=2,roofEnd=42,wallBottom=63,bevel=3,rows={{0x28,0x29,0x29,0x285},{0x30,0x31,0x32,0x33},{0x38,0x39,0x3a,0x3b},{0x60,0x41,0x42,0x43}}},
 {family='rse',kind='center',name='oldale_center',centerRoof=true,bodyBack=16,wallSample={8,55},trimSample={7,41},roofShape='barrel',roofRise=11,pair='general__petalburg',header=2,back=2,roofEnd=40,wallBottom=63,bevel=4,rows={{0x48,0x49,0x282,0x283},{0x50,0x51,0x52,0x53},{0x58,0x59,0x5a,0x5b},{0x60,0x61,0x62,0x63}}},
}
for _,r in ipairs(V and V.data and V.data('gen3_hoenn_exteriors') or dofile((os.getenv('DS_MOD_PATH') or '.')..'/data/gen3_hoenn_exteriors.lua'))do r.family='rse';M.exteriors[#M.exteriors+1]=r end
return M
