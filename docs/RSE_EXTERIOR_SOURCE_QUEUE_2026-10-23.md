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
| Emerald |227|84|28|
| Ruby |172|80|27|
| Sapphire |172|80|27|

Modern candidates include staged Gym/Mart adapters; source eligibility is not
Scene activation or native visual acceptance. Native map cells, collision,
elevation and warp data remain unchanged. Native original art remains fallback.

Current genuine sources cover Hoenn Centers, corridor Gym bodies/doors/notices,
three own-source corridor Mart variants, Briney/Pretty Petal shop, two Dewford
narrow houses and two Lavaridge source variants. Among the244 recognized civic
placements,162 still have no matching modern-source candidate. Beyond them,
whole-map review must still inspect unrecognized/dynamic/decorative buildings.

Next actual-source work: Oldale two home variants in GR0004 `t102_01` and
`chip_mado` (own side/front-window differences, plus original BM0003 hinged
door); Petalburg homes GR0007/0008 `touka_house2`; Rustboro town buildings and
Devon GR0032–0038; remaining named town/route facilities and landmarks. These
sources are located, not accepted. Ordinary Marts and Gyms elsewhere must retain
their own original source arrays where ORAS geography/art differs. The csv is
the continuing queue for exact uncovered native families and placements.
