# Original ORAS Oceanic Museum

Slateport's own GR150 c102_01_00 Museum retains1306 physical body triangles:
716 museum_waku,546 kaina_house01 and44 chip_mado. Original positions, UVs,
indices and opaque physical alpha independently match Nitrogen. Original AD20
pixels preserve the curved violet roof, windows, facade, source dish and its
supports. Source exposure RGB is omitted. The static origin(1080,0,360) and
body origin(1035,18.5,549) bind the original BM40 instance(1035,18,549) to the
actual ZO14 destination273. The original0.5 source-ground difference to that
instance is retained by the door geometry.

The original body/side-pier/front-pedestal bottoms close with44 triangles.
Individual pedestal caps subtract the already covered cap area. Original
source parts contain zero horizontal base-ground triangles. Only exact source
Y0 contacts and undersides recess0.05 native units. The rear follows the main
building's original side/roof profiles with84 triangles and an actual solid
source wall texel. The source roof hardware remains separate from this closure.

Ten original roof-fixture components have open paper surfaces. Their original
front vertices/UVs/indices remain unchanged. A0.1-source-unit backing and rim
follow each actual surface, preserving the dish's curved silhouette and the
open spaces between its supports. These add252 triangles. Each component uses
a solid opaque texel sampled from its own original paint. New fixture geometry
stays within the original model bounds; coincident support-bottom patches are
subtracted where the original roof already covers them. No rectangular backing
is projected through the dish and no new attachment or painted feature is added.

BM0040 c102_bm_door04 keeps68 physical panel/glass triangles and independently
verified rigid owners[2,1,2,1]. Its original six-frame hinge tracks sample
0,±0.79011055 and±1.57079637 radians at0,2.5,5; moving inverse-bind error is
zero. Twenty-four nonphysical light faces are omitted. The two original closed
leaf caps occupy the same center plane. Only that meeting ring recesses0.05
native units into each leaf, rotating with its original hinge in every pose.
The closed gap is0.1 native units. Non-contact coordinates, native anchors,
original pose travel and UVs remain fixed. The real fitted-body/roof/cap/leaf
audit finds zero overlapping coplanar area in all three poses.

The exact native building is Slateport(28,22),6×5 cells; both original portal
cells(30,26) and(31,26) remain authoritative. Uniform fitting uses96×64 with
0.25 padding and local door anchor(48,0,59.25), filling approximately95.5×61.5
of the blocked body. Every body/closure and every original door pose passes
native triangle clearance. Exact edition/map/pair, all native art rows,
permissions, owner, origin and ground level guard eligibility. The Hoenn facade
exposes this as kind=hoennMuseums through its existing atomic API; no Scene edit
is made. Failed/missing assets preserve native fallback and release all cached
source poses and partial body resources.

Native0x32a Museum entrances have no door-animation entry in the actual R/S/E
manifests, and all six original entrances emit no native door-animation frames.
The source leaves therefore use their fully open idle pose. Explicit matching
pose input still selects all three original cached states. This keeps the
native open passage visually clear without introducing a new gameplay gate,
sound or timing. The original admission dialogue is answered through ordinary
A-button input in QA; money, flags, scripts and VM state are never overwritten.

Latest official engine was checked before the batch:
[Gen1Recomp0.3.95](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Its matching Linux LÖVE shell runs copied isolated R/S/E QA profiles with
physical controller input disabled only in the QA engine configuration. The
current parent integrationc87489c7 and these source overrides form the final
QA composite; its new ActorFrameCache/SpriteFrustum dependencies were synchronized
before the final entrance rerun. `hoenn-museum-source.lua` checks actual native
body uploads, all132 underside vertices at−0.05, all paired poses, failed-upload
cleanup and the original unanimated-portal contract. `hoenn-museum-entries.lua`
checks exact live Scene ownership, both native entrances, original admission
input, normal returns, unchanged grid hashes and zero recovery failures. All
three final source/upload checks and all six final open-idle entrances/returns
pass. Two Emerald missing-source entrances/returns also pass; source absence
keeps the original native open entrance. Ruby walkable rear/roof views pass.

Source front/side/back/under/top and native front/side/entry/interior/return
captures were inspected. Native rear/roof views use the production first-person
camera from walkable grass(30,17), beyond the original pond; the nearer rear
cells are water and remain unwalkable. The rear wall is closed, the curved roof
and opaque dish backing remain intact, and base/door contacts are separated.

The running real-source regression covers18 models,162 rear rays and125,155
rear-related coplanar candidates; the Museum-specific audit separately covers
all body/cap/fixture/leaf combinations. Three mocked native candidates verify
source/native clearance, unchanged non-contact door coordinates, the0.05 edge
inset, the open idle contract and atomic source/mesh failure cleanup.

This adds three recognized source candidates:42 Emerald,41 Ruby,41 Sapphire,
124 of244 recognized placements;120 remain without matching sources. Original
571-map census hashes and recognized counts stay fixed. Whole-map review and
unrecognized roofs/facilities remain pending. Shipyard and Harbor continue next.
