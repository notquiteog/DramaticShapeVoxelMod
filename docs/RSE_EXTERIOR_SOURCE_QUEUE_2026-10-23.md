# RSE exterior source queue and measured coverage

Official0.3.95 native cache/adapter census on2026-10-23 covers every imported
`general__` map:227 Emerald,172 Ruby,172 Sapphire. This includes cave, underwater
and event families with zero recognized civic buildings; it does not mean all
content in571 maps was visually accepted. The CSV records every map, recognized
civic count, exact remaining family+coordinates and unchanged native grid hash.
`tools/qa/rse-exterior-inventory.lua` reproduces the adapter census in an isolated
profile. Recognition itself can miss art families; zero is not an empty-map claim.

| Edition | Maps inspected | Recognized civic placements | Modern source candidates |
| --- | ---: | ---: | ---: |
| Emerald |227|84|42|
| Ruby |172|80|41|
| Sapphire |172|80|41|

Modern candidates include staged Gym/Mart adapters; source eligibility is not
Scene activation or native visual acceptance. Native map cells, collision,
elevation and warp data remain unchanged. Native original art remains fallback.

Current genuine sources cover Hoenn Centers, corridor Gym bodies/doors/notices,
three own-source corridor Mart variants and Slateport's own city Mart, Briney/Pretty Petal shop, two own-source Oldale homes, three own-source Petalburg homes, six own-source Rustboro home/flat/school variants and Devon Corporation, two Dewford
narrow houses and two Lavaridge source variants. Among the244 recognized civic
placements,120 still have no matching modern-source candidate. Beyond them,
whole-map review must still inspect unrecognized/dynamic/decorative buildings.

Next actual-source work: remaining Rustboro Flat2 and tower GR0032–0038; remaining named town/route facilities and landmarks. These
sources are located, not accepted. Ordinary Marts and Gyms elsewhere must retain
their own original source arrays where ORAS geography/art differs. The csv is
the continuing queue for exact uncovered native families and placements.

The six Oldale home candidates were added after the initial571-map pass using
positive actual0.3.95 native per-placement upload/door/cap/rollback checks in all
R/S/E. Original per-map grid hashes and recognized counts stay unchanged.

`Gen3ModernHoennBuildings` provides one standalone Scene-facing transaction for
reviewed Gym/Mart/Oldale/Petalburg/Rustboro/Devon families: build/draw/release/ownsDoor. Its prepare/ground
functions expose paired notices. A failed or interrupted building upload releases
only new resources and never claims native-door ownership. Source/dispatcher
The initial facade QA passed24 native R/S/E building candidates with every cached door state,
resource cleanup and failed-upload rollback on official0.3.95; exception and
incomplete-provider tests preserve preceding Scene resources. Parent Scene
release integration and whole-map reviews are tracked separately from the
per-placement native gameplay/source checks below.

The Rustboro additions use12 positive native0.3.95 source/dispatcher checks,
including original hinge states and cap depth, after the initial whole-map census.
The subsequent Flat1/House3 additions use six more exact native candidates.
The running recognized candidate total is124 of244;120 remain without sources.
Final integrated visual/gameplay acceptance is tracked independently. See
ORAS_RUSTBORO_HOMES_2026-10-23.md for the first four families and
ORAS_RUSTBORO_FLATS_2026-10-23.md for the Flat1/House3 continuation,
controller-isolated native entry/return and current pending fit review.

Devon adds three positive native per-placement checks, six actual paired-door
entries/returns and two Emerald missing-source fallback entries after the
initial571-map census. Original hashes and recognized counts remain fixed.
See ORAS_DEVON_CORPORATION_2026-10-23.md. Rear completeness of the owned
Gym/Mart/Oldale/Petalburg/Rustboro bodies was separately corrected and checked
with actual-source rays; prior rear-only screenshot interpretation was wrong.
See ORAS_REAR_CLOSURES_2026-10-23.md for the correction and native evidence.

Slateport Mart adds three positive native candidates with its own GR149
pc_base body/AD20 paint and original ZO14→266/BM9 portal. Source and actual
entrance/return evidence is separate from the initial whole-map census. See
ORAS_SLATEPORT_MART_2026-10-23.md. Current recognized candidate count is124
of244,120 missing; other unrecognized roofs/facilities still require review.

Oceanic Museum adds three exact native candidates. Its own GR150 body, AD20
paint and BM40 paired hinges match ZO14→273. Open roof hardware receives thin
backings/rims without filling the dish silhouette. Native0x32a has no door
animation, so the source leaves use their fully open idle pose. Normal native
admission input, both entries and returns are tested. See
ORAS_OCEANIC_MUSEUM_2026-10-23.md. Recognized candidates now124 of244;120
remain. Slateport Shipyard/Harbor and unrecognized roofs continue.
