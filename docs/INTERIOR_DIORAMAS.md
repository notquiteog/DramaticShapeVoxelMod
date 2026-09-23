# Interior dioramas — 1.23.0-test.9, QA pending

The two interior references supplied on September 22 guide this pass: open
fronts, closed room edges, shallow furniture, readable pixel artwork and warm
light. This implementation is prepared for test.9; exact packaged visual verification follows publication.

## Test.9 reviewed additions and overlap correction

Adds15 whole-object furniture recipes matching137 native museum, Silph, Power Plant and Mansion objects, with independent reviewed wall/floor profiles. Museum wooden floors0x109/0x111 explicitly stay flat. The list of complete native source fixtures is in [the current checkpoint](NATIVE_PARITY_2026-09-22.md).

Oak's starter table consumes its complete two-row native drawing, but its solid footprint now occupies only the blocked first row. Its modeled front ends at worldz79, before the walkable row5 where the player and rival stand; starter-ball supports move3px back onto that tabletop. This fixes the source cause of the reported body/table intersection without lowering other furniture or changing actor lean/collision/scripts. Geometry tests pass; exact screenshot verification remains pending.

## Shared presentation

`InteriorDiorama` frames architectural rooms in all three generations. Home,
shop, Center and laboratory palettes provide plaster walls, skirting, corner
trim, cornices, side-window panels and a dark foundation. The camera-facing
wall opens when viewed from outside; an eye inside sees an enclosed room and
ceiling. Compact rooms fit fully into the static camera at its selected angle.
Large halls retain the player-following camera. First-person and rotating
third-person cameras retain their controls.

Scene lighting adds indirect fill, soft contact shading beside the walls and
warm side light. No blur is applied to pixel artwork or UI. Both the color and
shadow passes clip the old outside border: hiding only its color left a false
shadow band on the floor. Every pass resets clipping and lighting before the
next field/battle scene.

Crystal keeps its existing authored furniture and floor finishes; Gen 1 keeps
its furniture geometry and imported artwork. FireRed uses the actual native
metatile layers, excluding padded black cells from the enclosure. No collision,
warps, native map data, inventory, party or scripts are changed.

## FireRed furniture

The native Mart and Pokemon Center tileset families now use the 3D field path.
Twenty-five additional pair-scoped shop/Center recipes cover stock shelves,
checkout sections, benches, vending machines, terminals, the healing machine,
reception counters, tables, seats and plants. Two additional house planter
recipes preserve the original plant illustration as a cutout; foliage follows
free cameras while staying at its authored angle in static views.

Recipes claim complete drawings, so one shared tile ID cannot turn unrelated
art into a cabinet. The native healing animation, special field effects,
transitions and shop camera still select the existing native presentation.
That fallback preserves their effects; depth-aware healing remains separate
unfinished work.

## Verification and limits

Native QA uses the actual Linux Gen1Recomp 0.2.73 AppImage in isolated profiles.
`tests/interior_diorama_driver.lua` records house/lab/Mart/Center views in Yellow,
Crystal and FireRed: front, sides, rear, inside, normal gameplay, first person,
rotating third person, then return to the field. Fixtures select a walkable,
dry, non-warp cell. Script suppression is confined to this visual test driver;
these captures do not verify gameplay scripts.

The native inventories find 135 framed Gen 1 rooms, 233 Crystal rooms
(including gatehouses), and 124 enabled FireRed rooms. Another 103 FireRed
architectural maps have eligible bounds but remain on native presentation.
These numbers describe routing, not individual visual approval.

Eighteen representative rooms were captured, including a Gen 1 museum/forest
gate and Crystal traditional houses, Dance Theater, radio station and gate.
Normal gameplay, first-person and rotating views were exercised in addition
to inspection turntables. A separate FireRed run covered every camera rung.
Crystal battle menus/damage and FireRed battle-stage menus/damage/return pass
on the modified renderer. A direct Elm’s Lab → staged battle transition also
passes, checking room-to-battle state. Native Gen 2 support passes 181/181 checks.

Headless tests cover generation/tileset isolation, padded-cell bounds, open
front height, finite furniture geometry, source UVs, and rooted plant cards.
Existing adapter, outdoor, companion, Gen 2 depth and support checks are also
run. Captures and logs stay outside Git under `/tmp/interior-hd2d`.

The room framing is shared coverage, not a claim that every decoration has
received an individual visual review. FireRed's other specialty interiors
still use native presentation: gyms, ships, department stores, towers,
industrial maps, some distinct house sets and multiplayer rooms require their
own furniture/animation adapters. All-room inventory reports distinguish
eligible framing from an actually enabled HD scene. Existing legacy furniture
and wall drawings can still need individual refinement even in framed rooms.
