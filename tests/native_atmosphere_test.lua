local values={communityForest='default',communityCaves='default',communityTower='default',atmos='low',communityCaveDetails='off',towerFog='on',towerDetails='full',towerFogSpeed='normal',towerFogThickness='normal'}
local configs,draws={},{}
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
local M=assert(loadfile('lib/NativeAtmosphere.lua'))({require=function(n)return ({ForestAtmos=F,CommunityVisuals=C,TowerFogSettings=T})[n]end})
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
print('PASS native atmosphere dimensions, opt-in/off, map identity, fog thickness/speed and Gen1 isolation')
