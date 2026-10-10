# Gen3 native model coverage — ongoing

This checklist records inspected models, not inferred coverage from tile
classification. FireRed, LeafGreen, Emerald, Ruby and Sapphire full-world
coverage is unfinished.
Collision, native metatile IDs, warps and player saves are not modified.

## Verified batch: Mossdeep Space Center

- Complete 9×8 native building pattern; original facade and glazing.
- Closed two-wing shell, side/rear window bays, solid piers and cornices.
- Recessed native doorway, 24px headroom and aligned native door animation.
- Raised circular roof apparatus, concave dish, faceted central rocket,
  red lattice launch gantries with solid braces, separate short equipment frame.
- Exact complete 6×6 projected rocket/gantry pattern restores native water and
  grass beneath the original projected drawing. Incomplete/other patterns remain
  unconsumed; c.mid/collision/elevation are preserved.
- All geometry remains within the native blocked 9×8 building footprint.

Evidence: engine 0.3.52, existing isolated `emerald-port-emerald-qa` identity,
`/home/admin/Projects/.scratch/coverage-20261004/results/emerald-space-center-review`.
Native map and enlarged source composite inspected; production front, right,
rear, left, eye-height and native door animation captures inspected. Daytime
fixture uses actual production meshes with a controlled inspection camera.
This is appearance/geometry evidence, not normal input traversal evidence.

Focused tests: `gen3_space_center_test`, `gen3_civic_test`, `gen3_hoenn_test`,
`gen3_scene_cache_test`. Real-map building footprint census: Emerald 58 recognized
assemblies, zero low faces overlapping the central 8×8 of collision-0 cells.
This bounded audit does not establish universal collision safety or coverage.

## Next batches (source review required)

- [ ] Lilycove department store and museum; other regional Contest Halls.
- [ ] Slateport specialist buildings and remaining Rustboro scenery.
- [ ] Remaining Emerald city/facility structures and unusual foliage.
- [ ] Remaining FRLG specialized exteriors and interior/furniture families.
- [x] FireRed dedicated isolated runtime verified for recorded Cinnabar and Pewter batches; other families remain unverified.
- [ ] Exhaustive original-art census, with first-person/orbit evidence per family.

## Verified batch: Rustboro Devon Corporation

The complete 10×9 original drawing now has a raised central tower and lower
wings, original mosaic roofs, pointed windows, three facade storeys, parapets,
solid pilasters and a shallow winged medallion. Side/rear elevations continue
the native window vocabulary. Both native entrance cells retain separate door
surfaces and 28px headroom. The wings end before the front walking strip;
those exact native pavement cells retain their original source pixels.

Production evidence: same isolated Emerald engine/profile as above,
`results/emerald-devon-review`; source composite plus four directional, eye and
native door captures inspected. Focused Devon/SpaceCenter/Civic/Hoenn tests pass.
Emerald footprint census now recognizes 59 assemblies, zero flagged low faces.
The Space Center's entrance tunnel also gained a closed rear panel, avoiding
an unintended view through the entire building when the entrance is open.

Rustboro's other houses, Lilycove specialists and Slateport specialists remain
pending. These two individual buildings do not establish family-wide coverage.

## Verified batch: Rustboro urban houses

Seven complete source patterns cover eight actual Rustboro residences, including
tall white apartment blocks and tan houses with rooftop ventilation cabinets.
Closed roof overhangs preserve the native rear walking row; full side/rear walls
use native window panels and solid sills. Roof materials repeat the actual
interior roof pattern without stretching source fascia or duplicating cabinets.
Door recesses follow the measured 20px native frame. Stone-backed homes use the
reviewed city pavement; the east lawn-backed home retains its grass underlay.

Source and production artifacts: `results/emerald-rustboro-homes-review`, same
isolated Emerald0.3.52 profile. Eight placements/32 directional captures plus
entry views generated; representative front, side, rear and eye captures across
all seven patterns inspected. Neighboring buildings remain in the production
scene; a few long-distance initial views were occluded and the camera was
corrected. Focused Urban/Civic/Hoenn/SpaceCenter/Devon tests pass. Real-map
Emerald footprint census: 67 recognized assemblies, zero flagged low faces.

