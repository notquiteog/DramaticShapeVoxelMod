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
| Emerald |227|84|33|
| Ruby |172|80|32|
| Sapphire |172|80|32|

Modern candidates include staged Gym/Mart adapters; source eligibility is not
Scene activation or native visual acceptance. Native map cells, collision,
elevation and warp data remain unchanged. Native original art remains fallback.

Current genuine sources cover Hoenn Centers, corridor Gym bodies/doors/notices,
three own-source corridor Mart variants, Briney/Pretty Petal shop, two own-source Oldale homes, three own-source Petalburg homes, two Dewford
narrow houses and two Lavaridge source variants. Among the244 recognized civic
placements,147 still have no matching modern-source candidate. Beyond them,
whole-map review must still inspect unrecognized/dynamic/decorative buildings.

Next actual-source work: Rustboro town buildings and
Devon GR0032–0038; remaining named town/route facilities and landmarks. These
sources are located, not accepted. Ordinary Marts and Gyms elsewhere must retain
their own original source arrays where ORAS geography/art differs. The csv is
the continuing queue for exact uncovered native families and placements.

The six Oldale home candidates were added after the initial571-map pass using
positive actual0.3.95 native per-placement upload/door/cap/rollback checks in all
R/S/E. Original per-map grid hashes and recognized counts stay unchanged.

`Gen3ModernHoennBuildings` provides one standalone Scene-facing transaction for
reviewed Gym/Mart/Oldale homes: build/draw/release/ownsDoor. Its prepare/ground
functions expose paired notices. A failed or interrupted building upload releases
only new resources and never claims native-door ownership. Source/dispatcher
QA passes all24 native R/S/E building candidates with every cached door state,
resource cleanup and failed-upload rollback on official0.3.95; exception and
incomplete-provider tests preserve preceding Scene resources. Parent Scene
activation and final native gameplay/visual checks remain outstanding.
