# Cold geometry and terrain streaming — 2026-10-15

## Changes

Identical Hoenn coastal rocks now share one carved local hull per tileset,
family and water underlay within a scene build. Each instance emits independent
world-space vertices and UVs; terrain elevation cannot mutate the template.
Atlas/provider replacement invalidates the template. Templates belong to the
prepared cells, so parallel scene coroutines and reloads do not share global
mutable state. No model design, material, collision or footprint changed.

The shared VoxelHull mesher uses numeric strides instead of allocating a
coordinate table for every tested voxel face. Face order, winding, palette
sampling and vertex arithmetic are preserved. This benefits callers in all
three generations, without claiming a measured FPS improvement in all games.

TerrainLevels retains its public coordinate-keyed cells but uses a temporary
bounded dense grid during topology construction. Flood/support passes now yield
through the existing build-budget callback. Output heights, support tie order,
terraces and connected-map alignment remain unchanged. Gen2/Gen3 use this path.

## Measured results

Official Gen1Recomp **0.3.89**, verified latest through the official release API
on October 15. Packaged source unchanged; public driver/test helpers copied from
0.3.88 because the package omits them. NVIDIA RTX5060Ti, driver615.71.09,
Linux desktop, actual2560x1440 fullscreen/vsync0, AUTO distance, AAoff, upscale1.
Standalone Battle Art1.39.0 plus this batch and parity commit9fb3696. Disposable
native-options-<game>-qa profiles; no player save modified.

The same instrumented cold-load fixture before/after:

| Scene / operation | Before ms | After ms |
|---|---:|---:|
| Emerald Route104 first Scene.draw |1371.13|829.37|
| Route104 sea-rock append total |557.53|44.71|
| Emerald Petalburg first Scene.draw |404.72|250.13|
| Petalburg sea-rock append total |227.31|58.99|

Route104 mask generation fell from44 calls to4, Petalburg21 to4. Instrumentation
adds overhead: these are matched diagnostic runs, not general loading-time
promises. Initial builds and unprepared warps still execute synchronously.

Uninstrumented native Running Shoes approach12 cells before the Route104 east
connection into Petalburg: p9516.70ms, peak20.64ms versus the previous accepted
20.63/27.75ms. Prefetch1/promotion1/failures0,3025 native sampler comparisons
passed, camera remained active. A2/4ms prefetch-budget experiment missed the
ready deadline and peaked188.84ms; rejected. Existing4/8ms budgets remain.
These are cooperative targets; uploads/engine calls can exceed them.

1440p Emerald battle command phase, HIGH shadows: mean3.97ms/p956.60ms/peak9.74ms,
180 cache hits and zero geometry scans/rebuilds. This confirms cached battle
rendering, not an improvement over the prior3.17ms mean run, nor every animation.

## Verification and reproducibility

- Broad suite:296 passed,0 failed,58 external-fixture skips.
- Existing hull/terrain suites pass; added sea-rock reuse, independent output,
  atlas/UV-provider replacement and fresh-build isolation checks pass.
- Added terrain yield-after-decoding and no-row-wrap neighbor checks pass.
- Independent scratch baseline comparison:36 old/new hull geometries exactly
  equal,100 old/new terrain graphs exactly equal,100 coroutine-yielded graphs
  equal to synchronous outputs. Rock vertices/UVs/shades exactly equal at zero,
  positive and negative origins. No baseline implementations copied into product.
- Native FireRed streaming lifecycle PASS: complete-window retention, reversal,
  warp cancellation into Oak's lab, invalidation and retained camera. Forest/lab
  captures inspected at1280x720. Existing dense canopy occlusion remains visible;
  model art and visual polish are owned by the separate model task.

Evidence root: `.scratch/gpu-cold-20261015/` beside the repository. `profile.lua`
is the timing wrapper, `before/run.log` and `after/run.log` are matched profiles;
`equivalence.lua`, `rocks-equivalence.lua` and `*.before.lua` contain comparisons.
Reusable committed drivers are `tests/scenery_connection_driver.lua` with
CONNECTION_RUN=1, and `tests/scenery_streaming_lifecycle_driver.lua`.
The established runner is `.scratch/gpu-perf-20261015/run-desktop.sh`:

```
env CONNECTION_RUN=1 __GLX_VENDOR_LIBRARY_NAME=nvidia bash RUNNER emerald DRIVER OUTPUT PROFILES native-options-emerald-qa
```

`running/after.png` inspected: connected town, forest and actors visible; this
performance batch does not certify existing model quality. `battle/battle-on.png` inspected: both battlers, native healthboxes and command
UI render. `battle/` uses the existing fullscreen.lua fixture. Captures verify rendering, not manual controller
operation, online battles or every edition. Processes exit; isolated profiles
retain their QA settings only. No release/version bump in this batch.
