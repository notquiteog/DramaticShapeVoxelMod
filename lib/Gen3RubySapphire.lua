-- Independently reviewed Ruby/Sapphire source families. Do not dispatch the
-- entire Emerald catalogue: several identical IDs draw different objects.
local V=...
local M={recipes={}}
local BoundaryProps=V and V.require('Gen3BoundaryProps')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/lib/Gen3BoundaryProps.lua')
local EarlyProps=V and V.require('Gen3EarlyProps')or dofile((os.getenv('DS_MOD_PATH')or'.')..'/lib/Gen3EarlyProps.lua')
local exteriorNames={slateport_shipyard=true,slateport_oceanic_museum=true,oldale_house=true,oldale_mart=true,oldale_center=true,
 battle_frontier_tower=true,lilycove_department_store=true,lilycove_museum=true,rustboro_devon_corporation=true,mossdeep_space_center=true,
 petalburg_city_mart=true,petalburg_city_center=true,petalburg_city_gym=true,
 petalburg_city_wide_home=true,petalburg_city_home=true,birch_lab=true,
 littleroot_player_house=true,littleroot_rival_house=true}
-- 2026-10-14 source batch: RS and Emerald native maps contain these complete
-- drawings with the same layout, openings and roof form; RS pixels differ
-- only in roof texture/palette (side-by-side source sheets inspected). Devon
-- and Space Center now use the distinct reviewed RS models below. Still held:
-- Frontier and Lilycove's gold residence (walkable lower-tier corners).
-- Mossdeep/Verdanturf homes use their own reviewed variants below (2026-10-15).
for _,name in ipairs({'rustboro_city_center','rustboro_city_mart','dewford_town_center','slateport_city_center',
 'slateport_city_mart','mauville_city_center','mauville_city_mart','verdanturf_town_mart','verdanturf_town_center',
 'fallarbor_town_center','fallarbor_town_mart','lavaridge_town_mart','lavaridge_town_center','fortree_city_center',
 'fortree_city_mart','lilycove_city_center','mossdeep_city_center','mossdeep_city_mart','sootopolis_city_mart',
 'sootopolis_city_center','pacifidlog_town_center','ever_grande_city_center',
 'rustboro_city_gym','dewford_town_gym','mauville_city_gym','lavaridge_town_gym','mossdeep_city_gym',
 'lilycove_north_home','lilycove_west_cliff_home','lilycove_wide_home','lilycove_east_home',
 'lilycove_southwest_home','dewford_town_hall','dewford_town_home','dewford_town_south_home','lavaridge_town_home',
 'fallarbor_town_west_home','lilycove_harbor','slateport_harbor','lilycove_contest_hall',
 'verdanturf_town_west_home','verdanturf_town_center_home',
 'mossdeep_city_west_home','mossdeep_city_north_home','mossdeep_city_northeast_home','mossdeep_city_east_home'})do exteriorNames[name]=true end
-- Exact native layouts reviewed separately from Emerald; rectangular glazing
-- and square sash frames are selected below, never Emerald's arched windows.
for _,name in ipairs({'rustboro_small_tan','rustboro_wide_tan','rustboro_east_tan','rustboro_south_tan',
 'rustboro_white_small','rustboro_white_tall','rustboro_white_thin'})do exteriorNames[name]=true end
local furnitureNames={center_healer=true,center_screen=true,hoenn_center_front_desk=true,
 hoenn_center_left=true,hoenn_center_right=true,hoenn_center_pc=true,
 hoenn_center_map=true,hoenn_center_medicine=true,hoenn_center_terminal=true,
 hoenn_center_table=true,hoenn_cushion_550=true,hoenn_cushion_564=true,
 hoenn_center_plant=true,hoenn_link_plant=true,hoenn_center_wall_528=true,hoenn_center_wall_535=true}
