# Original ORAS Oldale backed chairs

The three guarded RSE home-chair families now use the original Alpha Sapphire Oldale wooden chair: 91 Emerald, 95 Ruby and 95 Sapphire placements across 32/33/33 edition-room instances. These are component approvals only. FireRed/LeafGreen coverage is unchanged; no whole map is accepted by this batch.

## Source and geometry

The original linkage is ZO230 → AD115 → MM171 → GR513, model `t102r0101_00_00`, submesh 1/material `t102_chair`. The reproducible importer selects one complete chair from the room mesh: four legs, shaped seat, curved closed back, two posts and two spindles. Provenance records original model/texture/decoded-pixel hashes and bounds. Original opaque 32×64 texture and UVs remain; vertex lighting becomes white.

The original selection contains 154 triangles. Clipping buried leg ends at the actual seat underside yields 170 exposed source triangles. Another 100 triangles close exposed undersides/recesses, for 270 total. The seat underside excludes all eight vertices of each leg intersection, including two slightly concave rims. Exact source-area subtraction matches 147.2210765244189 square source units; no cap crosses an internal leg joint. Buried post ends receive no internal caps. Four source floor contacts differ by less than 0.00003 units and alone snap to their common contact plane. No upper geometry, room plane, floor, light or shadow is added.

The source uses one uniform scale within the native one-cell footprint. Native left/right chairs rotate by one/three quarter turns; their original seat/back proportions remain. Only physical ground contacts recess 0.025 pixels. Tests verify upper vertices remain unchanged, all feet touch the same plane, both rotations stay within bounds, and all seventeen imported interior source models have zero positive-area coplanar overlaps.

Eligibility requires the exact RSE home pair, native metatile identity (555/556/738), design, one-cell dimensions, zero collision and native height signature. Native floor, collision, elevation, warps, actors, scripts and gameplay remain native. Missing any required source texture retains the existing atomic native furniture fallback.

## Native verification

Latest official release was checked before the coherent batch: v0.3.96. Tests used an isolated official .96 engine, API3 mod checkout and independently writable profiles cloned from genuine imported caches. Standalone source and missing-texture runs passed all 98 affected edition-room instances and all 281 owner placements. Source review covered every room overview, every individual front view, 281 whole-component views, and 222 available walkable side views. Nine source-model angles include front/back, sides and both undersides. Missing-source room overviews retain native furniture correctly. HD2D seated actors remain independent and can naturally occlude chair seats.

Fresh adapter census covered all 2,161 maps across all five editions. Every native map hash and furniture-family count matches the previous census. The only candidate delta is these 281 chairs: candidate totals are E556/R515/S515/FR398/LG398 (2,382). The separate accepted-component ledger now has 2,337 components across 280 edition/map pairs; all map-level `renderedAccepted` flags remain false.

During native map entry, the engine changes Steven's house cell (6,4) from `[721,7,3]` to `[753,7,3]` in all RSE editions. Ruby/Sapphire Game Corner also changes (3,0) `[515,7,0]` → `[653,7,0]` and (3,1) `[537,114,3]` → `[661,7,3]`. These native script deltas are recorded separately; hashes remain unchanged across subsequent furniture generation/rendering. Source and missing-source runs are recorded in `coverage/gen3-interiors-2026-10-23/oldale-chair-runs.jsonl`.

Checks passed: exact original data/contact/union test, seventeen-model surface-plane test, guarded home-furniture/failure-fallback test, SDK-backed scenery fit/resource test, clean importer regeneration (Lua/PNG/provenance byte-identical), Python compilation and diff whitespace checks. Captures, raw BCH files, caches and profiles remain local scratch evidence.

## Remaining coverage

This batch does not accept existing generic room framing, wallpaper transitions, other service/research furniture, or any whole map. Some room wall fixtures still project into rooms, notably generic Trick House/Rustboro framing. Those wall/opening families require their own native boundary and plane review. Source eligibility in the all-map inventory continues to be distinct from rendered acceptance.
