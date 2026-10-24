# Cerulean closed-window house

Adds the original HGSS Cerulean `ha_h01b-mesh` only to the complete native
FireRed/LeafGreen Cerulean City short drawing at (31,25). It has no door in
either source or native map; it does not acquire a doorway or warp. Other
Cerulean houses and the Bike Shop remain separate unmatched families.

Source: [Cerulean City, asset592833](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592833/).
Archive SHA256 `93213bd623a031574bbaf35fe315724c518bc667119714c0470206b635f3732e`;
DAE SHA256 `16016239d286fbeba49961943b3d5f28745040c49a01af5c9f3bffd6ae5fadf1`.
The deterministic importer retains all168 physical source triangles, UVs and
both original PNG byte streams, excluding8 baked-shadow triangles. Measured
rear siding, beam/gable, original roof fascia, profiled soffit and recessed
foundation close the original cut surfaces:206 processed triangles. Rear art
contains no invented windows, vent, door, sign or ornament. Provenance keeps
original full bounds, which include the excluded shadow; physical source bounds
are X[-30.95312,30.95312], Y[2,50], Z[-28,18].

The uniform fit is63.92px wide ×47.5px deep in the native80×48px blocked body,
without stretching source proportions. Exact map/origin, pair,20-cell MID and
permission matrix, stable body floor and triangle/collision clearance guard the
placement. The roof-header walkable row stays outside the fitted body. Native
MID/collision/elevation/warp data and floors are unchanged. Source contact rings
and underside recess.05px under ground; upper geometry stays at its source datum.
Missing assets or upload refusal retain the existing native-derived fallback.

The original native foundation/roof margins are lawn. A nearest-road inference
had selected sand212/228 beneath the old drawing. This exact recipe now uses
clean grassMID1. Read-only native atlas tests verify exposed header margins and
the lower-left foundation lawn against the original grass palette in both games,
reject road donors and roof-bearing header artwork as plain floor donors.
Actual source roof geometry remains upright; roof pixels are never flattened.

Latest official release queried before this batch:0.3.96. Standalone API3 Battle
Art, original official engine SHA256
`c79b51b1b2fb53bc8a066307af9423e8da76f3a72e6affb47081b7ef7f57171b`,
Linux shell LÖVE11.5/AppImage SHA256
`7f069ffd953efbacbb62ae6339f8f10f15460d326d689d030c5d1c7b44eb48b3`.
Own isolated QA profiles use immutable imported seed assets; user saves unchanged.
Both editions pass overview, quarter/front/side/rear and first-person capture,
real front and right-side collision attempts, continuous native frontage/right
perimeter walking, no-warp check and unchanged full-map SHA256
`aed68bfe91dac11cfe83f774c4a1048c33c483783bd500950ba0cab393aa2219`.
Inspected final FR overview/side/rear and LG front/quarter/walking captures show
closed contact with the native grass, no observed ground/wall overlap or exposed
gap. LG missing-asset fallback also passes native walking. The neighboring
Cerulean Mart passes real source-door entry and return in both editions.

Scratch evidence excluded from Git: `.scratch/frlg-exteriors/api3-resume/out/`
`cerulean_closed-{firered,leafgreen}`, `cerulean_closed-leafgreen-missing`,
`marts-{firered,leafgreen}`, `cerulean-ledger-{firered,leafgreen}`.
Each final process returns0 with PASS. The earlier walking fixture held input
through a completed step and overshot by one tile; final driver releases when
the first native step starts. Production movement was never altered.
Fourteen focused Lua source/neighbor/ground/dispatcher suites and changed-file
LuaJIT compilation pass. Import regeneration is byte-identical. Native source
proof: `tests/gen3_cerulean_closed_house_ground_source_test.py` with both imported
`generated/gba` roots; raw caches/captures/archives are not committed.

Updated identifier-only census:426 maps,76 outdoors,133 assemblies per edition;
80 source eligible,73 rendered accepted,53 unmatched,6324 unclassified blocked
cells. The7 eligible shared-ground review gaps remain separate. This is one
family's acceptance, not complete map/game coverage. Silph's authentic uniform
width fit fills only47% of its blocked native depth and stays on hold; do not
stretch it or claim that source presence proves usable placement.
