local enabled=false;local V={};local loaded={}
function V.require(k)
 if k=='CommunityVisuals'then return{customCityGround=function()return enabled end}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end;return loaded[k]
end
local ts={cols=2,midToSlot={[1]=0,[2]=1},imageData={getPixel=function(_,x,y)
 if x<16 or x%16<6 then return .2,.7,.3,1 else return .8,.7,.4,1 end end}}
local c={ts=ts,mid=2,cx=7,cy=3,base=16,collision=0,shape={kind='flat'}}
local M=V.require('NativeCityGround');assert(not M.geometry({c},'FR_LAVENDER_TOWN'));enabled=true
assert(not M.geometry({c},'FR_PALLET_TOWN'));assert(not M.geometry({c},'CUSTOM_LAVENDER'))
for _,id in ipairs{'FR_LAVENDER_TOWN','FR_FUCHSIA_CITY'}do
 local v,i,n=M.geometry({c},id);assert(n==1 and #v==4 and #i==6)
 for _,p in ipairs(v)do assert(p[1]>=112 and p[1]<=118 and p[3]>=48 and p[3]<=64,'native non-turf repainted');assert(p[2]>16 and p[2]<16.03);assert(p[4]>=0 and p[4]<=1 and p[5]>=0 and p[5]<=1)end
end
for _,field in ipairs{'prop','civic','stairs','boundary'}do c[field]=true;assert(not M.geometry({c},'FR_LAVENDER_TOWN'));c[field]=nil end
c.collision=7;assert(not M.geometry({c},'FR_LAVENDER_TOWN'));c.collision=0;c.shape.kind='water';assert(not M.geometry({c},'FR_LAVENDER_TOWN'))
print('PASS native city turf: source pixel mask, elevation, collision/building/water exclusions, stable UV, OFF/custom fallback')

local changes=0;local original=V.require
V.require=function(k)if k=='Generation'then return{isGen3=function()return true end}elseif k=='Gen3Scene'then return{invalidate=function()changes=changes+1 end}end;return original(k)end
local style=V.require('TreePresentation');style.changed('communityCityGround');style.changed('communityTunnels');style.changed('unrelated');assert(changes==2,'native scenery menu did not invalidate changed option')
