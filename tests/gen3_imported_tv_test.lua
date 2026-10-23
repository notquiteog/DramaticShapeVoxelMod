local edition='firered'
package.loaded['src.core.GameVersion']={get=function()return edition end}
local F=dofile('lib/Gen3Furniture.lua')
local modules={SceneryModelData={},ModelInstances={},BuildBudget={check=function()end},Gen3Furniture=F,
 Gen3PublicPCFrames=dofile('lib/Gen3PublicPCFrames.lua'),ImportedInteriorTVData=dofile('lib/ImportedInteriorTVData.lua')}
local V={mod={read=function(path)local f=assert(io.open(path,'rb'));local s=f:read('*a');f:close();return s end}}
V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local I=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
assert(I.register(I.tvId));local info=S.info(I.tvId);assert(info.parts==3)
local verts,fit=S.vertices(I.tvId,{width=16,depth=16,height=17,padding=.25})
assert(fit.bounds[4]-fit.bounds[1]>15.4 and fit.bounds[5]<17)
local triangles=0;for _,p in ipairs(modules.ImportedInteriorTVData.oras_home_tv.parts)do triangles=triangles+#p.indices/3 end
assert(triangles==104,'source84 plus separately authored20 closure triangles')
for _,part in ipairs(verts)do for _,v in ipairs(part.vertices)do assert(v[1]>=.25 and v[1]<=15.75 and v[3]>=.25 and v[3]<=15.75)end end
local build=S.buildBatches;local failure=false
S.buildBatches=function(list,_,opts)
 assert(#list==1 and list[1].model==I.tvId and list[1].y==11 and list[1].z==32)
 assert(list[1].fit.groundInset==.025,'TV source underside meets native cabinet plane')
 if failure then return nil,'texture absent'end
 return opts.parts
end
for _,version in ipairs{'firered','leafgreen','ruby','sapphire','emerald'}do
 edition=version;local hoenn=version~='firered'and version~='leafgreen'
 for _,pair in ipairs(hoenn and{'building__generic_building'}or{'player_house','house'})do
  local name=hoenn and'hoenn_home_small_tv'or pair=='house'and'neighbor_living_television'or'living_television'
  local recipe;for _,r in ipairs(F.recipes)do if r.name==name and r.pair==pair then recipe=r end end;assert(recipe)
  local cells={};for y,row in ipairs(recipe.rows)do cells['3:'..y]={cx=3,cy=y,primary='building',pair=pair,mid=row[1],collision=y<3 and 7 or 0,
   behavior=y==2 and 0x86 or 0,base=5,ts={}}end
  local p=F.extract(cells)[1];assert(p and p.recipe==recipe);p.groundHeight=5
  assert(I.eligible(p,cells));cells['3:2'].behavior=0;assert(not I.eligible(p,cells),'non-TV cupboard substituted');cells['3:2'].behavior=0x86
  cells['3:3'].collision=7;assert(not I.eligible(p,cells),'changed native approach accepted');cells['3:3'].collision=0
  failure=true;assert(not I.build(cells,function()end,{})and not p.importedInterior,'TV asset failure hid native furniture');failure=false
  local result,err,count=I.build(cells,function()end,{});assert(result and not err and count==1 and p.importedInterior==I.tvId)
  local low,note,all=0,0,0
  assert(I.remainder(p,function(v)
   local a,b=math.huge,-math.huge;for _,q in ipairs(v)do a=math.min(a,q[2]);b=math.max(b,q[2])end
   assert(b<=6.05 or not hoenn and a>=23,'old CRT remained beside imported TV')
   if b<=6.05 then low=low+1 else note=note+1 end;all=all+1
  end,function()return{{0,0},{1,0},{1,1},{0,1}}end))
  assert(low>0 and(hoenn and note==0 or not hoenn and note>0),version..' native cabinet/note lost')
  assert(cells['3:2'].mid==recipe.rows[2][1]and cells['3:3'].collision==0)
 end
end
S.buildBatches=build
print('PASS all-five true-TV identity, original cabinet/wall-note remainder, failed-source fallback, bounded source fit and authored rear/undersides')
