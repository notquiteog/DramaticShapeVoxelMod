# Ruby/Sapphire Birch laboratory — 2026-10-09 (unreleased)

Closed rectangular roof apparatus now distinguishes the RS lab from Emerald's
round drum. Native corrugation continues beneath the removed source projection.
Independent RS orbit/eye renders inspected and focused suites pass; census11/0
per edition. Littleroot homes/tiered roofs remain pending. Detailed evidence in
Gen3 model coverage ledger; no gameplay data or saves changed.

# Ruby/Sapphire Petalburg model batch — 2026-10-09 (unreleased)

Five source-reviewed families add six Petalburg buildings per edition. Native
Ruby/Sapphire source maps match; Emerald roof art differs and is not copied.
Production orbit/eye captures inspected, targeted suites pass. Native census
now10/0 per edition. All five games remain partial; coverage ledger records
scope and limitations. Next: Littleroot's distinct RS laboratory apparatus.

# Five-game Gen3 model checkpoint — 2026-10-09 (unreleased)

Ruby/Sapphire now use a separate source-reviewed catalogue instead of falling
through to Kanto shapes. Only Oldale house/mart/Center and reviewed general
scenery are enabled; unmatched Emerald exteriors/interiors remain native.
Separate RU_/SA_ source and production orbit/eye captures inspected; each
native footprint census recognizes four assemblies with zero overlap flags.
Fresh isolated FireRed import verifies Cinnabar native source parity and
front/eye/side models; census105/0. Lab rear orbit is obscured by the mansion.
Full per-game evidence and remaining work are in
`docs/GEN3_MODEL_COVERAGE_2026-10-09.md`. Six focused suites pass. All five games
remain unfinished; next source batch is Ruby/Sapphire Petalburg. No saves,
collisions, warps, assets, versions or releases changed.

# Partner compatibility and region extension — 2026-10-09

Parent added Gen3 optional scenery.registerTilesetAlias(pair,target), with owner
protection, explicit disposal and scene cache invalidation. New custom-region
scenery guide documents native fallback, lifecycle and identical-art-only scope.
Alias/session/disposal regression passed; full suite183/0/56. This API batch
has no live custom-region render fixture yet. Source audit and partner unit
checks in docs/UPSTREAM_COMPATIBILITY_2026-10-04.md; no exhaustive parity claim.
Upstream abs/Wilds/Skies contain no missing commits. Kanto Git fetch failed;
do not label cached reference current. Seven manifests remain independent.

Three agents active: generation_parity (capture effects), crystal_models
(department-store windows/interior coverage), gen3_models (Mossdeep Space Center).
Modern UI completed Gen1/2 roster commitff9945c, later screens still pending.
Agents should continue model coverage batches autonomously and coordinate shared
files. Parent owns Tilesets/Integration API changes only in this batch.

# Mossdeep cliff-composite trees — 2026-10-09 (unreleased)

Complete north-edge and corner composite trees now join the two standalone
Mossdeep trees in the original-art tree pipeline. Full 3x3 patterns and blocked
root required. North band retains native floor elevation, stone cap and stone
retaining material; it does not add an artificial 24px column. Walkable corner
cells remain flat under the canopy. No collision/warp changes. All four large
Mossdeep trees now have matching recipes; this does not cover other tree types.
Gen3 tree retaining faces now use their underlay instead of stretching tree
art vertically. Parent owns these Gen3Hoenn/Scene/test edits.

Engine0.3.52 source-map inspection plus production turntables and eye views:
.scratch/coverage-20261004/results/emerald-mossdeep-cliff-tree and
emerald-mossdeep-corner-tree. Inspected front/rear north band and corner front;
first prototype introduced artificial rock columns and was corrected before
commit. Source scenery still has unrelated flat buildings/foliage requiring
further coverage. Tests: .scratch/mossdeep-cliff-20261009-tests.log.

Generation-parity and Modern UI agents restarted at user's explicit request.

# Mossdeep standalone trees — 2026-10-09 (unreleased)

Two complete native 3x3 Mossdeep trees now use the shared original-art tree
pipeline instead of flat ground drawings. Exact full pattern and blocked root
required; trunk centered on that blocked cell, low trunk bounded within it.
Native lawn palette excluded from tree samples after rendered QA revealed blue
lawn patches on the crown. Model/billboard preference remains supported.
Cliff-composite variants deliberately remain pending: consuming those as plain
trees would remove terrain. No gameplay collision or warps changed.

Engine0.3.52 private Emerald QA: native source map inspected; four directional
and eye-height production renders at (48,19) in
.scratch/coverage-20261004/results/emerald-mossdeep-tree-review. Camera fixture
corrected to account for raised terrain before final inspection. Regression
covers full/partial matching, cliff exclusion, blocked anchor and low trunk
bounds. Suite log: .scratch/mossdeep-trees-20261009-tests.log.
Full tile coverage is NOT complete. Other flat tree families and cliff-composite
Mossdeep drawings remain visible in captures and require further work.

Release follow-up: Yellow1.12.4 CI succeeded; published Lua bundle recursively
matches locally packed content, SHA256 verified, auxiliary checksum refreshed.

# Gen3 building footprints — 2026-10-05 (unreleased)

Recognized Civic models now use native collision rows to keep rear walls out
of walking lanes while preserving source roof overhangs. Kanto gym wings end
at z64, leaving the native front strip clear; entrance remains projected.
Five short FRLG house families use 24px walls/doors for headroom. Explicit
Verdanturf/Steven home rear bounds remain recorded in recipes. No native
collision, warps, movement or save changes.

Raised Civic foundations sample ground instead of source roof/window pixels.
New donors outside previously reviewed service assemblies must be classified
reviewed surfaces or native grass1; unknown flat decorations are excluded.
Foundation material refinement and remaining flat foliage are still needed.

