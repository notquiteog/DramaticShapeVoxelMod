local enabled=false;local V={};local loaded={}
function V.require(k)
 if k=='CommunityVisuals'then return {rocket={get=function()return enabled and'n64memory'or'default'end},elevator={get=function()return enabled and'n64memory'or'default'end}}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return loaded[k]
end
local M=V.require('NativeRocketWalls');local col={indoor=true,first=0,last=1,back=0,front=32,height=32}
local cells={['2:0']={cx=2,cy=0,column=col,collision=7},['2:1']={cx=2,cy=1,column=col,base=16,collision=7},['3:1']={cx=3,cy=1,shape={kind='door'}}}
assert(not M.geometry(cells,'FR_ROCKET_HIDEOUT_B1F'));enabled=true
assert(not M.geometry(cells,'FR_PLAYERS_HOUSE_1F'))
for _,id in ipairs{'FR_ROCKET_HIDEOUT_B1F','FR_ROCKET_HIDEOUT_ELEVATOR'}do
 local v,i,claim=M.geometry(cells,id);assert(#v>100 and #i>0 and claim['2:0']and claim['2:1']and not claim['3:1'])
 for _,p in ipairs(v)do assert(p[1]>=32 and p[1]<=48 and p[2]>=16 and p[2]<=48 and p[3]>=0 and p[3]<=32,'wall escaped blocked native column')end
end
col.stageHidden=true;assert(not M.geometry(cells,'FR_ROCKET_HIDEOUT_B1F'))
print('PASS native Rocket wall kit: shared geometry, OFF/scope, elevation, doorway exclusion and battle culling')
local rows={{0x2eb,0x2e8,0x2e8,0x2e8,0x2ec},{0x2f3,0x2f0,0x2f0,0x2f0,0x2f4},{0x2fb,0x2f8,0x2f8,0x2f8,0x2fc}}
local mural={}
for y,row in ipairs(rows)do for x,mid in ipairs(row)do mural[(x-1)..':'..(y-1)]={mid=mid,collision=7,shape={kind='flat'}}end end
mural['0:1'].collision=0;M.prepare(mural,'FR_ROCKET_HIDEOUT_ELEVATOR');assert(mural['0:0'].shape.kind=='flat','walkable mural must fail closed')
mural['0:1'].collision=7;M.prepare(mural,'FR_ROCKET_HIDEOUT_ELEVATOR');assert(mural['0:0'].shape.kind=='roomWall')
