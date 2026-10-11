local enabled=true;local V={};local loaded={}
function V.require(k)
 if k=='CommunityVisuals'then return{referenceBuildings=function()return enabled end}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return loaded[k]
end
local walkable={['1:3']=true};local map={id='VERMILION_CITY',def={warps={{x=1,y=3,destMap='POKEMON_FAN_CLUB'}}},tileset={imageWidth=128,imageHeight=128},isWalkableCell=function(_,x,y)return walkable[x..':'..y]or false end}
local g={x=0,y=0,width=8,depth=8,wallTile=34,quadFirst=1,quadLast=1,style='kanto_hip'}
local S={gen2=true,outdoor=true,exteriors={g},objectQuads={{{0,0,0},{1,0,0},{1,1,0},{0,1,0}}}}
local M=V.require('NativeGen2Buildings');M.build(S,map);assert(M.lastCount==1 and #S.objectQuads>100)
for _,q in ipairs(S.objectQuads)do assert(q.referenceMaterial and q.uv);for _,p in ipairs(q)do if p[2]<24 then assert(p[1]>=0 and p[1]<=64 and p[3]>=0 and p[3]<=64)end end end
walkable['2:2']=true;assert(not M.spec(map,g));walkable['2:2']=nil
enabled=false;assert(not M.spec(map,g));enabled=true;map.id='NEW_REGION';assert(not M.spec(map,g));map.id='VERMILION_CITY';map.def.warps={};assert(not M.spec(map,g))
print('PASS native Gen2 shared buildings: actual model kit, opaque source donor, native doors, clear floor exclusions and fallback')
