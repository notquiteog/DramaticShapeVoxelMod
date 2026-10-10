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

## Underground warehouse crates

- [x] Native 67/68-above-83/84 crate: separate source lid, closed body, corner
  posts, rails and solid X braces on four sides. Height is12px rather than a
  wall-sized extrusion of the entire projected drawing. Geometry remains
  within x/z1..15 of each source cell. Original palette/art supplies all faces.

Gold/Silver/Crystal `gen2-warehouse-verified.lua`: native source images reviewed,
walkable `(5,3)` camera, four views, unchanged full tile/collision grids. All44
native crate patterns match44 production models per version; every source
crate cell asserted blocked. Inspected Crystal eye view and Silver overview;
additional Crystal `gen2-warehouse-back` inspects rear bracing. Unit test guards
footprint, height, lid and side/rear braces. Full-furniture and Underground
regressions pass. The initial recipe was gated to this warehouse; the reviewed storage extension
below adds the two other native crate maps.

## Department basement and Rocket storage crates

- [x] Reuse the complete native crate volume in GOLDENROD_DEPT_STORE_B1F and
  TEAM_ROCKET_BASE_B1F after separately inspecting their source maps.

Gold/Silver/Crystal `gen2-storage-crates.lua` passes: 32 department basement and
16 Rocket base native patterns match production models per game, every source
cell blocked, full native tile/collision grids unchanged. Four views per map
were captured from walkable cells. Inspected Crystal basement eye view and
Silver Rocket side view; neighboring machinery remains a separate coverage
task. Crate footprint/geometry test passes with the explicit three-map scope.

## Port and Rocket storage plants

- [x] Complete native 30/31–46/47–62/63 plants in Olivine/Vermilion port
  passages and Rocket B1: closed pot/rim/soil and solid curved leaves, sampled
  from each game's original plant palette. Claim the fourth floor row to avoid
  a partial-cell floor wall, while drawingRows keeps the original24px crop.

Gold/Silver/Crystal `gen2-storage-plants.lua` passes from walkable cameras:
2 models per map, both source cells blocked, full native grids unchanged and
four views captured. Independently inspected native source maps; inspected
Crystal port first/overview, Gold port rear and Silver Rocket first-person.
The initial3-row claim exposed a floor-wall artifact, fixed before acceptance.
Focused crop/scope and existing pot-mask/geometry tests pass. Port stairs and
Rocket workstation/shelves remain separate coverage items.

## Rocket base bookcases

- [x] Rocket B1 native paired bookcases: closed rear/sides/base/cap, two open
  shelves, three separate source-matched books per shelf and lower drawers.
  Integer artwork crops prevent seams from fractional spine slices.

Gold/Silver/Crystal `gen2-rocket-books.lua` passes: two native patterns/models,
all source cells blocked, full native grids unchanged, four walkable-camera
views. Inspected Crystal first and Silver overview; closed geometry remains
inside the southern blocked cell of the original drawing. Focused bounds,
full native furniture, plant and crate regressions pass. The adjacent terminal
is still the next separate coverage task.

## Rocket base terminal

- [x] Rocket B1 terminal now has a desk with knee space, drawer pedestal,
  closed CRT shell/stand/vents and mouse. The original slanted screen is
  unprojected using its native atlas corners; it no longer repeats across a
  generic box lid. The wall covered by the original desk drawing is restored
  from native4/20 tiles at the neighboring16px wall height.

Gold/Silver/Crystal `gen2-rocket-terminal.lua` passes: one complete native
assembly, all four source cells blocked, full native tile/collision grids
unchanged, four views from walkable `(19,13)`. Crystal first/overview inspected;
initial wall gap and oversized backing were corrected before acceptance.
Focused footprint/screen/underside/wall tests and complete-furniture regressions
pass. The native walkable chair remains unchanged. This is one workstation,
not general terminal coverage across all tilesets.

## Native stair traversal audit

