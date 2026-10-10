local layout='default';local uploaded;local V={};local cache={}
local settings={customPillars=function()return layout~='default'end,layout=function()return layout end,pillarColor=function()return'granite'end}
local gpu={newMesh=function(v,i)uploaded=v;return{vertices=v,release=function()end}end}
function V.require(k)
 if k=='CommunityVisuals'then return settings end
 if k=='Voxel3D'then return gpu end
 cache[k]=cache[k]or assert(loadfile('lib/'..k..'.lua'))(V);return cache[k]
end
local M=V.require('NativeLegendaryPillars');local P=V.require('GranitePillars')
P.textures.granite={};P.mask={}
local function cell(x,z,wood,collision)return{cx=x,cy=z,collision=collision,base=4,shape={kind='fence',wood=wood}}end
local cells={['0:0']=cell(0,0,false,1),['1:0']=cell(1,0,false,1),['2:0']=cell(2,0,true,1),['0:1']=cell(0,1,false,0)}
assert(not M.build(cells,'FR_FUCHSIA_CITY'))
for _,l in ipairs{'separate','bottom','top'}do layout=l
 local record=assert(M.build(cells,'FR_FUCHSIA_CITY'));assert(record.claims['0:0']and record.claims['1:0'])
 assert(not record.claims['2:0']and not record.claims['0:1'],'wood/walkable cells claimed')
 for _,v in ipairs(uploaded)do assert(v[1]>=0 and v[1]<=32 and v[3]>=0 and v[3]<=16,'pillar extends into walkable lane');assert(v[2]>=4,'lost native elevation')end
end
cells['0:0'].stageHidden=true;cells['1:0'].prop={};assert(not M.build(cells,'FR_FUCHSIA_CITY'),'battle-cleared or prop-owned cell claimed')
assert(not M.build(cells,'NEW_BARK_TOWN'),'Gen1/2 fallback altered')
local draws=0;gpu.glassMask='old';gpu.glassMaskNow=function(x)gpu.glassMask=x end;gpu.glass=function()end
assert(P.drawNative({mesh={},image={},mask='new'},function()assert(gpu.glassMask=='new');draws=draws+1 end))
assert(draws==1 and gpu.glassMask=='old','scene draw callback or mask restore missing')
assert(not pcall(P.drawNative,{mesh={},image={},mask='new'},function()error('draw failed')end));assert(gpu.glassMask=='old','failed draw leaked mask')
print('PASS native Legendary pillar layouts, bounded solid-cell ownership, elevation, OFF/wood/props/battle fallback and draw callback')
