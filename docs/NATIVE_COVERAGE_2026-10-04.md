# Native-art coverage checkpoint, 2026-10-04

This is incremental coverage, **not every-tile completion**. No release is
claimed from this checkpoint. Native maps, collision, warps and puzzle logic
remain engine-owned; visual fixtures assert that layout/collision are unchanged.

## Changes

- Emerald: 36 additional complete building patterns (gyms, Centers/Marts and
  houses), bringing the Hoenn exterior list to 42. Native roof paint extends
  through the modeled service-building corners instead of borrowing grass.
- Littleroot: complete native furniture patterns, horizontal beds, computers,
  cabinets, low seating, wall pictures/clocks and correctly proportioned recessed
  windows. Stair corrections were committed separately as 532e0f4.
- Hoenn scenery: source-sized narrow conifers, Dewford sandy conifers, Mauville
  fences, directional low ledges and short blocked ocean rocks. Tree-art cache
  identity now includes drawing/crop policy, so different canopies cannot borrow
  the same cached image accidentally.
- FRLG: replace false single-cell beds/consoles/bookcases in condos, Lorelei's
  house, Celadon Hotel/roof room, Tanoby ruins and Pokémon Tower. Add complete
  furniture drawings and straight ruin masonry; retain source art for unresolved
  shapes. Correct known floor IDs that were becoming barriers.
- Vermilion: fifteen separate ribbed, open metal bins and the native two-bar
  electric barrier. Gate recipe only claims the complete closed-state drawing.
- Saffron: square nearly-flush teleport pads and complete fluted columns;
  Cinnabar: full two-cell-wide quiz terminals instead of wall-to-console mappings.
- Game Corner: paired and edge-clipped slot cabinets with separate blue stools.
- Seven Island house: native low three-door/three-drawer cupboards, bookcases,
  dining table/chairs and planters; entrance rugs remain flat.
- Shared shell: remove invented luminous side windows. Native-window geometry
  belongs to source-specific recipes; live exterior-map portals remain pending.

## Evidence

Official Linux Gen1Recomp 0.3.51. Isolated profiles and scripts under
`/home/admin/Projects/.scratch/coverage-20261004`; no user save modifications,
ROM pixels, generated atlases or captures committed.

Native 2D diagrams: source/cities/audit fixtures. Render fixtures: Emerald
starting/exteriors, FRLG condos, FireRed audit-render, FRLG gym-corner. Inspected
selected overview, side/rear and first-person captures; this does **not** mean
all maps and all angles were visually signed off. Latest LeafGreen gym-corner
includes the Seven Island floor/cupboard repair. Latest FireRed audit-render
includes roof-room floor exclusions.

Standalone full suite: 111 passed / 11 existing failures / 85 skipped.
Focused reruns after the last furniture/floor edits pass: 268 designed object
recipes, source bounds and incomplete-pattern guards, room shell, Hoenn shapes,
outdoor ledges, and additional furniture. Original failure ceiling unchanged.
Tests validate matching/geometry, not artistic completeness or gameplay puzzles.

## Remaining visible gaps

Native room-wall backing and internal corners need more work, including Pokémon
Tower's stepped perimeter, special gym partitions, and gaps behind some house
fixtures. Game Corner counter, signage and cabinet end caps need further models.
Tanoby straight masonry is modeled; its full corner vocabulary is not finished.
Several Celadon shrubs remain native flat art pending complete drawings. Additional
Hoenn city buildings, routes, caves and special interiors still need source-specific
recipes. Cliff classifications need broader outdoor visual review. Gen1/2 require
continued native-art audits too. Counts are not a claim of universal quality.

## Second modeling pass

- Eight additional complete Hoenn house patterns cover Verdanturf, Fallarbor
  and Mossdeep, including Steven's house (50 exterior patterns total). Explicit
  native door/window openings retain original sashes/handles; the shared builder
  no longer overlays invented hardware on these source-specific openings.
- Verdanturf's low gray fence now has native-sized stone posts and a single
  pale rail; optional fence sampling does not change other fence defaults.
