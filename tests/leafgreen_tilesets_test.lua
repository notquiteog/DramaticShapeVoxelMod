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
assert(not P.supports(cave,P.resolve(cave.midLayout.pair,known)),'edition matching enabled an unreviewed cave')
assert(P.canonical('general__custom')=='general__custom','unknown custom tileset was reclassified')
P.bind({});assert(P.canonical('general__rom_082d4ad4')=='general__rom_082d4ad4','old game aliases survived a new binding')
print('PASS LeafGreen civic/forest/Mart aliases, named pairs, cave/custom isolation and session reset')
