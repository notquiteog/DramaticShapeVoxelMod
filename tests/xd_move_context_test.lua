local M=dofile('lib/XDMoveContext.lua')
local gen=1;package.loaded['src.core.GameVersion']={generation=function()return gen end}
package.loaded['src.battle.Damage']={isSpecial=function(t)return t=='FIRE'end}
local types={DARK=20}
package.loaded['src.battle.gen2.Damage']={isPhysical=function(t,table)assert(table==types);return t~='DARK'end}
assert(M.resolve()== 'attack')
assert(M.resolve({definition={type='FIRE'}})=='special')
assert(M.resolve({definition={type='NORMAL'}})=='attack')
gen=2
assert(M.resolve({definition={type='DARK'},battle={data={type_chart={types=types}}}})=='special')
assert(M.resolve({definition={type='STEEL'},battle={data={type_chart={types=types}}}})=='attack')
gen=3
assert(M.resolve({definition={category='physical'}})=='attack')
assert(M.resolve({definition={category='special'}})=='special')
print('PASS XD move context uses each native generation category')
