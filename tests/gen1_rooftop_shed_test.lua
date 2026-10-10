local profile=assert(loadfile('data/voxel_heights.lua'))()
local t=assert(profile.buildings.MANSION[1]);assert(t.id=='mansion_rooftop_shed')
local H=dofile('tests/astra_fixture.lua')
local image,w,h
if os.getenv('ROOF_ATLAS')then image,w,h=H.atlas(os.getenv('ROOF_ATLAS'))
else w,h=128,128;image={getPixel=function()return .3,.3,.3,1 end}end
local V={data=function()return profile end,require=function(name)
 if name=='BuildBudget'then return{tick=function()end}end
 if name=='LegendaryTowerExterior'then return{activeFor=function()return false end}end
 error(name)
end}
local B=assert(loadfile('lib/Buildings.lua'))(V)
local function key(x,y)return(y+64)*4096+x+64 end
local function scene(id,broken)
 local s={tileAt={},shapeAt={},skip={},ground={},objectQuads={}}
 for r,row in ipairs(t.tiles)do for c,tile in ipairs(row)do s.tileAt[key(c-1,r-1)]=tile end end
 if broken then s.tileAt[key(2,3)]=1 end
 local map={id=id,def={width=2,height=2},tileset={id='MANSION',imageWidth=w,imageHeight=h}}
 B.build(s,map,image,w/8);return s
end
local s=scene('CELADON_MANSION_ROOF');assert(#s.objectQuads>0,'full source pattern must create model')
local maximum=0;local planes={}
for _,q in ipairs(s.objectQuads)do
 for _,p in ipairs{q[1],q[2],q[3],q[4]}do
  assert(p[1]>=0 and p[1]<=48 and p[3]>=0 and p[3]<=64,'outside source footprint')
  maximum=math.max(maximum,p[2])
 end
 for a=1,3 do if q[1][a]==q[2][a]and q[1][a]==q[3][a]and q[1][a]==q[4][a]then planes[a]=true end end
end
assert(maximum>=16 and planes[1]and planes[2]and planes[3],'shed requires upright walls, closed roof and sides')
assert(not s.skip[key(6,0)]and not s.skip[key(0,8)],'neighboring walkway claimed')
assert(#scene('CELADON_MANSION_1F').objectQuads==0,'shared furniture art must not become a shed')
assert(#scene('CELADON_MANSION_ROOF',true).objectQuads==0,'incomplete drawings must not claim neighboring art')
local I=assert(loadfile('lib/InteriorDiorama.lua'))({})
assert(I.profile({id='CELADON_MANSION_ROOF',tileset='MANSION',width=4,height=6},1)==nil,'roof is outdoors')
assert(I.profile({id='CELADON_MANSION_1F',tileset='MANSION',width=4,height=6},1),'actual interior stays enclosed')
print('PASS source-scoped rooftop shed geometry, neighboring walkway, partial/indoor rejection and open-air room classification')
