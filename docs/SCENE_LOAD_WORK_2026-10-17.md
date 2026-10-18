# Scene loading and transition work — 2026-10-17

This is an optimization checkpoint, **not completion of the 165 FPS target**.
Native testing uses official Gen1Recomp 0.3.89, its packaged Linux LÖVE runtime,
NVIDIA RTX 5060 Ti / driver 615.71.09, 2560×1440, native render scale, Auto distance
and High shadows. Isolated per-game QA profiles; only Battle Art is installed.
The comparison is published 1.44.1 (`fc51546`), not an older engine build.

## Changes

- Original-art Gen 3 trees no longer decode/flood-fill the unused illustrated
  tree sheet. Switching to illustrated trees still loads it once on demand.
- Sea-rock hull recipes share a bounded CPU cache across scene builds (eight
  recipes, at most 16,384 quads). Source atlas, overlay, UV layout and authored
  recipe changes invalidate reuse. GPU instances remain scene-owned.
- Unchanged civic facade/glow textures share reference-counted leases between
  active, pending and destination scenes. The last scene releases the images;
  there is no unbounded or idle GPU texture cache. Explicit source invalidation
  prevents new leases from reusing old pixels while existing scenes retire.
- Native boundary classifications are reused only within a scene build.
- Twelve-cell terrain windows reduce rebuild frequency without reducing the
  selected render distance. Adjacent promotion still checks map, dimensions,
  content and atlas identity; native connected maps remain authoritative.
- Gen 1/2 terrain publishes its complete mesh before optional cache compression.
  Persistence stays in the same cancellable job, behind current terrain/trees
  but ahead of connected/speculative construction to bound retained raw buffers.
  This changes scheduling, not vertices, collision, cache format or native UI.

- Large table-format meshes upload in 2,048-vertex slices through the existing
  public LÖVE API. A mesh becomes visible only after all writes finish; canceled
  builds release an unpublished allocation immediately. This shared path serves
  all generations, while existing packed GB/GBC terrain uploads remain intact.

## Evidence and limits

Scratch evidence: `../.scratch/stream-next-20261017/` relative to this checkout.
Drivers: `cold.lua`, `returns.lua`, `tree-modes.lua`, `legacy-publish.lua`.
Native NVIDIA launcher: the existing `gpu-perf-20261015/run-desktop.sh`; use
`QA_ENGINE=engine-next-baseline` for the exact 1.44.1 baseline and `engine` for
this checkout. Every process closes; normal player saves/options are untouched.

- Early Emerald Route 104 cold-scene sample: 634.825 → 337.626 ms after lazy tree
  art and shared rock recipes. This is scene preparation, not application boot.
- Emerald after material reuse: six native running return crossings peaked at
  6.84–15.41 ms; the previous batch reached 31.14 ms. Sampling is not a guarantee.
- Five GBA editions completed a native running connection plus six reversals,
  preserved camera ownership and matched the engine's connected-map sampler.
  First-cross maxima in the twelve-cell-window batch: Emerald 16.63, Ruby 15.67,
  Sapphire 16.66, FireRed 56.84, LeafGreen 37.41 ms. FireRed return outliers remain.
- Emerald battle, 180 measured frames with High shadows: mean 2.912, p95 3.851,
  max 4.836 ms. Still-world max 8.275; moving field max 16.921. The moving-field
  segment is artificial positioning; `returns.lua` uses actual native running.
- All six GB/GBC editions passed forest/lab/first-person smoke checks before the
  publication-order change. Follow-up Red full-forest mesh publication sampled
  3580.7 → 3258.0 ms, with 478 ms of cache work deferred after publication. This
  measures the **full** mesh, not first visible body terrain or full game boot.
  Crystal samples were variable/slower; no Gen 2 timing improvement is claimed.
