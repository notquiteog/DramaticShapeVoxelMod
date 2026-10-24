-- Reviewed source furniture only; extraction, native walls and interactions
-- remain owned by the existing interior adapters.
local V=...
local Models=V.require('SceneryModels')
local PCFrames=V.require('Gen3PublicPCFrames')
local M={id='oras_center_pc',tvId='oras_home_tv',bedId='oras_comfortable_bed'}
local registered={}
local dataFiles={
 oras_trick_house_floor_cushion='ImportedTrickCushionData',oras_center_pc='ImportedInteriorData',oras_home_tv='ImportedInteriorTVData',oras_comfortable_bed='ImportedInteriorBedData'}
dataFiles.oras_littleroot_dining_table='ImportedHomeFurnitureData'
dataFiles.oras_littleroot_fridge='ImportedHomeFurnitureData'
dataFiles.oras_oldale_checked_table='ImportedOldaleFurnitureData'
dataFiles.oras_oldale_neighbor_table='ImportedOldaleFurnitureData'
dataFiles.oras_oldale_refrigerator='ImportedOldaleFridgeData'
dataFiles.bdsp_galactic_server='ImportedInstitutionServerData'
dataFiles.oras_oldale_china_cupboard='ImportedOldaleCupboardData'
dataFiles.oras_oldale_kitchen_sink='ImportedOldaleSinkData'
dataFiles.oras_oldale_backed_chair='ImportedOldaleChairData'
dataFiles.oras_center_glass_table='ImportedCenterTableData'
dataFiles.oras_center_healer='ImportedCenterHealerData'
dataFiles.oras_pyre_memorial='ImportedPyreMemorialData'
dataFiles.oras_flower_bookcase='ImportedFlowerBookcaseData'
dataFiles.oras_birch_bookcase='ImportedBirchBookcaseData'
dataFiles.oras_birch_freestanding_case='ImportedBirchFreecaseData'
-- Complete public-PC and genuine TV drawings include the wall above and
-- walkable perspective apron. TV identity additionally requires native 0x86
-- behavior; similarly named cupboards, home desks and labs are not substitutes.
local families={
 center_healer={byPair={
  ['building__pokemon_center']={pair='building__pokemon_center',family='rse',kind='centerHealer',rows={{0x222,0x223},{0x22a,0x22b}},collisionRows={{7,7},{7,7}},
   model='oras_center_healer',fitWidth=32,fitDepth=32,fitHeight=28,zRows=0,groundInset=.025},
  network={pair='network',kind='centerHealer',rows={{0x2aa,0x2ab},{0x2b2,0x2b3}},collisionRows={{7,7},{7,7}},
   model='oras_center_healer',fitWidth=32,fitDepth=32,fitHeight=28,zRows=0,groundInset=.025}}},
 hoenn_center_table={pair='building__pokemon_center',family='rse',kind='centerTable',rows={{0x23d,0x23e},{0x245,0x246}},collisionRows={{7,7},{7,7}},
  model='oras_center_glass_table',fitWidth=32,fitDepth=32,fitHeight=16,zRows=0,groundInset=.025},
 center_table={pair='network',kind='centerTable',rows={{0x29c,0x29d},{0x2a4,0x2a5}},collisionRows={{7,7},{7,7}},
  model='oras_center_glass_table',fitWidth=32,fitDepth=32,fitHeight=16,zRows=0,groundInset=.025},
 hoenn_home_chair_555={pair='building__generic_building',family='rse',design='em_start_seat_pad',rows={{0x22b}},collisionRows={{0}},
  model='oras_oldale_backed_chair',fitWidth=16,fitDepth=16,fitHeight=32,zRows=0,rotation=1,groundInset=.025},
 hoenn_home_chair_556={pair='building__generic_building',family='rse',design='em_start_seat_pad',rows={{0x22c}},collisionRows={{0}},
  model='oras_oldale_backed_chair',fitWidth=16,fitDepth=16,fitHeight=32,zRows=0,rotation=3,groundInset=.025},
 hoenn_home_chair_738={pair='building__generic_building',family='rse',design='em_start_seat_pad',rows={{0x2e2}},collisionRows={{0}},
  model='oras_oldale_backed_chair',fitWidth=16,fitDepth=16,fitHeight=32,zRows=0,rotation=3,groundInset=.025},
 hoenn_home_cushion={pair='building__generic_building',family='rse',design='em_home_cushion',rows={{0x244}},collisionRows={{0}},
  model='oras_trick_house_floor_cushion',fitWidth=16,fitDepth=16,fitHeight=4,zRows=0,groundInset=.025},
 birch_free_books={pair='building__lab',family='rse',design='em_lab_free_books',rows={{0x224,0x225},{0x22c,0x22d},{0x234,0x235}},collisionRows={{0,0},{7,7},{7,7}},
  model='oras_birch_freestanding_case',fitWidth=32,fitDepth=32,fitHeight=32,groundInset=.025},
 birch_free_books_end={pair='building__lab',family='rse',design='em_lab_free_books',rows={{0x236,0x237},{0x22c,0x22d},{0x234,0x235}},collisionRows={{0,0},{7,7},{7,7}},
  model='oras_birch_freestanding_case',fitWidth=32,fitDepth=32,fitHeight=32,groundInset=.025},
 birch_books={pair='building__lab',family='rse',design='em_lab_books',rows={{0x210,0x211},{0x218,0x219},{0x220,0x221}},collisionRows={{7,7},{7,7},{7,0}},
  model='oras_birch_bookcase',fitWidth=32,fitDepth=16,fitHeight=32,groundInset=.025},
 hoenn_home_small_books={pair='building__generic_building',family='rse',design='em_home_books',rows={{0x26e,0x26f},{0x276,0x277},{0x27e,0x27f}},collisionRows={{7,7},{7,7},{0,0}},
  model='oras_flower_bookcase',fitWidth=32,fitDepth=16,fitHeight=32,rotation=3,groundInset=.025},
 hoenn_home_books={pair='building__generic_building',family='rse',design='em_home_books',rows={{0x279,0x27a},{0x281,0x282},{0x289,0x28a}},collisionRows={{7,7},{7,7},{0,0}},
  model='oras_flower_bookcase',fitWidth=32,fitDepth=16,fitHeight=32,rotation=3,groundInset=.025},
 hoenn_pyre_memorial={pair='general__facility',primary='general',family='rse',mapPattern='_MT_PYRE_[1-6]F$',design='fr_tower_grave',rows={{0x2ee}},collisionRows={{7}},
  model='oras_pyre_memorial',fitWidth=16,fitDepth=16,fitHeight=17,zRows=0,groundInset=.025},
 rs_pyre_memorial={pair='general__facility',primary='general',family='rse',mapPattern='_MT_PYRE_[1-6]F$',design='fr_tower_grave',rows={{0x2ee}},collisionRows={{7}},
  model='oras_pyre_memorial',fitWidth=16,fitDepth=16,fitHeight=17,zRows=0,groundInset=.025},
 hoenn_pyre_memorial_wall_shadow={pair='general__facility',primary='general',family='rse',mapPattern='_MT_PYRE_[1-6]F$',design='fr_tower_grave',rows={{0x326}},collisionRows={{7}},
  model='oras_pyre_memorial',fitWidth=16,fitDepth=16,fitHeight=17,zRows=0,groundInset=.025},
 rs_pyre_memorial_wall_shadow={pair='general__facility',primary='general',family='rse',mapPattern='_MT_PYRE_[1-6]F$',design='fr_tower_grave',rows={{0x326}},collisionRows={{7}},
  model='oras_pyre_memorial',fitWidth=16,fitDepth=16,fitHeight=17,zRows=0,groundInset=.025},
 tower_grave_657={pair='building__rom_082d4efc',design='fr_tower_grave',rows={{0x291}},collisionRows={{7}},
  model='oras_pyre_memorial',fitWidth=16,fitDepth=16,fitHeight=17,zRows=0,groundInset=.025},
 hoenn_center_pc={pair='building__pokemon_center',family='rse',design='fr_center_pc',rows={{0x20c},{4},{0x224}},groundInset=.025},
 center_terminal={pair='network',design='fr_center_pc',rows={{0x285},{0x62},{0x295}},groundInset=.025},
 hoenn_home_small_tv={pair='building__generic_building',family='rse',design='em_home_small_tv',rows={{0x230},{0x21e},{0x238}},model='oras_home_tv',cabinet=6,groundInset=.025},
 living_television={pair='player_house',design='fr_living_tv',rows={{0x2d},{0x35},{0x3d}},model='oras_home_tv',cabinet=6,note=true,groundInset=.025},
 hoenn_home_bed={pair='building__generic_building',family='rse',design='em_home_bed',rows={{0x25a,0x25b},{0x262,0x263}},model='oras_comfortable_bed',blocked=true,fitWidth=32,fitDepth=32,fitHeight=18,zRows=0,groundInset=.025},
 neighbor_living_television={pair='house',design='fr_living_tv',rows={{0x2d},{0x35},{0x3d}},model='oras_home_tv',cabinet=6,note=true,groundInset=.025},
 hoenn_start_dining_table={pair='building__brendans_mays_house',family='rse',design='em_start_table',
  rows={{0x21a,0x21b},{0x222,0x223},{0x22a,0x22b}},collisionRows={{7,7},{7,7},{0,0}},
  model='oras_littleroot_dining_table',fitWidth=32,fitDepth=32,fitHeight=32,zRows=0,groundInset=.025},
 hoenn_start_fridge={pair='building__brendans_mays_house',family='rse',design='em_start_fridge',
  rows={{0x230},{0x238}},collisionRows={{7},{7}},
  model='oras_littleroot_fridge',fitWidth=16,fitDepth=16,fitHeight=32,groundInset=.025},
 hoenn_home_table_yellow={pair='building__generic_building',family='rse',design='em_home_table',
  rows={{0x248,0x249},{0x250,0x251}},collisionRows={{7,7},{7,7}},
  model='oras_oldale_checked_table',fitWidth=32,fitDepth=32,fitHeight=32,zRows=0,groundInset=.025},
 birch_server={pair='building__lab',family='rse',design='em_lab_server',rows={{0x216},{0x21e},{0x292}},collisionRows={{0},{7},{0}},model='bdsp_galactic_server',fitHeight=32,groundInset=.025},
 lab_server={pair='oak_lab',design='fr_lab_server',rows={{0x29d},{0x2ad},{0x2b5}},collisionRows={{7},{7},{0}},model='bdsp_galactic_server',fitHeight=32,groundInset=.025},
 silph_server={pair='building__rom_082d4ecc',design='fr_native_rack',rows={{0x37d},{0x385},{0x37e}},collisionRows={{7},{7},{0}},model='bdsp_galactic_server',fitHeight=32,groundInset=.025},
 powerplant_server={pair='building__rom_082d4e9c',design='fr_native_rack',rows={{0x308},{0x310},{0x318}},collisionRows={{7},{7},{43}},model='bdsp_galactic_server',fitHeight=32,groundInset=.025},
 mansion_server={pair='building__rom_082d4f2c',design='fr_native_rack',rows={{0x317},{0x31f},{0x36e}},collisionRows={{7},{7},{43}},model='bdsp_galactic_server',fitHeight=32,groundInset=.025},
 hoenn_home_fridge={pair='building__generic_building',family='rse',design='em_home_fridge',
  rows={{0x278},{0x280},{0x288}},collisionRows={{7},{7},{0}},
  model='oras_oldale_refrigerator',fitWidth=16,fitDepth=16,fitHeight=32,rotation=1,groundInset=.025},
 hoenn_home_tv={pair='building__generic_building',family='rse',design='em_home_tv',
  rows={{0x286,0x287},{0x28e,0x28f},{0x296,0x297}},collisionRows={{7,7},{7,7},{0,0}},
  model='oras_oldale_china_cupboard',fitWidth=32,fitDepth=16,fitHeight=32,groundInset=.025},
 hoenn_home_sink={pair='building__generic_building',family='rse',design='em_home_sink',
  rows={{0x26c,0x26d},{0x274,0x275}},collisionRows={{7,7},{0,0}},
  model='oras_oldale_kitchen_sink',fitWidth=32,fitDepth=16,fitHeight=32,zRows=0,rotation=1,groundInset=.025},
 hoenn_home_table_plain={pair='building__generic_building',family='rse',design='em_home_table',
  rows={{0x24a,0x24b},{0x252,0x253}},collisionRows={{7,7},{7,7}},
  model='oras_oldale_neighbor_table',fitWidth=32,fitDepth=32,fitHeight=32,zRows=0,groundInset=.025},
}
local function familyFor(p)
 local f=p and p.recipe and families[p.recipe.name]
 return f and(f.byPair and f.byPair[p.pair]or not f.byPair and f)or nil