This completes the reviewed Rustboro house patterns, not every exterior or
scenery element in Rustboro and not Emerald coverage as a whole.

## Verified batch: Lilycove blue-roof homes

Five complete patterns cover six Lilycove homes. Native blue-tiled gables,
recessed doors/windows, pale panels and solid blue vertical stiles continue onto
closed side/rear elevations. Native rear walking rows remain clear beneath the
roof overhangs; cliff-edge placements retain the engine's elevation/retaining
geometry. Neither map collision nor terrain elevation is changed.

Artifacts: `results/emerald-lilycove-homes-review` and the isolated
`results/emerald-lilycove-southwest-home-review`. Six placements/24 directional
captures plus eye/door views; representative views across all five patterns
inspected. Long-distance multi-placement camera state initially produced empty
views for east/southwest houses; resetting the inspection camera and capturing
the southwest placement separately resolved the fixture issue. Empty initial
captures are not verification evidence.

Focused Lilycove/Civic/Hoenn suites pass. The native Emerald footprint census
now recognizes 73 assemblies, zero flagged low faces. Lilycove department store,
museum, contest hall, specialist shop and harbor remain visibly flat/pending.

## Verified batch: Lilycove Contest Hall

The exact 7×7 native hall now has a closed red pavilion shell, original emblem
entrance, chamfered silver-blue roof, rounded faceted fasteners, raised V-shaped
pennant ribbons and side/rear structural bands. The original flat pennants are
removed only from their known source rectangles to avoid duplicate decoration.
The raised roof retains its blocked-body/walkable-rear-row separation.

Production front/right/rear/left and eye views inspected in
`results/emerald-lilycove-contest-review`, isolated Emerald0.3.52 profile.
ContestHall/Civic/Hoenn focused tests pass. Emerald footprint census: 74
recognized assemblies, zero low-face overlap flags. Other regional Contest
Halls use different drawings and remain outside this model's coverage.

## Verified batch: Lilycove and Slateport harbor terminals

Two exact 7×6 source patterns now have closed corrugated gable roofs, native
nautical facades and recessed entrances. Lilycove retains rectangular windows;
Slateport has solid circular frames and recessed native glass on all elevations.
Roof stripes repeat the native interior sample without projecting top-down
corner/background pixels over the raised slopes. Lilycove's native rear walking
row remains clear; Slateport retains its distinct blocked rear footprint.

Production orbit and eye/door captures inspected in
`results/emerald-harbors-review`, isolated Emerald0.3.52 profile. Harbor and all
previous focused model suites pass. Native footprint census: 76 recognized
assemblies, zero low-face overlap flags. This is scoped evidence for recognized
assemblies, not proof of complete regional scenery coverage. Next source targets
include Lilycove museum/department store and Slateport specialist buildings.

## Verified batch: Lilycove gold residence

The exact 6×5 drawing at (36,20) now has two raised gold roof tiers, native
repeating seam/highlight strips, pale ridge caps and the silver dormer fascia.
Closed risers support the upper tier; both tiers have closed undersides/end
caps. Native recessed door/windows and gold corner posts continue around the
shell. Low geometry remains south of the native rear walking row.

`results/emerald-tiered-home-review`: production orbit and eye captures
inspected. First prototype had an unsupported upper tier; its riser was closed
before final capture. Tiered-home/Civic/Hoenn tests pass. Emerald footprint
census now recognizes 77 assemblies with zero low walking-cell overlap flags.


## Verified batch: Cinnabar laboratory (LeafGreen)

Complete 7×5 native laboratory/sign drawing now becomes a closed rounded shell,
solid pale longitudinal ribs/crossbars, original red roof panel and doorway,
curved side glass and a raised beveled sign. Native shoreline cells are preserved
individually; only the sign's projected foreground pixels become turf. Solid
body/supports remain on blocked rows, clear of both native walking rows.