- [x] Celadon and Goldenrod department1F↔2F and both directions of each
  Olivine/Vermilion internal passage stair pair:24 successful native steps and
  warp landings across Gold/Silver/Crystal. Full tile/collision grids remain
  unchanged after rendering the approach. Driver is committed for repetition.
- [ ] Descending department stairs remain visually difficult to read at eye
  level; successful traversal does not close their visual coverage.

`gen2-stair-traversal.lua` (committed as `gen2_stair_traversal_driver.lua`) takes
first-person approach captures and invokes native `movePlayer`, then verifies
native destination/landing. Inspected Crystal four representative approach
views. Source port stairs are already correctly recipe-pinned; the earlier
plant fixture put its camera directly on one ascending stair. That view was
not evidence of a missing stair recipe. Other floors/warp families remain
outside this bounded traversal audit.

## Crystal Battle Tower floor ornaments

- [x] Remove the incorrect block28 “reception” recipe. It claimed only the
  upper half of a circular floor ornament and raised it into a pink console.
  All four native cells under each of the four complete ornaments are walkable.
  Their original artwork now remains complete at floor level.

Crystal `gen2-tower-footprints` verifies the16 walking cells;
`gen2-tower-lobby-floor` verifies four complete drawings, no false reception
models, unchanged full native tile/collision grids and four walkable-camera
views. Before/after overviews inspected. Source-crop regressions pass.
Gold/Silver imported maps contain no Battle Tower1F or Outside; this is an
explicit Crystal-only correction. Other lobby furnishings need review.

The MART shallow-descent experiment was reverted because the forward eye view
was not enough evidence of an improvement. Native stair geometry is unchanged;
traversal evidence above remains valid, and descending visual review stays open.

## Crystal Battle Tower kiosk and seats

- [x] Replace the legacy lower-half PC crop with the complete four-row blue
  kiosk. Separate closed pedestal, display shell, original upright screen,
  sloped controls and projected lid; sides/back/underside stay enclosed.
- [x] Six native low cushions replace the old table interpretation of block7.

Crystal `gen2-tower-furniture-footprints` confirms both PC cells and all six
seat cells blocked. `gen2-tower-furniture` asserts1 PC/6 seats, four native floor
ornaments still walkable, full grids unchanged and four views at walkable
`(6,8)`. First/overview inspected against original source. The initial generic
PC adapter was rejected in favor of this integrated kiosk model. Focused whole
crop/bounds/cushion-height, complete-furniture and source-crop tests pass.
Gold/Silver do not contain these maps. Other Battle Tower details remain open.

## Crystal Battle Tower north-wall doors

- [x] Twelve complete north-row door/control/glass drawings (lobby1,
  battle room1, hallway10) now have closed rear panels, narrow jambs and lintels.
  Their16px height matches neighboring native wall ornaments. Walking approach
  interiors remain clear; door art is not repeated on a box top.
- [x] Hallway's offset elevator drawing: separately resolved below; the
  north-row recipe remains restricted to avoid duplicate matches.

Crystal `gen2-tower-doors` captures all three maps in four views, asserting
native walkability, matching production counts and unchanged complete grids.
Inspected final battle-room eye and hallway overview. Focused open-approach,
closed-frame and existing Tower/furniture tests pass. The seven existing
rounded stone ornaments were inspected in `gen2-tower-panels-before` and
retained; their source footprints are blocked. Animated door states and native
Tower challenge progression are not covered by these static fixtures.

## Crystal hallway elevator assembly

- [x] The offset4×4 source assembly now folds its solid left wall into the
  single blocked upper-left cell. The door stands at the north edge; both
  lower cells and the upper-right approach remain clear. Original roof band,
  wall face, controls and glass are preserved on their respective surfaces.

`gen2-tower-elevator-footprint` confirms three walkable cells and one blocked
cell. Crystal `gen2-tower-elevator-entry` asserts one model, clear lower warp
row, unchanged native grid and four views. Native `movePlayer` then enters the
original BATTLE_TOWER_ELEVATOR destination. First/overview inspected. Focused
vertex bounds/open-approach and complete-furniture tests pass. Challenge
progression and animated door sequences remain outside this static-model scope.


