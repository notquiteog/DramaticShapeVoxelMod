local height=0;local blocked=false;local solidCalls=0
local Collision={isGrass=function(x,y)return x<12 end,isWalkable=function(x,y)solidCalls=solidCalls+1;return not blocked end,isWater=function(x,y)return x>=12 end}
package.loaded['src.core.game3.collision']=Collision
local deps={CommunityVisuals={customForest=function()return true end},Gen3Tilesets={outdoor=function(d)return d.mapType==1 end},NativeAtmosphere={kind=function(m)return m.id=='ILEX_FOREST'and'forest'end},
 Gen2Elevation={at=function(_,x,z)return x>120 and height or 0 end},Gen3Elevation={at=function(_,x,z)return x>120 and height or 0 end}}
local N=assert(loadfile('lib/NativeHabitat.lua'))({require=function(n)return deps[n]end})
local map={id='ROUTE_29',def={environment='ROUTE',width=12,height=10},cellCollision=function()end,
 isGrassCell=function(_,x,y)return Collision.isGrass(x,y)end,isWalkableCell=function(_,x,y)return Collision.isWalkable(x,y)end,isWaterCell=function(_,x,y)return Collision.isWater(x,y)end}
assert(N.profile(map).native);map.def.environment='CAVE';assert(not N.profile(map));map.def.environment='ROUTE'
local a=N.scan(map,128,128);assert(#a.green>0 and a.greenLevel>0 and a.water>0 and solidCalls<=490)
local b=N.scan(map,128,128);assert(#a.green==#b.green and a.green[1].seed==b.green[1].seed,'placement drift')
blocked=true;assert(#N.scan(map,128,128).green==0,'butterflies inside obstacles');blocked=false
height=20;local c=N.scan(map,128,128);assert(#c.green<#a.green,'particles straddle elevation boundary')
local g3={id='FR_ROUTE_1',nativeGeneration=3,nativeDef={mapType=1,midLayout={width=24,height=20}},def={}}
assert(N.profile(g3).native and #N.scan(g3,128,128).green==#c.green)
g3.nativeDef.mapType=8;assert(not N.profile(g3),'ambience inside building')
assert(not N.native({id='ROUTE_1'}),'Gen1 adapter changed')
print('PASS native habitat bounded deterministic grass, water, blocked cells, elevation and interior exclusions')
