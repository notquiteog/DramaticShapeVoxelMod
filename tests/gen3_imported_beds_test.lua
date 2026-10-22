local edition='emerald';package.loaded['src.core.GameVersion']={get=function()return edition end}
local F=dofile('lib/Gen3Furniture.lua')
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end},Gen3PublicPCFrames=dofile('lib/Gen3PublicPCFrames.lua'),ImportedInteriorBedData=dofile('lib/ImportedInteriorBedData.lua')}
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local I=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
assert(I.register(I.bedId));assert(S.info(I.bedId).parts==3)
local model=modules.ImportedInteriorBedData.oras_comfortable_bed;local source,closure=0,0
for _,part in ipairs(model.parts)do if part.authored then closure=closure+#part.indices/3 else source=source+#part.indices/3 end end
assert(source==534 and closure==90,'source bedding or closure provenance changed')
local vertices,fit=S.vertices(I.bedId,{width=32,depth=32,height=18,padding=.25})
assert(fit.bounds[4]-fit.bounds[1]>20.5 and fit.bounds[6]-fit.bounds[3]>31.4 and fit.bounds[5]<12)
for _,part in ipairs(vertices)do for _,v in ipairs(part.vertices)do assert(v[1]>=.25 and v[1]<=31.75 and v[3]>=.25 and v[3]<=31.75 and v[2]>=0,'bed entered walking apron')end end
local build=S.buildBatches;local failure=false
S.buildBatches=function(list,_,opts)
 assert(#list==1 and list[1].model==I.bedId and list[1].x==0 and list[1].z==48 and list[1].y==2)
 if failure then return nil,'missing bed texture'end;return opts.parts
end
for _,version in ipairs{'ruby','sapphire','emerald'}do
 edition=version;local recipe
 for _,r in ipairs(F.recipes)do if r.name=='hoenn_home_bed'then recipe=r end end;assert(recipe)
 local cells={};for y,row in ipairs(recipe.rows)do for x,mid in ipairs(row)do cells[(x-1)..':'..(y+2)]={cx=x-1,cy=y+2,primary='building',secondary='generic_building',pair=recipe.pair,mid=mid,collision=7,base=2,ts={}}end end
 local p=F.extract(cells)[1];assert(p and p.recipe==recipe);p.groundHeight=2;assert(I.eligible(p,cells))
 for _,key in ipairs{'0:3','1:3','0:4','1:4'}do
  cells[key].collision=0;assert(not I.eligible(p,cells),'walking bed cell consumed');cells[key].collision=7
 end
 cells['1:4'].base=3;assert(not I.eligible(p,cells),'uneven native floor accepted');cells['1:4'].base=2
 local name=recipe.name;recipe.name='hoenn_start_bed_left';assert(not I.eligible(p,cells),'one-cell starter bed shrunk into imported family');recipe.name=name
 failure=true;assert(not I.build(cells,function()end,{})and not p.importedInterior,'missing bed source hid native model');failure=false
 local out,err,count=I.build(cells,function()end,{});assert(out and not err and count==1 and p.importedInterior==I.bedId)
 assert(not I.remainder(p,function()error('bed emitted native duplicate')end,function()end))
 for _,c in pairs(cells)do assert(c.collision==7 and c.base==2)end
end
S.buildBatches=build
print('PASS full-blocked native Hoenn beds, original source proportions/bedding, authored closure, clearance and missing-resource/native fallback')
