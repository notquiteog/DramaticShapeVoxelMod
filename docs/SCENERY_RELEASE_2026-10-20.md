# 1.53.0 scenery release verification

This incremental batch covers the shared realistic-water material, recessed native
waterways, imported ORAS grass, matching ORAS broadleaf trees and native-faced BW2
signs. Prepared Center/Oak catalog assets are not automatic native placement.
Characters, Pokémon and flowers remain HD-2D. Native gameplay, collision, scripts,
warps and base UI remain engine-owned. Manifest hard dependencies remain empty.
Regional authored coverage remains 84/125 complete, with 41 queued.

## Runtime and evidence boundaries

The latest official release was checked again through the public release API:
Gen1Recomp 0.3.91, published 2026-10-19, source tag
3806bf3df53f650e235b09f8d76feb731c30a076. Native checks use its actual LÖVE11.5
runtime and NVIDIA RTX5060Ti/OpenGL3.3/615.71.09. Native screenshots are inspected;
Lua tests alone do not establish visual approval. QA profiles are disposable;
player saves are untouched. Desktop evidence does not establish phone timing.

Earlier grass/bank/catalog captures in their linked documents predate the final
realistic shader and tree adapter. They establish their stated source masks,
collision/data invariants and model conversion only. Final package checks below
must be read separately; no earlier image is relabeled as final code.

## Source checks

The final coherent source, including the curvature guard and connected-map
identity checks, passed364 Lua suites, zero failures, with58 explicit unavailable
external-fixture skips. Focused shader tests and actual GPU checks also pass. Six supplied-archive
scenery tests pass; original grass binding, 168 original bind-pose vertices,
sampler wrap, deterministic conversion and PNG bytes pass. Bank asset checks
cover3 unchanged PNG hashes and7744 opaque texels, including bare-cliff faces.
The source-tree importer retains108 source triangles/UV/RGBA, adds252 separately
credited closure/rotated-source triangles, verifies closed bark and rejects
coincident added triangle faces; original textures and deterministic output pass.

Root-native source checks inspected20 FireRed/LeafGreen model/camera views:
Pallet conifers retain their closed native-family 3D models; Safari broadleaf
owners use the actual imported model. Uploaded source vertex colors/positions
and complete blocked owner bounds are checked through the actual Mesh API.
Three Gen1 Route1 runs each verify416 native8px grass placements, native walking,
16 removed Cut presentation subtiles, restoration, missing-image fallback and
non-instanced GPU uploads. Selected source/35-degree/four-direction first-person
and fallback captures were inspected. Gen1 mature one-cell/conifer families keep
their existing models; no source-model replacement is claimed for those trees.

The native FireRed deep-water battle fixture proves the previous gap and fix:
Route21 North center152,696, arena fillOFF, native terrain4, nativeFloor0.
Before: actor/camera support0 above actualwater−8. After: support and both HD-2D
actor points−8 while the native floor remains0. A native wild Tentacool battle
and actual surf avatar are used; this is a presentation fix, not a gameplay edit.

## Final archive checks

Pending the final source freeze and exact archive run. Do not treat this section
as completed verification until the checked package record is entered here.

## References and limits

- [Continuous water and bounded performance evidence](REALISTIC_WATER_2026-10-20.md)
- [All eleven games: explicit remaining model inventory](ALL_ELEVEN_MODEL_COVERAGE_2026-10-20.md)
- [Real source grass and masks](IMPORTED_GRASS_2026-10-20.md)
- [Native banks and source water-depth measurements](GEN3_WATER_BANK_REFERENCES_2026-10-20.md)
- [GB bank/grass source verification](GB_IMPORTED_GRASS_WATER_2026-10-20.md)
- [Tree source geometry, completed surfaces and supported families](IMPORTED_TREES_2026-10-20.md)
- [Catalog materials, source credits and prepared-only buildings](STATIC_SCENERY_CATALOG_2026-10-20.md)

This is not a completed eleven-game AAA remaster or an all-map FPS claim. Narrow
fragments, unmatched tree families and third-party overrides retain their existing
models. Native shallow-shore foam remains source artwork. A single combined map
water mesh with several authored heights still has a dominant reflection plane;
neighbor-map sheets are grouped separately. Optional partner smoke checks do not
prove every multiplayer or battle combination. Unpublished concurrent Doubles
work is preserved and excluded; published partner releases are used for QA.
