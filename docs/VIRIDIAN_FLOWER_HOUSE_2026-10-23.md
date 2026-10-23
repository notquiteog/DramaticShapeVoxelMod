# Viridian School flower-house exterior — 2026-10-23

The exact native FR/LG `viridian_flower_house` at(24,15) now uses the matching
regional ordinary-house source from [HGSS Viridian City, asset592881](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/).
Native drawings were inspected first: the ordinary-house roof/body/left door
is retained as the regional family, with the native flower-planter variant.
The alternate local `to_h02` source has a different window drawing and
is not substituted. Existing original source attribution and hashes remain in
`assets/scenery/viridian-house/provenance.json`; no duplicate asset pack is added.

`Gen3ImportedViridianFlowerHouses` selects only this complete5×5 native drawing,
original permissions, level ground and original civic ownership. The physical
source house stays in its three blocked body rows. Its original measured rear,
gable, roof-soffit and foundation closure is reused. The native roof-header and
lower flower row remain walkable as before. Source shading and the static door
are excluded from this private registered body variant. The original separate
8-triangle door receives its own native-frame inward hinge poses; original
geometry, texture and engine timing remain intact. All source frames stay in
the blocked body rectangle. The `.05` contact-ring inset keeps native ground
clear without moving the source entrance or upper building.

The decoration is flat HD2D. `Gen3ViridianFlowerCards` reads only the active
public native metatile atlas, preserving the original two flower-planter
rectangles(16×16 and48×16). Exact native facade-gray and surrounding lawn colors
become transparent; all205 left and656 right retained pixels keep their actual
RGBA. Unknown drawings/palettes fail the reviewed pixel-count guard and retain
the complete native Civic fallback. No original ROM art or generated native
atlas is committed.

Both cards use a uniform half-scale, with their original aspect ratios, placed
in the matching source wall bays around its left door. The sprite's full native
width is not left floating beyond the narrower regional source facade. Petals,
leaves, stems, original planter paint and every bloom remain flat; no petals or
plants are extruded. The image is owned by its particular scene group and is
released on failure, cancellation and scene teardown. A late planter failure
unwinds the newly uploaded source body and door poses before native fallback.

`Gen3ModernKantoBuildings` dispatches this family as `viridianFlowerHouses`.
Its existing release entry point now also calls an optional building-specific
release method for the native-card image. Existing child door and chimney
routing remains intact. Parent Scene integration needs no new rendering branch;
exposing `scenery.viridianFlowerHouses` from its dynamic family counts supports
the reusable native review driver. No Scene edits are included here.

Official0.3.95 Linux source/LÖVE11.5 shell, Mesa llvmpipe, isolated FR/LG QA
profiles and no companions: both editions rendered the source exterior, native
planters and source closed/half/open door. Default/first-person front/side/rear,
native2D and real held-input School entry/return were inspected. Native
metatile/collision/elevation hashes were unchanged. Missing-image FireRed kept
the complete native building and its original School entrance/return. Drivers
emitted PASS; shell shutdown returned1. Physical phones and the final combined
production package remain separate checks.

The per-map ledger also records the native decoration RGBA hash. Source
eligibility and rendered acceptance remain separate. Current per edition:
426 maps,132 detected assemblies,26 eligible,106 unmatched,5 inspected in these
batches. Nine families have at least one eligible adapter;45 have none. Gyms
remain partial. Unclassified terrain/boundary cells are not missing-building
counts or proof of complete coverage.

The same source-door audit corrected Pewter's authored hinge to the original
right rear door edge, opposite its left handle. Closed geometry/UVs are
unchanged. All source door frames and actual entry/return were rechecked after
that correction; this authored pose is not represented as an extracted HGSS
animation track.
