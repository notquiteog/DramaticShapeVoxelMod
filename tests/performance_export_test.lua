-- Standalone producer-contract regression for performance-monitor integration.
local checks = 0
local function check(value, message)
  checks = checks + 1
  assert(value, message)
end

love = { timer = { getTime = function() return 12.5 end } }

local storageCalls = 0
local modules = {
  LoadTimings = { snapshot = function()
    return { live = { terrain_all = 2.5 }, worst = { ms = 44, rows = { cache_all = 9 } } }
  end },
  VoxelMeshDisk = {
    available = function() return true end,
    precacheAvailable = function() return true end,
    cacheReadOnly = function() return false end,
    stats = function()
      storageCalls = storageCalls + 1
      return { bytes = 123, files = 4, maps = 2 }
    end,
    ramStats = function() return { enabled = true, bytes = 45, files = 2, dirty = 1 } end,
  },
  CacheTrace = { snapshot = function()
    return { sequence = 3, counts = { ['ram-hit'] = 2 }, recent = {
      { sequence = 3, event = 'ram-hit', map = 'CELADON_CITY', detail = 'body' },
    } }
  end },
  ChunkMesher = { stats = function()
    return { pending = 2, queue = { current = 1, speculative = 1 } }
  end },
  CommunityFlora = { treeStats = function() return { maps = 1, pending = 2 } end },
  ShadowMap = { stats = function() return { allocations = 3, size = 1536, active = true } end },
  SaplingEdits = { stats = function() return { cuts = 4, restores = 1, fallbacks = 0 } end },
}

local V = { require = function(name) return assert(modules[name], name) end }
local P = assert(loadfile('lib/PerformanceExport.lua'))(V)
local api = P.export('1.10.6')

check(api.apiVersion == 1 and api.schemaVersion == 1, 'versioned provider contract')
check(api.sourceModId == 'BATTLE_ART_VOXEL_FORK' and api.sourceVersion == '1.10.6',
      'provider identifies its producer')
check(api.capabilities.cacheTrace == 1 and api.capabilities.mesher == 1,
      'provider advertises structured diagnostics')

local s = api.snapshot()
check(s.monotonicSeconds == 12.5, 'snapshot timestamps at source')
check(s.timings.live.terrain_all == 2.5 and s.timings.worst.ms == 44,
      'timing buckets are exported')
check(s.cache.available and s.cache.precacheAvailable and not s.cache.readOnly,
      'cache capabilities are exported')
check(s.cache.persistent == nil and s.cache.ram.dirty == 1,
      'fast snapshot does not enumerate persistent storage')
check(storageCalls == 0, 'hot snapshot never requests persistent inventory')
check(s.cache.trace.counts['ram-hit'] == 2 and s.cache.trace.recent[1].map == 'CELADON_CITY',
      'structured cache events are exported')
check(s.mesher.pending == 2 and s.trees.pending == 2,
      'mesher and tree queue pressure are exported')
check(s.shadow.size == 1536 and s.saplings.cuts == 4,
      'shadow and edit counters are exported')
check(api.storageSnapshot().files == 4, 'persistent cache inventory is explicitly sampled')

-- The snapshot must be detached from producer-owned tables so a consumer cannot
-- mutate Battle Art diagnostics by accident.
s.timings.live.terrain_all = 999
s.cache.trace.counts['ram-hit'] = 999
local fresh = api.snapshot()
check(fresh.timings.live.terrain_all == 2.5, 'timing tables are copied')
check(fresh.cache.trace.counts['ram-hit'] == 2, 'cache trace tables are copied')

local trace = assert(loadfile('lib/CacheTrace.lua'))()
love = { timer = { getTime = function() return 7 end } }
trace.log('ram-hit', 'CELADON_CITY', 'body')
trace.log('disk-miss', 'ROUTE_7', 'full')
local ts = trace.snapshot()
check(ts.sequence == 2 and ts.capacity == 64
      and ts.counts['ram-hit'] == 1 and ts.counts['disk-miss'] == 1,
      'CacheTrace records structured counters without desktop file logging')
check(#ts.recent == 2 and ts.recent[2].map == 'ROUTE_7',
      'CacheTrace retains bounded recent event details')

print(checks .. ' checks passed (performance export API)')
-- Native snapshots must not load/inspect the GB mesh cache or walk storage.
modules.Generation={number=function()return 3 end,version=function()return 'emerald' end}
local scene={stream={hits=120,started=2},geometryCache={bytes=123,hits=4},map='EM_ROUTE104'}
modules.Gen3Scene={performanceSnapshot=function()return scene end}
local foreignLoads=0
local nativeV={require=function(name)
 if name=='VoxelMeshDisk' or name=='ChunkMesher' or name=='CommunityFlora' or name=='CacheTrace' or name=='SaplingEdits' then foreignLoads=foreignLoads+1 end
 assert(name~='VoxelMeshDisk' and name~='ChunkMesher' and name~='CommunityFlora'
  and name~='CacheTrace' and name~='SaplingEdits','foreign workload loaded')
 return assert(modules[name],name)
end}
local nativeApi=assert(loadfile('lib/PerformanceExport.lua'))(nativeV).export('test')
local n=nativeApi.snapshot()
assert(n.generation==3 and n.game=='emerald' and n.nativeScene.stream.hits==120)
assert(n.nativeScene.geometryCache.bytes==123 and n.mesher.pending==nil)
n.nativeScene.stream.hits=0
assert(scene.stream.hits==120 and nativeApi.snapshot().nativeScene.stream.hits==120)
assert(next(nativeApi.storageSnapshot())==nil and storageCalls==1)
assert(nativeApi.capabilities.nativeScene==1 and foreignLoads==0)
modules.Generation.number=function()return 2 end
assert(api.snapshot().nativeScene==nil and api.snapshot().mesher.pending==2)
print('PASS native scene metrics, detached cache data, no GB facade/storage work, Gen2 fallback')
