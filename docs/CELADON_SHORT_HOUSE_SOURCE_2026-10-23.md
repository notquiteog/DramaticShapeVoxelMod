# Celadon original single-floor house

Adds authentic HGSS `ta_h01-mesh` to the complete native FR/LG Celadon short
closed house at(20,26),4×4 drawing. This source is a single-floor building with
its original asymmetric roof, recessed windows and architectural flower planter.
It has no source doorway or native entrance; no door, sign or vent is invented.
Other Celadon tall/vented/enterable buildings remain separate source gaps.

Source [Celadon City, asset592831](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592831/),
original game art Nintendo/Creatures/GAME FREAK. Archive SHA256
`f2289da05c3190d9b21940b88f66233fc6b106198ab922aa64261384ed4b483f`;
DAE SHA256 `4a391a04af9bbad3391a35b8dd2bbe9cdda3800ff6626be0639e31ca7eab2d75`.
The156 source triangles include26 nonphysical baked-shadow triangles, which are
excluded. Original physical source130 comprises106 architecture triangles and24
live flower/leaf triangles. Keep all original architecture/UVs and both original
PNG byte streams; add34 measured closure triangles for140 architecture triangles.
The missing asymmetric rear fascia, wall, full profiled soffit and foundation
are closed. Rear wall tops split at actual soffit-triangle intersections; repeated
intersection points are deduplicated. Tests prove all140 triangles nondegenerate
and no positive-area coplanar overlap anywhere in the physical architecture,
including the original window panes and frames. The ground cap/contact ring
recess.05px without moving the upper source body, native floors or geometry.

The24 original living leaf/petal triangles become8 flat HD2D groups using the
existing cylindrical billboard shader. Original source silhouettes, UVs and PNG
bytes survive their30degree source-front projection. Tests prove no overlap
within a projected group. Each card's complete yaw radius is clamped within the
same64×48px native blocked rectangle; this can shift a flower anchor inward by
a few pixels while preserving its silhouette and scale. It does not add closed
petal geometry, source lighting or new native plant placements. Architecture
and planter remain unchanged. Characters, Pokémon and field flowers retain
existing HD2D defaults; no companion mod is required.

Uniform architecture fit is51.92px wide ×47.5px deep in64×48px, preserving source
proportions. Exact native map/origin, pair,16-cell drawing/permissions, stable
body floor, triangle clearance and atomic card/build uploads guard placement.
The existing local native grass donors8/9/16 remain unchanged. Read-only source
atlas tests show the original roof margins and those local donors are lawn;
nearby street365/374 and roof-bearing header art are excluded as plain donors.
Original native grid/warps/elevation/collision remain byte-identical. No whole
map, remaining-family or five-game coverage claim follows from this placement.

Latest official engine queried:0.3.96; standalone API3, own isolated QA profiles
and immutable native asset seeds. Exact official engine/shell hashes match the
Cerulean batch documented in CERULEAN_CLOSED_HOUSE_SOURCE_2026-10-23.md. Final
FR/LG source placement, eastern-street walking, blocked side and rear-wall
attempts, and actual walkable roof-header checks pass with process0 and no mod
errors/recovery. Full native map SHA256 remains
`38ce5f3b097f8459b0924b3f11e835758e54506b063d478d91a649cd054766a9`.

The next native building starts immediately at y30: there is no native front
aisle. Earlier fixture attempts to walk across it correctly failed against that
existing collision. Final front/quarter captures look from the valid eastern
street; rear/header and near side contacts are also inspected. The frontal
facade is partly occluded by the neighboring building in overview, and the
left side abuts an existing block. Isolated original/closed source gallery
covers all sides and underside. Inspected native close-ups show the planter,
flat source flower art and closed ground/roof joins without an observed exposed
gap or z-fighting. The separate adjacent taller vent building retains native
fallback and is not counted as a modern source. FireRed missing-source fallback
passes the same native walking route. Both editions also pass actual neighboring
Celadon Gym entry/return while the new house renders; native hashes stay equal.

Evidence excluded from Git: `.scratch/frlg-exteriors/api3-resume/out/`
`celadon_short-{firered,leafgreen}`, `celadon_short-firered-missing`,
`celadon-neighbor-entry-{firered,leafgreen}`, `celadon-ledger-{firered,leafgreen}`;
source gallery `.scratch/frlg-exteriors/source-intake/{next-views,celadon-closed-views}`.
Sixteen focused Lua source/neighbor/ground/dispatcher/flower suites and changed
Lua compilation pass; original-source deterministic/coplanar/card and both native
atlas proofs pass. No raw archive, native cache, ROM or capture is committed.

Canonical census per edition:426 maps,76 outdoors,133 identified assemblies;
81 source eligible,74 rendered accepted,52 unmatched,6324 unclassified blocked
cells. Seven eligible shared-ground review gaps remain separately identified.
Silph remains held because the genuine uniform source fills only47% of native
blocked depth. Native Saffron low houses are single-floor closed variants;
available ordinary HGSS `ybc_h03` is two-floor, so it is not substituted there.
