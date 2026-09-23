local Shapes=assert(loadfile('lib/Gen3TileShape.lua'))()
local Pairs=assert(loadfile('lib/Gen3Tilesets.lua'))()
package.loaded['src.import.gba.versions']={TILESET_PAIRS={network={primary='building',secondary='pokemon_center'}}}
local M=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(name)assert(name=='Gen3Tilesets');return Pairs end})
assert(not M.profile({tileset='CAVERN',width=5,height=5},1))
assert(not M.profile({environment='CAVE',width=5,height=5},2))
assert(not M.profile({environment='TOWN',width=5,height=5},2))
for _,gen in ipairs({1,2,3})do
 local def={id='VIRIDIAN_MART',tileset='MART',environment='INDOOR',width=6,height=5,mapType=8,
  midLayout={pair='network',midAt=function(_,x,y)return x>0 and x<5 and y<4 and 0x281 or 0 end}}
 local p=assert(M.profile(def,gen));assert(p.theme=='shop')
 if gen==3 then assert(p.bounds[1]==16 and p.bounds[3]==80 and p.bounds[4]==64,'native padding became room floor')end
 local b=p.bounds
 for side=1,6 do for _,open in ipairs({true,false})do
  local v,i=M.geometry(p,side,open);assert(#v>0 and #i>0)
  for _,point in ipairs(v)do
   assert(point[1]>=b[1]-4 and point[1]<=b[3]+4 and point[3]>=b[2]-4 and point[3]<=b[4]+4)
   if side<=4 then
    local outside=side==1 and point[3]<=b[2] or side==2 and point[1]>=b[3]
     or side==3 and point[3]>=b[4] or side==4 and point[1]<=b[1]
    -- Only shallow trim may project into the room, never a solid wall cell.
    assert(outside or point[1]>=b[1]-1 and point[1]<=b[3]+1 and point[3]>=b[2]-1 and point[3]<=b[4]+1)
    if open then assert(point[2]<=0,'cutaway covers player or exit')end
   end
  end
 end end
end
local wallCells={
 ['0:0']={cx=0,cy=0,pair='house',shape={kind='roomWall'}},
 ['1:0']={cx=1,cy=0,pair='house',shape={kind='roomWall'}},
 ['1:1']={cx=1,cy=1,pair='house',shape={kind='roomWall'}},
}
Shapes.layout(wallCells)
local cornice,full=wallCells['0:0'].column,wallCells['1:0'].column
assert(cornice.front==full.front and cornice.walls==full.walls,'wall cornice stretched above a cabinet')
local p=assert(M.profile({id='HOME',tileset='HOUSE',width=4,height=4},1))
for _,aspect in ipairs({.75,1,16/9,21/9})do
 local camera=assert(M.camera(p,math.rad(35),aspect));assert(camera.eye[2]>p.height and camera.curve==0)
end
assert(not M.camera({bounds={0,0,640,640},height=40},math.rad(35),16/9),'large hall should keep scrolling')
local F=assert(loadfile('lib/Gen3Furniture.lua'))()
local objects=0
local recipes={};for _,r in ipairs(F.recipes)do recipes[#recipes+1]=r end
for _,r in ipairs(recipes)do if r.pair=='network' or r.pair=='building__rom_082d4bcc' then
 local cells={}
 for y,row in ipairs(r.rows)do for x,mid in ipairs(row)do
  cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,pair=r.pair,primary='building',ts={}}
 end end
 local list=F.extract(cells);assert(#list==1,'recipe does not claim exactly its drawing: '..r.name)
 local emitted=0
 F.append(list[1],function(points,uv,shade,anchor)
  emitted=emitted+1
  for i,p in ipairs(points)do
   for _,n in ipairs(p)do assert(n==n and math.abs(n)<1000)end
   for _,n in ipairs(uv[i])do assert(n>=0 and n<=1,'UV escapes source art')end
  end
  if r.kind=='plant' then assert(anchor and anchor[3]>0,'plant missing free-camera anchor')end
 end,function()return {{0,0},{1,0},{1,1},{0,1}}end)
 assert(emitted>0);objects=objects+1
end end
assert(objects>=20)
assert(Shapes.of('general','pokemon_center',0x2A0).kind~='interiorFloor','interior profile escaped primary scope')
assert(Pairs.supports({midLayout={pair='network'},mapType=8},{primary='building'}))
-- Shared Building scenes retain the camera; unreviewed art stays flat.
assert(Pairs.supports({midLayout={pair='unknown'},mapType=8},{primary='building'}))
print('PASS interior generation isolation, padding, cutaway bounds and '..objects..' native-art furniture recipes')
