local modules={ModelInstances={},BuildBudget={check=function()end},SceneryModelData=dofile('lib/SceneryModelData.lua'),
 TreePresentation={voxel=function()return true end},CommunityVisuals={customTrees=function()return false end,customForest=function()return false end,customSafari=function()return false end}}
local V={mod={read=function(_,p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end}}
function V.require(n)if modules[n]then return modules[n]end;local m=assert(loadfile('lib/'..n..'.lua'))(V);modules[n]=m;return m end
local H,T,S=V.require('Gen3ImportedHoennTrees'),V.require('ImportedTrees'),V.require('SceneryModels')
local function fixture(prefix)
 local bounds={208,1168,240,1200};local region={def={id=prefix..'_ROUTE115'}};local cells={};local rows={{0x1d4,0x1d5},{0x1dc,0x1dd}}
 for yy,row in ipairs(rows)do for xx,mid in ipairs(row)do local x,y=12+xx,72+yy
  cells[x..':'..y]={cx=x,cy=y,mid=mid,primary='general',secondary='fallarbor',pair='general__fallarbor',region=region,
   collision=7,base=xx==1 and 0 or 6,floor={layer=0},shape={kind='tree',treeFamily='round',root=xx==1 and yy==2,treeBounds=bounds}}
 end end
 return cells['13:74'],cells
end
for _,edition in ipairs{'EM','RU','SA'}do
 local root,cells=fixture(edition);assert(H.wholeRoundSlope(root,cells));local list=T.gen3Placements(cells,{region='hoenn'})
 assert(#list==1 and list[1].model=='oras_route104_broadleaf'and list[1].source==root and list[1].y==0,'native trunk datum/source changed')
 assert(not root.importedTree,'planning hid native fallback')
 local parts,fit=assert(S.vertices(list[1].model,list[1].fit));for _,p in ipairs(parts)do for _,v in ipairs(p.vertices)do
  assert(v[1]>=.25 and v[1]<=31.75 and v[3]>=.25 and v[3]<=31.75,'source canopy leaves blocked rectangle')
 end end
 local native={};for k,c in pairs(cells)do native[k]={c.mid,c.collision,c.base,c.floor.layer,c.shape.treeBounds}end
 S.buildBatches=function()return nil,'missing texture'end;assert(not T.buildGen3(cells,function()end,{}, {region='hoenn'})and not root.importedTree,'failed upload claimed tree')
 S.buildBatches=function(_,_,opts)return opts.parts end;assert(T.buildGen3(cells,function()end,{}, {region='hoenn'})and root.importedTree)
 for k,c in pairs(cells)do local n=native[k];assert(c.mid==n[1]and c.collision==n[2]and c.base==n[3]and c.floor.layer==n[4]and c.shape.treeBounds==n[5])end
end
for index,mutate in ipairs{
 function(r,c)c['14:74'].collision=0 end,
 function(r,c)c['14:73'].shape.treeBounds={208,1168,240,1200}end,
 function(r,c)c['14:73'].floor.layer=4 end,
 function(r,c)c['14:74'].base=12 end,
 function(r,c)c['14:74'].base=3 end,
 function(r,c)c['14:73'].mid=0x1ce end,
 function(r,c)c['14:73'].stageHidden=true end,
 function(r,c)c['14:73'].civic={}end,
 function(r,c)c['14:73'].boundary='forest'end,
 function(r,c)c['14:73'].region={}end,
 function(r,c)c['14:73'].shape.treeFamily='ash'end,
 function(r,c)c['14:73'].shape.root=true end,
 function(r,c)c['14:73'].shape.treePalette='gold'end,
 function(r,c)c['14:73']=nil end,
 function(r,c)r.shape.treeBounds[3]=224 end,
 function(r,c)r.shape.root=false end,
}do local root,cells=fixture('EM');mutate(root,cells);assert(not H.wholeRoundSlope(root,cells),'foreign/ambiguous terrace owner accepted '..index)end
local root,cells=fixture('FR');assert(not H.wholeRoundSlope(root,cells,{region='kanto'}),'Kanto source replaced')
print('PASS complete round-tree six-pixel terrace, source/native immutability, atomic upload fallback, no walking/foreign/large-slope substitution')

local stats=S.stats();assert(stats.models>0 and stats.textures==0 and stats.textureBytes==0 and stats.failedImages==0)
local count=stats.models;stats.models=0;assert(S.stats().models==count,'resource diagnostics mutate live accounting')
print('PASS isolated read-only scenery resource accounting')

-- The three remaining Route115 coastal owners have exactly two ground bands
-- separated by12px, with the same complete tree art and low trunk support.
local root,cells=fixture('EM');cells['14:73'].base=12;cells['14:74'].base=12
assert(H.wholeRoundSlope(root,cells))
local list=T.gen3Placements(cells,{region='hoenn'});assert(#list==1 and list[1].y==0 and list[1].model=='oras_route104_broadleaf')
cells['14:73'].base=18;cells['14:74'].base=18;assert(not H.wholeRoundSlope(root,cells),'arbitrary terrain span accepted')
print('PASS exact native twelve-pixel coastal tree owner; unchanged low trunk support; arbitrary spans rejected')

local root,cells=fixture('EM');cells['13:73'].base=12;cells['14:74'].base=12
assert(not H.wholeRoundSlope(root,cells),'unreviewed twelve-pixel diagonal accepted')
root,cells=fixture('EM');cells['13:73'].base=12;cells['13:74'].base=12;cells['14:73'].base=0;cells['14:74'].base=0
assert(not H.wholeRoundSlope(root,cells),'unsupported high-left trunk layout accepted')

root,cells=fixture('EM');cells['14:73'].floor.layer=3;cells['14:74'].floor.layer=3
assert(H.wholeRoundSlope(root,cells),'native blocked layer3 six-pixel owner rejected')
assert(#T.gen3Placements(cells,{region='hoenn'})==1)
cells['14:73'].base=12;cells['14:74'].base=12
assert(not H.wholeRoundSlope(root,cells),'unreviewed layer3 twelve-pixel owner accepted')
print('PASS native blocked layer3 six-pixel tree ownership; twelve-pixel guard remains narrow')

local function forestFixture(depth)
 local b={896,320,928,320+depth};local cells={};local root
 for y=20,19+depth/16 do for x=56,57 do
  local c={cx=x,cy=y,mid=x==56 and 0x1dc or 0x1dd,boundary='forest',primary='general',secondary='rustboro',pair='general__rustboro',base=x==56 and 0 or 6,
   shape={kind='tree',treeFamily='round',root=x==56 and y==20,treeBounds=b}}
  cells[x..':'..y]=c;if c.shape.root then root=c end
 end end
 return root,cells
end
for _,depth in ipairs{16,32}do
 local root,cells=forestFixture(depth);assert(H.forestRoundSlope(root,cells,{region='hoenn'}))
 local p=T.gen3Placements(cells,{region='hoenn'});assert(#p==1 and p[1].model==(depth==16 and H.shallowModel or 'oras_route104_broadleaf')and p[1].y==0)
 assert(not root.importedTree and root.base==0 and cells['57:20'].base==6 and root.collision==nil)
 local parts=assert(S.vertices(p[1].model,p[1].fit));for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do
  assert(v[1]>=.25-1e-6 and v[1]<=31.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=depth-.25+1e-6)
 end end
end
for _,mutate in ipairs{
 function(c)c['57:20'].base=12 end,
 function(c)c['57:20'].base=-6 end,
 function(c)c['57:20'].collision=7;c['57:20'].boundary=nil end,
 function(c)c['57:20'].collision=0 end,
 function(c)c['57:20'].boundary='water' end,
 function(c)c['57:20'].region={}end,
 function(c)c['57:20'].mid=0x1d5 end,
 function(c)c['57:20'].shape.treePalette='gold'end,
 function(c)c['57:20'].shape.root=true end,
 function(c)c['57:20'].shape.treeBounds={896,320,928,352}end,
 function(c)c['57:20'].civic={}end,
}do local root,cells=forestFixture(32);mutate(cells);assert(not H.forestRoundSlope(root,cells,{region='hoenn'}),'unreviewed forest terrace accepted')end
print('PASS exact synthetic DC/DD forest six-pixel owner; full/shallow source body, native/foreign/walking/span exclusions')
