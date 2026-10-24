# Original ORAS Slateport Harbor

The Harbor uses its own GR150 c102_01_00 body, AD20 texture banks and BM0093
com_bm_portdoor01 paired sliders. Original GR placement(927,0,171) matches
ZO14 destination275. Static origin(1080,0,360), original UVs, indices and rigid
owners[2,1,2,1] independently match Nitrogen. Source exposure RGB is omitted.

The complete source contains1068 c106_01 triangles,48 c106_window triangles and
174 Comb2/t106_02 triangles. Comb2 carries actual walls; its name does not imply
that the whole material is an effect. Four reviewed original triangles40–43
are the neon PICA portal-effect marker behind the physical leaves, and are
omitted with the24 nonphysical BM light faces. Native side/entrance inspection
caught both the missing wall layer and the marker during review; neither
intermediate is accepted. The final physical source retains1286 original
triangles before clipping. Only16 source triangles extending beneath original
Y0 are clipped there with affine source UVs; every above-ground coordinate and
portal anchor remains fixed. Tiny source ground quantization within0.0001
source units snaps to exactY0. The final three source parts contain1294 triangles.

Ten underside triangles follow the actual stepped foundation rim. The rear
follows the original side/roof profiles with134 triangles and a solid gray
texel used by original window trim. Exact ground contacts and undersides
recess0.05 native units. Original steps, upper walls, paint and source heights
stay fixed. No source terrain or duplicate floor overlay is copied.

All68 original panel/glass triangles use the actual source slider tracks at
frames0,2.5,5. Their original bone X tracks are(0,−36),(9.054,−45.054) and
(18,−54), beneath the original root translation(18,0,9). Moving inverse-bind
error is zero. Only the original central closed-leaf cap ring recedes0.05
native units per leaf, producing a0.1-native-unit gap. Non-contact coordinates,
all source UVs and original slider travel remain fixed. Native0x2c6 has no
animation entry, so its original open passage uses fully open source leaves
at idle; explicit matching pose input still exposes all three cached states.

Exact native Slateport(25,7),7×6, portal(28,12) uses uniform112×80 fitting,
0.25 padding and door anchor(56,0,74.25). It fills111.5×approximately54 native
units inside the blocked body. Every body/closure and every door pose passes
triangle clearance against actual native cells. Exact edition/map/pair, all art
rows, permissions, owner, origin and flat ground guard activation. The facade
kind is hoennHarbors through its existing atomic API. The separate native pier
warp(40,7) is never claimed. No Scene edit or gameplay change is made.

The latest official engine was checked immediately before the batch:
[Gen1Recomp0.3.95](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Its matching Linux LÖVE shell used copied isolated R/S/E profiles, controller
input disabled only in the QA engine configuration, and parent integration
27048431 with these own source overrides. All three final complete-source
upload/slider/contact/failed-upload rollback checks pass. All three final
actual-Scene entrances and normal returns pass, reaching the original Harbor
at(11,14), with unchanged native grid hashes and zero renderer recovery
failures. One Emerald missing-source entrance and normal return also pass.
Source eligibility, current parent-composite evidence and release integration
remain separate claims.

Inspected final actual-source front/side/rear/under/top views and native
front/side/rear/roof/entry/interior/return captures. Native first-person views
use walkable(28,14),(24,9),(32,13), and diagonal rear(22,6); direct rear approach
is blocked by original trees. Walls are complete, the entrance is open without
the marker, the stepped foundation is grounded and original roof detail stays
intact. Source-body/cap/rear/leaf coplanar audit finds zero overlapping area in
all three fitted poses. A real side-wall ray requires Comb2 and rejects its
omission baseline. The running rear regression covers19 source models,171
rays and133,542 rear-related coplanar candidates.

This adds three candidates after the original571-map census:43 Emerald,
42 Ruby,42 Sapphire,127 of244 recognized civic placements.117 still lack a
matching candidate, and whole-map/unrecognized-art review remains pending.
Shipyard stays native fallback: its exact walkable foyer(26,37) conflicts with
the intact source footprint aligned to portal(26,38). No permission, collision,
portal or shared-clearance relaxation is made. Regional source work continues.
