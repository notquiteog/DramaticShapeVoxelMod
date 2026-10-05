local values={communityForest='default',communityCaves='default',communityTower='default',atmos='low',communityCaveDetails='off',towerFog='on',towerDetails='full',towerFogSpeed='normal',towerFogThickness='normal'}
local configs,draws,mists={},{},{}
local function setting(k)return{key=k,get=function()return values[k]end}end
local C={forest=setting('communityForest'),caves=setting('communityCaves'),tower=setting('communityTower'),caveDetails=setting('communityCaveDetails')}
function C.customForest()return values.communityForest~='default'end
function C.customCaves()return values.communityCaves~='default'end
function C.customTower()return values.communityTower~='default'end
function C.caveDetailLevel()return values.communityCaveDetails end
local T={enabled=setting('towerFog'),details=setting('towerDetails'),speed=setting('towerFogSpeed'),thickness=setting('towerFogThickness')}
function T.detailsLevel()return values.towerDetails end
function T.speedMultiplier()return values.towerFogSpeed=='fast' and 1.45 or 1 end
function T.thicknessMultipliers()return values.towerFogThickness=='heavy' and 1.45 or 1,1 end
function T.active()return values.towerFog=='on'end
local F={setting=setting('atmos'),setOverride=function(id,c)configs[id]=c end,
 frame=function(map,_,opt)if opt.level=='off'then return end;return{fog={density=configs[map.id].fog.density,heightK=.06}}end,
 draw=function(map,opt)draws[#draws+1]={map.id,opt}end}
local M=assert(loadfile('lib/NativeAtmosphere.lua'))({require=function(n)return ({ForestAtmos=F,CommunityVisuals=C,TowerFogSettings=T,TowerGraveMist={drawNative=function(map,layout)mists[#mists+1]={map,layout}end},Gen2Elevation={at=function()return 6 end},Gen3Elevation={at=function()return 12 end}})[n]end})
local def={midLayout={width=50,height=30},mapType=1}
local forest=M.gen3(def,'FR_VIRIDIAN_FOREST');assert(forest.def.width*32==800 and forest.def.height*32==480)
assert(M.gen3(def,'FR_VIRIDIAN_FOREST')==forest)
assert(not M.fog(forest));values.communityForest='n64memory';assert(M.fog(forest));values.atmos='off';assert(not M.fog(forest))
assert(not M.kind({id='VIRIDIAN_FOREST'}),'Gen1 ownership changed')
local tower={id='TIN_TOWER_1F',cellCollision=function()end,def={environment='INDOOR'}}
values.communityTower='n64memory';local before=M.fog(tower).density;values.towerFogThickness='heavy';assert(M.fog(tower).density>before)
values.towerFog='off';assert(not M.fog(tower));values.towerFogSpeed='fast';M.draw(tower);assert(draws[#draws][2].speed==1.45)
values.towerDetails='subtle';M.draw(tower);assert(draws[#draws][2].particleLevel==.35)
values.towerDetails='off';M.draw(tower);assert(draws[#draws][2].level=='low')
local cave=M.gen3({mapType=4,midLayout={width=20,height=20}},'FR_ROCK_TUNNEL_1F');assert(M.kind(cave)=='cave');assert(not M.fog(cave))
values.communityCaves='n64memory';values.communityCaveDetails='full';assert(M.fog(cave));M.draw(cave);assert(draws[#draws][2].level=='full')
-- Native mist reads the correct cell grid and preserves elevated floors.
tower.def.width,tower.def.height=4,4
tower.isWalkableCell=function(_,x,y)return x~=3 end
tower.tileAt=function(_,x,y)return x==6 and 45 or 2 end
values.towerFog='on';M.draw(tower);assert(#mists==1)
local layout=mists[1][2];assert(#layout.anchors==6 and layout.ground(16,16)==6)
assert(not layout.walk(-1,0) and not layout.walk(8,0));assert(M.mistLayout(tower)==layout)
local graveMap={width=8,height=6,midAt=function(_,x,y)return x==3 and y==2 and 0x291 or 0x281 end,
 collAt=function(_,x,y)return x==3 and y==2 and 7 or 0 end}
local g3=M.gen3({mapType=8,midLayout=graveMap},'FR_POKEMON_TOWER_3F')
M.draw(g3);local l3=mists[2][2];assert(#l3.anchors==1 and l3.anchors[1][1]==3 and l3.anchors[1][2]==2)
assert(l3.ground(32,32)==12 and not l3.walk(3,2) and not l3.walk(8,0))
values.towerFog='off';M.draw(g3);assert(#mists==2,'OFF allocated/drew mist')
assert(not M.mistLayout(forest),'mist leaked into forest')
print('PASS native atmosphere dimensions, opt-in/off, map identity, fog thickness/speed and Gen1 isolation')

values.atmos='low';values.communityForest='n64memory'
local woods=M.gen3({mapType=3,width=20,height=20},'EM_PETALBURG_WOODS')
assert(M.kind(woods)=='forest' and M.fog(woods),'Hoenn forest omitted from shared controls')
M.draw(woods);assert(draws[#draws][2].level=='low')
values.atmos='off';assert(not M.fog(woods));local n=#draws;M.draw(woods);assert(#draws==n)
values.atmos='full';values.communityForest='default';assert(not M.fog(woods))
assert(not M.kind(M.gen3({mapType=1,width=20,height=20},'EM_PETALBURG_CITY')),'town became a forest')
assert(M.kind({id='NATIVE_FOREST',cellCollision=function()end,def={environment='FOREST'}})=='forest')
print('PASS Hoenn/native forest controls, OFF and town/Gen1 isolation')
