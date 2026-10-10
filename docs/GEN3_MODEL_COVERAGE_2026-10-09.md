# Gen3 native model coverage — ongoing

This checklist records inspected models, not inferred coverage from tile
classification. FireRed/LeafGreen/Emerald full-world coverage is unfinished.
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
- [ ] FireRed dedicated runtime verification (shared FRLG code alone is not it).
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
