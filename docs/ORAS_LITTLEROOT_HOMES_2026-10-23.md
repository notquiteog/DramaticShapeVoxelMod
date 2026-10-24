# Original ORAS Littleroot houses

Both original houses come from GR6 `world01_02_04`, actual ZO6/AD8/MM1. GR0
is a development/test scene and is not a source substitute. MM1 places GR6 at
(2,4) with world center(1800,0,3240); original BM2 portals(1701,0,3087) and
(1917,0,3087) match ZO6 destinations223/225. Each house keeps1519 physical
triangles (1191 t01_01,324 t01_02,4 chip_mado) with original positions, UVs,
indices and opaque physical alpha independently checked against Nitrogen.
AD8 source pixels preserve actual golden roofs, walls, windows and gutters.
Source exposure RGB, terrain, trees, mailbox props and nonphysical lights are omitted.

The six-corner foundation underside adds4 triangles. Rear closure adds236
triangles following the original side/roof profiles inside original bounds.
Both use an opaque texel sampled from the original wall triangle's paint at
(141.5,53.5) in the256-square t101_01 atlas. Only actual Y0 source contact
vertices move0.05 native units below native ground. No duplicate terrain plane
is imported. The original1.125-source-unit entrance threshold remains physical
source geometry above ground, independently separated from the bottom closure.

BM0002 `t101_bm_door01` keeps66 physical door/window triangles and its actual
six-frame hinge samples0,−0.69813168,−1.39626336 radians. Original rigid owner,
pose positions/UVs and inverse bind are checked independently (moving error0).
Its top is only0.000015 source units above the body lintel: only that exact top
contact ring recesses0.05 native units in all three poses. Lower Y0 contacts
recess0.05 below ground. Portal/hinge anchors and upper frame stay fixed.
Actual fitted body/cap/rear/door audit reports zero overlapping coplanar area
for both houses in all three poses; the original top contact was reproduced.

Exact native Littleroot placements(2,4)/(13,4),5×5, `general__petalburg`, full
source-art rows, permissions, region owner and flat-ground guards select the
respective originals. Uniform fitting80×64 with0.25 padding leaves the native
walkable roof header clear, anchors X56/X24 within the actual portal cells
and local Z54. Source spans are60.66×45.05 and59.69×44.34 inside the blocked
body. Every body/closure and every door pose passes native triangle clearance.
No cell, portal, collision or warp changes. Facade kind is `littlerootHomes`.

Latest official engine was checked before the batch: Gen1Recomp0.3.96,
release0e92b587. Matching native Linux shell, owned engine and disposable .96
R/E/S identities run this API3 source standalone. All six source placements
pass native body/pose/contact upload and failed-upload rollback. All six actual
Scene entrances and normal returns pass, using the original Brendan/May1F
warps, unchanged native grid hashes and zero streaming recovery. Both Emerald
missing-asset entrances/normal returns also pass with native fallback. Source
and native front/side/rear/under/top/rotating/contact captures were inspected.
Native actors and flowers retain default HD2D presentation.

Reproduce with tools/qa/hoenn-littleroot-{source,entries}.lua, external QA_UTIL,
SHOT_DIR and isolated *-qa profiles; QA_MISSING_ASSETS=1 selects source absence.
Real source geometry tests cover both houses and all poses, plus21 source rear
closures. Root release integration is separate; this batch adds six source
candidates after the original571-map census:45EM44RU44SA,133/244 recognized
placements,111 missing. Birch's Lab and whole-map/unrecognized families remain
pending. The source-faithful Shipyard prototype stays inactive due native foyer
clearance and is preserved separately.
