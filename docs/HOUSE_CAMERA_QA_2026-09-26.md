# House stairs, seating and camera regression evidence

Target: Battle Art 1.28.3, mesh revision 76. Native Gen1Recomp 0.3.20, Linux LÖVE,
RTX 5060 Ti. Isolated `ascendant-{yellow,crystal,firered,leafgreen}-qa` identities
under `/home/admin/Projects/.scratch/ascendant-20260926` (Q below). The user's
AppImage chainloads 0.3.20; its installed options were read without modifying
its files. Player saves and the running user game were untouched.

## Reproduced failures and changes

- FireRed actual house-door traversal at FAR 64, AA 2, upscaling OFF, curve 1,
  water FULL raised `field mesh creation failed` three times and disabled 3D.
  Instrumentation found a connected tileset's empty 0-vertex/0-index ground
  batch. Empty streams now skip upload; genuine failed uploads still trigger
  bounded recovery. Successfully allocated streams have immediate ownership
  for cleanup. Failed index uploads release their mesh instead of returning
  an invalid mesh. Baseline: `Q/results/firered-house-exit-user-options` and
  `firered-house-exit-diagnose`.
- Native house stairs have complete 3x3 metatile drawings, not the previous
  four-cell subset. Both floors now have continuous flights and landings,
  closed stringers and downstairs wells. Original warp and collision remain.
- Crystal north-row stairs were swallowed by derived door folding, hidden
  behind wallpaper and room enclosure, and downstairs also sealed by the
  room foundation. All four causes are addressed; native source drawings
  retain four treads, with an 8px descending drop so the risers do not hide
  every tread from a normal eye on the approach. Room framing and wallpaper recess behind these bays.
- The FireRed/LeafGreen bedroom's two-cell dresser was misassigned a chair.
  It now has a closed case, two drawer fronts, knobs and feet.
- Native Mom (graphics 88) has seated support only when stationary on a
  matched chair. Her hips meet the 6.8px cushion, feet sit below it, and her
  card moves to the chair's depth. Chair backs face outward from the table.
  Walking, non-chair cells, items and follower actors do not use this support.
  Crystal's native stool support remains in use.
- Native eye references: Yellow/Crystal front-frame eyes at row 8 of 16;
  FireRed/LeafGreen front-frame eyes at row 21.5 of 32 and visible foot anchor
  31. Eye height is therefore 8 / 9.5 above the standing rendered baseline,
  plus existing ground/jump/ride offsets. Standing frame selection avoids
  walking-frame padding bob. Explicit provider eye-row metadata is supported.
  Native first person disables world curvature and uses a 24px focus distance.

## Checks

`tests/gen3_house_exit_driver.lua`, via `Q/run.sh GAME house-exit-final`:
FireRed and LeafGreen pass actual held-input house-to-Pallet warps in static,
rotating third-person and first-person views at FAR, then FULL. They retain
selected mode, active renderer and zero recovery failures. Native first-person
height, level horizon and real GPU invalid-index cleanup assertions pass.
The projection assertion uses the actual AA canvas size.

`tests/house_polish_driver.lua`, via `Q/run.sh GAME house-polish`:
Yellow, Crystal, FireRed and LeafGreen native house fixtures. Inspect overview,
first-person stair and dresser captures, and Mom from first-person and orbit.
Crystal asserts four actual tread quads survive the full structure pipeline;
its upstairs room asserts a foundation opening. Camera fixtures stand on clear
floor (the initial Crystal probe mistakenly stood on the raised dining table).
A combined LeafGreen early fixture missed the door after repeated photo
teleports; the separate fresh real-door regression passes in both editions.

Eleven focused LuaJIT suites pass: `camera_eye_test`, `house_stairs_test`,
`gen3_stairs_test`, `gen3_sprite_anchor_test`, `interior_diorama_test`,
`designed_interiors_test`, `sprite_billboards_test`, `render_recovery_test`,
`gen3_scene_cache_test`, `gen3_starting_furniture_test`, and
`gen3_center_furniture_test`. They include 31 up/26 down native stair recipes,
136 complete furniture designs, negative whole-pattern guards, foundation
holes, native wallpaper/stair separation and seated-actor exclusions.
All 270 production main/lib/data files compile with LuaJIT 2.1. `git diff --check` passes.

The legacy monolithic SDK test cannot compile: its existing main chunk exceeds
LuaJIT's 200-local limit. The separate old source-engine SDK harness rejects
`gen3` in the current manifest. Neither is counted as passing. Native 0.3.20
fixtures and focused tests above provide this batch's runtime evidence.

Final ZIP verification repeats Crystal/Yellow house fixtures, FireRed and
LeafGreen real door warps, and LeafGreen house/dresser/seating captures from
the extracted archive. `house_neighbors_driver.lua` checks Blue’s/rival’s
house, Oak’s lab, Elm’s lab and a Crystal Center as shared-room regressions.
Archive bytes and every cart pin are checked against the release SHA-256.

## Limits and cleanup

Fixtures are fresh in-memory worlds, with test-only teleports for scenery and
native held-input movement for door regressions. They use the cart companion
mods; this batch does not change or reverify multiplayer gameplay. Xvfb results
are functional/render evidence, not performance measurements. Camera input
on physical controllers and Android remain unverified here.

This release does not certify every room, staircase or tile across the games.
All-map scenery, settings parity and native Gen3 world-space battle actors
remain unfinished. Source images/ROM data, screenshots and generated caches
are not committed or packaged. Fixture processes exit and isolated mod links
are restored after packaged verification.