`results/leafgreen-frlg-specialist-source` contains the native map/grid;
`results/leafgreen-cinnabar-lab-review` contains inspected production orbit and
eye/door views. The QA enumerator needed the production edition alias binding
after map loading: native LeafGreen pair `082d4b4c` resolves to recipe `082d4b6c`.
Early flat/no-placement captures were fixture/recipe alias mismatches and are
not validation evidence. Rounded glass was split along shell segments to avoid
being buried in the wall; sign silhouette/underside and base-band depth were
corrected from renders. Focused laboratory/Civic/Hoenn/recent-model tests pass.
LeafGreen native footprint census: 104 recognized assemblies, zero low walking
cell overlap flags. FireRed runtime verification remains pending.

Ruby/Sapphire are separate coverage work: parity's new Ruby fixture uses RU_
map IDs (Sapphire SA_), and source differences still need inspection. Emerald
pattern coverage is not evidence for those games.

## Verified batch: Cinnabar mansion (LeafGreen)

The complete 7×4 mansion now has a closed steep roof with three solid gabled
dormers, two source-windowed storeys, rear/side windows and cornices. The central
entrance recess and checkerboard canopy stay within the blocked source cells;
the native walkable stair drawing below the building remains untouched. The
canopy's source checkerboard is drawn horizontally and its former facade patch
is repaired with original wall color. Door animation uses the authored recess.

Native source in `leafgreen-frlg-specialist-source`, inspected production orbit
and eye/door captures in `leafgreen-cinnabar-mansion-review`. Mansion/Civic
focused suites pass. LeafGreen native footprint census: 105 recognized
assemblies, zero low walking-cell overlap flags. This is still only a scoped
exterior addition; full regional building/furniture coverage remains unfinished.


## Five-game checkpoint: independently reviewed Ruby/Sapphire dispatch

Ruby/Sapphire previously missed Hoenn dispatch and fell through to Kanto tile
interpretation. They now use a separate reviewed-family catalogue: the complete
Oldale house, mart and Center drawings, plus checked general trees/signs/flowers.
All source cells, including facades, must match. Identical Emerald IDs alone do
not enable buildings, interior furniture or specialized terrain in these games.
The RS house uses its native corrugated roof, not Emerald roof pixels. Birch's
rectangular RS apparatus differs from Emerald's round apparatus and remains
unmodeled pending a separate batch.

Native source captures in `{ruby,sapphire,emerald}-rse-model-source` were compared
separately. Ruby/Sapphire production captures in `{ruby,sapphire}-rse-model-review`
include four Oldale placements, four orbit directions each, eye and door views.
Inspected shells close at the sides/rear and preserve the native rear walking
row. The separate native footprint audits recognize four assemblies per game,
with zero low-face walking-cell overlap flags. These are bounded geometric
checks, not evidence of complete world coverage or normal keyboard traversal.
RS dispatch, Hoenn, Civic and three furniture regression suites pass.

| Game | Current evidence in this workstream | Still unverified/unmodeled |
| --- | --- | --- |
| Emerald | Specialist batches above; 77 recognized assemblies, zero overlap flags | Remaining regional exteriors/interiors and exhaustive first-person coverage |
| LeafGreen | Cinnabar lab/mansion and previous catalogue; 105 recognized assemblies, zero overlap flags | Remaining specialist buildings/interiors and exhaustive coverage |
| FireRed | Fresh isolated import; Cinnabar native source is byte-identical to inspected LeafGreen source; front/eye/side production renders inspected; 105 recognized assemblies, zero overlap flags | Other models need per-game visual checks; lab rear orbit is occluded by neighboring mansion |
| Ruby | Oldale three families/four placements and reviewed general scenery; four assemblies, zero overlap flags | Petalburg/Littleroot, all remaining regions and interiors |
| Sapphire | Independently captured Oldale three families/four placements and reviewed general scenery; four assemblies, zero overlap flags | Petalburg/Littleroot, all remaining regions and interiors |

