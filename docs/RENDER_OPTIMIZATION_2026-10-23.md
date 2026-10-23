# Rendering optimization, 2026-10-23

Engine: latest official Gen1Recomp0.3.95 verified before the native batch.
Linux source runtime uses LÖVE11.5 from the0.3.89 native shell, NVIDIA renderer,
all seven companion mods enabled, isolated profiles and unchanged user saves.
Model coverage remains with its separate owner.

## Changes and scope

Shared shadow translation preserves all matrix values while reducing temporary
allocation/multiplication. Water material uniforms are reused within a draw pass;
mutable values, new passes and failed sends invalidate correctly. Effect queues,
owner ordering, idle scent frames and lamp transforms avoid repeated allocation.
These helpers are shared across generations; no shadow quality/cadence reduction.

GPU scenery prototypes now have explicit live-scene leases, independent instance
offsets, cancellation cleanup and no idle cache. Ordinary batches allocate no
visibility snapshot. Opted-in physical Gen3 trees use conservative instance
subsets; terrain shadows always submit full batches. Unsupported drivers retain
merged meshes, unknown bounds draw normally, and curved/camera-facing geometry
is excluded from camera rejection. Water outside the camera skips reflection
and unused underwater capture. These main-view culling changes are Gen3-specific.

Gen3 sparse light texture upload paints exactly the same nonzero texels without
walking every unlit voxel. Terrain construction reuses scalar UV arithmetic with
identical vertex/UV/order/shade results. Repeated fits, boundary fingerprints and
per-cell temporary arrays are reduced. Tree placement scans check their budget
every32cells; scene-owned resource publication remains atomic. No native
collision, models, lighting strength, resolution settings or gameplay changed.

## Evidence

41 focused suites passed after integration, plus the workers' exact shadow,
water-uniform and terrain tests. The terrain oracle checks19,200 emitted
vertex/UV values, and a5929-cell tree fixture yields186times with identical
placements. All1398 repository Lua files compiled under LuaJIT.

A native Emerald Route104 capture compared culling enabled/disabled in four
camera directions at1280x720: all RGBA bytes matched each time. Inspected the
rendered scene. This verifies culling equivalence, not complete model quality.

At2560x1440, high shadows, automatic distance, native resolution, no AA,180frames
per phase, the same scripted scene produced these wall-time samples in ms:

| Phase | Released1.57.7 mean / p95 / max | Optimized mean / p95 / max |
|---|---|---|
| Standing overworld |5.957 /11.761 /15.330|5.366 /9.700 /13.405|
| Moving window |8.175 /14.423 /28.431|7.412 /13.693 /20.016|
| Warm battle |2.970 /4.278 /5.234|3.122 /4.412 /5.707|

Main draw submissions fell from475to370 standing,485to396moving, and293to210
in battle. One of two water reflection passes was skipped in this view.
Battle throughput did not improve measurably; it was already below6ms in this
fixture. The moving-window benchmark changes camera/player position directly;
it is not the native connection test below. Wall timers are not GPU timestamps,
and short runs include normal game/driver variance.

Five separate native running connection fixtures passed sampler/camera/promotion
assertions. After this batch, forced remaining builds on two-cell FR/LG approaches
were150/164ms (wall maxima166/184ms). Earlier in this same optimization turn those
wall maxima were321/301ms; this is not a comparison against the published baseline.
R/S/E twelve-cell approaches completed prefetched scenes before crossing, with
27.7/28.5/23.8ms wall maxima. Their remaining streaming slices reached13–16ms.

## Remaining limits

Steady165FPS (6.06ms) is NOT achieved across moving overworlds or cold connections.
Late entries still synchronously finish a destination for coordinate/collision
correctness. Further improvement needs staged scene work that can preserve the
correct connected world during a late transition, and smaller indivisible work
units. Do not hide stalls with stale geometry, lower-quality shadows or missing
objects. No Android/iOS hardware performance or full-world visual certification.
XD readiness and unrelated feature parity are not certified by this batch.

## Final package verification

The installable1.57.8 package passed load/update/render with all seven mods in
Red, Blue, Yellow, Gold, Silver, Crystal, FireRed, LeafGreen, Ruby, Sapphire and
Emerald. All593 packaged production Lua files compile. Native forest-to-lab and
first-person checks also passed in all six Gen1/2 editions at1280x720; inspected
Gold's rendered lab view. These are bounded rendering checks, not comprehensive
playthroughs or FPS certification. Processes exited normally and user saves were
untouched. Only documentation changed after those package checks; final packaged
production bytes were compared against the tested archive before publication.
