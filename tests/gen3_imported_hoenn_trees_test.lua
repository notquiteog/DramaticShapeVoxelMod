local modules={ModelInstances={},BuildBudget={check=function()end},SceneryModelData=dofile('lib/SceneryModelData.lua')}
local V={mod={read=function(_,p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end}}
function V.require(n)
 if modules[n]then return modules[n]end
 local m=assert(loadfile('lib/'..n..'.lua'))(V);modules[n]=m;return m
end
local M=V.require('Gen3ImportedHoennTrees');local S=V.require('SceneryModels')
local function fixture(depth)
 local b={32,48,48,48+depth};local c,cells=nil,{}
 for y=3,2+depth/16 do
  local q={cx=2,cy=y,mid=y%2==0 and 0xc7 or 0xc6,primary='general',secondary='petalburg',pair='general__petalburg',collision=7,base=4,region={def={id='EM_ROUTE104'}},shape={kind='tree',root=false,treeFamily='conifer',treeBounds=b}}
  cells['2:'..y]=q;c=q
 end
 c.shape.root=true;return c,cells
end
for _,depth in ipairs{16,32}do
 local c,cells=fixture(depth);local p=assert(M.placements(c,cells,{region='hoenn'}));assert(#p==depth/16)
 for _,entry in ipairs(p)do
  assert(entry.source==c and entry.treeInfo==p[1].treeInfo and entry.model==M.model)
  local parts,f=assert(S.vertices(entry.model,entry.fit));assert(f.bounds[5]>19.6 and f.bounds[5]<19.7)
  for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do
   assert(v[1]>=.25-1e-6 and v[1]<=15.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=15.75+1e-6)
   assert(cells[math.floor((entry.x+v[1])/16)..':'..math.floor((entry.z+v[3])/16)].collision==7,'source vertex enters a walking tile')
  end end
 end
 local b=p[1].treeInfo.bounds;assert(b[1]>=32.25 and b[3]<=47.75 and b[2]>=48.25 and b[4]<=48+depth-.25)
 assert(not c.importedTree,'planning hid the fallback before upload')
 for _,mid in ipairs{0x1e,0x1f,0x2e,0x2f,0x3e,0x3f,0xce,0xcf,0x16,0x17,0x239,0x23a,0x243}do
  local before=c.mid;c.mid=mid;assert(not M.placements(c,cells,{region='hoenn'}),'non-whole-crown source accepted');c.mid=before
 end
 local top=cells['2:3']
 for _,field in ipairs{'boundary','prop','civic','stageHidden'}do top[field]=true;assert(not M.placements(c,cells,{region='hoenn'}),field);top[field]=nil end
 for _,field in ipairs{'collision','mid','pair','base'}do
  local before=top[field];top[field]=field=='collision'and 0 or field=='mid'and 0x3e or field=='base'and 20 or'foreign'
  if field~='base'or depth==32 then assert(not M.placements(c,cells,{region='hoenn'}),field)end;top[field]=before
 end
 if depth==32 then local before=top.shape.treeBounds;top.shape.treeBounds={unpack(before)};assert(not M.placements(c,cells,{region='hoenn'}),'foreign owner');top.shape.treeBounds=before end
 c.shape.treeFamily='round';assert(not M.placements(c,cells,{region='hoenn'}));c.shape.treeFamily='conifer'
 c.region.def.id='FR_ROUTE_2';assert(not M.placements(c,cells,{region='kanto'}),'cross-region substitution')
end
local data=V.require('ImportedPineTreeData')[M.model]
assert(#data.parts==4 and #data.parts[1].indices/3==12 and #data.parts[2].indices/3==96)
assert(#data.parts[3].indices/3==12 and #data.parts[4].indices/3==24)
assert(M.policy(M.model).minHeight==18 and not M.policy('oras_route104_broadleaf'))
for r=0,3 do
 local parts,f=assert(S.vertices(M.model,{width=32,depth=32,padding=.25,rotation=r}))
 assert(f.bounds[5]>39.9 and f.bounds[5]<40)
 for i,part in ipairs(parts)do for j,v in ipairs(part.vertices)do
  local original=data.parts[i].vertices[j];assert(v[4]==original[4]and v[5]==original[5],'source UV changed')
  assert(v[1]>=.25-1e-6 and v[1]<=31.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=31.75+1e-6)
 end end
end
print('PASS source evergreen UVs, closed bark, rigid per-crown owner packing, narrow/full fits, native walking clearance, rail/stair/edge exclusions and fallback ownership')
