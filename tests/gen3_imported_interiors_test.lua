local uploaded,available=false,false
local placements
local models={info=function()return uploaded end,
 register=function(id,data,provider)assert(id=='oras_center_pc'and data.parts and provider.read);uploaded=true;return true end,
 buildBatches=function(list,mesh,options)
  assert(type(mesh)=='function');placements=list
  if not available then return nil,'missing texture'end
  return options.parts
 end}
local V={mod={read=function()end}}
V.require=function(name)
 if name=='Gen3PublicPCFrames'then return dofile('lib/Gen3PublicPCFrames.lua')end
 if name=='SceneryModels'then return models end
 if name=='ImportedInteriorData'then return{oras_center_pc={parts={}}}end
 error(name)
end
local I=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(V)
local function fixture(hoenn,x)
 local rows=hoenn and{{0x20c},{4},{0x224}}or{{0x285},{0x62},{0x295}}
 local pair=hoenn and'building__pokemon_center'or'network'
 local p={cx=x,cy=0,w=16,d=48,pair=pair,groundHeight=8,
  recipe={pair=pair,name=hoenn and'hoenn_center_pc'or'center_terminal',family=hoenn and'rse'or nil,design='fr_center_pc',rows=rows}}
 local cells={}
 for i=1,3 do cells[x..':'..i-1]={cx=x,cy=i-1,mid=rows[i][1],collision=({7,0x93,0})[i],base=8,primary='building',pair=pair,prop=p}end
 return p,cells
end
local p,cells=fixture(true,5);assert(I.eligible(p,cells))
cells['5:1'].mid=5;cells['5:1'].collision=7;assert(I.eligible(p,cells),'Hoenn powered native PC vanished');cells['5:1'].mid=4;assert(I.eligible(p,cells),'Hoenn flicker OFF lost blocked collision7');cells['5:1'].collision=0x93
for _,field in ipairs{'boundary','stageHidden','stairs','civic'}do
 cells['5:1'][field]=true;assert(not I.eligible(p,cells),field);cells['5:1'][field]=nil
end
for _,field in ipairs{'collision','mid','base','pair','primary','prop'}do
 local original=cells['5:1'][field];cells['5:1'][field]=field=='base'and 9 or false
 assert(not I.eligible(p,cells),field);cells['5:1'][field]=original
end
p.recipe.rows[3][1]=0x21c;assert(not I.eligible(p,cells),'different upper-room PC');p.recipe.rows[3][1]=0x224
assert(not I.build(cells,function()end,{})and not p.importedInterior,'failed upload hid native furniture')
available=true
local parts={};local result,err,count=I.build(cells,function()end,parts)
assert(result==parts and not err and count==1 and p.importedInterior=='oras_center_pc')
assert(placements[1].x==80 and placements[1].z==16 and placements[1].y==8)
assert(placements[1].fit.width==16 and placements[1].fit.depth==16 and placements[1].fit.height==24)
local q,kanto=fixture(false,3);assert(I.eligible(q,kanto))
kanto['3:1'].mid=0x63;kanto['3:1'].collision=7;assert(I.eligible(q,kanto),'Kanto powered native PC vanished');kanto['3:1'].mid=0x62;assert(I.eligible(q,kanto),'Kanto flicker OFF lost blocked collision7');kanto['3:1'].collision=0x93
for k,c in pairs(kanto)do cells[k]=c end
assert(#I.placements(cells)==2 and I.placements(cells)[1].source==q)
q.recipe.name='room_computer';assert(not I.eligible(q,cells),'home computer identity substituted')
assert(I.build({},function()error('unexpected GPU call')end,parts)==parts)
local noSource={require=function(name)if name=='Gen3PublicPCFrames'then return dofile('lib/Gen3PublicPCFrames.lua')end;if name=='SceneryModels'then return models end;error('missing')end}
local fallback=assert(loadfile('lib/Gen3ImportedInteriors.lua'))(noSource)
assert(not fallback.register(),'source omission must preserve native furniture')
print('PASS exact regional public PC identity, all native cell/height guards, sorted bounds, resource failure and actor/ground preservation')
