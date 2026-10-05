local enabled=false;local V={};local loaded={}
function V.require(k)
 if k=='CommunityVisuals'then return {customRoads=function()return enabled end}end
 if k=='BuildBudget'then return {tick=function()end}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return loaded[k]
end
local ts={cols=2,midToSlot={[0x163]=0,[0x162]=1},imageData={getPixel=function(_,x,y)if x<16 or x%16<8 then return .8,.7,.4,1 else return .2,.7,.3,1 end end}}
local M=V.require('NativeLegendaryRoads');local mask=M.mask(ts,0x162);assert(#mask==1 and mask[1][3]==8 and mask[1][4]==16,'pixel-exact mask or rectangle merging failed')
local c={ts=ts,mid=0x162,cx=2,cy=3,base=16,collision=0,shape={kind='flat'}};local cells={c}
assert(not M.geometry(cells,'FR_LAVENDER_TOWN'));enabled=true;assert(not M.geometry(cells,'FR_PALLET_TOWN'))
local v,i,n=M.geometry(cells,'FR_LAVENDER_TOWN');assert(n==1 and #v>20 and #i==#v)
for _,p in ipairs(v)do assert(p[1]>=32-1e-6 and p[1]<=40+1e-6 and p[3]>=48-1e-6 and p[3]<=64+1e-6,'stone overlaps native grass edge');assert(p[2]>=16 and p[2]<17,'paving became an obstacle')end
c.collision=7;assert(not M.geometry(cells,'FR_LAVENDER_TOWN'));c.collision=0;c.civic={};assert(not M.geometry(cells,'FR_LAVENDER_TOWN'))
print('PASS optional native roads: actual shared stone geometry, exact source mask, merged rectangles, elevation, OFF and solid/building exclusions')
