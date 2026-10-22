local available=false;local registered={};local placements
local Models={info=function(id)return registered[id]end,
 register=function(id,data,p)assert(data.parts and p.read);registered[id]=true;return true end,
 buildBatches=function(list,newMesh,opts)placements=list;if not available then return nil,'missing source texture'end;return opts.parts end}
local V={mod={read=function()end}}
V.require=function(name)
 if name=='SceneryModels'then return Models end
 return assert(loadfile('lib/'..name..'.lua'))(V)
end
local M=V.require('Gen3ImportedFences')
local function cell(x)return{cx=x,cy=5,base=8,primary='general',secondary='petalburg',mid=0x149,collision=7,ts={layered=true}}end
local c=cell(3);local cells={['3:5']=c};assert(M.eligible(c)=='oras_rural_fence')
for _,k in ipairs{'boundary','prop','civic','stairs','stageHidden'}do c[k]=true;assert(not M.eligible(c),k);c[k]=nil end
for _,k in ipairs{'mid','collision','primary'}do local v=c[k];c[k]=false;assert(not M.eligible(c),k);c[k]=v end
c.ts.layered=false;assert(not M.eligible(c));c.ts.layered=true
local parts={};local result,err,n=M.build(cells,function()end,parts)
assert(not result and err and n==0 and not c.importedFence and not M.floor(c),'failed source hid native drawing')
available=true;result,err,n=M.build(cells,function()end,parts)
assert(result==parts and not err and n==1 and c.importedFence=='oras_rural_fence')
assert(M.floor(c)==1 and M.underOnly(c),'exact original lower grass required')
assert(placements[1].x==48 and placements[1].y==8 and placements[1].z==80)
assert(placements[1].fit.width==16 and placements[1].fit.depth==16 and placements[1].fit.padding==0)
assert(c.collision==7 and c.mid==0x149 and c.base==8)
local d=V.require('ImportedFenceData').oras_rural_fence
local lo={1e9,1e9,1e9};local hi={-1e9,-1e9,-1e9}
for _,p in ipairs(d.parts)do for _,v in ipairs(p.vertices)do for k=1,3 do lo[k]=math.min(lo[k],v[k]);hi[k]=math.max(hi[k],v[k])end end end
assert(lo[1]==0 and hi[1]==16 and lo[2]==0 and hi[2]==10.25 and lo[3]>=0 and hi[3]<=16,'native footprint/height')
local H=V.require('Gen3Hoenn');local R=V.require('Gen3RubySapphire')
assert(H.emeraldShape('general','petalburg',0x149,0,7).nativeFence=='rural149')
assert(R.ownShape('general','petalburg',0x149,0,7).nativeFence=='rural149')
assert(not H.emeraldShape('general','petalburg',0x149,0,0).nativeFence)
print('PASS source-failure atomicity, exact RSE fence/blocked guards, original lower layer, elevation and closed native bounds')
