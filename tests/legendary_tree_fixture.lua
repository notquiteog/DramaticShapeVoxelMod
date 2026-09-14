-- Real Legendary builder/cache with synthetic map/graphics/codec boundaries.
local F = { now = 0, meshes = {}, draws = {}, events = {}, queue = {}, mode = "full" }
local ffi = require("ffi")
package.loaded["src.render.Assets"] = { register = function() end }
package.loaded["src.core.Version"] = { engine = "0.2.53" }
package.loaded["src.core.Platform"] = { detect = function() return { os = "Windows" } end }
love = { timer = { getTime = function() F.now = F.now + 0.00002; return F.now end },
  system = { getOS = function() return "NX" end }, graphics = {}, data = {} }
function love.data.pack(_, fmt, ...)
  local values = { ... }
  return ffi.string(ffi.new("float[?]", #values, values), #values * 4)
end
function love.data.unpack(fmt, blob, pos)
  local n = #fmt - 1
  local a = ffi.new("float[?]", n)
  ffi.copy(a, blob:sub(pos, pos + n * 4 - 1), n * 4)
  local out = {}
  for i = 0, n - 1 do out[i + 1] = a[i] end
  out[n + 1] = pos + n * 4
  return unpack(out)
end
function love.data.compress(_, _, raw) return raw end
function love.data.decompress(_, _, raw) return raw end
function love.data.newByteData(raw) return { raw = raw, release = function() end } end
function love.graphics.newMesh(_, n)
  local mesh = { n = n, writes = {}, released = 0 }
  function mesh:setVertices(data, first)
    self.writes[#self.writes + 1] = { first = first, bytes = #data.raw }
  end
  function mesh:setDrawRange(first, count) self.range = count end
  function mesh:release() self.released = self.released + 1 end
  function mesh:getVertexCount() return self.n end
  F.meshes[#F.meshes + 1] = mesh
  return mesh
end
local mods = {}
local V = { path = "." }
function V.require(name)
  if mods[name] then return mods[name] end
  if name == "BuildBudget" or name == "VoxelMeshDisk" or name == "LoadTimings"
    or name == "Gen2DepthTrees" or name == "Gen2Trees" or name == "LegendaryTreeCache" or name == "CommunityFlora" or name == "Mat4" then
    mods[name] = assert(loadfile("lib/" .. name .. ".lua"))(V)
    if name == "LegendaryTreeCache" then
      local create = mods[name].new
      mods[name].new = function(M) F.M = M; return create(M) end
    end
    return mods[name]
  end
  return {}
end
mods.CacheTrace = { log = function(event, id, detail) F.events[#F.events + 1] = { event, id, detail } end }
mods.CommunityVisuals = {
  crystalDepth=function(map)return F.depth and map and map.cellCollision~=nil end,
  crystalStyle={get=function()return "hd2d" end},
  crystalHD = function(map) return map and map.cellCollision ~= nil end,
  customTrees = function() return true end, customCutTrees = function() return true end,
  customForest = function() return false end, fullTreeDetail = function() return F.mode == "full" end,
  treeDetailLevel = function() return F.mode end,
}
mods.RenderDistance = { neighbor = function(nb) return nb.eligible ~= false end,
  section = function(x, z, extent, player)
    return not F.radius or (x-player.px-8)^2+(z-player.py-8)^2 <= (F.radius+extent)^2
  end }
mods.Voxel3D = { FORMAT = {}, project = function() return 80, 72, 1 end,
  size = function() return 160, 144 end, glass = function() end, glassMaskNow = function() end }
function mods.Voxel3D.pushQuad(indices, q)
  for _, i in ipairs({0, 1, 2, 0, 2, 3}) do indices[#indices + 1] = q * 4 + i + 1 end
end
function mods.Voxel3D.newMesh(vertices, indices)
  return love.graphics.newMesh({}, #indices)
end
function mods.Voxel3D.draw(mesh) F.draws[#F.draws + 1] = mesh end
mods.Voxel3D.drawFoliage = mods.Voxel3D.draw
mods.ChunkMesher = {}
function mods.ChunkMesher.requestWork(map, name, signature, priority, work, cancel)
  local key = map.id .. ":" .. name
  if F.queue[key] and F.queue[key].signature == signature then return end
  if F.queue[key] then F.queue[key].cancel() end
  F.queue[key] = { co = coroutine.create(work), cancel = cancel, priority = priority, signature = signature }
end
function mods.ChunkMesher.cancelWork(id, name)
  local key = id .. ":" .. name
  if F.queue[key] then F.queue[key].cancel(); F.queue[key] = nil end
end
function F.pump(limit)
  local frames = 0
  while next(F.queue) and frames < (limit or 10000) do
    frames = frames + 1
    local key, job = next(F.queue)
    local budget = V.require("BuildBudget")
    budget.begin(job.co, 0.001, 4)
    local ok, err = coroutine.resume(job.co)
    budget.finish()
    assert(ok, err)
    if coroutine.status(job.co) == "dead" then F.queue[key] = nil end
  end
  return frames
end
function F.map(id, cells)
  local map = { id = id, def = { width = 8, height = 8, tileset = "OVERWORLD" }, tileset = {} }
  function map:cellTile(x, y) return self.sapling and x == 1 and 45 or 64 end
  function map:isWalkableCell() return false end
  _G.__ds_round_cells = _G.__ds_round_cells or {}
  _G.__ds_round_base = _G.__ds_round_base or {}
  _G.__ds_sapling_cells = _G.__ds_sapling_cells or {}
  _G.__ds_round_cells[id] = cells
  for cell in pairs(cells) do
    local x,y = cell:match("(-?%d+)|(-?%d+)")
    _G.__ds_round_base[id .. ":" .. (tonumber(x)*16+8) .. "|" .. (tonumber(y)*16+8)] = 0
  end
  return map
end
F.V, F.mods = V, mods
F.disk = V.require("VoxelMeshDisk")
F.disk.staticEligible = function() return true end
F.disk.fingerprint = function(map, slot) return map.id .. ":" .. slot end
F.disk.beginSession(true, true)
F.flora = V.require("CommunityFlora")
for _, name in ipairs({"barkImg", "leafyImg", "detailImg", "stoneImg", "shadowImg", "stoneGlassMask"}) do
  F.M[name] = function() return {} end
end
return F
