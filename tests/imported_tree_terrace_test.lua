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
