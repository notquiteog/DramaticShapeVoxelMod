# Gen2 model coverage checklist — 2026-10-09

This records bounded model work, not approval of every classified tile.

- [x] Department-store native window drawing (MART 14/15/28/29): recessed
  original reflection artwork, closed backing, dimensional frames and sill.
  The pane no longer appears on a cube's roof. All geometry stays inside its
  blocked 16px source cell; native map/collision/warp data is unchanged.
- [x] Department-store elevator, reception-window overlap, cash register and
  directory: authored and verified in the bounded fixtures below.
- [ ] Department-store stairs: existing native stair recipes remain; a separate
  traversal and visual review is still needed to close stair coverage.
- [ ] Other Crystal building/interior families: inventory and per-model review
  remain outstanding; classifier counts cannot close this item.

Validation: official engine 0.3.52, disposable `emerald-port-crystal-qa`
identity under `.scratch/coverage-20261004/profiles`; no portable.txt in the
engine root. Fixture `crystal-windows.lua` captured Celadon 1F/6F and Goldenrod
1F at overview, orbit side/rear and first person. Inspected Celadon 6F overview
and first-person, Goldenrod 1F side. Native pane reflections/frame and walking
floor are retained. Source reference: `results/crystal-source`. New renders:
`results/crystal-crystal-windows`. Native tile-grid invariant passed in all
three scenes; no collision/warp code changed. Player saves were not used.

Tests: `gen2_department_windows_test`, `house_department_models_test`,
`gen2_depth_furniture_test` pass. Tests bound all model vertices to the native
cell and protect the complete vertical glass crop. No version/release change.

## Elevator follow-up; Gold and Silver evidence

- [x] Complete MART elevator door/control panel drawing: closed rear door,
  narrow jambs, lintel and control-wall volume. Native warp cell `(2,0)` is
  collision122 and walkable in these fixtures. The new doorway leaves its
  interior approach open; the door is only at the cell's rear plane. Geometry
  tests protect that open space and bound the whole two-cell assembly.
- [x] Counter-overlapped window drawings (14/15 above 42/43): closed by the
  reception follow-up below.

Gold/Silver QA caches were v12 and rejected by engine0.3.52. Reimported the
user's installed ROMs into disposable `emerald-port-gold-qa` and
`emerald-port-silver-qa` identities through the official importer (v13); no
player saves copied. Native source renders inspected independently for both
variants: store window/elevator drawings agree, while plant art differs.

`crystal-elevators.lua` captured Celadon1F and Goldenrod1F in Gold, Silver and
Crystal (four views each), with native tile-grid invariant and walkable-warp
assertions. Inspected Crystal and Gold first-person Celadon entrance, Silver
Goldenrod overview. Results under `results/{game}-crystal-elevators`; native
references under `results/{game}-crystal-elevator-source`. All three targeted
suites pass. This confirms these store assemblies only, not all Gen2 models.

## Reception window/counter overlap

- [x] The previously open 14/15-above-42/43 drawing now has separate upright
  native glass and a closed horizontal counter case/worktop. Final pane depth
  matches adjacent ordinary windows; the first prototype's over-recessed panes
  were corrected after first-person inspection. All vertices stay in the
  original blocked cell. The original reflection and worktop art stay distinct.

Gold/Silver/Crystal `crystal-counter-windows.lua`: Celadon1F and Goldenrod1F,
24 final captures total. Inspected final Crystal/Gold Celadon first-person,
Silver Goldenrod overview and side. Native layout and elevator-walkability
checks passed. Same three test suites pass, including overlap surface direction
and bounds. Source and final captures remain scratch-only. Other store props
and other map families are still not signed off.

## Johto brick-building entrances

- [x] Complete 55/56-above-57/58 Johto doors now sit in 2px inward recesses,
  with closed jamb/reveal, lintel and threshold surfaces. Original door art
  stays in order and at its original facade coordinates. Partial drawings and
  other tileset families do not carve openings. No outward geometry is added.
- [x] Paired tile38 window bands: closed by the following window pass.
- [ ] Other door/window families, major city landmarks and remaining generic
  scenery require further review; this entrance pass is not full exterior
  coverage.

`gen2-door-recess.lua` verified walkable camera cells in Goldenrod `(14,23)`
(facing the small brick house) and Olivine `(19,19)` (Mart), Gold/Silver/Crystal.
Four views each; native tile-grid invariants passed. Inspected Crystal both
first-person entrances, Silver Olivine first-person and Gold Goldenrod overview.
Native source city images were inspected for all three versions; larger map
art differs between games, so whole-map parity is not assumed. Earlier
`gen2-city-model-review` used unvalidated camera positions and is survey evidence
only, not a walking fixture. `gen2_exteriors_test` passes with complete/partial
opening assertions and existing Kanto/roof/wall preservation checks. Scratch:
`results/{game}-gen2-door-recess`, `results/{game}-gen2-city-model-source`.

## Paired Johto window bands

- [x] Complete paired tile38 bands now sit 1px inward from the brick facade,
  with closed reveals and sill. Their full native 16x8 drawing remains in its
  original vertical plane and position. Lone unmatched tiles stay unchanged.