## Crystal Battle Tower exterior

- [x] Replace the generic low U-shaped extrusion with the complete native
  glass landmark: six side-wing storeys, eight taller chamfered shaft bands,
  pale flat roof, closed sides/back/base, supported entrance canopy and
  yellow entry panes behind the original warp boundary.
- [x] Both native entry lanes remain empty below the18px canopy; the only
  low portico supports occupy the two original blocked cells. All400 source
  tiles must match before this specialized assembly claims the drawing.
- [x] Later generic door/volume/post detection respects existing model claims.
  The first rendered pass exposed yellow door art being extracted again as a
  fence/step; tracing identified the post pass and the final view is clear.

`gen2-tower-exterior-before` preserves the generic baseline. Final Crystal
`gen2-tower-exterior-verified` renders true model-centered front/side/rear and
native first-person at walkable(9,12), north-facing, pitch-.25. All four views
were inspected at NIGHT; complete native tile/collision grids and400 ground
claims remain unchanged. Both original entrances were traversed via native
`movePlayer`, reaching BATTLE_TOWER_1F. The committed driver reproduces these
checks in an isolated QA profile. The off-map rear diagnostic camera also shows
existing repeated border terrain behind the map; that terrain is outside this
model's claim and remains a separate renderer issue.

Focused exterior/footprint/whole-source tests and the existing114-check Gen2
shape suite pass, including unclaimed native wall/door classifications. Tower
interior and general exterior regressions pass. Gold/Silver imported map tables
have no Battle Tower; this batch is Crystal-only. Daylight, animated entrance
states and native challenge progression are not claimed verified.

## Gold/Silver/Crystal Mansion clock and low book racks

- [x] Celadon Mansion1F clock now has its original continuous dial/case face
  recessed into a closed wooden body, with separate projected crown. The old
  generic shelf adapter split and repeated its pixels as book spines.
- [x] Adjacent book racks now use the native lower16px facade, four separate
  original book spines and lower storage panels. Blank upper wall/projected
  lid rows no longer inflate the rack to clock height. Native lid art sits on
  the closed top; sides, rear and underside are complete.

Independent `gen2-historical-source` map renders and native metatile15 grids
were compared in all three games. `gen2-mansion-clock-before` records the
Crystal generic-model defect. Final `{gold,silver,crystal}-gen2-mansion-assemblies`
assert1 clock/2 racks, native lower cells blocked and complete tile/collision
invariants. Four model-centered/first-person views captured per game from
native player cell(1,5), north-facing, pitch.12; all Crystal views, Gold eye/rear
and Silver overview/side inspected. Original walking floor stays clear.

Focused clock/recess/rack-height/source/bounds tests,60 source-crop recipes,
34 shared assemblies, Tower/Rocket and house/department regressions pass.
The recipe can also match the same rack drawing elsewhere in the Mansion
family; those rooms need their own rendered review and are not counted here.
Other Mansion furniture and stairs remain open.

## Gold/Silver/Crystal Mansion workstations

- [x] Celadon Mansion2F(1) and3F(3) native desktop/CRT assemblies per game:
  original screen unprojected onto an upright display, closed vented case and
  pedestal, separate keyboard with sealed sloping edges, complete desk legs
  and underside. Native papers remain on the desktop; monitor art is no
  longer flattened onto it. CRT display proportions corrected after review.
- [x] The matching low book rack from the previous batch is also visible and
  reviewed in both upstairs rooms.
- [ ] Native chair drawings remain flat: Crystal audit confirms all four
  chair cells collision0/walkable. Raising occupied furniture there would
  intrude into original walking space; no collision change was made.

All three independently imported games agree on source metatile18. Baseline:
`crystal-gen2-mansion-desks-before`. Final:
`{gold,silver,crystal}-gen2-mansion-workstations-final`, four views on both floors
from native player(1,5). Fixtures assert1/3 assemblies, both source footprint
cells blocked and full grids unchanged. Final Crystal3F eye/side, Gold2F rear,
Silver2F overview inspected. The initial screen crop included brown casing;
corrected native parallelogram corners before final acceptance. Rear cameras
were moved nearer to see the model behind room-wall occlusion. First-person
3F retains native NPCs, which obscure part of the left desktop.

