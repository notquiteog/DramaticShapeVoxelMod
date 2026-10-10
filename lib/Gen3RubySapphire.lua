-- Independently reviewed Ruby/Sapphire source families. Do not dispatch the
-- entire Emerald catalogue: several identical IDs draw different objects.
local M={recipes={}}
local exteriorNames={oldale_house=true,oldale_mart=true,oldale_center=true,
 petalburg_city_mart=true,petalburg_city_center=true,petalburg_city_gym=true,
 petalburg_city_wide_home=true,petalburg_city_home=true,birch_lab=true,
 littleroot_player_house=true,littleroot_rival_house=true}
local furnitureNames={center_healer=true,center_screen=true,hoenn_center_front_desk=true,
 hoenn_center_left=true,hoenn_center_right=true,hoenn_center_pc=true,
 hoenn_center_map=true,hoenn_center_medicine=true,hoenn_center_terminal=true,
 hoenn_center_table=true,hoenn_cushion_550=true,hoenn_cushion_564=true,
 hoenn_center_plant=true,hoenn_link_plant=true,hoenn_center_wall_528=true,hoenn_center_wall_535=true}
local martNames={hoenn_mart_register=true,hoenn_mart_plant=true,hoenn_mart_island=true,hoenn_mart_sidecase=true,hoenn_mart_stock_560=true,hoenn_mart_stock_545=true,hoenn_mart_glass=true}
local labNames={birch_floor_plant=true,birch_side_cupboard=true,birch_southeast_workstation=true,birch_south_book_stacks=true,birch_south_workstation=true,birch_machine=true,birch_books=true,birch_free_books=true,birch_free_books_end=true,birch_computer=true,birch_research_desk=true,birch_starter_desk=true,birch_server=true,birch_plant=true}
function M.recipeActive(r)if r.edition=='rs' then return true end;if r.family=='rse' and r.pair=='building__lab' then return labNames[r.name]==true end;if r.family=='rse' and r.pair=='building__shop' then return martNames[r.name]==true end;return r.family=='rse' and r.pair=='building__pokemon_center' and (furnitureNames[r.name]==true or (r.name or ''):match('^hoenn_escalator_up_[012]$')~=nil or (r.name or ''):match('^hoenn_escalator_down_[012]$')~=nil) end
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
for _,id in ipairs{0x1ce,0x1cf,0x1d4,0x1d5,0x1d6,0x1d7,0x1dc,0x1dd,0x1e4,0x1e5,0x1e6,0x1e7}do trees[id]=true end
local roots={[0x1dc]=true,[0x1e4]=true,[0x1e6]=true}
function M.exteriors(source)
 local out={}
 for _,r in ipairs(source)do if exteriorNames[r.name]then
  local copy={};for k,v in pairs(r)do copy[k]=v end
  copy.header=#r.rows -- require every native source cell, including facade
  if r.name=='birch_lab' then copy.ventShape='rectangular' end
  if r.name:match('^littleroot_') then copy.roofShape='littleroot_tiered' end
  out[#out+1]=copy
 end end
 return out
end
function M.shape(primary,secondary,mid,behavior,collision)
 if primary=='general' then
  if trees[mid]then return {kind='tree',ground=1,root=roots[mid],anchorX=16,anchorZ=8,
   treeRows={{0x1d4,0x1d5},{0x1dc,0x1dd}},treeFamily='round',treeTrim=0}end
  if mid==3 then return {kind='sign',height=12,ground=1,hoenn=true}end
  if mid==4 then return {kind='flowers',height=6,ground=1}end
  if mid==1 then return {kind='flat',reviewedSurface=true}end
 end
 return {kind='flat'}
end
return M