Engine0.3.52: full suite 182 passed /0 failed /56 skipped. New runtime
building-footprint-census.lua flags face bounding boxes overlapping central
8x8 walkable cells at y1.5..16: Emerald57 recognized assemblies /0 flagged,
LeafGreen103 /0 flagged (before:4 and69). This is a bounded geometry audit,
NOT exhaustive coverage or a proof of collision safety. FireRed QA profile
failed to boot this pass; shared FRLG code is covered through LeafGreen.
Artifacts: .scratch/coverage-20261004/results/*-building-footprints-after.
Latest Emerald building-doors completed14 placements/56 directional captures
plus eye/door views across Verdanturf and Mossdeep; inspected rear houses and
Mossdeep gym retaining faces. Prior LeafGreen Pewter gym/Three Island rear/
Route2 eye captures inspected. Camera is QA-controlled production rendering.
Player saves untouched. Full-world models/parity remain incomplete.

# Square Hoenn gym canopies — 2026-10-05 (unreleased)

User corrected the canopy: native angled outlines indicate projected artwork,
not a trapezoidal world-space roof. Six shared Hoenn gym recipes now have
parallel canopy sides, square corners and closed undersides over the narrower
vestibules. Native doors, footprints and walking lanes unchanged. Focused
Civic/Hoenn tests protect rectangle, soffit, native door and footprint bounds.
Production Petalburg turntable/eye-height fixture uses engine0.3.52 in
.scratch/coverage-20261004/results/emerald-building-doors.

# Hoenn service buildings and gym entrance polish — 2026-10-05 (unreleased)

Emerald's standard Centers now use a closed chamfered shell, native recessed
sliding doors, original sign, lower roof shoulders and a distinct raised middle
hump. The emblem is attached to the fascia, not a standing sign. Marts use their
own broad blue plateau roof with rolled edges. Native-map pattern audits found
16 standard Centers and 12 standard Marts, including both Battle Frontier
buildings; all now have matching recipes. This count excludes special buildings
such as department stores. Roof materials exclude regional dirt/ash corner art.
Under-building ground selects nearby walkable native floor rather than grass.

Petalburg/Dewford/Lavaridge house families gained authored recessed windows and
doors, bounded timber relief, and corrected native siding/trim samples. Six
standard Emerald gym entrances now reinterpret the source's diagonal white
strips as solid angled vestibule walls. Closed shallow beveled canopies use
unprojected native gold roof art. Native door surfaces remain aligned; tests
protect front/rear walking strips and door source dimensions. No collisions,
warps, movement or saves changed.

Validation: official engine0.3.52, disposable Emerald profile, native building
composites inspected; production turntables/eye-height and native animated door
sequences in .scratch/coverage-20261004/results/emerald-{building-doors,
emerald-centers,emerald-services}. Centers and Marts source audit drivers live
alongside those captures. Focused Civic/Hoenn tests pass; full suite179 passed,
0 failed,56 skipped (.scratch/hoenn-services-gym-20261005-tests.log). This is
scoped building work, not complete world coverage or a new published release.

# Route 1 composite fence/tree edges — 2026-10-05 (unreleased)

Reproduced the user's screenshot at the southern Route 1 gate above Pallet.
Pallet-secondary metatiles 2AA/2AB/2B2/2BA combine thin fences with partial
canopies; they fell through to flat rendering. Scoped recipes now replace all
four with matching General metal fence models, aligned to EC/ED corner axes.
Adjacent tree roots retain ownership of the complete trees; composite foliage
is no longer painted on the ground. Models stay inside their blocked cells;
no native collision, grass encounter, warp or walking-path edits.

Official engine 0.3.52, isolated LeafGreen QA profile, native atlas inspected,
production overhead and eye-height Route 1 gate captures reviewed. Shared
FRLG Pallet tileset fix applies to both games; this run was LeafGreen.
Evidence: .scratch/coverage-20261004/frlg-route-edge.lua and results/
leafgreen-frlg-route-edge/garden{1,2}.png; source frlg-composite-atlas.
Viridian garden checked too: ordinary side fences already modeled correctly.
Regression tests cover corner alignment, full rail span, cell bounds, absence
of flat composite foliage and secondary/interior scoping. Full suite:
175 passed, 0 failed, 56 skipped (.scratch/frlg-gate-20261005-tests.log).
This resolves the identified gate, not an exhaustive world visual audit.

# Hoenn gym entrances and native walking lanes — 2026-10-05 (unreleased)

Petalburg, Rustboro, Dewford, Mauville, Lavaridge and Mossdeep gym drawings now
use a flat main roof, separate low entrance canopy, angled projecting vestibule,
three recessed native windows and aligned native animated doorway. Side walls
stop before the native walkable last-row strips. Five gyms have walkable rear
roof-art rows: their body and rear window trim now sit inside blocked cells,
while the roof remains an overhead overhang. Petalburg retains its blocked rear.
Lavaridge's overlapped sign is a separate closed sign/post within its blocked
cell; the hidden wall uses the native unoccluded metatiles from the same atlas.
Native collisions/warps unchanged. Side/rear windows use authored pane art,
size and height rather than accidentally sampling the wall below the pane.

Native source drawings/collision rows inspected for all six; engine0.3.52
production front/side/back/eye-height and native door sequences captured in
.scratch/coverage-20261004/results/emerald-building-doors. Source composites in
emerald-hoenn-gym-source and .scratch/hoenn-gyms-native.png. Lavaridge sign crop
corrected after rendered review; final Lavaridge/Rustboro rerun verified.
Bounds regressions protect front/rear walking lanes and sign cell. Full suite
174 passed / 0 failed / 56 skipped (.scratch/hoenn-gyms-20261005-final-tests.log).
Shared suite includes concurrent parity work; no full-world completion claim.
Next active report: partial flat tree edges and disconnected fence variants in
user screenshot; location clarification pending, checking FRLG outdoor variants.

# Gen3 building silhouettes, source materials and native doors — 2026-10-05 (unreleased)

Reworked the shared civic building renderer: closed roof soffits and independent
opaque roof materials; removed facade/grass pixels from roof corners and empty
rear rows; corrected FRLG Center roof/window boundary. Centers and Marts now
have chamfered front corners. Authored doors/windows use native-art recesses,
without added grey frames/sills. Center eaves use their roof palette. Hoenn
Centers retain the rounded raised roof but slope down to a straight front eave
instead of adding a tall solid arched front. Native emblem UV spacing follows
the front slope length to avoid stretching the logo.

Gen3 native opening/closing door frames now project into each known authored
aperture, sharing its height, source crop, inset and terrain base. Frame timing,
sound, warp logic and collision remain engine-owned. Unrecognized door recipes
retain the earlier fallback and still need explicit review.

Updated QA to official Gen1Recomp 0.3.52 (release SHA256 verified) and re-imported
supplied LeafGreen/Emerald ROMs into isolated profiles for its new cache formats.
No production save changes. Runtime: .scratch/runtime-0.3.52/engine. Coverage
run.sh now uses it. Official source-tag test utilities supplement the packaged
payload; no engine production code changes.

Reviewed native art and production renders in Viridian, Littleroot and Oldale:
12 building placements, four elevations plus close eye-height views; native
opening/open/closing sequences on authored doors. Evidence:
.scratch/coverage-20261004/results/{leafgreen,emerald}-building-doors.
Full 0.3.52 suite: 173 passed, 0 failed, 56 skipped
(.scratch/civic-20261005-doors-tests.log). Regression coverage includes roof
opacity/material isolation, corner bounds, straight Hoenn front eave and door
projection. This is a reviewed subset, not an all-building/AAA quality claim.
Pallet's separate renderer, other regional variants and Gen1/Gen2 remain part
of the broader visual audit. Parity/UI agents continue independently.

# Mauville wall machines and bins — 2026-10-05 (unreleased)

Two native wall-machine drawings now use independent closed cabinets, upper
lightboxes, recessed framed displays and projecting coin trays. Cloud wallpaper
is excluded from cabinet faces. Both metal bins have separate faceted bodies,
raised rims and recessed openings. Front crop excludes surrounding carpet and
projected rim; source palette retained. Complete machine recipes require both
blocked rows; bins require blocked cells. Native collision remains unchanged.

Emerald v0.3.51 isolated QA_CASINO native/overview/first-person front/side checks,
including both machines and both bins, in .scratch/coverage-20261004/results/
emerald-casino-models. Fixed screen occlusion and bin carpet contamination before
final visual review. Focused pattern/UV/walkspace tests pass; full shared suite
172 passed/0 failed/56 skipped (.scratch/casino-models-tests.log). Full suite
includes parity agent's current tests; its work is not part of this commit.

Game Corner counter, palms, signs, walls and seating remain unfinished; no
all-world coverage or full feature parity claim. No release in this batch.

# Mauville paired slot cabinets — 2026-10-05 (unreleased)

Both complete 2x5 slot-bank patterns now build four back-to-back cabinet pairs
(16 machines total), with separate bases, projecting control shelves, upper
housings, face surrounds, closed ends and coin-return slots. Side-facing native
panel artwork is rotated onto the correct outward face. Source cap row remains
floor; all solid parts lie within four blocked rows. The native walkable chair
cells retain flat artwork pending a seating solution that preserves movement.

Verified Emerald v0.3.51 isolated QA_CASINO fixture: two banks and both roulette
tables asserted, whole-room collision unchanged. Inspected first-person angled
end/front views after revising the initial overly box-like profile. Screens and
native source are in .scratch/coverage-20261004/results/emerald-casino-models
and emerald-casino-source. Hoenn recipe, designed-object and footprint tests
pass (168 Hoenn patterns, 367 designed objects). Other room furniture, wall,
seating and all-world visual coverage remain unfinished. No new release.

# Mauville roulette tables — 2026-10-05 (unreleased)

Both native 2x3 roulette drawings now have four legs, a supporting apron,
closed tabletop, raised octagonal wheel and central spindle. Original felt,
number and wheel artwork retained; bottom carpet/shadow strip excluded.
Complete-pattern matching requires all six native blocked cells. Source and
runtime captures are in .scratch/coverage-20261004/results/emerald-casino-source
and emerald-casino-models. QA_CASINO=1 tools/qa/furniture-walkspace.lua checks
both assemblies, first-person front/side viewing cells and unchanged collision.
Inspected native source, overview and first-person side. Gold wheel sample
corrected after source pixel review. Hoenn patterns (167), designed objects
(366) and shared walkspace tests pass. Engine v0.3.51; isolated save profile.

Game Corner slot banks, seating, counter, palms, signs and remaining room
models are still unfinished. This is incremental coverage, not room/all-world
completion. Existing generation-parity and Modern UI agents work independently.

# Museum upper rear wall — 2026-10-05 (unreleased)

Added four complete native wall patterns (17 assemblies) for the upstairs
museum rear wall, stepped wings and corner joins. Closed backs/sides and
source colors fit blocked cells; no collision edits. QA_GALLERY native and
rendered overview inspected on Emerald v0.3.51; driver asserts all 17 matches.
162+4 Hoenn recipe patterns, designed-object and walking-space tests pass.
Still no claim of exhaustive world coverage or every-angle approval.

# Lilycove Poké Ball exhibit and wall returns — 2026-10-05 (unreleased)

The small exhibit is a separate volumetric Poké Ball on a low, flat plinth,
not a relief embedded in its base. Native green sculpture colors retained;
closed voxel sphere, equatorial seam and front button fit the single blocked
cell. Both five-row wall-return drawings now have closed sides/caps and native
front skirting. Exact collision-row recipes preserve the walkable projected
row of the partition return and all existing routes.

Verified Emerald v0.3.51 with QA_GALLERY=1 tools/qa/furniture-walkspace.lua;
.scratch/coverage-20261004/results/emerald-gallery-statues contains native,
overview, front/side ball and first-person wall-end captures, inspected after
final changes. Driver asserts both returns, small exhibit and unchanged native
collision. Shape tests check separate low base, rounded depth, narrowed top,
solid bounds and mismatch rejection. Full suite: 170 passed, 0 failed, 56
skipped (.scratch/museum-ball-tests.log). Earlier adapter failure is resolved
by parity agent's 0570903 fixture update. No user saves changed.

Earned painting overlays, remaining upstairs wall variants and exhaustive
other-map visual coverage are still unfinished. Modern UI and parity agents
continue independently; their uncommitted files excluded from this batch.

# Lilycove hollow counter and stone exhibit — 2026-10-05 (unreleased)

Complete native 6x5 counter and 5x4 stone-display recipes now use exact collision
rows, including solid counter value 0x90, walkable projected rows and the hollow
staff aisle. Geometry does not alter collision. Counter top source crops exclude
checker floor; native signs remain on top. Stone exhibit has a chamfered raised
plinth, stepped closed stone slab and original inscription. Its stepped face
bounds were corrected against individual native pixel rows after first-person
review showed background slivers. Rear/side faces stay closed.

Verified isolated Emerald v0.3.51 museum1F/2F via QA_GALLERY=1
 tools/qa/furniture-walkspace.lua. Captures/logs:
.scratch/coverage-20261004/results/emerald-gallery-statues. Inspected overview,
inside/side counter and front/back exhibit views. Driver asserts both complete
assemblies, views on native walking cells, and unchanged whole-room collision.
159 Hoenn recipe checks, 358 designed objects and walkspace tests pass.
Full shared-worktree suite: 169 pass, 1 fail, 56 skipped; gen3_adapter_test
failure referred to parity agent working on native Crystal pack dependencies.
Do not interpret suite failure as resolved until its fix and rerun are recorded.

Remaining room work includes short bust, wall returns/corners and earned art
variants. Exhaustive other-map visual coverage remains unfinished. Modern UI
and generation parity agents continue separately; no release claimed here.

# Lilycove museum sculptures, walls and flights — 2026-10-05 (unreleased)

Three tall sculptures now have cached closed voxel hulls from their native
opaque artwork and separate closed pedestals. Unlike the League statues,
these figures are on the opaque base layer: mask only border-connected native
background. Ground-floor statue uses reviewed checker floor palette; upstairs
uses each row's border background. Enclosed highlights stay. Figure depth is
8px; all solids stay inside blocked lower cells. Recipes require complete
native art and blocked bases. No native collision or warps altered.

Added eight complete picture-wall patterns retaining original paintings,
yellow wall and pink skirting on closed walls. Only blocked base rows carry
solids. Native cap samples are explicitly reviewed (small paintings fill most
of their tiles; arbitrary edge samples produced dark caps, fixed after render).
Added exact 3x2 native ascending/descending museum stair recipes using existing
north-facing Hoenn frame/flight geometry, floor-specific native materials.

Verification: v0.3.51 isolated Emerald profile, companions on. Native images
and cell grids: emerald-lilycove-source and emerald-gallery-statue-source in
.scratch/coverage-20261004/results. QA_GALLERY=1 tools/qa/furniture-walkspace.lua
via scratch gallery-statues driver asserts both upstairs sculptures, each
stair assembly and unchanged full room collision grids. Inspected both floors'
final overviews and upstairs first-person sculpture closeup. Final wall-cap
rerender inspected after source sampling fix. Tests: sculpture mask/bounds/
cache, all Hoenn recipes and family isolation, shared walkspace, stair assembly
and designed-interior crop checks pass. Full suite 168 passed/0 failed/56
external skips (.scratch/museum-tests.log); targeted tests rerun after final
cap sample and additional patterned-floor regression.

Still incomplete: downstairs counter, large display platform and short bust,
wall returns/corners, earned painting overlays and broad other-map coverage.
No manual warp traversal or all-angle/all-map artistic sign-off claimed.
Parity agent continues independently; its uncommitted changes are not part of
this museum commit. No captures/ROM pixels or user save changes committed.

# Native full-body backs and cave-audio adapter — 2026-10-05 (unreleased)

Gen3 FULL-BODY BATTLE BACKS uses existing Crystal/full_body normal/shiny assets
through NativeFullBody. Applies only to world-stage allied back cards with
owned non-ROM art; OFF, front view, MODDED, missing species/forms and unstaged
UI keep their existing provider. Pixel pitch uses Gen5 source resolution.
Gen1/2 installation unchanged; no extra actor draw layer introduced.

LeafGreen v0.3.51 isolated runtime: 267 provider draws / 24 animated frames;
live ON/OFF, distinct normal/shiny canvases, species386 fallback, unstaged
scope and one actor per side passed. Parent inspected full-body-on capture;
agent inspected ON/OFF. Results .scratch/coverage-20261004/results/
leafgreen-full-body-native/, reproducible tools/qa/gen3-full-body.lua.
Live singles verified; no new doubles/network gameplay QA (existing slot
identity tests pass). Full suite 166 passed, 0 failed, 56 external-fixture
skips (.scratch/gallery-final-tests.log).

NativeCaveAudio shares CAVE SOUND OFF/LOW/MID, loads optional packaged assets,
tracks 16px footsteps excluding map entry/teleports, uses SFX volume, fades on
leaving caves/battles/camera-off and releases on quit. Gen2 old atmosphere
sound mixer is disabled to avoid duplication. Unit audio mocks exercise actual
playback lifecycle; Crystal and LeafGreen runtime verify native routing,
classification and silent missing-asset behavior. Optional MP3s are NOT bundled;
audible runtime playback not claimed. Remains partial in OPTION_PARITY.tsv.
Repro tools/qa/native-cave-audio.lua; logs crystal-cave-audio-g2 and
leafgreen-cave-audio in the same scratch results tree.

Full parity incomplete: missing Gen2=16 / Gen3=40 plus partial/provider cases.
No cart release, native gameplay/UI ownership preserved, user saves untouched.

# Tall-grass blobs — companion fix 2026-10-05

Kanto Wilds commit a93a025d (pushed main) fixes the reproduced Gen3 hidden-land
encounter artifact: presentation.lua baked the underwater dark oval for every
hidden encounter. Land/cave hidden bodies are now transparent, water retains
its marker, and cache keys distinguish terrain. Encounter behavior untouched.
Parent inspected FireRed Route1 matched before/after overview; agent also
verified actual input walking and native fallback. Evidence:
.scratch/coverage-20261004/results/firered-grass-blobs{,-after,-walk}/.
Presentation regression and 53 settings assertions passed. This closes the
identified hidden-spawn blob, not every possible shadow defect. No cart release.

# Lilycove gallery native coverage — 2026-10-05 (unreleased)

Added complete four-by-four native drawing for Emerald Lilycove Museum 2F's
five gallery partitions. Solid cabinetry is bounded to the single blocked base
row (local y=2); projected cap and shadow rows retain checker floor. Closed
backs/sides use native green, cap uses native pale artwork, front retains the
native framed panel. Requires all four blocked base cells; incomplete patterns
or walkable bases are rejected. Gen3Hoenn family scope prevents FRLG ID aliases.

Source v0.3.51 isolated Emerald profile with companions. Native source capture
and collision grid: .scratch/coverage-20261004/results/emerald-lilycove-source/.
QA_GALLERY=1 tools/qa/furniture-walkspace.lua via scratch gallery.lua produces
emerald-gallery/: both floors unchanged collision; all five recipes matched.
Inspected native 1F/2F, final 2F overview and first-person face. Geometry bounds,
recipe matching, family isolation, native source rectangles pass focused tests.
Museum 1F, upper perimeter/statues, dynamic earned painting overlays and other
special interiors remain unfinished/unverified. This is not every-tile coverage.
No ROM art committed, player saves untouched, no release bump.

# FRLG bed footprints and house stair width — 2026-10-05 (unreleased)

Compared native bedroom/Lorelei artwork and imported collisions. Only the
centre foot cell is blocked: fr_bed local (1,2), fr_lorelei_bed (1,1).
Rebuilt complete low beds within those cells, with separate feet, frame,
headboard, mattress, pillow and native blanket art. No native collision or
warps changed. Census now records zero flags for both beds (previously one
per bed). Seat/sofa flags remain unresolved, not silently removed.

User flagged starting-bedroom staircase width while reviewing the capture.
Gen3HouseStairs previously gave the projected front fascia floor depth: tread
Z17..43. Narrowed to Z17..31 with rails/stringers/well sides moved together,
restoring newly exposed floor. Horizontal two-cell run and original landing
rug remain. Applied to ascending and descending player-house assemblies.
Regression protects the physical flight from returning to a second lane.

Evidence: source engine v0.3.51, isolated FireRed/LeafGreen QA profiles and
companions. Native and rendered bed captures in GAME-beds-final; final stair
and bed fixtures in leafgreen-beds-stairs under .scratch/coverage-20261004/results.
Inspected bedroom overview before/after, both floors' final stairs overview,
and Lorelei close view (partly obscured by native NPCs). Room collision grids
unchanged. Repeat QA_BEDS=1 with tools/qa/furniture-walkspace.lua copied to the
scratch runner. No manual warp traversal claimed. Full suite: 164 passed,
0 failed, 56 external skips (.scratch/beds-stairs-tests.log).

Refreshed Emerald footprint census: only chair/cushion/stool families flagged;
this measures authored boxes against central actor walkspace, not every surface
or every game's visual completeness. Full-world coverage, seats, exterior
families and the reported black patches remain open. No release bump.

# FRLG fence artwork correction — 2026-10-05 (unreleased)

User screenshots: Pallet repeated perpendicular rail prongs, flat fence art
beneath foliage, black patches in Route 1 grass. Fixed Pallet 284/287 as straight
native-material pickets, shared EE/F6/1F0 endpoint directions, D6/D7 covered
fences, Fuchsia 336/337/33F models. Fuchsia recipes use canonical rom_082d4b54;
LeafGreen live imported rom_082d4b34 resolves through Gen3Tilesets.bind.
Ground strips keep native foliage without duplicate flat metal. Every fence
vertex remains in its own cell; production native collision is never modified.
EF retains its prior unverified recipe (not extrapolated from the EE drawing).

Source runtime v0.3.51, isolated QA profiles with all seven companions. Native
composited atlas inspected, rather than inferring corners from adjacency.
LeafGreen fences-final: 10 cases / 30 captures plus canopy GPU checks passed.
Inspected endpoint/alias overview and rotating views, covered foliage view and
Pallet first-person view. Some camera captures are obscured by NPCs/buildings;
those are not visual passes. Paths under .scratch/coverage-20261004/results/.
Repro driver tools/qa/gen3-fence-coverage.lua additionally compares every map
collision cell and preserves target metatile. Requires DS_MOD_PATH and SHOT_DIR.
Final FireRed fences-checked run: all 30 captures, unchanged full collision
grids and canopy GPU checks passed; inspected Pallet overview confirms straight
rails while genuine boundary corners remain connected.
Focused regressions and complete suite: 164 passed, 0 failed, 56 fixture skips;
.scratch/fences-tests.log. No player save touched, captures remain untracked.

Black patches remain OPEN: current Route 1 daytime and forced NIGHT captures
with companion spawns did not reproduce them (leafgreen-outdoor-source and
firered-outdoor-night). User clarification pending about current cart and whether
patches move. No speculative shadow or spawn patch applied. Building models
were not changed in this pass. Full world coverage and visual polish remain
incomplete; these fence checks do not establish all-tile/all-game quality.

# Native FULL preset parity — 2026-10-05 (unreleased)

Audited existing option inventory; full parity is NOT complete. Gen3 FULL
previously only selected a camera angle. Gen3FullPreset now applies the same
supported GB presentation values on entry: maximum tilt-shift, no world curve,
FULL water, staged battles ON, player back view. FULL pins DAYTIME to SYNC.
Other choices apply only on entry: users can edit battles/art afterward; loading
an already-FULL save doesn't overwrite those edits. Leaving FULL releases the
clock without reverting user choices. Native Game3 framing/UI remain engine-owned,
not rewritten through GB-only Zoom or battle-panel APIs. The native menu still
shows its existing rows (Gen1 hides some while FULL); this is not full menu
conditional-visibility parity. No changes to Gen1/2 consumers.

Runtime verification: v0.3.51 isolated LeafGreen and Emerald profiles;
`bash .scratch/coverage-20261004/run.sh GAME full-preset` with copied checked-in
`tools/qa/gen3-full-preset.lua`. Driver explicitly dispatches core.update (raw
source drivers otherwise bypass mod updates). Both passed preset entry, settings
reaching their consumer objects, battle edit retention, clock release and restore.
Inspected both full-preset.png renders: diorama blur/night clock active, native
UI remains crisp. Results .scratch/coverage-20261004/results/GAME-full-preset/.
No battle gameplay QA in this test; no player saves touched. 164 suites passed,
0 failed, 56 external-fixture skips; logs .scratch/full-preset-tests.log.

Updated docs/OPTION_PARITY.tsv from tools/option-parity-report.lua. Missing
options remain 16 (Gen2), 42 (Gen3), plus partial/provider cases. Outstanding
Legendary capture/audio/beam effects, native specialty scenery, Gen3 RAM
precache, standing-trainer integration and Crystal-specific art options need
real implementations/adapters, not editable placeholders. Inventory is source
coverage only, not proof of every option on every platform. No release bump.

# FRLG League statues — 2026-10-05 (unreleased)

All ten Lance corridor statues now have closed native-art voxel sculptures
and separate plinths. The figure is in BG2: previous under-layer-only contact
sheets hid it. Gen3Statue uses upper-layer alpha (no floor-colour guessing),
VoxelHull for the native sculpture silhouette, and caches templates per native
atlas/mid. Figure depth is bounded to eight pixels, centered on the blocked
base cell; all solids stay in that cell, never the walkable projected top row.
Four boundary drawings use the same native 249 plinth and preserve 290 wall-cap
art as ground. Neighboring wall columns remain owned by the wall renderer.
New blockedRows metadata refuses matching a statue if its base is walkable.

Verification: source engine v0.3.51, isolated FireRed AND LeafGreen QA profiles.
`QA_LEAGUE=1 bash .scratch/coverage-20261004/run.sh GAME league-statue-audit`
(GAME=firered/leafgreen, paths relative to /home/admin/Projects).
Driver is the checked-in tools/qa/furniture-walkspace.lua copied into scratch.
Each game: all five League room collision grids unchanged, all ten Lance
statues matched, no scene errors. Inspected FireRed overview/first-person and
LeafGreen overview/first-person/side captures. Results:
.scratch/coverage-20261004/results/{firered,leafgreen}-league-statue-audit/.
Additional LeafGreen Oak's Lab regression from league-statues-final inspected
in preceding pass; no shared room-wall changes here. Scripts halted after load:
these are render/collision fixtures, not completed gameplay or online tests.
163 suites pass, 0 fail, 56 skipped for external fixtures; 333 lib Lua modules
compile in LuaJIT. Logs .scratch/league-statues-tests.log. New test checks
upper-layer alpha, sculpture/plinth bounds, template reuse, partial matches,
boundary isolation, and walkable-base rejection. Tests do not certify perfect
visual fidelity. Player saves untouched; QA processes exit themselves.

Still unfinished: Champion chamber platform/walls/fixtures, League outer shell
and side treatment, remaining seats/beds, broad all-game artistic coverage and
partner feature parity. No release/version bump. No all-tiles completion claim.

# FRLG League wall and fixture pass — 2026-10-05 (unreleased)

Raised shared native orange League walls/closed rear doors (collision 7 only),
using adjacent native floor colour instead of purple in all rooms. Authored
ice/stone stacks and mirrored curved horns; retained Agatha's column model.
Complete four-row wall-fixture recipes include the original two-row wall
panel, preventing missing wall bays. Only the blocked rows contain solids;
the final walkable source apron remains floor. Free horns match two rows so
both lower court fixtures still match when their apron becomes the doorway.

Evidence: engine v0.3.51, isolated LeafGreen QA profile; player saves untouched.
Driver: .scratch/coverage-20261004/league-complete.lua via
`QA_LEAGUE=1 bash .scratch/coverage-20261004/run.sh leafgreen league-complete`
(paths relative to /home/admin/Projects). Native/overview/first-person captures
under .scratch/coverage-20261004/results/leafgreen-league-complete/.
Inspected Lorelei, Bruno, Agatha and Lance fixture/wall captures; also inspected
Champion overview and unrelated Oak's Lab overview. All six rooms retained
exact native collision arrays after rendering. Scripts halted after Map.load:
this proves geometry/collision preservation, NOT a played League campaign.
332 lib/*.lua files compiled with LuaJIT; 162 suites passed, 0 failed,
56 skipped (missing external fixtures). Designed-object test covers 347 cases.
New bounds assertions cover source faces, boxes and polygon vertices; wall
fixtures stop before the native walkable apron. Logs in
.scratch/league-tests-final.log and .scratch/league-20261005/logs/.

Remaining: Lance corridor statues still flat (upper art absent from the simple
metatile contact sheet, requires source-layer review), Champion platform/wall
and fixtures, League outer beige shell and side treatment, broader seats/beds,
all-world artistic coverage and partner parity. This is NOT full coverage or
100-percent visual fidelity. FireRed shares these canonical recipes but this
batch's runtime captures used LeafGreen only. No release/version bump.

# FRLG arena/League/source-art correction — 2026-10-05 (unreleased)

Native atlas + collision review found three invented objects: Agatha's
0x2a1 is a court-border floor tile, Game Corner 0x2a8/0x2a9 are carpet,
and Colosseum 0x30a/0x2f6/0x2fa are floor/wall art, NOT spectator stands.
Removed their furniture recipes and unused model branches. Added reviewed
Colosseum court surfaces and collision-scoped wall profiles. Arena walls
have four-pixel thickness; the source's empty/teal top band is not extruded
as black wall faces. Native screen/panel artwork remains on the upright wall.

Authored all six actual purple/gold Agatha columns from complete native
354/355 and wall 362-or-363/356/360 drawings. Closed stepped bases/caps,
gold flutes, purple sides; solids remain inside the two blocked rows, never
on the third walkable source apron. Existing generic League wall art still
lies on the floor: this is not a finished-room claim.
Game Corner's thirty blue chairs now retain side backrests facing their
machines. They remain walkable native seating requiring actor-support work.
Kept Gen2's shared old stool implementation unchanged under its original ID;
new Gen3 chair has its own design ID to avoid unreviewed cross-game changes.

Evidence: native, overview and first-person captures inspected using source
engine v0.3.51, LeafGreen isolated profile with companions. Maps: Agatha,
Battle Colosseum 2P, Celadon Game Corner, SS Anne 1F Room1 (neighbor check).
All four settled collision grids unchanged through rendering. No gameplay,
save, input or online-battle changes. No manual walking or gameplay battle
claim. QA_SEATS=1 tools/qa/furniture-walkspace.lua repeats the fixtures.
Scratch: .scratch/coverage-20261004/results/leafgreen-seats-{before,verified};
leafgreen-arena-art and leafgreen-agatha-art retain native atlas/grid evidence.
All game processes exited; user saves untouched.

Full authored-box census: 263 interiors / 1,233 objects / 128 flags (was143).
Six new columns have zero overlap flags. Remaining seat/bed overlaps are
unresolved; the census checks only central 8x8 low-box intersections, not
all geometry, every tile, exteriors or Gen1/2. Removing false models reduces
counts but does not certify complete coverage. Beds, seated-actor support,
other-generation coverage and broad fidelity remain open.
162 suites pass, 0 fail, 56 external-fixture skips; 347 production Lua files
compile in LuaJIT. Tests: .scratch/seats-final-tests.log; footprints in
leafgreen-seats-census. No release/cart/version change this pass.

# FRLG homes and industrial walkspace — 2026-10-05 (unreleased)

Compared native art/collision for starting bedroom, Celadon roof room, Seven
Island House Room1, Lorelei's house, Rocket Hideout B4F and Five Island
warehouse. The starting bedroom/neighbor green cabinet was incorrectly
modeled as a television: restored a two-shelf bookcase with green header.
Sevii bookcases use the same reviewed native cabinet structure. Bedroom PC
and dresser fit their blocked rows; the blue native floor seat is a low pad.
Roof-room desk retains its books and woven top without floor pixels.
Sevii cupboard and Lorelei display fit their blocked rows. Rocket sofas fit
one blocked row, ordinary desks two; executive desks have a separate terminal
and fit one blocked row. Processing-machine access fitting stays in the
blocked upper arm of its L-shaped native footprint; trimmed chassis edge.

Straightened house rear walls behind the corrected furniture. Wallpaper
completion now fills only claimed furniture columns, preserving native
posters/windows on untouched columns (a render check caught the poster
being covered by generic wallpaper). Neighboring starting-house 1F and
rival's house checked with intact windows/poster and straight rear walls.
No native gameplay/collision or saves changed.

Engine v0.3.51 / LeafGreen isolated profile / companions enabled. Native,
overview and first-person captures: .scratch/coverage-20261004/results/
leafgreen-homes-{before,verified}, plus leafgreen-homes-neighbors.
Before fixture also inspected Hotel, but its walkable sofa remains unresolved.
All six target rooms and two neighbors preserve settled native collision.
QA_HOMES=1 tools/qa/furniture-walkspace.lua repeats the six targets.
First-person Hideout capture includes transient native floor/story overlay;
no claim of resolving that separate visual issue or full manual playthrough.
Sevii/Lorelei generic rear-wall texture orientation still needs authoring.

Authored-box census now 143 flagged placements (was 166): remaining stools,
chairs, cushions, Colosseum stands, corner seating caps, two beds, Hotel sofa,
and Agatha pedestal. These need actor-support/geometry review; not an excuse
to alter native collision or erase the native furniture. This census checks
only low boxes against central 8x8 walkspace, not every tile/mesh/exterior.
No claim of all-world coverage or Gen1/2 parity completion.

162 test suites passed, 0 failed, 56 external-fixture skips; production LuaJIT
compile and diff checks pass. .scratch/homes-final-tests.log. Census:
leafgreen-homes-census/footprints.csv. QA processes exited, player saves
untouched. Changes unreleased; no cart/version update this pass.

# FRLG retail/museum/Day Care fidelity — 2026-10-05 (unreleased)

Reviewed original imported artwork and collision in Celadon Center 1F,
Pewter Museum 1F, Celadon Department Store 2F/5F, Four Island Day Care.
Day Care metatile 0x309 is a walkable tufted cushion, not merchandise racking:
replaced that erroneous model with a low stitched pad, retaining its original
carpet tile beneath it. Department stock islands/glass cases start in their
blocked second row; removed parquet from their source top crops. Center
storage and museum bookcases fit their blocked rows and use separately
authored headers, two stocked shelves, closed cases and source book spines.
The white/green header is no longer repeated on individual book fronts.
Rear shells/columns stay behind these fixtures; corresponding Center wall
maps/screens stay mounted on the wall. No native collision edits.

LeafGreen engine v0.3.51, isolated profile with companions. All five rooms
captured native/overview/first-person; inspected cabinet close-ups, department
island and room overviews. All five settled native collision grids unchanged
through rendering. Driver: tools/qa/furniture-walkspace.lua QA_RETAIL=1.
Native art crops and captures (scratch only):
.scratch/coverage-20261004/results/leafgreen-retail-{before,final}.
No manual walking, FireRed boot, all-angle or complete-world visual claim.
Some surrounding wallpaper remains floor-oriented: outside this fixture pass.

Full LeafGreen box census: 263 interiors / 1,254 objects; flags 205 -> 166.
39 corrected placements (18 Center cabinets, 4 museum shelves, 9 department
displays, 8 Day Care cushions). All changed designs now have zero flags.
This checks only central 8x8 walkspace intersections with low authored boxes;
not every tile/polygon, generic wall or exterior. Remaining seats and other
furniture still need review. Gen1/2 and Emerald unaffected this pass.
162 suites pass / 0 fail / 56 external-fixture skips; 347 production Lua files
compile under LuaJIT; diff check clean. .scratch/retail-final-tests.log.
QA processes exited, user saves untouched, no release/cart modifications.

# FRLG office/lab native footprints — 2026-10-05 (unreleased)

Silph tape/monitor terminals fit their blocked first row; server banks fit
rows 0/1. Oak's lab computer, terminal, server and bookcases no longer extend
into their native walking lanes. Freestanding bookcase end pieces use the
same blocked middle row as the complete shelves. Condo workstations retain
CRT, keyboard and book components in row 1; sofas fit row 0; bookcases fit
their blocked rows. Octagonal meeting-table polygon now starts in blocked
row 1, rather than crossing the walking row. Original palettes/source art
retained; no gameplay collision changed.

Initial render exposed lab wallpaper masking corrected fixtures. Added the
canonical oak_lab atlas to straight rear-wall handling, and made lab wallpaper
follow that rear plane. Re-rendered: computer/shelves visible, straight wall.
QA baseline now records collision AFTER native map-load/door scripts settle;
Silph applies legitimate collision changes while loading. All five final
fixtures preserve that settled collision through native/3D camera renders.

Engine source v0.3.51, LeafGreen isolated QA profile, companions enabled:
FR_SILPH_CO_2F/10F, FR_CELADON_CITY_CONDOMINIUMS_2F/3F, FR_OAKS_LAB.
Native source exports and before/after captures:
.scratch/coverage-20261004/results/leafgreen-kanto-offices-before and
leafgreen-kanto-offices-verified2. First-person terminal/lab/bookcase and
room overview captures inspected. Condo 2F first-person fixture remains
poorly framed behind a partition; overview confirms sofa footprint only.
Run tools/qa/furniture-walkspace.lua with QA_OFFICES=1 to reproduce.
No player save modified; scripts halted for camera inspection, not a manual
walkthrough or complete story test. FireRed shares recipes but was not booted.

Full authored-box census: 263 interiors / 1,254 objects / 205 flagged instances,
down from 265. Corrected designs have zero remaining flagged instances;
generic books still has four OTHER flagged placements in Pewter Museum.
Census is central-8x8 low box overlap only: does not certify every cell,
polygon, ground texture, exterior or Gen1/2. The octagonal tabletop has a
separate polygon footprint regression. Remaining 205 flags need review;
seats may intentionally be walkable and need actor-support verification.

Validation: 162 suites pass, 0 fail, 56 external-fixture skips; 347 production
Lua files compile with LuaJIT; diff whitespace check passes. Test logs:
.scratch/kanto-office-final-tests.log. Census: leafgreen-kanto-footprint-office.
No release/cart change. Other-world coverage remains unfinished.

# Museum/facility walkspace pass — 2026-10-05 (unreleased)

Reviewed native art and collision rows for Oceanic Museum 1F, Mossdeep Space
Center 1F/2F and Rustboro House1. Closed rounded cream/blue museum vessels
replace thin wall slabs; wallpaper on the source's right edge is excluded.
Small museum cylinders/glass cases fit the blocked second row. Facility
computer desks retain CRT/keyboards but move their supports into the native
blocked second row; two-row plans tables retain their original footprint.
Control banks and household sofas fit their blocked first row. No native
collision, scripts, input or saves modified.

Emerald authored-box census now flags 213 placements (previous 241): only
82 right chairs, 47 left chairs, 54 cushions and 30 stools remain. These
walkable native seats still need actor-support review, not automatic removal.
The 28 corrected non-seat placements pass the central 8x8 footprint test.
This does NOT certify every tile, collision edge, arbitrary mesh face,
exterior or other generation. The same censused corrected recipes cover
other maps, but only the four listed rooms were visually inspected this pass.

Official engine v0.3.51, isolated profile, companions enabled; native,
overview and first-person driver captures inspected. Evidence:
.scratch/coverage-20261004/results/emerald-institutions-{before,after,verified};
source crops retained only in scratch. Census emerald-footprint-institutions.
Run tools/qa/furniture-walkspace.lua with QA_INSTITUTIONS=1 for these four
rooms and collision-immutability assertions. Fixed this driver's remaining
LeafGreen double atlas resolution as in the census. Scene scripts halted for
inspection: no manual walking/controller or complete playthrough claim.
All fixture processes exited; user saves untouched.

Validation: 162 suites pass, 0 fail, 56 external-fixture skips. Footprint
regressions cover vessel/desk bounds and control/sofa placement. Broader
world/source-art coverage, other generations' footprint audit, seating
support and museum's remaining generic wall/door art remain unfinished.
No release/cart changes this pass.

# Native walkspace/model correction — 2026-10-05 (unreleased)

Compared live imported source art, native collision rows and renders for
Emerald Oldale Mart, Rustboro House3, Fortree House3 and Birch's Lab; FR/LG
Cerulean Mart, with Viridian Center/Route2 House as neighboring checks.
Moved home appliances, drawers, lab shelves/computers/desks/servers into
blocked rows. Birch cupboard upper row is floor: only the lower blocked row
now carries its solid cabinet; native floor no longer textures its top.
Bookcase lids use the actual white lid, not floor/cushion source pixels.
FRLG mart coolers return to their blocked footprint (fixes the recent polish
regression). Rectangular shop/lab north walls stay straight behind the
corrected furniture; mounted notices/windows follow the same wall plane.
Added FRLG mart wall notice. Removed Emerald's invented return counter:
its two cells are clock wallpaper and walkable floor. The clock is restored
on its original wall drawing. Native collision/scripts remain unchanged.

Full Emerald authored-prop census: 281 -> 241 flagged instances, including
13 removed false counter claims. Corrected designs have zero flagged solids.
Census flags are review candidates (many seats), NOT all proven defects.
Fixed census double-canonicalizing LeafGreen atlas names; preloads all layouts,
binds aliases and sorts map/report traversal. Earlier LeafGreen aggregate
comparisons are invalid due to this harness flaw. New complete baseline:
263 interiors, 1254 designed props, 265 flagged candidates; all 12 mart
coolers now pass. Emerald: 708 designed props, 241 remaining flags.
The census only checks authored box solids intersecting central walkable
8x8 footprints below actor height. It does not certify every terrain cell,
wall, card, exterior, smaller edge overlap or any Gen1/2 object.

QA engine official 0.3.51, isolated profiles, companions present. Drivers:
tools/qa/furniture-walkspace.lua and furniture-footprint-census.lua.
Evidence .scratch/coverage-20261004/results/{emerald,leafgreen}-footprint-
rooms-before/after and {emerald,firered}-footprint-final-rooms (native,
overview, first-person); source crops under emerald-footprint-sources.
Final census {emerald,leafgreen}-footprint-final. Rooms assert native collision
unchanged after renders. Source images remain scratch-only. These are
teleported fixture captures, not controller movement/playthrough proof.
162 suites passed, 0 failed, 56 fixture-dependent skips; 339 designed-object
checks and walkspace tests repeated after final source-crop corrections.
All production LuaJIT compilation passed before those simple crop changes.
Fixture processes exited, player saves/install untouched. No release.

Remaining coverage is substantial: current candidates include seating,
office/museum fixtures, generic cabinets/racks; source-faithful wallpaper,
other interiors, all exterior/terrain geometry and Gen1/2 walkspaces still
need exhaustive review. Do not claim every tile or every game is finished.

# Shared rendering optimization — 2026-10-05 (unreleased)

All generations now skip equal model/sunModel uniform uploads in visible and
shadow passes. Cache stores 16-value snapshots, detecting matrices animated in
place; pass/shader resets and failed-send retries prevent stale transforms.
BuildBudget.tick avoids inactive counters/modulo outside cooperative builds.
Gen3 shares its water list between shadow/visible passes and stores healing
prop references at scene build instead of scanning every cell during healing.
No model, shader effect, shadow resolution or render-distance reduction.

Official engine 0.3.51; isolated Yellow Viridian Forest, Crystal Ilex Forest,
LeafGreen Viridian Forest, Emerald Petalburg Woods. 2560x1440, high shadows,
180-frame submission census; companion Pokemon remain live. Requested versus
actual matrix uploads: Yellow 11921/9564; Crystal 18046/9499; LeafGreen
16324/14704; Emerald 23314/21694 (approximately 20/47/10/7 percent avoided).
Driver tools/qa/render-submissions.lua. Logs/captures under
.scratch/coverage-20261004/results/<game>-render-perf-count; before/after
comparison at .scratch/render-opt-20261005/comparison.png visually inspected.
These counts isolate avoided submissions within a sample. Separate-run CPU
measurements were mixed, and some runs were concurrent: NOT evidence of an
end-to-end FPS improvement or a GPU/frame-time claim. No automated quality
reduction. Cold builds, repeated Gen3 shadow rendering and GPU-heavy forests
remain candidates for further profiling; optimization is not exhausted.

Validation: 162 suites passed, 0 failed, 56 external-fixture skips; all 347
production files compiled with installed LuaJIT (Python Lupa helper unavailable).
Matrix tests cover mutation, equal distinct tables, per-uniform state, shader/
pass resets, and failures. Shadow-OFF mock includes the new cache dependency
and still proves zero GPU access. Isolated fixture processes closed; normal
user saves/install untouched. No cart or release update this pass.

# Native mart polish — 2026-10-05 (unreleased)

Replaced FRLG mart's flat till and open-legged checkout with authored register,
sloped keypad, drawer, closed L-counter and a separate low clerk cushion.
Rebuilt island racks with neutral native side panels and independent stock;
labels are on outward faces rather than stretched across their tops. Rear
cabinets now stand in front of the north wall: no cabinet-shaped wallpaper
recess. Thin framed pictures use a shallow inset so wallpaper cannot hide art.

Evidence: isolated official v0.3.51 source engine, fresh native FR/LG fixtures.
Before: .scratch/coverage-20261004/results/leafgreen-common-fixtures.
After: .scratch/coverage-20261004/results/leafgreen-mart-final (overview/first).
Native source atlas inspected via firered-mart-source/island.png. The two
versions share this matched tileset. Common fixtures also boot the Viridian
Center and Route2 house; no runtime errors. Driver common-fixtures.lua and
mart-final.lua under the same scratch root. Player saves/install untouched;
all fixture processes quit. Captures are fixture QA, not manual movement QA.

Full suite: 162 passed / 0 failed / 56 external-fixture skips, followed by
339 designed-object checks after the thin-frame inset fix. Added assertions
that high checkout surfaces stay outside the clerk aisle and wall cabinets
stay inside their intended footprint. Native collision/gameplay unchanged.
No release this pass. Broader interior/exterior polish remains incomplete;
this pass covers the FRLG shared mart models and shallow wall displays.

# Terrain depth follow-through — 2026-10-05 (after 1.31.1, unreleased)

Existing terrain topology/stairs/platform/bridge geometry remains in place.
Closed a real battle consumer gap: Gen3Stage discarded native elevation when
choosing its area and camera/actor support. Gen3Elevation.battleFloor freezes
the encounter's support and restricts candidate centers/yaw scoring to native
walkable, level cells on the same physical surface. Native collision and battle
mechanics are untouched. Camera rig and all staged actor anchors share that
frozen support, including bridge underpasses, instead of sampling the deck.

Official 0.3.51 isolated QA: Emerald Route119 (18,34), native layer 1 underpass
height 0 and upper-deck height 32. Started real native wild battles on each;
verified BattleCam.rig input and both staged actor heights, inspected captures.
Driver tools/qa/bridge-battle.lua; default tests the native underpass layer,
BRIDGE_LAYER=3 tests the deck. This is a battle fixture, not traversal/network QA.
Evidence: .scratch/depth-20261005/bridge-{under,deck}.png and
.scratch/coverage-20261004/results/emerald-bridge-battle.

Repeated all-map census: Crystal 388 maps/17530 raised cells/69 flights;
FireRed and LeafGreen each 426/7138/293; Emerald 519/21862/317.
1759 maps total, zero topology conflicts. Logs/coverage.tsv in
.scratch/coverage-20261004/results/*-terrain-census-depth. This is topology
coverage, not visual signoff on every tile. Gen1 authored terrain unchanged.
Full suite: 162 passed, zero failed, 56 missing external fixture skips;
.scratch/depth-20261005/tests.log. Added low/high bridge battle bounds/collision
regressions. No user saves touched. Companion/replay underpass-layer transport
still needs its own integration/validation; do not claim full multiplayer parity.

# Modern UI release and native Legendary preset — 2026-10-05

Gen3 loads LegendaryVisualsPreset, registers its master and uses the same live
setting rows as Gen1. Effective labels agree with renderer values; child edits
leave the preset for CUSTOM and retain raw preferences. Native direct-options
migration persists once. Emerald runtime driver verifies FULL overlay, child
edit, persistence and restoration. This is partial Legendary parity: capture
beam/suction/audio and specialty model families remain missing.

BattleTheme resolves optional Modern Pokemon UI v1 dynamically, with local
fallback when absent/disabled/incompatible/failing. Gen3 battle styling now
excludes Emerald's regional native menu namespaces. Modern UI standalone GB
panels were visually found to become neon in Gen1's palette pass and overlap
sprites; fixed to palette-safe colors and native player HUD bounds. Retained
wrappers disarm on unload. Separate Modern UI repo is independently loadable.

Full suite before the final menu guard: 161 passed, zero failed, 56 external
fixture skips; the new FRLG/RSE menu-guard test also passes. Live ON/OFF captures
inspected for Yellow/Crystal/LeafGreen/Emerald, standalone and with partners.
Engine v0.3.51 is current as verified from its latest GitHub release. See
 docs/NATIVE_UI_AUDIT_2026-10-05.md: Online and Ride custom dark menus are still
native-style gaps. Remaining Ascendant/Legendary work is NOT certified complete.

# Shared options and native camera parity — 2026-10-05 (unreleased)

Extracted Gen1's category names/order into OptionCategories, consumed by both
GB generations and native Game3 pages. Every catalog key has exactly one
category (except the migrated legacy battle-stage alias). Native artwork and
UI rendering stay with each engine. Gen3 keeps the existing fireredCamera save
key but shows VOXEL; its short 3RD label fits the native value column.

Fixed a concrete Crystal menu bug: the native constructor ignores opts.rows.
Submenus now set the native rows/view/sub fields, keep BACK, and retain the
parent's options table. Conditional rebuilds keep that exit. Regression tests
exercise the real native menu constructor for Gold, Silver and Crystal.

Game3 now shares Gen1 third-person zoom bounds/step/easing, wheel direction,
left/right-stick click zoom, and camera cycling that skips FULL. Q/E also
operate the third-person boom when not rebound. Right-drag mouse look polls
on engines without input.pointer; events and polling cannot double motion.
Native FRLG and Emerald menus retain wheel/look ownership. First-person and
survey zoom paths are not replaced. Camera collision, touch/pinch and every
Gen1 cinematic feature are NOT claimed as ported by this change.

Live verification (Gen1Recomp 0.3.51, isolated profiles): Yellow, Crystal,
LeafGreen and Emerald WORLD pages, inversion changes reaching the camera,
and restoring the original choice. Inspected Crystal/LeafGreen/Emerald menu
captures; Crystal initially displayed the root again, then correctly displayed
the WORLD controls after the constructor fix. LeafGreen third-person wheel
shortened the boom; left-stick click restored it, with exclamation animation
and right-stick look still working. Drivers: tools/qa/option-parity.lua and
 tools/qa/gen3-camera-parity.lua. Evidence: .scratch/coverage-20261004/results/
{yellow,crystal,leafgreen,emerald}-parity-options and leafgreen-parity-camera.
No user saves changed. Full suite: 159 passed, zero failed, 56 historical
fixture/source-art skips; 685 Lua files compiled; whitespace checks clean.

Source inventory: docs/OPTION_PARITY.tsv, reproducible with
`luajit tools/option-parity-report.lua`. Corrected Crystal weather/FSR consumers
and optional Modern UI provider ownership. This inventory is NOT runtime QA:
Gen2 still lists 16 missing and 29 partial options; Gen3 43 missing and six
partial, including generation-specific art controls. Largest remaining ports:
Legendary capture/audio/beam effects, special scenery families, Gen3 RAM
precaching and optional standing-trainer provider integration. Gen3 FULL currently
selects the camera angle but does not apply the Gen1 bundled presentation preset.
Do not advertise
full feature parity or turn these statuses green from menu visibility alone.

# Exclamation/emote camera ownership — 2026-10-05 (unreleased)

Reproduced in LeafGreen Pallet Town on Gen1Recomp 0.3.51: native
FieldEffects.startExclamation made Gen3Scene.nativeRequired true and disabled
Gen3Integration.active until the effect ended. Added native emote cards to
Gen3's supported effects. The engine collector supplies the original glyph,
frame and bounce; only coordinates are projected into the voxel scene. Cards
stay upright, follow free-camera yaw, retain terrain support and depth, and
never advance script/animation timers. Unsupported effects retain native fallback.

Before/after isolated QA: .scratch/coverage-20261004/results/leafgreen-emote-camera
(before.log/png and run.log/exclamation.png), plus emerald-emote-camera.
Confirmed 3D stays active during the bubble, right-stick yaw changes, and native
completion fires exactly once. Inspected both rendered bubbles. The fixture
invokes the real native effect on a stationary player, with story VM halted;
it is not a full trainer-approach/battle transition playthrough. User saves untouched.
Unit checks cover static/first/rotating-third card orientation, height/bounce,
frame preservation, empty effects, and emote+dust versus unsupported overlaps.
Full suite with engine/generated fixtures: 157 passed, zero failed, 56 external
historical-fixture skips (.scratch/emote-20261005/tests.log).
Gen1/2 camera gates unchanged; their existing dialogue/movement ownership tests
remain in the suite. No cart/release versions changed.

# Terrain support and strict test baseline — 2026-10-05 (unreleased)

Fortree's native 0x170 bridge cells now have a raised deck, underside and thin
fascia, with a separate lower floor only when matching walkable banks prove
an underpass. Native player/NPC elevation selects deck versus lower support;
first-person and orbit cameras follow that support. Collision and gameplay
remain engine-owned. Ordinary variable-layer tiles cannot invent crossings.
Gen1/2 terrain algorithms are unchanged. Fixed TerrainAtlas to consume the
engine's public animClock API when provider wrappers obscure tick's internals.
Water shaders qualify return/arguments consistently and retry the unqualified
signature when the backend rejects explicit precision.

Validation against official Gen1Recomp v0.3.51 source/runtime:
- Full suite with engine and existing Yellow generated data: 156 PASS,
  zero FAIL, 56 SKIP. Skips require historical snapshots/source atlases, not
  replacement snapshots generated from the candidate. Logs:
  .scratch/terrain-20261005/final.log and logs-final/. No failing-test allowance.
- The 1,173-assertion SDK suite now compiles within LuaJIT's local limit and
  exercises current menu/default/provider contracts. Fixed obsolete fixture
  dependencies across companion, scenery, animation, HUD and geometry suites.
  No feature was disabled in production to satisfy a test.
- Engine-only suite runs in CI using pinned v0.3.51; resource skips are explicit,
  actual failed assertions fail CI. All 678 production/test Lua sources in the
  compile sweep passed; whitespace clean.
- Native census: Crystal 388 maps / 17,530 raised cells / 69 flights;
  FireRed and LeafGreen each 426 / 7,138 / 293; Emerald 519 / 21,862 / 317.
  All four report zero uphill topology conflicts. This measures topology,
  not visual approval of every tile.
- Native walking: Crystal Dance Theater 0->6; LeafGreen Mt Ember 24->36.
  Both max per-frame support delta 1.5. LeafGreen first-person camera 49.5
  equals 36 terrain + 13.5 eye height. Inspected raised-floor first-person
  and Emerald Route119 bridge underside/deck screenshots.

Repeatable drivers: tests/elevation_review_driver.lua accepts
TERRAIN_CENSUS_ONLY=1; tests/elevation_walk_driver.lua; and
 tools/qa/bridge-underpass.lua. Use isolated *-qa profiles only.
Evidence in .scratch/coverage-20261004/results/*-terrain-census-final,
*-terrain-walk-final and emerald-bridge-review. No user saves changed.
The bridge driver places fixture actors on both layers; it does not certify
native traversal, companion followers, replay or battle placement under bridges.
Those consumers still need layer-aware integration review. No claim of exhaustive
visual perfection or multiplayer terrain verification. No release/cart pins changed.

# Shared Gen3 furniture footprint audit — 2026-10-05 (unreleased)

Corrected 16 authored component assemblies: Center PCs/medicine shelves,
Mart stock/glass cases/coolers, household TVs/books/cupboards/fridges/sinks.
Move complete native-textured assemblies into their blocked footprint instead
of using the artwork's perspective apron as additional floor depth. Gen3
north-wall shell and native wallpaper now recess behind those assemblies;
otherwise the corrected Mart coolers were hidden behind the wallpaper.
All gameplay collision, warps and interactions remain unchanged. Gen1/2
furniture placements and cave shells are unchanged.

Repeatable engine driver: tools/qa/furniture-footprint-census.lua. It audits
resolved authored props in Gen3 indoor maps against native collision and
reports low solids intersecting a walkable cell's central 8x8px region.
Flags are review candidates: chairs/seats can be intentional. This does not
certify every tile, generic geometry, source-art accuracy or gameplay access.
Emerald flags fell 474 -> 281 (193 placements); FireRed 330 -> 253 (77).
LeafGreen post-change census completed: 263 indoor maps, 1187 authored props.
No before-change LeafGreen measurement was taken.

Evidence: official engine 0.3.51, isolated profiles and fresh teleported
fixtures, existing companions enabled. Scratch coverage-20261004 contains
footprint-census[-after] outputs and common-fixtures native/overview/first
captures. Inspected Emerald Oldale Center/Mart and Slateport house, FireRed
Viridian Center, Cerulean Mart and Route 2 house. Cerulean Mart was rechecked
in first person after moving the separate wallpaper layer. Grid was disabled
for final captures. Fixture story VM halted for geometry inspection; this is
not a full playthrough. No user saves modified. All fixture processes exited.

Validation: interior_walkspace_test (16 shared families, exit frames, wall
recess merging/cache invalidation), interior_diorama_test,
designed_interiors_test (337 objects), gen3_center_furniture_test and
gen3_additional_furniture_test pass. System LuaJIT compiled 683 Lua files;
unchanged tests/battle_art_voxel_fork_test.lua exceeds LuaJIT's 200-local
limit at line 2604 (also reproduced from HEAD). Python compile helper cannot
run under system Python because its Lupa luajit21 backend is unavailable.
Changed production files compile and boot successfully.

Remaining: flagged seats/stools need actor-support review; Mart return
counters, lab/office furniture, museum cases, native generic cabinets/racks
and remaining Gen2 footprints are not certified. No exhaustive world coverage
or all-five-mod feature parity claim. No release/cart pins changed in this batch.

# Interior exit frames and walkable-space corrections — 2026-10-04 (unreleased)

User reports missing indoor exit doors and models protruding into traversable
space, specifically Emerald's starting truck and room. Shared InteriorDiorama
now uses boundary warp cells to cut actual wall apertures and draw door jambs
and lintels, including camera-facing cutaway walls. Adjacent warp cells merge
into one opening; interior stair warps do not become perimeter doors. Cave
passage handling is unchanged. Frames are offset from wall faces and their
jambs stop at the lintel to avoid coplanar flicker. These are open doorways,
not animated door leaves or live views of the outside.

Emerald truck: replaced generic furniture fallback with a complete native
cargo recipe, separate cargo cases, clean native metal floor, preserved bright
exit ramp, and metal-toned enclosure. All cargo solids lie in native blocked
cells. Starter furniture: desk/monitor, dresser, console and TV bodies now
stay in their blocked footprint; bed occupies its actual impassable centre
cell rather than its walkable perspective artwork. Walkable seating is low
pads. Added the missing living-room dresser tile variant. Wall picture, clock
and window are attached to the corrected starter-house north wall plane.
Native collision, warp data, scripted behavior and interactions are unchanged.

Evidence: official 0.3.51, isolated Emerald door-footprint/door-footprint-after
fixtures in .scratch/coverage-20261004. Inspected original 2D truck artwork,
before/after truck and both Brendan-house floors, plus first-person truck exit.
Fixture confirms unchanged collision grids and actual Player.tryMove succeeds
through the truck lane but fails into native cargo. Fixture scripts halt story
VM for geometry inspection; this is not a full new-game cutscene test.
Yellow Oak lab and Crystal Elm lab gb-doors fixtures also pass; inspected
Yellow first-person and Crystal overview exit frames. Shared shell tests cover
all three engines and merged doorway apertures. Tests: 337 complete designed
objects, 146 Hoenn recipes, native wall crops, Center/additional furniture,
interior shells and new interior_walkspace_test pass. No user saves modified.

Remaining: other maps/props can still have footprint mismatches; no full-world
collision-to-geometry certification. FireRed/LeafGreen-specific objects were
not changed this pass. Doors/windows do not yet show a live exterior. No new
mod/cart release or version bump in this pass.

# Optional modern UI ownership and upstream inventory — 2026-10-04 (unreleased)

User requires native UI by default, a separate optional modern UI mod, preserved
upstream Legendary features/settings, current partners, and no hard companion
dependencies. See docs/UPSTREAM_COMPATIBILITY_2026-10-04.md for audit and limits.

Fetched configured remotes: no missing upstream commits in voxel, Wild Skies or
spawn. Partner origin/main branches were current. All 72 literal upstream setting
keys retained; VIRIDIAN FOREST label restored without altering saved keys/values.
Do NOT claim complete Legendary native Gen2/3 scenery parity from this inventory.

ModernBattleUI now checks optional MODERN_POKEMON_UI API v1. No provider (or OFF)
means native HUD/textbox styling, no hidden panels or added glyph shadows. Gen1
styled textbox path delegates directly when absent. Gen2/3 hooks and doubles
modern HUD obey the same opt-in. Existing preference values are preserved.
Other legacy UI interactions (forced layouts, sprite packs, partner overlays)
still need a complete audit; full native-UI isolation is not yet certified.

New sibling `modern-ui` is a standalone local preview. Native settings in all
engines; Gen1/2 frame adapters and Gen3 scoped native healthbox palette; optional
voxel public stage integration enables projected cards/commands. Standalone
modern commands/game-wide menu replacement remain unimplemented. No remote or
release created. Do not add it to carts as a mandatory dependency.

Focused checks pass: UI provider absent/OFF/error/version, textbox controls,
Gen2/3 battle options, 437 native consumer checks, Legendary migration/profile,
Gen3 doubles 53 contracts, Gen2 doubles HUD, standalone 3-engine mocked framing,
and audit_partner_contracts.py. Full old SDK suite cannot run without tests.modkit.
Emerald official 0.3.51 runtime menu ON/OFF passed and captures inspected with all
partners and in a separate ONLY-Modern-UI profile. Fixed standalone panel oversize
found in first capture by recolouring native healthboxes and their text wipe
rectangles together. Gen1/2 standalone visual QA and full battle matrix pending.
Fixtures in .scratch/coverage-20261004/modern-ui*.lua, results/emerald-modern-ui*;
only scratch profiles were modified. Existing carts/user saves untouched.

# Interior false-shadow fix and regional furniture — 2026-10-04 (unreleased)

User reported implausible diagonal shadows across home walls. Root cause was
InteriorDiorama.geometry alternating two material swatches at quad corners.
Nearest filtering converted interpolated UVs into hard diagonal palette wedges;
these were not actual cast shadows. Each face now samples one material texel.
Face shading and the real renderer shadow pass are retained. The shared fix
applies to Gen1/2/3 room walls, ceilings, trim and plinths. Regression checks
verify constant material UVs over each face for every generation/cutaway side.
No mesh-disk revision needed: these enclosure meshes are built at runtime.

Inspected before/after Emerald Sootopolis home captures (regional-homes-before/
final) and final Crystal Elm lab / Yellow Oak lab (gb-wall-light), official
0.3.51. The diagonal material patches are gone; furniture/actor shadows remain.
The Gen2 debug overlay says Pokemon Gold, but the fixture asserts the selected
GameVersion matches crystal. Do not infer a separately tested Gold release.
QA files remain under `.scratch/coverage-20261004`; user saves untouched.

Coverage work continued: seventeen complete source patterns model 72 more
furniture instances across Sootopolis, Rustboro and the Safari rest house.
New sofas have separate backs/arms/cushions/feet; wide tables have full-depth
surfaces and legs. Native palette variants reuse appropriate existing sink,
cabinet, appliance and chair components. Original diagrams reviewed from
regional-homes-source; rendered five-room fixture verifies unchanged native
map/collision data. Inspected Sootopolis before/after overviews. This is not
visual certification of all 72 occurrences or all room fittings.

Focused tests: 335 designed objects, 144 Hoenn recipes, wall recess/crop bounds
and enclosure/material regressions pass. Emerald census now has 126 maps with
matched fixtures / 1,642 instances, out of 519 maps and 495 enabled scenes.
Remaining gaps include native wall/window families, stair and special-object
variants, other interiors/exteriors and settings adapters. Full-world coverage
and parity remain unfinished. No release/version bump.

# Hoenn native wall openings — 2026-10-04 (unreleased)

Three complete generic-building source patterns replace 58 flat wall fixtures:
21 round windows, 35 wallpaper sections and two broken-wall tunnel entrances.
Windows preserve the native circular glass artwork with recessed panes and
raised casement bars. They do not yet show a live exterior. Tunnel openings
have authored stepped jambs matching the native pixel silhouette, with the
dark source mouth recessed six pixels. Back/sides are closed. Native warps,
collision and gameplay remain untouched. Remaining plain upper wall fragments
behind cabinets use the existing bounded wall-column treatment.

QA on official Gen1Recomp 0.3.51: isolated Emerald windows-after/windows-final
fixtures under `.scratch/coverage-20261004`, with original artwork from the
existing homes-source captures. Inspected Lilycove motel 2F first-person and
Fossil Maniac house first-person/overview; the doorway now joins the wallpaper
instead of leaving isolated upright panels. Repeated fixture includes the
Fortree homes/shop and asserts native layout/collision equality. Test capture
options belong only to the scratch profile; user saves untouched.

Focused tests: source crop/footprint/recess depth, interior enclosure, 127
Hoenn recipes and 318 designed objects pass. Refreshed Emerald inventory:
519 maps, 75 pairs, 495 enabled scenes, 112 maps with matched fixtures and
1,570 instances. The fixture count includes wall panels, not just furniture.
This is not all-map visual approval. Room corners/returns, other window/door
families, live exterior window views and other games' unfinished coverage
remain open. Full-world coverage and parity are NOT complete. No release.

# Fortree and Hoenn home furniture — 2026-10-04 (unreleased)

Ten additional complete patterns model 27 previously flat furniture instances:
Fortree central tree supports, drawers, cabinets, appliances, two shop counters;
rustic bookcase, low glass cabinet, appliance and empty table variants. All six
Fortree interiors now have matched furniture. Eleven existing rustic cabinet
instances used a bookshelf model despite native glass-front art; they now use
closed cabinetry with the original fronts and separate worktops. Reviewed
Fortree orange siding bands stand vertically. Edge/diagonal wall drawings still
need authored transitions; room-shell fallback is not native-art completion.

The central support is one closed twelve-sided trunk matching the complete
2x4 source drawing, not repeated small trees. Removed an overlapping internal
box top after rendered QA exposed z-fighting. Furniture uses native artwork
and separate depth-bearing structures. Partial tree drawings cannot claim the
whole model. Atlas, primary, edition and blocked-wall guards remain required.

QA: official 0.3.51, isolated Emerald fresh fixture, native source diagrams in
`.scratch/coverage-20261004/homes-source.lua`; before/after/final/view fixtures
cover Fortree houses 1/2, decoration shop, Fossil Maniac house and Lilycove motel
2F in overview/orbit/first-person. Original map/collision arrays unchanged.
Inspected first-person shop, Fortree overview, Fossil house and motel
overviews. House 2 first-person remains obscured by an NPC even after moving
the fixture camera one cell sideways; this is NOT a first-person sign-off
for that cabinet. No collision/gameplay changes or user saves.

Focused tests: 315 designed objects, 124 Hoenn recipes, native wall scope,
partial-support rejection, enclosure and starting/additional furniture pass.
Full Emerald source census: 519 maps, 75 pairs, 495 enabled scenes, 111 maps
with matched furniture, 1,512 objects. This census is NOT a visual sign-off.
Remaining gaps include Fortree wall corners/returns, source windows/doorways,
other interior/exterior fixtures and unresolved settings adapters. All-game
coverage/parity remain unfinished. No version bump or release.

# Native shortcuts and Fallarbor rock coverage — 2026-10-04 (unreleased)

Gen3 now handles Gen1 shortcuts 5 (grid), 7 (curve), 8 (staged battles),
and 9 (water), using the existing live settings/persistence. Field gates
prevent changing these during battles/locked field sequences. Existing 3/6
camera and tilt shortcuts remain available in their prior contexts; all six
now defer to explicit gameplay bindings and key-binding capture. Native
pressed/released calls verified persistence in FireRed, LeafGreen and Emerald
on official 0.3.51. Unit tests cover release non-repetition, binding ownership,
locked-field rejection and quest/battle camera/tilt behavior. No physical
keyboard/controller claim from these driver calls.

Added the three omitted CommunityVisuals options to the support inventory:
SAFARI ZONE, KANTO AMBIENCE and BUILDING STYLE. Gen2/3 remain explicitly missing
until adapters are audited. Regression checks require every CommunityVisuals
setting to appear in the inventory; 437 native consumer checks pass.

Emerald's Fossil Maniac tunnel uses general__fallarbor and INDOOR rather than
CAVE. Its exact native map identity now receives cave walls/ceiling; shared
Route 114 and unrelated indoor Fallarbor maps stay outside that exception.
Seven reviewed blocked brown cliff drawings use joined rock terrain with
native cap/face/sand samples. Walkable copies, blank border, sand and small
rock decorations are excluded. These cliffs also cover shared Route 114 art.

QA: isolated `.scratch/coverage-20261004/{field-hotkeys,fossil-source,
fossil-before,fossil-after,fossil-final}.lua`. Inspected original source art,
before/after tunnel first-person and Route 114 overview. Three-map fixture
(tunnel, Route 114, adjoining house) asserts unchanged native layout/collision.
Hotkey, Hoenn scope/recipe, enclosure and native consumer suites pass.
User saves untouched. No version bump or release. Full-world coverage and
parity are still unfinished: tunnel small rocks/mixed edge cells, other maps'
geometry, capture effects and unsupported option adapters remain outstanding.

# Native enclosure, forest controls and museum coverage — 2026-10-04

Unreleased. Emerald General-primary indoor families now retain the shared
room enclosure/cutaway/first-person ceiling. Census: 33 newly eligible rooms
across facility, bike shop, contest, ship, Frontier reception/Palace, truck and
battle tent families. Map type alone was unsafe: weather-suppressed event
islands and ferry docks also report INDOOR. Preserve the explicit family guard;
all ten such FRLG exterior candidates remain open, as do Hoenn event islands.
Gen1/2 ownership is unchanged. This is not visual approval of all 33 rooms.

Petalburg Woods and native FOREST environments reach the shared forest effect
controls. Stable key communityForest now displays FOREST STYLE across all
three generations. Official 0.3.51 Emerald native options events verified
LOW/OFF/default consumers and rendered forest without changing defaults.

Eight Oceanic Museum source patterns now cover cylinder/glass exhibits,
terminals, two display islands with modeled ship/parts, wall cases and a
solid divider. Native yellow/blue plain wall bands stand vertically. Source
crop ends before carpet/shadow pixels; initial material/crop problems were
corrected against native pixels and first-person renders.

QA: `.scratch/coverage-20261004/{museum,forest-options,room-census,
palace-source}.lua`. Museum/Space Center/Devon fixture retains identical native
map/collision grids. Inspected museum overview and final first-person; Palace
native room diagram checked against enclosure eligibility. Final census:
Emerald 519 maps / 406 enclosures / 33 added; FireRed 426 / 340 / 0 added;
LeafGreen 426 / 337 / 0 added. The FR/LG count difference has not been fully reconciled; this census
is not a visual sign-off.
305 designed objects, 114 Hoenn recipe/family checks, native atmosphere,
interior enclosure/exterior exclusions and 399 native consumer checks pass.
No complete full-world coverage or settings parity claim: museum counters,
other exhibits/stairs, unreviewed geometry, capture effects, sprite-pack and
remaining native scenery controls still need work. No version bump/release.

# Hoenn science rooms — 2026-10-04 (unreleased)

Added native Space Center/Devon workstations (separate CRTs, keyboards and
open-legged tables), plan tables, pedestal stools, inclined control banks,
window/wall bands and upper-floor railings. Twenty pair-scoped recipes map to
51 actual furniture instances across the complete Emerald inventory; recipe
counts include alternate general/building atlas guards, not twenty new types.
Eight complete facility stair patterns use recessed up/down flights with their
own gray/red materials and floor; native landing behavior remains required.

Official 0.3.51 isolated `science-source.lua` source diagrams and `science.lua`
render fixture under `.scratch/coverage-20261004`. Both Space Center floors
and Devon 2F render in static/orbit/first-person; layout and collision unchanged.
Inspected Space Center overview/first-person and Devon overview after fixes.
The rear Devon capture faces out of the room and is NOT a rear-model sign-off.
Focused suites: 297 designed objects, 106 Hoenn furniture recipes, 68 stair
patterns, plus starting/additional/Center/depth-furniture tests pass. The old
astra_furniture_support test needs ASTRA_FURNITURE_BASELINE and was not run.

Emerald inventory remains 519 maps / 75 atlas pairs, 495 supported scenes,
103 maps with matched furniture, 1,468 matched furniture objects (before the
last stair additions; furniture total unaffected). This is a coverage census,
NOT all-map visual approval. Remaining science-room gaps include stair-adjacent
wall returns, Devon 1F/3F fittings, museum exhibits and room boundary completion.
Full-world tile coverage and feature parity remain unfinished. No release.

# Option parity checkpoint — 2026-10-04 (unreleased)

Gen3 now consumes BACK PLACEMENT for both allied Pokemon: AUTO/WORLD project
into the scene; OG UI keeps the native slots, without duplicate world cards.
The existing native setting list exposes and synchronizes it. Gen3 also
supports the Gen1/2 `6` blur hotkey. GB support inventory now supplies a real
pipeline-owned blur row instead of a read-only placeholder; it deduplicates
the engine row and retains pipeline persistence/preset ownership.

Official 0.3.51 isolated boots: Yellow/Crystal actual options-row change,
persistence and restoration passed; FireRed/LeafGreen/Emerald battle modes,
real editable settings row, persistence and press/release hotkey checks passed.
FireRed OG UI screenshot inspected. Doubles slot ownership verified by unit
tests, not a new live double battle. Five focused unit suites pass (including
399 native consumer checks and 17 Gen2 battle-option checks).

Full parity is NOT complete. OptionSupport source audit currently reports
Gen2: 46 implemented, 29 partial, 13 missing, 2 provider, 2 not applicable.
Gen3: 43 implemented, 7 partial, 40 missing, 1 provider, 1 alias.
These are option counts, not device/rendering verification percentages.
Remaining: Gen2 capture-ball FX/audio; Gen3 those effects plus original
Legendary scenery control adapters, Crystal-style sprite-pack controls,
RAM precache and standing trainer. Native atmosphere and UI also retain
explicit partial entries. Do not enable empty controls or silently claim parity.
Scratch fixtures/results: `.scratch/coverage-20261004/{options-parity,
gb-option-parity}.lua` and `results/*-*-parity`. Latest terrain work remains
unreleased too. No cart/mod version changes in this checkpoint.

# Native terrain topology — 2026-10-04 (after 1.31.0)

Recognize Emerald normal-behavior stair drawings, including Meteor Falls; stop
reading its seaweed behavior as FireRed stairs. Shared minimum-rise topology
handles unequal flights and south-up mound access; Fortree bridge decks no
longer merge side crossings. Mesh revision 86 refreshes retained Gen2 geometry.
[Evidence, census and limitations](docs/TERRAIN_LEVELS_2026-10-04.md).
All 1,759 Gen2/3 imported-map fields build without height conflicts. Gen1's
existing native profiles are retained. Walk/camera tests pass; full-world visual
coverage and complete under-bridge actor-layer rendering are NOT claimed.

# Crystal station fittings — 2026-10-04

Goldenrod/Saffron station seats now have native yellow cushions, backrests,
arm supports and feet; platform fences have separate posts/open gaps, and
entry rails have closed cases. Three complete source patterns, floor retained.
Official 0.3.51 isolated `crystal-station` fixture completed both stations;
inspected Goldenrod overview/first-person. 277 designed-object and furniture
source-bound guards pass. Train body/track presentation and complete station
wall detailing remain unfinished. No gameplay/train travel validation or release.

# Native houses, Tower walls and Crystal cabinets — 2026-10-04

Added eight Hoenn house patterns (50 total), Verdanturf stone fences, native
opening details, connected Pokémon Tower wall returns/reception counters, and
four Crystal Game Corner cabinet/stool recipes. Corrected Hoenn cliff-band
false positives. [Evidence and remaining gaps](docs/NATIVE_COVERAGE_2026-10-04.md#second-modeling-pass).
Official 0.3.51 isolated renders; full suite 112 pass / 11 existing fail / 85 skip,
with focused checks repeated after final cabinet/cliff adjustments. Unreleased.
Every-tile visual coverage, live window portals and complete terraces remain open.

# Native coverage checkpoint — 2026-10-04

Completed another modeling/correction batch across Emerald and FRLG, including
native gym objects, Game Corner cabinets, Seven Island furniture, more Hoenn
buildings and scenery. [Scope, QA and explicit remaining gaps](docs/NATIVE_COVERAGE_2026-10-04.md).
Full suite 111 pass / 11 known fail / 85 skip; focused final checks pass.
Every-tile coverage is unfinished; no cart/mod release for this checkpoint.

# Native window fidelity — 2026-10-04

Removed invented luminous side-wall windows from the shared room shell;
recessed Emerald house windows now match native frame/glass proportions.
[Research, QA and remaining exterior-view work](docs/NATIVE_WINDOWS_2026-10-04.md).
Actual live exterior-map portals are not implemented. Keep this limitation
explicit; painted sky panes are not equivalent. No release for this change.

# Emerald stair artwork correction — 2026-10-04

Replaced the new freestanding gray Littleroot stairs with native golden treads
inside a framed wall recess. Separate up/down materials avoid sampling the
purple outline as wood; closed jambs/lintel/returns replace tall banisters.
Native layout, warps, collision and actor movement remain untouched.

Official 0.3.51 isolated Emerald fixture: `.scratch/coverage-20261004/starting.lua`;
results in `results/emerald-starting`. Inspected Brendan 1F overview/first,
Brendan 2F overview/first and May 2F overview. All four house fixtures completed
and asserted unchanged native grids. Stair tests: 32 up / 28 down assemblies;
Crystal stair/foundation guards also pass. This is not an all-games stair visual
sign-off. Descending steps are naturally hidden below floor level at a level
first-person view. Other uncommitted coverage work remains in the checkout;
do not mistake it for a reviewed release. No new release for this correction.

# Shared houses and department stores — 2026-10-04

Post-1.30.0 main work: 15 Emerald house recipes add 298 fixtures across 46 more
maps; Crystal store benches/vending machines and FRLG demo tables/display
islands are modeled. Removed false Celadon floor-to-merchandise recipes.
[Evidence and remaining coverage](docs/HOUSE_STORE_COVERAGE_2026-10-04.md).
Official 0.3.51 render fixtures; standalone tests 111 pass / 11 known fail /
85 skip. No new release yet. Full-world coverage remains unfinished.

# World battle projection and Littleroot models — 2026-10-04

Battle Art 1.30.0: native Gen3 actors/effects use pooled transparent cards in the
world depth/shadow pass. Gen1/2 battle ownership is unchanged. See
[QA and remaining coverage](docs/WORLD_BATTLE_2026-10-04.md). Native source
artwork remains ROM-derived at runtime; no art/caches/captures are committed.
Work lives on main. Scratch fixtures: `.scratch/world-battle-20261004`.

# Emerald and modeled architecture release — 2026-10-04

Battle Art 1.29.0 integrates upstream 1.11.1, native Emerald scenery recipes,
modeled building openings/roofs, Center/Mart furniture and corrected Gen3
far-side battle sizing. See [the evidence and remaining work](docs/EMERALD_QA_2026-10-04.md).
Current engine: official 0.3.51. Release set: Battle Art 1.29.0, Wilds 2.5.0, Online 0.9.0, Ride 0.5.0,
Doubles 0.13.0 and Skies 1.14.0; all target main. Carts: Crystal 1.22.0,
Yellow 1.10.0, and FR/LG/Emerald previews 0.9.0. Isolated Linux profiles only; no user save edits.
Do not interpret older upstream handoff entries below as the current branch,
version, test environment or completeness claim.

# Desktop Test134 integration - 2026-09-30

Integrated all Test134 code from `C:/Users/User/Desktop/Test134` into this
desktop checkout on the existing `1.11.1` branch, starting at `5e9f650` with a
clean working tree. Local uncommitted integration only; no branch switch,
commit, push, deployment, release, deletion, or version bump. Manifest and
exported version remain 1.11.0, as they were on this branch before the merge.

Imported 121 changed/new Lua files (33 replacements, 88 additions), covering
city architecture, forest/Safari presentation, water/surf/battle placement,
ambience and sky/scenery. Added 13 supplied media/credit files locally under
the existing ignored `assets/legendary/` path. Preserve those asset exclusions;
these files are not included by ordinary Git staging. Kept destination-only
files, existing README/changelog, manifest, packaging exclusions and tests.
Donor validation captures/history were not imported into the project.

Normalized comparisons and three-way preparation against `a26364d` produced
no conflicts; incoming code already retains the subsequent cut-tree regrowth
repair and current exported version. Test134 source files were not edited.
`.claude/test134-merge/` holds exact before-file backups, starting commit,
SHA-256 inventory/actions, preparation/apply scripts, review diff and validation
results. The handoff's original contents are backed up there too.

Checks performed here: LuaJIT 2.1 compiled all 241 production/data Lua files;
mocked hosted-trainer visibility, atmosphere companion integration, Lavender
approach visuals (216 checks), and mesh disk format/migration (40 checks)
passed. Supplied Test134 sky and scenery/runtime checks and all 12 filtering
and API-refusal configurations passed against this merged checkout.
Git whitespace validation passed. These are compilation, static and mocked
checks, not inspected game rendering or GPU shader validation.

Incomplete checks: battle sidecar, Stadium model API, Legendary profile and
migration, and city-ground suites stop on old mocks lacking newly introduced
modules/settings (SafariReserve, SafariFooting, new preset members). Water
reflection/precision suites require missing `tests.modkit`; cut mesh suites
require missing engine `src.render.Assets`. The donor fallback comparison
requires its absent `../test131-work` baseline. Exact errors are preserved in
the scratch validation.json; no tests or production behavior were weakened to
make them pass. These suites need updated fixtures/full engine validation.

Not verified: live gameplay, game rendering, GPU shaders, companion-on/off,
battle/capture/naming, movement and 2D fallback, or Android. The documented
`D:/gen1recomp` engine is absent. No executable, game/save/slot/map/camera
fixture was launched, no screenshots were generated, and no game processes,
player saves, options, installed mods or environment settings were changed.

## Working-tree recovery, 2026-09-29 — read this first

At 14:07 the checkout was found with 20+ files unmerged and full of
`<<<<<<< Updated upstream` / `>>>>>>> Stashed changes` markers, so the mod
stopped parsing (`main.lua:723: unexpected symbol near '<'`). **This was not a
merge anyone started with git.** The evidence:

- `.git/AUTO_MERGE` existed but there was no `MERGE_HEAD`, no `REBASE_HEAD` and
  no `sequencer` — so no merge or rebase was actually in progress, yet the index
  held stage 1/2/3 entries for 24 paths.
- The stage-2 ("ours") blob for `main.lua` was git's **empty-file** hash
  `d41d8cd9`, which a normal merge never produces. Stage 2 was otherwise
  byte-identical to `main`, and stage 1 to `ORIG_HEAD` (`9021702`, already an
  ancestor of `main`).
- Stage 3 matched `main.lua` as of the tip of `Legendary-Additions` (`1b7eb90`)
  — which `git merge-base --is-ancestor` confirms is **already merged into
  `main`**, so merging it again has nothing to merge.
- The reflog contained no merge and no commit other than this work.
- `master` is an *ancestor* of `main` (93 commits behind), not a source of it.

Every conflicted path was verified to contain **only** conflict markers and no
real content, so nothing was lost. Recovery, in order:

1. Full `git bundle create --all` backup, plus the index, the unmerged stage
   hashes, `refs.txt`, the stash list, and a copy of every damaged file, under
   `/tmp/opencode/bav-recovery-*/` (108 MB, bundle 95 MB).
2. Saved the two intentional uncommitted edits as a patch.
3. `git reset --hard f4feaec` — returned the tree to the verified commit.
4. Re-applied the two edits, removed the stale `.git/AUTO_MERGE`, and
   re-verified: 114/114 on the Gen 2 shape suite, grass suite green, `git fsck`
   clean, `stash@{0}` untouched.
5. `stash@{0}` ("Crystal FireRed HD2D work before absol89 1.11.0 merge") was
   never popped, applied or dropped, and remains intact.

**Lesson worth keeping.** Another coding agent was running concurrently in this
workspace (on a different project). A second writer in one checkout is the most
likely cause of a conflict state that git itself did not create. If
`git status` ever shows unmerged paths while the reflog is empty, do not run
`git merge --abort` — there is no merge to abort. Check whether a second agent
is live, back up with `git bundle create --all`, and reset to a known-good
commit.

## 1.28.17 — The suite, measured properly

Where this started, with an engine root on `LUA_PATH`: **112 passed, 90 failed**,
and 90 that nobody had looked at in months. Where it is: **128 passed, 74
failed** with an engine; **106 passed, 11 failed, 85 skipped** standalone, which
is what CI sees.

The gap between those two numbers is the point. Standalone, 21 suites need the
**engine's** `tests.modkit`, which lives in the engine checkout and is not in
this repository — they cannot run at all without it, and the runner was counting
`module 'tests.modkit' not found` as a failure. They were never broken; they
were being measured by a harness that was not there. Those are SKIP now.

Of what genuinely runs without the engine, 21 of the original 32 are fixed, and
**every one was a fixture or a stale expectation, not a defect in the mod**:

- 9 loaded a mod module with `loadfile` and a hand-kept list of sibling names,
  or answered an unlisted one with `{}`. `tests/modload.lua` now resolves them
  off disk the way the installed loader does.
- 4 were pinned to values that moved: `CACHE_REVISION == 37` when it is 81, "all
  seven community rows" when there are 23, a GLSL blend factor renamed when its
  mix gained a range guard, and a suite that `sync()`d settings without
  selecting LEGENDARY VISUALS' CUSTOM mode, so the getter overrode them by
  design.
- the rest were fixtures missing a field the module had started reading: a
  tileset with no `blocks`, a map with no `id`, a `Voxel3D` stub with no
  `metalRenderer`/`battleOcclusion`, a `ModSetting` stub with no `key`.
- `Sky._source()` had stopped being exposed, so the sky assertions could not
  run. Restored, matching `Water._source`, already annotated "named for the
  suite".

The 11 still red without the engine are each a different thing and none is a
fixture: `battle_art_voxel_fork_test` (423 locals, past LuaJIT's 200 ceiling and
never once compiled), `retaining_cave_corner_test` (needs `ASTRA_GENERATED`),
and nine real assertions to investigate — `scenery_polish_test:5`,
`choose_your_hero_test:68`, `gen3_adapter_test:29`,
`companion_main_uninstall_integration_test`,
`stadium_hosted_extras_test:27`, `legendary_cave_merge_test:5`,
`legendary_tree_runtime_test` (`CommunityFlora.setting`),
`voxel_companion_api_v1_test:284`, `test56_interiors_options_test`.
`water_effect_precision_test` is green now that it is correctly classified as
engine-harness-dependent, and the feature it wants -- a pinned/bare two-form
water shader with a fallback chain -- has still never existed.

## 1.28.16 — Five test suites had drifted into being dead

`voxel_visual_object_filter` — 3,388 checks, the mod's second-largest suite —
had been failing with `unexpected Structures module CommunityVisuals`. So had
`battle_scene_visual_sidecar`, `ram_precache_setting`, `cut_mesh_refresh` and
`grass_east_edge`, each for the same reason in its own way.

Every one loaded a mod module with `loadfile("lib/X.lua")` and a hand-kept list
of the sibling names that module may `require`. **The installed loader always
passes the mod namespace**, so `V.require` resolves in the game and is nil in the
test. Each list was several modules out of date, and the failure surfaced as a
nil-index error inside a module the test never claimed to cover.

`tests/modload.lua` resolves siblings off disk the way the loader does, with
explicit overrides where a test deliberately substitutes a fake. The deliberate
substitutions stay and are ordered first: `Voxel3D`/`VoxelMeshDisk` in the
visual-object test are stubbed because it supplies a fake format which cannot go
through the renderer, and the fake `Mat4`/`DayNight`/`VoxelState` in the
companion namespace are that test's whole point.

Four fixture gaps were hiding behind the crashes and are fixed rather than
worked around:

- two `Voxel3D` stubs had no `metalRenderer` or `battleOcclusion`
- the visual-object fixture's tileset had no `blocks`, which `Structures` reads
  the border block out of (`Structures.lua:919`)
- `cut_mesh_refresh`'s map had no `id`, which the cache and job queue key on
- `grass_east_edge` pinned `CACHE_REVISION == 37` and it is 81 — 1.28.9 alone
  moved it past 80 as models changed, each bump invalidating stored geometry on
  purpose. Pinning the number made it a tripwire for every unrelated model
  change, so it now asserts what is actually protected: a current revision, so a
  cache written here cannot be read back by an older build.

One subtlety worth keeping: the `ChunkMesher` and `VoxelCompanion` namespaces
must be handed the **same** `Structures`/`TileShape`/`BuildBudget` instances the
test already holds. Fresh copies keep their own caches, and the mesher and the
test then disagree about what was claimed — which is how the first attempt at
this failed on "the canonical colour variant includes the sign".

Suite 123 passed / 79 failed with an engine; 105 / 35 / 62 standalone. CI
baseline 38 → 35, and the Tests workflow is green.

## 1.28.15 — A map connection is not a wall

`voxel_seam_ao_test` had been failing at every ref that could be checked
(`71065e0`, `1b7eb90`, and `046dd33`), so it is old rather than new — but the
defect is real and the test states it precisely.

The border ring is meshed `RING` tiles deep all the way round. At a **declared
connection** the body's own edge is therefore flanked by ring cells, and
counting those as tall neighbours occlusion-shaded the seam. On open water —
the one surface in the game with no art to hide behind — the band reads as a
shadow floating on the sea.

Two places needed the rule, and the second was the one that mattered:

- `aoShades` (top faces) now reads `aoHeightAt`, which at a seam returns the
  height of the **body cell the seam continues**, not the ring's own. Reading
  the ring directly reports 0 on a map with no elevation field, which makes a
  water surface look like it sat in a pit.
- `renderHeightAt` (the sides pass) returns the continuing water height at a
  seam, so a body edge never builds a face against open terrain at all. That
  face was the thing doing the shading.

`renderHeightAt` was the one that mattered because the shaded quads are the
*body's own east face* drawn against the ring, not the ring shading itself.
Once it stopped being built, the test's other three assertions — walled edges
still shade, the seam carries water corners, and the two-crowder step is
exactly `1 - 2*AO_STEP = 0.568` — all hold. 5/5.

The rule is scoped to `map.def.connections`, so this is the connection and not
an amnesty for every cell on a map edge.

**What could not be shown.** No real connected map changes above the noise
floor. `CELADON_CITY` is the only Gen 1 map in this build with real
`east`/`west` connections and its body is land, where the ring was never taller
than the body, so the rule has nothing to do — 0.14–0.22% against a 4.53%
noise floor. Pallet reads 35–44% but that is foliage animation (measured: 34.68%
and 49.86% between two runs of the *same* build), and the diff crop shows the
bush at a different frame with the ground, walls and fence pixel-identical. So
the fix is verified by its own fixture and by a clean full-suite run, **not** by
a before/after capture in the game. Reported as such rather than dressed up
with a capture that shows nothing.

Suite 118 passed / 84 failed.

CI is green on this commit, and the contract is a baseline rather than zero.
The first workflow push went red on the 38 pre-existing failures, which says
the suite has a known tail, not that it had regressed. `tools/TEST_BASELINE`
holds that count as a **ceiling**: a new failure fails the run, a fixed one only
lowers it. Verified both directions -- at 38 the runner exits 0, and with one
test deliberately broken it exits 1 with "39 suites failed, 38 are
known-failing". Standalone CI sees 103 passed / 38 failed / 61 skipped; with an
engine root it is 118/84.

## 1.28.14 — Orb plinths are two masses again

The four `orb_plinth` recipes (`gym_orb_plinth`, `champion_orb_plinth`,
`tower_gym_plinth`, `tower_round_brazier`) had resolved to **zero parts** and
rendered as one tall featureless slab, ever since 7712542 grouped `orb_plinth`
with `boulder` and gave it the `native_rock` path with no `modelShape`.
`gen2_reviewed_scenery_test:20` caught it and had been red since.

A plinth is two masses: the pedestal it stands on and the orb above it, with the
drawing's waist between them. One `VoxelHull` over the whole crop welds them
into a single block. The crop is **correct** and must not change — the earlier
suspicion that `left={0,0,2,4}` missed the drawing was wrong, and measuring
real placements showed the alternative `{2,0,2,4}` is the tileset's uniform
filler (3436 matches on 18 maps against 4 real ones, all `2/2 2/2 2/2 2/2`).

- `Gen2FurnitureTemplates` gives `orb_plinth` its own `modelShape` and two
  parts, with the upper one carrying the silhouette flag the test asks for.
- `Gen2VoxelRock` carves the mask **twice**: the row the mask is thinnest at is
  the waist, and each half gets its own sub-mask, so the gap in the drawing is
  a real gap. The orb's hull is raised by however tall the pedestal came out,
  so it stands *on* the pedestal rather than intersecting it.

Measured placement counts (how the camera was aimed, since a survey cell
nearby shows 0.00%):

| recipe | placements | example |
| --- | --- | --- |
| gym_orb_plinth | 18 in 9 maps | BLACKTHORN_GYM_1F (3,14), GOLDENROD_GYM (2,1) |
| champion_orb_plinth | 2 in 1 map | OLIVINE_GYM (3,12) |
| tower_gym_plinth | 4 in 2 maps | ECRUTEAK_GYM (3,14) |
| tower_round_brazier | 5 in 3 maps | — |

Rendered before and after at three real plinths. Olivine Gym, Ecruteak Gym and
Blackthorn Gym 1F each change 24–25%; the earlier near-miss survey cells change
0.00%, because they were not near a plinth — the first attempt at this fix
measured 0.00% everywhere and that was a bad camera, not a no-op. The other ten
survey scenes are bit-identical, so nothing else moved.

Inspected: the gym plinths now read as a red orb resting on a grey carved
pedestal with a visible gap, two per gym, instead of a black slab. The tower
brazier and the Champion's Room plinth are built by the same path.

Suite 117 passed / 85 failed.

## 1.28.13 — Gen 3 boulders, and a suite that finally runs on every push

### `Gen3Cave.rock` carved the whole metatile, not the boulder

`gen3_rock_silhouette_test` was failing on `ts={}`: `rock` has read the UV slot
off the tileset (`midToSlot`, `cols`, `imageData`) since ea4f076, so the fixture
had stopped being a fixture. With a real tileset supplied, the defect it was
written to catch appeared: `rock` built a `VoxelHull` over the **entire
16×16 metatile**. A metatile draws its boulder in the middle with a wall behind
it, so the block came out as wide as the artwork, carrying the disconnected
floor stripes and dirt grit that `boulderMask` had already rejected.

The ring builder this replaced trimmed every row to its own extent. ea4f076
dropped that when it swapped rings for a hull. The hull now covers the mask's
**own bounding box**, so the silhouette decides the size again.

Two details the assertion found rather than code review:

- `VoxelHull` emits a block spanning `[-w/2, w/2]` and computes `height =
  h - bottom`. Passing `bottom = h` — the obvious reading of "it is this tall" —
  zeroes the height and emits **nothing at all**. `bottom` is the empty rows
  *below* the shape: `15 - maxY`.
- The block is re-seated by its **centre** (`minX + hw/2`), not its minimum, or
  the boulder sits 8px off its artwork.

Verified by rendering before and after: Pewter Gym (the map the test models)
plus Saffron Gym, Viridian Forest, Route 9 and Mt Moon B1F. Only Pewter moves
(2.44%) and its boulders keep their shape and placement; the other four are
0.00–0.52%, with Mt Moon's being its water animation.

### `gen3_outdoor_test`: two faults, both in the test

It loaded `Gen3TileShape.lua` and `Gen3Outdoor.lua` via `loadfile(...)` with no
argument, so the mod namespace arrived nil and every `V.require` inside them
raised. Fixed by passing a resolver — which needs `local V` declared *before*
the table literal that closes over it. `local V = { require = function() ...
V ... end }` makes the inner `V` a different, nil local and reproduces exactly
the error the guard was added to remove. Worth stating rather than leaving to
the next reader.

It then read a missing camera anchor as a lost root for all three plant
drawings. They are three different things (`Gen3TileShape.lua:73`):

| mid | shape | correct output |
| --- | --- | --- |
| `4` | flowers | one anchored card, full 16px |
| `5` | shrub | carved `VoxelHull`, many un-anchored faces (`ROCKS & PLANTS` defaults to `modeled`) |
| `0xD` | grass | flat ground plate at `.025` (un-anchored) **plus** an anchored tuft |

`[5]` made the old "one native drawing became multiple cards" assertion
unsatisfiable, and `[0xD]` is the same two-mesh split that made
`gen2_depth_style_test` stale one release earlier. Each is now asserted on its
own terms. `tests/low_grass_test.lua`, which already pinned the 1.27.1 intent,
still passes unchanged.

### The suite now runs on every push

`tools/run_tests.sh` plus `.github/workflows/tests.yml`. Standalone it reports
**102 passed, 39 failed, 61 skipped**, and the split is honest: the 61 skipped
are the `astra_*` A/B harnesses and `palettes_gbc` fixtures this repository
does not carry; the 39 are real. With an engine root on `LUA_PATH` (as in a dev
checkout) it is 116 passed / 86 failed.

The 31 suites that need `src/` are reported as SKIP, not FAIL, when no engine
root is given — otherwise a missing checkout would read as a broken build.

The workflow also compiles every production module and runs `git diff --check`,
both verified locally. There is still no engine checkout, so those 31 suites
remain unrun in CI; wiring that up needs an engine repository reference that
does not exist in this workflow yet.

Suite went 112 → 116 passing across this session.

## 1.28.12 — Cave ladders: a stale test, and one piece of dead code

`cave_ladder_test` had been failing 17 checks since c22a6a6 (1.24.0-test.1,
Sep 23). That commit split the Gen 1 CAVERN ladder pin in two:

```
-      ladder = { 10, 11, 26, 27, 8, 9, 24, 25 },
+      ladder_up = { 10, 11, 26, 27 },
+      ladder_down = { 8, 9, 24, 25 },
```

which is a real change, not a rename. `Structures.buildStairs` reads
`s.class == "ladder_down"` to decide a cell is the **hole** rather than a riser,
and routes both to `CaveLadders.build`, which carves a shaft: a rim, four
walls, a floor and the source rails and rungs voxelised into it. The test still
asserted the undivided `ladder` class with `art == "billboard"`, so it demanded
the standee path that no ladder takes any more.

**The code was right and the test was stale.** Verified by rendering the real
thing: four live Gen 1 warp cells in `CERULEAN_CAVE_1F` (two `ladder_up`, one
`ladder_down`) captured in `close` and `first` at IN2 —
`results/yellow-ladders/`. Ladders read as a shaft with a rim and a visible
opening, which is what the source drawing shows. The test now pins the split
pins, `art == "stair"` as the routing condition, and both `ladder_up` and
`ladder_down` at 16.

Removing the test's other assertion surfaced genuine dead code: `PINNED_DEPTH`
had `ladder = 2`, but that table is only read for `art == "billboard"` shapes
(`Structures.lua:4001`), and a warp ladder is `art == "stair"`. Nothing could
reach it. Removed. The two-voxel carve the entry described still happens, in
`CaveLadders`' own `fill` calls, so it is now asserted by **building a shaft**
and counting the distinct z planes its quads span (1 or 2) rather than by
reading a table that no longer participates. A source-text grep was tried first
and rejected: it would keep passing if the code stopped carving.

Re-rendered all four ladder cells after the change: six of eight captures are
bit-identical, and the other two (1.48% and 0.37%) sit at the run-to-run noise
floor for the same scene (0.89% and 0.49%) — animated water and actor frames.
`PINNED_DEPTH` losing a key that nothing read cannot move pixels, and the
measurement confirms it.

46 checks. Suite 114 passed / 88 failed, up from 112/90.

### Three failures that are NOT regressions, and should not be "fixed"

Checked each against `046dd33` (before this session's work) and against the
handoff's own record. All three fail identically at that commit, so none is
something this work introduced:

- **`water_effect_precision_test`** — expects a `EFFECT_PREC` macro with a
  pinned and a bare shader form, tried in order. `EFFECT_PREC` **has never
  existed** in `lib/Water.lua` (0 occurrences at `71065e0` either), and
  `Water.shader` compiles one form. The test describes an unimplemented
  fallback, not a broken one. `PROJECT_HANDOFF.md:1017` already records this as
  "a legacy failure ... IDENTICAL with HEAD Water.lua. Not a new regression."
  The current signature
  (`vec4 effect(mediump vec4 color, Image tex, mediump vec2 tc, mediump vec2 sc)`)
  does satisfy the test's *intent* — every float slot qualified together,
  sampler left alone — just inline rather than through a macro.
- **`scenery_polish_test:5`, `choose_your_hero_test:68`, `gen3_adapter_test:29`,
  `legendary_cave_merge_test:5`, `legendary_visuals_test:48`** — all fail
  identically at `046dd33`.
- **`heal_overlay_test`** wants `data/palettes_gbc.lua`, which this checkout does
  not have.

Of the 88, ~59 are `astra_*` A/B tests needing `ASTRA_GENERATED`/`ASTRA_FULL_BASELINE`,
~22 are the `V`-less `loadfile` module-drift cases already described above, and
`battle_art_voxel_fork_test` cannot compile at all (LuaJIT's 200-local ceiling).

## 1.28.11 — Gen 2 grass test was stale, not the grass

`gen2_depth_style_test:59` ("grass illustration is no longer flat") was the
other real suite failure. It is a **stale assertion, not a rendering bug**:
1.27.1 (cae8ee7) deliberately split a grass patch into two meshes — the flat
meadow plate the blades stand on, and the upright blades — and added
`tests/low_grass_test.lua` to pin the new behaviour. It did not update
`gen2_depth_style_test`, which still asserted every emitted quad was at
`z == 4`, a shape that only a single-mesh patch had.

The test now pins both halves from both sides: a plate must be flat at
`y == .025` with no canopy anchor, blades must stay upright at `z == 4` with
one, and each source run must contribute exactly one of each. This is the
second time this suite caught a stale expectation rather than a real defect
(the first was `Gen2Elevation`); both went unnoticed for the same reason --
there is no CI runner, so nothing is red until someone runs it by hand.

`tests/low_grass_test.lua` still passes unchanged, which is the check that
1.27.1's intent is intact.

### Backlog, measured rather than estimated

Regenerated the native tile ledger with the 0.3.22 runtime (388 Crystal maps,
426 FireRed/LeafGreen). Unreviewed volume, by treatment:

- **Crystal**: 24,719 generic-wall cells across 1,114 distinct drawings in 34
  tilesets, plus 592 classified-ground and 230 modeled-prop rows. Largest
  clusters: `TILESET_DARK_CAVE` 4,043 cells / 21 drawings, `TILESET_TOWER`
  3,481 / 27, `TILESET_LIGHTHOUSE` 2,452 / 45, `TILESET_CAVE` 2,392 / 21,
  `TILESET_GATE` 1,404 / 11, `TILESET_KANTO` 1,369 / 60,
  `TILESET_ELITE_FOUR_ROOM` 1,335 / 29, `TILESET_UNDERGROUND` 1,274 / 20.
  The single largest drawings are uniform fills: `TILESET_TOWER 1:1:1:1`
  (1,412), `TILESET_DARK_CAVE 38:38:38:38` (1,318), `TILESET_GATE 0:0:0:0`
  (1,040), `TILESET_LIGHTHOUSE 1:1:1:1` (814).
- **FireRed/LeafGreen**: 74,506 unreviewed cells across 6,844 drawings, plus
  297 unmatched-building cells. 6,844 of those rows are `kind=flat` interior
  and outdoor surfaces, not walls — 38 Pokemon Center floors, 50 house floors,
  the Sevii/Mt Ember ledges, the Tanoby Ruins floors. Top rows:
  `general__rom_082d4bfc $2F2` (Mt Moon B1F, 1,672),
  `building__rom_082d4efc $281/$282` (Pokemon Tower 1F, 2,234 across 7 maps),
  `network $281/$008` (Pokemon Center 1F, 1,994 across 38 maps),
  `building__rom_082d5094 $008` (Trainer Tower 1F, 1,108 across 9 maps).

These are classification counts, not visual approval, in both directions: a
reviewed row can still look wrong, and an unreviewed row can look fine.

### Confirmed root cause: background filler is being built as wall mass

`TILESET_LIGHTHOUSE` (`OLIVINE_LIGHTHOUSE_1F/2F`, `FAST_SHIP_1F/B1F`) renders
as a featureless dark plane crossed by a thin white tile grid. Cause, measured
from the running mod rather than read off the art:

- The lighthouse tileset's tile `$01` is solid black. Dumped source art:
  `results/crystal-tiles/tiles-lighthouse.png`.
- `Gen2TileShape.classAt` returns `wall` for the map's background mass. On
  `OLIVINE_LIGHTHOUSE_1F` that is 252 of 360 cells; on `FAST_SHIP_1F`, 414 of
  574. Both maps' census rows are `0/wall` at `h=16 art=upright foldCell=true`,
  and the representative cell is `tile=1` with a uniform `1:1:1:1` drawing.
- The census agrees: `TILESET_LIGHTHOUSE 1:1:1:1` is 814 cells on its own.
- Both maps have `furniture_placements = 0` in the map census, so no recipe
  ever claims the room and nothing else supplies material.
- Net effect: a room whose walls and floor are the same black 16px mass. The
  real wall speckle (`$4A/$4B/$5A/$5B`) is present but never gets a silhouette
  because the void plateau around it is as tall and as dark as it is.

Proposed rule, not yet applied: a solid cell whose 2x2 drawing is **uniform** and
which has **no orthogonally walkable neighbour** is background, not wall. The
uniformity test is what keeps it safe — real wall drawings mix face rows, caps
and trims, while a filler tile repeats. Measured before shipping: how many
`wall` cells per tileset satisfy it. Rejected alternatives and why: recolouring
is wrong because the tileset is greyscale and the mod's rule is to keep the
native palette; a flat-height change does nothing because the problem is
silhouette, not height.

### Two things that looked like defects and are not

- Union Cave / Burned Tower B1F reading as "washed out" is faithful. Both use
  `TILESET_CAVE`, whose `$16` floor is a near-white dither in the source and
  whose wall tiles `$17/$07/$0A` are the dark rock. `MOUNT_MORTAR_1F_INSIDE`
  uses the same block numbering on `TILESET_DARK_CAVE` and reads correctly
  because that map group has a dark palette. The wall/floor contrast is the
  map's own palette, and the mesher already tops a wall with a rock tile rather
  than the floor tile.
- Large black regions in early FireRed captures were the fixture standing on a
  census rim cell and the camera looking off the map edge, not a rendering
  fault. Camera cells belong inside the space.

### Audit tooling left in `.scratch/ascendant-20260926`

- `survey.lua` / `survey2.lua` — batch scene capture. `survey2.lua` is the one
  that works: it re-applies the camera lock from inside the `game.update`
  wrapper, and asserts per target that the native tile/collision grid is
  unchanged. `QA_TARGETS=<file>` selects the list; each target is captured at
  the zoom a player holds (`close` = level 7, `first` = level 6) plus a fitted
  `overview`. A fitted overview of a whole route is too far out to judge
  scenery — it flattens ground into a repeating pattern.
- `tiles.lua` — dump chosen tileset tiles at 4-9x, for checking what the
  original drawing actually offers before modelling from it.
- `probe.lua` — per-map class census: every class with its count, example cell,
  `h`, `art`, `authored`, `volume`, `foldCell`, and the tile rows a
  representative cell wears. Answers "why does this look wrong" from the
  running mod.
- `orphan.lua` — intended to count the uniform-orphan-wall rule's blast radius.
  **Still broken**: it reports `statkeys=0` and does not classify a single
  cell. Do not trust it; fix before using it to justify the lighthouse change.
- `sheet.py` — contact sheet builder, `python3 sheet.py 'results/*-close.png'
  out.jpg 3 620`. The only practical way to review a full survey.
- `run-long.sh <version> <driver> [seconds]` — same launch contract as
  `run-0322.sh` with a survey-sized timeout. The 180s in `run-0322.sh` is too
  short for a multi-map survey.

### Environment blockers (both still true)

- **Xvfb/LÖVE crashes.** `XIO: fatal IO error 0 on X server ":99"` kills the
  run on longer drivers, and `timeout` then reports exit 124 with a log that
  stops at the boot map. It correlates with long CPU-bound loops that do not
  yield frames; map-based drivers (`survey2.lua`, `studio-release.lua`) run
  reliably, whole-tileset censuses do not.
- **No regression baseline for the mod's Lua suite.** The 0.3.22 runtime ships
  only `tests/drivers`. `tests/modkit`, `harness.lua`, `love_stub.lua`,
  `fs_io.lua` and `tests/fixture_data` were copied in from
  `/home/admin/Apps/Gen1Recomp/source` (an older engine build) to make
  `tests/gen2_tile_shape_test.lua` run at all; it then fails its
  authored-flag and class assertions. That is a fixture/engine mismatch, not
  evidence of a mod defect — but it means **there is currently no trustworthy
  way to detect a classifier regression across the 388/426 imported maps.**
  Resolving this is a prerequisite for the lighthouse change.

### Not verified / remaining risk

No rendering change was shipped, so no visual regression is possible from this
pass. Everything above is either a census count, a classification measurement,
or a capture I inspected. The lighthouse fix is diagnosed but unproven and must
not be described as done.

## 1.28.10 — Test baseline restored, and background fill is not a wall

Two things, one a regression fix and one the largest single scenery correction
measured so far. Changes: `lib/Gen2Elevation.lua`, `lib/Gen2TileShape.lua`,
`tests/gen2_tile_shape_test.lua`, `.gitignore`.

### The test suite had been red since 1.28.5, and nobody knew

`tests/gen2_tile_shape_test.lua` is the suite that pins the Gen 2 classifier.
It failed on a clean checkout: `Gen2Elevation.field` began reading
`map.width*2, map.height*2` in a2e6eaa (1.28.5, "Raise native platforms and
enclose cave interiors"), *after* the test was last touched in f73e09b (1.28.4).
A map without those fields raised inside `TileShape.at`'s `pcall`, so the
`pcall` returned no shape, the generic cell rules answered instead, and every
Gen 2 class silently resolved to unauthored ground — trees, water, walls, all of
it. The exception was swallowed, so it presented as ordinary assertion failures
rather than a crash.

`Gen2Elevation.field` now returns early for a map that cannot state its
dimensions, matching the guard its sibling `Gen2TileShape.supports` already
carries. 106/106, then 114/114 with the new cases below. Real maps always carry
`width`/`height` (`src/world/gen2/Map.lua:18`), so production is unaffected.

There is still **no CI runner** for the suite. `run-tests.sh` in
`.scratch/ascendant-20260926` is a stopgap and should be promoted into
`.github/workflows`.

### Suite baseline, for anyone touching a classifier

Run from the **mod root** with the engine on `LUA_PATH` — many suites
`dofile("lib/X.lua")` relative to the mod, so running them from the engine root
fails on file layout, not on code. Before and after this change: **112 passed,
90 failed**, identical lists. Categories:

- **~59 `astra_*`** need `ASTRA_GENERATED` and `ASTRA_FULL_BASELINE` (a
  generated Yellow dataset that does not exist here). Not real failures.
- **~22** are module-registry drift: the test loads a module with
  `loadfile(...)()` and no `V`, so `V.require(...)`, `Gen3Scene.new`,
  `Gen3Cave.midToSlot`, `Structures.crystalDepth`, `CommunityFlora.setting` are
  nil. `lib/VoxelHull.lua:3` and `lib/Gen3Outdoor.lua:5` already carry the
  `V and V.require(...) or loadfile(...)` pattern for exactly this; the rest do
  not. Precedent exists, so these are cheap, but each is its own file.
- **6 are real content failures** and are the next work:
  `gen2_reviewed_scenery_test:20` (see below), `gen2_depth_style_test:59`
  ("grass illustration is no longer flat" — Gen 2 grass blades are no longer at
  `p[3]==4`), `cave_ladder_test:153` (17 failures),
  `voxel_seam_ao_test` (water corners occlusion-shaded at a connected seam),
  `water_effect_precision_test:82`, plus `choose_your_hero_test:68`,
  `gen3_adapter_test:29`, `scenery_polish_test:5`.
- `battle_art_voxel_fork_test` cannot compile at all: "main function has more
  than 200 local variables" is LuaJIT's hard ceiling, and that file has grown
  past it. It needs splitting, not debugging.

### `TILESET_LIGHTHOUSE`/`GATE`/`TOWER`: the map's background was a 16px plateau

GSC draws the mass a map is carved out of as one solid tile repeated to the
border — `$01` (solid black) in `OLIVINE_LIGHTHOUSE_1F` and `FAST_SHIP_1F`,
`$00` in `GOLDENROD_UNDERGROUND`, `$01` again in `TIN_TOWER`. Every WALL
collision classifies it `wall`, so it became a 16px block as tall and as dark as
the room it surrounded, and the room disappeared into it. That is the whole of
the "washed out, flat, nothing there" reading in those tilesets.

`Gen2TileShape.backgroundMass` now finds that mass: a cell whose 2x2 drawing is
**uniform**, that touches **no walkable cell**, and that has **three or more
orthogonal neighbours carrying the same tile**, is background and resolves to
`ground` rather than `wall`. `ground`, not `void` — the mass is still there and
still unwalkable (collision is untouched), it just stops standing up; `void`
would punch a hole through to the underlay. Roof-palette cells are exempt,
because a building's roof rows are uniform and border only other solids.

Whole-*component* membership was implemented first and rejected: one walkable
cell anywhere in the run disqualifies the whole run, and Goldenrod's rock
touches its tunnels, so 717 background cells collapsed to 0. A 1-cell rim of
wall survives around each mass, which reads as a kerb.

Measured cell counts, `backgroundMass` output:

| Map | wall | background | % |
| --- | --- | --- | --- |
| GOLDENROD_UNDERGROUND | 129 | 717 | 84% |
| FAST_SHIP_1F | 190 | 224 | 54% |
| FAST_SHIP_B1F | 201 | 104 | 34% |
| TIN_TOWER_5F | 181 | 92 | 33% |
| OLIVINE_LIGHTHOUSE_1F | 225 | 27 | 10% |
| MOUNT_MORTAR_1F_INSIDE | 663 | 0 | 0% |
| UNION_CAVE_B1F | 179 | 0 | 0% |
| CELADON_CITY | 374 | 0 | 0% |
| CHERRYGROVE_CITY | 49 | 0 | 0% |

### Rendered verification, and a measured noise floor

Captured `close`/`first`/`overview` at IN2 on 10 maps before and after (the
same `git stash` swap, same targets, same zoom), then captured the **after**
build a second time to establish what "unchanged" looks like. That noise floor
matters: Cherrygrove differs 17.0% between two runs of the *same* build, from
animated water, foliage and the actor's idle frame, so an eyeball comparison
alone would have "proven" a regression that was never there.

| Scene | before→after | noise floor | verdict |
| --- | --- | --- | --- |
| GOLDENROD_UNDERGROUND | 57.5 / 81.0 / 44.1% | 0.00% | real |
| OLIVINE_LIGHTHOUSE_1F | 26.6 / 0.00 / 10.0% | 0.00% | real |
| FAST_SHIP_1F | 15.9 / 15.0 / 13.0% | 0.01% | real |
| FAST_SHIP_B1F | 0.01 / 0.00 / 15.9% | 0.00% | real (overview) |
| TIN_TOWER_5F | 0.07 / 0.00 / 6.6% | 0.00% | real (overview) |
| CHERRYGROVE_CITY | 16.8 / 10.7 / 18.8% | 17.0 / 11.0 / 17.8% | **noise** |
| CELADON_CITY | 3.1 / 3.4 / 4.2% | 3.3 / 4.5 / 3.5% | **noise** |
| ROUTE_4 | 0.5 / 0.2 / 0.0% | 0.8 / 0.3 / 0.1% | **noise** |
| MOUNT_MORTAR_1F_INSIDE | 0.02 / 0.00 / 0.00% | 0.02 / 0.00 / 0.00% | **noise** |
| UNION_CAVE_B1F | 0.00 / 0.00 / 0.00% | 0.00 / 0.61 / 0.13% | **noise** |

Inspected: the lighthouse stops being a flat grid plane and reads as a room with
depth; Goldenrod's rock reads as mass beside the tunnels instead of a uniform
plane; the Fast Ship gains a terrace. No area is punched through — cells that
went flat still carry the tileset's own art at floor level. Caves, cities and
routes are unchanged above noise.

Five new assertions in `gen2_tile_shape_test.lua` pin the rule from both sides
(background goes flat; mixed drawings, ground-bordered walls, lone blocks and
roof-palette cells all stay walls). The test's `fakeMap` grew two things it
lacked: a per-cell four-tile drawing, without which *every* cell is trivially
uniform and the rule cannot be expressed at all, and `widthCells`/`heightCells`,
without which the mass analysis reports nothing.

### The orb/pedestal regression, diagnosed and not fixed

`gen2_reviewed_scenery_test:20` fails: all four `orb_plinth` recipes
(`crystal_depth_gym_orb_plinth`, `_champion_orb_plinth`, `_tower_gym_plinth`,
`_tower_round_brazier`) resolve to **zero parts**, because 7712542 grouped
`orb_plinth` with `boulder` and it now takes the `native_rock` path with no
`modelShape`. Rendered: `TIN_TOWER_5F` shows the object as a tall featureless
slab, and Ecruteak/Champion's room plinths likewise. The test's contract
("orb and pedestal must stay separate") is the right one — a plinth drawn 16x32
is two masses with a waist, and one hull over the whole crop merges them.

Not attempted here: it needs per-tileset art work on four drawings, and the
`Gen2VoxelRock` split has to place two hulls at the right heights. Block dumps
for that work: `block.lua` renders a whole 4x4 metatile plus its ground block
(`results/crystal-block/block-tower_plinth-18.png`).

**Do not "fix" this by moving the crop.** It was tried and it is wrong. The
block dumps read as though the drawing sits in the block's right half, which
suggests `left={0,0,2,4}` misses it; moving the four recipes to `{2,0,2,4}`
looked right and changed **0.00%** of the rendered output. Counting real
placements instead of eyeballing pixels says why — `Buildings.matches` compares
a recipe's crop against the MAP's tile grid, and on this tileset the right half
is tile `2` in all eight positions, which is the uniform filler:

| recipe | shipped `left` crop | matches | `{2,0,2,4}` matches |
| --- | --- | --- | --- |
| gym_orb_plinth | `32/33 48/49 34/35 50/51` | 18 in 9 maps | 567 in 3 maps, all `2/2 2/2 2/2 2/2` |
| champion_orb_plinth | `46/47 62/63 78/79 94/95` | 2 in 1 map | 22 in 1 map, all `83/83 ...` |
| tower_gym_plinth | `40/41 56/57 42/43 58/59` | 4 in 2 maps | 3436 in 18 maps, all `2/2 ...` |
| tower_round_brazier | `74/75 90/91 76/92 54/55` | 5 in 3 maps | 3436 in 18 maps, all `2/2 ...` |

The shipped crops are four distinct tile rows, which is what a drawing is. The
right half is filler that happens to be everywhere on those maps, so it "matches"
thousands of times and builds nothing. The real bug is only the missing
`modelShape`/`parts`, and the recipe's crop is correct. Measurement tool:
`orbmatch.lua` in the QA scratch directory.

### Not verified

Gen 3 and the other two quarters of Crystal's uniform fills (388 maps, 34
tilesets) are unmeasured against this rule. First/third-person framing on the
changed maps was captured but not walked. Xvfb still crashes on long CPU-bound
loops that do not yield frames, which is what the whole-tileset census needs.

## 1.28.9 — Broadcast rooms and Rocket equipment

Crystal radio rooms now have dedicated broadcast receivers, mixing desks, microphones and low round stools. The complete 5F studio desk owns its stacked equipment and work surface together; cabinet materials no longer sample the empty floor strip above the source drawing.

FireRed/LeafGreen Rocket Hideout machinery now has a closed processing vessel, separate radiator fins, controls, piping and feet, using the native colors. Added the executive desk drawing and fifteen missing teal partition pieces; native walkable copies remain flat. Silph wall colors remain separate. Mesh revision 81 refreshes stored geometry.

Validated on Gen1Recomp 0.3.22 with native Crystal, FireRed, LeafGreen and Yellow fixtures, first-person/static/orbit views, unchanged native map grids, three complete B4F machines in both GBA editions, and focused geometry/source-art regressions. Full-area visual coverage and five-mod feature parity remain unfinished.

## 1.28.8 — Industrial drums, rubble and equipment

FireRed/LeafGreen Power Plant drums now use separate closed models instead of room-height walls: 66 drums across 39 complete source columns. Its 117 rubble piles use low, irregular faceted stones, with the original sprite alternative under ROCKS & PLANTS. Crystal gains native-art equipment racks and low cable trays, replacing generic shelf geometry.

Mesh revision 80 refreshes stored scenery. Tested on Gen1Recomp 0.3.22 with native map fixtures, original artwork, first-person/rotating views and focused geometry/settings regressions. This is an incremental scenery update; full-area coverage and five-mod feature parity remain unfinished.

## 1.28.7 — Full-depth starter table and power-plant machinery

Restores the full depth of Oak’s starter table in FireRed/LeafGreen, keeping all three Poké Balls centered and the native approach clear. Adds component models for Crystal’s Power Plant machinery and both FireRed/LeafGreen turbine drawings, using their native artwork and colors. Mesh revision 79 refreshes stored models.

Checked on Gen1Recomp 0.3.20 and the latest 0.3.22 with native first-person/rotating/static captures and focused geometry/cache regressions. Full-area scenery coverage and five-mod feature parity remain unfinished.

## 1.28.6 — Specialty interiors and shared tower mist

Added closed component models for Crystal tower timber columns, the Olivine lighthouse apparatus, Fast Ship dining tables and the FireRed/LeafGreen museum space exhibit. The lighthouse model is restricted to its map because ship tables reuse the same artwork. Mesh revision 78 refreshes stored geometry.

Gen2/Gen3 towers now draw Gen1's rolling mist banks with shared visibility, speed and thickness controls; thickness preserves raised floor heights. Refreshed the native tile ledger: 388 Crystal and 426 FireRed maps. Classification is not visual approval: 24,754 Crystal wall cells and 74,506 FireRed unreviewed cells remain in the review queue, alongside 297 unmatched FireRed building cells.

Validated on Gen1Recomp 0.3.20 with native specialty/lab captures in Yellow, Crystal, FireRed and LeafGreen, 144 complete-object geometry checks, atmosphere/cache tests and 399 option-consumer checks. Full-area quality and five-mod parity remain unfinished. See docs/SPECIALTY_QA_2026-09-26.md.

## 1.28.5 — Raised floors and enclosed caves

Raised Crystal and FireRed/LeafGreen floors now follow native stair connections and reviewed platform artwork. Cave shelves, mountain terraces, piers, theater stages, gym walkways and train platforms carry actors, scenery and cameras at their actual floor height. Water reflection planes follow the drawn water level. Native collision, warps and gameplay are unchanged.

Caves in all three generations receive closed outer walls and ceilings in ground-level views, with camera-side cutaways from outside, clearance above raised platforms, and openings for native boundary exits and descending stairs. Outdoors retain open scenery.

Validated on Gen1Recomp 0.3.20 using isolated native map inventories, representative rendered views and stair walking checks. This is an incremental release; exhaustive all-area visual coverage and companion parity remain unfinished. See docs/ELEVATION_QA_2026-09-26.md. Mesh revision 77 refreshes stored terrain.

## 1.28.4 — Cooperative scenery streaming and higher first-person view

FireRed/LeafGreen builds moving scenery windows cooperatively while continuing to draw the last complete window. Reversals, warps and invalidation cancel unfinished work and release its GPU resources. Model generation and shared uploads gain budget checkpoints; Crystal/FRLG reuse tree source pixels and Gen3 furniture matching skips unrelated recipes.

Raised first-person framing in all three generations: native GB height 12 world pixels, FRLG 13.5, retaining sprite foot anchors and authored provider overrides.

In one isolated 2560×1440 LeafGreen forest benchmark on Gen1Recomp 0.3.20 / RTX 5060 Ti, maximum traversal frame time fell from 53.28 ms to 10.57 ms. Mean was similar (4.56 → 4.61 ms); p95 increased (5.20 → 7.03 ms) as work was spread across frames. Both replacement windows completed. This is a targeted hitch reduction, not an all-game FPS claim. Cold map loads and individual GPU calls remain synchronous.

Native Yellow, Crystal, FireRed and LeafGreen checks covered forest/lab rendering, first-person height, and house exits. Focused scheduler, resource, geometry and furniture regressions pass. Full all-map quality and companion feature parity remain unfinished. Evidence: docs/STREAMING_QA_2026-09-26.md.

## 1.28.3 — House stairs, seating and first-person placement

Fixes FireRed/LeafGreen losing the selected 3D camera when leaving the player’s house with FAR/FULL render distance: connected tilesets with no ground triangles are valid empty batches. Genuine upload failures retain actionable diagnostics and bounded recovery.

Rebuilds complete FireRed/LeafGreen house staircases with separate treads, risers, stringers, handrails and recessed descending flights. Restores the bedroom dresser with two drawers and handles. Mom sits at the dining chair’s cushion, with the chair backs facing away from the table; scripted movement remains native.

Crystal house stairs retain their native four-step footprint. Stair warps are protected from door folding; north wall framing and wallpaper recess behind the flights, and shared Gen 1/2 room foundations leave descending stairwells open.

First-person eyes now follow native sprite eye rows and visible-foot anchors across all three generations. FireRed/LeafGreen first person also disables world curvature and uses the shared close-wall focus distance. Mesh revision 76 refreshes stored geometry.

Checked on Gen1Recomp 0.3.20 with isolated native fixtures and focused regressions. See docs/HOUSE_CAMERA_QA_2026-09-26.md for evidence and limits. Full all-map scenery and cross-generation feature parity remain unfinished.

## 1.28.2 — Native trees and forest performance

Native modeled trees retain distinct source families: pointed conifers, Viridian layered crowns, wide Ilex/Park trees, compact Crystal Kanto crowns and Cut saplings. Colors follow the original artwork around closed 3D crowns. Separate border trees and single wide trees retain their footprints; original 2.5D choices remain available. Shared source images no longer overwrite bush/tree model metadata. Mesh revision 75 refreshes stored models.

Crystal and FireRed/LeafGreen reuse GPU tree models and uploads only placement coordinates when the scenery window moves. Unsupported devices keep merged geometry. All generations reuse unchanged scalar draw state and set shadow camera uniforms once per pass. Gen 1 retains its authored procedural trees and existing map/chunk reuse. Shadows OFF now prevents shadow rendering, including direct native-adapter calls. A 2560×1440 LeafGreen forest traversal on RTX 5060 Ti reduced the largest sampled rebuild frame from about 1,300 ms to 64 ms; steady frames remained similar. This is a targeted short benchmark, not an all-game FPS claim. [Evidence and limits](docs/TREE_PERFORMANCE_QA_2026-09-26.md).

All-map scenery, cross-generation feature parity and completely hitch-free streaming remain unfinished.

## 1.28.1 — 2026-09-26

House and office plants use curved solid leaves, a raised midrib, closed undersides, and a tapered pot with a rim and inset soil; the native 2.5D alternative remains selectable. LeafGreen ship room styling now resolves edition-specific tileset aliases.

Crystal common houses gain complete potted plants, tall bookcases, wall pictures and clocks. Traditional houses gain low tables, cushions, hutches, drawers, cupboards, radios and continuous north-wall strips. Fixes the misplaced wall-row guard, wrong floor atlas slots in ORIGINAL GAME mode, and palette selection for modeled plants. Native potted plants retain the 3D/2.5D scenery choice. Mesh revision 74 refreshes older scenery.

FireRed/LeafGreen gains complete office sofas, oval/rectangular tables, stools and plants; ship cabin beds, chairs, tables, bookcases, bins, portholes and straight rail sections. Complete source drawings own their footprint. Ship interior framing is enabled without changing exterior deck framing. Native collision, scripts and warps are unchanged.

Validated on Gen1Recomp 0.3.20 with native map inventories and representative rendered views. This is an incremental improvement, not completion of all tiles, settings or battle-stage parity. See docs/SHARED_INTERIORS_QA_2026-09-26.md.

## 1.28.0 — 2026-09-26

Trees use normal round crowns: separate narrow border rows, one broad tree for a 2x2 drawing. Native TREE ART retains model/card choices. ROCKS & BUSHES adds solid/native-cutout choices in Gen2/3; default models leave people, Pokemon, grass and flowers as sprites. Mesh revision 73 invalidates older geometry. Adds Voxel Ascendant's MIT-licensed optional weather across all three engines (CLEAR/AUTO/RAIN/SNOW/FOG/STORM), with source attribution. Native battle mechanics are unchanged.

Replaces flat-looking source-column tree/rock extrusion with intersecting 3D canopy/stone masses using each game's native palette. Tree cards remain optional. Shelves now have individually projecting contents, while terminal/rack recipes get separate CRTs, keyboards and equipment modules. Six FireRed/LeafGreen Pokémon Tower grave drawings gain closed plinths and upright headstones, scoped to their original tileset.

Adds closed native-art Crystal sculptures, monuments and thin bicycle displays, plus timber-house side/back siding. Thirty-one more FireRed/LeafGreen cabinet recipes receive closed frames, recessed source facades, kickboards and separate storage bays. Existing authored consoles, appliances and lab models retain priority. Cache revision 73 refreshes stored scenery.

Connects native forest, cave and tower atmosphere controls to both later generations, including fog visibility/thickness, separate subtle/full particle levels and speed. Fixes the full-particle pass calling a nonexistent renderer API. FireRed/LeafGreen SCENERY TEXTURES now controls optional world-stable grain on scenery without affecting actor or UI art.

Verified focused geometry/settings tests, LuaJIT compilation and representative rendered scenes on Gen1Recomp 0.3.20. The native options menu changes, persists and restores the new controls. See [evidence and limits](docs/NATIVE_SCENERY_QA_2026-09-26.md). This is an incremental release: full city/route/interior coverage, specialty scenery settings and Gen3 world-space battle actors remain unfinished. Tower speed currently affects particles, not animated ground mist.

## 1.27.2 — 2026-09-26

Crystal shared scenery pass: 36 existing complete-object recipes now use component furniture—recessed shelving and machine displays, keyboard trays, legged tables, chairs and horizontal beds. Covers facilities, stations, Radio Tower, Game Corners, gates, mansions, ship cabins and Battle Tower. Six native rock drawings use closed source-colored voxel volumes, covering 2,048 placements in the imported map census. No collision, scripts or encounter behavior changes. Cache revision71 refreshes previous geometry.

Inventoried all388 Crystal maps and inspected ten representative maps in overview/first-person captures on Gen1Recomp0.3.20. Some fixture dialogue obscures lower screen regions; this is not exhaustive visual certification. Generic walls and specialist scenery still require review. Lower grass and starting-area fixes from1.27.1 are included.

## 1.27.1 — lower sprite grass and starting-area furniture

Source grass is lower across Gen1/2/3; native Gen2/3 ground-pattern layers retain complete patches and flowers stay upright. Fixed generic furniture stealing the FRLG bedroom console; added neighboring-house appliance/plant matches, framed wall picture and continuous backing; authored Crystal common-house TV/radio/books/table components. North enclosure alignment includes both house vocabularies. Cache revision70. Focused model/grass suites and LuaJIT compile pass. See [starting-area review](docs/STARTING_AREA_QA_2026-09-26.md). Existing all-map/settings/battle-camera limits remain.

## 1.27.0 — native voxel scenery and reported regressions

Crystal duplicate UI fixed via public companion ownership, including singles. Gen3 session-wide camera/battle failure latches replaced by bounded scene recovery; real Route1→Pallet transitions and injected transient/persistent faults pass in FireRed/LeafGreen0.3.20. The user's original exception has not reproduced. Native original-art voxel trees, tree detail controls, cave boulders, wall texel-center sampling and shared 3D-BTL legacy migration are included. Source captures inspected; all 261 production Lua files compile and 13 focused suites pass. See [fixtures and limits](docs/SCENE_RECOVERY_QA_2026-09-26.md). Full all-map/settings/Gen3 battle-camera parity remains unfinished. Persistent QA is in `/home/admin/Projects/.scratch/ascendant-20260926` (previous /tmp runs were lost on reboot).

## 1.26.0 release follow-up

Publishing now at user request.
Known visual gap: final Pallet reverse-angle captures still show noisy house gable/siding pixels, and some close civic walls retain shadow bands. These are not signed off as fixed. The complete 1.26 package has compile/packaging validation; the runtime checks above used the same working source, not a final archive reinstall.

## Forest/performance/FSR — 1.26.0

Completed native overlapping-crown placement, lower grass, sparse-layout dependency cache, optional shared FSR 1 EASU/RCAS, receiver-plane shadow correction and stable foliage clip-depth ties. Added modeled side/back house siding. Before/after forest captures and shadow ON/OFF isolation inspected. Source-consumer settings audit remains incomplete for many original Gen 1 options; unavailable rows are diagnostics, not implemented adapters.

Official0.3.2 + RTX5060Ti/615.71.09. QA is isolated under `/tmp/interior-studio-20260923/qa`; package/audit workspace `/tmp/forest-performance-20260923`. Source/header provenance and detailed limitations are in `docs/FOREST_PERFORMANCE_QA_2026-09-23.md`. CPU scene submission dropped from15.4ms to about0.63ms in the short720p fixture, but the separate1440p run remained about37–39ms per frame across Native/FSR; no broad FPS claim. FSR works on actual GPU in all three generations. Native metatile changes invalidate immediately. Shared foliage GPU cases retain static headings and upright first/free geometry.

DLSS, DLSS5 neural rendering and temporal frame generation are not implemented: native engine/render backend and motion-vector/presentation support are absent. Final archive checks and release audit follow below.

## Designed interior furniture — 1.25.0

Replaced reviewed Crystal and FR/LG furniture extrusions with source-part models: CRTs/keys/pedestals, consoles/controllers, legged desks/chairs, beds, kitchen fixtures, shelf frames, stock islands and low Center cushions. Complete native pair matches cover both player-house floors, labs, Centers and Marts. Crystal runtime bedroom bed/TV/picture and link controls are explicitly modeled. Corrected raised Center carpet borders, incomplete back-wall finishes and monitor occlusion; kept staff-safe reception footprints. Closed component undersides and incremented static mesh revision to 69. No collision/scripts/warps or source assets changed.

FireRed/LeafGreen ledge jumps and their landing dust now remain in the selected 3D camera; player and first-person eye height follow the native hop arc. Sand/grass path transitions retain their original cap artwork and continuous ledge height instead of tapering into false ends. Adjacent Mart checkout sections meet without inset seams.

Official latest Gen1Recomp0.3.2; isolated source/capture workspace `/tmp/interior-studio-20260923`. Initial and corrected rendered rooms inspected, including first/reverse views. Final ZIP SHA256 `3fa934fae0226825990b1cf27ea689b33c4ddc6f5d272a9858406495312377b7` installed byte-for-byte into the isolated runtime. FireRed recaptured all six rooms in four views; Crystal/Yellow archive boots passed. Earlier identical furniture code also passed 24-view Crystal and LeafGreen surveys. Native up/down escalators and six-ball healing completed with camera continuity. Native Route 1 hops retained static/orbit/first cameras in both editions (26 airborne and 22 dust frames each); final ZIP repeated LeafGreen. Inspected final Mart/bedroom and ledge/dust views. All 256 production Lua files compile, and eleven focused regression suites pass. Release assets/pins and pushed-main audit are recorded in `/tmp/interior-studio-20260923/published-audit.json` after publication. See `docs/INTERIOR_QA_2026-09-23.md` for fixture specifics and limits. This remains targeted interior work, not full all-map/option parity.

## Native Center and scenery polish — 1.24.0 (2026-09-23)

Complete native Center escalators, floor openings, joined walls, low staff-safe reception counters, upstairs desks/gates, healing tray/monitor alignment. Crystal kitchen/desk and museum fixtures; closed roof corners. Wild Skies1.13.1 excludes native indoor flocks. Both native editions tested on official0.3.2 with isolated profiles; FireRed freshly imported from the user-provided ROM path. No gameplay/collision/NPC-position changes. See [evidence and remaining limits](docs/SCENERY_QA_2026-09-23.md). All-tile parity remains unfinished.

## Verified final stair/grounding test build — 2026-09-23

Published BAV **1.24.0-test.3**, Wilds **2.4.1-test.1** and all three repinned test carts before testing. Final exact archives booted on official **0.3.1** in isolated Yellow/Crystal/FireRed/LeafGreen profiles. Both native editions cover all traversable stair behaviors across425 maps each; Crystal classifies322 stair/terrace/ladder cells across388 maps. LuaJIT, targeted geometry/grounding/input tests and production GPU checks pass. Ground contacts, upright plants, stairs and recorded-map recap were inspected in rendered captures. No runtime edits follow the published test.3 archive.

See [commands, fixtures, counts and limits](docs/RELEASE_QA_2026-09-23.md). All-tile visual parity remains unfinished; physical-controller/normal-transition gameplay and the user's exact save were not retested. Earlier “no tests before release” entries below describe publication order, not current verification status.

# 2026-09-23 camera, grounding and stair batch

Complete three-row S.S. Anne staircase with deterministic whole-assembly priority and landing behavior checks. Exclude reused underground wall flags. Add short source-textured Crystal cave steps and remaining shared indoor stair drawings. Includes upright foliage, per-frame grounding, contact shadows and recorded-map camera ownership from test.2.

Preceding packages passed sprite/geometry regressions and rendered Yellow, Crystal, FireRed and LeafGreen captures on official engine 0.3.1. LeafGreen covered all traversable native stair behaviors; the FireRed ship variant prompted this follow-up. Published before testing by request. Full scenery parity and exhaustive visual sign-off are still unfinished.

Implementation and regression fixtures are written. No engine or automated tests have run before this release. Source-art inspection is recorded outside the repository in /tmp/voxel-polish-20260923. Latest official engine confirmed: 0.3.1.

# 2026-09-23 camera, grounding and stair batch

Follow-up to test.1: cover the two additional apartment stair assemblies and ship/cave scene fallbacks found by the complete map census. Keep Quest Log sky/lighting tied to its recorded map. Correct extra soft-light bias on character shadows and add small ground-contact shadows that fade with real jump/flight height.

Test.1 passed all 354 Lua compile checks, sprite anchor regressions, 52 stair assembly geometry cases, and recorded-map camera isolation on engine 0.3.1. This follow-up is published before its own tests by request. Visual inspection and full scenery parity remain ongoing.

Implementation and regression fixtures are written. No engine or automated tests have run before this release. Source-art inspection is recorded outside the repository in /tmp/voxel-polish-20260923. Latest official engine confirmed: 0.3.1.

# 2026-09-23 camera, grounding and stair batch

Cylindrical foliage and upright character cards in all cameras; visible per-frame foot anchors across GB and GBA, retaining explicit jumps, flight, masks and furniture support. Source-matched Crystal stairs, Gen 1 cave ladder models, and FireRed/LeafGreen complete stair assemblies, terrace steps and ladder shafts. Quest Log recap uses recorded tiles/actors with the selected camera; dialogue keeps camera input. Shared native building scenes extend to all Building palettes.

Published before tests at the user’s request. This is an unverified test build at publication time; stair appearance and camera/grounding regressions require engine checks. This does not claim every tile or interior is finished. Special native field effects still use their engine presentation.

Implementation and regression fixtures are written. No engine or automated tests have run before this release. Source-art inspection is recorded outside the repository in /tmp/voxel-polish-20260923. Latest official engine confirmed: 0.3.1.

## Coordinated numbered releases — 2026-09-22

User requested releases for every active mod and cart. Promoted the six verified mod builds to numbered versions and refreshed all three cart pins. Runtime/assets are unchanged except version metadata. See docs/RELEASE_QA_2026-09-22.md for carried-forward evidence and remaining limitations. Packaging compilation, runtime equivalence, release digests and exact cart pins are checked for this release batch.

## Final published test.11 checkpoint

All three carts and their six core mods are published and pushed on main. Exact FireRed/LeafGreen single and wild-double animations, four visible battlers, native-authored trainer doubles, and the museum correction passed. Actor grounding and lab/rock fixes were visually verified in test.10 and remain included. See [verification and remaining limits](docs/RELEASE_QA_2026-09-22.md). No runtime source changed after publication.

## Museum counter follow-up and exact test.10 visual evidence — 1.23.0-test.11 (published; verification below)

Exact test.10 museum rotating/first-person captures exposed a bright yellow room-height slab at Museum1F(15,7). Native pair `building__rom_082d4c2c`, metatile `0x2AC`, collision7 is the lower-left bend of the L-counter. Adjacent counter art uses behavior128/collision144 and remains native/flat, so the wall list incorrectly raised this single solid tile. Removed only0x2AC from `Gen3AdditionalInteriors.walls`; retained honest unreviewed native art rather than classifying this object as an approved floor. A complete counter model remains missing. Regression uses exact(15,6)/(15,7) metadata, asserts no room column, and preserves the museum north wall. The15-object furniture test, LuaJIT compile and diff checks pass. Source fixed; no test.11 gameplay or subtask commit/publication.

Published BAV test.10 SHA-256 `52ad69c2aeb4cfe02da9787e86b14ecf18982169674966c0702af42e511fbe9e` and Wilds test.3 SHA-256 `a25ba997b920d9c185b6f6fa60270b0ad06f0dcc8ce9be563aa0cb8b0a0fb222` ran in `/tmp/parity-20260922/test10/engine` on official native0.3.1. Fresh copied caches/profiles under that directory's userdata; no normal save changed. Wrapper asserts manifest/runtime version, identity, isolated persistence and no portable mode; public input reset every frame isolates physical SDL controller input without changing devices or engine callbacks.

Personally inspected exact rendered captures under `/tmp/parity-20260922/test10/results/`: all5 actor shots (noon/low-moon × static/close plus explicit12px lift), all8 lab approach shots plus native fallback, all3 Pewter shots, and all15 cave shots (Mt Moon/Rock Tunnel/Diglett north entrance/Seafoam1F/NavelRock1F × static/rotating/first-person). Player spriteYOffset=0 and exported HGSS Bulbasaur raiseY=0; provider union padding2 is logged. Comparison against `/tmp/parity-20260922/test9/results/actor-baseline/low_moon_close.png` shows the detached low-moon shadow returned to actor feet, and Bulbasaur now shares the player ground baseline. The explicit raised actor remains raised. This stationary provider-actor fixture does not test normal follower progression or every animation/ride state.

Lab table no longer cuts player/rival in all8 approach views; reversed/side views show the item-padding correction. Pewter rocks no longer have floating floor-stripe/grit caps. All15 cave views have native palette depth geometry, black cave background and no outdoor sky/room shell; no stale Dojo dialogue obstructs them. Layout/collision integrity passed all10 depth fixtures (Pewter,5 caves,4 interiors). First-person views sometimes face a nearby wall, so none of this claims exhaustive map traversal. Museum floors remain flat, cabinets/plants render; museum exhibits, some Silph plants/tables and large machine drawings still use incomplete native/flat treatment. The exact test.9 full censuses (388 Crystal/425 FireRed maps) and option-support inventory remain the honest broader backlog.

Key images: `results/actor/low_moon_close.png`, `results/actor/follower_lift12.png`, `results/lab/approach_front.png`, `results/lab/approach_rear.png`, `results/pewter/FR_PEWTER_CITY_GYM_rotating.png`, and unresolved test.10 `results/interiors/FR_PEWTER_CITY_MUSEUM_1F_first.png`. Await root's next published archive before inspecting the counter fix. Native doubles four-sprite coverage is independently under investigation by the ride/front-animation agents; do not infer its success from these field fixtures.

## Animated fronts and native render follow-ups — 1.23.0-test.10 (published; follow-up results above)

Test.10 adds772 real timed BW front atlases for normal/shiny dex1–386,51133 timed frames and28810 distinct pixel frames, with no missing/static-only entries. The importer/source pin, licenses, provider precedence and remaining limits are recorded in `docs/BW_FRONT_ANIMATION.md`. Only the shared AnimatedBattleArt bundled fallback changes; installed atlases stay first priority and Gen1/Gen2 Crystal defaults are preserved. All asset hashes/dimensions/timing checks and782 native front decoder contracts pass, alongside existing22 identity and25 external decoder checks. Native rendered enemy animation remains pending exact release QA.

New user screenshot `/home/admin/Pictures/Screenshots/Screenshot_2026-09-22_22-52-18.png` shows native player/Bulbasaur detached from ground shadows. Gen3 omitted the existing `ShadowMap.snug` actor correction used by Gen1/2, allowing full terrain depth bias to detach sprite shadows at low moon. Gen3 actors now snug only the caster and pass the identical caster as `Voxel3D.draw` sunModel; terrain bias is unchanged. Reflections use their unreflected caster for light lookup. One animation-union alpha baseline is subtracted in local card space, supporting native CPU images and one cached/released public Canvas snapshot. Provider `spr.groundPadding`, including0, is authoritative; Wilds test.3 propagates original baselines through masked variants and preserves explicit PMD anchors. Native player0 union padding0 retains animation positions; HGSS Bulbasaur union padding2 preserves its1px standing/walk difference. Explicit jump/ride/flight/support heights remain additive. Regression covers union/cache, Canvas lifecycle, authored zero and heights0/4/9.12/36/96.

Test.9 exact ZIP SHA-256 `0823c54182623760065c42e0c58395308c03591be5b3108f36e12efdfdf908ab` ran on official native0.3.1 in `/tmp/parity-20260922/test9/engine`, with copied imported caches and isolated profiles. All eight Oak lab approach captures were personally inspected: table-through-player/rival clipping is resolved. Key evidence: `results/lab/approach_front.png`, `approach35.png`, `approach_west.png`. The reverse view exposed a1px native starter frame-padding gap, addressed by the shared union baseline above. Separate actor captures use published Wilds test.2 and the exported native actor/sprite provider; player spriteYOffset=0 and follower raiseY=0 are asserted. Pre-patch low-moon captures reproduce detached shadows with shadow slack2.35 world pixels; `results/actor-clean` raises the camera view so the actors sit above the optional catch HUD; the panel still obscures part of the ground, so a panel-free comparison remains pending.

Pewter gym rotating capture exposed dark disks over boulders: native metatile0x2A4 includes two full-width floor-stripe rows separated from the rock;0x2A2 has detached grit. `Gen3Cave.rock` now keeps the largest connected foreground component before constructing rings, preserving the shared source mask. Anchor, lab footprint/support, disconnected silhouette and cave-profile regressions pass; changed production files compile with LuaJIT and diff whitespace checks pass. Manifest/README/CHANGELOG identify1.23.0-test.10. **Actor-contact, rock-silhouette and BW-front changes need exact published-archive visual QA before any visual pass.** No subtask commit/release.

Exact test.9 classification completed: Crystal388 maps/2357 distinct drawing-collision-treatment rows, including1160 generic-wall-review rows covering25980 cells. FireRed425 maps/60 native pairs/11328 distinct rows;303 enabled depth scenes,92 furnished maps,969 matched objects. Remaining FireRed rows include4626 unreviewed (60489 cells),2910 native fallback (37140 cells),100 unmatched-building (297 cells). These are classification counts, not complete visual parity. CSVs and `summary.json` are under `results/crystal-census` and `results/firered-census`.

The first54-image depth sweep completed layout-integrity checks but real SDL controller input reached Xvfb and opened menus, invalidating obstructed captures (`results/depth`). Rerun `results/depth-quiet` uses public `game.input:reset()` before every deterministic fixture frame, without changing devices, engine code or user settings. All18 static views were inspected: gym walls/props/water and cave palette geometry render, museum floors remain flat, added cabinet/terminal/plant matches appear. Dojo trainer sight triggers dialogue that persists at the bottom of later captures, so caves/interiors are not full-frame visual approval. Remaining native flat exhibit/machine art matches the known coverage gaps. Lab bootstrap and first Wilds extraction failures were QA preparation mistakes, fixed without editing the tested mod archives. Full native option/scenery parity remains unfinished as recorded below.

## Native option consumers, depth scenery and lab footprint — 1.23.0-test.9

Prepared test.9 for publication before gameplay verification, as requested. Manifest/README/CHANGELOG now identify1.23.0-test.9; runtime exports derive their version from the manifest. No commit or release was performed by the settings/scenery subtask. Root owns publication and will append exact packaged test results after release.

Source consumers now cover native day/sky/AA/water/tilt options, Gen2/Gen3 battle UI presentation, selected trainer art, Summary/Dex selected-art scaling, native Gen3 arena plates/crop/boss identity, and exact same-species shiny context. Gen3 sprites receive day tint; native UI-plane actor world shadows/back placement remain unfinished. All89 controls stay visible: the current source inventory records Gen2 38 implemented/34 partial/13 missing/2 provider/2 other-engine, and Gen3 31 implemented/4 partial/53 missing/1 provider. These are source-consumer counts, **not** all-options parity or gameplay approval. See [full checkpoint](docs/NATIVE_PARITY_2026-09-22.md) and [machine-readable inventory](docs/option-support.json).

Geometry additions include reviewed Crystal furniture and FireRed gym/cave/interior profiles, plus15 complete furniture recipes matching137 objects in native museum/Silph/Power Plant/Mansion layouts. Source diagrams and first/last object coordinates are in `/tmp/parity-20260922/furniture/`. Full native map/tile classification censuses are prepared for the exact archive; no new post-change GPU map sweep has been run.

Inspected user screenshot `/home/admin/Pictures/Screenshots/Screenshot_2026-09-22_18-29-25.png`: the Oak table crossed the player/rival bodies. Native x8..10/y4 is blocked, while y5 is walkable and used by starter scripts. The former table model extended to world z94; it now ends at z79, consumes the entire native drawing while cropping only its actual tabletop, and offsets supported starter-ball feet3px inward. General actor lean, native collision and scripts are unchanged. Geometry regression passes. **Code-fixed, not yet visually verified.** The exact disposable fixture places player(8,5), rival(10,5), both up, then captures15/35/50/70-degree static and four rotating views; it retains8 other lab/room views and native fallback.

Validation completed before publication: system LuaJIT bytecode compile of222 production files; native option385, interface20, battle identity22, arena/trainer/tint31, Gen2 interface8, Gen2 HUD15, furniture15, lab footprint/support, staged pair, inversion/dialogue, atlas25 and underlay5 checks; official0.3.1 SDK mod loads181/181 across Gold/Silver/Crystal/Red; diff whitespace check. No gameplay launched for this checkpoint, no user save/profile touched.

Post-publication runners are prepared at `/tmp/parity-20260922/test9/`. `prepare_qa.py` requires the exact root-confirmed published ZIP and SHA-256, creates a clean native0.3.1 source copy without dirty/source-linked mods, installs only that BAV archive and copies imported caches into fresh isolated QA profiles. `run_qa.sh` cases: `lab`, `depth` (18maps ×3views), `crystal-census`, `firered-census`. The wrapper checks exact manifest/runtime version, identity, save-directory isolation and no portable mode. Run only after root supplies the published archive; inspect resulting PNGs before a visual claim. Companion/cart interaction is a separate later fixture.

Wild Skies rooftop support remains a documented gap: BA's current roof heights depend on active rendered/cached scene coverage, so there is no reliable mode-independent `gen3RoofHeightAt` export. Native ground perches continue to use collision; no speculative roof API was added during the code freeze.

## Four-battler framing and complete animated backs — 1.23.0-test.8

Four Gen 1 double-battle cards follow the actual composed sprite heads, and the camera widens to keep both near-side Pokemon in view. FireRed/LeafGreen modern commands preserve full-body sprite pixels beneath the old command window; status anchors use the selected artwork. Fixes the packaged animated BW back atlas path (dex 1–251). Includes the shared modern UI toggle and functional Gen 3 shadow/world-curve/wireframe controls from test.7.

Verified using isolated scripted profiles on latest official Gen1Recomp 0.3.1: four-card Yellow online doubles, normal battle completion with matching state hashes and intact owned parties; Crystal integrated sprite/settings checks; FireRed 1440p UI toggle, native directional input, animated back frame changes, damage, attack-stage lifetime and field return. Inspected native rendered captures, including complete FireRed back sprites and all four Yellow battlers. Final archive checks follow publication.

These remain test releases. Full cross-generation feature parity, complete animation coverage, Gen 3 shiny-context handling and exhaustive multiplayer move/disconnect scenarios are unfinished. User saves and live profiles were not touched.

## Shared modern battle HUD and bundled animated backs — 1.23.0-test.7

Gen 1 staged battles now have separate projected status cards for all four double battlers and compact commands drawn after attack effects. MODERN BATTLE UI is a live shared setting across all three generations; OFF retains native UI. Gen 3 exposes the existing shadow, world-curve and wireframe controls. The selected-art renderer can reuse the bundled animated BW back atlases for dex 1–251; missing species retain static fallback. Custom installed atlases remain first priority. Crystal remains the default Gen 1/2 sprite pack.

TEST PRERELEASE: published before gameplay testing as requested. Full cross-generation parity, Gen 3 shiny-context handling, animated front coverage and advanced multiplayer scenarios remain unfinished.

## Crystal interface ownership — 1.23.0-test.6

Fixes the inherited Gen 1 summary/dex/title ownership conflict: the selected-art interface renderer no longer restores its cached first image over Crystal animation. Gen 1 evolution also retains the mon’s shiny variant. Includes the integrated Crystal sprite pack (Gen 1/2 default), shared manager/in-game controls, full-body staged backs and removal of the separate cart dependency.

Verified on official Gen1Recomp 0.3.1 with isolated scripted profiles: Yellow/Crystal packaged test.5 sprite/settings checks; shiny reveal lifecycle; full-body frame changes and shiny variants; option opt-out; no duplicate sprites in inspected battle captures. A native two-client Gen 1 double battle rendered four animated battlers, completed with matching state hashes/results, preserved the owned parties and kept both players connected. FireRed test.5 exact cart boot/lab/field checks passed. The corrected Gen 1 summary animation passed a local regression fixture. Broader visual/mechanical parity remains unfinished (including Gen 1 partner HUD layout and unsupported generation adapters).

TEST PRERELEASE; final packaged follow-up checks follow publication. Select SPRITE PACK (RESTART) > SELECTED ART and restart to use the other Battle Art collections. HGSS remains overworld-only. Crystal’s optional full-body staged backs are Gen 5 artwork, distinct from its Crystal front/menu art.

## Crystal settings integration — 1.23.0-test.5

Crystal presentation controls now share the Battle Art mod settings and inherited in-game submenu, with migration of existing preferences. Avoids requiring Gen 1 OptionRows on Gen 2. Includes the integrated Crystal sprite pack, default in Gen 1/2, and optional animated full-body staged backs.

Test.4 packaged Yellow/Crystal fixtures passed single-owner selection, animated full-body frames, shiny variants, animated fronts, in-game controls and opt-out. Both battle captures inspected: one sprite per Pokemon. FireRed cart boot/lab/field checks passed. Prior static camera exit regression passed all three generations. This update receives its own follow-up checks after publication. Menus/evolution, shiny reveal timing and advanced battle scenarios still need visual coverage; full all-mod cross-generation parity remains unfinished.

## Integrated Crystal sprite pack — 1.23.0-test.4

Battle Art integrates Crystal Animated Sprites with Shiny Visuals 2.1.0: Crystal normal/shiny frames, sparkles and reveal audio, cry timing, trainer portraits, overworld skins, menus, evolution and move-effect presentation. Crystal is the default sprite pack for Gen 1/2; Gen 3 retains its selected Battle Art collection. Optional animated Gen 5 full-body staged backs are included and enabled. The separate Crystal sprite mod is no longer required.

SPRITE PACK (RESTART) switches between CRYSTAL and SELECTED ART; restart after changing it because the pack installs native menu and battle adapters. Existing Crystal preferences are preserved in the save options. CRYSTAL SPRITES retains its five presentation controls; FULL-BODY BATTLE BACKS is now a Battle Art option. Gen 1 doubles animate both enemy slots and can use both full-body player backs. One renderer owns species and trainer art.

TEST PRERELEASE, published before gameplay verification as requested. Prior camera regression fixture reproduced the old failure, then passed with test.3 in Yellow, Crystal and FireRed (lab-to-town transition and movement). Full feature/visual parity across generations remains unfinished; adapter-pending settings are not claimed functional.

## 1.23.0-test.3 — camera and sprite regression fixes

Fixes the fixed indoor camera leaking into outdoor static views in Gen 1/2. Removes the redundant Gen 1 draw-time sprite override, retaining the original Battle Art owner and shared static/animated asset loading. Gen 3 already resets the room camera to nil outdoors.

The preceding test.2 carts passed boot/lab/field checks; a native two-client Gen 1 double battle passed completion, mirrored state hashes, owned-party restoration and room retention. This targeted camera/sprite correction is a test build; visual regression verification follows publication. Supplied BW artwork is static fallback; actual animation requires matching existing Battle Art atlases. Unsupported generation-specific settings remain explicitly read-only.

## Unified Battle Art test release — 1.23.0-test.2

Battle Art now uses its existing ownership settings and animated-atlas decoder across Gen 1, Crystal and native FireRed/LeafGreen. Working shared controls: BATTLE ART, ANIM FRONT GEN, BACK ART SET, PLAYER and DUPLICATE FIX. Gen 5 animation uses user-installed atlases; the supplied BW images are STATIC full-body fallbacks, never decoded as animation sheets. All four double battlers use the selected art. HGSS remains overworld-only. No separate BW sprite mod is needed.

**TEST PRERELEASE — published before gameplay testing at the user’s request.** Includes the preceding right-stick, door/healing projection, settings inventory and Gen 1 online-double work. Unsupported generation-specific settings are read-only, explicitly marked ADAPTER PENDING. Native gameplay and advanced doubles verification remain pending.

# Test release checkpoint — 2026-09-22 (gameplay verification pending)

User explicitly requested publication before gameplay testing to conserve their
remaining account budget. Test artifacts and publication records are under
/tmp/test-round-20260922. Stable releases are not replaced.

Gen 1 online doubles implemented via an optional native cloned-party provider,
paired actions/targets, host-first turn ordering, queued-turn hashes and bench
refill. Native two-client gameplay validation is still required; advanced move
contexts, simultaneous faints and disconnect/cancellation require scrutiny.

Wilds now imports user-provided PKMN.NET SR4 HGSS walking frames. Gen 3 defaults
to these for wilds/followers, Ride reuses them and carries an independent fallback.
Gen 1/2 keep their existing defaults and opt in through the HGSS sprite choice.
New independent gen3-bw-battle-sprites mod uses the supplied STATIC BW fronts and
backs only during native battle drawing. The provided 96x96 PNGs are not animated.
Crystal's Gen 2 animated companion remains untouched. No HGSS battle artwork.

Battle Art Gen 3 adds right-stick input through public hooks, projects native
healing/door frames into world space, and keeps its camera selected. All settings
from the generated ModSetting catalog are visible in-game; missing generation
adapters are READ-ONLY / ADAPTER PENDING, not claimed functional. Gen 1/2 expose
the complete declared schema regardless of conditional preset pages.

Only build compilation/package validation performed before publishing. No live
profile/save modifications. The referenced X post could not be read; local fork
source confirmed the existing Gen 1 BattleArt/AnimatedBattleArt machinery, but
it is not connected to the native Gen 3 renderer. New native provider is separate.

# Release checkpoint — 2026-09-22

Prepared for publication at the user's request: Online 0.7.0, Wilds 2.3.1,
Double Battles 0.11.0, Ride 0.3.0; Johto Diorama 1.16.0, Yellow Online 1.4.0,
Voxel Red Preview 0.3.0. Battle Art runtime remains 1.22.0. This checkpoint
supersedes the unfinished-test status below, without claiming complete parity.

Current evidence on official Gen1Recomp 0.3.1 (isolated profiles):
- All three exact sealed-cart archives boot, validate cart identity and every
  pinned mod version, render their lab and return to the field. Crystal loads
  seven pins and full_body_backs=true; Yellow six; FireRed all five, including
  the new Ride port. Lab captures inspected for all three generations.
- 155 packaged Lua modules and the runtime-concatenated Ride source compile
  with LuaJIT. ZIP contents/hashes checked; no ROMs, saves or import caches.
- Native two-client FireRed Ride sync passes ground/flight, height, movement,
  dismount, local-state isolation and disconnect. Ground/flight captures inspected.
- Native Yellow and Crystal two-client ground Ride sync passes mount, movement,
  dismount and disconnect. Yellow remote mount capture inspected.
- Native Crystal online doubles pass paired choices, explicit targets, bench
  replacement, mirrored state hashes, win/loss completion, cloned-party restore
  and retained room. Native mirrored mechanics fixture and 43 unit checks pass.
  Final native run preceded the small PP/egg validation and Future Sight state
  normalization follow-ups; those have source/unit coverage, not a repeat duel.
- Native FireRed doubles and trade fixtures pass completion, party integrity
  and room/chat retention. Standalone FireRed Ride passes without companions.
- Fresh LeafGreen import into a disposable profile passes ground/flight/Surf,
  safe dismount and walkable axis-aligned follower trails.
- Crystal sprite provider passes full-body animation checks for Cyndaquil,
  Totodile, Chikorita, Raikou and Ho-Oh. Full-body battle capture inspected.

Evidence: /tmp/ports-parity-031 (doubles-release, double-core-final,
ride-net2, ride-gb2, ride-crystal2, ride-lg-verified, native-double, trade-final,
sprites-cart) and /tmp/release-ports-20260922 (archives, checksums, logs, captures).
Scripted QA .love uses the official interactive PlatformHooks.update seam and
passes the cart ID, correcting two stock driver omissions only. No production
engine patch or user profile/save changes. Live AppImage left untouched.

Remaining: Gen 1 online doubles, advanced Crystal double weather/delayed-move
combinations, broader mixed-mod/cancellation/disconnect matrix, exact GB custom
rider skin/scale parity and exhaustive scenery coverage. Crystal lab/field QA
logs a nonfatal Wilds nil-sprite fallback warning; investigate separately.
Gen 3 flight is map-local; standalone mount fallback art is nondirectional.
No new visual runtime changes this release. Gen 5 FireRed battle backs are
explicitly deferred by the user to a separate future mod. Crystal uses its
Gen 2 sprite companion, not Gen 5 art.

# Port work checkpoint — 2026-09-22 (UNRELEASED)

Sprite/cart QA passed on 2026-09-22: all seven exact published mod archives
load, sealed-cart full_body_backs=true reaches the provider, and Cyndaquil,
Totodile, Chikorita, Raikou and Ho-Oh advance animation frames through Battle
Art's public Gen2Staged.picFor integration. Native Cyndaquil/Sentret battle
capture inspected: full-body Cyndaquil is visible on stage. Evidence:
/tmp/ports-parity-031/sprites-cart.log and sprites-cart-battle.png.
Test harness detail: stock 0.3.1 scripted boot ignores the cart and bypasses
PlatformHooks.update, unlike interactive gameplay. The isolated QA .love
changes only cart boot arguments and the driver update call to the normal
PlatformHooks.update seam; no production engine/mod patches. An initial
unadjusted driver failed animation advance because it skipped that hook.
Cart manifest/index match, all seven ZIP hashes verified locally, strict
cartkit validation and packing pass. No new cart release published yet.

Current source changes remain uncommitted; published baseline below is unchanged.
Gen 3 Ride now has a native implementation in dramatic-sky-ride/lib/gen3/init.lua.
Official Gen1Recomp 0.3.1 standalone FireRed fixture passed ground movement,
free flight, native Surf, safe dismount and mounted follower suppression. Two
native FireRed clients passed remote mount, flight height, dismount, local-state
isolation and disconnect cleanup. Evidence: /tmp/ports-parity-031/ride*.log.
Only the standalone ground capture has been inspected so far; other captures
still need visual inspection. No claim of complete cross-generation Ride sync.

GB Ride read-only visual/pose exports and Online adapters are implemented but
not yet tested. Wilds Gen 3 now records the player's actual trail and hides its
follower while mounted; corner/warp cases still need verification. Optional
Crystal online-double provider and paired-turn transport are implemented but
NOT verified: the first two-client run timed out with host at intro and guest
at link-wait. Logs: /tmp/ports-parity-031/doubles-crystal-{host,guest}.log.
Gen 1 online doubles remain unimplemented. Do not publish these as complete.
Remaining work includes double mechanics/hash/refill checks, cancellation and
mixed-mod cases, standalone/LeafGreen Ride, and additional Gen 2/3 visual work.

Latest user addition: Crystal cart source re-adds animated sprites 2.1.0,
SHA256 9432787d25476ccf5ce63309efefad794ba6fae877f710013e6bf73ad2aa192f,
with full_body_backs=true in both cart.json and index-entry/meta.json. Preserve
this seventh pin when regenerating cart manifests. Cart 1.15.0 on GitHub has
not changed. Dedicated exact-release sprite/cart QA is under
/tmp/ports-parity-031/sprites-cart* and isolated profile
/home/admin/.local/share/crystal-sprites-cart-031-qa. No player saves changed.

# Release QA — 2026-09-22

Packaged ZIPs, exact SHA-256 pins and sealed carts tested in isolated
release-031-{yellow,crystal,firered}-qa profiles. Official Gen1Recomp 0.3.1
.love checksum verified. A QA-only copy changes only the scripted boot's two
cart-id arguments to honor QA_CART (stock driver boot discards --cart); no
production engine/loader/gameplay changes. FireRed reimported from the user's
local ROM into the disposable QA cache. Player profiles/saves untouched.

Three cart runs passed identity/pin/version checks, four native interiors and
field return each. Crystal/Yellow load all five mods plus Running Shoes.
FireRed bundles all five at the user's request: four load, Ride stays
wrong_generation because its Gen 3 port is unfinished. Rendered Yellow and
Crystal contact sheet and FireRed Oak lab/field captures inspected. Logs and
archives: /tmp/release-031-20260922. 368 packaged Lua files and the assembled
Ride source compile with LuaJIT; tree-art, lab, options, LeafGreen alias,
shared-world/activity and Gen 2 target-selection focused tests pass. Wilds
version, ASCII metadata, option-label and ZIP hygiene checks pass.

No claim of exhaustive visual parity or full multiplayer activity revalidation
on 0.3.1. Earlier two-client 0.2.73 evidence is retained separately. Gen 1/2
online doubles, Gen 3 Ride and the remaining disconnect/mixed-mod matrix are
still unfinished. Kanto Gear is absent; all packages exclude ROMs, player saves,
import caches and private battle artwork. Companion mods remain independent.

# Main-branch source checkpoint — 2026-09-22

User requested committing and pushing all mod/cart work to main. This checkpoint
contains the previously uncommitted presentation, options and cross-generation
port changes described below. It does not create new release tags or installable
cart assets. Cart source manifests are drafts using existing published pins;
replace those pins after companion releases and final integration verification.
Historical references to uncommitted work below describe the earlier checkpoints.

# Source-art, Oak lab and native options — 2026-09-22 (UNRELEASED)

User steering: original artwork/overhangs/LeafGreen; FRLG trees cut in half;
Oak lab machine, clipped starter balls, broken wall; missing in-game options;
real Pokédex desk. All remain uncommitted; no new releases/version/cart pins.

Implemented:
- Original tree/scenery settings, native tree atlas, complete FRLG 32x48 and
  forest 48x80 source assembly (including forest cap 641), palette/ground masks,
  transparent-bottom grounding and full-layout cache keys. Illustrated option
  retained, flat/model stem setting retained. Gen 1 trees unchanged.
- Source roof/eave work and LeafGreen semantic tileset aliases, as documented
  in docs/SOURCE_ART.md. User-facing wording is 2.5D; persisted keys unchanged.
- Gen3Furniture: round lab machine, native colors/platen, physical desk with
  legs/drawer, supported Pokédex/ball sprites, thin mounted posters, complete
  bookshelf tops and plant cutouts. Gen3Scene/InteriorDiorama align a continuous
  back wall to the native facade; no collision/event changes.
- InGameOptions in Battle Art, Wilds, Double Battles and Ride are independent
  adapters. Native Game3 option_rows does not call ui.options.rows. BAV/Wilds/
  Double get native pages; Double/Ride get missing GB rows. Numeric/toggle/choice
  persistence emits mod.options_changed. Composed wrappers tolerate hot reload.
- Crystal and Yellow cart SOURCE manifests reduced to five core mods plus
  Running Shoes. Their pins still point to older releases: do NOT build new cart releases
  from these manifests until new companion releases exist. VoxelRed remains published preview.

Native evidence, not exhaustive parity:
- Official upstream gen1recomp 0.3.0 .love, checksum verified. Runtime at
  /tmp/source-art-030; isolated source-art-{yellow,crystal,firered,leafgreen}-030-qa
  profiles. FireRed reimported into QA because old import was not 0.3.0 ready;
  LeafGreen uses the user’s imported cache. Player saves/install untouched.
- Crystal New Bark/Olivine roof and tree modes, FRLG Oak exterior and broad
  37-view surveys completed earlier this batch. Original tree final driver
  tests/native_tree_art_driver.lua captures Pallet and Viridian Forest native,
  static/first/rotating plus whole cutouts. Inspected both editions’ source art;
  final runtime views in /tmp/source-art-030/trees-final-{firered,leafgreen}.
- tests/gen3_lab_driver.lua: native FRLG lab, machine extraction, 3 supported
  balls, 8 cameras from walkable cells, original 2D fallback. Captures inspected
  at /tmp/source-art-030/lab-views-{firered,leafgreen}. Latest LeafGreen run also
  verifies complete plant alpha; prior FireRed run used same desk/machine/wall
  but preceded that one-line plant mask dispatch correction.
- Native options drivers: all four games’ mods load; options rows/pages open,
  change, persist, emit events and retain values on reopening. Native methods
  exercised, not physical keyboard clicks. Gen3 labels shortened after visual
  overlap inspection. Captures /tmp/source-art-030/options-*.
- Unit tests: native_tree_art, leafgreen_tilesets, gen3_lab, in_game_options,
  interior_diorama, gen2_exteriors/roof_shell, gen3_roof/civic/outdoor and
  boundary_scenery pass. LuaJIT compiles 76 changed/new mod Lua files plus
  assembled Ride; all five mod repositories pass git diff --check.

Remaining: Forest gate still uses flat artwork; dense forest root-placement
coverage and specialty interiors/caves need a broader survey. No claim that
all tiles are perfect. Ride Gen3, GB online doubles, remaining five-mod native
0.3.0 integration matrix and releases are tracked in Online’s handoff and remain
unfinished. Current work must not be presented as a completed five-mod cart.

# Cross-generation room battle HUD — 2026-09-22 (UNRELEASED)

`BattleTheme.layoutStatusCards` separates paired status cards horizontally,
clamps them within the screen and preserves their Pokémon head pointers.
`Gen3BattleHud` applies it to the four native FireRed battlers. Unit coverage
includes narrow/wide viewports, screen edges and four-card placement.

Actual 0.2.73 Linux, isolated crossgen-world-host/guest-qa profiles, Online +
Wilds + Double Battles + Battle Art: two native ENet clients completed a full
FireRed double link battle and returned with both original parties unchanged.
Before/after captures were inspected; all four Pokémon render, and the after
capture has four readable, separated cards above them. Fixture: Pallet Town,
host two Lv50 Bulbasaur / guest two Lv5 Rattata, Tackle-only moves, native
command and target flow, static staged camera. Evidence and driver:
`/tmp/crossgen-integration/native-link-driver.lua`, `link-double-*.log`,
`host/link-double.png`, `guest/link-double.png`. These paths are scratch data,
not shipped assets. Player saves were not changed. No new release/cart pins.

Room chat bubbles are owned by Online, which consumes the public Voxel3D
projection API. Remaining five-mod ports and broader matrix are tracked in
`../gen1online-plus/CROSSGEN_PORT_HANDOFF.md`; this is not full parity proof.

# Published release handoff — 2026-09-22

User requested all pending project work committed/pushed to main and new carts.
Battle Art 1.21.0 (1b7eb90), Double Battles 0.9.5 (5319358) and Wild Skies
1.12.3 (88dfdd5) are published. Battle Art's main is now the default branch;
Legendary-Additions also contains the full implementation commit. All absol89
commits through upstream 1.11.0 remain in the merge ancestry.

Carts: Johto Diorama 1.14.0 (12 mods), Yellow Online 1.2.0 (56 mods), and
public notquiteog/VoxelRed 0.1.0, a clearly marked Battle Art-only FireRed
preview. User explicitly selected the preview rather than awaiting companion
Gen 3 ports. CG3 stays on Crystal; Kanto Gear is absent in all three.

Final packaged-cart QA on actual 0.2.73, isolated profiles:
- Every pinned version loads through the native sealed-cart boot path.
- Elm's Lab / Oak's Lab / FireRed Viridian Center: static, first-person and
  rotating camera views, followed by field return. Screenshots inspected.
- Yellow exposed the obsolete Followers EX/PokePC pair's missing asset lookup;
  remove those two pins because Wilds 2.2.0 already owns followers and their
  settings migration. Hide its catch HUD as requested.
- Fixed Wild Skies virtual card resolution in its own package, not Battle Art:
  the engine's monochrome OBJ baker tried to read GPU-only card paths as files.
 20 portrait tests pass; native forced-Pidgey rendering no longer fails open.
- Crystal retains existing occasional Wilds sprite-fallback warnings. This is
  not Internet multiplayer, exhaustive map polish or a complete playthrough.

Artifacts/logs and SHA-256 audit: /tmp/cart-release-20260922. QA profiles:
cart-release-{crystal,yellow,firered}-qa. User saves were not modified. Engine
cartkit's old six-game list needed a FireRed addition; VoxelRed includes a
small wrapper, and the runtime independently accepts the packed cart.

Earlier entries below retain implementation history and explicit limitations.
FireRed specialty interior coverage, full depth-positioned FireRed battlers,
companion Gen 3 ports and multiplayer doubles are still unfinished.

# Release preparation — 2026-09-22

User authorized committing all project work to main and publishing new carts.
Battle Art 1.21.0 packages the following previously unreleased batches.
Double Battles 0.9.5 consumes the public HUD exports independently. Crystal
and Yellow receive updated pins; Voxel Red is explicitly a Battle Art-only
FireRed preview. Companion Gen 3 ports and multiplayer doubles are unfinished.
Earlier UNRELEASED entries below describe the implementation/QA history.

# Interior dioramas — 2026-09-22 (UNRELEASED)

Latest request: beautiful open-front interiors like two supplied room images,
across all three generations. New shared lib/InteriorDiorama.lua frames room
bounds with plaster, skirting, cornices, side windows and foundation. Home,
shop, Center and lab palettes. Camera-near walls open in external views;
first-person eyes inside see a closed room/ceiling. Compact-room static camera
fits the complete room at the selected angle; large halls retain scrolling.
Free camera modes stay on their own rigs. Native map/collision/scripts untouched.

Voxel3D interior uniforms add warm indirect fill/contact shading and clip the
old void border. ShadowMap.roomClip clips the same border casters (hiding only
color left a false front shadow band). begin resets shadow roomCut every pass;
endScene clears interior state. Shader material boundaries are inset .03 to
remove coplanar outside faces. Wall trim segments no longer overlap plaster.
No persistent terrain cache revision needed: these are shader/dynamic shell
changes; FireRed scene meshes are rebuilt in memory. Fork stays beta.3.

FireRed now enables network (Center) and building__rom_082d4bcc (Mart) pairs.
25 new pair-specific furniture recipes plus 2 house planter recipes; retain
native layers, cut out plant ground through reviewed floor colors, use shared
camera anchors. Upper wall cornice bands align with adjacent two-row windows
instead of stretching the single row above a claimed cabinet. Native healing,
shop and special-field-effect fallbacks stay active. Remaining specialty
FireRed interiors are NOT ported. See docs/INTERIOR_DIORAMAS.md.

Actual 0.2.73 Linux AppImage validation (isolated profiles):
- /tmp/interior-hd2d/final-{yellow,crystal,firered}[.log]: 4 rooms each;
  house, lab, Mart, Center. Front/side/back/inside, normal gameplay, 1st and
  rotating 3rd person, then outdoor return. Player placed on a walkable dry
  non-warp cell, not arbitrary geometry. Native script suppression in QA only.
- expanded-yellow[.log]: Museum1F and Viridian forest south gate.
- expanded-crystal[.log]: Violet Kyle house, RadioTower1F, DanceTheater and
  Ilex/Azalea gate. All 18 room fixtures PASS; representative screenshots
  visually inspected, not a claim that all map instances were reviewed.
- topdown-fr[.log]: every camera rung in the player's FireRed house. Shows
  complete compact-room framing, no ceiling above the room, open near wall
  also when a near-overhead eye projects inside the footprint.
- battle-crystal[.log] PASS native move menu/damage/head anchors;
  battle-firered[.log] PASS 1440p menus/moves/damage/stage lifetime/return.
- Interior bounds/recipes test PASS (25 Mart/Center recipes); adapter,
  outdoor, companion and Gen2 depth checks PASS. Gen2 support181/181 PASS.
  Runtime/driver Lua compilation and diff whitespace checks clean.
- Final indoor-battle[.log] PASS: render Elm's Lab first, then enter a staged
  Crystal battle directly. Head anchors, move selection and damage succeed;
  no stale room clipping on the battle renderer. The inspected battle still
  shows the older circular object-cutaway edges; this is not visual approval
  of indoor battle scenery. Reset roomCut in ShadowMap
  begin, not only its one-time GPU orientation probe. Ceiling appears only
  when the eye is below its actual height, not above it in a third-person rig.
- Inventory through native map providers: 135 Gen1 room frames, 233 Crystal
  including gates, 124 enabled FireRed. 103 other FireRed building-primary
  interiors remain native pending separate furniture/animation profiles.

Captures/logs under /tmp/interior-hd2d, none committed. Main repeatable driver:
tests/interior_diorama_driver.lua; set QA_INVENTORY=1 QA_VIEWS=1 QA_GAMEPLAY=1
and optional QA_INTERIORS comma-separated IDs. Uses existing run-native.sh and
isolated identities battle-art-crossgen-qa (Yellow/Crystal), firered-hd2d-qa.
Yellow cache is symlinked read-only by convention from the user's imported
cache; gameplay saves are not loaded or written. Prior 88 WIP files preserved.
No release, source commit, push, cart bump or deployment this turn.

This is a shared room-presentation pass, not full reference parity for every
object. Existing legacy furniture/wall artwork can still need bespoke fixes;
FireRed specialty adapters, depth-aware healing and the earlier independent
companion ports/public Voxel Red cart remain pending.

# Upstream synchronization — 2026-09-22

Merged all 10 new absol89 upstream/master commits through 1.11.0,
5e9f6509c66b1782dca52e0afb0f6ab7e2cf148b, into Legendary-Additions as
3fca9c2. Verified zero upstream commits missing from HEAD. Local merge only;
no push, release, version bump or cart re-pin. Fork stays 1.21.0-beta.3.

Preserved and restored all 88 pre-existing WIP files. Recovery refs remain:
refs/backups/pre-absol89-1.11.0-head and
refs/backups/pre-absol89-1.11.0-wip (stash 6d7a245). Before this handoff update,
84 files were byte-identical to the snapshot; only handoff, BattleScene,
ChunkMesher and Voxel3D differed from upstream integration. WIP remains
unstaged/untracked. BattleScene shadow key retains BOTH upstream trainer
revision and our render distance. Shader integration retains our boundary fog.

Incoming changes include cut-tree regrowth rebuilding full/body variants,
companion false-splice detection, capture recoil, scoped battle effects,
optional trainer shadows and battle fire illumination.

Validation after restoration:
- 212 runtime Lua files compile; git diff --check clean.
- Companion integration, boundary scenery, Gen3 adapter and terrain tests pass;
  Gen2 support passes 181/181 with actual 0.2.73 source.
- Actual Linux AppImage 0.2.73 native battle runs PASS: Crystal move selection,
  damage/head anchors; FireRed 1440p menus, damage, stage lifetime and return.
  Logs/captures: /tmp/firered-hd2d/upstream-1110-crystal[.log] and
  /tmp/firered-hd2d/upstream-1110-fr[.log]. Inspected command screenshots from
  both. Existing unfinished patterned ground, scene props near battlers and
  native screen-space FireRed sprites remain; this is merge regression QA.
- Whole-repository compilation hits the unchanged legacy test
  tests/battle_art_voxel_fork_test.lua:2604 (over 200 locals). Runtime compile
  above is clean. New Gen1 cut/regrow driver and optional companion effects
  were not exercised end-to-end in this Crystal/FireRed run.

# Shared distance and contextual boundaries — 2026-09-22 (UNRELEASED)

Latest explicit request implemented in the working tree: shared Auto / Low /
Medium / Far / Full for Crystal and FireRed. Auto defaults to desktop Medium,
mobile/console Low; persisted old values still work. Full draws complete loaded
connected rectangles plus scenery. In FireRed its map frontier is at least Far's
(frontier regression asserted), not the old two-hop-only set.

New BoundaryScenery selector gives real connected rectangles priority, then
samples the nearest native edge. Gen3Boundary uses native map/behavior metadata;
Gen2Boundary replaces the old uniform border ring only on Crystal outdoor/forest
maps. Water/raised-rock/forest donors, deterministic roots/variants, same nearby
trunk/leaf builders/materials and camera-facing rules. Ilex uses TILESET_FOREST
rather than relying on its non-outdoor environment header. Viridian Forest's
separate secondary tree drawing now has a 3-cell footprint / 1.5 scale: trunk676
owns the model, crest641 is canopy (NOT ground), all use safe General ground1.
Two map-specific QA failures caught these gaps before claiming completion.

Planar distance haze avoids washing out the foreground under an elevated camera.
Full uses rectangular region bounds. Voxel3D + reflective Water receive/reset
matching fog uniforms. WorldUnderlay uses the sky endpoint for default cyan/nature
under this new haze (explicit black/off unchanged), removing its unlit cyan
horizon seam. Boundary scenery casts shadows in Crystal field and staged battles.
Geometry cache68. Details: docs/RENDER_DISTANCE.md.

Actual0.2.73 Linux AppImage QA in isolated identities (no user profile mods edited):
- /tmp/firered-hd2d/boundary-fr-final.log PASS: Pallet, Cinnabar, Route3,
  ViridianForest, static/first/rotating views, all5 distances, no rotation rebuild,
  Full retains Far's connected maps.17 screenshots in matching directory.
- /tmp/firered-hd2d/boundary-crystal-final.log PASS: Cherrygrove, Route29,
  Blackthorn, Ilex; same camera/distance checks.17 screenshots. Driver waits for
  actual mesh queue completion and chooses walkable, non-water, non-warp cells.
- boundary-battle-fr.log PASS1440p head cards, input/moves, native damage,
  stage lifetime and return. boundary-battle-crystal.log PASS native battle,
  head anchors, move UI and damage. Both after new rectangle/water fog code;
  subsequent edits only added Viridian crest classification and Full frontier.
- Pure selector/distance, Gen3 adapter/forest isolation, terrain, Gen2 depth
  checks PASS. Water cast reflection52/52 including fog uniform reset.
- Gen2 shapes105/105 and support181/181 PASS with actual0.2.73 source + old
  helper tests on LUA_PATH. Use relative DS_MOD_PATH=mods/BATTLE_ART_VOXEL_FORK;
  absolute paths fool old tests.fs_io into discovering no mod.
- 78 changed/new Lua files compile; git diff --check clean. Legacy
  water_effect_precision_test still fails at signature line82 IDENTICALLY with
  HEAD Water.lua (confirmed using /tmp/bav-head-water.lua). Not a new regression.

This is representative QA, not approval of every map or all existing visuals.
Existing Crystal patterned materials/rocks/buildings and complete Gamma parity
remain broader unfinished work. No version bump, source commit, push, release
or cart re-pin during this feature work.

Previous requested FireRed companion ports/public Voxel Red cart STILL PENDING:
see docs/VOXEL_RED_INTEGRATION.md. Independently usable Wilds of Kanto,
Gen1Online+, Dramatic Sky Ride and Double Battles with Battle Art optional.
Cloned upstream Wilds2.2.0 into /home/admin/Projects/overworld-spawn-mod (clean,
no fork/release yet). Read actual engine Gen3 link/trade/battle APIs; it has
native link doubles (mode2) and trade writeback. battle_bridge.start preserves
native trainer doubles, but normal wild bridge explicitly excludes doubles.
Do not replace native simulation or override owned spawn encounters. Multiplayer
needs two-endpoint verification; no implementation or multiplayer claims yet.
Kanto Gear removal remains shipped Johto1.13.2 from the previous work.

# Final battle UI checkpoint — 2026-09-22 (UNRELEASED)

Actual0.2.73 at2560x1440 final native runs:
- /tmp/firered-hd2d/battle-ui-final.log PASS: directions, moves, HP damage,
  stage lifetime and field return. Screens in battle-ui-final/. Inspected
  commands + attack: native attack message panel remains oversized and is
  explicitly unfinished. Native screen-space battlers still lack scene depth.
- crystal-heads-final.log PASS singles head projection, move UI, damage.
- crystal-double-heads-final.log PASS two Sentret independently drawn, three
  separate overhead cards, second-target selection and native damage. Final
  run includes Crystal sprite companion via QA-only symlink. No errors. First
  double fixture had an event guard error (screen also emits battle.started);
  corrected fixture only decorates actual sim objects with enemyParty.
  Native screenshots inspected; projected image-frame bounds can leave extra
  air above animated sprites. Crystal terrain is still overly patterned.

Pixel font uses engine-bundled PlainPixel, nearest filtering, drawn after FX;
shared silver pointers/colored commands use clean PKMN/ITEMS labels and a
central diamond. No copied Gamma assets. No species scaling.
67 changed/new Lua files compile. Targeted helper projection/occlusion,
adapter, staged-pair, HUD visibility, outdoor, hosted-trainer tests PASS.
Companion HUD tests PASS fallback, DPI, capture isolation, all four projected
slot providers and semantic button order. Two broader legacy mocks still
fail identically with HEAD BattleScene: battle_scene_visual_sidecar_test
(missing mock battleOcclusion), stadium_hosted_extras_test (line27). Do not
claim a clean whole suite. Native Gen1 overhead UI, full doubles mechanics,
multiplayer doubles, exhaustive scene parity remain unverified/unfinished.

Only cart removal shipped: Johto1.13.2. Battle Art / Double Battles changes
remain uncommitted, with original manifest versions retained. QA identities
only gained companion symlinks; no user mod source installation changed.

# Follow-up: Kanto Gear removal — 2026-09-22

User requested removal from all carts. JohtoDioramaCart source/index/readme
updated, committed fd789aa and pushed main; release v1.13.2 published with
12 pins, validated online/strict. All other source pins/options/art unchanged.
Installed Johto cart and local downloaded/QA cart copies had only Kanto Gear
removed, preserving their own older pins/version/art. Backups outside carts:
/home/admin/.local/state/cart-backups/kanto-removal-20260922/*.bak.
Yellow Online did not contain it. User must restart a currently running cart
to unload an already loaded mod. Battle work remains separate/unreleased.
Removed mandatory Kanto Gear assertions from two old cart QA drivers.

Native Crystal head-card QA now PASS (single battle commands, move selection,
HP damage; /tmp/firered-hd2d/crystal-heads.log). Provider integration corrected
to mod.find exports rather than nonexistent Game.mods facade access.
Shared pixel font/UI refinement in progress; final reruns under
crystal-heads-final and battle-ui-final. Independent projected pairs/mirroring,
behind-camera and whole-object clearing tests PASS. Full doubles native QA
and Gen1 native overhead-card QA remain outstanding.

# Battle reference correction — 2026-09-22 (UNCOMMITTED)

Authoritative latest reference: user attachment /home/admin/Downloads/lbDmiO.png.
Silver status cards must stay ABOVE EACH POKEMON with downward pointers.
Four colored commands at lower right: Fight/PKMN above Items/Run. No red
screen borders or edge-anchored cards. NO species-dependent sprite scaling.
Keep native sprite artwork; 2.5D vegetation, 3D architecture/street props.

New FireRed Gen3Battle/Gen3BattleHud stage runs behind native sprites using
ordinary engine draw seams. High-resolution cards follow native sprite alpha
bounds; commands preserve native selection with presentation-only direction
mapping. Native special prompts and animations retain their owner. This is
NOT yet world-space/depth-tested FireRed battlers or exact Gamma parity.
Whole-object battle-area/camera-corridor hiding replaces fragment clipping
that left sliced building fragments. Field restoration rebuilds geometry.
Native 0.2.73 1440p QA PASS: /tmp/firered-hd2d/battle-whole-clear.log,
commands, moves, HP damage, stage during actions, unchanged player position,
return to field. Screens in matching battle-whole-clear directory.

Shared BattleTheme, projected BattleHudAnchors and public battlePresentation
hudAnchor export added for Gen1/2. double-battles-gen2 companion owns its own
HUD changes and consumes these public exports. Cross-generation head anchors
and companion theme still await native QA at this checkpoint. No release,
version bump, commit, push or cart re-pin. User profile untouched.

Street prop native QA: /tmp/firered-hd2d/street-props-final.log PASS18 views
of Pallet/Saffron mailboxes, Pallet/Fuchsia/Safari fences and signs. Flat-native
Crystal flora QA PASS8 scenes255 flower cells18 views. Extended FireRed flat
flora views need rerun after Route1 fixture correction. Broad all-map scenery
and native tree art parity remain incomplete; source census is not approval.

# Native 2.5D plant correction — 2026-09-22 (UNCOMMITTED)

User rejected the experimental rounded flower/grass/shrub relief: they want
FLAT 2.5D, and specifically like FireRed's original assets. Respect this
steering in the continuing scenery audit. Do not restore SceneryRelief or
invent replacement flower heads. Gen3Outdoor now emits ONE intact native
16x16 card for each flower/grass/shrub tile. Source under/over layers are
composited with only border-connected ground removed; native flower updates
still refresh this texture. Crystal flowers use ONE 8x8 native animated card;
grass uses coplanar native outline runs, preserving the shared opaque atlas
slot for decorative floor uses. SceneryMask owns the shared alpha flood.
All cards carry the existing canopy shader anchor: fixed static-view angle,
face first/rotating third/battle views. No crossed cards, domes or side skirts.

The rejected new Gen3FieldProps/SceneryRelief files were removed. FireRed live
rocks/boulders/items still use native sprites via the existing actor renderer;
no gameplay owner was changed. ItemPokeballs.lua has no new diff this batch.
Crystal material work from the interrupted scenery turn remains: preserve
native grass/path/water/stone/cave/paving RGB and patterns, with small grain;
flowers no longer reserve invented pink/white swatches. Shoreline material
now uses its native sand donor's colour. Existing tree illustrations remain;
this correction does NOT finish native-tree or all-map scenery parity.

ChunkMesher's indexed auxiliary builder now retains optional canopy anchors.
Crystal auxiliary meshes bypass the legacy six-float disk stream rather than
silently losing these anchors. Terrain/other generations retain their cache
paths. Immediate Cut blanking determines six/nine-float stride from the mesh
and clears the complete vertex. Cache revision67. No release, version bump,
ZIP, push, cart re-pin or changes to the user's running profile.

Native QA and current verification recorded below after runs finish.

# In-progress exterior rebuild — 2026-09-22 (UNCOMMITTED)

Latest user approved Lavender Tower's TOP SHAPE and requests a square base
that fills its footprint and touches elevated FireRed terrain. Implemented:
Gen3TowerExterior now has a full 112-wide square podium, height48; native door
stays front-only. Windowed upper volume, green dome and antenna are unchanged.
Gen3Terrain raises 23 reviewed General cliff/cap/corner IDs to32-unit rock
masses, with continuous4-unit steep bevels and native cap/face materials.
Tower-contact edges stay full-height; consumed source dome rows behind its
actual base are NOT treated as solid podium. Walkable floors, jump ledges,
collision and source map cells remain unchanged. This is a cliff presentation
pass, not complete multi-level walkable terrain or cave-mouth support.

No new release/version bump/ZIP/cart pin. All runtime changes since beta3
remain uncommitted on Legendary-Additions. Stable Crystal cart/user profile
untouched. All-building/Gamma Emerald parity is NOT complete.

Gen2Exteriors runs before generic columns. Whole roof/facade patterns cover
244 source placements across77 outdoor maps: Johto colored square brick and
plaster buildings, brown timber roofs, Kanto masonry and small houses. Crystal
Centers have square slab roofs, source brick colors and native front signs.
Kanto small houses now put the upper window band in the roof, not an extra
storey (roofRows4). Side/rear walls repeat masonry, not window tiles. Cache65.
Fallback Gen2RoofShell straight pitches/thin tiles and aligned ridges remain.

Gen3Civic plus data/gen3_exteriors.lua now cover103 whole drawing placements
across76 outdoor maps.38 data families, plus shared gyms/Centers/Marts.
Includes town houses, Viridian chimneys, Saffron Mart, One Island Center.
Gyms flat with narrow bevel; correct wall/roof/entry separation; no doubled
under/over walls; native-derived side/rear siding/windows. Lavender Tower
matches its8 upper rows in connected Route10 as well as7 Lavender rows:
the dome is actual native architecture, not an invented flat lid. First
claim removes source art from the ground. The native per-map census cannot
attribute this connected-map continuation without extra context.

TreePresentation adds TREE TRUNKS flat/solid, defaultflat; live invalidation
on both generations. Flat trunks share canopy pivot with depth separation.
TreeIllustrations isolates the largest alpha component per crown quadrant,
removing floating neighboring fragments. All owned art unchanged.

Native QA is actual0.2.73 AppImage payload /tmp/johto-hd/appimage-0273-qa.love,
not the stale source helper checkout. Runner /tmp/firered-hd2d/run-native.sh
accepts GAME DRIVER SHOT_DIR LOG [IDENTITY], QA_NATIVE_TIMEOUT default200.
Crystal identity battle-art-crossgen-qa; FireRed firered-hd2d-qa. Both QA mods
source-symlink repo. Never run same identity concurrently. No running QA jobs
at this handoff update. Native art/fixtures/screenshots stay outside repo.

Completed native evidence under /tmp/firered-hd2d/:
- exterior-turntables-crystal-all/:244 placements /976 views (initial timeout
  then resume). Older Kanto house roof corrected later, see kanto-roof-final/.
- exterior-turntables-firered-all/:93 placements /372 views, before new tower
  and8 extra city/route matches. extra-civics/22 placements88 views;
  extra-civics-final/13 placements52 views after chimney/emblem fixes.
- lavender-terrain-final/:11 placements44 front/right/back/left captures,
  includes final square tower base and corrected cliff UV tangent.
- terrain-normal/:12 normal first/third-person views, no inspection override,
  lavender/route10/viridian; native map cells unchanged. PASS.
- exterior-normal-crystal/:27 normal static/first/third-person views across
  Ecruteak/Pallet/Olivine. PASS. Turntables override the inspection camera;
  actor sizes/orientations in them are NOT normal player-camera verification.
- Source inventory exteriors-{crystal,firered}/:77+76 original outdoor maps.
  source-sheets-* contact sheets created; ONLY Crystal sheets1-4 inspected
  so far in the broad catalogue pass. Do not claim every image reviewed.
- Current inventories: crystal-exterior-final-audit.log (388 maps),
  firered-terrain-final-audit.log (425 maps). Summarizer passes all388,012cells.
- Pure tests: gen2_exteriors, gen2_roof_shell, gen3_civic, gen3_terrain,
  gen3_adapter, gen3_gym, tree_illustrations pass.105/105 shapes and181/181
  support pass against current0.2.73 source with old helper tests on LUA_PATH.
 Changed Lua compilation and targeted tests pass; validator on actual0.2.73
 retains the same6 MK301 findings. Old Apps validator with default repo falsely
 rejects gen3: pass --repo /tmp/johto-hd/engine-0273 and old tests on LUA_PATH.
 QA inventory JSON export is now local/pure (no networking-module dependency).

Private authoring helper /tmp/firered-hd2d/author-exterior-families.py rebuilds
native-ID-only family data from source-reviewed rectangles. Private
model-count.lua outputs244/103 and per-map review queue; pure fixtures and
native PNGs must not be packaged. Source/map catalogue is NOT visual approval.

Docs/ledgers updated for current unreleased snapshot, including153-map
exterior queue (all whole-map visual signoffs still pending).

Remaining work: specialty landmarks, gatehouses, omitted roof variants,
all-map visual review, full connected-map/streaming edges, unsupported interior
families, native fallback scenes. No all-building perfection or finished
Gamma Emerald parity claim. Review docs before packaging. Use gh with explicit
--repo notquiteog/DramaticShapeVoxelMod if later publishing. New runtime/data
files must be included in candidate ZIP and exact-package native tests.

# Published beta3 verification — 2026-09-22

Published https://github.com/notquiteog/DramaticShapeVoxelMod/releases/tag/v1.21.0-beta.3
Runtime commit03eff022d6b1e355ccff9497671b2d4853df54b6. Prerelease, not latest.
Exact ZIP /tmp/firered-hd2d/BATTLE_ART_VOXEL_FORK-1.21.0-beta.3.zip:
580 entries,7,791,193 bytes; SHA256
58ad7488bcc0d69779667d597970401057b4d20cd7f13b8e183d913ab4417264.
GitHub uploaded digest verified equal. Source/runtime files in this ZIP were
compared byte-for-byte with the staged source before the runtime commit.

Final exact-package native QA on actual Linux0.2.73:
- packaged-beta3-gyms-final.log: PASS32 views, all8 main gyms plus Fighting
  Dojo, full footprint assertions and unchanged native map cells.
- packaged-beta3-outdoor-final.log: PASS27 views, native flower clock/material
  refresh, metal corners/vertical runs and both wooden end posts. The driver
  now includes border cells and finds a safe viewpoint around fence ends;
  earlier incomplete runs failed to find fixtures, not runtime models.
- Images in gym-exteriors/ and outdoor-details/. Visually reviewed Saffron's
  final signs, Fuchsia's side wall/corner fences and Cinnabar's exterior.
  Saffron signs mask their actual shaded/pale paving swatches separately;
  grass-only masking left paving at their rounded top corners.
- Changed Lua compiles; outdoor/gym/adapter/roof/furniture/known-gap tests pass.
  Existing181 support and102 shape results remain in support-beta3.log and
  shapes-beta3.log. Final validate-beta3-final.log has the same6 pre-existing
  MK301 findings; it is NOT clean validation.
- firered-tile-audit-final.log:425 maps,60 pairs,150 eligible scenes,96 whole
  props on19 maps. Final ledger has2,115 fence cells/102 rows;66,740 unreviewed
  cells/4,191 rows. All240,512 cells accounted for. Crystal inventory and nine
  radio-room source checks are described below; no sealed-cart revalidation.

The QA FireRed mod folder contains this exact ZIP's contents. User live profile
and stable Crystal cart1.13.1/BA1.20.3 remain untouched. Do not repin the cart to
this preview. Many FireRed buildings, rocks/cliffs and specialty interiors still
remain flat; some building side walls have visible shadow artifacts. Optional
FireRed post effects and battle integration remain unported. All-map visual
perfection/Gamma Emerald parity is not complete. Next work should use the
committed tile ledger's actual examples, not blanket collision-based guesses.

# Tile coverage and FireRed gym exteriors — 2026-09-22 — beta3 candidate

Latest steering: user wants every tile in Crystal/FireRed covered. Then flagged
GYMS; clarified FireRed and EXTERIOR. Prioritize the exteriors, not gym puzzles.
Answered training-data question honestly: Oak's lab is common Pokemon knowledge;
actual fix came from the local map, with no claim about specific training items.

Current source version1.21.0-beta.3, not yet published at this record's creation.
Stable Crystal sealed cart remains1.13.1/BA1.20.3. Live user profile untouched.
Do not claim all tiles/models or Gamma Emerald parity are complete.

New runtime:
- Gen3Buildings matches whole gym drawings across6–8 columns, including all
  eight Kanto gyms and Saffron's Fighting Dojo. Missing top strip139/13A/13B
  and wider facade155/15D caused holes/flat strips. City-specific trim is only
  claimed in a complete pattern, including Saffron's secondary facade. Uniform
  closed shell, cropped roof background, straight gables, projecting entrance.
  Side/rear courses/high windows added; window UV cropped to exclude signage.
- Whole notice-board recipes include context-scoped Saffron variants. Models
  only change drawing; native collision, scripts, doors and battles untouched.
- Gen3Outdoor: reviewed horizontal/vertical/corner/end post/rail fences,
  low2.5-unit turf/sand ledges, short
  flower/grass rosettes, crossed shrubs and backed signs. Flowers refresh the
  derived atlas from the native tile-animation clock; no private cache reads.
- Initial lab furniture/wall displays; shallow closed interior walls. Large
  machines/planters still flat, gym interiors remain native.
- IMPORTANT: beta2's environment gate was insufficient. Cached cave defs say
  TOWN. Pairs.supports now prefers native mapType. Corrected eligible scene
  count is150, not258. Native Diglett's Cave fallback is regression-tested.
- Crystal desk terminal now matches the WHOLE counter/monitor ahead of the
  taller equipment recipe.1F desk,5F machine and Lavender desk all place;
  all82 furniture recipes have matches. Cache58.

Audit: docs/TILE_COVERAGE.md and docs/coverage/{crystal,firered}-tiles.csv.
Native totals:388 Crystal maps/147,500 cells/2,295 distinct treatment rows;
425 FireRed maps/240,512 cells/11,146 rows. FireRed96 props on19maps.
Every map cell accounted for, NOT all-map rendering or visual approval.
Raw maps/recipe records in /tmp/firered-hd2d/tile-audit. Summarizer checks sums.

QA helper /tmp/firered-hd2d/run-native.sh takes game, driver, outputdir, log,
optional identity; internally uses correct cwd /tmp/johto-hd/engine for U.
Actual engine0.2.73 fused QA payload, software GL; NEVER stale source as runtime.
FireRed QA mod path contains the extracted beta3 candidate; beta2 files moved
outside the mods directory to /tmp/firered-hd2d/installed-beta2-backup.
Crystal standalone QA profile keeps its source symlink. No sealed-cart test.

Source checks:37 FireRed scene captures under outdoor-views; nine radio-room
captures under radio-views; gym-exteriors captures across8cities; outdoor-details
fixtures and flower clock/material refresh. Final packaged gym/outdoor checks
include cutout notice boards and source-reviewed vertical/corner/end fences.181 support and102 shapes pass in
support-beta3.log/shapes-beta3.log. Geometry/adapter/furniture tests pass.
validate-beta3.log contains the same six pre-existing MK301 findings, not clean.
Private source atlas/layout images under gym-catalog and catalog stay untracked.

Remaining: vast city/landmark/interior/rock/cliff/decoration coverage in both
engines, all states/cameras, FireRed optional post effects and battle integration.
Side-wall shadow aliasing and some native pixel art remain visible. Do not let
ledger completeness or matched recipes become an all-map visual sign-off.

# City/roof follow-up — 2026-09-22 — 1.21.0-beta.2

Published: https://github.com/notquiteog/DramaticShapeVoxelMod/releases/tag/v1.21.0-beta.2
Runtime commit c8c0ec2c6f0ebb805770b130765c086e43a801df. Prerelease, not latest.
Exact ZIP: /tmp/firered-hd2d/BATTLE_ART_VOXEL_FORK-1.21.0-beta.2.zip
569 entries, 7,638,611 bytes. SHA256:
11eb3b63db413e2670de87eb7f525b505ca18657edbdf826cbca059b8c23e7a0.
GitHub uploaded digest verified equal. Exact extracted package passed native
1440p roof QA (packaged-beta2.log) and additional first-person close rear
views (rear-close.log, rear-close/oak_lab_rear_1.png through rear_3.png).
Rear wall is closed without internal fins; shadow-edge aliasing and plain
side/rear materials remain visual polish work. Final static scan is recorded
in validate-beta2-final.log with the same six existing findings.

Latest user steering: not every roof is curved or hipped; Oak's Pallet lab needs
its chimney and no grass folded into the building. Then reported lines off
lab's back. Fixed roof type and cropping; removed internal divider walls that
could protrude through the cutout roof background. Inspect rear views as well
as the front. A closed outer shell remains. Do not reintroduce global curves.

Beta2 changes:
- Gen3Scene uses Renderer:setWorldOverride at frameRects display resolution.
  Old beta1 rendered into the low-res world canvas and lost HD texture detail.
  Native UI and battle transitions stay native; battle/field smoke passed.
- Gen3Tilesets resolves generated primary__secondary names on cached boots.
  Versions.TILESET_PAIRS lacks most dynamic entries after import! Do not read
  ROM offsets or private cache to recover them. Environment gates caves/ships.
- General common Mart/Center/civic and Viridian houses; initial Building-primary
  room/furniture profiles (tables, chairs, counters, cabinets, TV, PC, bed).
  Whole-pattern extraction, no collision guessing. Many decorations remain flat.
- Gen3RoofDetails: flat lab, straight gables, grass silhouette masking scoped
  to reviewed art (green Viridian roofs preserved), source top-row crop,
  modeled shaft/cap/recessed flue, exposed shell only. Back walls closed.
  Ghost actors outside built terrain are culled, never ticked by rendering.
- Crystal Structures splits adjacent Johto houses at real ridge16/17/18,
  not palette7 bricks below windows; roof-height consensus scoped to roof edge.
  Paving47 and wall brick7 get muted materials. Cache57.

No source/input art committed. User's live pokemon-love2d profile untouched.
The sealed Crystal cart stays1.13.1/BA1.20.3; DO NOT claim it contains beta2.
This is an opt-in preview, not an all-map/Gamma Emerald completion claim.

Native actual0.2.73 evidence (/tmp/firered-hd2d):
- candidate-views.log:33 captures,5 outdoor maps +3 homes +native Oak lab
  interior fallback, camera/foliage/movement/resolution handoff assertions.
- roof-1440p.log and roof-1440p/: flat lab/chimney at2560x1440, static,8free,
  3rear views. Rear center camera is partly occluded by neighboring house;
  oblique rear images expose the lab shell. Source driver protects QA identity.
- crystal-city-views.log and directory:45 captures5towns,3static+6free each;
  native stacked-house/window-brick regression and foliage assertions passed.
- coverage-beta2.log: census425FireRed maps/60pairs;258 eligibleHD scenes,
  67props on10maps. Counts are NOT all-map visual approval. CSV containsIDs
  and counts only. Private native composited atlases in catalog/ are QA-only.
- battle-beta2.log: native wild intro reaches command, engine abort, HD return.
- support-beta2.log181/181; shapes-beta2.log102/102; adapter/roof/material tests
  pass. validate-beta2.log has same6existing MK301 findings, not clean validation.

Pending: other FireRed city-specific facades, fences/rocks/ledges/flora,
remaining home variants and specialty interiors, optional post controls and
battle integration; Crystal large landmarks/specialty interiors, zero-match
radio terminal and broader map/state/camera review. See both coverage docs.

# FireRed preview — 2026-09-21

Published: https://github.com/notquiteog/DramaticShapeVoxelMod/releases/tag/v1.21.0-beta.1
Runtime commit488442e82c348a1bd7151d3cf0377f8ae9d53b45. GitHub prerelease,
not latest; latest stable remainsv1.20.3. Exact ZIP7,636,744 bytes:
/tmp/firered-hd2d/BATTLE_ART_VOXEL_FORK-1.21.0-beta.1.zip
SHA25648acfd985d4f1137592016b776fe9cf937caf4571113163200a6695da1430c09.
GitHub uploaded asset digest verified equal. Packaged native QA PASS in
/tmp/firered-hd2d/packaged.log with13 captures under packaged-views/.
Driver now selects safe walkable positions before screenshots and waits out
the location banner. Reviewed final Route1, Viridian first-person and Crystal
regression images. FireRed QA mod folder now contains the exact extracted ZIP
instead of the earlier source symlink. Do not overwrite this published tag.

New user request: make this work for FireRed too. Added 1.21.0-beta.1 as a
separate opt-in preview; DO NOT repin the Crystal sealed cart to this preview.
Existing stable BA1.20.3/cart1.13.1 remain the user's Crystal release.
See docs/FIRERED_SUPPORT.md for the exact scope. Do not claim FireRed full
visual parity, completed interiors, staged battles or companion compatibility.

Actual installed engine0.2.73 supports FireRed. The source checkout at
/home/admin/Apps/Gen1Recomp/source is stale and its old ModTargets rejects
gen3 in ANY manifest. Use /tmp/johto-hd/engine-0273 (actual AppImage payload).
Minimum engine bumped to0.2.73 because older loaders reject the gen3 token.
QA fused payload /tmp/johto-hd/appimage-0273-qa.love remains actual0.2.73 with
scripted cart handling / PlatformHooks driver updates, not an engine port.

Gen3Integration branches before all legacy installs. It wraps native
FieldView.draw and scopes native Tilt off around Display.present. Gen3Scene
uses shared Voxel3D/ShadowMap/Mat4/Gen2DepthTrees/Gen2Trees with native
Tileset/Sprite providers. No new ROM-cache reads or shipped imported pixels.
General outdoor trees and Pallet buildings are mapped; other art stays flat.
Interiors/caves, doors, healing, shop camera and special effects fall back to
native. Battles are not patched. First/rotating-third-person maps BOTH
wasPressed and isDown through native Player.update. A failed/unsupported GPU
must also stop remapping movement. Foliage fixed in static modes, facing in
free modes. Neighbor ghosts are never ticked from the renderer.

Native QA profiles created (copies of imported inputs, no live saves):
/home/admin/.local/share/firered-hd2d-qa and battle-art-crossgen-qa.
The user's /home/admin/.local/share/pokemon-love2d was read-only.
User's canonical US1.0 FireRed ROM already existed in Apps; reused its imported
firered cache. None of that art/ROM is committed or included in the release.

Evidence in /tmp/firered-hd2d:
- views.log and views/: thirteen mode screenshots across Pallet/Route1/
  Viridian/starting bedroom, native eastward movement10->12 from camera-up,
  real key3 dispatcher and canopyFacing assertions PASS.
- battle.log: native wild intro reached command, screenshot, engine abort
  and 2.5D return PASS. This is not a combat/multiplayer test.
- crystal.log and crystal-regression.png: actual0.2.73 Crystal New Bark
  terrain/trees built, Gen3 export absent; separate no-cart QA boot.
- crystal-support-final.log:181/181 using actual0.2.73 modules and old test
  helpers via LUA_PATH. Gen3 adapter contract and Crystal roof tests pass.
- validation-final.log: same SIX pre-existing MK301 findings, no new findings.
  Need old test helpers in LUA_PATH when modkit targets extracted payload.
- All changed Lua compiled under system LuaJIT. Full Python checker lacks
  lupa in system Python; use LuaJIT directly or the dependency runtime.

Rendering bugs caught/fixed during QA: roof pixels live in native overlayer,
wall-bottom column walk must include preceding walls, camera movement must
rotate newly pressed directions too, and native get(pair) rebinds animation
so repeated neighbor lookup must not restart the active animation clock.
Remaining: map/prop profiles, sign alpha edging, material/detail parity,
FireRed native effect adapters, battle staging, controllers/touch free look.

# Roof update and fresh coverage — 2026-09-21

Published BA1.20.3 and cart1.13.1 (do not overwrite releases).
BA commit4b40e97f2a68f17d1be993e8f524699d8a6d894c;
ZIP SHA256714f81a4899df2889444b3d6df518a38632c7ae629dc6c83e0ae2eafda8247d0.
Cart commit11b7b8d0b5ee672fdbae2720f0124f8a528cece1;
G1RCART SHA25639189929c3b8fde0849ed566afc2e041f0bceb4d03d49ddb05c69056f9e818f8.
Both release URLs are under their respective notquiteog repositories.
Exact packaged-cart boot PASS: /tmp/johto-hd/cart-1.13.1-final.log,18 views
in New Bark/Celadon at1440p on0.2.73. Runtime asserted13 loaded pinned versions,
Crystal/sealed+, hidden Wilds HUD, full-body backs default and cache56.
Reviewed Celadon's final ceramic finish. Bundle bytes match committed cart
source/CG3 label, QA installed bundle and index; BA hash matches exact ZIP.
cartkit online validation passed after BA publication; archive was not rebuilt.
 User asked whether EVERYTHING was perfect:
answered NO. Never claim complete visual parity or exhaustive verification.

Gen2RoofShell now curves the existing pitched slope, adds ceramic pans/rolled
seams, overlapping lips, a rounded ridge and modest projecting eaves with
closed soffits. Original facade collision/footprints stay native. Gen2Materials
uses a coherent muted town glaze, tile14 for Johto/JohtoModern pitched roofs,
tile5 for Kanto. Flat rooftop geometry unchanged. Cache56. Static/free-camera
foliage modes from1.20.2 are unchanged and asserted in the new roof driver.

Native actual0.2.73/1440p evidence:
- /tmp/johto-hd/roofs-final-1203:45 views,5 towns,3 static+6 free angles each.
- /tmp/johto-hd/coverage-1203: census388 maps,35 tilesets,1,549 furniture
  matches;81/82 recipes placed. Generic wall cells31,353 in1,236 signatures
  include normal walls, not just missing models.
- /tmp/johto-hd/tileset-review-1203.log:35 representative native scenes built,
  none lacked walkable cameras; screenshots2560x1440. Coverage driver now sets
  window size, clears dialogue and resets the mode per map. Earlier
  tileset-views-1203 screenshots had stale-frame/dialogue artifacts and are NOT
  the visual review set. Kanto material finalization is in this second survey.
- Geometry tests cover closed stepped seams, ceramic relief, eave/ridge bounds,
  one ridge per column, outward winding on both roof halves, material scope.
- Style isolation, cache40, tile-shapes95, support181 pass. Six existing MK301
  ROM-cache findings unchanged; validation is not clean.

See docs/CRYSTAL_VISUAL_COVERAGE.md for visible work still required: irregular
large/joined building proportions, vivid/repeated city walls/paving, specialty
interiors, and the unmatched radio-terminal recipe. Roof finish does not fix
those building-volume decisions. No native gameplay, multiplayer or companion
logic changed. Only disposable QA profile modified; live user game untouched.

# Latest correction — static vs free-camera foliage — 2026-09-21

User's final mode rule: static third-person/diorama levels1–5 keep ALL trees
and bushes fixed; first person6 and rotating third person7 face the camera.
Battles retain camera-facing foliage from the earlier explicit request.
CanopyBillboard uniform canopyFacing uses fixed normal(0,.6,.8) in static
views and the live eye in free views; wood uses the matching plane. VoxelScene
sets the mode BEFORE shadows, BattleScene sets it for battle, both view/shadow
shaders receive it each draw. Cache55 unchanged. GPU test checks static cards
are pixel-identical as the eye moves with projection fixed, plus four headings,
overhead, unchanged solid geometry and upper wood behind leaves.

Published final releases (do not overwrite):
- BA1.20.2: c96cb325cd1b5c3935cbc76177812e93d1bd2f5c
  SHA256 57da080064880b55daca9806f88489d1c6a7a025065562d3a82885d9e284e564
- Crystal sprites2.1.0: c4857687bd665a56d7dd59698bd860216d545492
  SHA256 9432787d25476ccf5ce63309efefad794ba6fae877f710013e6bf73ad2aa192f
- Cart1.13.0: 43b18fd7d81c115ad1e4f42cf34a3d7fd5008327
  SHA256 77ddd9b88be4cc4e936fc19a471b2202d91df1e22a4a9b716a9b42634d91d123
Cart pins BA1.20.2 and sprites2.1.0, full_body_backs=true; both manifest and
index updated. All13 release pins verified online by cartkit. Release assets
and checksums live on the respective notquiteog GitHub repositories.

Exact packaged-cart verification PASS on actual 0.2.73 Linux AppImage:
/tmp/johto-hd/cart-1.13.0-final-1202.log and matching screenshot directory.
Asserts Crystal/sealed+/13 loaded pinned versions/hidden HUD/full-body default/
cache55, GPU static/free-facing and rooted upper-wood occlusion;18 world views
across New Bark/Route29 and5 staged species, animation/shiny/opt-out fallback.
Reviewed static New Bark and rotating-third-person screenshots at2560x1440.
Healing/mount native checks and pure regressions remain recorded below.
Only disposable johto-appimage-qa profile changed; live user game untouched.

# Working checkpoint — illustrated tree cards / 0.2.73 — 2026-09-21

User's FINAL tree direction supersedes the anchored multi-layer prototype:
use flat illustrated foliage. One card per tree; NO 3D cap/cheeks/stacked crowns.
Billboard in yaw AND pitch for overhead, 1ST, 3RD and battle views. Original trunks/boughs use negative anchor Y to keep upper wood behind its own foliage plane; grounded bases stay unchanged. Same art/recipe for border fill. Three tree families plus
low shrubs and cut saplings remain. VertexCanopy stores anchor X/Z/Y now; negative Y marks upper-wood
occlusion and zero means ordinary solid geometry. Cache55. Each tree
uses six streamed foliage vertices (two triangles), down from up to216.
Native shadow pass includes the foliage card for its existing nearest section.

User pushed the previous batch: BA1.20.0, Sky Ride0.2.23, Double Battles0.9.4,
cart1.12.1. Crystal full-body provider was still uncommitted/unpinned. Current
batch prepares BA1.20.1, sprites2.1.0 and cart1.13.0. Earlier local 1.20.1 zip
and 26a4149 crown prototype are superseded and MUST NOT be shipped.

Native QA uses the actual 0.2.73 AppImage payload/binary from the user's Apps
folder, extracted at /tmp/johto-hd/squashfs-root. QA main.lua alone is patched:
script boot honors --cart; driver updates call PlatformHooks.update(Game,1/60).
Runtime/cart scope asserted. System LOVE uses ~/.local/share/love; AppImage
uses ~/.local/share. Only disposable johto-appimage-qa modified; no live user
profile/input. Old /tmp files disappeared between sessions: historical logs
are not current evidence.

Evidence before the final archive verification:
- tree-depth-0273.log runs GPU four-heading + overhead/local-anchor/unaffected
  solid geometry plus upper-wood depth checks,18 world views at2560x1440 across New Bark/Route29,
  then five staged species entered with 1ST selected.
- heal-mount-0273.log PASS: six native healing balls in Center/Elm machine,
  horizontal bed alignment and animation completion; follower-backed Raikou,
  cropped rider in diorama/3RD, no rider in1ST, dismount restores native player.
- Pure style/geometry, Legendary trees141, mesh cache40, support181,
  Gen1 heal63 and battle-occlusion group/depth/floor tests pass.
- Installed modkit reports SIX MK301 ROM-cache findings. Every reported file
  was byte-identical to pre-change HEAD. Do not call validation clean.

Crystal sprites2.1.0 finishes last session's stagedPokemonSprite provider:
502 normal/shiny BW back atlases for251 species,36,469 nonempty frames checked
for dimensions/timing. Generated art is release-only; URLs/hashes and credits
accompany it. Cart enables full_body_backs; standalone default stays off.
Native 0.2.73 checks: animated/shiny Cyndaquil, Totodile, Chikorita, Raikou,
Ho-Oh and option-off fallback. Native menus retain Crystal art.

Limits: paired allied commands and multiplayer doubles remain unfinished;
no Internet test. Exact Gamma parity, all maps and hardware performance remain
unverified. Wilds still emits occasional existing pose-fallback warnings.
Release hashes and exact packaged-cart verification go in the follow-up.

# Working checkpoint — target input, encounter ownership, dialogue look — 2026-09-14

Published BA1.19.1, Double Battles0.9.3, cart1.12.0.
BA runtime ae0c0fc71825609fb157de54686f7dd94e019f5f; ZIP SHA256
5705c92215d0dc3b0a6167626f5b9d5cafe80027d273ea7b52c06e237204baec.
Double Battles9ec5d57f3762d1f74aa6ae358cebce08c3438820; ZIP SHA256
f2f9f12acf0f79b46f860761811c34431e79010e99a6ab35ebef3cbde69e81fc.
Cart77a8f7f15220bf39a8f376cd1f064358b75535c4; cart SHA256
07c86143d1e26e50a328aae1523a243456b1ce128fbe44e4e4f137ebf239e17b.
Latest user asked whether general doubles logic and multiplayer were fully
finished/verified. Answered NO explicitly. Crystal normal UI still commands
one player-side active; paired ally command collection and full spread-move/
doubles mechanics parity remain unfinished. Online+ pvp/session exchanges one
action per player; no doubles network protocol exists. Do not claim online
2v2 support or a two-computer Internet playtest.

Double Battles: new gen2_target.lua wraps native submit/update. A move enters
opponent selection only while two living enemies exist; directional aim, A
confirm, B cancel, no PP/turn consumption until confirm. Modern HUD renders
choices and highlights selected foe. Core already honors action.target.
Automatic wild partners now require the scoped World.tryWildEncounter ->
rollEncounter(kind=wild,terrain=grass/water) -> startBattle origin. Scope restored
on errors/return; direct mod, visible spawn, fishing and special calls remain
singles. Partners use matching terrain table; SOMETIMES now rolls its30% chance.
Trainer auto-decoration also requires current World.startBattle scope: Online+
and native link set pvp/link flags AFTER Battle.new emits battle.started, so a
flag-only guard is too late. No runtime reads of another mod's private files.

BA: FirstPerson.looking separate from driving. Crystal world scripts and only
text-box stacks allow look; movement retains original busy/stack gates. Menus,
battles and text over another screen do not grant world-camera ownership.
Public input.gamepad and input.pointer carry Gen2 stick/touch alongside mouse.

Validation (disposable AppImage QA profile, 0.2.60 update, core.update enabled):
- /tmp/johto-hd/target-093.log PASS: supplied spawn/fish mon identity/HP retained;
  native random doubles; choose either target via native input, cancel no PP;
  selected damage only; next mod spawn cannot inherit random origin. Screenshot
  target-093/target_second.png reviewed at2560x1440.
- /tmp/johto-hd/dialogue-1191.log PASS: modes6/7 mouse/stick/touch yaw while text
  stays up, no walking, script VM gate permits look, start menu blocks look.
- /tmp/johto-hd/pvp-guard-093.log PASS: two LOCAL Online+ engine/session peers,
  trainer_doubles=true, no auto-decoration,3 mirrored singles rounds match HP/PP.
  Transport is an in-memory test adapter; Internet transport is NOT tested.
- Pure target/cancel/fainted fallback/link tests + HUD DPI/animation capture;
  native engine core39; BA support181 and camera/inversion/movement guards PASS.
- Old native-actions regression uses an explicit pair fixture now; direct mod
  encounter doubling is deliberately removed. It is not a new native-run claim.

Only johto-appimage-qa updated; user profile/live save untouched. All13 source
and index pins match and online packing passes. Exact released archives installed
in QA; cart-1.12.0-final.log asserts real cart scope, Crystal/sealed+/1.12.0,
BA1.19.1,13 companions, hidden HUD, and repeats the full dialogue-camera PASS.
Native log confirms Double Battles0.9.3 loaded. Runtime ZIP predates this
handoff-only follow-up. Previous published checkpoint follows.

# Working checkpoint — scenery + reproduced glitchmon — 2026-09-14

Published BA1.19.0, Online+0.5.5 and cart1.11.0.
Cart source bc51249d04b1e8f49c661a01a1ec6b32e2d5e03b, release v1.11.0.
BA runtime b3d16b195062c175e6ec83631b121457622329db; ZIP SHA256
342e552d1c1287ba4e8d0503a8d1c4a7e406a067bdefd15008d3f2fd096c7b35.
Online+ eb06b95d9124ae691622fde3a390592c8e5a5405; ZIP SHA256
ad5c22f4a848ba074fca75a8e37132beb8e84209b88a7e742b0e7a7d92844074.
0.5.5 normalizes numeric Crystal time-of-day IDs for standalone offline
encounters (0/1/2/3 -> morning/day/night/night); pure roster tests pass.
The cart delegates offline encounters to Wilds. No BA runtime change after1.19.0.
BA: actual crystal_center_healer now horizontal (Elm's earlier separate recipe
was already fixed); PokéCom healer uses bed recipe. Native sign components share
their ground baseline and a shallow backing joins the cap. Capped roof courses,
subtler roof materials, curved side foliage for rotating views, and a free-camera
only upper room enclosure for INDOOR maps. Cache48. Native40-view review passed:
/tmp/johto-hd/camera-scenery-shell.log and image folder; Center placement checks
in center-sign-roof-final.log. Pure geometry/roof/bed/style/material/furniture and
support181 pass. Scenery driver skips story/encounter triggers for visual QA.

ROOT CAUSE REPRODUCED: user confirmed the brown sprite in live X11 window capture
(/tmp/johto-hd/user-game-window; read-only capture, no user inputs injected).
Online+'s core.update job rerolled its offline roster every frame; towns with
empty grass lists randomly inserted/removed rare slots. Eight corrupt rare
entries (New Bark/Cherrygrove + aliases) spell species T/M/C/S with letter-valued
levels and fell back to SPRITE_PIKACHU, whose Wilds placeholder is Charmander.
Native old-code log live-hook-motion.log records repeated NEW_BARK_TOWN_obj_301/
302 with species T/M. It was spawning fresh actors, so per-object displacement
probes could not detect it. Online+ candidate validates species/levels, keeps a
per-visit roster, consumes claimed local entries, removes corrupted database
rows and yields offline wild/follower ownership to Wilds via exported capability
API. Server encounters remain when connected, removed on disconnect with Wilds.
Native copied-save900 frames PASS in live-hook-fixed.log; ambient stays and
adding Cyndaquil leaves exactly one follower. No live server test.

CRITICAL QA CORRECTIONS:
- Actual AppImage profile is /home/admin/.local/share/pokemon-love2d, NOT its
  sibling love/pokemon-love2d. User files untouched. Copied to johto-appimage-qa.
- AppImage filename is0.2.59 but profile chainloads updates/gen1recomp-0.2.60.love.
  Thus patching ONLY AppImage main.lua did nothing! Copied update payload's main
  is patched for QA, no real user engine changed. Source and native059/060 World,
  Npc, Gen2Compat, SpriteRenderer are byte-identical; Game2 changed shader origin.
- POKEPORT_DRIVER skips core.update by calling Game:update directly. For motion
  verification the disposable driver's update branch MUST call
  PlatformHooks.update(Game,1/60). This runs Online+'s actual Jobs.step.
- Script shortcut also ignores --cart. In disposable launcher only, change
  `if scripted then` to `if scripted and not resolvedLaunch.cartSpecified then`.
  Assert SaveData.getCart()==johto_diorama. scope5.log proves it. Earlier cart-path
  checks that asserted only version/HUD did not prove scope in an updated fused
  profile; retain their geometry/input results, not claims about that scope.
- Run source LOVE from /tmp/johto-hd/engine. A repo containing main.lua can shadow
  the intended game even when the LOVE argument points at the engine.
- Support: from engine cwd, DS_MOD_PATH=mods/BATTLE_ART_VOXEL_FORK luajit
  /home/admin/Projects/DramaticShapeVoxelMod/tests/gen2_support_test.lua.

Final 13-pin source/index equality and online cart pack pass; cart SHA256
a0f271d699f43878d1bcad901163f74a3e85c2bce0e12ec416bb37186edbde82.
Packaged native camera-key test with core.update enabled passes all angle
levels, first-person activation, saved choice and menu blocking in
/tmp/johto-hd/cart-camera-diag.log. An earlier failure was a queued text/menu
screen in the copied profile, correctly blocking the hotkey. QA drivers now
clear initial mod greeting/UI after settling before entering free roam; their
explicit menu gating assertion remains. No camera runtime regression found.

Final exact packaged 13-mod cart + normal update hooks: 40 views PASS in
/tmp/johto-hd/cart-camera-scenery-final.log; screenshots in matching directory,
reviewed outdoor/indoor contact sheets. Driver reached final PASS; the launcher
was ended by its timeout during shutdown (not a clean-exit claim). Initial
visual fixture failure was a queued text screen; clearing it after scene settle
fixes the fixture, without changing production menu behavior.
All three towns PASS with Online+0.5.5 in cart-1.11.0-final-055.log: no duplicate
Online actors, one follower, ambient retained. Exact pinned archives installed
ONLY in johto-appimage-qa; user profile and live game untouched.
The camera fixture updates after runtime1.19.0 are QA-only and are not in that ZIP.

Remaining: exact Gamma parity, broader
map/texture polish and hardware performance are not claimed complete.

# Published checkpoint — cart1.10.0 / camera3 restored — 2026-09-14

Released/pushed:
- BA1.18.0 runtime79f0d9a131871f946f601e89ffd4c81bac4146f6;
  ZIP SHA4641547e91f285fcc6d702c196294cb122540f6f97e20e458218d91ead5c5f98.
- Online+0.5.3 e1f4b69b29e16c0fea1c67c9249f80f0fa8aa520.
- Wild Skies1.12.2 c65703c992149d62dd1419a0f3d7cc7f0becf190;
  fork notquiteog/wild_skies, local wild-skies-gen2.
- Cart1.10.0 cb0e39a, Crystal sealed+,13mods,CG3 unchanged.
  SHA346358ac8f8e142d535c052914c94d89160995e1e0e8893ea63454493b590d2b.

Actual packaged cart-path camera test PASS:
/tmp/johto-hd/cart-1.10.0-camera.log. Asserts BA1.18.0 and cart HUD option0,
then real love.keypressed3 reaches first/thirdperson, persists choice and
refuses menu presses. Log confirms all three new companion versions loaded.
Exact bundle/source equality and online pin/hash validation pass. Index meta
pins/load order synchronized. QA cart copied ONLY to johto-parity-qa profile.

Source 1440p doubles attack/KO/escape/animation/party regression PASS:
/tmp/johto-hd/gaps-battle.log. Packaged keyboard test also passes independently
in packaged-camera-1.10.0.log. Five-map/cache/crown evidence and open issues
below remain accurate. Runtime release zip was built before this handoff-only
commit. Do not claim the bouncing actor or exact Gamma parity is fixed.

# Working candidate — camera key and known-gap fixes — 2026-09-14

Latest user request: 3 no longer changes camera including first person.
FIXED: live Game2 has no game.overworld. main.lua now uses pipelineGate and
public input.key before native TILT claims 3. Native keyboard regression passes
levels 4,5,6,7,0,2,3,4 from FULL, first-person activation, persistence and menu
gating: /tmp/johto-hd/gaps-camera-2.log. Gen1 wrapper retained.

BA1.18.0 candidate: native static snapshot/cache rules; open Park bench/bin,
actual radio-desk placement, Center counter-ball crop; shallow illustrated crown
caps; Dark Cave fractured wall surface and floor material. Cache rev47. Pure
support181, furniture47, HD60, geometry and new known-gap tests pass. Final
native five-map test /tmp/johto-hd/gaps-visual-4.log passes 164 RAM records with
encode/decode/warm reload. Screenshots reviewed. Not persistent disk proof.

Online+0.5.3 candidate omits unsupported Gen1 map_scripts registry on Gen2;
Casino Lounge map remains unported. Wild Skies fork1.12.2 candidate imports MIT
upstream release1.12.1, corrects (def,tileset,x,y) collision calls for neighbouring
maps; native seam11 tests pass. Local repo wild-skies-gen2 / origin
notquiteog/wild_skies. Original MIT LICENSE retained.

Bouncing Charmander remains OPEN despite user confirming New Bark/cart1.9.0.
New 900-frame x3city depth/flat probe /tmp/johto-hd/gaps-motion.log found no jumps.
Wilds uses a Charmander placeholder for SPRITE_PIKACHU, but a leaked actor is
only a lead. No speculative clamp or follower hiding. User gameplay save is
not present in the disposable QA profiles. Broader Gamma parity and hardware
performance remain open. Cart1.10.0 packaging/publication is next.

# Published checkpoint — Crystal 2.5D / cart 1.9.0 — 2026-09-14

Latest user request is completed for Crystal: removed the scenery-style
selector and voxel/source alternatives; always use layered 2.5D scenery.
Gen 2's camera row is 2.5D CAMERA. Keep its stable internal pipeline ID for
saved-camera and companion compatibility. Fresh profiles activate FULL on the
initial boot; explicit camera settings including OFF are retained. Optional
2.5D LIGHT and Depth of Field remain separate. Gen 1 retains its rendering.

Published runtime commits / versions:
- Battle Art 1.17.2: 585ed1b72328a4decacffb8dd5717daa035c5b0b.
  ZIP SHA256 88afb747e2e30435595af70fdf6a52c7c4c7162635b648880d000e3871483417.
- Double Battles 0.9.2: 7620f92b3bbf13485318b48e6b454f0607c5e774.
  Source HEAD dbf5484 is a later QA-driver-only update for removed style API.
- Sky Ride 0.2.22: 669a27fe12b3a1cf92b96b9a04929e6b813b6bc9.
- Cart 1.9.0: 2ff63883f743689f766a2979b0792979f52f7f2d.
  Cart SHA256 2a048bd7d53785e6d40888430d12dba3cefea0063214249f250904c0d03b0577.
  Crystal sealed+, CG3 cover, all thirteen pins retained. Wilds HUD option0.
  No obsolete crystalStyle pin. Online pack validates all release pins;
  exact bundle/source bytes and index metadata match.

Final packaged cart test PASS:
/tmp/johto-hd/cart-1.9.0-hd2d-verified.log and corresponding screenshot folder.
Fresh disposable profile, actual cart launch path, 2560x1440: camera level1
and saved options asserted BEFORE driver camera changes; hidden HUD asserted
from cart options, no manual override; removed style API, legacy values,
scene rebuild, source collision preservation, optional light and DOF pass.
The one-line disposable launcher adjustment below is necessary because the
engine's script shortcut discards --cart; no engine source was modified.
Packaged 16-map/19-view scenery PASS: packaged-scenery-1.9.0.log; packaged
1440p battle attacks/paired Sentret/KO/escape/party PASS: packaged-battle-1.9.0.log.
Those two run BA1.17.1; 1.17.2 changes only camera label and fresh-save pipeline
activation. Final source support181 passes. No Android/hardware GPU testing.
Only johto-parity-qa and johto-hd2d-fresh-qa profiles were used/updated.

The 1.17.2 fix uses the EXISTING Voxel.seedOptions FULL preset in save.created
and immediately applies it when newly seeded, matching save.loaded behavior.
No extra game.ready callback remains. Previous temporary 35-degree/level3
assertions below describe investigation, not shipped code.

Remaining: exact Gamma Emerald parity, generic architecture/props (including
Park benches), high-angle foliage and hardware performance. Fast bouncing
Charmander remains un-reproduced. Known Online+ Gen1 map-script and Wild Skies
defCellTile warnings remain. Do not claim every object perfected.

# Final default-camera check — 2026-09-14

1.17.2 changes the Gen 2 camera label to 2.5D CAMERA and applies the newly
seeded camera in save.created. Game2 restores pipelines BEFORE emitting its
boot save.created event, so the existing FULL default was recorded but not
activated for that boot. The seed helper still preserves an explicit OFF.
Fresh imported profile johto-hd2d-fresh-qa now passes pre-driver camera-level
and options assertions, then fixed-style migration/1440p/shader checks:
/tmp/johto-hd/fresh-hd2d-default-6.log. Support181 passes. Earlier attempts
incorrectly expected level3; the existing default is FULL (level1, 35 degrees).

The strict cart-HUD check originally failed because engine scripted boot
ignores --cart and passes nil into bootGame. A disposable main.lua copy in
/tmp/johto-hd/release-engine changes only its scripted-branch condition to
`if scripted and not resolvedLaunch.cartSpecified then`; this routes --cart
through the normal validated startLaunchRequest path while retaining the
frame driver. Engine source and user profile untouched. Actual cart-path
1.17.1 boot passes /tmp/johto-hd/cart-1.9.0-final-cart-path.log. Re-run with
packaged 1.17.2 and publish cart1.9.0 after updating pin/hash.

# 2.5D-only Crystal presentation — 2026-09-14

Latest user steering removes the voxel style and its selector. 1.17.1 makes
crystalHD/crystalDepth unconditional for native Gen 2 maps, removes the
crystalStyle row/registration and selectable opaque-canopy path, and ignores
legacy saved style values. Gen 1 keeps its established rendering path. Optional
2.5D LIGHT / Depth of Field remain. Cart should carry no obsolete crystalStyle
pin option. Gen2 depth_style_driver now checks the fixed default, ignored old
saved values and optional shaders instead of cycling the removed row.

Packaging audit caught main.lua was accidentally omitted from 410b452's
staging list: published 1.17.0 lacks optional-light pipeline registration and
the battle-ended hook despite having their modules. Both entry-point changes
must be INCLUDED in 1.17.1. Do not claim 1.17.0 alone fixes these two features.
Doubles runtime0.9.2 is correct; its QA driver was adjusted in the source repo
for the now-removed style API (no runtime change / no new pin needed).
Native tree role QA now inspects S.roundStamps instead of sandbox-invisible
_G registries, so cut/bush counts become meaningful.

# Lower ledges follow-up — 2026-09-14

User judged the six-pixel mound crest too tall. 1.17.1 lowers it to 2.5 pixels,
retains its three-pixel footprint and smooth profile, and scales all six source
dirt rows over the shorter unjumpable face. Cache revision46. Collision and
jump permissions unchanged. Cart 1.9.0 is not yet published; update its Battle
Art pin from the just-published 1.17.0 to 1.17.1 before publishing it.

# Working release candidate — 1.17.0 / cart 1.9.0 — 2026-09-14

Current working tree adds layered 2.5D foliage, low shrubs / retained Cut
saplings, essential-crown LOD protection, matching twelve-tile forest fill,
44 furniture recipes, 16 floor finishes, small flowers / low Park rims,
unequal reef clusters, native rock-ground selection, soft wet-sand shores,
and rounded mound ledges with the outward dirt face preserved. Optional
SceneFinish world lighting + existing DOF leave UI outside the composite.
Battle stage persists until its native screen is popped. Cache revision 45.
Generated original crown PNG / prompt: assets/crystal/depth-crowns-v2.*.
See docs/CRYSTAL_1_17.md for coverage and explicit remaining work.

Companions: Double Battles 0.9.2 defers HUD during animation BG bakes and draws
it once after FX. Sky Ride 0.2.22 restores main_55_gen2_test_gift.lua in parts.txt
at the user's request. Scientist (9,10), New Bark: grants missing owned-species
level-50 Ho-Oh/Fly, Suicune/Surf, Raikou and Gyarados/Surf only on interaction.
No boot gifts or save deletion. Cart source selects crystalStyle=depth and
Wilds catch_hud_size=0; publication/pin synchronization still pending here.

Actual evidence this checkout: /tmp/johto-hd/tree-npc-final.log (16 maps/19 views,
NPC presence/no auto-gift, trees/roofs/furniture/live fruit/rock ownership),
scenery-final.log (8 views, 255 flowers, native shallow Park rims, varied reefs),
depth-final-2k.log (style switching and optional shaders), battle-final-2k.log
(native damage, both Sentret, survivor/party ownership, animation HUD, KO/escape
stage lifetime). Latest mound-only rerun: ledge-mounds.log. All-map inventory
and screenshots: all-maps-depth + all-maps-tail (373+15=388). The first run hit
its time bound; tail rerendered from map374. No unavailable walkable cameras.
Inventory 79 recipes, 77 placed, 1,447 placements. All-map sweep predates final
foliage/shore/Park fixes; focused native checks cover those final changes.
Pure support181, doubles39, trees110, HD60, furniture44, floor16, flower/shore/
rock/mound/roof/staged-pair/HUD tests pass. No Android/hardware GPU validation.

Still open: fast bouncing Charmander un-reproduced (stationary three-city
probe in charmander-probe.log had no species/jumps); exact Gamma Emerald
parity, remaining generic props/architecture (notably Park benches), high-angle
foliage, and hardware performance. Known Online+ registry warning and Wild
Skies Gen 2 defCellTile mismatch remain; optional cache writes reject but GPU
owners survive. Do not claim complete visual coverage from map smoke tests.

# Release checkpoint — cart 1.8.0 — 2026-09-13

Cart source 8a947c9 pins Battle Art 1.16.0 (eb332ca); the other twelve pins,
Crystal sealed+ and CG3 are unchanged. Pack SHA256:
fc470d8e8b165b2330a307d4e32474d8327c96d2eba70a3a1bad71eceb887b67.
Online validation and exact source/pack byte equality pass. Packaged full-cart
boot loads 1.16.0, reaches game.ready and submits first frame:
/tmp/johto-hd/cart-1.8.0-boot.log. QA release-engine now uses extracted 1.16.0
under packaged-1.8.0 for Battle Art; companions still packaged-1.7.0. Only the
johto-parity-qa cart was updated; no real user profile touched.

# Scenery and roof-shell pass — 2026-09-13

Battle Art 1.16.0 (eb332ca), published: original RGBA foliage-sprays-v2.png with prompt and
built-in generation provenance beside it. Larger outer sprays, smaller inner
crowns and hashed species choice; sparse bounded meadow cover. Crystal HD
sunlight uses a nine-tap tent filter and cool shadow fill, with Gen 1/source
lighting branch preserved. Corrected plaster tile 50 ->27 after native New Bark
map inspection; tile50 is terrain. Blue-gray windows and warm timber retain
source silhouettes. User reported roof holes: pitched tops had no side closure
above run.h. Gen2RoofShell now shares corner profiles with the mesher, closes
exposed gables and differing adjacent heights; shared interior faces omitted.
Johto roofed flanks/rears now use wall art instead of folded roof rows.
Mesh cache revision43. Geometry, collision and native map data remain separate.

Actual software-GPU checks: 16-map/19-view scenery pass at
/tmp/johto-hd/roof-final.log, including east/west/rear roof views;
previous art pass /tmp/johto-hd/parity-final.
Native 1440p doubles damage, paired rendering, survivor promotion and party
ownership PASS at /tmp/johto-hd/parity-battle-2k.log (before roof-only change).
Pure roof/ground bounds and exclusions, scenery9, HD60, tree108, support181,
item balls, bin/bed, staged pair and Lua syntax pass. Known Online+ map_scripts
incompatibility remains recorded; not a zero-warning boot. No Android hardware
verification. Complete prop coverage, better encounter-grass art, architecture
geometry, caves and exact Gamma Emerald parity remain open. Do not claim full
parity based on this incremental scenery release.

# Release checkpoint — cart 1.7.0 — 2026-09-13

Final pushed pins: Battle Art 1.15.3 (35c7fad), Double Battles 0.9.1
(c391673), Sky Ride 0.2.21 (6349c56). Cart source 0488bf3, Crystal sealed+,
CG3 unchanged, thirteen mods. Packed SHA256:
67bcc0dd8475521b3b4f109f2b4e6c243edc0e551c64b9dc3952ffabe40436c1.
Online validation passes. Pack bytes equal cartkit.bundle_bytes(source).
Extracted release ZIPs passed native BattleState.submit, damage, two same-
species rendered actors, survivor promotion and owned-party checks at
/tmp/johto-hd/doubles-cart-1.7.0.log. 1440p source build evidence is
/tmp/johto-hd/doubles-2k2. Current packaged QA engine is release-engine,
mods point to /tmp/johto-hd/packaged-1.7.0. No user profile was installed or
modified; only johto-parity-qa cart was replaced. Do not use unreleased
1.6.1 artifacts; those were intermediate builds before UI/facing feedback.

# 1440p framing and facing correction — 2026-09-13

User caught mirrored player back art and requested a more expansive 2K view.
Gen2Staged now returns noMirror for the native back slot; BattleScene expands
its own Crystal lens by 1.25 + widescreen delta (about 1.45 at 16:9). External
camera ownership is preserved. Double Battles 0.9.1 renders its compact HUD
at full-window edges with scale capped at4, outside the old handheld scissor;
font DPI follows that display scale. First 2K attempt clipped the edge cards:
fixed with scoped setScissor reset. Latest complete 2560x1440 native battle
passes at /tmp/johto-hd/doubles-2k2.log, screenshots in doubles-2k2. Both
Sentret and the corrected Cyndaquil facing are visually verified. Scenery and
lighting still fall short of Gamma Emerald; do not claim exact parity.

# Modern doubles UI follow-up — 2026-09-13

User requested a modern battle UI, then correctly pointed out incomplete
Sentret sprites and blurry text in the first comparison. Doubles 0.9.0
owns its native-panel HUD/menu/move/dialogue renderer in lib/gen2_hud.lua;
Battle Art 1.15.2 honors usesModernDoublesHud() to omit legacy backplates.
Fonts use the actual panel transform scale as glyph DPI (7px logical,
35px raster at scale5), fixing magnified antialiasing. Missing iw2/ih2 in
Gen2Staged caused paired textures to fail: now reads each image size.
Two-Sentret real screen check passes, both staged.drawn entries asserted,
image /tmp/johto-hd/doubles-sharp/doubles_menu.png. Labels/HP and move PP,
survivor promotion, native damage and party ownership verified. Original
special prompts remain native. Explicit enemy aim and player pair command
collection remain future work; don't imply full modern doubles mechanics.

# 1.15.1 scenery / gameplay hotfix follow-up — 2026-09-13

Scenery changes: Gen2Trees stable crown rotation/height/width and exposed
boughs; smaller leaf sprays, mipmapped original foliage; Gen2GroundEdges
bounded 0.35–1.5px turf fringes over Johto dirt tiles; roof courses and lab
wood in the HD atlas. Source/collision untouched; mesh cache revision 39.
Full 16-map/19-view comparison passes at /tmp/johto-hd/polish2; pictures
reviewed for New Bark and Elm. Pure geometry/material/ownership suites pass.
Buildings and vegetation still need substantial work for Gamma Emerald parity.

User interrupted with opponents immune to damage and an unowned level-50
Ho-Oh after fainting. Doubles 0.8.0 was ignoring the native {kind=move}
action shape. Fixed in its own repo 0.8.1 with survivor promotion and owned
party loss/replacement tests (39/39). Real native BattleState.submit damages
foes and promotes the survivor: /tmp/johto-hd/doubles-fix.log. Sky Ride's
temporary test giver grants level-50 Ho-Oh on interaction; removed from its
production entry list in 0.2.21, no existing save mons deleted. This is an
identified source, not proof the user interacted with it. Fast overworld
motion remains un-reproduced/open. No Android verification.

# Release checkpoint — 2026-09-13

Published and pushed: Battle Art v1.15.0 (031e26d), Sky Ride v0.2.20
(c70b36f), and JohtoDioramaCart v1.6.0 (0359aba). Cart SHA256:
255626a4f9012f50533541f6335a4ce85e706d300743e209124b7b4768cf4ccf.
Mod archive SHA256: bd34b99f643d803fe31b6d8052933b15cd17445b9edb72bfc49e2a6320349945.
Sky Ride archive SHA256: e75d1d16c49f11198ae0b208180926281677097b70e199ec7c0b26519466f94e.

Online cart validation checked all thirteen published pins. The actual cart
launch (--game=crystal --cart=johto_diorama, no driver) loaded the thirteen
packaged versions in pinned order and reached game.ready. A separate driver
against the extracted release packages passed real rendered water/camera
checks, both rungs moving east from (7,5) to (9,5). Art/CG3 bytes preserved.
Logs: /tmp/johto-hd/packaged-cart.log, packaged-camera-water.log and
cart-validation.log. Full scenery screenshots: /tmp/johto-hd/review2.
The separate Sky Ride owner-delegation regression passes; its older generic
load test could not run against this import because it tries Gen 1 Data.load
and requests text_pointers.lua. Do not claim that fixture passed.

Fast ground/water Pokémon report remains open and broad scenery coverage
remains iterative. Neither was represented as fully fixed in release notes.

# Crystal 1.15.0 follow-up — 2026-09-13

Prepared after 1.14.2: smaller item balls, horizontal Elm healing bed, open
lab bin, original foliage atlas and distinct family UVs, irregular grass,
native imported animation frames and native camera-relative Gen 2 grid walk.
Sky Ride companion 0.2.20 delegates its older onTop bridge to providers that
advertise supportsGen2World; this fixed the observed mid-step camera drop.
See docs/CRYSTAL_1_15.md and CRYSTAL_FOLIAGE_ART.md for scope/provenance.

Fresh checks: full 16-map/19-view driver passes (/tmp/johto-hd/review2),
camera/water GPU driver passes (/tmp/johto-hd/camera-water6), SDK 181 support
and 95 shapes, pure geometry/ownership checks. Current 13-companion QA engine
is /tmp/johto-hd/engine. Online+ still records its exact unsupported map_scripts
registration; do not claim zero loader errors for the whole stack.

User's cart-1.5.0 fast ground/water Pokémon report remains un-reproduced in
two instrumented current boots; /tmp/johto-hd/spawns*.log records water and
ambient guests. No Wilds movement patch made. No Android claim. Every prop
family is not yet bespoke: continue the 35-tileset coverage audit.

# 1.14.1 - Gen 2 doubles on the staged battle — 2026-09-13

Additive, released on Legendary-Additions (tag v1.14.1): when a battle
carries the double-battles fork's second slots (battle.player2 /
battle.enemy2), Gen2Staged composes BOTH mons into each side's staged
billboard card (lead left, partner right, same ground line) and
Gen2Battle's flat-panel skip covers both through the drawn table. Verified
in-engine: a wild double on Route 29 (Sentret joining Geodude, rolled
from the map's own table) stages both mons on the diorama while the
engine's text runs the round. Cart repinned as JohtoDioramaCart 1.3.3. The doubles follow-up shipped
the same day: Battle Art 1.14.1 + double-battles-gen2 0.8.0 (second HP
plate, doubles default on) are ON the cart — JohtoDioramaCart 1.5.0
swapped Free Fly out for the dramatic-sky-ride fork (0.2.19: the Crystal
rider crop is verified through the engine's asset reader; Gen 1
untouched) and repinned gen1online-plus 0.5.2 (server connect-address
banner). Thirteen pins, boot-verified from the packaged files, stack
audit clean: no hard dependencies between mods, no cart-member conflicts,
all thirteen claim Gen 2, and the priority order is the pinned load
order (Crystal Animated Sprites outermost on pokemon.sprite). Remaining
in the double-battles fork: the player-side partner and aim menu; in
gen1online-plus: PVP 2v2 over the doubles2 contract.

# Crystal 1.13.0 / cart 1.2.0 released — 2026-09-13

The original interim corrections below have now been superseded. Branch remains
Legendary-Additions. Applicable DRAMALESS commits are cherry-picked; license
notice retained. Whole furniture recipes in data/gen2_furniture.lua replace
Mom's kitchen and lab furniture, with CPU-only support heights for warm-cache
boots. Gen2Ledges makes three-pixel lips/corners; Gen2Rocks models coastal,
ocean and live rock actors. See docs/CRYSTAL_1_13.md for scope and evidence.

Eleven-mod compatibility driver passed with all five requested additions.
Modern UI has been forked to notquiteog/gen2recomp and its unmodified upstream
archive published as v1.0.15 for an installable checksum pin. Modern Johto stays
optional/off by default. CG3 label copy prepared at JohtoDioramaCart/art/CG3.png
(512×512; original Pictures image unchanged). Cart base remains crystal and
seal remains sealed+. RELEASED 2026-09-13: branch Legendary-Additions pushed,
tagged `v1.13.0` and released on notquiteog/DramaticShapeVoxelMod with
`BATTLE_ART_VOXEL_FORK-1.13.0.zip` + `sha256sums.txt` (sha256
`70dce2c9…` — matches the cart pin). JohtoDioramaCart 1.2.0 committed
(df540b3), tagged `v1.2.0` and released with `johto_diorama-1.2.0.g1rcart` +
`cart_sums.txt`; index entry validates clean against the
gen1recomp-mod-index checker (tags trimmed to the 8-tag cap). Boot verified
from the packaged files: release g1rcart in a clean save's carts/ with the
pinned 1.13.0 zip as the installed mod — all eleven pinned versions load in
the pinned order and the game reaches ready (kanto_gear has no priority, so
loading ahead of Wilds proves the cart's load_order applied; driver boots
drop the cart by design — scripted boots call bootGame(version, nil), so the
in-engine cart-context asserts cannot run under POKEPORT_DRIVER; the
launcher-request boot `love . --game=crystal --cart=johto_diorama` is the
cart path). QA scripts/artifacts are /tmp/johto-parity and
tests/*cart_driver.lua; every pin's sha256 was checked against its published
release asset.

# Gen 2 parity in progress — 2026-09-13

Local branch `Legendary-Additions`, no new release yet. Battle background dim
and attack-animation clears are now gated by 3D-BTL (the earlier battleFit=fill
attempt was wrong: Game2.paintBattleSurround explicitly dims the margins).
Round border trees use the complete two-cell drawing; interactive bushes and
isolated cave rocks use one-cell hulls. Route 29's grass-capped lip classification
and fence post/rail routing are present. Gen 2 cache token refreshed.

Fresh checks: gen2 shapes 92, gen2 support 181, budget 35, storage 7; 158 Lua
production files compile. Disposable six-mod engine boots (source 2cc86d5,
llvmpipe/Xvfb, Free Fly published 1.8.2) captured a real Cyndaquil/Sentret battle
including 30 attack frames without white fill and without dark side strips.
Seven map driver checks show no unclaimed round scenery. These are desktop
checks, not Android. Some companion warnings still occur (Wild Skies Map API,
Wilds nil-sprite fallback); not claimed as a zero-warning gameplay session.

USER CORRECTION: furniture still too tall; Mom's appliances still laid out in
depth; fence/ledge corners remain boxes; ledges must be thin bars rather than
cell-wide raised shelves; rocks/boulders and low ocean barrier rocks need actual
models. Elm's Lab camera must stand on clear floor. Do not publish this interim
geometry. Fetch and integrate applicable upstream artyrambles/DRAMALESS_SHAPE
main commits (fetched through 97ca3e1); preserve Battle Art ownership/identity.
Their history has no common ancestor with this checkout, so do not overwrite the
fork with their renderer. Latest sprite-size and GBCFX fixes already exist here.

QA artifacts/drivers: /tmp/johto-parity; isolated engine there links local mod
and published companions. Base engine /home/admin/Apps/Gen1Recomp/source.
Save identity johto-parity-qa; imported test data in johto-shots/crystal.
Cart remains 1.1.2 with Battle Art 1.12.2 and Free Fly 1.8.1. Release/re-pin is
still pending after the corrected geometry is verified.

# Johto diorama: one-cell trees, outdoor-only volumes, per-map roof bake - 2026-09-12

Three faults reported on the JohtoDioramaCart after 1.12.1: bushes two
storeys tall, tree borders reading as growing into the walking path (New
Bark), and interior furniture -- especially tables -- way too tall. All
three were 1.12.1's two overcorrections (the 32px tree, the everywhere
volume reading) and all three are fixed in `lib/Gen2TileShape.lua`:

- `tree` is back at the class default 16px, one cell. The 32px box leaned
  two cells of screen space over the ground at the 35-degree camera, which
  read as a treeline growing INTO the path, and every bush -- bushes are
  the same class, wall collision over PAL_BG_GREEN -- stood two storeys.
- The volume reading is gated OUTDOORS (`TOWN`/`ROUTE`,
  `Palettes.ROOF_ENVIRONMENTS`). Indoors every solid answers `wall`, so
  furniture and the room's back wall were one region and ELM'S LAB's
  tables read their height off the room's depth -- 48px towers. The same
  gate covers `thin`, whose fence/sign reading had already made 68 fences
  out of DARK CAVE's rock when ungated.

A fourth fault was found while verifying and is fixed in
`lib/TerrainAtlas.lua`: the Gen 2 atlas bake keyed its cache on
`tileset.id # daytime # mode`, but `Palettes.bgSet` loads the BG palettes
per map group and rewrites the roof slot from that group's roof colours.
GSC's towns share TILESET_JOHTO, so the first town visited decided every
later town's roofs -- New Bark came up in Cherrygrove's pink after one
visit there. The key now carries the map id.

