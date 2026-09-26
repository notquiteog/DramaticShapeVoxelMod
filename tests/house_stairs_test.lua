local Stairs=dofile('lib/InteriorStairs.lua')
local function key(x,z)return(z+64)*4096+x+64 end
for _,name in ipairs({'TILESET_PLAYERS_HOUSE','TILESET_PLAYERS_ROOM'})do
 for _,down in ipairs({true,false})do
  local S={objectQuads={},tileAt={}}
  for y=0,1 do for x=0,1 do S.tileAt[key(x,y)]=x+y*16 end end
  local map={tileset={id=name,tilesPerRow=16,imageWidth=128,imageHeight=128}}
  Stairs.build(S,map,{},0,0,{class=down and 'stair_down_n' or 'stair_n',h=16})
  local treads=0
  for _,q in ipairs(S.objectQuads)do
   if q.interiorStairRole=='house-tread'then treads=treads+1 end
   for i=1,4 do local p=q[i]
    assert(p[1]>=0 and p[1]<=16 and p[3]>=0 and p[3]<=16,'stairs escaped their collision cell')
    assert(down and p[2]<=0 and p[2]>=-8.35 or not down and p[2]>=0 and p[2]<=16.7,'wrong signed flight')
    assert(q.uv[i][1]>=0 and q.uv[i][1]<=1 and q.uv[i][2]>=0 and q.uv[i][2]<=1)
   end
  end
  assert(treads==4,'original drawing has four steps')
 end
end
-- Every GB descending stair/ladder opening must remain open through the
-- room foundation, regardless of its orientation or the game generation.
for gen=1,2 do
 local classes={'stair_down_n','stair_down_e','stair_down_w','ladder_down','stair_n'}
 local Shapes={forMap=function()return{}end,at=function(_,_,_,x)return{class=classes[x/2+1]or'floor'}end}
 local I=assert(loadfile('lib/InteriorDiorama.lua'))({require=function(n)assert(n=='TileShape');return Shapes end})
 local map={def={id='HOUSE',tileset='HOUSE',environment='INDOOR',width=3,height=1},tileset={},widthCells=6,heightCells=1,tileAt=function()return 1 end}
 local p=assert(I.forMap(map,gen));assert(#p.openings==4)
 local vs=I.geometry(p,5,false)
 for i=1,#vs,4 do
  local x,z=0,0;for j=i,i+3 do x=x+vs[j][1]/4;z=z+vs[j][3]/4 end
  assert(not (x>0 and x<64 and z>0 and z<16),'foundation sealed a descending flight')
 end
end
print('PASS Crystal house treads/closed sides and Gen1/2 foundation openings')

-- Crystal house stairs occupy the north wall row: recess only their bay.
local Shapes={forMap=function()return{}end,at=function(_,_,_,x,y)return{class=x==18 and y==0 and 'stair_n' or 'ground'}end}
local I=assert(loadfile('lib/InteriorDiorama.lua'))({require=function()return Shapes end})
local p=I.forMap({def={id='PLAYERS_HOUSE_1F',tileset='TILESET_PLAYERS_HOUSE',environment='INDOOR',width=5,height=4},tileset={},tileAt=function()return 76 end},2)
assert(p.northFront==15.7 and #p.northRecesses==1 and p.bounds[2]==-.3)
local vs=I.geometry(p,1,false)
for i=1,#vs,4 do
 local x,y,z=0,0,0;for j=i,i+3 do x=x+vs[j][1]/4;y=y+vs[j][2]/4;z=z+vs[j][3]/4 end
 assert(not(x>145 and x<159 and z>3 and z<17 and y>1 and y<35),'north wall still hides the staircase')
end
print('PASS recessed north-wall stair bay with closed returns')

local G=assert(loadfile('lib/Gen2DesignedFurniture.lua'))({})
local S={objectQuads={},shapeAt={[64*4096+18+64]={art='stair'}}}
G.backing(S,{tileset={id='TILESET_PLAYERS_HOUSE'},def={width=5}},16,128,128)
assert(#S.objectQuads==20)
for _,q in ipairs(S.objectQuads)do assert(q[1][3]==(q[1][1]>=144 and -.1 or 15.9),'wallpaper sealed staircase')end
print('PASS native wallpaper stays behind the stair bay')
