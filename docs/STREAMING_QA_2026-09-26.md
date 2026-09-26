# Scenery streaming and first-person height — 1.28.4

Engine: official Gen1Recomp 0.3.20, native LÖVE/OpenGL 3.3, Linux,
RTX 5060 Ti / NVIDIA 615.71.09. QA root:
`/home/admin/Projects/.scratch/ascendant-20260926`.
Isolated `ascendant-*-qa` profiles, no-sync, existing imported ROM data.
The user's running AppImage/save was not modified.

## Implementation

Gen3 retains one complete terrain window and builds one replacement using the
shared coroutine budget (2 ms target per draw). Geometry and metadata publish
atomically. A reversed request cancels its candidate; map/layout/provider
changes, replay and battle culling rebuild synchronously to avoid stale scene
coordinates or gameplay edits. Cancellation releases partially uploaded meshes,
civic images and tree placement buffers. Current-map tile animation binding is
restored after each slice. Upper-atlas replacement also invalidates geometry.

Native hull generation yields between rows/planes. Shared mesh uploads check
the cooperative deadline before allocating. These are safe no-ops outside the
owning build coroutine. Crystal retains the existing Gen1/2 queue, registers
placement buffers before yielding, and reuses tree pixels instead of rereading
the ground palette for every placement. Gen1 keeps its existing authored geometry
and queue; no Gen1/2 frame-rate improvement is claimed from this run.
Gen3 furniture candidates are indexed by source tile without changing recipe
priority, room scoping or animated escalator aliases.

First-person default framing rises four native world pixels: GB 8 → 12;
FRLG 9.5 → 13.5 with the native visible-foot anchor. Larger provider frames scale
the default; explicit provider eye rows still win. Grounding, hops and ride lift
are unchanged.

## Benchmark

`tests/scenery_streaming_driver.lua`: Viridian Forest at (10,20), rotating-third
camera, AUTO distance, balanced modeled trees, AA0, spatial upscale off, native
2560×1440 fullscreen, vsync off. Artificial 135px movement over 180 frames plus
30 settling frames, preceded by warmup and a stationary sample. This tests
rendering, not collision/gameplay. Map preview is explicitly dismissed.

`run-display.sh leafgreen streaming-reference` uses the previously released
1.28.3 archive. `streaming-final` uses the new source; runs were sequential on
the real display. Xvfb runs and an earlier concurrent measurement were excluded.

| Traversal (210 frames) | 1.28.3 | 1.28.4 source |
| --- | ---: | ---: |
| Mean ms | 4.56 | 4.61 |
| p95 ms | 5.20 | 7.03 |
| Maximum ms | 53.28 | 10.57 |
| Completed replacement windows | 2 | 2 |

Stationary means: 3.88 / 3.91 ms. Maximum cooperative slice measured 5.80 ms:
an individual GPU call, allocation or GC can exceed the 2 ms target. This is
reduced peak latency, not less work or a guaranteed frame-time ceiling. Cold
map loads, battle/replay rebuilds and individual GPU uploads remain synchronous.

## Checks and rendered evidence

- LuaJIT compilation of all production modules.
- Focused tests: scene_stream, streaming_geometry (149 yields; identical complete
  vertices/indices/UVs/shading), voxel_build_budget, voxel_hull,
  native_tree_models, native_tree_art, model_instances, gen3_scene_cache,
  gen3_starting_furniture, gen3_additional_furniture, gen3_center_furniture,
  camera_eye. All pass.
- Native `scenery_streaming_lifecycle_driver.lua` in LeafGreen: previous window
  stays visible; reversal cancels; candidate completes; warp into Oak's lab
  cancels the forest candidate; invalidation recovers; camera stays active.
- Native `scenery_streaming_legacy_driver.lua`: Crystal Ilex forest (47 completed
  instance sections), Elm's lab; Yellow Viridian forest and Oak's lab using its
  existing authored terrain path. Queue completes; first-person height 12.
- Packaged 1.28.4 ZIP reinstalled into the isolated runtime and passed the same
  streaming lifecycle fixture in FireRed (`results/firered-streaming-archive`).
  Archive SHA256: `2a439c1bdb36e4c0584f841d6a8044b78a1ee098a1aed769bc61d147089f5dfb`.
- Native `house_polish_driver.lua`: Yellow/Crystal house cameras at 12; LeafGreen
  stairs/dresser/Mom. FireRed `gen3_house_exit_driver.lua`: real door input,
  FAR/FULL, three cameras, eye 13.5, no camera fallback, genuine GPU error cleanup.
- Inspected captures: `results/{yellow,crystal}-streaming-legacy/forest.png`,
  `results/leafgreen-streaming-lifecycle/{forest-complete,lab-after-cancel}.png`,
  `results/{yellow,crystal}-house-polish/*1F-first.png`,
  `results/leafgreen-house-polish/dresser-first.png`. Forest geometry remains
  complete and lab furniture survives the pending-work cancellation. Raised
  house views retain grounded furniture and room walls.

Legacy `legendary_tree_runtime_test.lua` stops on a missing TreePresentation
setting in its mock fixture; `cut_mesh_refresh_test.lua` requires the engine's
unavailable tests.harness. Neither is counted as passing. Focused scheduler and
native scene tests above exercise this change. No all-map, multiplayer or
Android certification. Tree/grass appearance, all-map polish and companion
feature parity remain separate unfinished work.