## Evidence, in this checkout

- `tests/gen2_tile_shape_test.lua`: 80/80. The two assertions that pinned
  the old behaviour were updated (`tree.h` 32 -> 16, `groundAt` 32 -> 16)
  and a new indoor block pins the volume gate (`wall.volume == nil` on an
  INDOOR map, `Structures.volumeClaims` false, isolated solids stay
  `wall` rather than fences/signposts).
- `tests/gen2_support_test.lua`: 163/163.
- LuaJIT 2.1 compile sweep: 141 production files, 0 failures.
- Real Crystal boots (engine source at HEAD, shipped-equivalent harness,
  Xvfb + llvmpipe, sandboxed POKEPORT_IDENTITY), screenshots at the FULL,
  35 and 75 rungs:
  - NEW_BARK_TOWN: green gabled roofs with doors in facades, one-cell
    treelines and bushes off the path, town signs low, NPCs on the ground.
  - ELM'S LAB: tables at furniture height, starter balls sitting ON the
    ball table, bookshelf racks proper, the healing machine ON its table.
  - PLAYERS_HOUSE_1F: the dining table low with the seated pair beside it,
    kitchen counters low.
  - CHERRYGROVE_POKECENTER_1F: the counter an 8px band with the machine on
    top, nurse behind it.
  - ROUTE_29: ledges 6px with their lip, tall grass as tufts on flat
    ground, the fence one cell wide and low, tree borders off the path.
  - VIOLET_CITY: gym's plank roof and facades correct, one-cell tree mass
    (174 cells) with no plateau and no gable.
  - Roof regression order: CHERRYGROVE -> NEW_BARK -> VIOLET in one
    session keeps each town its own roof colour (this was the pink-roof
    reproduction; it stays green now).
