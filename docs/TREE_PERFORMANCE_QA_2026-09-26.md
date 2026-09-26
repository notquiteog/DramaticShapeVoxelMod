# Native trees and performance — 1.28.2

Gen1Recomp 0.3.20, OpenGL 3.3, NVIDIA 615.71.09 / RTX 5060 Ti. Disposable Yellow/Crystal/LeafGreen profiles; source checkout loaded through QA-only mod links. User saves and options were not changed. Scratch evidence: `/home/admin/Projects/.scratch/ascendant-20260926/results`.

## Measured bottleneck

`tests/gen3_performance_driver.lua` boots LeafGreen's Viridian Forest at (10,20), selects rotating third person, native modeled trees with BALANCED detail, AUTO distance, AA/FSR/tilt-shift off, and a 2560×1440 fullscreen viewport. It warms 120 frames, measures 180 rotating stationary frames, then synthetically advances the public player pixel position 135 pixels over another 180 frames. This isolates rendering: it does not test real movement or collision. Both traversal runs rebuild the scenery window twice. Companions remain loaded.

| Metric | Merged models | Shared GPU models |
| --- | ---: | ---: |
| Stationary mean frame | 3.73 ms | 3.64 ms |
| Traversal mean frame | 17.46 ms | 4.48 ms |
| Traversal p95 | 4.08 ms | 5.75 ms |
| Largest traversal frame | 1301.43 ms | 64.00 ms |
| Tree vertex copying, traversal total | 1431.11 ms | 0 ms after warmup |
| Mesh creation/upload, traversal total | 945.25 ms | 5.87 ms |

The large improvement is the rare rebuild stall, not normal rendering throughput. The p95 did not improve in this short sample; residual rebuild work is still synchronous. GPU timers were not used; instrumented function timings measure CPU elapsed time. Logs: `leafgreen-performance-build/run.log` and `leafgreen-performance-instanced/run.log`.

Initial Xvfb results (~39 ms) spent ~36 ms in present and are excluded from performance conclusions. Real-display exploratory windowed Crystal Ilex / LeafGreen forest runs were approximately 3–4 ms stationary; window manager resizing reduced their viewport height, so they are not claimed as 1440p benchmarks. Only the fullscreen traversal above used a confirmed 2560×1440 scene.

## Changes and checks

One immutable model is retained per native tree artwork/detail variant. Scene windows own small instance-position buffers, released on rebuild. Main and shadow shaders share the same placement transform. Unsupported instancing devices use the existing merged path. OFF shadows skip allocation and submission, not just shadow sampling: the native test recorded zero shadow passes after the fix versus 180/180 before.

Five native model families use the original pixel palettes and correct wide/narrow footprints; no ROM art is included in the package. Crystal New Bark, Ilex, Celadon and LeafGreen Pallet/Viridian captures were inspected together. This is representative tree review, not certification of every map; Ilex overview framing/crowd density still needs polish.

Unit checks cover tree families/footprints, shared-image variants, instance buffer ownership and fallback, shader cleanup after draw errors, disabled-shadow zero-GPU work and closed model faces. Native GPU comparison matches instanced and merged color/shadow pixels exactly from four cardinal views and verifies the following ordinary mesh draw. Post-change Pallet, Viridian and Oak's lab overview/first-person captures cover scenery and a busy unrelated interior. Yellow and Crystal native smoke checks cover the common shader path. Complete all-map and multiplayer/feature parity remain unfinished.

## Cross-generation follow-through

Crystal's spatial tree sections now hold native model instance batches; map offsets, wind, culling, battle foliage masking and the nearest-section shadow budget use the same shared draw path. Live placement buffers are rebuilt through the existing cooperative queue instead of restoring transient native-atlas UVs from another session. Shared GPU prototypes are weakly cached; live scene batches retain ownership and evicted palettes/detail variants can be collected. Native merged geometry remains the fallback.

Gen 1's authored procedural variants and map/chunk cache remain unchanged: they already persist across walking frames. It is **not** switched to a generic repeated tree model. All generations now avoid re-sending unchanged scalar draw uniforms; shadow camera uniforms are sent once per pass. Unit tests cover scene/shader invalidation. GPU/smoke checks cover FireRed, LeafGreen, Crystal and Yellow. The measured 95% rebuild-stall reduction applies to the LeafGreen test above, not to every generation or scene.
