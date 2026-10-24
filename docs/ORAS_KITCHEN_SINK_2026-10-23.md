# Genuine ORAS Oldale kitchen units

The original Oldale sink/worktop replaces all 39 matching generic RSE kitchen
units, 13 in each edition. Native 2D art shows a basin/faucet on the left and
a dish/counter area on the right. The original ORAS unit retains that layout,
with its newer hob, drawers, three dishes and two colored ceramic cups. Nearby
native drawers and refrigerators remain independent objects.

Source: Alpha Sapphire ZO230 → AD115 → MM171 → GR513,
`t102r0101_00_00`, submesh 12, `sink01`. All 484 original triangles and their
positions/UVs remain unchanged apart from uniform normalization. Nitrogen
independently agrees with the selected geometry. The original 128×128 PNG is
preserved. Original ceramic tints remain; grayscale source vertex shading is
removed. No floor, source shadow or light geometry is selected.

The 86 authored triangles close vessel bottoms, the actual faucet spout top,
cabinet underside and exposed counter underside. The counter and base meet at
the same source height. Convex clipping partitions the 132-square-source-unit
exposed underside around the cabinet footprint; no second base lid occupies
that plane. A collinear source countertop T seam has zero area and gains no
face. The faucet stem already meets the counter, so it gains no duplicate
bottom cap. A geometric triangle intersection test reports zero positive-area
coplanar overlaps across all eleven imported furniture models. Point queries
also require the exposed underside to be covered exactly once and the joined
cabinet interior to remain uncapped at that height.

The exact native family, pair/design, four metatiles, 7/0 collision rows and
uniform native height are required. Quarter-turn fitting aligns the source's
west-wall front to native south. The original proportions fit inside the native
32×16 blocked body, below height 14 including faucet and dishes. The walkable
apron stays clear. Only physical Y0 vertices recess 0.025 pixels; all upper
geometry and native floors/walls/gameplay cells remain unchanged.

The latest official engine release was checked before verification: 0.3.95,
published 2026-10-21T02:42:51Z. Matching source and the official Linux LÖVE shell
ran separate disposable profiles. All 39 native overviews and individual
first-person captures were inspected, together with nine source views including
both undersides. All 13 Emerald maps also pass absent-PNG fallback. Every tour
emitted PASS; the shell returned one at shutdown, so no clean-exit claim is made.
No native captures/pixels, raw scenes/archives, caches or player saves are
committed. Source conversion reproduces identical model data, PNG and provenance.

The refreshed five-edition ledger retains 2161 identical native map hashes.
Only 39 maps gain a kitchen unit candidate. The component ledger now records
459 accepted furniture placements across 228 maps; every complete-map acceptance
remains false. Native guard/fallback, footprint/contact, source tint, exposed
underside, no-overlap and existing interior/shared-model suites pass. Other
furniture and whole-room source coverage remains outstanding.