- Known gaps unchanged: animated tiles (water, flowers) are coloured but
  still; Cherrygrove's water-edge wall boxes carry their own art and are
  read at the volume depth their drawing gives -- not part of the report.

## Release

Bumped `manifest.json` to 1.12.2 (`mod.exports.version` follows the
manifest). Tagged and released as `v1.12.2` on notquiteog/
DramaticShapeVoxelMod; JohtoDioramaCart re-pinned.

# Imported upstream history (absol89 1.11.0)

# Desktop Test77 integration - 2026-09-17

Merged the user's `C:/Users/User/Desktop/Test77` into the desktop Legendary
Battle Art checkout on existing branch `1.11.0`, starting at `c66decf` with a
clean working tree. This is a local, uncommitted file integration; no deployment,
release, tag, push, or version bump. Manifest and exported version remain 1.10.9.

Imported Test77 capture recoil/facing, scoped translucent effects, battle fire
lighting, and the standing-trainer shadow callback in BattleScene,
CharacterRenderers, Voxel3D, and q57/Ballistics. Added the five supplied test-note
files and README introduction. The donor's notes describe historical paired
builds and validation, not checks performed here or installed companions.

Preserved newer branch implementations in BattleArt (Oak intro backsprite),
ChunkMesher (MeshDisk purge), and VoxelCompanion (false legacy-splice detection),
plus current main.lua and manifest metadata. Line-ending-only donor differences
were left unchanged. Destination-only files and assets were retained; donor
files were not modified. One existing sidecar test mock now includes the real
CharacterRenderers.revision API used by the imported shadow cache signature.

