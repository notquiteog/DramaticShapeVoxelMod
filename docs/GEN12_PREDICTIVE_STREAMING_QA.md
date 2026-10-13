# Gen 1/2 predictive streaming — 2026-10-13

The latest checked official runtime was Gen1Recomp 0.3.85. Testing used isolated Yellow/Crystal profiles, loaded worktree source, and serialized Xvfb runs.

Crystal connections contain both a numeric `map` identifier and the string `mapId`; predictive warming previously selected the numeric field and missed connected routes. Prediction now uses the native string identifier, `World:resolveWarp`, `World:connectionMap`, and `World.computeNeighbors`. Dynamic upstairs/elevator exits retain their native destination resolution. Full meshes receive the same connected-body masks as the live world.

Both generations now cancel unrelated speculative jobs when leaving an area; jobs promoted to visible priority remain protected. OFF and LIVE CACHE retain their existing no-prediction semantics. No render-distance, geometry, texture, or foliage quality reduction.

## Focused evidence

- Crystal New Bark Town: four warp candidates previously; six candidates now, including Route 29/27. Observed both route full meshes completing before departure.
- Native New Bark → Route 29 crossing, same profile/scene/driver: baseline full mesh absent before crossing and four additional rendered frames before it became ready; corrected version ready before crossing, zero pending frames. Single comparison, not an FPS benchmark or statistical latency claim.
- Yellow Pallet → Route 1 retained its existing ready-before-crossing behavior: zero pending full-mesh frames after this change.
- Native generation tests cover numeric/string connection fields, dynamic warp resolution, destination map construction, neighbor masks, body-job discovery and cancellation of obsolete predictions.
- Engine modkit: 1173/1173 Battle Art checks and 22/22 RAM precache OFF integration checks passed.

The captured CPU/presentation timings are dominated by this Xvfb setup and do not establish a general GPU or frame-rate gain. Broader walking/running performance and large forests remain separate profiling targets.
