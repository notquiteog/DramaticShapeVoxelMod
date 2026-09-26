local P=dofile('lib/Gen3Tilesets.lua')
local S=dofile('lib/Gen3TileShape.lua')
local T=dofile('lib/Gen3Terrain.lua')
package.loaded['src.core.game3.collision']={isSurfable=function(b)return b==0x11 end}
local palettes={'rom_082d4bfc','rom_082d4df4','rom_082d4e0c','rom_082d4e24','rom_082d501c'}
for _,secondary in ipairs(palettes)do
 local spec={primary='general',secondary=secondary}
 assert(P.supports({midLayout={},mapType=4},spec))
 assert(S.of('general',secondary,0x291,8,7).kind=='caveWall')
 assert(S.of('general',secondary,0x291,8,43).kind=='flat','walkable rock cap raised')
 for _,mid in ipairs({0x285,0x286,0x287,0x294,0x296,0x297,0x2AF})do
  local ladder=S.of('general',secondary,mid,0x61,114)
  assert(ladder.kind=='ladder' and ladder.ground==0x281,'semantic ladder lost its floor opening')
 end
 assert(S.of('general',secondary,0x282,0,7).kind=='rock')
 assert(S.of('general',secondary,0x281,8,43).reviewedSurface)
 assert(S.of('general',secondary,0x2CB,0x11,41).kind=='water')
 assert(S.of('general',secondary,0x3FF,0,7).kind=='flat','unknown blocked art guessed as wall')
end
assert(P.supports({midLayout={},mapType=4},{primary='general',secondary='unreviewed'}),'unknown art disabled the entire camera')
assert(S.of('general','unreviewed',0x3FF,0,7).kind=='flat','unknown art gained invented geometry')
local cells={}
for y=-1,2 do for x=-1,2 do
 local raised=x>=0 and x<=1 and y>=0 and y<=1
 cells[x..':'..y]={cx=x,cy=y,shape=S.of('general',palettes[1],raised and 0x291 or 0x281,8,raised and 7 or 43)}
end end
assert(T.height(cells,16,16,28)==28)
assert(T.height(cells,0,8,28)==0)
local samples={}
T.append(cells,cells['0:0'],function(v)
 for _,p in ipairs(v)do assert(p[2]>=0 and p[2]<=28)end
end,function(_,mid)samples[mid]=true;return {{0,0},{1,0},{1,1},{0,1}}end)
assert(samples[0x291]and samples[0x299]and not samples[113],'cave borrowed outdoor cliff artwork')
P.bind({FR_ROCK_TUNNEL_1F={midLayout={pair='general__leafgreen_cave'}}})
assert(P.resolve('general__leafgreen_cave',{}).secondary=='rom_082d4df4')
print('PASS cave palettes, native walkability, ladder/entrance preservation, water, unknown-art fallback, cap geometry and LeafGreen aliases')