Evidence: `.claude/test77-merge/` contains before-file backups, starting commit,
SHA-256 inventory/decisions, merge script, validation script, and validation.json.
LuaJIT 2.1 compiled all 153 production/data Lua files. Existing mocked suites
battle_scene_visual_sidecar (37 checks), hosted_trainer_visibility,
stadium_models_api (18 checks), and atmosphere_companion_integration passed.
Scratch math checks passed recoil endpoints, finite trajectory/facing, and
shortest-arc turning. Git whitespace validation passed.

Not verified: actual game rendering, GPU shader compilation, battle/capture and
naming flows, companion-on/off and 2D behavior, or Windows/Android gameplay.
The documented D:/gen1recomp engine installation is absent on this machine.
No game/save/slot/map fixture was launched; no screenshots were produced.
No game process, player save, or game options were changed.

# Lavender Battle Art parity + exact bald-square fix - 2026-09-10

The previous follow-up targeted the wrong rectangle. The large 12x12
`pokemon_tower_top` claim on ROUTE_10 is the already-approved flower square and
must remain exactly as it is. The screenshot's grey/bald square is instead on
LAVENDER_TOWN: it is the synthesized floor beneath the Silph Scope sign at
engine cell `(9,3)` (source tiles `tx18..19`, `ty6..7`). The sign art stands up
as a billboard and claims those four source tiles, so the mesher has to choose
their replacement floor explicitly.