- Pokémon Tower: correct green floor exclusions, purple panel walls with white
  cornices, closed bounded returns at stepped north-wall joins, and a complete
  L-shaped reception counter. The wider rectangular room shell and southern
  polygon outline remain unfinished; this is not whole-Tower approval.
- Crystal Goldenrod/Celadon Game Corners: separate gray pedestal stools and
  paired red cabinets with the original pink/yellow panels. Dedicated geometry
  retains the dark center seam and closed backs/ends. Final first-person render
  confirms the side-panel depth offset eliminates coplanar flicker.
- Hoenn atlas review excludes house-wall/ground IDs from the cliff band and
  samples a rock-only cap. This does not implement complete terrace elevations.

Evidence: same official Linux 0.3.51 isolated QA setup. Fixtures `more-houses`,
`tower-walls`, `crystal-corner-source`, `crystal-corner`, and `hoenn-atlas` under
`.scratch/coverage-20261004`. Inspected selected overview, side/rear and first-
person captures; native source diagrams reviewed before recipe construction.
The Crystal compatibility HUD labels itself Pokémon Gold; the isolated import
and selected game for these runs are Crystal. No player save was modified.

Standalone suite: 112 pass / 11 existing fail / 85 skip. Focused guards cover
274 designed objects, source sampling bounds, closed components, native floor
exclusions, wall returns, door/window hardware and Hoenn scenery scope. Final
small material/cliff changes received focused reruns. No new release or universal
visual/gameplay approval is implied. Hoenn special buildings, cliffs, additional
caves/interiors, live exterior-window views and all-map visual review remain open.

### Crystal station fittings

Three additional complete patterns cover yellow seats, repeated open platform
railings and entry housings in the station tileset. The seats have separate
feet/cushions/backrests instead of a single extruded tile; source floor remains
blue indoors and gray on the platform. Native collision/warp layout unchanged.
Official 0.3.51 `crystal-station` fixture completed Goldenrod and Saffron; inspected
Goldenrod overview and first-person. 277 designed-object recipes and focused
source-bound tests pass. This is not a full station sign-off: train geometry,
tracks, perimeter details and travel animation still need review.

### Hoenn science rooms

Space Center and Devon offices now match 51 additional native furniture
instances using twenty atlas-scoped recipes: CRT workstations with keyboards,
open-legged plan tables, pedestal stools and inclined instrument banks.
The shared original-art model builder closes backs and sides. Native window
bands and office wallpaper stand vertically; Space Center rails retain gaps.
Eight three-cell-wide facility stair recipes preserve landing behavior and
use recessed flights with native gray/red materials instead of flat openings.

QA: official 0.3.51 `science-source` and `science` fixtures. Source diagrams,
selected overview/first-person renders reviewed; map/collision grids unchanged.
297 designed-object checks, 106 Hoenn recipe/family checks and 68 staircase
patterns pass, alongside focused existing furniture regressions. Devon rear
fixture faces outside the room, so it does not establish rear-view approval.
Museum exhibits, additional Devon floors, stair-adjacent wall returns and full
room boundaries still need work. These maps are not claimed fully finished.

### Native room ownership and Oceanic Museum

Restored enclosure eligibility for 33 Emerald indoor maps whose primary atlas
is General: office, contest, ship and other explicitly scoped room families.
Do not generalize this to every INDOOR-tagged map: FRLG docks and Hoenn event
islands use that tag too. Complete FR/LG/Emerald census preserves those exterior
exceptions. Gen1/2 enclosure branches are unchanged.

Added eight Museum patterns with closed exhibit cases, pedestal terminals,
display islands, miniature ship/parts, wall cases and a divider. Kept native
cream/blue materials; excluded the lower carpet pixels from upright glass.
Native plain wall bands stand up; additional wall decorations/counters/stairs
remain unfinished. Official 0.3.51 source diagrams and final first-person view
inspected. Native layout/collision grids unchanged. Focused geometry, scope,
source-crop and enclosure tests pass; this does not certify every room/tile.
