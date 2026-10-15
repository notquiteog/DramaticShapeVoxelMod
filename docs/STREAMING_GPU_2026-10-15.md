# Connected-map streaming and render allocations — 2026-10-15

## Changes

Native Gen3 prepares one real connected destination ahead of the player, using
public map definitions and the engine's primary/direct/distant/border precedence.
It retains the complete live scene until a destination is ready. Map identity,
source/provider fingerprints and bounded window compatibility govern promotion;
script edits, different providers and distant warps cannot reuse stale scenery.
No collision, actors, native map selection or model designs change.

Native building/furniture cache generation now stages bounded compressed RAM
records. It previously performed two durable storage writes per generated model
inside the rendering coroutine (record plus complete index). CACHE > SAVE writes
records and one index explicitly. Failed writes retain retryable dirty records;
DROP clears compressed RAM only. OFF/LIVE/FULL/budget and corrupt-cache fallback
remain supported. SAVE/DROP uses the native GBA field choice/message APIs.

Shared shader numeric snapshots are reused without losing pass/shader invalidation.
Source alpha floods use integer queues and test each boundary pixel once. Gen3
scene fingerprints avoid unchanged-frame allocations; animated cutout atlases
reuse CPU scratch data and GPU images while copying fresh source pixels.

## Runtime evidence

Official Gen1Recomp **0.3.89**, confirmed latest from its GitHub release API on
2026-10-15. Packaged engine source unchanged; only public driver helpers/test
harness copied from0.3.88 because the0.3.89 package omits them. Linux desktop,
NVIDIA RTX5060Ti, OpenGL3.3, driver615.71.09. Actual2560x1440 fullscreen, vsync0,
AUTO distance, HIGH shadows, AAoff, upscale1. Standalone Battle Art1.39.0 checkout
plus this batch; disposable `native-options-<game>-qa` profiles, no player saves.

The reproduced Emerald Route104→Rustboro native walking boundary previously
peaked at499.36ms (496.33ms inside Scene.draw). With completed prefetch but old
storage writes, boundary promotion worked but40–48ms stalls occurred earlier
inside model-cache writes. After deferred writes:

| Edition / real native crossing | Frame p95 ms | Peak ms | Prefetch / promotion / failures |
|---|---:|---:|---|
| Emerald Route104→Rustboro |6.48|7.82|1 / 1 / 0|
| Ruby Route104→Rustboro |4.68|14.82|1 / 1 / 0|
| Sapphire Route104→Rustboro |3.97|14.85|1 / 1 / 0|
| FireRed Route1→Viridian |5.13|13.21|1 / 1 / 0|
| LeafGreen Route1→Viridian |5.41|12.04|1 / 1 / 0|

Camera remained active. Destination lookup matched native worldMidAt at5525
sample cells per Hoenn edition and4745 per FRLG edition. Final maximum streamed
slice was8.2–11.7ms, including engine/GPU calls between cooperative checkpoints;
the initial2/4ms budget is a yield target, not a hard maximum. Fixture warms180 frames
near the boundary, then uses normal native directional input. This demonstrates
ready-destination promotion, not guaranteed zero stalls at arbitrary running
speeds, immediate teleports or unprepared/unsupported custom maps.

A subsequent cold continuous-running fixture starts12 cells before the east
Route104→Petalburg boundary with Running Shoes granted through the native Emerald
flag and only one warmup frame. This exposed partial adjacent-window work being
discarded; it now finishes/reuses that work too. Final approach budgets are4ms
farther out and8ms within8 cells. The accepted run completed prefetch before entry:
1 prefetch/1 promotion/0 failures,3025 native samples matched,20.63ms p95 and27.75ms
peak across the whole approach, versus846ms when discarded. This removes the
large hitch in this fixture but does **not** establish a locked60fps running floor.
A3/6ms experiment left work unfinished at entry (226ms spike), so was rejected.

Final Emerald180-frame phases after this budget adjustment, same1440p fixture:

| Phase | Mean ms | p95 ms | Peak ms |
|---|---:|---:|---:|
| Still field |4.43|7.18|11.63|
| Artificial within-map traversal/turning |8.04|14.06|19.70|
| Native battle command phase, HIGH shadows |3.17|4.83|6.68|
| Native battle command phase, shadowsOFF |2.94|4.58|7.52|

Both battle phases made180 cache hits, zero scene scans/rebuilds. Battle exits
through the native abort path successfully. These are bounded CPU/frame timings,
not GPU timestamp queries or a claim about every attack/companion/144Hz frame.
Xvfb added large presentation overhead; these measurements use the desktop.

Actual Emerald/Ruby/FireRed native CACHE menus passed SAVE, DROP, directional/A/B
navigation and return to the parent menu. Real LÖVE float/compression codec tests
passed persistence, canonical source order, art/options/slot/source invalidation,
OFF/LIVE/FULL/budget, malformed/nonfinite payloads, write/index failure and retry.
No render-time writes occur. FireRed forest lifecycle fixture passed retained
windows, reversal, atomic completion, warp cancellation, invalidation and camera.
Yellow/Crystal forest/lab/first-person shared-renderer smoke assertions pass;
these do not establish all-map visual coverage.

Inspected captures: Emerald final crossing and battle; all three native cache
menu families; FireRed completed forest; Yellow forest and Crystal lab-first.
The legacy fixture has synthetic placement/options and developer HUD; these are
renderer smoke evidence, not polished model acceptance. Root has not changed
models. No every-map, every-companion or universal frame-time claim is made.

## Reproduction and tests

Scratch evidence directory: `.scratch/gpu-perf-20261015` beside this checkout.
`crossing-before2`, `crossing-final-{emerald,ruby,sapphire,firered,leafgreen}`,
`crossing-run-accepted`, `perf-accepted`, `cache-menu-{emerald,ruby,firered}`, `lifecycle-firered`,
`legacy-{yellow,crystal}` contain logs/captures. Each process exited and all
mutated saves/options are isolated QA fixtures.

Reusable drivers: `tests/scenery_connection_driver.lua` (set `CONNECTION_RUN=1` for the cold running approach),
`tests/gen3_cache_menu_driver.lua`, existing scenery lifecycle/legacy drivers.
Pure tests cover sparse overrides/provider/window/battle fingerprint invalidation,
shader-state reset and in-place mutation, randomized alpha reachability,60-frame
atlas pixel/alpha changes, cleanup/fallback, stream failure/cancellation/promotion,
and native cache menu insertion/actions. Allocation microbenchmark over20000
iterations: uniform snapshots~16252KB→2.5KB; scene keys~43599KB→1.9KB. Allocation
figures are not FPS measurements.

Limits: cold initial scene/warp still builds synchronously; partial destination
work can finish synchronously if crossing arrives too early. One extra prepared
scene increases bounded GPU memory. Unsupported/replay/custom providers retain
safe immediate fallback. Full terrain/tree disk precaching and complete11-game
feature parity are separate unfinished work.

Final broad suite after HUD integration:295 passed,0 failed,58 external-fixture
skips (SDK1173 included). Subsequent adjacent-partial promotion focused tests
pass. No version bump, push or release is claimed for this performance batch.