FireRed evidence: `firered-frlg-specialist-source`, `firered-cinnabar-lab-review`,
`firered-cinnabar-mansion-review`, `firered-building-footprints-after`. Its old QA
cache entered the launcher; the user's supplied ROM was imported with engine
0.3.52 into fresh `emerald-port-firered-models-qa`, without copying player saves.
All paths above are beneath the existing scratch results directory. Test
processes exited. No imported assets, captures, saves or ROMs are committed.
Next batch: independently review Petalburg source families in Ruby/Sapphire.


## Verified batch: Ruby/Sapphire Petalburg

Five additional complete source patterns enable six buildings in each game:
wide home, two small homes, gym, Center and mart. Independently captured native
Petalburg maps are pixel-identical between Ruby and Sapphire; Emerald roofs
are visibly different. The reused closed shells sample each running game's
own art, including RS red corrugated house roofs. Gym entrance projection,
side glass, home rear windows and native front approach remain intact.

Production `{ruby,sapphire}-rse-petalburg-review` captures contain 24 orbit views
per game plus eye/door views. Front, side, rear and eye views across the families
were inspected; trees partly occlude the gym rear. Full-pattern and walking-row
regressions pass, as do Hoenn/Civic suites. Updated independent native census:
Ruby10/0 and Sapphire10/0 recognized assemblies/low walking overlap flags.
The table above records the preceding checkpoint; current RS scope is Oldale
plus Petalburg (eight source families). Hedges, remaining terrain, Littleroot
and interior furniture remain pending. No collision/warp/save edits.


## Verified batch: Ruby/Sapphire Birch laboratory

The exact 7×5 lab at Littleroot (3,12) now uses the native RS rectangular roof
extractor: closed stepped plinth/casing/cap and recessed solid grille. Emerald
retains its independently authored circular drum. Repeated RS roof seams are
restored beneath the removed projected apparatus; the initial render revealed
a plain donor patch, corrected before final captures. The shell keeps the
native rear walking row clear and uses native recessed door/window art.

Ruby/Sapphire Littleroot native source captures match independently. Final
`{ruby,sapphire}-rse-birch-review` orbit and eye views inspected; roof patch and
side/rear closure verified. RS/Hoenn/Civic tests pass. Independent native census
now11/0 per edition (nine enabled source families). Moving trucks remain native
sprites; Littleroot's two homes still await source-faithful tiered roof geometry.
No full-world or complete furniture claim. Processes exited; saves unchanged.


## Priority correction: excessive rear roof projection

User-reported roofs extending too far behind buildings were reproduced in rear
and side renders. Civic moved the rear wall forward over native projected roof
rows to preserve walking cells, but left the roof at the original source edge.
Roof geometry now starts within two pixels of the actual rear wall, with the
existing 1.5px eave lip. Native source coordinates remain separate: the complete
roof artwork still maps across the shortened roof, including closed underside,
bevels, gable/barrel ends and shifted rooftop equipment bases.

Custom Rustboro urban slabs/parapets, Lilycove gold upper tier and Contest Hall,
and Cinnabar's rounded laboratory/ribs receive the same bounded rear treatment.
Space Center/Devon already aligned roofs and walls and were not changed.
Pending Littleroot home activation is excluded from this correction.

Inspected production side/rear renders: Ruby Oldale house; Emerald Oldale Center,
Rustboro tan residence, Lilycove gold home/Contest Hall; LeafGreen Viridian house
and Center; FireRed/LeafGreen Cinnabar lab. Evidence in `ruby-rear-roof-review`,
`emerald-rear-roof-review`, `leafgreen-frlg-rear-roof-review`, and the refreshed
Cinnabar lab review directories. Final FireRed capsule render incorporates the
one-pixel front-bound correction found by its geometry test. Nine focused suites
pass, including new rear eave/UV/closed-underside regression. Native footprint
census remains Emerald77/0, Ruby11/0, FireRed105/0. This verifies representative
families and shared geometry, not every map/camera. Native walls, collisions,
warps and player saves remain unchanged.