local martNames={hoenn_mart_clock=true,hoenn_mart_register=true,hoenn_mart_plant=true,hoenn_mart_island=true,hoenn_mart_sidecase=true,hoenn_mart_stock_560=true,hoenn_mart_stock_545=true,hoenn_mart_glass=true}
local labNames={birch_floor_plant=true,birch_side_cupboard=true,birch_southeast_workstation=true,birch_south_book_stacks=true,birch_south_workstation=true,birch_machine=true,birch_books=true,birch_free_books=true,birch_free_books_end=true,birch_computer=true,birch_research_desk=true,birch_starter_desk=true,birch_server=true,birch_plant=true}
-- These complete native drawings were checked independently against RS
-- starting homes. Do not activate unrelated Emerald rustic/regional fixtures.
for _,mid in ipairs{0x20c,0x20d}do labNames['birch_wall_note_'..mid]=true end
for _,mid in ipairs{0x241,0x239,0x249}do labNames['birch_native_seat_'..mid]=true end
local homeNames={}
for _,n in ipairs{'tv','books','fridge','kitchen_drawers','sink','table_yellow','table_plain','chair_555','chair_556','chair_738','plant','small_tv','window','picture','wide_drawers','small_books','bed','table_orange'}do homeNames['hoenn_home_'..n]=true end
local startNames={}
for _,n in ipairs{'high_window','fridge','sink_hob','kitchen_cabinet','kitchen_cabinet_right','living_tv','living_drawers','living_drawers_variant','bedroom_drawers','computer_left','computer_right','console_left','console_rs_right','wall_picture','wall_clock_left','wall_clock_right','wall_window','bed_left','bed_right','dining_table','dining_chair_537','dining_chair_545','dining_chair_540','dining_chair_548'}do startNames['hoenn_start_'..n]=true end
function M.recipeActive(r)if r.edition=='rs' then return true end;if r.family=='rse'and r.pair=='building__generic_building'then return homeNames[r.name]==true end;if r.family=='rse'and r.pair=='building__brendans_mays_house'then return startNames[r.name]==true end;if r.family=='rse' and r.pair=='building__lab' then return labNames[r.name]==true end;if r.family=='rse' and r.pair=='building__shop' then return martNames[r.name]==true end;return r.family=='rse' and r.pair=='building__pokemon_center' and (furnitureNames[r.name]==true or (r.name or ''):match('^hoenn_escalator_up_[012]$')~=nil or (r.name or ''):match('^hoenn_escalator_down_[012]$')~=nil) end
-- Ruby/Sapphire link rooms have individual booths, unlike Emerald's long desk.
for i,q in ipairs({{0x24c,0x254,0x265},{0x24d,0x255,0x25f},{0x24e,0x256,0x25f}})do
 M.recipes[#M.recipes+1]={name='rs_link_booth_'..i,edition='rs',family='rse',primary='building',pair='building__pokemon_center',kind='rsLinkBooth',ground=0x202,recessBack=15,
  rows={{0x23f,q[1],0x25c},{0x247,q[2],0x264},{0x24f,0x268,0x21e},{0x257,0x270,0x25d},{q[3],0x26b,0x202}}}
end
M.recipes[#M.recipes+1]={name='rs_link_partition_end',edition='rs',family='rse',primary='building',pair='building__pokemon_center',kind='rsLinkPartition',ground=0x202,recessBack=15,
 rows={{0x23f},{0x247},{0x24f},{0x257},{0x25f}}}
