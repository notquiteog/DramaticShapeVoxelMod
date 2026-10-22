local modules={ModelInstances={},BuildBudget={check=function()end},SceneryModelData=dofile('lib/SceneryModelData.lua'),TreePresentation={voxel=function()return true end},CommunityVisuals={customTrees=function()return false end,customForest=function()return false end,customSafari=function()return false end}}
local V={mod={read=function(_,p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end}}
function V.require(n)if modules[n]then return modules[n]end;local m=assert(loadfile('lib/'..n..'.lua'))(V);modules[n]=m;return m end
local H,T,S=V.require('Gen3ImportedHoennTrees'),V.require('ImportedTrees'),V.require('SceneryModels')
local original=V.require('ImportedTreeData').oras_route104_broadleaf
local before={};for i,p in ipairs(original.parts)do before[i]={};for j,v in ipairs(p.vertices)do before[i][j]={unpack(v)}end end
local data=V.require('ImportedCompactTreeData')
for id,d in pairs(data)do
 local narrow=id==H.narrowModel;local depth=narrow and 32 or 16;assert(H.register(id))
 local info=S.info(id);assert(info.parts==#original.parts)
 local f=S.fit(id,{width=16,depth=depth,padding=.25});assert(f.bounds[5]>19.8 and f.bounds[5]<19.9,'compact tree disproportionate to16px NPC')
 assert(f.anchors.canopyBottom[2]>6.7 and f.anchors.canopyBottom[2]<6.9,'bare trunk too tall or buried canopy')
 assert(f.bounds[4]-f.bounds[1]>15.4 and f.bounds[6]-f.bounds[3]>(narrow and 30.9 or 15.4),'compact tree leaves half-empty owner')
 for i,p in ipairs(d.parts)do local source=original.parts[i]
  assert(p.texture==source.texture and p.role==source.role and p.opacity==source.opacity and #p.vertices==#source.vertices and #p.indices==#source.indices)
  for j,index in ipairs(p.indices)do assert(index==source.indices[j],'source closure topology changed')end
  for j,v in ipairs(p.vertices)do local s=source.vertices[j]
   for k=1,6 do assert(s[k]==before[i][j][k],'shared source mutated')end
   assert(v[1]==s[1]and v[4]==s[4]and v[5]==s[5]and v[6]==s[6],'source canopy width/UV/shade changed')
   if p.role=='tree_canopy'then
    local base=original.anchors.canopyBottom[2];assert(math.abs(v[2]-(base+(s[2]-base)*1.25+.20))<1e-8)
    assert(v[3]==s[3]*(narrow and 2 or 1))
   else assert(v[2]==s[2]*1.25 and v[3]==s[3],'tidy trunk depth was squeezed/stretched')end
   if p.colors then for k,n in ipairs(p.colors[j])do assert(n==source.colors[j][k],'source RGBA changed')end end
  end
 end
 -- The original outer bark plus its authored closure remains a closed hull.
 local edges={};for _,i in ipairs{1,3}do local p=d.parts[i]
  local function point(v)return string.format('%.6f,%.6f,%.6f',v[1],v[2],v[3])end
  for j=1,#p.indices,3 do for k=0,2 do local a,b=point(p.vertices[p.indices[j+k]]),point(p.vertices[p.indices[j+(k+1)%3]])
   if a>b then a,b=b,a end;local edge=a..'/'..b;edges[edge]=(edges[edge]or 0)+1
  end end
 end
 for _,count in pairs(edges)do assert(count==2,'compact bark has open topology')end
end
local function fixture(prefix,depth,synthetic)
 local cells={};local bounds={624,816,640,816+depth};local region=not synthetic and{def={id=prefix..'_ROUTE115'}}or nil
 for y=51,50+depth/16 do
  local c={cx=39,cy=y,mid=y==51 and(depth==16 and 0x1e5 or 0x1d4)or 0x1dc,
   collision=not synthetic and 7 or nil,boundary=synthetic and'forest'or nil,base=12,primary='general',secondary='fallarbor',pair='general__fallarbor',region=region,
   floor=not synthetic and{layer=0}or nil,shape={kind='tree',root=y==51,treeFamily='round',treeBounds=bounds}}
  cells['39:'..y]=c
 end
 return cells['39:51'],cells
end
for _,prefix in ipairs{'EM','RU','SA'}do for _,depth in ipairs{16,32}do for _,synthetic in ipairs{false,true}do
 local root,cells=fixture(prefix,depth,synthetic);local opts={region='hoenn'};local list=T.gen3Placements(cells,opts)
 assert(#list==1 and list[1].model==(depth==16 and H.compactModel or H.narrowModel),'compact native adapter unavailable')
 local p=list[1];assert(p.source==root and p.y==root.base)
 local parts,f=S.vertices(p.model,p.fit);for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do
  local c=cells[math.floor((p.x+v[1])/16)..':'..math.floor((p.z+v[3])/16)]
  assert(c and c.shape.treeBounds==root.shape.treeBounds,'compact source escaped owned blocked footprint')
 end end
 local fail=S.buildBatches;S.buildBatches=function()return nil,'missing texture'end;assert(not T.buildGen3(cells,function()end,{},opts)and not root.importedTree,'failure hid native tree')
 S.buildBatches=function(_,_,options)return options.parts end;assert(T.buildGen3(cells,function()end,{},opts)and root.importedTree)
 S.buildBatches=fail
 for _,c in pairs(cells)do assert(c.base==12 and c.collision==(not synthetic and 7 or nil)and c.shape.treeBounds==root.shape.treeBounds,'native ownership/ground changed')end
end end end
for _,mutate in ipairs{
 function(r,c)c['39:52'].collision=0 end,
 function(r,c)c['39:52'].base=18 end,
 function(r,c)c['39:52'].mid=0x16 end,
 function(r,c)c['39:52'].civic={}end,
 function(r,c)c['39:52'].stageHidden=true end,
 function(r,c)c['39:52'].shape.treeBounds={624,816,640,848}end,
 function(r,c)c['39:52'].shape.treePalette='gold'end,
 function(r,c)c['39:52']=nil end,
}do local root,cells=fixture('EM',32);mutate(root,cells);assert(not H.placements(root,cells,{region='hoenn'}),'walking/foreign/source ambiguity accepted')end
print('PASS designed compact full canopy/tidy closed trunk; unchanged ORAS textures/UV/RGBA/topology; all RSE narrow owners; native bounds/levels and atomic fallback')
