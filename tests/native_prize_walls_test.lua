local enabled=true;local cache={};local V={require=function()end}
function V.require(k)
 if k=='CommunityVisuals'then return{prizeRoom={get=function()return enabled and'n64memory'or'default'end}}end
 if not cache[k]then cache[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return cache[k]
end
local M=V.require('NativePrizeWalls');local cells={['2:0']={collision=7},['2:1']={cx=2,cy=1,collision=7,base=3,column={indoor=true,first=0,last=1,back=0,front=32,height=48}}}
local vs,ix,claims,n=M.geometry(cells,'FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM');assert(n==1 and #vs>80 and #ix>100 and claims['2:0'])
for _,p in ipairs(vs)do assert(p[1]>=32 and p[1]<=48 and p[2]>=3 and p[2]<=51 and p[3]>=0 and p[3]<=32)end
cells['2:0'].collision=0;assert(not M.geometry(cells,'FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM'));cells['2:0'].collision=7
enabled=false;assert(not M.geometry(cells,'FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM'));enabled=true;assert(not M.geometry(cells,'CUSTOM_REGION'))
local native={['1:0']={cx=1,cy=0,mid=0x285,collision=7},['1:1']={cx=1,cy=1,mid=0x28d,collision=7},['1:2']={cx=1,cy=2,mid=0x2c4,collision=0}}
assert(M.geometry(native,'FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM'))
native['1:0'].mid=0;assert(not M.geometry(native,'FR_CELADON_CITY_GAME_CORNER_PRIZE_ROOM'))
print('PASS native Prize Room shared wall panels, source palette, blocked columns, OFF/custom fallbacks')
