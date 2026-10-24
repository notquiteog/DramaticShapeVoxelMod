# Original ORAS open bookcase

The genuine Flower Shop bookcase replaces all 33 `hoenn_home_books` placements:
eleven each in Emerald, Ruby and Sapphire. Exact generic-building art and
collision rows remain required; the separate small-bookcase family is pending.
All 2161 map hashes, furniture-family counts and earlier source candidates
remain unchanged. The full census has 2012 source-placement candidates and
1967 accepted components across 258 maps; complete-map acceptance remains false.

The source is Alpha Sapphire ZO366 → AD161 → MM273 → GR623,
`r104ar0101_00_00`, submesh25 `books02` and submesh26 `bookshelf01`.
Independent Nitrogen decoding agrees with all original positions, UV and
triangle indices. Original book/case textures are 64×64 and 128×64.
No source floor, shadow or light geometry is included.

All 476 original triangles remain: twenty separate books and the open wooden
case. The grayscale book atlas uses original vertex pigments. Each book now
uses its brightest original pigment uniformly, removing directional and
ambient vertex shading; the wood uses its original colored texture without
vertex lighting. Original books, leaning angles and source proportions remain.
The native quarter-turn presents the original spine side toward the room.

There are 144 authored closure triangles. Minimum-area triangulation closes
the exact original book-cover rims, including tilted books. Every welded book
edge has two owners. Four foot bottoms and exposed plank undersides close;
buried divider ends, case-wall ends and foot tops receive no duplicate caps.
The lower plank underside is partitioned around the four exact foot footprints.
Wood and book closures retain distinct texture bindings.

Two original side-panel upper rims extended 0.0001 source units into the top
plank underside, creating four positive-area coplanar slivers. Those buried
rim vertices now end at the exact original plank join. All other positions
and all original UV/triangles remain intact. Geometric clipping finds zero
positive-area coplanar intersections in the complete 620-triangle model and
all thirteen imported furniture models. This fixes source geometry directly.

A uniform fit stays within the blocked 32×16 native footprint, height about22
pixels, without entering the native walking apron. Only exact Y0 source
vertices use the 0.025-pixel contact recess; upper geometry and X/Z stay fixed.
CPU contact/bounds, book closure, native identity and atomic failure tests pass.
The importer reproduces data, PNG and provenance byte-for-byte.

Official latest 0.3.95 was checked before native validation. All 33 placements
rendered successfully in isolated profiles. Every individual first-person entry
and room overview was inspected, along with nine source angles including both
undersides. Existing Pokémon/NPCs remain HD2D. All eleven Emerald rooms pass
missing-PNG fallback; a representative native fallback overview was inspected.
Ten focused suites pass. Native drivers emitted PASS; Linux shell shutdown
returned 1. Evidence is component-scoped, with no whole-room/game acceptance.
Raw sources, native pixels, profiles and captures remain outside the repository.


## Separate small-bookcase continuation

The separate native `hoenn_home_small_books` family is now verified at all
17 locations (Emerald5/Ruby6/Sapphire6), bringing this source to 50 accepted
placements. Matching requires its own exact six-cell drawing
`26e/26f,276/277,27e/27f` with collision rows `7/7,7/7,0/0` in the original
generic-building pair. The source model, textures, fit and closure geometry
are unchanged from the first batch.

Official latest 0.3.95 was checked again before the continuation. All 17 native
before-images, first-person source entries and modern room overviews were
inspected. All 17 rooms also pass missing-PNG fallback; representative Emerald
and Game Corner fallback overviews were inspected. Both Ruby and Sapphire
Game Corner entry scripts replace the two hidden-stair cells with the native
closed-door drawing. Their live hashes/deltas are recorded separately; the
renderer changes none of those native cells. Three focused source/identity
suites pass. The refreshed full five-edition census retains all 2161 hashes,
all furniture-family counts and every previous candidate. Only these 17 source
owners are added: 2029 candidates, 1984 accepted components across 258 maps,
complete-map acceptance false. Driver PASS/shutdown-status1 limits still apply.
