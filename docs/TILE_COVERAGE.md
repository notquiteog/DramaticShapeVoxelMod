# Tile coverage — measured, not asserted

Newest first. Supersedes the "24,719 generic-wall cells / 1,114 drawings" figures
in `PROJECT_HANDOFF.md`, which described a subset (generic wall cells only) and
were not reproducible.

Everything here is produced by three committed tools and is re-runnable:

| Tool | What it does |
| --- | --- |
| `tools/qa/import-game.sh` | imports one ROM into its own `XDG_DATA_HOME` |
| `tools/qa/sweep.lua` | every map, both cameras, scene-graph validated |
| `tools/qa/drawing-census.lua` | every distinct tile drawing, with a representative cell |
| `tools/qa/drawing-capture.lua` | one isolated render per distinct drawing |
| `tools/qa/analyze-sweep.py` | scores a capture directory |

## What a "tile" actually is here

Neither Gen 1 nor Gen 2 stores a metatile id. The stored granularity is

```
cell  = 2x2 tiles  (16x16 px, the walk grid)
block = 2x2 cells  (4x4 tiles = 32x32 px)   <- def.blocks[] indexes this
finest stored unit = the 8x8 tile id
```

A Game Boy "metatile" is 2x2 tiles — half a block — and nothing in either engine
names it. So the reviewable unit is the whole **block drawing**, keyed by
`(tilesetId, blockId)`. Gen 2 writes `METATILE_COUNT = 128` blocks per tileset,
which is what keeps that set bounded and reviewable against ~143k cell instances.

Gen 3 does have a real id: `def.midLayout:midAt(cx, cy)`, with the tileset pair
from `def.midLayout.pair` — the same call `lib/Gen3Scene.lua:157` makes.

**Trap:** on Gen 2, `Map:cellTile()` and `Map.defCellTile()` return the
**collision byte**, not a tile id (`src/world/gen2/Map.lua:165-166`). Gen 1 is the
opposite — `defCellTile` returns the 8x8 tile id and requires the `tilesetDef`.
Anything doing tile work must not call `cellTile` on Gen 2 and believe the number.

## Measured totals

| Game | Gen | Maps | Cells | Distinct drawings |
| --- | --- | --- | --- | --- |
| red | 1 | 222 | 94,876 | 1,194 |
| blue | 1 | 222 | 94,876 | 1,194 |
| yellow | 1 | 223 | 94,988 | 1,209 |
| gold | 2 | 368 | 143,376 | 1,466 |
| silver | 2 | 368 | 143,376 | 1,466 |
| crystal | 2 | 388 | 147,500 | 1,864 |
| firered | 3 | 426 | 937,464 | 11,060 |
| leafgreen | 3 | 426 | 937,464 | 11,060 |
| emerald | 3 | 519 | 1,265,348 | 13,262 |

**3,162 maps · 6,324 map captures · 36,106 distinct drawings · 3.19M cell instances.**

Union across all nine games, per generation: gen 1 = 1,210, gen 2 = 1,874,
gen 3 = 33,022. FireRed and LeafGreen overlap far less than sibling games would
suggest, consistent with metatile numbering being cart-local.

## Map sweep results

All nine games: every map, both cameras, **0 refused, 0 unverified** by the
scene-graph gate (`game.world.map.id` for gen 1/2, `src.core.game3.map.current`
for gen 3). No battle splashes and no title cards anywhere in the final runs.

## Per-drawing results

Every distinct drawing rendered in isolation, both games' worth of cameras,
scored on uniformity with the HUD masked out. `FLAT` is the failure this project
exists to catch — a subject that draws as one untextured plane.

