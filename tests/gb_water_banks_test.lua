local modules={};local V={require=function(n)return assert(modules[n],n)end}
local M=assert(loadfile('lib/GBWater.lua'))(V)
local map={def={tileset='OVERWORLD',width=1,height=1}}
local source={class='water',h=-2,art='flat',authored=true}
assert(M.shape(map,source).h==-8 and source.h==-2,'shared source class mutated')
assert(M.shape(map,source)==M.shape(map,source),'immutable shape variant rebuilt')
assert(M.relative(map,-20)==-20 and M.relative(map,3)==3,'authored deeper/raised pool changed')
local indoor={def={tileset='INTERIOR'}};assert(M.shape(indoor,source)==source,'indoor pool changed')
map.def.voxelWater=false;assert(M.shape(map,source)==source,'extension opt-out ignored')
map.def.voxelWater={bankDepth=10};assert(M.relative(map,-2)==-10 and M.relative(map,-20)==-20)
map.def.voxelWater={waterline=4};assert(M.relative(map,-2)==4)
map.def.voxelWater=nil;assert(M.relative(map,-2,{preserveWaterLevel=true})==-2)
local ground={class='ground',h=0,art='flat'};local bridge={class='ground',h=3,bridge=true}
local special
function map:isWaterCell(x,y)return x==1 end
function map:tileAt(x,y)return x==2 and 1 or 0 end
modules.TileShape={forMap=function()return{}end,heights=function()return{water=-2}end,
 at=function(_,_,tile)return tile==1 and M.shape(map,source)or special or ground end}
modules.Gen2Elevation={at=function()return 6 end}
modules.BankMaterials={uv=function()return{{0,1},{1,1},{1,0},{0,0}}end}
assert(M.surfaceAt(map,24,8)==-8 and M.surfaceAt(map,8,8)==nil)
map.cellCollision=function()return 0 end;assert(M.surfaceAt(map,24,8)==-2,'native elevated water support lost')
local vs,ix=M.bankGeometry(map);assert(#vs==32 and #ix==48,'missing below-floor closure')
for i=1,#vs,4 do assert(vs[i][2]==-2 and vs[i+2][2]==6,'bank top/bottom disagree with source floor/sheet')end
special=bridge;local v=M.bankGeometry(map);assert(#v==0,'bank soil crossed an authored deck')
special=ground;map.def.voxelWater=false;assert(#M.bankGeometry(map)==0)
-- Equal ordinary-water answers can still have different authored-pool policy.
map.def.voxelWater=nil;source.h=-20
local key=M.policyKey(map);assert(M.plane(map)==-14)
map.def.voxelWater={waterline=-8}
assert(M.policyKey(map)~=key and M.plane(map)==-2,'plane cache reused preserved deep pool after explicit -8 policy')
map.def.voxelWater={bankDepth=8};assert(M.policyKey(map)~=key)
map.def.voxelWater=false;assert(M.policyKey(map)~=key)
print('PASS HGSS eight-pixel natural banks, immutable shared art, interior/deep/raised/bridge preservation, explicit extension policies and elevated native support')
