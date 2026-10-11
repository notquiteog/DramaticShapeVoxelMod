local settings={};local reads=0
local S={new=function(key,label,values)
 local s={value=values[1]};function s:get()return self.value end
 function s:sync(v)self.value=v end;settings[key]=s;return s
end}
local globals=_G.__ds_ceiling_config;local rngCalls=0;local pushes=0;local draws=0
love={math={newRandomGenerator=function()return {random=function()rngCalls=rngCalls+1;return .5 end,setSeed=function()end}end},
 filesystem={write=function()error('host filesystem mutated')end},graphics={push=function()pushes=pushes+1 end,pop=function()pushes=pushes-1 end}}
local R={tint={1,1,1}}
local V={path='test',mod={read=function(_,path)reads=reads+1;return [[local V=...;return {draw=function(s)
 assert(s.map.def.tileset=='OVERWORLD');assert(_G.__ds_ceiling_config());assert(not love.filesystem.write('x','x'))
 math.randomseed(1);math.random();_G.__ds_backdrop_status='drawn';V.require('Voxel3D').tint={0,0,0}
 end,invalidate=function()end}]]end},require=function(n)
 if n=='Weather'then return {mode=function()return 'clear'end} elseif n=='ModSetting'then return S elseif n=='Voxel3D'then return R elseif n=='NativeAtmosphere'then return {kind=function(m)return m.kind end}end
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
