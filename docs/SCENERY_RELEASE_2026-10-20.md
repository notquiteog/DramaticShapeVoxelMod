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

The fresh source archive at commit `9de17d44d435d268868fdc777925e2f18b703127`
was extracted into an empty installed folder and used by every final native run.
Its tested ZIP SHA-256 is
`64909ad6ce6fa15d16de2c78ce00926aa85a726ee85b9d208fdec2b013dbf6e0`.
The ZIP contains11,518 files and529 Lua files, all syntax-compiled. Raw source
archives/DAE/OBJ files, ROMs, saves, caches, tools and tests are excluded. Two
pre-existing `unused.zip` asset archives are excluded too; no runtime references
use them. Selected processed Lua models, original selected PNGs and provenance
are included.

Every runner verifies version1.53.0/cache108,529 actual mounted library/scenery/
entry-file hashes, realistic-water and solid-tree schema defaults, NVIDIA and all
eight water shader requests (four shared programs). Thirty standalone native
runners and two all-six-partner runners pass with no mod errors. All404 final
captures were inspected:

| Native final archive check | Runners | Inspected captures |
| --- | ---: | ---: |
| All-eleven water/material/native support | 11 | 156 |
| Six GB grass/native masks/fallback/cleanup | 6 | 84 |
| GSC +five GBA tree/source/fallback/boundaries | 8 | 110 |
| Five GBA native Cut/Surf and cleanup | 5 | 30 |
| FireRed +Ruby with all six published partners | 2 | 24 |

Water and GB grass captures also received independent review. Tree checks retain
complete native owner footprints, colors, protected projected/walkable cells,
saved cards, missing-asset closed-model fallback and ordinary merged uploads.
Some Petalburg orbit views are distance-haze controls; clear Littleroot views,
Petalburg low-eye/cases and actual source/GPU/native-input checks establish the
reviewed RSE tree behavior, as the tree report records.

Five actual GBA field-move callbacks remove imported grass on native Cut:
FR/LG120→116 placements and R/S/E37→34, then retain the expected source edit.
Native Surf hops succeed at Pallet `(7,16)` and Route103 `(49,7)` in R/S or
`(44,7)` in Emerald. Their land0/water−8 Kanto or−4 Hoenn support is consistent
in third/first person, with unchanged native source/collision/elevation digests.
These field callbacks use QA-supplied party data and do not test badge/menu/HM
eligibility. GB checks exercise a presentation Cut rectangle, not its HM menu.
All eleven grass/unload runners verify six unique cached grass/bank/tree PNG
images are released after scene owners at the public launcher-quit boundary.

Optional partner smoke versions: Wilds1.15.2, Sky Ride0.5.5, Doubles0.14.4,
Online0.11.2, Overworld Spawn2.6.5 and Modern UI0.4.2. Native shore/lab scenes in
FULL/SKY/OFF and35°/first-person pass. The existing spawn crowding and indoor
capture HUD remain documented limits; smoke checks do not establish complete
multiplayer parity or every paired battle feature. Unpublished Doubles changes
are not included.

Final evidence amendments change documentation only. The package is rebuilt
from the final commit and the complete runtime-file SHA-256 map is compared with
the tested archive, preserving every tested library/data/asset/vendor/entry byte.
The published ZIP checksum is supplied separately with the GitHub release.

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
