local V={require=function(n)
 if n=='SharedModelMesh'then return assert(loadfile('lib/SharedModelMesh.lua'))()elseif n=='ModelInstances'then return{}elseif n=='BuildBudget'then return{check=function()end}elseif n=='SceneryModelData'then return{}end;error(n)
end}
local S=assert(loadfile('lib/SceneryModels.lua'))(V)
local function png(w,h)local function u(n)return string.char(math.floor(n/16777216)%256,math.floor(n/65536)%256,math.floor(n/256)%256,n%256)end;return '\137PNG\13\10\26\10'..u(13)..'IHDR'..u(w)..u(h)end
local dimensions={32,32};local released=0
love={filesystem={newFileData=function()return{release=function()end}end},graphics={newImage=function()return{getDimensions=function()return unpack(dimensions)end,setFilter=function()end,setWrap=function()end,release=function()released=released+1 end}end}}
local def={parts={{texture='texture.png',vertices={{0,0,0,0,0,1},{1,0,0,1,0,1},{0,1,1,0,1,1}},indices={1,2,3}}}}
for i=1,80 do
 local id='regional_source_'..i;assert(S.register(id,def,{read=function()return png(unpack(dimensions))end}))
 assert(S.image(id,'texture.png','repeat','repeat'),'touring small regional models exhausted count before byte budget')
end
local a=S.stats();assert(a.models==80 and a.textures==80 and a.textureBytes==80*32*32*4)
assert(S.limits.textureBytes==8388608 and S.limits.catalogBytes==10485760,'memory ceilings must remain bounded')
dimensions={2048,2048};assert(S.register('oversized',def,{read=function()return png(unpack(dimensions))end}))
assert(not S.image('oversized','texture.png','repeat','repeat'),'large texture escaped byte ceiling')
assert(S.stats().textures==80,'failed image changed live accounting');S.release();assert(released==80)
print('PASS extended regional source tour below unchanged memory ceilings, oversized texture rejection and full cleanup')
