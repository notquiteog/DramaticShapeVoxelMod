# Initial loads and transitions: second optimization pass

This continues8bf1ab4. It changes computation/storage, not model design,
collision, source artwork, options or companion dependencies.

## Implementation

- Gen1/2 packed mesh cache encoding collects fragments once per1MiB block.
  Previously it repeatedly copied a growing string for every72KiB input fragment.
  Persistent bytes, block boundaries, compression and explicit-save behavior
  remain unchanged. No cache revision bump or invalidation required.
- Shared terrain topology uses union/find for stair-network connectivity instead
  of repeatedly traversing the same network for every ledge. Source ordering,
  floor datums and cycle rejection are unchanged.
- Gen3 elevation classifies each distinct metatile/collision combination once
  per field. Each cell still has independent layer, behavior and support data;
  native edits invalidate the field as before.
- Gen3 cliff quads sample25 shared corners instead of64 redundant evaluations.
  Temporary caching ends with that tile's build; it cannot hide terrain edits.
- Gen3 scene builds reuse pair metadata and triangle index constants.
- Gen2 boundary trees reuse existing native GPU prototypes with per-instance
  placement buffers. Edge classifications are memoized within one build. Main
  and shadow passes use identical original materials/positions. Unsupported
  drivers retain merged geometry; flat trees retain their existing card path.
  Clear releases placements, not shared model prototypes.

## Environment and measurements

Latest official Gen1Recomp0.3.89 verified via release API on2026-10-15.
NVIDIA RTX5060Ti/driver615.71.09, Linux desktop. Packaged engine source unchanged;
public driver/test helpers retained from0.3.88 because the package omits them.
Standalone Battle Art1.39.0 with this batch and concurrent parity changes. All
runs use isolated native-options-<edition>-qa profiles, with no player saves.

The previous matched Emerald cold diagnostic is now Route104829.37→693.77ms,
Petalburg250.13→231.20ms. Route104 elevation field work104.37→24.71ms. Cliff
height evaluations8192→3200. These instrumented CPU-side timings include probing
overhead; they are not a guarantee for every map or graphics driver.

Red forest cache encoding550.13→356.91ms total across startup work; peak frame
89.83→85.85ms. Blue/Yellow after values342.51/352.86ms encoding, peak86.31/77.89ms.
The six legacy fixtures mechanically enter a forest, then lab, then first-person.
Their stylized/palette-sensitive fixture captures are not visual quality approval.

Crystal's first forest frame was1106.30ms in the initial run and709.69ms in the
more detailed repeat. Detailed timing identified418.81ms in the unbudgeted
boundary/shadow path and211.07ms in mesh allocation. With boundary instancing,
peak288.84ms, boundary/shadow173.15ms and mesh allocation17.28ms on its worst
frame. Before/after forest captures inspected: tree shape/placement/material and
fog remain consistent; lab and first-person checks also pass. Cold boundary
construction remains synchronous and is a remaining optimization target.
Final Gold/Silver repeat after instancing: peak172.71/169.77ms versus initial
1077.20/1184.47ms; forest/lab/first-person checks pass and forests inspected.
The native Gen2 facade labels Crystal's preview POKEMON GOLD; the selected
runtime edition remains crystal. These are fresh-process samples, not averages.

Five native Running Shoes boundary approaches at2560x1440, AUTO distance,
HIGH shadows, AAoff/upscale1:

| Edition | Native connection | p95 ms | Peak ms |
|---|---|---:|---:|
| FireRed |Route1→Viridian|18.91|22.67|
| LeafGreen |Route1→Viridian|21.28|22.52|
| Ruby |Route104→Petalburg|16.02|21.77|
| Sapphire |Route104→Petalburg|15.36|20.31|
| Emerald |Route104→Petalburg|15.99|22.10|

All five report1 prefetch/1 promotion/0 failures, native sampler agreement and
active camera. Kanto uses a2-cell approach (the route has no12-cell straight
walkable lane); Hoenn uses12. The fixture now accepts CONNECTION_APPROACH.
Do not compare the shorter Kanto approach as an equal-work load benchmark.
The previous Emerald20.64ms peak and this22.10ms are similar, not evidence of a
further transition FPS gain. No smaller prefetch budgets were adopted.

## Verification

Shared broad run:299 passed,0 failed,58 missing-prerequisite skips (parity
worker's `.scratch/voxel-parity-20261015/suite-gen2-audio-final.log`), including
this stable optimization batch. Focused suites pass: cache format/storage,
native elevation, cliff boundaries,
terrain topology, model instances and new Gen2 boundary instance equality.
Cache regression verifies identical encoded bytes for a2.4MB stream split into
irregular fragments vs one chunk, plus full roundtrip. Boundary regression
compares instanced expansion with merged geometry, verifies palette/material,
flat option, cache stability and single release of placements. Terrain tests
cover repeated ledges joining stair networks, collision variants and edits.
Independent scratch comparisons:400 exact old/new terrain graphs including
ledge networks/cycles,50 exact cliff meshes with irregular supports.

Scratch evidence: `.scratch/load-perf-20261015/` beside the repository, including
`compare.lua`, original source snapshots, `legacy.lua`, `legacy-detail.lua`,
`verify-all.sh`, `verify-gba.sh`, per-edition run logs and captures. GPU runner:
`.scratch/gpu-perf-20261015/run-desktop.sh GAME DRIVER OUT PROFILES IDENTITY`.
Cold Gen3 profile is `.scratch/gpu-cold-20261015/profile.lua`. Legacy capture
resolution1280x720; Gen3 measurements2560x1440. An initial Kanto12-cell fixture
failed to find a walkable lane; corrected to2 before accepting results.

Initial main-scene construction, unprepared warps, individual GPU allocations
and some boundary work can still hitch. This is not full optimization of all
maps, nor all-game visual or controller certification. No version/release/push.
