local cached={};local V={}
function V.require(k)
 if k=='Gen3Hoenn'then return {active=function()return false end}end
 if not cached[k]then cached[k]=assert(loadfile('lib/'..k..'.lua'))(V)end
 return cached[k]
end
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
local S=V.require('Gen3TileShape');local F=dofile('lib/Gen3Forest.lua')
local cells={}
for y,mid in ipairs{0x2FE,0x306,0x30E}do
 local shape=S.of('general','rom_082d4b54',mid,0,7)
 assert(shape.safariTree and shape.treeRows[4][2]==0x30E)
 cells['1:'..y]={cx=1,cy=y,mid=mid,pair='safari',shape=shape}
end
assert(F.prepare(cells)==1 and cells['1:1'].shape.root and not cells['1:3'].shape.root,'one owner per full crown')
assert(cells['1:1'].shape.anchorZ==40)
for _,mid in ipairs{0x2FC,0x304,0x31A,0x324,0x32A}do
 assert(not S.of('general','rom_082d4b54',mid,0,7).safariTree,'shore/edge composites consumed')
end
assert(not S.of('general','rom_082d4af4',0x2FE,0,7).safariTree,'unrelated tileset consumed')
print('PASS Safari native tree rows, one crown owner, composite and tileset isolation')
