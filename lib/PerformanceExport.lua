-- Stable read-only diagnostics provider for external performance monitors.
--
-- This is intentionally a sampling API rather than a profiler UI. Battle Art
-- owns the counters because it knows what "cache hit", "tree queue" and the
-- timing buckets mean; a separate monitor mod owns capture cadence, reporting
-- and presentation. Consumers must not depend on Battle Art private files.

local V = ...

local M = {
  API_VERSION = 1,
  SCHEMA_VERSION = 1,
  SOURCE_MOD_ID = "BATTLE_ART_VOXEL_FORK",
}

local function clock()
  if love and love.timer and love.timer.getTime then return love.timer.getTime() end
  return os.clock()
end

local function copy(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}
  if seen[value] then return nil end
  local out = {}
  seen[value] = out
  for key, child in pairs(value) do
    local copiedKey = type(key) == "table" and tostring(key) or key
    out[copiedKey] = copy(child, seen)
  end
  return out
end

local function call(module, method, fallback)
  local okModule, value = pcall(V.require, module)
  if not okModule or type(value) ~= "table" or type(value[method]) ~= "function" then
    return fallback
  end
  local ok, result = pcall(value[method])
  if not ok then return fallback end
  return result
end

function M.snapshot(hostVersion)
  local generation = call("Generation", "number", 1)
  local native = generation == 3
  local ram = not native and call("VoxelMeshDisk", "ramStats", {}) or {}
  local timing = call("LoadTimings", "snapshot", {})
  local out = {
    apiVersion = M.API_VERSION,
    schemaVersion = M.SCHEMA_VERSION,
    sourceModId = M.SOURCE_MOD_ID,
    sourceVersion = tostring(hostVersion or "unknown"),
    monotonicSeconds = clock(),
    generation = generation,
    game = call("Generation", "version", nil),
    timings = copy(timing),
    cache = {
      available = not native and call("VoxelMeshDisk", "available", false) and true or false,
      precacheAvailable = not native and call("VoxelMeshDisk", "precacheAvailable", false) and true or false,
      readOnly = native or call("VoxelMeshDisk", "cacheReadOnly", true) and true or false,
      ram = copy(ram),
      trace = copy(not native and call("CacheTrace", "snapshot", {}) or {}),
    },
    mesher = copy(not native and call("ChunkMesher", "stats", {}) or {}),
    trees = copy(not native and call("CommunityFlora", "treeStats", {}) or {}),
    shadow = copy(call("ShadowMap", "stats", {})),
    spriteBounds = copy(call("SpriteHeadBounds", "snapshot", {})),
    saplings = copy(not native and call("SaplingEdits", "stats", {}) or {}),
  }
  if native then
    -- The GB mesher counters are not Gen3 workload measurements. Export the
    -- actual native scene/CPU cache without loading a foreign game facade,
    -- enumerating disk contents or changing any render/cache state.
    out.nativeScene = copy(call("Gen3Scene", "performanceSnapshot", {}))
  end
  return out
end

function M.export(hostVersion)
  hostVersion = tostring(hostVersion or "unknown")
  return {
    apiVersion = M.API_VERSION,
    schemaVersion = M.SCHEMA_VERSION,
    sourceModId = M.SOURCE_MOD_ID,
    sourceVersion = hostVersion,
    capabilities = {
      timings = 1,
      cache = 1,
      cacheTrace = 1,
      storage = 1,
      mesher = 1,
      trees = 1,
      shadow = 1,
      saplings = 1,
      nativeScene = 1,
    },
    snapshot = function() return M.snapshot(hostVersion) end,
    storageSnapshot = function()
      if call("Generation", "number", 1) == 3 then return {} end
      return copy(call("VoxelMeshDisk", "stats", {}))
    end,
  }
end

return M
