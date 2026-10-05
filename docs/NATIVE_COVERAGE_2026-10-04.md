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