M.recipes[#M.recipes+1]={name='rs_upper_pc',edition='rs',family='rse',primary='building',pair='building__pokemon_center',kind='designed',design='fr_upper_pc',ground=0x202,rows={{0x20c},{4},{0x21c}}}
M.recipes[#M.recipes+1]={name='rs_mart_checkout',edition='rs',family='rse',primary='building',pair='building__shop',kind='martCheckout',ground=0x201,rows={{0x238,0x239,0x23a},{0x240,0x241,0x242}}}
M.recipes[#M.recipes+1]={name='birch_east_book_stacks',edition='rs',family='rse',primary='building',pair='building__lab',ground=0x202,kind='labStacks',sourceOffset=8,stackOffset=8,rows={{0x20f},{0x217},{0x21f}}}
M.recipes[#M.recipes+1]={name='birch_east_small_desk',edition='rs',family='rse',primary='building',pair='building__lab',ground=0x202,kind='labSideDesk',rows={{0x227},{0x22f}}}
local trees={}
for _,id in ipairs{0x1ce,0x1cf,0x1d4,0x1d5,0x1d6,0x1d7,0x1dc,0x1dd,0x1de,0x1df,0x1e4,0x1e5,0x1e6,0x1e7,0x1f2,0x1f3}do trees[id]=true end
local roots={[0x1dc]=true,[0x1de]=true,[0x1e4]=true,[0x1e6]=true,[0x1f3]=true}
local rsSpace={name='rs_mossdeep_space_center',family='rse',pair='general__mossdeep',kind='space_center',geometry='landmark',landmark='rs_space',header=8,wallSample={4,44},trimSample={4,33},openings={{64,112,80,128,door=true}},permissions={
 {7,7,7,7,7,7,7,7,7},
 {7,7,0,7,7,7,0,7,7},
 {7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7},
 {7,7,7,7,113,7,7,7,7},
},rows={
 {0x32b,0x337,0x32c,0x32c,0x32d,0x32c,0x32c,0x337,0x32e},
 {0x333,0x334,0x317,0x32f,0x335,0x32f,0x317,0x334,0x336},
 {0x2da,0x2db,0x2db,0x2dc,0x2dd,0x2de,0x2df,0x2df,0x2c7},
 {0x2da,0x2db,0x2db,0x2dc,0x2dd,0x2de,0x2df,0x2df,0x2c7},
 {0x2da,0x2db,0x2db,0x2dc,0x2dd,0x2de,0x2df,0x2df,0x2c7},
 {0x2da,0x2db,0x2db,0x2dc,0x2dd,0x2de,0x2df,0x2df,0x2c7},
 {0x2e2,0x2e3,0x2e3,0x2e4,0x2e5,0x2e6,0x2e7,0x2e7,0x2cf},
 {0x2ea,0x2eb,0x2eb,0x2ec,0x2ed,0x2ee,0x2ef,0x2ef,0x2d7},
}}
local rsBattle={name='rs_battle_tower',pair='general__dewford',kind='battle_tower',geometry='battle_tower',tower='rs',header=9,openings={{96,128,112,144,door=true}},permissions={
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7},
 {0,0,0,0,7,7,113,7,7,0,0,0,0},
},rows={
 {0x280,0x249,0x24a,0x24a,0x278,0x279,0x27a,0x27b,0x262,0x24a,0x24a,0x260,0x281},
 {0x280,0x249,0x24a,0x24a,0x278,0x279,0x27a,0x27b,0x262,0x24a,0x24a,0x260,0x281},
 {0x272,0x249,0x24a,0x24a,0x278,0x279,0x27a,0x27b,0x262,0x24a,0x24a,0x260,0x273},
 {0x26a,0x249,0x24a,0x24a,0x278,0x279,0x27a,0x27b,0x262,0x24a,0x24a,0x260,0x26b},
 {0x248,0x249,0x24a,0x24a,0x278,0x279,0x27a,0x27b,0x262,0x24a,0x24a,0x260,0x261},
 {0x248,0x249,0x24a,0x24a,0x278,0x279,0x27a,0x27b,0x262,0x24a,0x24a,0x260,0x261},
 {0x248,0x249,0x24a,0x24a,0x24b,0x24c,0x24d,0x24e,0x24f,0x24a,0x24a,0x260,0x261},
 {0x250,0x251,0x252,0x252,0x253,0x254,0x255,0x256,0x257,0x252,0x252,0x268,0x269},
 {0x258,0x259,0x25a,0x25a,0x25b,0x25c,0x25d,0x25e,0x25f,0x25a,0x25a,0x270,0x271},
}}
function M.exteriors(source)
 local out={}
 for _,r in ipairs(source)do if exteriorNames[r.name]then
  local copy={};for k,v in pairs(r)do copy[k]=v end
  if r.name=='mossdeep_space_center'then for k,v in pairs(rsSpace)do copy[k]=v end end
  if r.name=='battle_frontier_tower'then copy={};for k,v in pairs(rsBattle)do copy[k]=v end end
  copy.header=#copy.rows -- require every native source cell, including facade
  if r.landmark=='museum' then copy.squareWindows=true end
  if r.geometry=='devon' then
   copy.geometry='landmark';copy.landmark='rs_devon'
   copy.permissions={
 {7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7},
 {0,0,0,7,113,113,7,0,0,0},
}
  end
  if r.store=='lilycove' then copy.squareWindows=true end
  if r.geometry=='urban'then
   copy.squareWindows=true
   copy.windowInset=r.name:find('white',1,true) and {2,2,14,15} or {1,4,15,16}
   copy.blockedStart=1
   if #r.openings>0 then copy.nativeDoorMid=r.name:find('white',1,true) and 0x21f or 0x22f end
  end
  if r.name=='slateport_oceanic_museum' then copy.squareRoofLights=true end
  if r.name=='birch_lab' then copy.ventShape='rectangular' end
  -- RS Slateport harbor has rectangular windows, not Emerald's portholes.
  if r.name=='slateport_harbor' then copy.roundWindows=false end
  if r.name:match('^littleroot_') then copy.roofShape='littleroot_tiered' end
  if r.name:match('^verdanturf_town_.*home$')then
   -- RS has an unbroken green sheet roof and circular windows; Emerald's
   -- ridged roof and square panes must not leak into these native houses.
   copy.roofShape='flat_panel';copy.roofRise=0
   copy.blockedStart=1
   copy.nativeDoorMid=0x3a1
   copy.openings={}
   for _,o in ipairs(r.openings)do local q={};for k,v in pairs(o)do q[k]=v end
    if not q.door then q.round=true end;copy.openings[#copy.openings+1]=q
   end
  end
  if r.name:match('^mossdeep_city_.*home$')then
   -- Native RS glazing is a wider, dark inset beneath the pale surround.
   copy.openings={{17,42,30,62,door=true},{40,42,60,58}}
   copy.blockedStart=1
   copy.nativeDoorMid=0x2a1
   copy.bodyBack=18 -- also exclude the projected roof row when it is solid
  end
  out[#out+1]=copy
 end end

 return out
end
-- Reviewed source-equivalence table (identifiers only). Loaded lazily so the
-- module also works in standalone unit tests without the mod loader.
local parity
local function approved(primary,secondary,mid,kind)
 if not parity then
  parity=type(V)=='table' and V.data and V.data('gen3_rs_parity')
   or dofile((os.getenv('DS_MOD_PATH') or '.')..'/data/gen3_rs_parity.lua')
 end
 return parity[('%s__%s:%03X'):format(primary or '',secondary or '',mid or 0)]==kind
end
M.approved=approved
function M.surface(primary,mid,collision,secondary,emerald)
 if M.disableParity then return end -- QA candidate generation only
 local e=emerald and emerald(primary,mid,collision)
 if e and approved(primary,secondary,mid,e.kind)then return e end
end
function M.shape(primary,secondary,mid,behavior,collision,emerald)
 local own=M.ownShape(primary,secondary,mid,behavior,collision)
 if own.kind~='flat' or own.reviewedSurface or not emerald or M.disableParity then return own end
 local e=emerald(primary,secondary,mid,behavior,collision)
 if e and (e.kind~='flat' or e.reviewedSurface) and approved(primary,secondary,mid,e.kind)then return e end
 return own
end
function M.ownShape(primary,secondary,mid,behavior,collision)
 local prop=EarlyProps.shape(primary,secondary,mid,collision,'ruby');if prop then return prop end
 local boundary=BoundaryProps.hoenn(primary,secondary,mid,collision);if boundary then return boundary end
 if primary=='general' then
  -- Independently inspected RS drawing: same brown field boulder, own pixels.
  if mid==0xe0 and collision==7 then return {kind='rock',ground=1,height=14}end
  if trees[mid]then return {kind='tree',ground=1,root=roots[mid],anchorX=16,anchorZ=8,
   treeRows={{0x1d4,0x1d5},{0x1dc,0x1dd}},treeFamily='round',treeTrim=0}end
  if collision==7 and(mid==0x1f4 or mid==0x1f5)then
   return{kind='tree',ground=1,root=true,anchorX=8,anchorZ=8,treeRows={{mid}},treeFamily='round',treeTrim=0}
  end
  if mid==3 then return {kind='sign',height=12,ground=1,hoenn=true}end
  if mid==4 then return {kind='flowers',height=6,ground=1}end
  if mid==1 then return {kind='flat',reviewedSurface=true}end
 end
 return {kind='flat'}
end
return M
