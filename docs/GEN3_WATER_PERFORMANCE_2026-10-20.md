# Native water verification and performance evidence — pre-merge candidate

Reviewed 2026-10-20. The matched performance runs below use official
Gen1Recomp **0.3.89**, Battle Art **1.49.0 versus 1.50.0/cache 107**.
The candidate used an unreleased 1.50.0 manifest label before concurrent main
advanced to 1.51.2. These are pre-merge measurements, not timings of the final
merged 1.52.0 release. They remain 0.3.89 evidence after the newer engine release. Official 0.3.91
was published 2026-10-19; its separate package compatibility checks must be
reported separately. No 0.3.91 timing is substituted into this comparison.

## Method

`tools/qa/gen3-surface-benchmark.lua` uses the public native map/player,
collision, camera, scene performance provider, and engine FrameProfiler APIs.
Only Battle Art is installed in these shells. Each edition has an isolated
copied QA profile; no player save is overwritten.

- NVIDIA GeForce RTX 5060 Ti, driver 615.71.09; actual renderer verified as
  OpenGL 3.3.0 NVIDIA, rather than Mesa software rendering.
- Xvfb, 1280×720 scene and window, render distance 16, AA off, FSR off,
  world curve off, day, high shadows, balanced modeled trees, tilt shift off.
  Existing default KFP SKY remains BATTLE ART; the optional layered-cloud
  optimization is measured in its dedicated enabled fixture.
- Native dry shore cells, no warp/object at the starting cell; fixed facing.
  Cameras 3 (35°) and 6 (actual first person), FULL/SKY/OFF water.
- 90 warm frames, then 360 sampled frame intervals for each segment.
  Streaming must settle first; builds and stream-start counters must remain
  unchanged through each measurement. All runs are serial with other agents'
  GPU work paused.
- Native metatile IDs, permissions, and elevations are hashed before/after
  each map and must remain unchanged. Native actors and gameplay continue;
  there is no encounter, collision, scripting, or VM replacement.
- Actual public-read mod source hashes, renderer, settings, positions,
  scene counters, graphics statistics, water mesh vertices, and phase values
  are exported with results. There are 36 segments and 36 inspected candidate
  screenshots, plus their 36 matched baseline screenshots.

| Map | Native cell | Facing |
| --- | --- | --- |
| EM_ROUTE103 | 44,7 | down |
| EM_ROUTE104 | 31,15 | up |
| EM_PETALBURG_CITY | 7,22 | down |
| FR_ROUTE_21_NORTH | 15,43 | left |
| FR_PALLET_TOWN | 10,16 | down |
| FR_OAKS_LAB | 6,10 | up |

## Results

Frame intervals are whole presented-frame cadence in this headless setup.
Water CPU is wall time submitting the water pass, **not GPU execution time**.
Draw calls include the whole scene. SKY's final draw count is provided beside
FULL; in 1.49.0 both modes had the same count for these fixtures.

| Map | Camera | FULL mean frame ms, before → after | Frame-time change | Water CPU ms, before → after | FULL draws, before → after | After SKY draws |
| --- | --- | --- | --- | --- | --- | --- |
| EM_ROUTE103 | 3 | 11.262 → 11.316 | +0.48% | 0.223 → 0.207 | 72 → 64 | 62 |
| EM_ROUTE103 | 6 | 11.765 → 11.403 | -3.08% | 0.233 → 0.209 | 68 → 61 | 59 |
| EM_ROUTE104 | 3 | 11.587 → 11.350 | -2.05% | 0.264 → 0.210 | 77 → 67 | 66 |
| EM_ROUTE104 | 6 | 11.410 → 11.547 | +1.20% | 0.239 → 0.224 | 72 → 63 | 62 |
| EM_PETALBURG_CITY | 3 | 12.259 → 12.338 | +0.65% | 0.415 → 0.395 | 101 → 87 | 85 |
| EM_PETALBURG_CITY | 6 | 11.661 → 11.852 | +1.64% | 0.322 → 0.347 | 95 → 83 | 81 |
| FR_ROUTE_21_NORTH | 3 | 11.288 → 11.732 | +3.93% | 0.191 → 0.201 | 56 → 49 | 48 |
| FR_ROUTE_21_NORTH | 6 | 11.520 → 11.314 | -1.79% | 0.187 → 0.180 | 51 → 45 | 44 |
| FR_PALLET_TOWN | 3 | 11.387 → 12.359 | +8.54% | 0.143 → 0.184 | 40 → 37 | 36 |
| FR_PALLET_TOWN | 6 | 11.279 → 12.618 | +11.87% | 0.122 → 0.157 | 36 → 34 | 33 |
| FR_OAKS_LAB | 3 | 11.413 → 11.955 | +4.75% | 0.000 → 0.000 | 45 → 45 | 45 |
| FR_OAKS_LAB | 6 | 11.536 → 11.158 | -3.28% | 0.000 → 0.000 | 43 → 43 | 43 |

