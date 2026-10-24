local loaded,available,drawn={},false,nil
local models={info=function(id)return loaded[id]end,
 register=function(id,data,provider)assert(data.parts and provider.read);loaded[id]=true;return true end,
 buildBatches=function(list,mesh,opt)drawn=list;if not available then return nil,'missing source texture'end;return opt.parts end}
local V={mod={read=function()end}}
V.require=function(name)
 if name=='SceneryModels'then return models end
 if name=='Gen3PublicPCFrames'then return dofile('lib/Gen3PublicPCFrames.lua')end
 if name=='ImportedInstitutionServerData'then return dofile('lib/ImportedInstitutionServerData.lua')end
 if name=='ImportedOldaleFridgeData'then return dofile('lib/ImportedOldaleFridgeData.lua')end
 if name=='ImportedOldaleCupboardData'then return dofile('lib/ImportedOldaleCupboardData.lua')end
 if name=='ImportedOldaleChairData'then return dofile('lib/ImportedOldaleChairData.lua')end
 if name=='ImportedCenterTableData'then return dofile('lib/ImportedCenterTableData.lua')end
 if name=='ImportedCenterHealerData'then return dofile('lib/ImportedCenterHealerData.lua')end
 if name=='ImportedOldaleSinkData'then return dofile('lib/ImportedOldaleSinkData.lua')end
 if name=='ImportedPyreMemorialData'then return dofile('lib/ImportedPyreMemorialData.lua')end
 if name=='ImportedFlowerBookcaseData'then return dofile('lib/ImportedFlowerBookcaseData.lua')end
 if name=='ImportedBirchBookcaseData'then return dofile('lib/ImportedBirchBookcaseData.lua')end
 if name=='ImportedTrickCushionData'then return dofile('lib/ImportedTrickCushionData.lua')end
 if name=='ImportedBirchFreecaseData'then return dofile('lib/ImportedBirchFreecaseData.lua')end
 if name=='ImportedHomeFurnitureData'then return dofile('lib/ImportedHomeFurnitureData.lua')end
 if name=='ImportedOldaleFurnitureData'then return dofile('lib/ImportedOldaleFurnitureData.lua')end
 error(name)