| Game | Drawings | OK | Empty | Flat | Defect cells | Share of cells |
| --- | --- | --- | --- | --- | --- | --- |
| red | 1,194 | 1,192 (99.9%) | 1 | 1 | 96 | 0.1% |
| blue | 1,194 | 1,192 (99.9%) | 1 | 1 | 96 | 0.1% |
| yellow | 1,209 | 1,207 (99.9%) | 1 | 1 | 96 | 0.1% |
| gold | 1,466 | 1,453 (99.1%) | 0 | 13 | 1,588 | 1.1% |
| silver | 1,466 | 1,441 (98.3%) | 0 | 25 | 604 | 0.4% |
| crystal | 1,864 | 1,838 (98.6%) | 0 | 26 | 1,644 | 1.1% |
| firered | 11,060 | 11,060 (100%) | 0 | 0 | 0 | 0% |
| leafgreen | 11,056 | 11,056 (100%) | 0 | 0 | 0 | 0% |
| emerald | *rendering* | | | | | |

**30,519 drawings scored, 30,439 OK (99.7%), 5,120 defective cell instances of
~2.4M (0.2%).**

### What "100%" does and does not mean

FireRed and LeafGreen score a clean 100%, and that is not the same as authored
voxel art. The metric only detects *empty* and *flat* frames. Gen 3 renders
**native tile art extruded in 3D**, which is correctly modulated and scores OK
even though no Emerald-specific profile exists. See "Open defect families".

### The flat family, confirmed in both cameras

`MAHOGANY_MART_1F` was checked first- and third-person: `TILESET_TRADITIONAL_HOUSE`
walls render as an untextured plane over an untextured floor. The one block that
*is* reviewed (`Gen2FloorFinish.lua:11`, block 4, tatami) is itself among the
flat readings, so the finish contributes no visible variation. The family is
25 blocks in Crystal, 12 in Gold, 13 in Silver, plus `TILESET_GATE__39`
(1,040 cells) and `TILESET_TOWER__1` (1,412 cells in Gold) — the largest single
defects in Gen 2.

Gen 1's remaining 1 empty and 1 flat per game are `OVERWORLD` / `GYM` blocks in
city maps; the blank-frame retry in the harness removed the other 30-38 per game.

## Open defect families

1. **Gen 2 `TILESET_TRADITIONAL_HOUSE`** — walls and floors render flat, in all
   three Gen 2 games. ~1.4% of drawings, ~1.1% of cells.
2. **Gen 2 `TILESET_GATE__39`** — the largest single flat drawing in Crystal at
   1,040 cells.
3. **Gen 3 has no authored art at all.** FireRed/LeafGreen/Emerald render native
   tiles in 3D. `lib/Gen3TileShape.lua` carries ~330 FireRed metatile ids and
   `lib/Gen3Tilesets.lua` maps 425 `FR_`/`SEVII_` map ids, none of which apply to
   Emerald's numbering. Emerald is 13,262 drawings with no profiles. This is the
   largest remaining authoring job by an order of magnitude.

## Metrics are not verdicts

Four separate harness bugs each produced convincing, entirely false defect
rates. All four were camera placement, not rendering:

- standing **on** the drawing, which for any wall/tree/fence is not a walkable
  cell, so the camera was inside geometry — 23% empty
- requiring `Perm.LAND` specifically, which cave and dungeon floors are not — a
  further 4%
- never setting **yaw/pitch**, so the camera faced a wall at point-blank — more
  flat readings
- aiming **horizontally at floors**, which fall out of frame

The chain went 509 "empty" → 79 → 68 → 26 for Crystal, and the mod never changed
in any of those steps. Open the image before believing a bucket.

Two more calibration notes:

- A genuine missing-geometry void is ~0.94–1.00. A legitimate **night sky** is
  ~0.63–0.66 against a ~0.02 median. Thresholding at 0.60 is badly wrong; ~0.90
  is right, and there is an empty gap between them.
- Gen 3's third-person dark interiors are **not** a defect. The frame is 100%
  `RGB(6,8,12)` — exactly `Interior.background` (`.022,.032,.046`) — and the room
  renders correctly underneath it.