Battle Art Lavender now snapshots the CURRENT Legendary Lavender city treatment:
non-path ground uses the same vivid Route 10 green lawn geometry/material,
authored `$23/$39` path cells use the same lavender-grey path palette, and the
existing Tower flower landscaping is unchanged. That makes the claimed sign
floor at `(9,3)` plain non-checkered grass in both modes while preserving the
checker/path network beside it. The CITY GROUND modes remain separately keyed so
a future Legendary revision can diverge without taking this approved Battle Art
baseline away. Fuchsia is unchanged.

The earlier unsolicited `1.10.7` version bump was reverted: `manifest.json` and
`mod.exports.version` remain `1.10.6`. No tags are moved or created by this work.
No source map tiles, collision, walkability, warps, encounters, or Tower
flowerbed density/placement are changed.

# Lavender Tower lawn + Battle Art flowerbed - 2026-09-10

Historical note: `43d7922` made the existing Route 10 Tower flower landscaping
available in Battle Art too. That change is retained because the user wants the
large flower square exactly as it is, but it was NOT the grey-square fix. The
grey square is the Lavender Town sign-floor claim described above.

# Lavender approach ground + Tower flowerbed - 2026-09-10

The previously pending screenshot request is now implemented. On ROUTE_10 the
final eleven authored block rows (tile rows 100..143, Rock Tunnel's lower mouth
through the Lavender seam) are one continuous ground treatment: BATTLE ART
routes every flat ground donor through the existing sandy Kanto-road material,
while LEGENDARY GRASS routes the same coverage through the approved bright
Route 10 lawn. ROADS & BRIDGES can still retain its authored path material when
enabled, and CITY GROUND still has no ownership over Route 10.

