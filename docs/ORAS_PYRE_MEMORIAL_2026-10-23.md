# Original Mt. Pyre memorials in Pokémon Tower

The genuine ORAS Mt. Pyre memorial replaces the common complete grave drawing
at 682 exact FireRed/LeafGreen locations: 341 per edition on Tower floors 2–7.
Native 2D art and all fixture cells were checked. This adapter requires native
metatile 0x291, collision 7, the exact tower pair/design and owner-consistent
height. Boundary variants remain separate. It does not replace the tower room,
walls, staircases, floor, healing area, dialogue or actors.

Source: Alpha Sapphire ZO86 → AD53 → MM47 → GR301,
`d108r0101_00_00`, `Comb1`, bound to the original `d108_obj1` texture. Three
connected components of 72, 36 and 16 triangles form one complete memorial:
arched finial, stepped plinth and beveled inscription plaque. All 124 original
triangles, positions and UVs remain unchanged apart from uniform normalization.
Nitrogen independently agrees with the original batch. The opaque 64×64 PNG
is preserved; grayscale vertex shading is removed. Other memorial instances,
room floor, source shadows and source light geometry are excluded.

The source omits its back and underside. The 79 authored triangles follow the
actual angled plinth rear profile, close the original underside and arch rear,
and seal tiny original arch/plaque attachment gaps with perimeter skirts.
Those skirts terminate on existing original platform/case surfaces and gain
no duplicate internal cap. The plinth is closed; every original boundary edge
is incident to exactly two faces. Attachment rims terminate inside their
existing source backing surfaces. All twelve imported furniture models pass
geometric positive-area coplanar-intersection tests.

Uniform fitting preserves the original proportions inside a single 16×16
native blocked cell, below height 17. The actual base remains over 12 pixels
wide/deep. Only physical Y0 contacts recess 0.025 pixels. Every upper source
coordinate and all native map cells remain unchanged. A mismatched owner/base
height rejects source placement, including the single-cell case. The refreshed
full native census confirms all older source placement counts remain identical.

The official latest engine was checked before verification: 0.3.95, published
2026-10-21T02:42:51Z. Matching source and the official Linux LÖVE shell ran
isolated disposable profiles. All 682 placements upload and appear in native
floor overviews; individual first-person contact sheets and nine source angles,
including both undersides, were inspected. Every camera uses an actual native
walkable cell. Dense native graves obstruct direct sightlines for 35 fixtures
per edition; the ledger records that occlusion. NPCs and original dialogue also
retain their real occlusion. No claim of uniformly unobstructed close views is
made. Complete-floor acceptance remains false. All six FireRed floors also
pass absent-PNG fallback. Drivers emit PASS; the shell returns one at shutdown,
so no clean process-exit claim is made.

Regeneration reproduces identical model data, PNG and provenance. Source,
angled closure, attachment joint, footprint/contact, exact guard/fallback and
existing interior/shared-model tests pass. All 2161 census native hashes stay
identical; only these twelve maps gain 682 candidates. The component ledger
contains 1141 accepted placements across 240 maps. Raw archives/scenes,
native pixels, caches and captures are excluded. RSE Mt. Pyre still lacks
furniture extraction; its art audit is a separate next family, not coverage
inherited from this Kanto batch.

The later [RSE continuation](RSE_PYRE_MEMORIALS_2026-10-23.md) separately verifies
all 793 complete common and wall-shadow graves across the 18 Mt. Pyre floors.