`gen2-window-bands-eye.lua`: Gold/Silver/Crystal Goldenrod `(12,23)` and
Olivine `(8,23)`, native walkable positions, overview/orbit/first-person.
Final fixture includes both full native tile and collision-grid invariants.
Inspected Gold and Crystal Goldenrod eye views, Silver Olivine eye view; all
six scenes passed. Earlier eye views were too low to show whole windows and
were replaced with upward camera pitch. Existing exterior/roof suites pass,
including paired and partial band regressions. No collision or warp changes.

## MART cash register

- [x] Complete 32/33-above-48/49 native till drawing now becomes a closed
  counter pedestal, raised display, printer and sealed inclined keypad. Source
  screen/key/printer pixels are kept on their respective faces; equipment is
  no longer a flat counter-top texture. All parts remain within one source cell.

Gold/Silver/Crystal `gen2-register.lua`: Celadon1F and Goldenrod1F, all four
views and full native tile/collision invariants. Inspected Crystal/Gold Celadon
first-person and Silver Goldenrod overview. Additional Crystal
`gen2-register-side.lua` inspected Cherrygrove Mart and Celadon side views from
asserted walkable camera cells; no open model sides seen. Ordinary Mart art was
inspected independently (`gen2-register-source`). The side fixture initially
retained an irrelevant elevator-cell assertion; it was removed before the
successful captures. Register, department-window, full furniture and depth
furniture tests pass. Other shop furniture remains separately scoped.

## Department directory

- [x] Complete 44/45-above-60/61 drawing now has a closed backing and recessed
  framed sign face. Native lettering is no longer repeated on the top/sides.
  Its imported Crystal background event at Celadon1F `(14,0)` resolves to
  `1c:49e9` / text `1c:4aea`, the six-floor service directory, confirming the
  intended object rather than guessing a cabinet from its outline.

Gold/Silver/Crystal `gen2-directory.lua`: Celadon1F and Goldenrod1F overview,
side/rear orbit and first person, native tile/collision invariants. Inspected
Crystal/Gold Celadon first-person and Silver Goldenrod overview. Stair approach
remains clear; entire model bounded to its blocked source cell. Directory,
register, window, complete-furniture and depth-furniture suites pass. Native
artwork and imported event/text data remain local QA references, not bundled.

## Native collision audit of the new store patterns

`tests/gen2_store_footprint_driver.lua` checked every MART map in each imported
version on engine0.3.52. All five new recipe patterns align to native cells.
Window, overlap, directory and register cells are blocked; every elevator's
approach is walkable and its adjacent control-wall cell is blocked. All pass.

| Native drawing matches | Gold | Silver | Crystal |
| --- | ---: | ---: | ---: |
| Plain store window | 114 | 114 | 112 |
| Counter/window overlap | 8 | 8 | 8 |
| Elevator and control panel | 12 | 12 | 12 |
| Cash register | 17 | 17 | 17 |
| Department directory | 12 | 12 | 12 |

These are pattern/footprint counts, not visual sign-off of every placement.
The difference in window totals reinforces that versions are checked
independently. Runtime outputs: `results/{game}-gen2-new-fixture-census`.

## Goldenrod Underground stalls and plants

- [x] Three complete long green stalls: closed shaped ends, native green tops,
  fluted sides and underside. Front skirt pixels are kept off the countertop
  after first-person review found their initial crop leaking onto the top.
- [x] Nine tall and three short plants use the existing closed native-palette
  planter/leaf model rather than cuboid tree drawings.
- [ ] Underground stools intentionally remain flat: native collision0 permits
  walking through those drawings. Raising stools would obstruct the aisle.
- [x] Underground static overview ceiling obstruction: fixed by the camera
  gate follow-up below.

Recipes are explicitly scoped to GOLDENROD_UNDERGROUND, which uses TILESET_GATE
(the similarly named warehouse uses TILESET_UNDERGROUND). An initial wrong
family assignment produced unchanged art and was corrected before acceptance.

Gold/Silver/Crystal native source images inspected independently. Final
`gen2-underground-verified.lua` asserts 3 built stalls and plant presence, with
full native tile/collision invariants at walkable `(4,12)`. All report 3 stalls,
9 tall plants and 3 short plants. Inspected Crystal/Silver first-person and
Gold side views. Counts are assembly matches, not all-world visual coverage.
Native stool/counter collision examined in `gen2-underground-footprints`.
Underground, complete-furniture and existing depth-furniture tests pass.

## Enclosure camera gate

Gen2InteriorShell now requires ThirdPerson.selected() before interpreting a
hidden player as a collapsed boom. Previously, showsPlayer()==false outside
3RD enabled the ceiling in ordinary static views. The change keeps static
cutaways open, preserves first-person ceilings and preserves collapsed-boom
ceilings. No camera or collision parameters change.

Focused camera-gate and existing depth-style tests pass. Gold/Silver/Crystal
`gen2-underground-audit.lua` succeeds with 3/9/3 assembly counts, full native
tile/collision invariants, and blocked-cell checks for every matched new
Underground counter/plant. Inspected Crystal/Silver overview (gray obstruction
removed), Crystal/Gold first-person (ceiling retained). This is direct evidence
for Underground; other dungeon maps still need individual visual review.
