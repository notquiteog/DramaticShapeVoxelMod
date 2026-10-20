local settings={};local reads=0;local clears=0;local version="red"
local cloudDraws,cloudClears=0,0
local clouds={draw=function()cloudDraws=cloudDraws+1 end,clear=function()cloudClears=cloudClears+1 end,invalidate=function()end,status='soft clouds'}
local S={new=function(key,label,values)
 local s={value=values[1]};function s:get()return self.value end
 function s:sync(v)self.value=v end;settings[key]=s;return s
end}
local globals=_G.__ds_ceiling_config;local rngCalls=0;local pushes=0;local draws=0
love={math={newRandomGenerator=function()return {random=function()rngCalls=rngCalls+1;return .5 end,setSeed=function()end}end},
 filesystem={write=function()error('host filesystem mutated')end},graphics={push=function()pushes=pushes+1 end,pop=function()pushes=pushes-1 end}}
local R={tint={1,1,1}}
local V={path='test',mod={read=function(_,path)reads=reads+1;return [[local V=...;return {draw=function(s)
 assert(s.map.def.tileset=='OVERWORLD');assert(_G.__ds_ceiling_config().clouds==false,'legacy cloud decks duplicated host clouds');assert(not love.filesystem.write('x','x'))
 math.randomseed(1);math.random();_G.__ds_backdrop_status='drawn';V.require('Voxel3D').tint={0,0,0}
 end,invalidate=function()end}]]end},require=function(n)
 if n=='Clouds'then return clouds elseif n=='Generation'then return{version=function()return version end}elseif n=='KfpBirdArt'then return{clear=function()clears=clears+1 end}elseif n=='Weather'then return {mode=function()return 'clear'end} elseif n=='ModSetting'then return S elseif n=='Voxel3D'then return R elseif n=='NativeAtmosphere'then return {kind=function(m)return m.kind end}end
 error(n)
end}
local K=assert(loadfile('lib/KantoFirstPerson.lua'))(V)
assert(not K.draw({map={def={tileset='OVERWORLD'}}})and reads==0)
assert(K.outdoor({def={environment='TOWN'}}));assert(not K.outdoor({def={environment='INDOOR'}}))
assert(K.outdoor({nativeGeneration=3,nativeType=3,def={}}));assert(not K.outdoor({nativeGeneration=3,nativeType=4,def={}}))
assert(not K.outdoor({nativeGeneration=3,nativeType=3,kind='forest',def={}}))
K.horizon:sync('valley');local tint=R.tint
assert(K.draw({map={def={tileset='OVERWORLD'}},player={px=0,py=0}}))
assert(pushes==0 and R.tint==tint and rngCalls==1 and reads==1)
assert(_G.__ds_ceiling_config==globals and K.status().__ds_backdrop_status=='drawn')
K.horizon:sync('city');K.draw({map={def={tileset='OVERWORLD'}}});assert(reads==2)
assert(not next(K.errors));print('PASS KFP isolation, lazy loading, native classification, live art switching and render-state restoration')

local game={data={}};K.bindGame(game);assert(clears==1 and K.currentGame()==game)
K.bindGame(game);assert(clears==1,'unchanged game clears art every frame')
game.data={};K.bindGame(game);assert(clears==2,'reused game loses new data')
version='crystal';K.bindGame(game);assert(clears==3,'reused game loses new edition')
K.refreshBirds();assert(clears==4,'option refresh fails')
print('PASS native bird cache lifecycle: game identity, data identity, edition and explicit options refresh')
K.sky:sync(true);K.draw({map={def={tileset='OVERWORLD'}}})
assert(cloudDraws==1 and K.status().__ds_cloud_status=='soft clouds','layered sky did not use host cumulus')
K.horizon:sync('off');K.sky:sync(false);local n=cloudClears
assert(not K.draw({map={def={tileset='OVERWORLD'}}})and cloudClears==n+1,'clouds OFF retained current reflection')
K.sky:sync(true);assert(not K.draw({map={def={environment='INDOOR'}}})and cloudDraws==1,'indoor sky leaked')
print('PASS one host cloud path, independent OFF lifecycle and indoor standdown')
