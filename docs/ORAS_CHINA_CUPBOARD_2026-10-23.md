# Genuine ORAS china cupboards

The generic RSE glass china cupboard now uses the matching original ORAS
Oldale model at all 74 native locations: 24 Emerald, 25 Ruby and 25 Sapphire.
The legacy extractor calls this family `hoenn_home_tv`; native 2D art identifies
two glass doors and lower drawers beside a separate TV. Its six native cells
do not carry television behavior 0x86. The family's existing identifier remains
stable. Rustic cupboards and unrelated drawings retain their current adapters.

The source is Alpha Sapphire ZO230 → AD115 → MM171 → GR513,
`t102r0101_00_00`, submesh 10, `t102_shelf02`. All 242 original triangles,
positions and UVs remain unchanged apart from uniform normalization. Nitrogen
independently agrees with the selected geometry. The original 128×128 PNG,
including transparent door texels, is preserved. Source grayscale vertex
shading is removed; the original pink dish and red/blue ceramic tints remain.
Four cup bodies, two separate handles, three dishes, case, doors, drawers and
interior shelf surfaces are retained. No floor, shadow or source light is used.

The 104 authored closure triangles close reviewed vessel bottoms, handle ends,
case underside/inner ceiling, shelf backs/undersides and panel backs. Panel
backs sit 0.03 source units inside their original fronts. Their perimeter
strips would coincide with existing case walls and shelves, so those buried
duplicate strips are excluded. Lower shelf side caps are likewise excluded
where original case inner walls already close them. The original rear case
T seams remain; a fan over that branched boundary would overlap source faces.
Geometric triangle clipping confirms zero positive-area coplanar overlaps.

Exact pair/family/design, all six metatiles, native 7/7/0 collision rows and
uniform height are required. Uniform fitting preserves source proportions in
the native 32×16 blocked body, with height below 32. The walkable apron stays
clear. Physical bottom contacts recess 0.025 pixels; upper source geometry,
native floor/wall cells and elevations do not move. Failed source loading
retains complete native furniture.

The official latest engine was checked before the batch: 0.3.95, published
2026-10-21T02:42:51Z. Separate disposable profiles and the matching official
Linux LÖVE shell visited all 74 locations. Native overviews and individual
first-person captures were inspected, together with nine source views including
both undersides. All 24 Emerald maps also pass absent-PNG fallback. Every tour
emitted PASS; the shell returned one on shutdown, so no clean-exit claim is made.
No native pixels, raw source archives/scenes, caches or captures are committed.

The full five-edition census still contains 2161 identical native hashes.
Only 74 maps gain a cupboard candidate. The separate ledger records 420 accepted
furniture components on 228 maps; complete-map acceptance stays false. Source,
fit/contact, ceramic tint, exact guard/fallback and all ten imported furniture
coplanar-intersection tests pass. Regenerated model data, PNG and provenance
are byte-identical. Remaining furniture and room coverage is still outstanding.