## Verified batch: Ruby/Sapphire Littleroot homes

Player/rival houses now have two closed shingled roof tiers, a structural riser,
raised native pale fascia and solid ridge caps. Native door/window arrangement
is preserved for each opposite layout. The rejected first prototype extended
its upper tier behind the moved rear wall; the final version ends at the same
bounded rear eave as the lower tier. A regression checks the tier's rear extent.

Final `{ruby,sapphire}-rse-littleroot-homes-review` orbit and eye captures were
inspected independently. RS/Hoenn/Civic suites pass; native census13/0 per
edition, eleven enabled source families. Emerald's Littleroot roofs still use
the previous geometry and require their own adoption/render batch. RS interiors,
most remaining exteriors and special scenery remain unfinished.


## Verified follow-up: Emerald Littleroot tiers

Emerald's player/rival roofs now use the same source-layout-compatible closed
tier geometry, sampling Emerald's own orange shingles and gold caps. Its source
was separately inspected before adoption. `emerald-rse-littleroot-homes-review`
front/side/eye renders inspected; focused Hoenn/RS tests pass. Native census
remains77/0. This supersedes the preceding note about Emerald's old gable.


## Verified batch: Ruby/Sapphire Center ground-floor fixtures

Fifteen complete source families now enable nineteen Oldale Center fixtures
per edition: healer, monitor, counter/returns, PCs, wall map, medicine cabinet,
glass table, shallow cushion pads, plant and two wall segments. Independently
captured RS/Emerald Oldale Center native images are pixel-identical. This does
not enable unreviewed upper-floor furniture or escalator animation families.

The footprint audit found the existing plant volume occupied its native
walkable projected apron; it now sits sixteen pixels farther back on the
blocked cell with a bounded north-wall recess so it remains visible. Hoenn
cushions now use at most1.21px floor relief instead of2.52px. Both corrections
also apply to Emerald's identical source. Production `{ruby,sapphire,emerald}`
`-rse-center-interior-review` orbit and eye renders inspected; six focused suites
pass, including plant-apron/pad-height regressions. Dummy-UV face footprint check
reports RS19fixtures/0flags. Emerald20fixtures/2flags are both its unchanged
escalator lower cells (0,7)/(1,7), requiring a separate stair traversal/geometry
audit. This test is scoped to authored fixtures and does not certify every room.
All runs used isolated fresh fixtures and exited; collisions/warps/saves unchanged.


## Verified follow-up: Hoenn escalator approach clearance

The two Emerald audit flags came from the flight/rail depth extending into the
native walkable lower drawing row. Hoenn flight depth is now confined to its
middle blocked/warp row; the lower projected apron becomes floor. All native
source samples and collision/warp metadata remain unchanged. The three upward
animation patterns are now enabled in RS after separately inspecting both
editions' composited frame strips (`escalator-frames.png`). Downward RS patterns
remain disabled pending upper-floor source/runtime review.

Final RS/Emerald orbit renders inspected in the same Center review directories;
the authored face audit now reports20fixtures/0flags in each game. Frame-family
and center suites pass, including an explicit flight-depth boundary regression.
This supersedes the prior Emerald20/2 result. Normal input/warp traversal was
not exercised by these controlled visual fixtures; gameplay implementations are
unchanged. All three engines exited and player saves remain untouched.


## Verified batch: Ruby/Sapphire upper Center link booths

Separate native upper-floor captures show three private service booths rather
than Emerald's continuous counter. Four RS-only complete patterns now provide
closed orange partitions with white caps, individual desks/gates, full native
service symbols and recessed portal art. Low geometry leaves the clerk and
portal approach lanes open; partition/lintel undersides are closed. Emerald
receives none of these edition-specific recipes.