This section describes the earlier `5e1d267` state. The current parity patch at
the top of this file supersedes Lavender's mode split: Battle Art now keeps the
same current bright lawn and lavender-grey `$23/$39` path palette as Legendary.
Fuchsia remains unchanged.

The flowerbed does not use guessed camera coordinates. `pokemon_tower_top` is
already the claim-only 12x12 tile rectangle on Route 10 that contains the upper
half of Pokemon Tower's source drawing; Buildings now records that exact matched
footprint. The follow-up Tower-lawn patch makes those animated flower standees
a Battle Art baseline too, while preserving the exact checkerboard/density in
Legendary. No source map tile, collision, warp, encounter or walkability data is
changed.

Persistent cache identities now use `route10-lavender-approach-v2-tower-lawn`,
`route10-tower-flowerbed-v2-baseline` (AUX), and `lavender-battle-parity-v5`. Static and
animated atlas map isolation remains unchanged. Headless validation: CITY
GROUND/Route 10 suite 50 checks, dedicated Lavender approach/flowerbed suite
216 checks, grass east-edge 15 checks, build-budget 35 checks, and voxel-storage
6 checks. All 114 production Lua files compile under Lupa's LuaJIT 2.1 backend.
Actual in-engine visual comparison is still required before release.

# LuaJIT TerrainAtlas compile-limit fix - 2026-09-10

