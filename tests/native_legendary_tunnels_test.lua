local enabled=true;local V={}
V.require=function(name)
 if name=='CommunityVisuals'then return{tunnels={get=function()return enabled and'n64memory'or'original'end}}end
 if name=='UndergroundRoom'then return assert(loadfile('lib/UndergroundRoom.lua'))(V)end
 error(name)
end
local M=assert(loadfile('lib/NativeLegendaryTunnels.lua'))(V)
local cells={}
local function cell(x,y,collision,kind)local c={cx=x,cy=y,collision=collision,shape={kind=kind or'flat'}};cells[x..':'..y]=c;return c end
cell(0,0,0);local stair=cell(1,0,0,'steps');stair.stairs={}
cell(2,0,7);local wall=cell(2,1,7,'roomWall');wall.column={indoor=true,first=0,last=1,back=0,front=32,height=40}
local a,b,claims,count=M.geometry(cells,'FR_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL')
assert(a and #b>0 and count.floors==1 and count.walls==1)
assert(claims['2:0']and claims['2:1']and not claims['0:0']and not claims['1:0'])
for _,p in ipairs(a)do
 assert(p[2]>=0 and p[2]<=40)
 assert(p[1]>=0 and p[1]<=48 and p[3]>=0 and p[3]<=32)
 assert(p[1]<=16 or p[1]>=32,'geometry enters stair cell')
end
cells['2:0'].collision=0
local _,_,cl,n=M.geometry(cells,'FR_UNDERGROUND_PATH_EAST_WEST_TUNNEL');assert(n.walls==0 and not next(cl),'walkable column claimed')
wall.column.stageHidden=true;cells['2:0'].collision=7
local _,_,_,n=M.geometry(cells,'FR_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL');assert(n.walls==0)
local strip={['0:0']={cx=0,cy=0,collision=7,shape={kind='flat'}},['1:0']={cx=1,cy=0,collision=0,shape={kind='flat'}}}
local v,_,owned,num=M.geometry(strip,'FR_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL');assert(owned['0:0']and num.walls==1 and num.floors==1)
for _,p in ipairs(v)do if p[2]>.06 then assert(p[1]>=12 and p[1]<=16 and p[3]>=0 and p[3]<=16,'side wall leaves solid footprint')end end
strip['0:0'].stairs={};local _,_,owned,num=M.geometry(strip,'FR_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL');assert(not next(owned)and num.walls==0)
enabled=false;assert(not M.geometry(cells,'FR_UNDERGROUND_PATH_NORTH_SOUTH_TUNNEL'))
enabled=true;assert(not M.geometry(cells,'CUSTOM_TUNNEL'));assert(not M.geometry(cells,'EM_RUSTURF_TUNNEL'))
print('PASS native Legendary tunnels: boundaries, stairs, walkable cells, hidden walls, OFF/custom fallback')
