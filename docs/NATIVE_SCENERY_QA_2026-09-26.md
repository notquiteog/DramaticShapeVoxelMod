# Native scenery and settings, 1.28.0

Engine: official Gen1Recomp **0.3.20**, also confirmed as the latest GitHub release on 2026-09-26. Source-linked Battle Art with Online 0.8.0, Wilds 2.4.1, Ride 0.4.0, Doubles 0.12.0 and Skies 1.13.1. Disposable `ascendant-{game}-qa` identities under `/home/admin/Projects/.scratch/ascendant-20260926/profiles`; player saves untouched. FireRed/LeafGreen use current imported user ROM caches, Crystal/Yellow use copied caches. No ROM material is included in this repository or release.

## Changes and evidence

- Responding to the reported flat centers: tree/rock geometry now consists of solid intersecting canopy/stone masses; source images provide native colors instead of a flat front silhouette. Card options remain unchanged. Shelf contents are separate volumes, and reviewed terminal/rack families have projecting controls and modules. Native grave variants use closed footings, upright inscribed bodies and stepped caps.

- Crystal: reviewed sculpture/monument/orb/bicycle drawings use closed native-color volumes. Bicycle thickness is capped at three world pixels. The shared timber exterior builder adds side/back siding only to timber buildings; original flat brick/plaster styles remain unchanged.
- FireRed/LeafGreen: 31 additional cabinet recipes use closed panels, cornices, kickboards and recessed native facades. Specific authored equipment takes priority. This raises the designed-object regression inventory from 58 to 89. Six Tower grave recipes raise the final regression inventory to 95. These are complete recipe cases, not a count of newly modeled placements.
- Native atmosphere uses actual map dimensions and stable seeded placement. Forest/cave/tower choices, fog visibility/thickness and particle intensity/speed are consumed live. FULL particle rendering now uses the supported scoped effect API. SUBTLE has reduced intensity; OFF suppresses particles. Tower mist motion is still missing, so FOG SPEED is explicitly partial.
- Native SCENERY TEXTURES controls optional subtle scenery grain. Actors and UI retain original textures, and the draw flag is restored even on errors.

Scratch launch command: `./run.sh GAME CASE` from the directory above. Drivers use public source-engine APIs and isolated fixture teleports, with core-update mod hooks dispatched explicitly where clocks/settings require them.

| Fixture | Evidence / limitation |
| --- | --- |
| `leafgreen/native-equipment` | Museum 1F, Silph 6F, Power Plant, Mansion B1F; overview and first person. Native location-preview overlays dismissed for the final run. Equipment and surrounding walls inspected; not every cabinet face is visible from these positions. |
| `crystal/native-sculptures` | Lance, Olivine, Celadon, Pewter and bicycle-shop shared props, overview/first person. Native sculpture source retained. Some bootstrap dialogue obscures the lower screen. |
| `firered/native-atmosphere` | Viridian Forest, Rock Tunnel and Pokémon Tower, enabled/disabled controls; final actual-scene captures with native location previews dismissed. Driver completes without renderer recovery/errors. Cave flash forced to zero only in the fixture to inspect geometry. |
| `crystal/gb-atmosphere`, `crystal/gb-reference` | Ilex Forest, Tin Tower, Ecruteak. Flat-source comparisons and corrected city overview inspected. The initial Ecruteak reverse camera intersected a building, so that capture is not visual approval. Some lower-screen dialogue remains. |
| `firered/forest-shadow` | Detailed textures with shadows ON/OFF. Shader compiles and renders; triangular crown shading disappears with shadows off. This appearance is not claimed fixed or proven to be z-fighting. |
| `leafgreen/parity-options` | Ten native menu rows adjust, persist to engine options, survive reopen, then restore. |
| `crystal/gb-parity-options` | Nine native atmosphere rows adjust, persist, reopen and restore through the actual GB menu. |
| `yellow/yellow-smoke` | Original Gen1 Pallet voxel pipeline loads at the selected level. No new Gen1 scenery adapter. |

