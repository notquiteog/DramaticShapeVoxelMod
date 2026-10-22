local version='emerald'
package.loaded['src.core.GameVersion']={get=function()return version end,generation=function()return 3 end}
package.loaded['src.core.game3.collision']={isSurfable=function()return false end}
local modules={ModelInstances={},BuildBudget={check=function()end},SceneryModelData=dofile('lib/SceneryModelData.lua'),TreePresentation={voxel=function()return true end},CommunityVisuals={customTrees=function()return false end,customForest=function()return false end,customSafari=function()return false end}}
local V={mod={read=function(_,p)local f=assert(io.open(p,'rb'));local s=f:read('*a');f:close();return s end}}
function V.require(n)if modules[n]then return modules[n]end;local m=assert(loadfile('lib/'..n..'.lua'))(V);modules[n]=m;return m end
local S,F,T=V.require('Gen3TileShape'),V.require('Gen3TreeFootprints'),V.require('ImportedTrees')
for game,prefix in pairs{ruby='RU',sapphire='SA',emerald='EM'}do
 version=game
 for _,rows in ipairs{{{0x1d6,0x1d7},{0x1e6,0x1f2}},{{0x1d4,0x1d7},{0x1f3,0x1e5}},{{0x1d4,0x1d5},{0x1de,0x1df}},{{0x1d4,0x1d5},{0x1ec,0x1ed}}}do
  local cells={};local region={def={id=prefix..'_RUSTBORO_CITY'}}
  for y,row in ipairs(rows)do for x,mid in ipairs(row)do local shape=S.of('general','rustboro',mid,0,7)
   assert(shape.kind=='tree'and shape.ground==1 and shape.treeFamily=='round','curved lower tree half remained flat/cliff')
   cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=7,base=0,primary='general',secondary='rustboro',pair='general__rustboro',region=region,shape=shape,floor={layer=0}}
  end end
  local native={};for k,c in pairs(cells)do native[k]={c.mid,c.collision,c.base}end
  local stats=F.prepare(cells,game);assert(stats.models==1 and stats.cells==4,'one source crown became duplicate compact trees')
  local list=T.gen3Placements(cells,{region='hoenn'});assert(#list==1 and list[1].model=='oras_route104_broadleaf','whole ordinary tree did not retain full modern source')
  local root=list[1].source;assert(root.cy==1 and root.cx==0 and root.shape.treeBounds[3]==32 and root.shape.treeBounds[4]==32)
  for k,c in pairs(cells)do local n=native[k];assert(c.mid==n[1]and c.collision==n[2]and c.base==n[3]and c.shape.treeBounds==root.shape.treeBounds)end
 end
 do
  local cells={};local region={def={id=prefix..'_ROUTE116'}}
  for y,row in ipairs{{0x1d4,0x1d5},{0x1ec,0x1ed},{0x17,0x17}}do for x,mid in ipairs(row)do
   cells[(x-1)..':'..(y-1)]={cx=x-1,cy=y-1,mid=mid,collision=7,base=0,primary='general',secondary='rustboro',pair='general__rustboro',region=region,floor={layer=0},shape=S.of('general','rustboro',mid,0,7)}
  end end
  F.prepare(cells,game);local list=T.gen3Placements(cells,{region='hoenn'})
  assert(#list==3,'mixed round/pine source lost a whole tree or planted a duplicate')
  local counts={};for _,p in ipairs(list)do counts[p.model]=(counts[p.model]or 0)+1 end
  assert(counts.oras_route104_broadleaf==1 and counts.oras_evergreen_tree==2)
  local pine=cells['0:2'];local H=V.require('Gen3ImportedHoennTrees')
  assert(#H.placements(pine,cells,{region='hoenn'})==1 and pine.base==0 and pine.collision==7)
  cells['1:1'].collision=0;assert(not H.placements(pine,cells,{region='hoenn'}),'partial/foreign round background permitted a pine')
 end
 for _,mid in ipairs{0x1f4,0x1f5}do
  local cells={};local region={def={id=prefix..'_ROUTE104'}}
  for y,id in ipairs{0xc7,mid}do cells['0:'..(y-1)]={cx=0,cy=y-1,mid=id,collision=7,base=0,primary='general',secondary='rustboro',pair='general__rustboro',region=region,
   shape=S.of('general','rustboro',id,0,7),floor={layer=0}}end
  F.prepare(cells,game)
  local list=T.gen3Placements(cells,{region='hoenn'})
  assert(#list==1 and list[1].model==V.require('Gen3ImportedHoennTrees').foregroundModel,'evergreen tail duplicated or remained flat')
  assert(#list[1].sources==2 and list[1].sources[1]==cells['0:0']and list[1].sources[2]==cells['0:1'])
  assert(cells['0:1'].shape.treeFamily=='round'and cells['0:1'].collision==7,'source classification/permissions mutated by planner')
 end
 for _,pair in ipairs{{0x1e8,0x1d6},{0x1e9,0x1d5},{0x1fc,0x1f4},{0x1fd,0x1f5}}do
  local cap={cx=0,cy=0,mid=pair[1],collision=0,primary='general',secondary='fallarbor',pair='general__fallarbor',shape={kind='flat'}}
  local body={cx=0,cy=1,mid=pair[2],collision=7,primary='general',secondary='rustboro',pair='general__rustboro',shape=S.of('general','rustboro',pair[2],0,7)}
  local cells={['0:0']=cap,['0:1']=body}
  assert(V.require('Gen3Hoenn').prepareTreeCaps(cells)==1 and cap.shape.kind=='tree'and cap.shape.ground==1 and not cap.shape.root)
  F.prepare(cells,game);assert(not cap.shape.treeBounds and cap.collision==0,'walking source cap gained geometry or changed permission')
  cap.shape={kind='flat'};body.civic={};assert(V.require('Gen3Hoenn').prepareTreeCaps(cells)==0 and cap.shape.kind=='flat','conflicting civic body removed source projection');body.civic=nil
  body.collision=0;assert(V.require('Gen3Hoenn').prepareTreeCaps(cells)==0 and cap.shape.kind=='flat','unverified body removed source projection')
 end
 -- Encounter-grass caps are walking projections, not new bushes/trees.
 for _,mid in ipairs{0x1c6,0x1c7}do
  local c={cx=0,cy=0,mid=mid,collision=24,primary='general',pair='general__rustboro',shape={kind='flat'}}
  local body={cx=0,cy=1,mid=0x1d4,collision=7,primary='general',pair=c.pair,shape=S.of('general','rustboro',0x1d4,0,7)}
  local cells={['0:0']=c,['0:1']=body};assert(V.require('Gen3Hoenn').prepareTreeCaps(cells)==1)
  F.prepare(cells,game);assert(c.shape.ground==0xd and not c.shape.root and not c.shape.treeBounds and c.collision==24)
  c.shape={kind='flat'};c.collision=0;assert(V.require('Gen3Hoenn').prepareTreeCaps(cells)==0,'non-grass permission accepted as encounter cap')
 end
 -- Rock/leaf composites stay cliffs and preserve the real native upper floor.
 for _,mid in ipairs{0x1f0,0x1f1}do
  local c={cx=0,cy=1,mid=mid,collision=7,primary='general',secondary='rustboro',pair='general__rustboro',shape={kind='flat'}}
  local upper={cx=0,cy=0,mid=0x71,collision=0,primary='general',pair=c.pair,base=6,floor={layer=4},shape={kind='flat'}}
  local id=mid==0x1f0 and 0x1d4 or 0x1d5
  local lower={cx=0,cy=2,mid=id,collision=7,primary='general',pair=c.pair,shape=S.of('general','rustboro',id,0,7)}
  local cells={['0:0']=upper,['0:1']=c,['0:2']=lower};local H=V.require('Gen3Hoenn');local profile=H.shape('general','rustboro',0x74,0,7)
  assert(H.prepareTreeCliffs(cells)==1 and c.shape.kind=='cliff'and c.shape.height==profile.height and c.shape.side==0x71)
  assert(c.mid==mid and c.collision==7 and upper.base==6 and upper.floor.layer==4 and upper.collision==0)
  upper.mid=0x7d;upper.collision=7;upper.shape=profile;assert(H.prepareTreeCliffs(cells)==1,'verified existing cliff join rejected')
  upper.mid=0x70;assert(H.prepareTreeCliffs(cells)==0,'arbitrary wall support accepted')
  upper.mid=0x71;upper.collision=0;lower.collision=0;assert(H.prepareTreeCliffs(cells)==0,'walking body acquired cliff')
  lower.collision=7;upper.pair='foreign';assert(H.prepareTreeCliffs(cells)==0,'foreign upper support accepted')
 end
 local c={cx=0,cy=0,mid=0x1f3,collision=0,primary='general',secondary='rustboro',pair='general__rustboro',shape=S.of('general','rustboro',0x1f3,0,0)}
 F.prepare({['0:0']=c},game);assert(not c.shape.root and not c.shape.treeBounds,'walking projected art acquired trunk')
 assert(S.of('building','generic_building',0x1f2,0,7).kind~='tree','interior ID reused as tree')
end
version='firered';assert(V.require('Gen3Hoenn').prepareTreeCaps({['0:0']={cx=0,cy=0,mid=0x1e8,collision=0,primary='general'},['0:1']={mid=0x1d4,collision=7,primary='general',shape={kind='tree'}}})==0,'FRLG source pixels changed');assert(S.of('general','viridian_city',0x1f2,0,7).kind=='cliff','FRLG-numbered native cliff changed')
print('PASS exact RSE curved tree halves, clean grass ground, one complete owner/source tree, immutable permissions, walking/interior/FRLG exclusions')
