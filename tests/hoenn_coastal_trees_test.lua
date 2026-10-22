local edition='emerald'
package.loaded['src.core.GameVersion']={get=function()return edition end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
local modules={ModelInstances={},BuildBudget={check=function()end},SceneryModelData=dofile('lib/SceneryModelData.lua'),TreePresentation={voxel=function()return true end},CommunityVisuals={customTrees=function()return false end,customForest=function()return false end,customSafari=function()return false end}}
local V={mod={read=function(_,p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end}}
function V.require(n)if modules[n]then return modules[n]end;local m=assert(loadfile('lib/'..n..'.lua'))(V);modules[n]=m;return m end
local H,S,F,T,Models=V.require('Gen3ImportedHoennTrees'),V.require('Gen3TileShape'),V.require('Gen3TreeFootprints'),V.require('ImportedTrees'),V.require('SceneryModels')
local function fixture(rows,x)
 x=x or 2;local cells={};local region={def={id=({emerald='EM',ruby='RU',sapphire='SA'})[edition]..'_DEWFORD_TOWN'}}
 for y,mid in ipairs(rows)do local c={cx=x,cy=y+2,mid=mid,collision=7,base=6,primary='general',secondary='dewford',pair='general__dewford',region=region,floor={layer=0},shape=S.of('general','dewford',mid,0,7)}
  cells[x..':'..(y+2)]=c;assert(c.shape.kind=='tree'and c.shape.ground==0x124)
 end
 F.prepare(cells,edition);return cells
end
for _,game in ipairs{'emerald','ruby','sapphire'}do edition=game
 for _,pattern in ipairs{{{0x243},1},{{0x239,0x243},2},{{0x243,0x243},2},{{0x243,0x23a},1},{{0x243,0x243,0x23a},2}}do
  for x=2,5 do local cells=fixture(pattern[1],x);local plans=T.gen3Placements(cells,{region='hoenn'});assert(#plans==pattern[2],'coastal crown/trunk count '..game)
   local claimed={};for _,p in ipairs(plans)do
    assert(p.model==H.model or p.model==H.foregroundModel);assert(p.y==6)
    for _,c in ipairs(p.sources or{p.source})do claimed[c]=true end
    local parts=assert(Models.vertices(p.model,p.fit))
    for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do local q=cells[math.floor((p.x+v[1])/16)..':'..math.floor((p.z+v[3])/16)]
     assert(q and q.collision==7,'coastal source leaves blocked footprint')
    end end
   end
   for _,c in pairs(cells)do assert(c.base==6 and c.collision==7 and c.shape.ground==0x124 and not c.importedTree);if c.shape.root then assert(claimed[c],'coastal native owner remains uncovered')end end
  end
 end
 -- A walking native239 projection above23A remains sand and gains no tree.
 local cells=fixture{0x23a};local c=cells['2:3'];cells['2:2']={cx=2,cy=2,mid=0x239,collision=0,base=6,primary='general',secondary=c.secondary,pair=c.pair,region=c.region,shape=S.of('general','dewford',0x239,0,0)}
 local p=T.gen3Placements(cells,{region='hoenn'});assert(#p==1 and p[1].source==c and p[1].z==48 and p[1].fit.depth==16 and not cells['2:2'].shape.treeBounds)
 cells['2:2'].mid=0x240;assert(#T.gen3Placements(cells,{region='hoenn'})==0,'unproven sand crown substituted')
 -- Native243/23A group must keep its exact art, ownership, sand and level.
 for _,mutate in ipairs{
  function(c)c['2:3'].collision=0 end,
  function(c)c['2:3'].shape.ground=1 end,
  function(c)c['2:3'].mid=0x240 end,
  function(c)c['2:3'].region={}end,
  function(c)c['2:3'].base=0 end,
  function(c)c['2:3'].shape.treeBounds={32,48,48,80}end,
  function(c)c['2:3'].shape.treePalette='gold'end,
  function(c)c['2:3'].prop={}end,
  function(c)c['2:3'].boundary='water'end,
 }do local cells=fixture{0x243,0x23a};mutate(cells);assert(#T.gen3Placements(cells,{region='hoenn'})==0,'foreign/partial/mixed-ground coastal owner accepted')end
 local cells=fixture{0x243,0x243,0x23a};local parts={};local build=Models.buildBatches
 Models.buildBatches=function()return nil,'missing source texture'end
 assert(not T.buildGen3(cells,function()end,parts,{region='hoenn'}));for _,c in pairs(cells)do assert(not c.importedTree)end
 Models.buildBatches=function(_,_,opts)return opts.parts end
 assert(T.buildGen3(cells,function()end,parts,{region='hoenn'})==parts);for _,c in pairs(cells)do if c.shape.root then assert(c.importedTree)end end
 Models.buildBatches=build
end
-- R/S source variants mix a normal round left foot and an evergreen cap
-- beneath the right half; only the distinct017 body below thatED is a pine.
for _,game in ipairs{'emerald','ruby','sapphire'}do edition=game
 for _,left in ipairs{0x1e4,0x1e6}do
  local cells={};local region={def={id='RU_ROUTE116'}}
  for y,row in ipairs{{0x1d4,0x1d5},{left,0x1ed}}do for x,mid in ipairs(row)do
   cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=7,base=0,primary='general',secondary='rustboro',pair='general__rustboro',region=region,shape=S.of('general','rustboro',mid,0,7)}
  end end
  cells['1:2']={cx=1,cy=2,mid=0x17,collision=7,base=0,primary='general',secondary='rustboro',pair='general__rustboro',region=region,shape=S.of('general','rustboro',0x17,0,7)}
  F.prepare(cells,edition);local p=T.gen3Placements(cells,{region='hoenn'});assert(#p==2,'reviewed mixed round/pine foot source lost a tree')
  assert(p[2].model==H.model and p[2].x==16 and p[2].z==32 and p[2].source==cells['1:2'])
 end
end
print('PASS RSE coastal evergreen crown/trunk packing, exact native sand/blocked bounds, atomic fallback, native walking/foreign exclusions and mixed round/pine source feet')

-- Explicit synthetic tree owners carry a complete canonical portrait even
-- when sampled source rows start at a lower trunk. Fill each owned rectangle
-- once; never invent native permissions or claim a walking/water boundary.
for _,rows in ipairs{{0x23a},{0x23a,0x239},{0x23a,0x23a},{0x243,0x243}}do
 local cells=fixture(rows);for _,q in pairs(cells)do q.collision=nil;q.boundary='forest';q.region=nil end
 local p=T.gen3Placements(cells,{region='hoenn'});assert(#p==1 and p[1].fit.depth==#rows*16 and not p[1].sources)
 assert(p[1].model==(#rows==1 and H.model or H.foregroundModel))
 for _,q in pairs(cells)do assert(q.collision==nil and q.boundary=='forest'and q.base==6)end
 cells['2:3'].boundary='water';assert(#T.gen3Placements(cells,{region='hoenn'})==0)
end
local cells=fixture{0x243,0x243};cells['2:3'].region={def={id='SA_ROUTE106'}}
assert(#T.gen3Placements(cells,{region='hoenn'})==2,'same source/pair/level connected native map owner rejected')
cells['2:3'].collision=nil;cells['2:3'].boundary='forest';cells['2:3'].region=nil
assert(#T.gen3Placements(cells,{region='hoenn'})==2,'blocked forest/native owner join rejected')
cells['2:3'].collision=0;assert(#T.gen3Placements(cells,{region='hoenn'})==0,'walking native/forest join accepted')
-- A native23A body can meet the completed end of a separate generated forest
-- owner. Its own compact tree remains entirely in the native blocked tile.
local cells=fixture{0x23a,0x23a};for _,q in pairs(cells)do q.collision=nil;q.boundary='forest';q.region=nil end
local owner=cells['2:4'];cells['2:5']={cx=2,cy=5,mid=0x23a,collision=7,base=6,primary='general',secondary='dewford',pair='general__dewford',region={def={id='SA_ROUTE107'}},
 shape={kind='tree',treeFamily='conifer',ground=0x124,root=true,treeBounds={32,80,48,96}}}
local plans=T.gen3Placements(cells,{region='hoenn'});assert(#plans==2 and plans[2].source==cells['2:5']and plans[2].z==80 and plans[2].fit.depth==16)
print('PASS bounded generated coastal forest portraits, same-source native/forest and connected-map joins, standalone native edge body, no native permission changes')
