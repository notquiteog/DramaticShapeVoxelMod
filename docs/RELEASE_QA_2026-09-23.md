# Published stair, grounding and camera verification — 2026-09-23

Runtime build: **1.24.0-test.3**, commit `169e5c771c7625bad9544374917dbd079f581b2b`.
ZIP SHA-256: `77bc4ac8d70499f74cd8ae8f510268ae695f4dfb1a5530aa18253b48ce274985`.
Companion grounding build: Wilds of Kanto **2.4.1-test.1**.
Carts: Johto Diorama **1.17.1-test.3**, Yellow Online **1.5.1-test.3**, Voxel Red **0.4.1-test.3**.
All runtime changes and cart pins were published before testing, as requested. Subsequent source changes are tests and this evidence only.

## Environment and fixtures

Official Gen1Recomp **0.3.1**, confirmed latest at publication, running under Linux/Xvfb with software GL. The exact published archives were extracted into `/tmp/voxel-polish-20260923/qa/engine/mods`. All six cart core mods were enabled. Yellow, Crystal, FireRed and LeafGreen used copied imported caches and separate temporary profiles; no player saves or options were edited.

Launch: `/tmp/voxel-polish-20260923/qa/run.sh GAME CASE`, where GAME is `yellow`, `crystal`, `firered` or `leafgreen`, and CASE is `gb3` or `native3`. The wrapper asserts runtime/manifest versions, save isolation and edition. It neutralizes physical controller input, so these are scripted rendering/input-contract checks, not a physical-controller playtest.

GB fixtures: player house 1F/2F, Mt Moon or Dark Cave, and Pallet/New Bark. Native fixtures: Pallet, player house 1F/2F and Mt Moon. Native Pallet includes a companion-provided HGSS Bulbasaur. Static 35-degree, rotating third-person and low first-person views were captured. Quest Log intentionally shows recorded Pallet while the live player remains in Mt Moon; assertions preserve live map and player coordinates.

Rendered captures/logs are under `qa/results/{yellow-gb3,crystal-gb3,firered-native3,leafgreen-native3}`. Inspected captures show modeled house stairs/recesses, upright plants at low camera angles, and actors anchored at ground level. Static high-angle cards foreshorten naturally. Representative reviewed files include `firered-native3/stairs_2.png`, `firered-native3/ground_trees_6.png`, `crystal-gb3/scene_2_static.png`, `yellow-gb3/scene_4_static.png` and LeafGreen house/actor captures. Remaining room and roof defects are visible; these images do not establish complete scenery parity.

## Checks completed

- Exact final mod archive: all **251 Lua files** compile with LuaJIT.
- `tests/crossgen_grounding_test.lua`: shared GB/native per-frame anchors, image-read caching, alpha/color-key handling and explicit/masked anchors pass.
- `tests/gen3_sprite_anchor_test.lua`: existing anchor API passes.
- Wilds `tests/gen3_sprite_grounding_unit_test.lua`: **10 assertions** pass.
- `tests/first_person_invert_test.lua`: invert/look checks plus dialogue, movement and menu/battle ownership pass.
- `tests/gen2_tile_shape_test.lua` from engine root with `DS_MOD_PATH=mods/BATTLE_ART_VOXEL_FORK`: **105/105** pass.
- `tests/gen3_stairs_test.lua`: **30 up / 25 down** assembly patterns pass, including complete-pattern/landing guards, step heights, recessed wells and ladder geometry.
- Full native imported-map census: **425 maps per edition**, **123 stair assemblies**, **358 terrace cells**, **142 ladder cells**, **zero uncovered traversable stair behaviors**, in both FireRed and LeafGreen. No matched stair lives in a disabled/fallback scene.
- Crystal census: **388 maps**, **322 modeled stair/terrace/ladder cells**. This is a classification count, not an assertion that every decorative stair drawing was visually inspected.
- Production GPU shader: **36 static/free eye-height and distance combinations** retain world vertical and the same foot plane. Existing heading/static/upper-trunk occlusion GPU test updated for upright foliage and passes against the published shader, including the highest exposed 75-degree view.
- Exact-archive recap fixtures and camera assertions pass in both native editions.

## Remaining limits

Gen1 stairs/ladders were rendered in representative house/cave scenes; there was no complete Gen1 decorative-stair census. Red/Blue, Gold/Silver and additional editions beyond these four were not booted. No physical right-stick, ordinary door walkthrough, battle/healing transition, multiplayer or user-save reproduction was performed in this batch. Native special field effects still retain their engine presentation where documented. Every-room and every-tile visual sign-off, furniture refinement and roof polish remain unfinished. Grounding checks preserve intentional jump/flight/furniture offsets; they do not prove every external sprite provider or animation frame has correct authored offsets.

Runtime processes exit or are bounded by the fixture timeout. The only new repository files are code/tests/docs; captures, imported game data and local assets remain outside git.
