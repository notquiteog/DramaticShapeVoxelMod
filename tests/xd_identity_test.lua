local M=dofile('lib/XDIdentity.lua')
local version,gen='crystal',2
package.loaded['src.core.GameVersion']={generation=function()return gen end,get=function()return version end}
package.loaded['src.core.gen2.Unown']={letterFromDVs=function(dv)return dv and dv.letter end}
package.loaded['src.core.game3.pokemon']={unownLetter=function(pid)return pid%28 end}
local mon={dvs={letter=26},personality=27};local b={mon=mon}
assert(M.form(201,b)=='25')
assert(M.form(201,{mon={}})=='unresolved-unown')
gen=3;assert(M.form(201,b)=='27')
assert(M.form(201,{mon={personality=0}})=='0')
for name,expected in pairs({ruby='0',sapphire='0',firered='1',leafgreen='2',emerald='3'})do
 version=name;assert(M.form(386,b)==expected)
end
assert(M.form(351,b,{castformMon=mon,castformForm=129})=='castform-1')
assert(M.form(351,b,{castformMon={},castformForm=1})=='default')
assert(M.form(327,b)=='unsupported-pid-spots')
b.transformed=true;assert(M.form(201,b)=='unresolved-transform-form')
assert(M.form(25,b)=='default')
print('PASS XD native forms, unresolved identity, transformed forms and missing markings fallback')
