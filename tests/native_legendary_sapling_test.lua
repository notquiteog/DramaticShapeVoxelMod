local enabled,voxel=false,true
local built,released=0,0;local vertices
local V={};local loaded={}
package.preload['src.core.game3.field_moves']=function()return {GFX_IDS={CUT_TREE=82}}end
function V.require(k)
 if k=='CommunityVisuals'then return {customCutTrees=function()return enabled end}end
 if k=='TreePresentation'then return {voxel=function()return voxel end}end
 if k=='Voxel3D'then return {
 pushQuad=function(t,q)local b=q*4;for _,i in ipairs{1,2,3,1,3,4}do t[#t+1]=b+i end end,
 newMesh=function(v,i)vertices=v;built=built+1;assert(#i>0);return {release=function()released=released+1 end}end}end
 if k=='ReferenceMaterials'then return {encode=function(_,x)return x end}end
 if k=='ShadowMap'then return {snug=function(m)return m end}end
 if not loaded[k]then loaded[k]=assert(loadfile('lib/'..k..'.lua'))(V)end
 return loaded[k]
end
local M=V.require('NativeLegendarySapling');local draws=0
local function draw(mesh,tex,m)draws=draws+1;assert(tex=='native' and m[4]==40 and m[8]==16 and m[12]==56)end
assert(not M.draw(82,32,48,16,'native',draw))
enabled=true;assert(not M.draw(95,32,48,16,'native',draw),'FR identity leaked into Emerald')
voxel=false;assert(not M.draw(82,32,48,16,'native',draw));voxel=true
assert(M.draw(82,32,48,16,'native',draw)and built==1)
for _,p in ipairs(vertices)do assert(math.abs(p[1])<=8 and math.abs(p[3])<=8 and p[2]>=0 and p[2]<=22,'sapling outside source footprint')end
assert(M.draw(82,32,48,16,'native',draw)and built==1)
assert(not M.draw(82,32,48,16,'native',function()error('GPU unavailable')end)and M.lastError)
M.clear();assert(released==1)
print('PASS native Cut sapling: engine identity, OFF/card fallback, footprint, cache and failure fallback')

package.preload['src.world.gen2.Permissions']=function()return {isCutTree=function(c)return c==18 end}end
local S=V.require('LegendarySapling');local coll=18;local map={cellCollision=function()return coll end}
assert(S.gen2(map,0,0));coll=19;assert(not S.gen2(map,0,0),'headbutt tree must retain original shape')
coll=18;enabled=false;assert(not S.gen2(map,0,0));enabled=true;voxel=false;assert(not S.gen2(map,0,0));voxel=true
assert(not S.gen2({},0,0),'Gen1 must keep its registry owner')
