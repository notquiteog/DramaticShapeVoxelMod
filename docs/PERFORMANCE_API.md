# Battle Art performance provider API

`BATTLE_ART_VOXEL_FORK` exposes a read-only performance producer at
`mod.exports.performance`. Reporting, capture cadence and UI belong in a separate
monitor mod; consumers should not read Battle Art files or inspect private Lua
state.

## Contract

Current API/schema version: `1`.

```lua
local handle = mod.find("BATTLE_ART_VOXEL_FORK")
local perf = handle and handle.exports and handle.exports.performance
if perf and perf.apiVersion == 1 then
  local sample = perf.snapshot()
end
```

The provider descriptor contains `apiVersion`, `schemaVersion`, `sourceModId`,
`sourceVersion`, `capabilities`, `snapshot()` and `storageSnapshot()`.

`snapshot()` is designed for regular sampling and does not enumerate persistent
storage. It returns detached tables containing:

- `timings`: Battle Art's exclusive CPU timing buckets, live window, worst frame,
  peaks, totals, max call cost, call counts, cancellations, job errors and
  fallbacks.
- `cache`: availability/read-only flags, session RAM cache state and a bounded
  structured cache-event trace. `trace.sequence` is monotonic and `recent` holds
  at most `trace.capacity` events so consumers can de-duplicate samples.
- `mesher`: resident map/settled-slot counts, stale maps, pending jobs, queue class
  counts, unconsumed failure count and up to 32 lightweight job descriptors.
  `jobsTruncated` reports whether more jobs exist. No meshes, maps or coroutines
  escape.
- `trees`: Legendary tree-cache maps, sections, vertices and pending jobs.
- `shadow`: shadow target size, allocation count and active state.
- `saplings`: cut/restore/fallback counters.

Persistent cache inventory can involve `storage.list`, so it is deliberately
separate. Call `storageSnapshot()` at a low cadence rather than from the hot
sampling loop.

All returned tables are copies. Consumers may retain or transform them without
mutating Battle Art. Unknown/missing internal diagnostic modules fail open to
empty tables/default capability flags so diagnostics cannot break rendering.

## Compatibility

Consumers should require only `apiVersion == 1` and inspect `capabilities` before
depending on an optional section. `schemaVersion` can advance when fields are
added without changing the calling convention; an incompatible calling contract
requires a new `apiVersion`.

### Native Gen3 workload (additive schema1 fields)

`snapshot()` also identifies `generation` and `game`. On FireRed, LeafGreen,
Ruby, Sapphire and Emerald, `nativeScene` contains the actual native renderer's
`stream` counters (`started`, `completed`, `cancelled`, `hits`, `slices`,
`maxSlice`, `maxStreamSlice` in seconds), `prepares`, `builds`, `cacheHits`,
map ID, distance/bounds, render size and compressed CPU `geometryCache` counters.
`capabilities.nativeScene == 1` advertises this optional branch. Tables are
copied; modifying a snapshot cannot change the renderer.

The legacy GB `mesher`, `trees`, `saplings` and `cache` fields are not native
Gen3 workload measurements and remain empty/unavailable there; the monitor
must use `nativeScene` instead. Gen3 snapshots do not load GB mesh/cache
modules or scan storage. `storageSnapshot()` currently returns an empty table
for Gen3; CPU cache counters do not pretend to enumerate persistent bytes.
Gen1/2 keep their existing detailed GB diagnostics. None of these reads changes
render quality, cache policies or the world, and no monitor mod is required.

`spriteBounds` reports cumulative `cpu` source scans, `fit` CPU fitted-image
scans, and `gpu` fallback measurements. Cached repeat queries do not increment
these counters. A GPU measurement is a bounds readback, not a frame time.
All generations share this optional diagnostic table.
