local field={cells={['1:0']={height=60},['2:2']={height=72,high=78}}}
local modules={Gen3Tilesets={resolve=function()return{primary='general',secondary='cave'}end},
 Gen3TileShape={of=function()return{kind='flat'}end},
 Gen3Elevation={field=function()return field end},Gen2Elevation={field=function()return field end}}
package.loaded['src.import.gba.versions']={TILESET_PAIRS={}}
package.loaded['src.core.game3.scripting.interaction_scripts']={behaviors={}}
local M=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(n)return assert(modules[n],n)end})
for gen=1,3 do
 local def={tileset='CAVERN',environment='CAVE',mapType=4,width=4,height=4,warps={{x=1,y=0}},
  midLayout={pair='cave',cellAt=function(_,x,y)return{coll=y==0 and 0 or 7}end}}
 local map={def=def,isWalkableCell=function(_,x,y)return y==0 end}
 local p=assert(M.forMap(map,gen));assert(p.cave and p.theme=='cave')
 assert(not M.camera(p,.6,16/9),'cave stole the scrolling camera')
 assert(p.bounds[1]==0 and p.bounds[2]==0,'cave padding incorrectly trimmed')
 if gen~=1 then assert(p.height==142,'ceiling intersected a raised platform')end
 assert(#p.passages[1]==1 and #p.passages[2]==0,'boundary exit sealed or invented')
 local floor=gen==1 and 0 or 60
 local wall,indices=M.geometry(p,1,false);assert(#indices>0)
 for i=1,#wall,4 do local q=wall[i];local cx=(q[1]+wall[i+2][1])/2;local y=(q[2]+wall[i+2][2])/2
  assert(not(cx>16 and cx<32 and y>floor and y<floor+32),'stone face fills exit opening')
 end
 for side=1,6 do local v=assert(M.geometry(p,side,false));assert(#v>0)
  for _,q in ipairs(v)do assert(q[2]>=-4 and q[2]<=p.height)end
 end
 for side=1,4 do for _,q in ipairs(M.geometry(p,side,true))do assert(q[2]<=0,'cutaway hides the map')end end
end
assert(not M.profile({tileset='OVERWORLD',width=8,height=8},1))
assert(not M.profile({environment='ROUTE',width=8,height=8},2))
assert(not M.profile({mapType=1,width=8,height=8},3))
assert(M.profile({environment='CAVE',tileset='TILESET_ICE_PATH',width=8,height=8},2).theme=='ice')
-- Native cave finish chooses the dominant actual wall drawing, composes one
-- material, and leaves foundation/ceiling ownership with their normal theme.
local material={};local requested
modules.Gen3TileShape.of=function(_,_,mid)return mid==0x389 and{kind='caveWall',side=mid}or{kind='flat'}end
modules.Gen3RoomWallpaper={material=function(d,ts)requested=d.voxelWallpaper;assert(ts.native);return material end}
modules.Gen3CaveShell=dofile('lib/Gen3CaveShell.lua')
package.loaded['src.core.game3.tileset_native']={get=function()return{native=true}end}
local def={id='QA_NATIVE_ICE',mapType=4,width=4,height=4,midLayout={pair='cave',cellAt=function(_,x,y)return{mid=0x389,coll=7}end}}
local p=assert(M.forMap({def=def},3))
assert(p.nativeCaveFinish and p.wallpaper==material and p.wallpaperHeight==28)
assert(requested[1]==0x389 and requested[2]==0x389 and requested.single==true)
assert(p.shellTexture==nil,'wall UV must not leak into floor foundation/ceiling')
for side=1,4 do local v,i=M.geometry(p,side,false);assert(#v>0 and #i>0)end
print('PASS all-generation cave walls, terrace clearance, boundary passages, cutaway and outdoor exclusion')
