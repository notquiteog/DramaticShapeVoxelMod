# Continuous water material, 2026-10-20

The default FULL and optional SKY water modes now use a continuous, smooth material across all eleven games. The source texture supplies alpha coverage, not per-pixel RGB wave bands. OFF retains the native fallback. Characters, Pokémon, flowers, gameplay collision and native shore-floor classifications are unchanged. This is a calm pond/coastal-water treatment, not a claim of complete storm-ocean simulation.

The material evaluates three analytic waves and their gradient once, filters distant ripples by fragment footprint, uses smooth Fresnel reflection and a small sun/moon highlight, and applies depth absorption where a safe underwater color source exists. It removes the old stepped relief traversal, neighboring height samples, voxel-grid seams and pixel-normal reconstruction. It adds no render pass or texture copy. Existing FULL/SKY/OFF controls and standalone operation remain intact.

Four programs cover precise/compact FULL/SKY; grid options reuse the same programs. Actual NVIDIA shader reflection reports 8/5/8/5 active samplers, including the implicit source texture. Precise FULL retains its separate underwater-color texture and uses the sky fallback without a cloud-atlas sampler. Compact FULL reuses the reflection RGB texture for underwater color and retains clouds. Both SKY programs retain clouds. This stays within the existing eight-sampler budget; desktop compilation is not proof of every mobile driver implementation.

Curved compact color snapshots may already contain native water RGB. Such snapshots disable color transmission only; packed depth and foreground occlusion remain enabled. A distinct precise underwater-color texture retains transmission under curvature. The native GPU test reconstructs a four-pixel submerged bed with curvature 0.0001: changing the compact snapshot from plain RGB to alternating stripes changes guarded output by exactly zero; enabling transmission as a positive control changes RGB by 0.317647. This checks the actual positive-depth path, beyond the no-underwater-input case.

## Correctness and visual evidence

Focused tests cover default selection, four-program reuse and release, bounded continuous wave gradients, source-RGB independence, curvature transmission policy, and preserved depth/occlusion. Existing precision and reflection suites pass. The battle-art source contract suite passes 1,147 assertions after replacing obsolete pixel-wave expectations.

On official Gen1Recomp 0.3.91, LÖVE 11.5 and NVIDIA RTX 5060 Ti/OpenGL 3.3, the GPU driver renders two deliberately different opaque source RGB textures with equal alpha. Both SKY families produce identical output (maximum RGB difference zero). A half-transparent input retains exactly 2,048 transparent and 2,048 painted pixels on a 64×64 target. All four shader variants compile, and grid requests reuse them.

Clear native views were inspected in Red Pallet Town, Gold's Cherrygrove shore and Emerald Route 104, including 35-degree, first-person, sun-facing and later ripple phases. The ordinary native fog options are preserved; QA-only clear-view wrappers disable haze to expose surface defects. The accepted views show continuous ripples, retained bank/actor reflections and native shore boundaries. Existing eleven-game grass/depth evidence predates this material; exact final-archive material checks are recorded separately after packaging.

## Controlled shader cost

This is a paired shader workload, not a whole-release FPS comparison. The before/after source snapshots contain 12,350 files each and differ only in `lib/Water.lua` and `lib/NativeWaterSurface.lua`; imported trees, depth geometry and scene code are identical. Files and SHA-256 values are preserved in the scratch evidence directory. A subsequent narrow curvature guard does not execute in these flat, underwater-input-disabled kernel fixtures.

Four serial runs use B/A/A/B order, a 768×512 water quad, 24 draws per batch, 24 warm-up draws and 16 measured batches per segment. Each measured batch flushes and reads back the complete canvas, ensuring GPU completion. Values include CPU submission, canvas switches and readback; they are not GPU timestamps or native-game FPS. The table averages the two run medians per variant, in milliseconds per 24-draw batch.

| Workload | Prior material | Continuous material | Change |
| --- | ---: | ---: | ---: |
| GB SKY | 1.290705 | 0.560902 | −56.54% |
| GB FULL | 2.402432 | 1.550885 | −35.45% |
| GBA SKY | 0.596744 | 0.548687 | −8.05% |
| GBA FULL | 1.609710 | 1.554968 | −3.40% |
| Flat control before | 0.316814 | 0.325826 | +2.84% |
| Flat control after | 0.322120 | 0.308830 | −4.13% |

The GB reduction clearly exceeds control variation. The GBA FULL difference is within the observed control variation; it supports no reliable speedup claim. GBA SKY is a small measured change in this particular workload. No universal FPS improvement is claimed.

Evidence root: `/home/admin/Projects/.scratch/realistic-water-agent-20261020`. Raw kernel results are `timing-material-{b1,a1,a2,b2}/water-material-benchmark.json`; GPU correctness is `guard-positive-depth-gpu/water-material-gpu.json`; clear views are in `clear-{red,gold,emerald}`. Reusable drivers are `tools/qa/water-material-gpu.lua`, `water-material-benchmark.lua`, `gb-surface-benchmark.lua` and `gen3-surface-benchmark.lua`.

## Native whole-frame controls

Four serial native runs cover Red Pallet Town/Oak's Lab and Emerald Route 104/Birch's Lab, each in 35-degree and first-person cameras with FULL/SKY/OFF. Each segment warms 60 frames, measures 180 frames, records public profiler CPU samples and frame intervals, and captures the scene. All four runs exit successfully; all 48 captures were inspected. Water/bank positions and indoor geometry remain consistent, while FULL/SKY remove the old visible pixel bands. The Emerald map's native source/collision/elevation digest agrees across both shader snapshots.

The paired native observations do **not** establish a whole-game speedup: OFF and water-free indoor controls drift as well. For example, Red 35-degree shoreline mean intervals move from 11.837 to 12.093ms in FULL and 11.334 to 12.980ms in OFF; Oak's Lab 35-degree OFF moves from 10.657 to 11.165ms. Emerald 35-degree shoreline moves from 13.376 to 13.733ms in FULL and 12.483 to 13.804ms in OFF; Birch's Lab 35-degree OFF moves from 11.083 to 11.627ms. Reflection-dependent native draw counts also vary with frame phase, so the controlled shader batches above are the narrower useful cost evidence. No GPU timestamp, total-game FPS gain or universal performance guarantee is inferred.

Raw native reports/captures are `timing-native-{before,after}-{red,emerald}`; all 24 paired segment metrics are tabulated in `native-matched-comparison.tsv`. Native windows were serial on the same NVIDIA renderer, at 1280×720, distance16, AA/FSR disabled and VSync disabled. The matched snapshot hashes identify this specific renderer comparison; subsequent unrelated metadata-only source fixes are not relabeled as measured final-package timings.
