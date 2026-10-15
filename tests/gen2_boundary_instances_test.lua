-- Instance expansion must equal the merged boundary, including unsupported
-- GPU fallback, palette/material binding and placement-buffer cleanup.
local now=0
love={timer={getTime=function()return now end}}
local Budget=dofile('lib/BuildBudget.lua')
local yieldWork=false
local tick=Budget.tick;Budget.tick=function()if yieldWork then now=now+.0004 end;tick()end
local Select=dofile('lib/BoundaryScenery.lua')
local instanced,flat=true,false
local radius=32
local prototype={};local instances,merged,released=0,0,0
local leaf,bark={},{}
local function append(_,v,i,q,x,y,z)
 merged=merged+1
 for _,p in ipairs({{x-2,y,z},{x+2,y,z},{x+2,y+8,z+1},{x-2,y+8,z+1}})do v[#v+1]=p end
 return q+1
end
local native={gen2=function()return prototype end,appendModel=append,append=append}
function native.addInstance(c,groups,x,y,z)
 if not instanced then return false end
 groups[c]=groups[c]or{};table.insert(groups[c],{x,y,z});instances=instances+1;return true
end
function native.buildInstances(groups,_,__,out)
 out=out or {}
 for c,positions in pairs(groups)do
  out[#out+1]={placements=positions,release=function(self)assert(not self.released);self.released=true;released=released+1 end}
 end
 return out
end
local modules={BoundaryScenery=Select,RenderDistance={radius=function()return radius end},
 Generation={isGen2=function()return true end},
 Voxel3D={newMesh=function(v,indices)for _,i in ipairs(indices or {})do assert(i>=1 and i<=#v,"chunk index escaped its vertices")end;if #v==0 then return end;return {vertices=v,release=function(self)assert(not self.released);self.released=true end}end},
 TreePresentation={flat=function()return flat end,voxel=function()return not flat end,original=function()return true end,art={get=function()return 'original'end}},
 CommunityVisuals={treeDetail={get=function()return 'balanced'end},forest={get=function()return 'original'end},safari={get=function()return 'original'end}},
 Gen2TileShape={paletteOf=function()return 2 end,classAt=function()return 'foresttree'end},
 Gen2Trees={},Gen2DepthTrees={},Gen2DepthGrass={groundTile=function()return 5 end},
 NativeTreeArt=native,NativeLegendaryForest={card=function(c)return c end},
 CommunityFlora={crystalTreeMaterials=function()return bark,leaf end}}
modules.BuildBudget=Budget
modules.SceneStream=assert(loadfile('lib/SceneStream.lua'))({require=function(n)return assert(modules[n],n)end})
local map={def={width=2,height=2,environment='FOREST'},tileset={id='TILESET_FOREST'},tileAt=function()return 12 end}
local state={map=map,neighbors={},player={px=0,py=0}}
local function run(useInstances,flatCards)
 instanced,flat=useInstances,flatCards;merged,instances=0,0
 local B=assert(loadfile('lib/Gen2Boundary.lua'))({require=function(n)return assert(modules[n],n)end})
 local vertices={}
 local function draw(mesh,texture)
  assert(not mesh.released)
  if texture~=leaf and texture~=bark then assert(#mesh.vertices<=4096,'unbounded ground upload')end
  local v=mesh.vertices
  if mesh.placements then
   assert(texture==leaf,'instanced trees changed material');v={}
   local before=merged;for _,p in ipairs(mesh.placements)do append(prototype,v,{},0,p[1],p[2],p[3])end;merged=before
  end
  for _,p in ipairs(v)do vertices[#vertices+1]=table.concat({p[1],p[2],p[3]},',')end
 end
 assert(B.draw(state,0,0,320,240,function()return {}end,draw))
 local buildCount=B.builds;local a,b=merged,instances
 vertices={};B.draw(state,0,0,320,240,function()return {}end,draw)
 assert(B.builds==buildCount and merged==a and instances==b,'unchanged draw rebuilt boundary')
 table.sort(vertices);B.clear();B.clear()
 return table.concat(vertices,';'),a,b
end
local shared,sm,si=run(true,false);local fallback,fm,fi=run(false,false)
assert(shared==fallback and sm==0 and si>0 and fm==si and fi==0,'instance placement differs from merged geometry')
assert(released==1,'placement buffers were not released exactly once')
local _,bm,bi=run(true,true);assert(bm>0 and bi==0,'flat trees used voxel instances')
print('PASS Gen2 boundary instanced/merged equality, native material, stable cache, flat option and cleanup')

-- A moving boundary publishes atomically, including its shadow pass.
local B=assert(loadfile('lib/Gen2Boundary.lua'))({require=function(n)return assert(modules[n],n)end})
flat=false;instanced=true;state.player.px=0
local first={}
local function collect(out)return function(mesh)assert(not mesh.released);out[#out+1]=mesh end end
B.draw(state,0,0,320,240,function()return {}end,collect(first))
yieldWork=true;state.player.px=96;B.update(state)
assert(B.streaming.completed==1 and B.streaming.started==2,'window was not sliced')
local pending={};B.draw(state,0,0,320,240,function()return {}end,collect(pending))
assert(#pending==#first);for i,m in ipairs(first)do assert(pending[i]==m and not m.released,'partial geometry leaked into render')end
for i=1,1000 do B.update(state);if B.streaming.completed==2 then break end end
assert(B.streaming.completed==2,'window never completed')
for _,m in ipairs(first)do assert(m.released,'old geometry was not released')end
-- Reversal cancels the obsolete candidate and preserves the live scene.
state.player.px=192;B.update(state);local cancelled=B.streaming.cancelled
state.player.px=96;B.update(state);assert(B.streaming.cancelled==cancelled+1)
-- Map identity changes must never show the previous map, including direct draws.
state.player.px=192;B.update(state)
state.map={def=map.def,tileset=map.tileset,tileAt=map.tileAt}
B.draw(state,0,0,320,240,function()return {}end,function(m)assert(not m.released)end)
assert(B.streaming.completed==3)
B.clear();B.clear();yieldWork=false
print('PASS Gen2 boundary sliced window, atomic shadow/color publication, reversal, warp and cleanup')

radius=96;state.map=map;state.player.px=0
local a=run(true,false);local b=run(false,false)
assert(a==b,'bounded uploads changed the full perimeter')
print('PASS multi-chunk boundary vertex/index equality and bounded ground uploads')
