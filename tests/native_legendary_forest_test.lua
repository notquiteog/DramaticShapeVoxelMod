local active,voxel=false,true
local cache={}
local V={}
function V.require(k)
 if k=='CommunityVisuals'then return {customForest=function()return active end,treeDetail={get=function()return 'handheld'end}}end
 if k=='TreePresentation'then return {voxel=function()return voxel end}end
 if k=='BuildBudget'then return {tick=function()end}end
 if not cache[k]then cache[k]=assert(loadfile('lib/'..k..'.lua'))(V)end
 return cache[k]
end
local M=V.require('NativeLegendaryForest');local art={w=48,h=80,bottom=8}
local c={cx=3,cy=5,shape={spacing=3}}
assert(M.card(art,c,'FR_VIRIDIAN_FOREST')==art)
active=true;assert(M.card(art,c,'FR_ROUTE_1')==art)
voxel=false;assert(M.card(art,c,'FR_VIRIDIAN_FOREST')==art);voxel=true
local model=M.card(art,c,'FR_VIRIDIAN_FOREST');assert(model~=art and model.legendaryForest)
assert(M.card(art,c,'FR_VIRIDIAN_FOREST')==model,'prototype not shared')
local v,i={},{};local count=V.require('NativeTreeArt').appendModel(model,v,i,0,100,5,200)
assert(count>100 and #i==count*6)
local material={};local high=0
for _,p in ipairs(v)do
 assert(p[1]>=76-.001 and p[1]<=124+.001 and p[3]>=176-.001 and p[3]<=224+.001,'canopy exceeds native drawing footprint')
 assert(p[2]>=5-.001 and p[2]<=77+.001,'height or ground changed')
 material[math.floor((p[6]-4096)/128)]=true;high=math.max(high,p[2])
end
assert(high>76.9 and material[19]and material[20],'missing trunk/crown materials')
print('PASS optional native forest: default/card/unrelated-map fallback, shared Gen1 geometry/materials, original tree footprint and height')