Production Ruby and Sapphire Dewford Center 2F front, rear, side and eye renders
inspected in `{ruby,sapphire}-rse-upper-center-review`, with independent native
references in `-rse-upper-center-source`. Both scoped authored-face audits report
15 fixtures / 0 explicit-floor flags. Six focused Lua suites pass, including
RS edition isolation, lane bounds and closed undersides. Normal input/warp
traversal was not exercised. Upper-floor PC, additional plants and downward
escalator patterns remain native pending separate source/model review. Engines
exited; isolated QA fixtures only, player saves and gameplay unchanged.


## Verified follow-up: Ruby/Sapphire downward escalators

Separately exported all three downward native animation patterns in both games
(`rse-upper-center-review/escalator-frames.png`) before enabling these families.
Production orbit/side and dedicated `stairs-eye.png` captures inspected in both
editions: native dark rails, orange trim, pale enclosure and recessed flight
remain within the bounded middle row. Upper-room scoped face audit now16/0
per edition. RS/Hoenn/Center focused suites pass. This enables the existing
geometry only; input and warp traversal remain untested. Remaining upper PC
and link plants are still native, with all wider coverage gaps unchanged.


## Verified follow-up: Ruby/Sapphire upper PC and link plants

The upper PC has its own complete RS three-cell pattern; its bottom source cell
is different from the downstairs PC. It reuses the source-sampled closed CRT,
keyboard and pedestal model after checking both native room images. Two link
plants use the matching two-cell source family with their pots on blocked cells.
Production front/rear/side and dedicated PC eye captures inspected for both
games in the same upper-room review directories. Scoped face audit now19/0;
RS, Center and starting-furniture suites pass, including PC projected-apron
bounds and incomplete-pattern rejection. No gameplay or saved progress changed.
This completes these selected room fixtures, not all Center variants or Gen3
interiors; remaining regional coverage and normal warp traversal are open.


## Verified batch: Ruby/Sapphire Mart display cases

Separate RS/E Oldale Mart native captures confirm matching shelf/cooler artwork
and footprints. Five reviewed families enable five RS assemblies: two stock
cabinets, three-door glass case, central double shelf and side shelf. Production
RS front/rear/side/eye captures inspected in `-rse-mart-review`; both scoped
face audits report5/0. RS/Hoenn/designed-interior suites pass. The general
designed-object test now selects Ruby for RS-only fixtures, retaining full
385-object checks. Source fixtures are in `-rse-mart-source`.

Checkout and register have differing RS metatile patterns and remain native
pending a separate model. Mart plant likewise awaits a projected-apron fix
(the existing Emerald recipe needs review); this batch does not enable it.
No collision, interaction, warp or player-save changes.


## Verified follow-up: Hoenn Mart plant apron

Moved the source-projected plant volume back16px into its blocked wall niche,
using the existing bounded recess hook. RS family enabled after separate source
inspection. RS/Emerald production views inspected; focused tests include all
three games' plant-apron bounds. RS Mart audits6/0 each. Emerald7/2 exposes an
existing checkout slab across clerk-aisle cells(0,3)/(1,3); this is the next
priority fix, not a plant regression. Native gameplay/saves unchanged.


## Verified fix/batch: native Hoenn L-shaped checkout

Emerald's old generic slab occupied two native clerk-aisle cells. The new closed
L-shaped counter follows the front blocked row and right-hand service column,
retains native glass/panel art and leaves the rear-left aisle empty. Ruby and
Sapphire receive their distinct complete two-row pattern, preserving their
different front-panel art. Production front/rear/side and checkout eye captures
inspected in all three games. Each Mart scoped audit now7/0, superseding EM7/2.
Four focused suites pass; a geometry regression checks both aisle cells.
Register and additional wall details remain native; interaction/warp traversal
was not exercised. Presentation only; no gameplay/saved progress modified.


## Verified batch: Hoenn Mart register