end
local M=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
local fixtures={
 {name='center_healer',kind='centerHealer',pair='building__pokemon_center',rows={{0x222,0x223},{0x22a,0x22b}},coll={{7,7},{7,7}},x=5,z=1,id='oras_center_healer',fit={32,32,0},height=28},
 {name='center_healer',kind='centerHealer',family=false,pair='network',rows={{0x2aa,0x2ab},{0x2b2,0x2b3}},coll={{7,7},{7,7}},x=5,z=1,id='oras_center_healer',fit={32,32,0},height=28},
 {name='hoenn_center_table',kind='centerTable',pair='building__pokemon_center',rows={{0x23d,0x23e},{0x245,0x246}},coll={{7,7},{7,7}},x=11,z=6,id='oras_center_glass_table',fit={32,32,0},height=16},
 {name='center_table',kind='centerTable',family=false,pair='network',rows={{0x29c,0x29d},{0x2a4,0x2a5}},coll={{7,7},{7,7}},x=11,z=6,id='oras_center_glass_table',fit={32,32,0},height=16},
 {name='hoenn_home_chair_555',pair='building__generic_building',design='em_start_seat_pad',rows={{0x22b}},coll={{0}},x=2,z=4,id='oras_oldale_backed_chair',fit={16,16,0},rotation=1},
 {name='hoenn_home_chair_556',pair='building__generic_building',design='em_start_seat_pad',rows={{0x22c}},coll={{0}},x=6,z=4,id='oras_oldale_backed_chair',fit={16,16,0},rotation=3},
 {name='hoenn_home_chair_738',pair='building__generic_building',design='em_start_seat_pad',rows={{0x2e2}},coll={{0}},x=6,z=4,id='oras_oldale_backed_chair',fit={16,16,0},rotation=3},
 {name='hoenn_home_cushion',pair='building__generic_building',design='em_home_cushion',rows={{0x244}},coll={{0}},x=3,z=3,id='oras_trick_house_floor_cushion',fit={16,16,0},height=4},
 {name='birch_free_books',pair='building__lab',design='em_lab_free_books',rows={{0x224,0x225},{0x22c,0x22d},{0x234,0x235}},coll={{0,0},{7,7},{7,7}},x=0,z=5,id='oras_birch_freestanding_case',fit={32,32,1}},
 {name='birch_free_books_end',pair='building__lab',design='em_lab_free_books',rows={{0x236,0x237},{0x22c,0x22d},{0x234,0x235}},coll={{0,0},{7,7},{7,7}},x=2,z=5,id='oras_birch_freestanding_case',fit={32,32,1}},
 {name='birch_books',pair='building__lab',design='em_lab_books',rows={{0x210,0x211},{0x218,0x219},{0x220,0x221}},coll={{7,7},{7,7},{7,0}},x=0,z=0,id='oras_birch_bookcase',fit={32,16,1}},
 {name='hoenn_home_small_books',pair='building__generic_building',design='em_home_books',rows={{0x26e,0x26f},{0x276,0x277},{0x27e,0x27f}},coll={{7,7},{7,7},{0,0}},x=4,z=0,id='oras_flower_bookcase',fit={32,16,1},rotation=3},
 {name='hoenn_home_books',pair='building__generic_building',design='em_home_books',rows={{0x279,0x27a},{0x281,0x282},{0x289,0x28a}},coll={{7,7},{7,7},{0,0}},x=2,z=0,id='oras_flower_bookcase',fit={32,16,1},rotation=3},
 {name='hoenn_pyre_memorial_wall_shadow',primary='general',mapId='EM_MT_PYRE_1F',pair='general__facility',design='fr_tower_grave',rows={{0x326}},coll={{7}},x=9,z=7,id='oras_pyre_memorial',fit={16,16,0},height=17},
 {name='rs_pyre_memorial_wall_shadow',primary='general',mapId='RU_MT_PYRE_1F',pair='general__facility',design='fr_tower_grave',rows={{0x326}},coll={{7}},x=9,z=7,id='oras_pyre_memorial',fit={16,16,0},height=17},
 {name='hoenn_pyre_memorial',primary='general',mapId='EM_MT_PYRE_1F',pair='general__facility',design='fr_tower_grave',rows={{0x2ee}},coll={{7}},x=10,z=3,id='oras_pyre_memorial',fit={16,16,0},height=17},
 {name='rs_pyre_memorial',primary='general',mapId='RU_MT_PYRE_1F',pair='general__facility',design='fr_tower_grave',rows={{0x2ee}},coll={{7}},x=10,z=3,id='oras_pyre_memorial',fit={16,16,0},height=17},
 {name='tower_grave_657',family=false,pair='building__rom_082d4efc',design='fr_tower_grave',rows={{0x291}},coll={{7}},x=3,z=5,id='oras_pyre_memorial',fit={16,16,0},height=17},
 {name='hoenn_home_sink',pair='building__generic_building',design='em_home_sink',rows={{0x26c,0x26d},{0x274,0x275}},coll={{7,7},{0,0}},x=8,z=1,id='oras_oldale_kitchen_sink',fit={32,16,0},rotation=1},
 {name='hoenn_home_tv',pair='building__generic_building',design='em_home_tv',rows={{0x286,0x287},{0x28e,0x28f},{0x296,0x297}},coll={{7,7},{7,7},{0,0}},x=0,z=0,id='oras_oldale_china_cupboard',fit={32,16,1}},
 {name='birch_server',pair='building__lab',design='em_lab_server',rows={{0x216},{0x21e},{0x292}},coll={{0},{7},{0}},x=5,z=0,id='bdsp_galactic_server',fit={16,16,1}},
 {name='lab_server',family=false,pair='oak_lab',design='fr_lab_server',rows={{0x29d},{0x2ad},{0x2b5}},coll={{7},{7},{0}},x=5,z=0,id='bdsp_galactic_server',fit={16,16,1}},
 {name='silph_server',family=false,pair='building__rom_082d4ecc',design='fr_native_rack',rows={{0x37d},{0x385},{0x37e}},coll={{7},{7},{0}},x=5,z=0,id='bdsp_galactic_server',fit={16,16,1}},
 {name='powerplant_server',family=false,pair='building__rom_082d4e9c',design='fr_native_rack',rows={{0x308},{0x310},{0x318}},coll={{7},{7},{43}},x=5,z=0,id='bdsp_galactic_server',fit={16,16,1}},
 {name='mansion_server',family=false,pair='building__rom_082d4f2c',design='fr_native_rack',rows={{0x317},{0x31f},{0x36e}},coll={{7},{7},{43}},x=5,z=0,id='bdsp_galactic_server',fit={16,16,1}},
 {name='hoenn_home_fridge',pair='building__generic_building',design='em_home_fridge',rows={{0x278},{0x280},{0x288}},coll={{7},{7},{0}},x=10,z=0,id='oras_oldale_refrigerator',fit={16,16,1},rotation=1},
 {name='hoenn_start_dining_table',design='em_start_table',rows={{0x21a,0x21b},{0x222,0x223},{0x22a,0x22b}},coll={{7,7},{7,7},{0,0}},x=3,z=6,id='oras_littleroot_dining_table',fit={32,32,0}},
 {name='hoenn_start_fridge',design='em_start_fridge',rows={{0x230},{0x238}},coll={{7},{7}},x=0,z=1,id='oras_littleroot_fridge',fit={16,16,1}},
 {name='hoenn_home_table_yellow',pair='building__generic_building',design='em_home_table',rows={{0x248,0x249},{0x250,0x251}},coll={{7,7},{7,7}},x=3,z=4,id='oras_oldale_checked_table',fit={32,32,0}},
 {name='hoenn_home_table_plain',pair='building__generic_building',design='em_home_table',rows={{0x24a,0x24b},{0x252,0x253}},coll={{7,7},{7,7}},x=4,z=3,id='oras_oldale_neighbor_table',fit={32,32,0}},
}
for _,q in ipairs(fixtures)do
 local cells={};local pair=q.pair or'building__brendans_mays_house'
 local p={cx=q.x,cy=q.z,w=#q.rows[1]*16,d=#q.rows*16,pair=pair,groundHeight=8,
  recipe={name=q.name,design=q.design,kind=q.kind,family=q.family~=false and'rse'or nil,rows=q.rows}}
 for y,row in ipairs(q.rows)do for x,mid in ipairs(row)do
  cells[(q.x+x-1)..':'..(q.z+y-1)]={cx=q.x+x-1,cy=q.z+y-1,mid=mid,collision=q.coll[y][x],base=8,primary=q.primary or'building',region={mapId=q.mapId},pair=pair,prop=p}
 end end
 assert(M.eligible(p,cells));local count=0;for _ in pairs(cells)do count=count+1 end
 local list=M.placements(cells);assert(#list==1 and list[1].model==q.id)
 assert(list[1].x==q.x*16 and list[1].z==(q.z+q.fit[3])*16 and list[1].y==8)
 assert(list[1].fit.width==q.fit[1]and list[1].fit.depth==q.fit[2]and list[1].fit.height==(q.height or 32))
 assert(list[1].fit.rotation==q.rotation,'source front rotation changed')
 assert(list[1].fit.groundInset==.025,'physical source contact became coplanar with native floor')
 local last=cells[(q.x+#q.rows[1]-1)..':'..(q.z+#q.rows-1)]
 for _,key in ipairs{'collision','mid','base','pair','primary','prop'}do
  local original=last[key];last[key]=key=='base'and 9 or false
  assert(not M.eligible(p,cells),'unreviewed source accepted '..key);last[key]=original
 end
 for _,key in ipairs{'stageHidden','stairs','civic','boundary'}do last[key]=true;assert(not M.eligible(p,cells),key);last[key]=nil end
 if q.mapId then local old=last.region;last.region={mapId='EM_MOSSDEEP_CITY_SPACE_CENTER_1F'};assert(not M.eligible(p,cells),'foreign room accepted');last.region=old end
 local original=p.recipe.design;p.recipe.design='unrelated';assert(not M.eligible(p,cells));p.recipe.design=original
 if q.kind then local old=p.recipe.kind;p.recipe.kind='unrelated';assert(not M.eligible(p,cells),'wrong furniture kind accepted');p.recipe.kind=old end
 local capabilities=q.id=='oras_center_healer'and{healingSurface=true}or nil
 if capabilities then local original={};local result,err,n=M.build(cells,function()error('unaware renderer uploaded animated source')end,original)
  assert(result==original and not err and n==0 and not p.importedInterior,'unaware renderer hid native healer')end
 available=false;local result,err,n=M.build(cells,function()end,{},capabilities)
 assert(not result and err and n==0 and not p.importedInterior,'failed source upload hid complete native furniture')
 available=true;local parts={};result,err,n=M.build(cells,function()end,parts,capabilities)
 assert(result==parts and not err and n==1 and p.importedInterior==q.id)
 local after=0;for _ in pairs(cells)do after=after+1 end;assert(count==after)
 for y,row in ipairs(q.rows)do for x,mid in ipairs(row)do local c=cells[(q.x+x-1)..':'..(q.z+y-1)];assert(c.mid==mid and c.collision==q.coll[y][x]and c.prop==p)end end
end
print('PASS exact Littleroot identities, native wall/apron and height guards, unchanged gameplay cells and atomic missing-source fallback')
