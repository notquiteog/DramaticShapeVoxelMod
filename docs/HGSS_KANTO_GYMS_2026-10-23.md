# Source-matched Viridian/Pewter/Cerulean/Saffron Gyms — 2026-10-23

The initial two genuine regional sources are `to_gym_001-mesh` with
`gym_door_007-mesh` from [HGSS Viridian City](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/),
and `nbc_gym_001-mesh` with `gym_door_005-mesh` from
[HGSS Pewter City](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592849/).
Both scenes were submitted by Kuramapika1 on September1,2026; original game art
is Nintendo / Creatures / GAME FREAK. The actual source badge colors distinguish
these regional variants. Other Kanto or Sevii Gyms are not substituted.

`tools/import_hgss_kanto_gyms.py` reproduces the original274 physical triangles
per regional source, excluding11 baked shadow triangles. Fifty-four authored
triangles close measured rear wall/belt/roof cuts, both roof soffits and the
foundation; total328 includes the independent8 source door triangles. Rear
wall and blue-belt caps sit0.015 source units behind their original cut edges
to prevent coplanar internal faces. Side-wall gray, belt blue and roof brown
come from measured original UV islands. The original roof silhouette, openings,
windows, columns, emblems, glass, PNG bytes and source local proportions remain.
No other town objects or ground are included.

`Gen3ImportedHGSSGyms` requires the complete original6×5 Viridian or7×5 Pewter
native drawing, every original permission, flat blocked body cells and original
civic ownership, with no hidden/boundary/prop conflict. The model occupies the
original blocked-cell union, including its native entrance tile and excluding
the walkable rear header and front corners. A source-preserving uniform fit
places its front door at localX56/Z49 relative to the blocked body origin,
which is1px inside the native entrance tile. AtZ54, the broad source front
columns would enter the walkable corners; the real source mask test rejects
that placement. Every source vertex and triangle is checked, using the existing
`Gen3ImportedGyms.clearance` triangle/tile clipping implementation. No source
building is stretched, flattened or trimmed to pass that mask.

`Gen3HGSSGymDoors` retains both curved source panels and all original8 triangles.
Native frames0/1/2 drive explicitly authored inward paired hinges at0/45/90
degrees; this is not an extracted HGSS animation track. Every pose is checked
against the same native permission mask. Missing images, partial upload failure
and cancelled scene construction unwind all temporary door meshes and preserve
native fallback. The static body never keeps a duplicate closed door behind
open animation frames.

## Building/ground contact

The Gym fits and Pewter-house fit explicitly use
`groundInset=.05`, provided by shared commit0fb2b673. This moves only the
source Y0 contact-ring vertices below native ground, including the matching
edges across source parts. Anchors, physical upper geometry, UVs and the native
ground are unchanged. It is not a whole-building translation.

Native FireRed before/after first-person views at the same Viridian fixture
showed fine ground striping between the original front columns before the
inset and clean contact afterward. LeafGreen independently rendered clean
contact. Closed/half/open source doors and real held-input entry/return still
passed after this change. The rear wall/roof separation fixes and the ground
contact fix address different coplanar surfaces.

## Native evidence and integration

Latest official runtime checked again: v0.3.95. The official Linux source and
LÖVE11.5 shell rendered both cities in FireRed and LeafGreen with isolated QA
profiles, Mesa llvmpipe and no companions. Default, first-person front/left/
right/rear, native2D, all source door frames, native interior and final returned
field captures were inspected. Both original Gym warps and return warps worked;
metatile/collision/elevation hashes were unchanged. The near-door fixture is a
QA teleport; it does not certify normal progression past Viridian's NPC/story
access. Missing-image LeafGreen fixtures retained native buildings and both
native warps. Drivers emitted PASS; shell shutdown returned1, not process0.

The reusable driver is `tools/qa/frlg-imported-exterior-review.lua`, with
`QA_FAMILY=gyms|houses`, an explicitly supplied `QA_UTIL` helper and a disposable
identity ending `-qa`. `QA_QUICK=1` omits side/rear camera inspection only;
`QA_MISSING_ASSETS=1` exercises source failure. At the end of this Gym batch the per-map source ledger
recorded25 eligible and107 unmatched assemblies per edition, with4 inspected
placements per edition. Later batches update the canonical ledger. It remains an inventory, not whole-game acceptance.

Production Scene remains parent-owned; native QA used a scratch overlay. Hooks:

- Cache successful `Gen3ImportedHGSSGyms.build(g,cells,newMesh,sceneryParts)`
  groups as `importedHGSSGyms`. Keep the complete native Civic fallback on false.
- Draw `Gen3HGSSGymDoors.draw(g,nativeAnim,draw)` in the ordinary opaque/depth/
  shadow pass and release its poses during scene teardown.
- Suppress a native animation card only when `ownsDoor(g,x,y)` returns true.
  Engine input, timing, sound, collision and warps stay authoritative.
- Expose `performanceSnapshot().scenery.hgssGyms` for the reusable QA driver.

The focused regional suite tests exact source/permission guards, positive and
negative full-triangle footprint examples, all source door poses, unavailable
images and late upload cleanup. Deterministic conversion re-creates every
output byte from the original local archives. Physical phones and the final
combined production Scene/package remain separate checks.

The preferred parent integration now uses the single
`Gen3ModernKantoBuildings` dispatcher for both verified houses and regional
Gyms. `build` returns `true,kind` only after the selected child completes;
`kind(g)` is `pewterHouses` or `hgssGyms` for per-family diagnostics. `draw`,
`release`, `ownsDoor`, optional `doorSurface` and `chimney` route only active
imported groups. Unknown drawings and failed uploads retain native fallback.
This dispatcher adds no Scene, companion or engine callback dependency.


