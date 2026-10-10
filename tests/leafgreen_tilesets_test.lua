local P=dofile('lib/Gen3Tilesets.lua')
local known={pallet_outdoor={primary='general',secondary='pallet_town'}}
P.bind({FR_CERULEAN_CITY={pair='general__rom_082d4ad4'},FR_VIRIDIAN_FOREST={pair='general__rom_082d4da4'},
 FR_VIRIDIAN_CITY_MART={midLayout={pair='building__rom_082d4bac'}}})
assert(P.canonical('general__rom_082d4ad4')=='general__rom_082d4af4')
assert(P.resolve('general__rom_082d4da4',known).secondary=='rom_082d4dc4')
local mart={midLayout={pair='building__rom_082d4bac'},environment='INDOOR'}
assert(P.supports(mart,P.resolve(mart.midLayout.pair,known)),'LeafGreen Mart fell back despite its reviewed artwork')
assert(P.resolve('pallet_outdoor',known).secondary=='pallet_town')
local cave={midLayout={pair='general__unreviewed_cave'},mapType=4}
local spec=P.resolve(cave.midLayout.pair,known)
assert(P.supports(cave,spec) and not P.cave(spec),'unreviewed art must keep shared scene without acquiring reviewed cave geometry')
assert(P.canonical('general__custom')=='general__custom','unknown custom tileset was reclassified')
P.bind({});assert(P.canonical('general__rom_082d4ad4')=='general__rom_082d4ad4','old game aliases survived a new binding')
print('PASS LeafGreen civic/forest/Mart aliases, named pairs, cave/custom isolation and session reset')

local dispose=assert(P.registerAlias('custom_region__mart','building__shop'))
assert(P.canonical('custom_region__mart')=='building__shop')
P.bind({});assert(P.canonical('custom_region__mart')=='building__shop','explicit registration lost on map bind')
assert(not P.registerAlias('custom_region__mart','building__lab'),'another provider replaced owner')
assert(not P.registerAlias('pallet_outdoor','building__lab'),'native family replaced')
assert(not P.registerAlias('building__shop','custom_region__mart'),'alias cycle accepted')
assert(not P.registerAlias('x','x') and not P.registerAlias({},'building__shop'))
assert(dispose() and not dispose(),'disposal must be idempotent')
assert(P.canonical('custom_region__mart')=='custom_region__mart','custom alias leaked after disposal')
print('PASS optional custom-region aliases, owner protection and disposal')
