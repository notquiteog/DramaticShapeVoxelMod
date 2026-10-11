local enabled=true;local V={};local cache={}
function V.require(k)
 if k=='CommunityVisuals'then return{referenceBuildings=function()return enabled end}end
 if k=='Gen3Civic'then return{profile=function()return{w=64,back=8,front=63}end}end
 if not cache[k]then cache[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return cache[k]
end
local M=V.require('NativeLegendaryBuildings');local g={cx=2,cy=3,width=4,depth=4,family='vermilion_shed',bodyBack=18,groundHeight=8}
local cells={};for y=3,6 do for x=2,5 do cells[x..':'..y]={collision=7}end end
local def={id='FR_VERMILION_CITY',warps={{x=3,y=6}}};cells['3:6'].collision=0
local v,ix,names,spec=M.geometry(g,def,cells);assert(v and #ix>100 and #names>1 and spec.doors[1].x==24)
for _,p in ipairs(v)do if p[2]<32 then assert(p[1]>=32 and p[1]<=96 and p[3]>=66 and p[3]<=111,'low model leaves blocked native body')end end
local door=M.doorSurface({placement=g,legendaryBuilding=spec},3,6);assert(door and door.sourceX==48 and door.sourceY==96 and door.base==8 and door.vertices[1][2]==25)
assert(not M.doorSurface({placement=g,legendaryBuilding=spec},4,6))
cells['2:5'].collision=0;assert(not M.geometry(g,def,cells));cells['2:5'].collision=7
def.warps={};assert(not M.geometry(g,def,cells));def.warps={{x=3,y=6}}
def.id='CUSTOM_VERMILION';assert(not M.geometry(g,def,cells));def.id='FR_VERMILION_CITY'
enabled=false;assert(not M.geometry(g,def,cells))
print('PASS native shared buildings: true authored geometry, solid-body gate, native doors, warp/source/default fallback')