Complete two-cell register source checked separately in RS/Emerald; the projected
wallpaper rows are excluded from machine surfaces. Closed pedestal and sloped
till retain native keypad, display and drawer pixels, readable at eye level.
RS/E front/rear/side/checkout eye renders inspected in the existing Mart review
directories. Scoped audits8/0 in each game; Hoenn/RS/additional-furniture suites
pass, including three-edition complete matching and service-cell bounds.
Small wall decorations and broader regional variants remain unreviewed. No
collision, interaction or save changes; normal service interactions untested.


## Verified batch: Ruby/Sapphire Birch lab core furniture

Eight separate native-source-compatible families enable bookcases, computer,
research desk, starter cupboards, server and plant. RS/E native sources captured
independently in `-rse-birch-source`; RS front/rear/side/eye production renders
inspected in `-rse-birch-review`. Scoped RS audits8/0 each, RS/designed suites
pass. Source-only aliasing remains gated for other room equipment.

The matching Emerald comparison exposes9/2: the existing circular machine
extends into walking apron cells(10,8)/(11,8). Its RS recipe remains disabled
until a dedicated geometry correction. South workstations and side equipment
are also still native. Initial review drivers retained an unrelated escalator
strip assertion; removed that QA-only block and reran successfully before
recording final audits. Player saves/gameplay unchanged.


## Verified fix/batch: Birch circular machine apron

Birch's machine moves back16px onto its native blocked footprint, retaining the
original circular platen, drum, panel and feet. Drum and foot/panel undersides
are now closed. RS family enabled only after separate source review. All three
games' front/rear/side and dedicated `machine-eye.png` production views inspected;
scoped lab audits now9/0 each, superseding EM9/2. RS/Hoenn/additional suites pass,
including apron bounds and drum underside regression. FRLG machine position is
unchanged; shared underside closure applies there but was not freshly rendered.
South workstations and additional lab equipment remain unreviewed.


## Verified batch: Birch narrow south workstation

The complete three-cell narrow workstation now has a supported native yellow
desk, closed terminal facing the adjacent seat, and raised desktop device.
Native art sampled separately; the adjacent green seat stays native walking
floor. RS/E orbit and dedicated workstation-eye views inspected; scoped lab
audits10/0 each. RS/Hoenn/additional suites pass with chair/apron bounds.
Neighboring book stacks and other side/south workstation variants remain native.
No gameplay or save changes.


## Verified batch: Birch south book stacks

Two complete native book-stack cells now form closed layered red, dark and blue
books with inset page blocks and source cover details. The source crop excludes
the projected floor and lower books from each top cover. RS/E dedicated low-eye
and orbit views inspected; scoped lab audits11/0 each. Hoenn/RS suites pass,
including exact stack/adjacent-chair bounds. Other workstation variants and
side equipment remain unfinished; no gameplay or save changes.


## Verified batch: Birch southeast workstation and side cupboard

Separate native mirrored workstation pattern faces its adjacent chair; source
terminal and desktop art remain distinct from the southwest model. The adjoining
gold cupboard uses only its blocked lower cell, leaving its projected upper
walking cell open. RS/E orbit and southeast-eye views inspected; scoped lab
audits13/0 each. Hoenn/RS/designed suites pass, including cupboard projection
regression and full source precedence. Remaining wall shelves, plants and
other furnishings are still native; no interaction or full-coverage claim.


## Verified batch: Birch floor plants and east book stacks

Native one-cell plants occupy their blocked cells; the east book-stack family
uses its separate three-cell drawing with an8px source/geometry offset. Closed
cover/page models reuse only the separately checked matching book art. RS/E
orbit and dedicated east-stack eye views inspected; scoped audits RS16/0 each,
Emerald15/0 (different northeast book arrangement; plant placements match). Hoenn/RS suites pass. Native
RS wallside small table, Emerald northeast books and walkable green seat drawings remain pending.


## Verified batch/correction: RS east small lab table

