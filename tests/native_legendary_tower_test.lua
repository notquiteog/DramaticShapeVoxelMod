local enabled,detail=false,true;local builds,released=0,0;local vertices
local loaded={};local V={}
function V.require(k)
 if k=='CommunityVisuals'then return {customTower=function()return enabled end,referenceBuildings=function()return detail end}end
 if k=='Voxel3D'then return {newMesh=function(v)vertices=v;builds=builds+1;return {release=function()released=released+1 end}end}end
 if k=='Gen3Civic'then return {profile=function()return {w=112,back=16,front=127,wall=143}end}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end
 return loaded[k]
end
local Source=V.require('LegendaryTowerExterior');Source.texture=function()return 'palette'end
local M=V.require('NativeLegendaryTower');local g={cx=3,cy=5,groundHeight=16,custom={geometry='tower'}}
local count=0;local function draw(mesh,tex,model)
 count=count+1;assert(tex=='palette'and model[4]==48 and model[8]==16 and model[12]==96)
end
assert(not M.draw(g,draw)and builds==0)
enabled=true;assert(not M.draw({custom={geometry='house'}},draw))
assert(M.draw(g,draw)and builds==1)
for _,p in ipairs(vertices)do if p[2]<24 then assert(p[1]>=0 and p[1]<=96 and p[3]>=0 and p[3]<=64,'base intrudes outside blocking footprint')end end
assert(M.draw(g,draw)and builds==1)
detail=false;assert(M.draw(g,draw)and builds==2 and released==1)
assert(not M.draw(g,function()error('GPU unavailable')end)and M.lastError)
M.clear();assert(released==2)
print('PASS native optional tower: actual shared model, footprint/elevation, cached geometry, OFF and render-failure fallback')