Focused workstation/clock/source/whole-furniture suites pass. Original chairs,
room-wall/stair appearance and non-Mansion workstations remain separate work.

## Gold/Silver/Crystal Kurt's tall bookcases

- [x] The legacy `traditional_drawers` depth recipe is actually two-tier
  book shelving. Retained its stable ID but replaced generic split crops with
  two rows of five original spines, lower storage front and the native wooden
  projected lid. Cases, shelves, contents, backs and undersides are enclosed.
- [x] Existing authored Violet drawers/hutch were inspected and retained;
  this batch does not replace those separate source drawings.

Compared independent Kurt source renders and metatile26 in all three games.
Baseline `crystal-gen2-traditional-before`. Final
`{gold,silver,crystal}-gen2-traditional-tall-books` asserts2 racks per game,
blocked lower source cells and unchanged native grids. Crystal overview and
Silver rear inspected. Initial eye/side cameras were obstructed by the native
NPC/hutch; `crystal-gen2-traditional-tall-books-final` shifts the player to
walkable(2,3) and camera nearer the cases. Inspected clear eye/side views.
Five targeted furniture/source suites pass. Other traditional furniture,
wallpaper and the apparent wall-picture/table mismatch remain open.

## Gold/Silver/Crystal Kurt wall picture

- [x] Legacy `traditional_low_table` crop is a framed wall picture, found only
  at Kurt's north wall in the Crystal traditional-room census. It now has a
  shallow closed back and raised frame, mounted at the north edge of its two
  blocked cells. Complete original artwork stands upright at wall height;
  the walking apron underneath is clear. Stable recipe ID retained.

Independent native source/metatile20 agreed across Gold/Silver/Crystal.
`gen2-traditional-picture-audit` records Crystal position(16,0) in tile units,
blocked collision7 in both cells. Final
`{gold,silver,crystal}-gen2-traditional-picture-final` verifies one model/game,
blocked source cells, the two walkable cells immediately below, and unchanged
full grids. Crystal overview/eye, Gold side and Silver rear inspected from
native player(9,3). An initial invented full-height backing panel was rejected;
final geometry is only the shallow wall-mounted frame. Focused frame bounds,
source orientation and five neighboring furniture suites pass. Remaining
traditional wall panels and room-wide coverage are still open.

## Gold/Silver/Crystal facility workstations

- [x] Complete source workstation adopts the closed CRT/keyboard/desk model
  with its own live facility artwork. Comparison against Mansion found11
  native border/casing pixels differ; the display geometry is compatible,
  while sampling remains per tileset/game. No ROM image was copied.

Independent facility source/collision census in each game finds11 complete
workstations: Mr Pokémon1, Ruins research center1, Power Plant3, RocketB2F1,
RocketB3F5. Both cells of every source assembly are blocked. Baseline Crystal
`gen2-facility-workstations-before` shows the monitor flattened on the desktop.
Final `{game}-gen2-facility-workstations` verifies the three public maps;
`{game}-gen2-facility-rocket-workstations` verifies both Rocket floors. Each
captures four views and asserts expected counts and unchanged complete grids.
The initial B2F camera was on its southern wall, so corrected to native(25,9).

Inspected Crystal Mr Pokémon eye/Power Plant rear, Gold Ruins overview,
Silver Power Plant side, Crystal RocketB2F overview and Gold RocketB3F eye.
B3's first rear view was blocked by server banks; the follow-up
`{game}-gen2-facility-rocket-b3-open` at native(21,12) verifies the lower room
and supplies clear Crystal overview, Gold side and Silver rear evidence.
Counts validate placement coverage; these representative views do not certify
all unrelated objects in those maps. Six focused furniture/source suites pass.
Facility bookcases and other remaining generic furniture remain open.