end
local function placement(p,f)
 return{model=f.model or M.id,x=p.cx*16,y=(p.groundHeight or 0)+(f.cabinet or 0),z=(p.cy+(f.zRows or 1))*16,
  fit={width=f.fitWidth or 16,depth=f.fitDepth or 16,height=f.fitHeight or(f.model and 17 or 24),padding=.25,groundInset=f.groundInset,rotation=f.rotation},source=p}
end
function M.register(id)
 id=id or M.id
 if registered[id]and Models.info(id)then return true end
 local file=dataFiles[id];if not file then
  if type(id)=='string'and id:match('^oras_truck_')then
   local truck=V.require('Gen3ImportedTruckRoom')
   if truck.isModel(id)then return truck.register(id)end
  end
  return nil,'unknown imported interior'
 end
 local ok,data=pcall(V.require,file)
 if not ok or type(data)~='table'or not data[id]then return nil,'imported interior source unavailable'end
 local result,err=Models.register(id,data[id],{read=function(path)return V.mod:read(path)end})
 if not result then return nil,err end
 registered[id]=true;return true
end
function M.eligible(p,cells)
 local r=p and p.recipe;local f=familyFor(p)
 if not f or r.design~=f.design or r.family~=f.family or p.pair~=f.pair
  or f.kind and r.kind~=f.kind
  or p.w~=#f.rows[1]*16 or p.d~=#f.rows*16 or p.stageHidden then return false end
 local base
 for row,expectedRow in ipairs(f.rows)do
  if not r.rows[row]or #r.rows[row]~=#expectedRow then return false end
  for col,expected in ipairs(expectedRow)do
   if r.rows[row][col]~=expected then return false end
   local c=cells[(p.cx+col-1)..':'..(p.cy+row-1)]
   local collision
   if c then
    if f.collisionRows then collision=c.collision==f.collisionRows[row][col]
    elseif f.blocked then collision=c.collision==7
    elseif row==2 then collision=c.collision==7 or f.model==nil and c.collision==0x93
    else collision=c.collision==(row==1 and 7 or 0)end
   end
   if not c or c.prop~=p or c.pair~=f.pair or c.primary~=(f.primary or'building')
    or not PCFrames.matches(r,c.mid,expected)or not collision
    or f.model=='oras_home_tv'and row==2 and c.behavior~=0x86
    or c.boundary or c.stageHidden or c.stairs or c.civic then return false end
   if f.mapPattern then local id=c.mapId or c.region and c.region.mapId;if type(id)~='string'or not id:match(f.mapPattern)then return false end end
   if base==nil then base=c.base or 0 elseif math.abs((c.base or 0)-base)>.001 then return false end
  end
 end
 if math.abs((base or 0)-(p.groundHeight or 0))>.001 then return false end
 return true
