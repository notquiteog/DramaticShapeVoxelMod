# Battle cache regression and shared renderer work — 2026-10-15

Gen3Scene requested a nil streaming context for battles, but its completed
snapshot published a non-nil context from Gen3SceneCache. Every subsequent draw
missed SceneStream's early return, rescanned the entire visible/connected tile
window, then rediscovered the unchanged geometry signature. Keeping the same
context on request and publication removes that work. Battle center/yaw, map
and native edits remain context dependencies and still rebuild synchronously;
replays retain their uncached path. Connected scenery is not reduced.

Shared DrawUniforms now snapshots vector values as well as matrices/scalars.
Battle cutaway floor/view/target values and foliage target vectors no longer
upload identical data for every terrain draw. This consumer is shared by all
three generations. In-place camera changes, shader/pass changes and failed
uploads still invalidate/retry. No geometry, lighting quality, distance default,
actor animation or UI behavior was intentionally changed.

## Evidence

Official Gen1Recomp0.3.88 was checked through the GitHub release API. Native
runtime: `.scratch/runtime-0.3.88/squashfs-root/bin/love`, source in its `engine`
folder, checkout linked as `mods/BATTLE_ART_VOXEL_FORK`. Private Gen3 imports
from0.3.86 and disposable `gen3-*-qa` profiles were reused; player saves were
not touched. No companions were enabled in this test engine.

- Emerald Route104,1280x720,AUTO distance,shadows ON:120 stationary battle
  frames before the change performed120 terrain scans/0 cache hits; after the
  context fix,0 scans/120 cache hits. Both images inspected: terrain, both
  animated combatants, shadows and native UI remain rendered.
- Whole Scene.draw time on **llvmpipe** was135.294ms before and161.320ms after.
  These were separate software-rendered runs with concurrent machine work;
  they do **not** establish an FPS improvement. The NVIDIA run failed GLX
  context creation and `nvidia-smi` could not communicate with the driver.
- Final-code bounded tests in all five Gen3 editions at480x270,LOW distance,
  shadows OFF:30/30 cache hits,0 terrain scans each, camera orbit remains
  active, and native `abort('run')` returns with both battle/stage inactive.
  All five rendered captures inspected. These reduced settings are fixture
  settings only, not changed production defaults.
- Scene-cache regression test executes the production request policy with
  real keys/streaming:120 stable hits, immediate yaw/edit/overworld transitions.
  Existing stream/cache/occlusion tests pass. Vector tests verify120 identical
  sends collapse to1, mutable values and lengths invalidate, and failed sends
  retry. Shared SDK suite:1173/1173 checks passed on0.3.88.

Drivers/logs/captures: `.scratch/battle-perf-20261015/` (`gen3.lua` paired
720p runs, `smoke.lua` final five-edition runs). The runner returns1 after its
quit path even when the final cleanup record is printed; treat the explicit
assertions and captures as evidence, not a clean process-exit certification.
The original720p fixture used an arbitrary abort result and did not complete
its cleanup assertion; the final smoke fixture uses the native 'run' result.
All test processes ended; live player game was not stopped.

Yellow and Crystal native battles also passed stage/orbit and zero-gap actor
footing assertions on the same runtime; captures were inspected. These are
representative shared Gen1/2 consumer checks, not all six editions or an FPS
benchmark (`.scratch/voxel-parity-20261015/battle/`).

Remaining: hardware frame-time verification, further profiling of GPU shadow/fill cost, and the
separate feature/consumer gaps in the live option-support inventory. This work
is not a claim of complete optimization or full11-game feature parity.

## Diagnostic parity follow-up

Actual runtime verification found the public performance provider was entirely
absent from Gen3's early-return install path. It is now exported in all five
Gen3 editions, with native scene/stream/compressed-geometry counters. Those reads
avoid loading GB-only mesher/cache facades or enumerating storage. The native
`gen3` integration namespace also has matching LeafGreen/Ruby/Sapphire aliases,
joining the existing FireRed/Emerald aliases. Public API/version remain backward
compatible; no companion is required.

All eleven current-engine startup contract runs pass (each game's public API,
correct version/generation, alias identity, detached counters). The producer
unit tests additionally verify unchanged Gen1/2 diagnostics and no GB/storage
work on Gen3. Reusable fixture: `tools/qa/performance-provider.lua`; actual run
logs under `.scratch/battle-perf-20261015/diagnostics-*/`. Existing legacy fields
are not mislabeled as native work; see `docs/PERFORMANCE_API.md`.

## Sprite bounds follow-up

Shared SpriteHeadBounds now scans retained BattleArt ImageData instead of
round-tripping owned images through a GPU canvas. Native fitted battle images
also reuse CPU bounds when their nearest-neighbor sampling is unambiguous.
Driver-sensitive texel-boundary fits and other providers retain GPU measurement;
no artwork, transforms, foot anchoring or animation timing changes.

The current-engine GPU comparison fixture checked 96 fitted images spanning
four source sizes, three destinations, mirroring and four scales. All measured
bounds matched; 56 used CPU bounds and 40 retained readbacks. This is a fixture
coverage count, not an FPS claim. Unit checks assert owned-image queries do not
access graphics and repeat queries reuse the cached bounds. SDK1173/1173 and
world battle projection/grounding/error-restoration tests pass.

Fixture: `tools/qa/sprite-bounds.lua`; log:
`.scratch/battle-perf-20261015/sprite-bounds/run.log`.
