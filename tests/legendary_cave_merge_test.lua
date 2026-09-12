-- Standalone LuaJIT regression for the two-parent cache and Tower UV merge.
local checks = 0
local function check(value, message)
  checks = checks + 1
  assert(value, message)
end
local ffi = require('ffi')
package.loaded['src.core.Version'] = {engine = '0.2.53'}
package.loaded['src.core.Platform'] = {detect = function() return {os = 'Windows'} end}
package.loaded['src.render.Assets'] = {register = function() end}
love = { graphics = { newMesh = function() end }, data = {
  pack = function(_, fmt, ...)
    assert(fmt == '<ffff')
    return ffi.string(ffi.new('float[4]', {...}), 16)
  end,
  unpack = function(fmt, blob, pos)
    assert(fmt == '<ffff')
    local f = ffi.new('float[4]')
    ffi.copy(f, blob:sub(pos, pos + 15), 16)
    return f[0], f[1], f[2], f[3], pos + 16
  end,
  compress = function(_, _, raw) return raw end,
  decompress = function(_, _, raw) return raw end,
  newByteData = function() end,
} }
local Generation = assert(loadfile('lib/Generation.lua'))()
local Timings = assert(loadfile('lib/LoadTimings.lua'))({
  require = function(name)
    return name == 'Generation' and Generation or nil
  end,
})
local Disk = assert(loadfile('lib/VoxelMeshDisk.lua'))({
  require = function(name)
    return name == 'LoadTimings' and Timings or { check = function() end }
  end,
})
Disk.staticEligible = function() return true end
Disk.fingerprint = function(map, slot) return map.id .. ':' .. slot end
Disk.beginSession(true, true)
local map = { id = 'MERGE_TEST' }
local terrain = { n = 1, chunks = { string.rep('t', 24) }, spans = {0, 1, 8, 8} }
local sign = { n = 1, chunks = { string.rep('s', 24) } }
check(Disk.CACHE_REVISION > 36, 'both parent cache formats must be invalidated')
check(Disk.saveTerrain(map, 'full', nil, terrain, {n = 0}, {sign = sign}, 'registry'),
      'combined terrain saves in session-only mode')
local loaded = assert(Disk.loadTerrain(map, 'full'))
check(loaded.terrain.chunks[1] == terrain.chunks[1], 'terrain survives')
check(loaded.visuals.sign.chunks[1] == sign.chunks[1], 'suppressible sign survives')
check(loaded.registry == 'registry', 'placement registry survives')
check(#loaded.spans == 4 and loaded.spans[2] == 1 and loaded.spans[3] == 8,
      'Cut ownership survives alongside the new streams')
check(Disk.saveTerrain(map, 'body', nil, terrain, {n = 0}), 'old caller remains supported')
local body = assert(Disk.loadTerrain(map, 'body'))
check(next(body.visuals) == nil and body.registry == '' and #body.spans == 4,
      'optional streams do not displace spans')
local reads, lists, writes = 0, 0, 0
local stored = {}
local storage = {
  readBytes = function(_, key) reads = reads + 1; return stored[key] end,
  writeBytes = function(_, key, bytes) writes = writes + 1; stored[key] = bytes; return true end,
  list = function() lists = lists + 1; return {} end,
}
for i = 1, 100 do
  local name = debug.getupvalue(Disk.loadIntoRam, i)
  if name == 'storage' then debug.setupvalue(Disk.loadIntoRam, i, storage); break end
end
check(Disk.saveRamToDisk() and writes == 2, 'only explicit save persists both records')
Disk.dropRam()
check(Disk.loadTerrain(map, 'full') == nil, 'LIVE CACHE cannot reload the persisted terrain')
check(#Disk.ramPlan() == 0 and reads == 0 and lists == 0, 'LIVE CACHE never reads or scans storage')
Disk.setSessionOnly(false)
check(Disk.loadTerrain(map, 'full').registry == 'registry' and reads == 1,
      'normal mode can load the complete combined record')

local tower = true
local M = assert(loadfile('lib/ChunkMesher.lua'))({ require = function(name)
  if name == 'CommunityVisuals' then return {customTower = function() return tower end} end
  if name == 'LoadTimings' then return Timings end
  return {}
end })
-- Reach the real local UV helper through the existing public mesh functions.
local seen = {}
local function find(fn, wanted)
  if type(fn) ~= 'function' or seen[fn] then return end
  seen[fn] = true
  for i = 1, 100 do
    local name, value = debug.getupvalue(fn, i)
    if not name then break end
    if name == wanted then return value end
    local found = find(value, wanted)
    if found then return found end
  end
end
local scale
for _, fn in pairs(M) do scale = scale or find(fn, 'auxiliaryUVScale') end
assert(scale, 'production auxiliary UV helper')
local towerMap = {id = 'POKEMON_TOWER_5F', tileset = {
  id = 'CEMETERY', imageWidth = 128, imageHeight = 48,
}}
local u, v = scale(towerMap)
check(math.abs(u * 3200 - 128) < .00001 and math.abs(v * 4096 - 48) < .00001,
      'original auxiliary texels stay in the source region of the expanded atlas')
tower = false
u, v = scale(towerMap)
check(u == 1 and v == 1, 'Battle Art Tower retains native UVs')
tower = true
towerMap.id = 'AGATHAS_ROOM'
u, v = scale(towerMap)
check(u == 1 and v == 1, 'other Cemetery maps retain native UVs')
local ranges = M.blockRanges({0, 6, 8, 8, 6, 6, 24, 8}, 0, 0, 16, 16)
check(#ranges == 1 and ranges[1][1] == 0 and ranges[1][2] == 6,
      'immediate Cut selects only the authored owner, not its neighbor')
local options = assert(loadfile('lib/CommunityVisuals.lua'))({require = function(name)
  assert(name == 'ModSetting')
  return {new = function(key, label, values, labels, default)
    return {key = key, values = values, value = values[default or 1],
            read = function(self)
              for i, v in ipairs(self.values) do if v == self.value then return i end end
              return default or 1
            end,
            get = function(self) return self.value end,
            row = function() return {step = function() end} end}
  end}
end})
check(not options.customTower() and not options.customCaves() and not options.customForest(),
      'new optional families preserve Battle Art defaults')
options.trees.value = 'n64memory'
check(options.customTrees() and options.fullTreeDetail(), 'saved Legendary tree choice retains full detail')
options.trees.value = 'n64memory_fast'
options.treeDetail.value = 'balanced'
check(options.customTrees() and not options.fullTreeDetail(), 'lighter tree geometry is a separate opt-in')
print(checks .. ' checks passed (Legendary cave merge)')