- Tree-mode captures inspected: native models, illustrated cards and original
  cards still switch; optional illustrated texture loaded exactly once.
  Emerald battle/connected city and Red forest/lab-first-person captures inspected
  for missing geometry/material regressions; these are not model-quality approval.

Experiments rejected: reducing streaming budgets delayed destination readiness
and caused 90–140 ms stalls. Preparing another local window ahead of the player
also competed with connection work (FireRed reversals 84–138 ms); that code and
its tests were removed. Neither experiment ships.

Focused tests cover source/recipe/UV invalidation, shared-image lifetime, bounded
rock eviction, exact emitted rock geometry, identical boundary donor selection,
full-distance window coverage, and terrain publication/cancellation ordering.
The final shared batch passed 324 suites, 0 failed, 58 external-fixture skips,
including parity commit `8ba4daa`. All eleven editions passed native checks
after the shared upload change: six forests/labs/first-person views and five
actual running connections with six reversals, native sampler equality and
camera/GC-policy restoration. The initial FireRed fixture used an unavailable
12-cell walkable lane; the completed FR/LG runs use the established two-cell
approach. Use `upload-final-*` for GBA final evidence, not older `final-*` logs.

The native upload microbenchmark reads vertices back from the real GPU: all
fields match exactly. Mean 32,768-vertex upload time over eight repetitions was
3.49 → 3.00 ms (six fields), 3.67 → 3.07 ms (nine fields). No `newMesh` call
exceeded the 4 ms diagnostic threshold in the final five GBA crossings.
FireRed first crossing peaked at 27.37 ms, with return spikes up to 37.59 ms;
Emerald first crossing peaked at 15.89 ms. All are samples under concurrent
model-test CPU load, not controlled claims of sustained frame-rate improvement.
Red full-forest publication was 2,840.5 ms with the final scheduling, while total
queue drain was 3,808.2 ms; Blue/Yellow publication was 2,954.7/2,776.7 ms.
Crystal full-forest publication was 531.0 ms; no Gen 2 speedup claim.
Final Emerald/LeafGreen connection and Crystal first-person lab captures were
inspected for upload/geometry loss. Existing model appearance is outside this
performance batch.

Public packed-buffer conversion was also tested with exact GPU readback, but
was slower than table upload and was removed. No FFI/private engine workaround
is used. Native timings still include construction, uploads
and GC spikes; a stable 6.06 ms frame budget across all 11 games is **not verified**.

## Follow-up terrain and shrub construction

Flat elevated caps emit one quad instead of sixteen when all25 sampled heights
are identical; bevels retain their original subdivisions. Repeated modeled
shrubs share immutable build-local hull recipes, with independent translated
vertices and fresh recipes on the next scene build. Furniture cutout queries
reject unrelated recipes before the expensive active-edition lookup.

Focused tests verify unchanged UVs/shading/translated hulls, build invalidation,
and beveled surfaces. Shared broad run:328 passes, one unrelated camera fixture
fixed and passing targeted rerun (329 combined passes),58 resource skips.
Four native running-connection fixtures pass (FR/Emerald/Ruby/Sapphire), each
with six reversals, native sampler equality and camera/GC restoration. Their
post-crossing captures were inspected for missing geometry/materials.

FireRed instrumented totals before/after: terrain314.31ms/4860calls versus
185.68ms/5516calls; shrubs96.86ms/1188calls versus43.46ms/1347calls;
cutouts40.20ms versus0.97ms,32calls each. These are accumulated function CPU
costs, not frame times; call counts differ because streaming schedules differ.
Return-crossing maxima in this sample were11.53/3.54/16.10/4.02/8.36/3.62ms;
first crossing25.12ms. Spikes still exceed the6.06ms target. Evidence:
`stream-next-20261017/phases-firered` and `terrain-{firered,emerald,ruby,sapphire}`.
Gen1/2 retain the shared scheduling/upload improvements above; this follow-up
removes work specific to the Gen3 scene builder. No claim of stable165FPS.