## Cerulean source and rear UV repair

The subsequent batch adds `ha_gym-mesh` with `gym_door_001-mesh` from
[HGSS Cerulean City592833](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592833/),
also Kuramapika1, September1,2026. Its actual blue Water-type badge and all source
geometry/PNG bytes remain original. The exact7×5 native drawing includes a
blocked northeast header cell; the guard retains that permission instead of
assuming the entire header is walkable. The same original paired-panel poses,
blocked-triangle clearance and explicit ground contact inset apply.

All three source Gyms contained a separate exporter UV defect on their existing
raised-tower rear quad: two triangles mapped the entire facade atlas, producing
orange/gray vertical strips on the back. Those two original faces now sample the
original neutral gray wall strip (`kn_gym_a.png`, U25.5/32,V0.5). Positions and all
other UVs remain unchanged; no texture bytes are edited. Converter provenance
records exact repaired source triangle indices. Before/after source and native
rear captures show a continuous gray wall instead of the atlas projection.

Both editions passed native Cerulean Gym entry and return. Both existing cities
were rechecked in both editions after the UV repair, including rear/ground
contacts, original door states and actual entry/return. LeafGreen with Cerulean
PNG sources masked retained native source/fallback entry and return. Source and
processed seven-direction captures, native front/left/right/rear/2D views and
closure contacts were inspected. Latest official runtime was checked again:
v0.3.95 with official Linux LÖVE11.5 shell, isolated profiles and Mesa llvmpipe;
explicit drivers pass, while shell shutdown returns1. New focused assertions
verify both original rear triangles retain the neutral wall paint.

The reusable `QA_FAMILY=gyms_all` reviews all three cities; `cerulean_gym` targets
only the new source. The dispatcher remains `hgssGyms`; no new Scene API is
required. Deterministic conversion recreates the three models and provenance.

Cerulean's shared Civic underlay currently shows yellow path between columns
where native2D shows lawn. The building batch does not change shared floor
selection. Native ground/collision hashes are unchanged, but Cerulean rendered
acceptance is conservatively **pending** that shared native-ground donor review.
Its metadata includes an explicit `renderedGap`. The source census now records30
eligible/103 unmatched recognized assemblies per edition, with11 inspected;
Gym source coverage is3/11 drawings and accepted Gym coverage remains2/11.
These are inventory counts, not a game-completion percentage.


## Saffron Gym and closed connection projection

The subsequent regional source is `ya_gym-mesh` with `gym_door_006-mesh` from
[HGSS Saffron City592877](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592877/),
also Kuramapika1, September1,2026. Its own original purple trim/badge, orange
entrance columns, brown roof, paired glass panels, source UVs and PNG bytes
remain. The same measured closed rear/belt/roof/soffit/foundation and two-face
rear-tower UV repair apply because the physical source topology matches the
other three regional Gyms. Original285 triangles include11 excluded shadow
triangles; the final328 preserve all274 physical source triangles and add54
closure triangles. Deterministic conversion reproduces all four models and
provenance, with no changes to the previous three outputs.

The exact7×5 native drawing on canonical pair `general__rom_082d4b9c` has an
all-blocked roof header and distinct facade/corner metatiles. The adapter checks
actual region identity and local coordinates: `FR_SAFFRON_CITY` at(43,8), or
`FR_SAFFRON_CITY_CONNECTION` at(33,1). Only the city has native door permission113;
the actual connection projection has permission7 and no warp. That closed
projection renders its original source panels closed. The distinct6×5 Fighting
Dojo is rejected. Header, native paving, blocked body union, ground datum and
all collision/elevation/warp data remain unchanged. Source/door triangle clipping
passes at the same X56/Z49 native entrance anchor; the shared contact-ring
inset does not move the building or source door.

Latest official release was checked before this batch: v0.3.95, using its
Linux source/LÖVE11.5 shell, Mesa llvmpipe, isolated FR/LG QA profiles and no
companions. Both city Gyms passed original held-input door frames0/1/2, entry to
`FR_SAFFRON_CITY_GYM` and native return; native hashes remained identical. Both
actual connection copies built this source with hashes unchanged; they have no
entry/return claim. Missing-source-image LeafGreen retained native city entry/
return and closed connection fallback. Original/closed seven-direction views,
native overviews and front/right/left-quarter/rear-contact views were inspected.
The broad rear view is obstructed by native forest, so the rear-contact camera
uses the original blocked roof-header tile; this is a disposable QA camera
fixture, not a change to walking collision. Full rear/roof closure is additionally
visible in the independent closed-source viewer. No ground/closure flicker was
observed. Drivers emitted PASS; shell shutdown remains1.

The disposable fixture sets the official `FLAG_HIDE_SAFFRON_ROCKETS` (0x3E)
through the public script flag API before loading Saffron, so the normal story
NPC does not obstruct the doorway. It never saves this synthetic progress or
changes production story logic. `QA_FAMILY=saffron_gym` in the reusable driver
covers both actual maps and asserts the exact source built at each coordinate.
The connection record explicitly marks `nonEnterable`, with no false warp test.
The final ledger now records54 source eligible/35 inspected accepted/79 unmatched
assemblies per edition. Gym source coverage is5/11 drawings; accepted Gym
coverage is4/11, with Cerulean pending its separate shared-ground assessment.
Other Gym sources, native low/enterable Saffron houses and Silph Co. remain gaps.
No production Scene hook changes are required: dispatcher kind remains `hgssGyms`.