end
function M.placements(cells)
 local list,seen={},{}
 for _,c in pairs(cells)do local p=c.prop
  if p and not seen[p]then
   seen[p]=true
   if p.recipe and p.recipe.name=='hoenn_truck_cargo'then
    for _,item in ipairs(V.require('Gen3ImportedTruckRoom').placements(p,cells))do list[#list+1]=item end
   elseif M.eligible(p,cells)then
    list[#list+1]=placement(p,familyFor(p))
   end
  end
 end
 table.sort(list,function(a,b)return a.z==b.z and a.x<b.x or a.z<b.z end)
 return list
end
-- The native engine owns timing/count/palette. Only successful source uploads
-- expose this visual surface; a failed upload keeps the ordinary native tray.
function M.healingSurface(p)
 if not p or p.importedInterior~='oras_center_healer'then return end
 local f=familyFor(p);if not f or f.model~='oras_center_healer'then return end
 local item=placement(p,f);local fit=Models.fit(item.model,item.fit);if not fit then return end
 local function world(name)
  local a=fit.anchors[name];if not a then return end
  return{item.x+a[1],item.y+a[2]+.18,item.z+a[3]}
 end
 local vertices={}
 for _,name in ipairs{'tray_back_left','tray_back_right','tray_front_right','tray_front_left'}do
  local a=world(name);if not a then return end;vertices[#vertices+1]=a
 end
 local centers={};for i=1,6 do local a=world('ball_'..i);if not a then return end;centers[i]=a end
 local edge=world('ball_radius');if not edge then return end
 local radius=math.sqrt((edge[1]-centers[1][1])^2+(edge[2]-centers[1][2])^2+(edge[3]-centers[1][3])^2)
 return{vertices=vertices,balls={centers=centers,radius=radius}}
end
function M.build(cells,newMesh,parts,capabilities)
 local list=M.placements(cells)
 -- Animated families require a renderer that uses their fitted surface. Older
 -- consumers keep the complete native healer rather than misplaced effects.
 if not(capabilities and capabilities.healingSurface)then
  local ready={};for _,p in ipairs(list)do if p.model~='oras_center_healer'then ready[#ready+1]=p end end;list=ready
 end
 if #list==0 then return parts,nil,0 end
 for _,p in ipairs(list)do local ok,err=M.register(p.model);if not ok then return nil,err,0 end end
 local result,why=Models.buildBatches(list,newMesh,{parts=parts})
 -- Mark only after every texture and mesh uploads. A failed source load keeps
 -- the complete native furniture, including its existing wall/ground handling.
 if result then for _,p in ipairs(list)do p.source.importedInterior=p.marker or p.model end end
 return result,why,result and #list or 0
end
-- Retain the exact native cabinet and wall note as separate components.
-- The parent supplies its ordinary elevation/wall-attachment emit callback.
function M.remainder(p,emit,uvFor)
 local f=familyFor(p)
 if p.importedInterior~=M.tvId or not f or not f.cabinet then return false end
 V.require('Gen3Furniture').append(p,function(vertices,uv,shade,anchor)
  local low,high=math.huge,-math.huge
  for _,v in ipairs(vertices)do low=math.min(low,v[2]);high=math.max(high,v[2])end
  if high<=f.cabinet+.05 or f.note and low>=23 then emit(vertices,uv,shade,anchor)end
 end,uvFor)
 return true
end
return M