The zero-water Oak control has no water vertices or water-pass calls and
retains exactly 45/43 draws. Its frame-time changes range from **−5.01% to
+4.75%** across the six samples. Emerald's changes range from −3.08% to
+5.29%. Pallet's FULL mean frame times increased 8.54%/11.87%, with increased
present and ordinary CPU submission times; the run does not establish how
much is persistent code cost versus run variation. These results **do not
support a general FPS improvement claim** or a 165 FPS guarantee.

Presentation itself consumes roughly 9 ms per frame in the NVIDIA/Xvfb
context. The official driver runs uncapped, despite the ordinary game cap
setting; its FrameProfiler work metric subtracts some present time. It must
not be interpreted as the achieved desktop frame rate. No public GPU
timestamp measurement was available. A desktop GPU bottleneck claim or
attribution of small cadence differences requires additional measurements.

Across the ten outdoor fixtures, FULL draw calls fall by 2–14 and SKY by
3–16. SKY canvas switches fall by 1–2. FULL canvas switches rise by 2–4
with the new reflection/depth correctness work. Median water submission
time across the ten fixture means is 0.228 → 0.208 ms for FULL and
0.222 → 0.196 ms for SKY; this is a small CPU measurement, not GPU timing.

The reproducible reductions are rendering work: fewer submitted scene draws,
SKY avoiding the FULL mirror copy, removing the native 16-step relief walk,
and cached native water draw/height lists. Those savings coexist with new
correctness work: planar actor reflections and a packed depth snapshot at
reviewed wet rocks. EM_ROUTE103's water geometry grows from 2468 to 2756
vertices to cover the rock underlays in the shared water pass. The other
five fixtures' water vertex totals are unchanged.

## Visual and clock review

All 36 candidate screenshots were inspected, including enlarged FULL
FireRed Route 21 North and Emerald Route 103 first-person views. The raised
checker/ridge appearance is gone in FireRed; FULL/SKY are smooth, native
banks remain intact, and Oak's room has no new water-related regression.
Characters, Pokémon, and flowers retain their sprite presentation.

The native wave profile uses continuous world-space low-amplitude waves
(maximum height scale 0.30 versus the legacy relief scale 5), with analytical
normals and distance filtering. Its ripple clock advances roughly 3.95–4.55
seconds during each sampled segment. The legacy GB water clock remains
unchanged and reads zero in native Gen3; it is no longer the native wave
clock. The public `tileset_anim.counter` only describes FR/LG animation;
its zero value in RSE is not evidence that RSE source animation stopped.

Native high-value wave/foam art remains visible. In particular Emerald Route
103 FULL first person retains conspicuous pale diagonal source-wave bands;
they are flat material detail rather than the former raised relief geometry.
This is a remaining visual limitation, and the screenshots should be reviewed
when deciding how much source-water contrast to retain. No claim is made
that every water tile or weather/time combination was visually covered.

## Reproduction and evidence handling

Run the checked-in QA driver through the approved isolated engine runner,
with `QA_MAPS`, `QA_CAMERAS=3,6`, `QA_WATER_MODES=full,sky,off`,
`QA_WARMUP=90`, and `QA_SAMPLES=360`. Verify the actual renderer and use the
same engine release, options, native cells, source snapshots, and profiles
for both sides. Repeat steady-state samples serially; use Oak as a control.
`QA_MEASURE=0` is suitable for visual coverage, not performance claims.

Raw logs, JSON exports, TSV values, imported native assets, and screenshots
remain in task scratch storage. They are excluded from the repository and
release package. This document records the measured scope and limitations;
unit-test success alone is not visual verification.