The pushed `26845c9` Lavender build reproduced the Mod Manager failure under
Lupa's LuaJIT 2.1 backend: `lib/TerrainAtlas.lua:996: function at line 704 has
more than 60 upvalues`. This is a production LuaJIT 5.1 compiler limit, not a
Kanto First Person dependency failure; Fengari had accepted the same file and
therefore missed it. Cave-material and Lavender-material painting were lifted
out of `communityAtlas`'s large protected-build closure, reducing its captured
locals without changing atlas output. `tools/check_luajit_compile.py` now
provides a reusable pre-package compile sweep using Lupa's `luajit21` backend.
All 114 production Lua files compile under that backend after the refactor.

# Lavender authored path-network correction - 2026-09-10

Historical pre-parity state: Lavender CITY GROUND first preserved the original
`$23/$39` path network instead of flattening every walkable cell to one
material, but Battle Art still used a sandy family while Legendary used its
lavender-grey/green treatment. The current top-of-file parity patch supersedes
that material split while keeping the authored topology. Route 10 remains
outside CITY GROUND ownership; Fuchsia, map data, collision, buildings and
non-ground geometry remain unchanged.
# Release 1.10.6 - performance profiler producer API

Tag `1.10.6` is the published producer-API baseline. The branch continues to
advertise `1.10.6`; do not move/create a tag or bump the version unless the user
explicitly requests it.

# Performance monitor producer API - 2026-09-10

Branch `feature/performance-profiler-v2` exposes a stable read-only diagnostics
provider at `mod.exports.performance` for the separate `performance-monitor`
project. The monitor owns capture cadence, aggregation, reports and UI; Battle
Art only publishes domain-specific telemetry. No dependency on performance-monitor
was added.

API/schema v1 returns detached snapshots of LoadTimings buckets, RAM/cache state,
structured bounded cache events, ChunkMesher queue/cache pressure, Legendary tree
cache stats, shadow target state and sapling edit counters. Persistent cache
inventory is intentionally separate behind `storageSnapshot()` because it may call
storage.list and should not contaminate high-rate performance samples. See `docs/PERFORMANCE_API.md`.

CacheTrace now records a platform-neutral 64-event structured ring plus monotonic
counters while retaining its existing desktop text log. ChunkMesher exposes only
lightweight scalar/job descriptors; no map, mesh or coroutine ownership escapes.
Focused standalone Fengari validation: `tests/performance_export_test.lua` passes
16 checks; changed Lua files parse and `git diff --check` passes. Native engine
integration with the separate monitor is still required before merging.
# Issue #54 CITY GROUND option - 2026-09-10

Branch `fix/issues54` starts from clean local/remote master `04b8643` (1.10.5).
Issue #54 separates Lavender/Fuchsia city turf from the broad Legendary GRASS
choice. New `CITY GROUND` defaults to `BATTLE ART`; `LEGENDARY VISUALS` keeps
the existing custom city treatment. Lavender's previously unconditional custom
ground now follows this row, while Fuchsia's existing tiled Legendary turf is
selected by CITY GROUND instead of GRASS. Other Overworld maps continue to use
GRASS unchanged. The new row lives under Legendary Visuals > GRASS & TREES and
uses the existing CommunityVisuals live invalidation/persistence path.

City-specific static and animated atlases are map-scoped so Lavender and
Fuchsia cannot reuse one another's baked OVERWORLD animation entry by visit
order. Persistent city terrain fingerprints now include a city-ground contract
token and the CITY GROUND value while ignoring unrelated GRASS changes; other
maps do not gain a CITY GROUND fingerprint dependency. Cache record format is
unchanged, so cache revision remains 37.

Focused standalone validation used the temporary Fengari Lua CLI because this
Windows PATH has no native Lua/LuaJIT executable: `city_ground_option_test.lua`
passes 21 checks (default/ownership matrix, geometry selection, persistent
fingerprints and animated-atlas isolation), `grass_east_edge_test.lua` passes
15, `voxel_build_budget_test.lua` passes 35, and
`voxel_mesh_disk_storage_test.lua` passes 6. All changed Lua files parse and
`git diff --check` passes. `ram_precache_setting_test.lua` cannot run from this
standalone checkout because its engine-side `tests.modkit` fixture is absent.
Native LuaJIT/engine gameplay and actual Lavender/Fuchsia visual comparison are
still required before release. Draft branch is prepared for desktop QA; no deployment or cache-revision bump.

# Local PR #52/#53 integration — 2026-09-09

Branch `codex/legendary-pr52-pr53-integration` starts from the user's local
master `b435d467b55b1c743a13193e794e3dcce5e8b1a2`. Integrated PR #52
`936b23a` and PR #53 `b94eaf3`. Resolved overlapping handoff notes and ignore
rules; production changes merged automatically.

Tower textures, backdrop and mounted-mod/physical-folder ambient audio reads
now use `assets/legendary/`. All 12 supplied PNG/MP3 files are present,
nonempty, ignored and untracked. No media added to source history. The donor's
`lib/` install notes below are historical; use the new path and retain filenames.
`backdrop4.png` is supplied alternate art; the runtime selects `backdrop.png`.
Manifest/mod identity stays at 1.10.5. Cache revision stays 37, with both the
Safari-specific refresh token and v5 auxiliary grass token retained.

Fresh validation: all 128 production Lua files compile under LuaJIT 2.1.
Thirteen existing suites pass (318 counted checks plus Safari wall/stair/foliage
assertions): Legendary cache/UV/settings, grass edges, build budget, disk
storage, Safari, ladders, Cut drop/mesh refresh, restored world hooks, OFF
storage/live hooks, heal overlays and reflections. The Windows harness's
rename-self directory probe prevented mod discovery; reran the two affected
suites with only that probe replaced in memory by a read-only host directory
check. No production or test files changed for this. Asset paths, exclusions,
cache tokens and unchanged manifest (normalizing line endings) verified.
These are headless/mocked checks; Android gameplay, GPU visuals, Tower memory
cost and frame time still require device validation. Earlier reports below
are historical. This integration is local; no remote push or master merge.

# Safari ground coverage and cache refresh — 2026-09-08

Complete olive treatment for flat grass tile94 and hedge/edge variants13,79,84–93.
Only four outdoor Safari atlases change; non-green detail/alpha retained on edges.
Native engine0.2.27 captured all four maps: 567 changed atlas pixels, all outside
new coverage unchanged; tile94 matches tile0 exactly. No Quest validation.
Map-scoped cache token prevents pre-PR51 shrub vertices from surviving the upgrade;
non-Safari fingerprints unchanged. No global cache revision bump.

# TEST138 grass-only integration — 2026-09-09

Applied only the post-TEST137 grass delta from Legendary grass update onto
`Legendary-Updates` at `bcb2f11`. The earlier cave merge is now committed there;
its prior uncommitted status below is historical. Grass changes remain local
and uncommitted, with no push or deployment.

Structures suppresses only exposed east tile-boundary grass caps. VoxelMeshDisk
advances the auxiliary grass fingerprint to v5; combined cache revision 37,
release identity, all other runtime files and assets remain unchanged.

15 focused synthetic geometry/cache checks, 19 existing cave/cache checks,
6 disk-storage checks and the Safari/stair regression pass under LuaJIT.
No Android visual/gameplay check. See
[the grass merge report](docs/LEGENDARY_GRASS_MERGE.md) for scope and evidence.

# Legendary Cave Update integration — 2026-09-09

Merged the supplied Legendary Cave Update into the clean `Legendary-Updates`
checkout at `335bef0`, using verified upstream tag 1.10.3 (`278862b`) as the
three-way base. Changes remain uncommitted; no push or game deployment.
See [the merge report](docs/LEGENDARY_CAVE_MERGE.md) for the file inventory,
conflict decisions, exact validation scope, local media and remaining checks.

Retained newer interface/title, museum/Safari, companion atmosphere, reflection,
heal and Cut integrations. Combined cache streams use revision 37 (new derived
cache build required). Tower defaults to Battle Art; saved Legendary trees keep
full detail and FAST is separate. Supplied PNG/MP3 files remain local in lib/,
excluded from Git; assets/ was not changed. The source input is untouched.

All 128 production Lua files compile. Eighteen standalone/mocked regression
commands pass, including 19 new cache/OFF/UV/setting merge checks. Existing
engine-dependent and real-map cave tests remain unavailable without their
engine/fixtures; Android gameplay and GPU visuals have not been verified here.
Donor TEST102–137 notes and all earlier handoff results remain historical.

# PR #51 merge verification — 2026-09-08

Merged PR head `1e07e7f` into current master `22f5b03` in an isolated worktree.
The merge is conflict-free. Only SafariFoliage.lua, TerrainAtlas.lua and this
handoff change; all other tracked files match the target branch, retaining
restored ladders, heal overlays, water reflections, immediate cut removal,
interface fixes and PR #50 companion atmosphere support.

Fresh Lua 5.1/LuaJIT headless checks passed: cave ladders, heal overlays, water
cast reflection, cut drop/mesh refresh, restored pipeline hooks, precache OFF
policy/integration, Safari walls/stairs/foliage bounds, museum fossils, NATURE
underlay, build budgets, disk storage, interface install/playback (3174 checks
plus 5 modern title checks), atlas decoding, native anchors, companion atmosphere
integration and camera/projection facts. Syntax and whitespace checks pass.
Initial harness working-directory/arg errors were corrected and those suites
rerun successfully. These checks are mocked/headless, not device visual tests.
The PR author's 3.2x shrub geometry cost remains a mobile/Quest performance
limitation; their desktop capture claims above were not repeated in this audit.

# Safari canopy palette and pixel shading — 2026-09-07

Safari shrubs now use fixed one-world-unit surface pixels, connected edge/lower
shadow patches and checkerboard transitions. Color assignment precedes greedy
face merging, preventing stretched texture marks. Voxel occupancy, placements,
collision and draw-call count are unchanged; solid swatches remain 6x1.

The shared FOREST tree canopy receives the existing olive mapping only inside
the four outdoor Safari maps. Bark, alpha and other maps retain their original
colors. Native atlas comparison found 578 changed leaf pixels and no other
pixel changes.

Validation: native desktop engine 0.2.27 paired captures passed without stderr.
The representative Center scene contains 86 shrubs: 266,996 vertices versus
83,564 in the previous material/geometry (about 3.2x). This is the approved visual
prototype, not a Quest performance clearance. Texture-chart optimization should
preserve the approved appearance before a Quest release; Quest/GLES and exact
0.2.53 gameplay have not been tested. No live installation or cache schema change.

# Companion atmosphere extension — 2026-09-07

Optional draft effects API: owner-scoped resources, per-eye queues, bounded
atmosphere state, desktop camera facts and native celestial fallback.
See docs/COMPANION_ATMOSPHERE.md for contract and validation limits.
The official 1.10.4 tree-lift flag no longer falsely blocks registration.
No manifest/cache bump, companion art/runtime, or gameplay changes.

# Requested world-feature restoration — 2026-09-06

Audited the active `DramaticShapeVoxelMod` checkout on local `master` at
`278862b`, loaded by `mods/BATTLE_ART_VOXEL_FORK` through its directory link.
Changes below are local working-tree changes; no commit, push or release made.

## Findings and changes

- PR #41 (`dfc177c`): newer `ladder_up`/`ladder_down` pins bypassed its
  standee geometry. Restored the original `ladder` pins and two-voxel prop
  depth. The newer shaft builder remains available but is not selected by
  the shipped cave ladder pins. This restores the requested source-art
  ladders without changing the game's warp or collision data.
- Heal alignment (`c083147`): `HealOverlay.lua` survived, but main.lua no
  longer called it and Voxel3D no longer exposed the required depth value
  and texture. Restored all three connections, including animation-state
  restoration when field FX throw.
- Player water reflection (`55e195d`): restored the planar cast canvas,
  reflected billboard transform, water-shader compositing and cleanup.
  The existing water setting and readable-depth/canvas fallbacks still apply.
- Immediate cut-tree removal (`7991ccee`): restored prop ownership spans,
  cached span serialization, targeted mesh uploads and the block-edit hook's
  coordinates/map/old-block arguments. Adapted span declarations to the
  current sink order and kept enlarged Legendary tree ownership on its
  authored cell. Unowned border geometry cannot extend a preceding prop run.
  Mesh cache revision is now 32 so pre-restoration records cannot be reused.

The cut fix retains the current terrain and neighbouring map caches and
removes the changed prop immediately. It still marks the edited map for a
budgeted background rebuild, just like the linked commit. This is not a
claim that all rebuild work or every possible frame-time spike is eliminated.
The format/ladder change requires caches to be rebuilt once after upgrading.

## Verification

Run from the engine root with `DS_MOD_PATH=dev/DramaticShapeVoxelMod`:

- `cave_ladder_test.lua`: 38 checks; updated its dead-pin check to recognize
  the newer explicit `sapling_tiles` detector metadata.
- `heal_overlay_test.lua`: 63 checks.
- `water_cast_reflection_test.lua`: 47 checks.
- `cut_drop_test.lua`: 22 checks.
- `restored_world_features_test.lua`: 22 checks covering actual registered
  pipeline calls, heal error recovery, the real Map:setBlock hook, the water
  pass/player transform connection and reflection error recovery.
- `cut_mesh_refresh_test.lua`: 10 checks covering table-sink spans, zeroed
  vertex uploads, retained drawable terrain and unaffected neighbour cache.

Run from the mod root:

- `voxel_build_budget_test.lua`: 35 checks.
- `voxel_mesh_disk_storage_test.lua`: 6 checks.

These are headless/mocked checks using the local LuaJIT/Lua 5.1 runtime, not
in-game visual, GPU-shader or Android performance validation. Lua syntax and
Git whitespace checks also pass.

Broader suites attempted but not passing: `battle_art_voxel_fork_test.lua`
exceeds Lua's 200-local limit; `voxel_visual_object_filter_test.lua` lacks a
CommunityVisuals fixture; `companion_main_uninstall_integration_test.lua`
has a platform fixture without `metalRenderer`. Those suites need separate
harness maintenance. Historical shaft-specific Astra ladder tests describe
the superseded ladder design, rather than this requested PR #41 restoration.

## Follow-up: platform-independent OFF and crash audit

Removed the unsuccessful iOS OFF-to-FULL override. OFF now skips all automatic
voxel cache storage probes/reads, preload planning, and speculative destination
work on every platform. Live geometry still builds cooperatively and its records
remain in session RAM, even without a persistent storage backend. Manual cache
generation/saving remain explicit actions. Added cancellation that preserves jobs
promoted to live terrain, and guarded the remaining direct GC call.

71 cache-policy checks pass, alongside the 243 earlier targeted checks. The map
audit completed Pallet, Route 1 and Celadon geometry against local Yellow data;
Celadon and Route 1 have materially larger geometry footprints than Pallet.
No iOS crash log was available, so memory pressure is a lead, not a confirmed
diagnosis. See `docs/OFF_MODE_CRASH_AUDIT.md` for exact semantics, measurements,
test coverage and the limits of these checks.

## Master integration — 2026-09-07

Fast-forwarded local master from `278862b` to `7743de9`, including PR #47
(museum fossils/cave corners) and PR #48 (Safari scenery/interior textures).
The remote advanced from two to four commits ahead during the fetch.

Reapplied all pending local edits and untracked documentation/tests, including
the user's manifest version `1.10.4`. The sole textual conflict was the cache
revision: upstream used 33 and the local span restoration used 32. The combined
geometry and record format now use revision 34. Local edits remain unstaged and
uncommitted; no push was made. A named safety stash retains the pre-integration
working tree.

The 314 targeted local checks pass on the combined code. Upstream museum,
Safari wall/stair, NATURE underlay, and real-map retaining cave/corner tests
also pass. The real-map test used local Yellow data. Syntax/whitespace and
unmerged-path checks pass; mobile gameplay remains unverified.

## Gen 4 tight atlas migration (2026-09-07)

Inspected `dev/gen4_front_tight-1.10.3` (770 regular/shiny PNG atlases).
Compared every frame against installed originals after a constant per-animation
translation: no altered visible pixels, clipped pixels, or empty frames. All
sheet dimensions match supplied metadata. Species, paths, timings and frame
counts are unchanged. No Unown PNG is supplied (existing metadata also refers
to an absent unown.png).

Merged only frame dimensions into both Gen 4 data tables, retaining original
sizes as legacyLayout. AnimatedBattleArt selects tight or legacy cells by exact
sheet dimensions, so incremental asset overlays remain compatible. No assets
were copied; the owner will overlay supplied assets onto the mod assets folder,
retaining files absent from the pack, then restart. Do not overwrite the merged
data tables with the supplied ones: that removes legacy compatibility.

Keep Summary BATTLE ART fitting: 580/770 opaque animation bounds exceed 56x56;
removing it overlaps name/HP/number UI. Existing fitting already uses scale <=1
and does not downscale artwork whose opaque bounds fit. Cropping preserves the
visible art size, so it cannot eliminate required fitting. Dex uses native
frames and benefits from reduced padding. Runtime/device visual QA remains
outstanding. Decoder and interface playback: 55 checks pass; metadata-only
comparison and Lua syntax checks pass.

## Interface scaling and Android title banding (2026-09-07)

Added INTERFACE SCALING: FIT/FULL (default FIT) beside INTERFACE SPRITES in
POKEMON ART. It applies to BATTLE ART Summary and Dex Image adapters. FIT uses
56x56 opaque-union fitting; FULL uses complete native prepared frames. Switching
is live and retains animation progress. FULL may overlap the stock screen UI.
Title rendering is independent. This supersedes the previous decision to keep
status fitting mandatory; the user explicitly requested FULL as a test option.

Android screenshot (user reports engine 0.2.56) shows horizontal bands on Ditto.
A suspected contributor is fractional display scaling of the title alpha-mask
true-color replay, previously one scissored pass per horizontal pixel run.
Coalesced identical consecutive runs into taller rectangles without changing
covered pixels or trainer exclusion. This reduces internal scissor boundaries
and draw calls, but is a mitigation, not a confirmed Android fix. Engine renderer
also has DPI-aware scissor rounding; device scaling and GPU behavior still need
verification. Ask tester to compare integer display scaling if bands persist.

Mocked interface/title tests: 3169 checks passed, including pixel-by-pixel mask
coverage, trainer occlusion, FIT/FULL live changes, and animation. Lua syntax and
git diff whitespace checks passed. No actual Android/device visual test performed.

## FULL interface anchor correction (2026-09-07)

User screenshots show padded Dewgong/Croconaw frames positioned too low. FULL
now removes shared animation-wide transparent margins and top-aligns visible
art at native resolution in a canvas at least 56x56. Oversized art retains all
pixels and can overlap UI. FIT is unchanged. Shared bounds preserve authored
animation motion. Native and fitted results use separate caches. Synthetic
production-fitter tests verify pixel preservation, top alignment, motion and
cache separation; device visual verification remains outstanding.

## Status centering and installed deployment (2026-09-07)

FULL Summary portraits now center within x=0..71; wider canvases start at x=0
to preserve the left edge. Only the sprite draw and matching true-color mark
move; scoped wrappers restore on errors. FIT remains unchanged. Kanto-Reforged
installed ui/summary_ui.lua labels now use ATK, DEF, SPEED, SPATK, SPDEF to
fit before three-digit values. Companion patch staged separately at
D:/gen1recomp/.codex-temp/interface-deploy/summary_ui.lua.
Compared tracked Battle Art runtime/data/shaders/main/manifest to installed
BATTLE_ART_VOXEL_FORK and copied only differences (2 files); also deployed
1 companion UI file. All copied hashes verified. Backups retained at
D:/gen1recomp/.codex-temp/interface-deploy/backup-20260907-030042.
No asset copying or deletion. Local playback/centering tests passed; in-game
visual verification requires restart.

## FULL Dex vertical centering (2026-09-07)

FULL Dex sprites now center vertically in the 72-pixel portrait area including
the number row, clamped at y=0 for oversized art instead of stock 64-h which
clips the top. Number remains drawn over the sprite as authorized. Matching
true-color marks move with the sprite; FIT is unchanged. 3173 mocked interface
checks and syntax/whitespace checks pass. Deployed InterfaceSprites.lua to the
installed BATTLE_ART_VOXEL_FORK with backup and matching SHA256. Device visual
verification remains outstanding.

## First-pose Dex anchor (2026-09-07)

Per user correction, FULL Dex vertical position now uses the first prepared
frame opaque y0/y1, not maximum animation/canvas height. Subtract first y0
from centered placement, keeping placement constant across animation. Shared
canvas still preserves pixels; it does not determine placement. Status remains
unchanged (user approved Charizard). 3173 mock checks and syntax/whitespace pass.
Deployed InterfaceSprites.lua with backup and SHA256 verification. Actual
animation stretching is not established by the screenshot; native pixels are
not rescaled by this anchor change. Device visual confirmation remains pending.

## Summary first-pose anchor and provider reflections (2026-09-07)

User confirms Android single-image title replay fixed banding and Dex FULL/FIT
looks good. FULL Summary now subtracts first frame opaque y0 from placement,
retaining its approved horizontal centering and native size. No Dex changes.

Found drawCast invoked normal provider drawEntity during reflectPlane pass;
provider models bypass billboardMatrix, so their draw was not mirrored. Added
optional drawReflection callback with reflectionPlane/reflectionRaise context.
Unclaimed reflections use existing mirrored engine sprite; provider art needs
the explicit callback to match its custom appearance in the water. Normal
provider rendering unchanged. Original 55e195d canvas/shader path remains.

Regression checks: water cast 47, heal overlay 63, ladders 38, cut drop 22,
cut refresh 10, restored hooks 22 all pass. Original dfc177c ladder geometry,
c083147 heal overlay alignment, 7991cce immediate prop removal retained.
Cut removal still permits background mesh rebuilding as the original commit
did; this is not a claim that every map rebuild has been eliminated.
Interface checks 3174 plus 5 modern replay checks pass; Lua syntax and whitespace
pass. Deployed InterfaceSprites, CharacterRenderers, VoxelScene with backup
and verified hashes. Phone reflection visual verification remains pending.
Uncommitted; published master/tag not moved.
# Exact Lavender north-exit bald-square fix - 2026-09-10

The in-engine screenshot finally identified the remaining bald patch precisely:
it is NOT the Lavender sign floor and NOT the Pokemon Tower flowerbed claim.
It is Route 10's southernmost source block at block coordinate `(4,35)`, block
`$31`, which expands to tiles `x16..19 / y140..143` and is entirely tile `$39`.
Because Route 10 is rendered as Lavender's northern neighbour, Battle Art's
broad sandy cave-to-Lavender approach treatment was painting that 32x32 seam
block as an isolated dirt square inside Lavender's otherwise green lawn.

`ChunkMesher` now treats exactly that one authored Route 10 seam block as plain
grass in BOTH Battle Art and Legendary, before the generic `$39` path branch.
The rest of Route 10's sandy Battle Art approach is unchanged, Lavender's
checker/path network is unchanged, and the large Pokemon Tower flower square is
unchanged. This is visual-only; collision, source tiles, warps and encounters
are untouched. The Route 10 body cache revision is now
`route10-lavender-approach-v3-exit-lawn` so an older sandy seam mesh cannot be
reused.

Release follow-up: after in-engine confirmation that the Route 10 exit lawn fix
worked, the user explicitly approved bumping both version surfaces to `1.10.7`
and tagging that new branch head as `1.10.7`.

## TEST56 merge into 1.10.8 (2026-09-11)

Merged Desktop Test56 non-destructively into the user-requested 1.10.8 branch.
See docs/TEST56_MERGE_1.10.8.md for provenance, scope, menu mapping, exclusions,
and validation. Current Battle Art Lavender/Route 10 fixes and tree-detail
submenu are retained. New casino/prize room and interior toggles default to
Battle Art, with saved selections preserved. Legendary Visuals now groups
Game Corner, Lavender & Cities, and Interiors. Capture options retain the
donor Ember Legacy grouping. Package version remains 1.10.7; no commit/push.

Legendary media now lives exclusively under assets/legendary/, including
ember-legacy/poke_ball audio. All 44 files match Test56 hashes; old lib media
was removed only after verifying identical destination copies. Media stays
ignored and must be distributed separately. Concurrent .gitignore edits kept.

The donor hosted-flight patch was withheld because it replaces companion
methods; existing hosted provider behavior remains. Native Fly changes are
included. Corrected donor capability-query drawing and cleared map-local lamp
state at scene end. LuaJIT compiled 151 Lua files; 18 standalone suites and
91 interior/menu, 55 city-ground, 216 Lavender-approach assertions passed.
These are local static/mocked checks, not Android gameplay/visual validation.

## Gen 2 support: Gold, Silver and Crystal (2026-09-12)

`manifest.json` now declares `"games": ["gen1", "gen2"]` at version `1.11.0`.
`docs/GEN1_GEN2_DIFFERENCES.md` was rewritten from "why this is Gen 1-only"
into the state of the port; `CHANGELOG.md` carries the per-file list. This
section is the evidence and what is left.

### The rule the port is built on

On a Gen 2 boot, `src/mods/Gen2Compat.lua` answers a mod's require for fifteen
Gen 1 names. The `src.world.OverworldController` answer is a facade over the
live `World` that dispatches back through exactly three members -- `update`,
`interact`, `talkTo` (`Gen2Compat.worldTick` / `interactWrapper` /
`talkToWrapper`). A patch on anything else is taken, reads back as our own
function, and is never called.

So every install site that PATCHES rather than CALLS now asks
`lib/Generation.lua` first. Sites that go through a hook, an event or a
registry needed nothing: those names mean the same thing in both engines.

### Checks performed in this checkout

Engine: `gen1recomp` source at HEAD, whose `src/mods/Gen2Compat.lua` is
byte-identical to the shipped `0.2.59` AppImage, so the compat contract under
test is the one the user runs.

- `modkit gen2check`: **38 errors -> 10**. The ten are the
  `lib/OverworldBattle.lua` write sites for the five absent battle members.
  MK404 reports a patch of an absent member separately from the read and there
  is no idiom that silences a write while still patching, so these are the
  static scan's view of code that is gated at runtime by
  `OverworldBattle.available()` plus a per-seam presence test. Not clean, and
  deliberately so.
- `modkit validate`: byte-identical to upstream (the four pre-existing MK301
  ROM-cache findings, unchanged).
- `tests/gen2_support_test.lua`: 118/118 over Gold, Silver, Crystal and a Red
  control. It asserts `mod.state == "loaded"` rather than only `#errors == 0`,
  because a gate skip is not an error and would otherwise pass; and it reads
  the ENGINE tables for the install sentinels, so "the Gen 1 patch did not
  land" is evidence rather than our own bookkeeping.
- Full mod suite: **99 pass / 84 fail**, against pristine upstream's
  **98 / 84** -- a file-by-file diff shows the only difference is the added
  case. The 84 are pre-existing and identical in both copies (cases needing a
  real LOVE context, and cases whose hardcoded `DS_MOD_PATH` default names a
  directory this package is not called). An earlier measurement of this
  reported 183/183 and was wrong: the loop expanded `$?` after a
  `$(basename ...)` substitution, so it recorded basename's exit code rather
  than the test's. The regression conclusion is unchanged -- it rests on the
  upstream-vs-fork diff, which was measured correctly -- but the absolute
  pass counts were not real. Three unit tests
  needed their stub `V` taught about the new `Generation` module
  (`interface_sprites_install_test`, `legendary_cave_merge_test`,
  `atmosphere_companion_integration_test`) -- those stubs assert on unknown
  module names by design, so a new dependency has to be declared.
- **Real Crystal boot**, shipped `0.2.59` AppImage under Xvfb with a sandboxed
  save identity (`POKEPORT_IDENTITY`) so the user's own profile was untouched:
  `state=loaded`, zero boot errors, `GameVersion` reported
  `crystal / generation 2 / lineage crystal`, ladder `OFF/FULL/15/35/50/75`,
  rung 7 clamped to 5, world reached (`PLAYERS_HOUSE_2F`), and the diorama
  drawn at both FULL and 75 degrees with real geometry, cast shadows and the
  player billboard. Software GL (llvmpipe) was needed for the 3D pass;
  without it the engine correctly keeps the 2D path.

Three crashes were found only by that real boot, not by any static check --
`doorTiles`, `Player:pose` and `map.renderer`. Each one left the world flat
while the mod reported itself loaded, which is the failure mode this whole
port is about.

### Not verified

One interior map on one cart. No outdoor, cave, water or connected-map
playtest; no Gold or Silver boot (headless only); no battle fought on Gen 2;
no save/reload cycle. The terrain is greyscale by construction, not by
accident -- see the known limitation in the doc.

### Remaining work, in the order it would pay off

1. DONE (2026-09-12): Gen 2 terrain colour, by baking the tileset atlas per
   PalMap slot against the eight BG palettes. Verified on Crystal in
   PLAYERS_HOUSE_2F -- tan floor, brown panelling, blue console screens, all
   matching the flat 2D render. Remaining in this area: ANIMATED tiles, which
   Gold drives by frame rewrite (`tileset.anim` / `animFrames` /
   `flowerFrames`) where the Gen 1 path in TerrainAtlas keys off
   `TileRenderer.animFrame` and the Gen 1 renderer -- so Gen 2 water is
   coloured but still.
2. PARTLY DONE (2026-09-12): `3D-BTL` runs on Gen 2 via `lib/Gen2Battle.lua`,
   which is a different implementation rather than a port. The engine already
   draws `world:draw()` behind a battle under BATTLE BG = world -- and that is
   the call that asks for our pipeline -- so the work was suppressing the
   panel's own opaque `Chrome.clear` through `drawScene(bodyFn)` /
   `drawSceneBody(panelFn)`, and holding BATTLE BG there. Verified on Crystal:
   CYNDAQUIL vs RATTATA fought over the 3D bedroom, HUD and menu over the top.
   What remains is the STAGED half: an arena search, the over-the-shoulder
   camera, the mons as billboards standing in the scene instead of in Gold's
   flat panel over it, and backplates under Gold's HUD (which is authored for
   a white field and can land a name box on busy geometry).

   Trap recorded: a Gen 2 battle shot during its ENTRANCE looks greyscale --
   `drawScene` opens with `GbcPalette.setBgp(self:exitFadeBgp() or ...)` and
   the fade ramp greys the panel deliberately. Wait for `phase == "menu"`.
   Reproducing it with the mod disabled is what proved it was not ours.
3. The walk through Gold's own step machinery for `1ST` / `3RD`:
   `movement.collision`, `input.step` / `input.key`, and `world.stepped` in
   place of Gen 1's `onStepComplete`.
4. Johto/Kanto-Gen2 mappings for the GEN6 arena router and map atmosphere,
   which still carry Kanto map ids and currently fall back safely.
5. Gen 2 equivalents for the `game.data.field` features that answer nil there:
   CAVE DARKNESS (`darkMaps`), the heal-machine sheet (`overworldFx`) and the
   cut-tree swaps.
