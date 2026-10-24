# Slateport's own original ORAS Mart

GR149 c102_00_00 pc_base is Slateport's distinct703-triangle Mart. The actual
256×256 pokecen_frind paint from static AD20 is retained; its own coordinates,
UVs and indices independently match Nitrogen. No corridor-town body or paint
is substituted. The static chunk origin(360,0,360) binds its local portal at
(315,18,81) to the actual GR149 BM9 instance(675,18,441), identity scale/rotation,
and ZO14 destination266. Native placement is Slateport(12,23),4×4 cells, door
(13,26) in all three editions.

The original19 bottom-rim points close the exact chamfers and entrance recess
with12 nondegenerate triangles after collinear points are removed. There are
zero source horizontal ground faces. The rear follows original side profiles
with219 triangles and a solid original wall texel; no extra windows, fixtures
or textures are invented. Only body Y0 contacts and underside recess0.05 native
units. BM9 retains its original43 physical faces, two original AD20 texture
paints, three original X-slider samples and original bind transforms;24 light
faces/source exposure RGB are omitted. The body's original18-unit ground and
the door's actual GR placement are the shared source frame. The distinct Slateport body has jamb planes at sourceX±14 that overlap the
original closed slider's outer sides. Only the slider's original side-contact
vertices recess0.05 native units inward, identically in all three poses; original
center, slider travel, Y/Z and UVs stay fixed. No whole-door or portal shift is
applied. The earlier three Mart bodies already have jamb clearance and receive
no side-ring alteration.

The uniform64×48 native fit with0.25 padding keeps the original portal at
local(24,0,41). Every physical body/cap/rear triangle and all cached door poses
pass native blocked-footprint clearance. Exact edition/map/pair, native rows,
permissions, owner, origin and level guards protect fallback. The facade's
existing API routes slateport_city_mart as kind=hoennMarts to the own-source
adapter and slider cache, with atomic body/door cleanup on missing assets or
failed uploads. No Scene edit or generic Mart substitution is used.

Actual-source rear regression covers17 models,153 rays and124,945 coplanar
candidates with zero new rear overlap and unchanged original model bounds.
Three mocked native candidates, all slider states and failed-source cleanup
pass; the facade tests also cover the new route and transaction rollback.
Latest official runtime was checked before verification:
[Gen1Recomp0.3.95](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Its matching Linux LÖVE shell uses isolated copied R/S/E profiles and QA-only
physical controller isolation. The source driver checks body uploads, all
36 underside vertices at−0.05, all slider states and failed-upload cleanup.
The entry driver checks exact live Scene source ownership, native entrance to
the correct Slateport Mart, normal return, unchanged native grid hash and zero
Scene recovery failures. Native front/side/rear/contact/interior/return and
source all-angle views are inspected; source roof, glass and wall paint remain
intact. Missing-source fallback is checked separately with the own asset folder
blocked. All three native source/pose/contact/rollback runs, all three native
entries/returns and the Emerald missing-source entrance/return pass. A separate
actual fitted-body/slider projected-area audit covers all twelve Mart model/
pose combinations and168 candidate pairs with zero overlapping area; disabling
only the new Slateport side inset reproduces27 original overlap pairs.

This adds three recognized source candidates:41 Emerald,40 Ruby,40 Sapphire,
121 of244 recognized placements,123 still missing. Whole-map native acceptance
remains pending. The census can miss generic/unrecognized roofs, so the small
Slateport civic count does not establish complete city coverage. Shipyard,
Oceanic Museum, Harbor and other uncovered regional families continue next.

A separate ground-contact regression covers the preceding Oldale/Petalburg/
Rustboro Marts. Source float rounding left some normalized Y0 ring/cap vertices
near1.5e−7, outside the shared1e−7 inset threshold; caps uploaded near0.000008
native units above ground. Only source contacts within0.0001 original units of
normalized ground now snap to exactY0, allowing the existing−0.05 recess to
apply. Upper coordinates, source UVs/indices, door poses and native anchors stay
unchanged. The meaningful mocked cap test rejects the old data. The final
four-Mart native source/pose/cap/rollback batch passes all twelve R/S/E
placements. The final `tools/qa/hoenn-mart-contact-entries.lua` tour passes all twelve
actual R/S/E entrances and normal returns after both contact corrections, with
unchanged native hashes and zero recovery failures. Its Emerald missing-source
run also passes all four entrances/returns. `hoenn-mart-contact-source.lua`
passes all twelve final source/cap/pose/rollback checks. Fresh native contact
captures were inspected across all four families; the regression rejects the
original un-snapped contact data and original un-recessed Slateport slider.