Ruby/Sapphire's complete table pattern now forms a closed supported desk and
raised device entirely on the upper blocked cell. Its lower source projection
stays floor. RS close-eye/orbit views inspected; scoped audits17/0 each.
Emerald15/0 remains unchanged: its northeast source arrangement uses29a/232
book cells, with no matching table. This corrects the prior explanation of
the count difference as plant placement; plant locations match. Both east
stack/table recipes are now explicitly RS-only and tested against Emerald
dispatch. Emerald northeast book stacks remain native for separate modeling.
Focused RS/Hoenn/additional suites pass; no gameplay/save changes.


## Verified batch: Emerald northeast individual book stacks

Emerald's29a/232 source cells now form three separate closed stacks in their
actual native arrangement. These family names remain gated out of RS. Native
source crop and Emerald front/rear/side/close-eye render inspected; scoped lab
audit18/0. RS/Hoenn suites pass including single-cell stack bounds; RS remains
17/0 at its previous rendered checkpoint. Walkable green seats remain native,
and this room check does not certify full Gen3 interiors or gameplay traversal.


## Verified batch: FireRed/LeafGreen Pewter Museum exterior

Complete16x7 native pattern now produces the closed main hall, pitched striped
roof, lower east wing and projecting fossil entrance. Native cream piers,
windows, door panels and roof details are preserved; side/rear elevations
continue the authored window/pier vocabulary. Closed roof trim and undersides
remain bounded. Distinct main/wing entrance planes align their native surfaces.

An opt-in claim mask consumes only89 building cells after validating the whole
source pattern. It leaves surrounding trees, shrubs, fences and entrance steps
available to native scenery rendering. The east wing's walkable projected roof
row stays clear of low walls; eaves stay near the actual rear wall.

FireRed and LeafGreen source exports were separately obtained and their Pewter
native PNGs compare byte-identical. Production front/right/rear/left, main/wing
eye views and door-state captures inspected in `{firered,leafgreen}`
`-pewter-museum-review`. Wing animated open/closed panels visibly align; main
entrance uses its native open arch. Native-map geometry audits in
`-pewter-museum-footprint` report1 assembly/0 explicit-floor flags per game.
Six focused suites pass, including complete-match rejection,89-cell claim mask,
scenery preservation, bounds and both door planes. Controlled fixture review
does not prove normal input/warp traversal. Player saves unchanged; all QA
processes exited. This adds one specialist exterior, not complete FRLG coverage.

## Verified batch: FireRed/LeafGreen Silph Co.

Complete 9×15 native drawing at `FR_SAFFRON_CITY (29,16)` becomes a closed
blue-glazed office tower, lavender ribbed roof deck and curved central
rooflight with capped ends and closed transverse ribs. Glazing/storey bands
continue around both sides and rear. Recessed animated doorway and native
entrance sign remain aligned; the native first walking row stays clear.

Independent FireRed/LeafGreen source PNGs in `{firered,leafgreen}-frlg-specialist-source`
match byte-for-byte. Engine 0.3.52 production captures in
`/home/admin/Projects/.scratch/coverage-20261004/results/{firered,leafgreen}-silph-review`
were inspected from front, rear, both sides and entrance eye height, including
native door states. Isolated `emerald-port-firered-models-qa` and
`emerald-port-leafgreen-qa` fixtures; controlled camera/daytime/view distance.
Native Rocket guard remains present at the entrance in this new-game fixture.

Scoped `silph-footprint` audits: one recognized building, zero low-face
intersections with central 8×8 collision-0 cells in each edition. The initial
LeafGreen audit lacked the normal tileset alias bind and found no model;
corrected fixture binds public map aliases before preparing models. This is
not a normal movement/warp test or an exhaustive collision guarantee.
Tests: `gen3_silph_test`, `gen3_civic_test`, `gen3_rear_roof_test`,
`gen3_pewter_museum_test`, `gen3_scene_cache_test` pass. No saves/gameplay data
changed. Remaining Saffron facade families visibly remain flat and require
separate source review; no full-city or full-game completion claim.
