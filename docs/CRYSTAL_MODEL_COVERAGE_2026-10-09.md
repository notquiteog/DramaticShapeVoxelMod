# Crystal model coverage checklist — 2026-10-09

This records bounded model work, not approval of every classified tile.

- [x] Department-store native window drawing (MART 14/15/28/29): recessed
  original reflection artwork, closed backing, dimensional frames and sill.
  The pane no longer appears on a cube's roof. All geometry stays inside its
  blocked 16px source cell; native map/collision/warp data is unchanged.
- [ ] Department-store stair/elevator wall fixtures: still generic source
  extrusions in the reviewed views; need independent native-art review.
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
- [ ] Counter-overlapped window drawings (14/15 above 42/43) still retain
  generic geometry beside the reception desk; distinct recipe needed.

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
