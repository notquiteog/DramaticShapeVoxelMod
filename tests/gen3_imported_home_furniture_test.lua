local loaded,available,drawn={},false,nil
local models={info=function(id)return loaded[id]end,
 register=function(id,data,provider)assert(data.parts and provider.read);loaded[id]=true;return true end,
 buildBatches=function(list,mesh,opt)drawn=list;if not available then return nil,'missing source texture'end;return opt.parts end}
local V={mod={read=function()end}}
V.require=function(name)
 if name=='SceneryModels'then return models end
 if name=='Gen3PublicPCFrames'then return dofile('lib/Gen3PublicPCFrames.lua')end
 if name=='ImportedHomeFurnitureData'then return dofile('lib/ImportedHomeFurnitureData.lua')end
 if name=='ImportedOldaleFurnitureData'then return dofile('lib/ImportedOldaleFurnitureData.lua')end
 error(name)
end
local M=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
local fixtures={
 {name='hoenn_start_dining_table',design='em_start_table',rows={{0x21a,0x21b},{0x222,0x223},{0x22a,0x22b}},coll={{7,7},{7,7},{0,0}},x=3,z=6,id='oras_littleroot_dining_table',fit={32,32,0}},
 {name='hoenn_start_fridge',design='em_start_fridge',rows={{0x230},{0x238}},coll={{7},{7}},x=0,z=1,id='oras_littleroot_fridge',fit={16,16,1}},
 {name='hoenn_home_table_yellow',pair='building__generic_building',design='em_home_table',rows={{0x248,0x249},{0x250,0x251}},coll={{7,7},{7,7}},x=3,z=4,id='oras_oldale_checked_table',fit={32,32,0}},
 {name='hoenn_home_table_plain',pair='building__generic_building',design='em_home_table',rows={{0x24a,0x24b},{0x252,0x253}},coll={{7,7},{7,7}},x=4,z=3,id='oras_oldale_neighbor_table',fit={32,32,0}},
}
for _,q in ipairs(fixtures)do
 local cells={};local pair=q.pair or'building__brendans_mays_house'
 local p={cx=q.x,cy=q.z,w=#q.rows[1]*16,d=#q.rows*16,pair=pair,groundHeight=8,
  recipe={name=q.name,design=q.design,family='rse',rows=q.rows}}
 for y,row in ipairs(q.rows)do for x,mid in ipairs(row)do
  cells[(q.x+x-1)..':'..(q.z+y-1)]={cx=q.x+x-1,cy=q.z+y-1,mid=mid,collision=q.coll[y][x],base=8,primary='building',pair=pair,prop=p}
 end end
 assert(M.eligible(p,cells));local count=0;for _ in pairs(cells)do count=count+1 end
 local list=M.placements(cells);assert(#list==1 and list[1].model==q.id)
 assert(list[1].x==q.x*16 and list[1].z==(q.z+q.fit[3])*16 and list[1].y==8)
 assert(list[1].fit.width==q.fit[1]and list[1].fit.depth==q.fit[2]and list[1].fit.height==32)
 assert(list[1].fit.groundInset==.025,'physical source contact became coplanar with native floor')
 local last=cells[(q.x+#q.rows[1]-1)..':'..(q.z+#q.rows-1)]
 for _,key in ipairs{'collision','mid','base','pair','primary','prop'}do
  local original=last[key];last[key]=key=='base'and 9 or false
  assert(not M.eligible(p,cells),'unreviewed source accepted '..key);last[key]=original
 end
 for _,key in ipairs{'stageHidden','stairs','civic','boundary'}do last[key]=true;assert(not M.eligible(p,cells),key);last[key]=nil end
 local original=p.recipe.design;p.recipe.design='unrelated';assert(not M.eligible(p,cells));p.recipe.design=original
 available=false;local result,err,n=M.build(cells,function()end,{})
 assert(not result and err and n==0 and not p.importedInterior,'failed source upload hid complete native furniture')
 available=true;local parts={};result,err,n=M.build(cells,function()end,parts)
 assert(result==parts and not err and n==1 and p.importedInterior==q.id)
 local after=0;for _ in pairs(cells)do after=after+1 end;assert(count==after)
 for y,row in ipairs(q.rows)do for x,mid in ipairs(row)do local c=cells[(q.x+x-1)..':'..(q.z+y-1)];assert(c.mid==mid and c.collision==q.coll[y][x]and c.prop==p)end end
end
print('PASS exact Littleroot identities, native wall/apron and height guards, unchanged gameplay cells and atomic missing-source fallback')
