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
 for _,mid in ipairs{0x1e,0x1f,0x2e,0x2f,0x3e,0x3f,0xcf,0x16,0x17,0x239,0x23a,0x243}do
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
assert(#data.parts==5 and #data.parts[1].indices/3==12 and #data.parts[2].indices/3==96)
assert(#data.parts[3].indices/3==12 and #data.parts[4].indices/3==24)
assert(data.parts[5].name=='canopy_rotated_inset_completion'and #data.parts[5].indices/3==96)
assert(M.policy(M.model).minHeight==18 and not M.policy('oras_route104_broadleaf'))
for r=0,3 do
 local parts,f=assert(S.vertices(M.model,{width=32,depth=32,padding=.25,rotation=r}))
 assert(f.bounds[5]>39.9 and f.bounds[5]<40)
 for i,part in ipairs(parts)do for j,v in ipairs(part.vertices)do
  local original=data.parts[i].vertices[j];assert(v[4]==original[4]and v[5]==original[5],'source UV changed')
  assert(v[1]>=.25-1e-6 and v[1]<=31.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=31.75+1e-6)
 end end
end
-- Actual 016/017 lower foliage/trunks are not round-tree source art. Only
-- accept a single blocked base beneath its own walkable projected 00E/F cap.
for _,mid in ipairs{0x16,0x17}do
 local b={32,48,48,64};local c={cx=2,cy=3,mid=mid,primary='general',secondary='petalburg',pair='general__petalburg',collision=7,base=4,
  region={mapId='EM_ROUTE103'},shape={kind='tree',root=true,treeFamily='round',treeRows={{mid}},treeBounds=b}}
 local above={cx=2,cy=2,mid=0xf,primary='general',secondary=c.secondary,pair=c.pair,collision=0,base=4,
  shape={kind='tree',root=false,treeFamily='conifer'}}
 local cells={['2:3']=c,['2:2']=above};local p=assert(M.placements(c,cells));assert(#p==1 and p[1].model==M.model and p[1].source==c)
 assert(p[1].x==32 and p[1].z==48 and p[1].treeInfo.bounds[2]>=48.25,'walking cap acquired geometry')
 assert(above.shape.treeBounds==nil and not above.importedTree and c.shape.treeFamily=='round','native ownership/classification changed')
 above.collision=7;assert(not M.placements(c,cells),'blocked canopy and trunk could represent the same imported tree');above.collision=0
 above.mid=0xc7;assert(not M.placements(c,cells),'dense front row gained duplicate pine');above.mid=0xf
 above.shape.root=true;assert(not M.placements(c,cells),'independent tree owner above ignored');above.shape.root=false
 above.civic={};assert(not M.placements(c,cells),'foreign cap owner');above.civic=nil
 cells['2:2']=nil;assert(not M.placements(c,cells),'unverified projected cap guessed')
end
-- The shallow broadleaf is an explicit source-depth edit, not a miniature
-- uniformly fitted tree: X/Y and source UV/RGBA/topology remain intact.
local broad=V.require('ImportedTreeData')[M.shallowSource.model];local originalZ={}
for i,p in ipairs(broad.parts)do originalZ[i]={};for j,v in ipairs(p.vertices)do originalZ[i][j]=v[3]end end
local function shallowFixture(x)
 local b={x*16,48,x*16+32,64};local cells={}
 for xx=x,x+1 do cells[xx..':3']={cx=xx,cy=3,mid=xx==x and 0x1d4 or 0x1d5,primary='general',secondary='petalburg',pair='general__petalburg',collision=7,base=4,
  region={def={id='EM_PETALBURG_CITY'}},shape={kind='tree',root=xx==x,treeFamily='round',treeBounds=b}}end
 return cells[x..':3'],cells
end
for _,x in ipairs{2,3}do
 local c,cells=shallowFixture(x);local p=assert(M.placements(c,cells));assert(#p==1 and p[1].model==M.shallowModel)
 local entry=p[1];assert(entry.fit.rotation==0 or entry.fit.rotation==2)
 local parts,f=assert(S.vertices(entry.model,entry.fit));assert(f.bounds[4]-f.bounds[1]>30.9 and f.bounds[6]-f.bounds[3]>15.4)
 assert(f.bounds[5]>28 and f.bounds[5]<28.5,'native width/height shrank with source depth')
 for i,part in ipairs(parts)do
  local source=broad.parts[i];assert(part.texture==source.texture and #part.indices==#source.indices and part.opacity==source.opacity)
  for j,n in ipairs(part.indices)do assert(n==source.indices[j],'closure topology changed')end
  for j,v in ipairs(part.vertices)do local original=source.vertices[j]
   assert(original[3]==originalZ[i][j],'shared full-depth source mutated')
   assert(v[4]==original[4]and v[5]==original[5]and v[6]==original[6],'source UV/shade changed')
   assert(math.abs(v[2]-original[2]*f.scale)<1e-6,'source vertical proportions changed')
   if source.colors then for k=1,4 do assert(v[k+6]==source.colors[j][k],'source vertex RGBA changed')end end
   assert(v[1]>=.25-1e-6 and v[1]<=31.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=15.75+1e-6)
   assert(cells[math.floor((entry.x+v[1])/16)..':'..math.floor((entry.z+v[3])/16)].collision==7,'shallow source enters walking cell')
  end
 end
 local other=cells[(x+1)..':3'];other.collision=0;assert(not M.placements(c,cells),'walking broadleaf corner');other.collision=7
 other.mid=0x16;assert(not M.placements(c,cells),'mixed evergreen source borrowed');other.mid=0x1d5
 other.base=12;assert(not M.placements(c,cells),'shallow source spans elevations');other.base=4
 other.prop={};assert(not M.placements(c,cells),'foreign prop consumed');other.prop=nil
 c.shape.treePalette='gold';assert(not M.placements(c,cells),'specialized palette substituted');c.shape.treePalette=nil
 c.shape.treeFamily='sapling';assert(not M.placements(c,cells),'sapling substituted')
end
assert(M.policy(M.shallowModel).minHeight==27.5 and not M.register('unknown_source'))
-- The last canopy and exposed trunk are one front tree, including the
-- cliff-clipped CE cap. Earlier overlapping canopy rows stay separate trees.
for _,depth in ipairs{16,32}do for _,cap in ipairs{0xc7,0xce}do
 local c,cells=fixture(depth);local b=c.shape.treeBounds
 cells['2:3'].mid=cap
 local y=3+depth/16;local tb={32,y*16,48,(y+1)*16}
 local trunk={cx=2,cy=y,mid=0x16,primary=c.primary,pair=c.pair,secondary=c.secondary,base=4,collision=7,region=c.region,
  shape={kind='tree',root=true,treeFamily='round',treeBounds=tb}}
 cells['2:'..y]=trunk
 local p=assert(M.placements(c,cells,{region='hoenn'}));assert(#p==depth/16,'extra front pine duplicated native tree')
 local tail=p[#p];assert(tail.model==M.foregroundModel and tail.fit.width==16 and tail.fit.depth==32)
 assert(tail.sources[1]==c and tail.sources[2]==trunk and tail.sourceTreeInfos[c]==tail.treeInfo)
 assert(#assert(M.placements(trunk,cells,{region='hoenn'}))==0,'trunk owner emitted duplicate source tree')
 assert(not c.importedTree and not trunk.importedTree,'planning suppressed native fallback before upload')
 assert(c.shape.treeBounds==b and trunk.shape.treeBounds==tb and c.shape.treeFamily=='conifer'and trunk.shape.treeFamily=='round','native owner bounds changed')
 local parts,f=assert(S.vertices(tail.model,tail.fit));assert(f.bounds[5]>19.6 and f.bounds[5]<19.7)
 assert(f.bounds[4]-f.bounds[1]>15.4 and f.bounds[6]-f.bounds[3]>25.6,'merged native body left half empty')
 assert(tail.fit.rotation==0 or tail.fit.rotation==2)
 for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do
  local q=assert(cells[math.floor((tail.x+v[1])/16)..':'..math.floor((tail.z+v[3])/16)])
  assert(q.collision==7 and(q.shape.treeBounds==b or q.shape.treeBounds==tb),'foreground entered walking/foreign cell')
 end end
 local masterInfo,lowerInfo=tail.sourceTreeInfos[c],tail.sourceTreeInfos[trunk]
 assert(masterInfo.bounds[2]<=lowerInfo.bounds[2]and masterInfo.bounds[4]>=lowerInfo.bounds[4])
 for _,field in ipairs{'prop','civic','stageHidden','boundary'}do
  trunk[field]=true;local old=assert(M.placements(c,cells,{region='hoenn'}));assert(old[#old].model==M.model and not old[#old].sources,'conflicted trunk group consumed');trunk[field]=nil
 end
 trunk.base=10;assert(M.placements(c,cells,{region='hoenn'})[#p].model==M.model,'unequal group levels flattened');trunk.base=4
 trunk.shape.treePalette='gold';assert(M.placements(c,cells,{region='hoenn'})[#p].model==M.model,'specialized group replaced');trunk.shape.treePalette=nil
 trunk.collision=0;assert(M.placements(c,cells,{region='hoenn'})[#p].model==M.model,'walkable trunk acquired merged tree');trunk.collision=7
end end
-- Added canopy uses exactly the source UV stream. The tiny inset prevents
-- coincident foliage surfaces; all original108triangles remain first.
local leaf,completion=data.parts[2],data.parts[5]
assert(#leaf.vertices==#completion.vertices)
for i,v in ipairs(completion.vertices)do
 assert(v[4]==leaf.vertices[i][4]and v[5]==leaf.vertices[i][5],'canopy completion invented UVs')
end
print('PASS source evergreen packing, safe projected-cap trunks, full shallow broadleaf bodies, unchanged UV/RGBA/closures and native walking/owner/fallback guards')

-- Boundary-fill forest already has explicit blocked ownership in ImportedTrees.
-- It may use the same reviewed full shallow body, without pretending that its
-- synthetic cells carry native permission7. A reviewed native boundary join
-- is permitted only inside the same complete owner; walking cells stand down.
local root,cells=shallowFixture(2)
for _,q in pairs(cells)do q.boundary='forest';q.collision=nil;q.region=nil end
local plans=assert(M.placements(root,cells,{region='hoenn'}));assert(#plans==1 and plans[1].model==M.shallowModel)
assert(cells['3:3'].collision==nil and cells['3:3'].boundary=='forest')
cells['3:3'].collision=7;cells['3:3'].boundary=nil;assert(M.placements(root,cells,{region='hoenn'}),'blocked native forest join rejected')
cells['3:3'].collision=0;assert(not M.placements(root,cells,{region='hoenn'}),'walking native join accepted')
cells['3:3'].collision=nil;cells['3:3'].boundary='water';assert(not M.placements(root,cells,{region='hoenn'}),'water boundary became tree')
print('PASS full forest shallow body, blocked native joins and walking/water standdown')