All 263 production Lua files compile. Seven focused suites pass: voxel hull/depth cap, Crystal furniture, designed interiors, Crystal exteriors, native atmosphere, native option consumers (390 checks), and in-game options. These tests cover source/geometry contracts; they are not all-map gameplay certification.

Additional source captures: `firered/tower-models` and `leafgreen/tower-models` cover Tower 3F/5F/7F from overview/reverse/first-person views. `firered/organic-native` covers native forest and gym rocks; `crystal/organic-crystal` selects a walkable path cell with a walkable northern neighbor (no 3x3 clearing exists near the forest fixture) rather than placing the camera inside trees. Updated LeafGreen equipment and Crystal city captures inspect separate modules and fuller volumes.

## Remaining work

The refreshed `option-support.json` records **Gen2: 45 implemented, 30 partial, 13 missing, 2 provider, 2 other-engine; Gen3: 40 implemented, 9 partial, 41 missing, 1 provider, 1 legacy alias**. “Implemented” means a source consumer exists, not exhaustive device QA. Missing controls are read-only diagnostics, not working controls.

Every-city/route/interior visual sign-off is unfinished. The prior 388-map Crystal census still contains 1,145 generic wall/drawing signatures; many are legitimate walls, but they have not all been visually reviewed. This release improves known object families without inventing semantics for unclassified tiles. Gen3 world-space battle actors/camera, specialty Legendary scenery settings, native capture effects and animated ground mist remain outstanding. No new multiplayer or physical-controller validation in this batch.

## Follow-up integration and correction

Narrow Crystal border rows now get separate round trees; 2x2 source trees remain one broad tree. Native art height no longer stretches a crown through depth. Gen3's taller source portraits retain one normally proportioned tree. Native ROCKS & BUSHES switches solid/source-cutout presentation; tree art remains independently selectable. Mesh revision 73 includes the option in cache fingerprints.

Optional weather adapted from MIT Voxel Ascendant 2.0.2 is live across all three engines; source/license preserved in THIRD_PARTY_NOTICES. Rendered CLEAR/RAIN/SNOW/FOG/STORM cases completed in Yellow, Crystal and FireRed, with FireRed rain inspected. No changes to gameplay weather. Rendering is screen-space atmosphere, not volumetric weather. Gen1/2 battle consumers compile but battle weather has not received new battle-fixture QA.

Latest checks: 264 production Lua modules compile using native LuaJIT; weather parity 41 checks; native option consumers 399; hull, original-tree footprint, native atmosphere, designed interiors (95), Crystal depth furniture, scenery geometry and menu tests pass. Real FireRed and Crystal menus edit/persist/reopen/restore WEATHER and ROCKS & BUSHES. LeafGreen model/card/detail/cave-rock fixture completes. Crystal New Bark tree correction inspected; the Ilex fixture remains visually crowded/partly obscured and is not a quality sign-off.

Wilds/Ride input integration additionally passes actual rebound G press/release through the running Yellow, Crystal and LeafGreen engines with the catching HUD hidden: exactly one selected Great Ball consumed, Poke Ball inventory unchanged. Native selected-ball input suite passes 61 assertions; Gen3 settings/capture 53; official Gen1/2 shared capture modules 104. Input injection is not physical-controller QA. See Wilds' parity document.

Final source audit covers 92 declarations; Gen1 has 85 implemented consumers, six native-only controls and one provider control. Complete parity and every-map visual polish remain open; see ASCENDANT_FEATURE_PARITY.md.

Native bushes remain independently selectable with illustrated trees. Bush cards have no added tree stem; cuttable trees retain their taller small-tree silhouette. The fork includes upstream/master through the fetched absol89 head; DRAMALESS is divergent and is not claimed fully merged.

Route 29 (10,2), player (10,4), rotating third-person: all four combinations of native/illustrated trees and model/card bushes render and were inspected. Bootstrap credits obscure the bottom third; this verifies the visible switch, not complete scene quality. Cut-versus-Headbutt classification has a focused regression check.
