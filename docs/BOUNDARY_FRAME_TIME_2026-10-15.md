# Boundary frame-time optimization — 2026-10-15

Target: smooth 1440p movement on the RTX 5060 Ti. 165 FPS requires 6.06 ms per
frame; this batch does **not** establish that target across all games/maps.

## Changes

- Gold/Silver/Crystal perimeter rebuilding now advances once per world update,
  with a 1 ms cooperative slice. The shadow and color passes consume the same
  complete cache. The previous window remains visible until replacement is
  ready; reversal cancels obsolete work, and map/options changes cannot reuse
  stale scenery. Cold builds still complete synchronously.
- Boundary ground uploads are split at 4,096 vertices. A large LOVE Mesh
  allocation cannot yield internally; splitting it removes that avoidable
  atomic stall. Vertices, UVs, indices, materials and coverage are unchanged.
  Partially uploaded buffers are owned by the candidate and released on cancel.
- Boundary UV tables are reused within each build. Existing tree instances and
  merged/flat fallback paths remain supported.
- FireRed/LeafGreen/Ruby/Sapphire/Emerald cliff builders share exact corner
  samples across the scene and use numeric neighborhood rows. Separate height
  profiles cannot collide; a new layout/build gets a fresh sampler. No terrain
  heights, gameplay cells, art or settings are changed.

## Runtime evidence

Latest official Gen1Recomp release checked through GitHub before the batch:
**v0.3.89**. Official Linux engine/LÖVE, desktop NVIDIA RTX 5060 Ti,
OpenGL 3.3, driver 615.71.09; isolated QA profiles, native 2560×1440, vsync off.
Public test helpers were carried from the prior official runtime because this
package omits them; production engine files were not modified.

Scratch evidence: `.scratch/fps-20261015/` in the parent Projects directory.
`verify.sh` runs serially, without the parity worker's GPU/CPU tests competing.
`boundary.lua` changes only the isolated player's render position across three
six-cell window boundaries; this is a rebuild stress fixture, **not** proof of
native walkable routing. Final captures restore the position and fixed camera.
Initial exploratory captures looked mostly beyond the forest; they are not
visual equivalence evidence. Final fixed-camera forest and Elm's lab captures
were inspected, as was the final Emerald battle capture. Existing fixture
palette/actor-pose limitations are not a visual-quality approval.

Final controlled Crystal fixture (`crystal-before-final` / `crystal-after-final`):

| Cost | Before | After |
| --- | ---: | ---: |
| Largest boundary call | 79.99 ms | 2.85 ms |
| Largest whole frame | 85.05 ms | 19.19 ms |
| Frame p95 | 9.16 ms | 7.62 ms |

Final Gold/Silver boundary calls peak at 3.36/1.88 ms; frame peaks are
6.94/9.91 ms. All G/S/C candidates completed and the subsequent lab warp
completed. An earlier outward-moving fixture improved 38.61→6.12 ms frame
peak, but it is a different camera/window path and is not substituted for the
final comparison above. Timings vary between processes and shader/GC states.

All five native Gen3 Running Shoes connection fixtures retain the camera,
show connected scenery, and pass native terrain-sampler agreement, with one
prefetch, one promotion and zero prefetch failures each:

| Game / crossing | p95 frame | Peak frame |
| --- | ---: | ---: |
| FireRed Route 1 → Viridian | 17.84 ms | 18.61 ms |
| LeafGreen Route 1 → Viridian | 17.94 ms | 20.17 ms |
| Ruby Route 104 → Petalburg | 14.57 ms | 20.73 ms |
| Sapphire Route 104 → Petalburg | 14.72 ms | 18.26 ms |
| Emerald Route 104 → Petalburg | 14.42 ms | 21.10 ms |

Kanto uses a two-cell valid straight approach; Hoenn uses twelve. These are not
equal workloads. They still exceed the 165 FPS target during streaming.

Emerald Route 104 cliff height calculations: 3,200→2,618 calls and
15.10→6.22 ms total against the previous batch; cold full scene
693.77→678.58 ms. Petalburg: 2,750→2,238 calls, 12.73→4.54 ms;
cold scene 231.20→211.29 ms. These fresh-process cold totals remain too large
for a visible frame and are not presented as hitch-free loading.

Final Emerald 1440p stationary battle, HIGH shadows: mean 2.76 ms, p95 3.75 ms,
peak 4.13 ms over 180 frames, zero geometry rebuilds. Moving-scene fixture peak
24.55→17.85 ms; p95 roughly unchanged at 12.37 ms. Steady battle performance
does not imply all attacks/maps/companions meet the same timing.

Red, Blue and Yellow also passed native forest/lab/first-person smoke at
1440p after the shared update-hook change. Their geometry implementation was
not changed by this batch. Across these fixtures all eleven editions ran;
this does not mean every area or feature was reviewed.

## Checks and remaining limits

Focused tests cover instanced/merged vertex equality, flat fallback, bounded
multi-chunk indices, cancellation/reversal/warp cleanup, atomic publication,
shared cliff corners, different wall profiles and fresh sampling after edits.
Shared final suite with the parity worker: **300 passed, 0 failed, 58 skipped**
(external prerequisites), including SDK 1,173 checks. LuaJIT compile and diff
whitespace checks pass.

Remaining costs: synchronous cold/unprepared-map builds, some indivisible
Gen3 generation/uploads and combined foreground/destination streaming work.
Earlier lowering of the destination budget caused late-crossing stalls, so
this batch retains those budgets instead of hiding work until the crossing.
No release/version/push, quality reduction, gameplay collision change or
player-save modification. Parity work continues independently.
