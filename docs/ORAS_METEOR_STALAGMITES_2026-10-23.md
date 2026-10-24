# Meteor Falls independent rock spikes

The complete native `254/25C` two-cell gold spike previously remained painted
on the floor. It now uses the original ORAS Meteor Falls stalagmite, independently
from surrounding cave walls: five owners in Meteor Falls 1F 1R per RSE edition,
15 owners total. FireRed and LeafGreen have no matching family and are unchanged.
Whole-room and whole-game acceptance remains false.

The supplied Alpha Sapphire source resolves through ZO71 → AD107 → MM32 → GR260,
model `d101r0101_00_00`, submesh0, material `gake_basic`, original texture
`d101r_gake01`. Connected triangles441–460 form the exact 20-triangle spike.
Both independent decoders agree on positions, UVs, indices and its identity-root
binding. Eight triangles close only the missing rear skin and seven-vertex
underside; the original upper geometry, proportions and UVs remain unchanged.
The result has exactly two incident faces per geometric edge and no
positive-area coplanar overlaps. Source vertex lighting is replaced with white.
Original game art belongs to Nintendo / Creatures / GAME FREAK.

Uniform fit preserves the original 16×46×14 proportions with a 32-pixel height
cap. The physical foot stays within the second blocked cell; only source-Y0
contact vertices recess .025 pixels below native ground. Both native cells,
surrounding rock, floor, ladders, water, warps and HD2D actors remain owned by
their existing adapters. Exact pair, two-row identity, collision7 in both rows,
edition and single-height guards exclude walkable copies and other cave art.
Source upload ownership is atomic. When the original PNG is unavailable, the
same closed CPU geometry uses the edition's native gold-rock paint samples;
there is no flat-card fallback.

Latest official engine checked for this batch: Gen1Recomp **0.3.96**. Official
Linux LÖVE shell, API3 standalone Battle Art, isolated `*-qa` identities,
immutable cache seeds and disposable fixtures were used. Source, before and
missing-PNG runs passed in Emerald, Ruby and Sapphire. Each run inspected all
five owners from four native walkable first-person/orbit directions plus native
and room overviews. Native walls continue to occlude unavailable directions;
no camera or collision change was made to expose a hidden surface. All nine
source views, including rear, top and both undersides, were inspected. Source
and before drivers assert unchanged native cells/elevations and warps; the
missing-PNG run independently asserts native cell invariance and zero uploads.

Focused checks pass: 424 closed-edge, uniform-fit, bottom-contact, exact-identity,
edition, walkable-copy and source-failure contracts; all24 imported model
coplanar checks; existing PC and native furniture tests; 597 native Hoenn cave
contracts; 5,532 cave shell contracts and enclosure tests. Re-running the source
importer produces byte-identical model, PNG and provenance files.

Fresh RSE adapter censuses preserve all 1,309 native hashes and all previous
furniture families, adding only this five-owner family in three maps. The
all-five canonical ledger retains 2,161 maps, including unchanged FRLG entries.
Candidates become 2,761 pieces / 2,887 native owners (including held/default-native
counter prototypes); accepted components become 2,632 across 283 edition/map
pairs. Every whole-map `renderedAccepted` flag remains false.

Reproduction driver: `tools/qa/meteor-stalagmites.lua`, with external `QA_UTIL`,
`SHOT_DIR`, disposable QA profile and optional `QA_VIEWS=1`. `QA_BEFORE=1` disables
only this family; `QA_MISSING_METEOR=1` omits the model's PNG reader. Metadata:
`docs/coverage/gen3-interiors-2026-10-23/meteor-stalagmite-runs.jsonl`, canonical
map/family ledgers and component acceptance records. Raw model archives,
native pixels, runtime caches and captures are excluded from Git. Scene is
untouched; no hook, version bump or release is required by this source batch.

Remaining work includes Emerald Navel Rock's flat rock vocabulary, broader
volcanic/underwater cave families and source-derived multi-row columns. These
component results do not imply complete cave or room coverage.
