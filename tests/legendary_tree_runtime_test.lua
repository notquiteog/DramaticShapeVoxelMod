local F = dofile("tests/legendary_tree_fixture.lua")
local checks = 0
local function check(v, why) checks = checks + 1; assert(v, why) end
local map = F.map("CELADON_CITY", { ["2|2"] = 24, ["4|4"] = 17 })
F.flora.requestCommunityTrees(map, {}, 2, false)
check(#F.meshes == 0, "request does not build or upload on the caller/draw stack")
check(F.pump() > 1, "actual procedural trees yield across shared-budget slices")
local stats = F.flora.treeStats()
check(stats.vertices == 130116, "FULL fixture retains exact approved vertex budget")
check(stats.maps == 1 and stats.pending == 0, "one completed map owner")
for _, part in ipairs(F.M.TRUNK.cache[map.id].parts) do
  local vertices = 0
  for _, name in ipairs({ "trunks", "stones", "hoods", "detail", "shadows" }) do
    if part[name] then vertices = vertices + part[name].n end
  end
  check(vertices <= F.M.TREE_SECTION_VERTEX_BUDGET, "hard spatial batch vertex cap")
end
for _, mesh in ipairs(F.meshes) do
  for _, write in ipairs(mesh.writes) do
    check(write.bytes <= 2048 * 24, "bounded graphics-driver upload")
  end
end
local before = #F.meshes
F.flora.requestCommunityTrees(map, nil, 1, true)
check(not next(F.queue) and #F.meshes == before, "demoting current map to neighbor reuses its GPU owner")
check(next(F.M.TRUNK.nbcache) == nil, "no duplicate neighbor tree cache")
F.draws = {}
local empty = { id = "ROUTE_16", def = { tileset = "OVERWORLD" } }
F.flora.drawCommunityTrees({ map = empty, player = {px=0,py=0},
  neighbors = { { map=map, ox=0, oy=0, eligible=false } } })
check(#F.draws == 0 and #F.meshes == before, "ineligible neighbor neither draws nor builds")
F.flora.drawCommunityTrees({ map = empty, player = {px=0,py=0},
  neighbors = { { map=map, ox=0, oy=0, eligible=true } } })
check(#F.draws > 0 and #F.meshes == before, "eligible neighbor draws the existing batches")
F.radius = 16
F.draws = {}
F.flora.drawCommunityTrees({ map = map, player = {px=2000,py=2000}, neighbors={} })
check(#F.draws == 0, "section R.DIST applies even to current-map trees")
F.radius = nil
F.flora.setLive({[map.id]=true})
F.flora.setLive({ROUTE_16=true})
check(F.flora.treeStats().maps == 1, "previous live neighborhood retained for return trip")
F.flora.setLive({ROUTE_17=true})
check(F.flora.treeStats().maps == 0, "old neighborhood evicted")
for _, mesh in ipairs(F.meshes) do check(mesh.released == 1, "eviction releases each GPU buffer once") end
F.flora.requestCommunityTrees(map, {}, 2, false)
F.pump()
local hit = false
for _, e in ipairs(F.events) do if e[1] == "tree-cache-hit" then hit = true end end
check(hit, "return visit restores section cache instead of procedural regeneration")
check(F.flora.treeStats().vertices == stats.vertices, "cache round trip retains all vertices")
F.flora.evictTrees()
F.mode = "balanced"
F.flora.requestCommunityTrees(map, {}, 2, false)
F.pump()
local balanced = F.flora.treeStats().vertices
check(balanced == 56388 and balanced < stats.vertices * .44, "shell-first recipe reduces actual geometry")
local fullNear, balancedFar = 0, 0
for _, part in ipairs(F.M.TRUNK.cache[map.id].parts) do
  if part.detail then
    fullNear = fullNear + part.detail.n
    balancedFar = balancedFar + part.detailFarCount
  end
end
check(balancedFar <= fullNear * .51, "BALANCED distant prefix halves complete crossed-card bunches")
F.draws = {}
F.flora.drawCommunityTrees({map=map,player={px=500,py=500},neighbors={}})
local ranged = false
for _, mesh in ipairs(F.draws) do if mesh.range then ranged = true end end
check(ranged, "distance selects the prebuilt vertex prefix without rebuilding")
F.flora.evictTrees()
F.mode = "handheld"
F.flora.requestCommunityTrees(map, {}, 2, false)
F.pump()
check(F.flora.treeStats().vertices == balanced, "HANDHELD keeps identical near silhouette")
for _, part in ipairs(F.M.TRUNK.cache[map.id].parts) do
  if part.detail then check(part.detailFarCount <= part.detail.n * .34, "HANDHELD distant bunch budget") end
end
-- Cancellation while decoding/uploading must include unpublished GPU buffers.
F.flora.evictTrees()
local start = #F.meshes + 1
F.flora.requestCommunityTrees(map, {}, 2, false)
for _=1,100 do if #F.meshes >= start then break end; F.pump(1) end
check(#F.meshes >= start, "test reached a partial graphics upload")
F.flora.setLive({UNRELATED=true})
check(not next(F.queue) and F.flora.treeStats().pending == 0, "eviction cancels unfinished work")
for i=start,#F.meshes do check(F.meshes[i].released == 1, "unfinished GPU resources released exactly once") end
-- A sandbox may advertise storage but reject a write. Finished meshes must
-- still publish once; a failed optional cache cannot cause a rebuild loop.
F.flora.evictTrees()
local save,load=F.disk.saveTreeParts,F.disk.loadTreeParts
F.disk.saveTreeParts=function() return false end
F.disk.loadTreeParts=function() return nil end
F.flora.requestCommunityTrees(map,{},2,false)
F.pump()
check(F.flora.treeStats().maps==1 and F.flora.treeStats().pending==0,
  "cache write rejection retains the complete GPU owner")
F.flora.requestCommunityTrees(map,{},2,false)
check(not next(F.queue),"cache write rejection does not retry finished geometry")
F.disk.saveTreeParts,F.disk.loadTreeParts=save,load
F.flora.evictTrees()
local crystal=F.map("NEW_BARK_TOWN",{["2|2"]=10,["4|4"]=17})
crystal.def.tileset,crystal.def.environment="TILESET_JOHTO","TOWN"
crystal.cellCollision=function()return 7 end
F.flora.requestCommunityTrees(crystal,{},2,false)
F.pump()
check(F.flora.treeStats().vertices>0 and F.flora.treeStats().vertices<4500,
  "dense Crystal trees use bounded volumetric foliage rather than XL crowns")
F.flora.evictTrees()
F.depth=true
local depth=F.map("DEPTH_FOREST",{["2|2"]=20,["4|4"]=20})
depth.def.tileset,depth.def.environment="TILESET_JOHTO","TOWN"
depth.cellCollision=function()return 7 end
F.flora.requestCommunityTrees(depth,{},2,false)
F.pump()
local foliage=0
for _,part in ipairs(F.M.TRUNK.cache[depth.id].parts) do
  if part.detail then
    check(part.detailFarCount==nil,"essential HD-2D canopy survives distant LOD")
    foliage=foliage+part.detail.n
  end
end
check(foliage>=24,"both layered crowns uploaded")
F.flora.evictTrees()
F.depth=false
print(checks .. " checks passed (Legendary geometry/cache/ownership/R.DIST)")
