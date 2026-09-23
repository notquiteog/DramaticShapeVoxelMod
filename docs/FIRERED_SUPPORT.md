# FireRed/LeafGreen native presentation — 1.23.0-test.9

Prepared against official **Gen1Recomp0.3.1**; exact packaged gameplay/visual verification follows publication. Import your own compatible ROM through the engine. No ROM or imported native artwork is included in this repository or mod ZIP.

The current source adds reviewed gym, cave and specialty-interior depth profiles, native water surfaces,15 exact additional furniture recipes, and a bounded Oak starter-table footprint fix. Native renderer, battle HUD/trainer/background and Summary/Dex options have concrete consumers and an auditable full option inventory. Full option/model coverage remains incomplete; a visible setting or classified tile does not prove functional or visual parity. Gen3 world-positioned battlers, cast shadows for native UI-plane actors, Stadium provider integration and many environment/capture options remain unfinished.

See [current implementation, tests and limitations](NATIVE_PARITY_2026-09-22.md), [all89 controls](option-support.json), and [interior geometry](INTERIOR_DIORAMAS.md). The earlier beta3 scope/evidence below is historical and does not describe test.9's complete current state. Publication and archive hashes are recorded by the release task.

## Earlier checkout notes (before test.9)

Shared interior dioramas now frame supported houses, labs, Marts and Centers.
Shop/Center recipes add native-art furniture depth; compact rooms fit the
static camera, with side-window lighting and enclosed eye-level views.
Native healing/shop/special effects retain their fallback. Other specialty
interiors still need separate adapters. See [interior coverage](INTERIOR_DIORAMAS.md).

Shared Auto/Low/Medium/Far/Full render distance, per-boundary water/rock/tree
continuation and stable sky fading are implemented. Connected maps remain
authoritative. See [render-distance scope and checks](RENDER_DISTANCE.md).

The working tree now uses flat gym roofs with beveled edges, complete civic
buildings and38 reviewed house/landmark families. Lavender Tower joins its
Route10 dome to its town facade; its square base meets newly raised General
cliff masses. The top shape is retained. These are presentation changes;
walkable terrain/collisions remain native. TREE TRUNKS defaults to FLAT 2.5D.

This work is not in the beta3 ZIP and has not been pinned into the sealed cart.
See [exterior coverage and remaining work](EXTERIOR_COVERAGE.md).

## Published beta3 additions and corrected scope

- Complete exteriors for all eight main Kanto gyms plus Saffron's Fighting Dojo.
  Whole drawings cover 6–8-column widths, missing back roof strips, wider facade
  segments and city-specific trim. Roofs remain straight gables. The projecting
  entrance, side/rear courses, high windows and applicable notice boards have depth.
- Reviewed General fences use posts/rails, including mapped corners, vertical runs and end posts. Grass and
  sand ledges are low 2.5-unit mounds with exposed dirt fronts. Flowers and grass
  use short sloped cutouts; shrubs use crossed cutouts. Native flower animation
  refreshes their derived material. Signs have posts and solid backs.
- Initial lab bookshelves, counters, computer, aquarium, wall displays and work
  table. Room walls have shallow, closed tops. Large lab machines and planters
  remain unfinished. Specialty interiors, including gym interiors, remain native.
- Correct the beta2 cave gate: imported cached definitions can say TOWN for
  caves. Native `mapType` now takes priority. The corrected inventory enables
  150 maps, not the previously reported 258. This is a scope correction, not
  evidence that those 258 maps were previously suitable HD scenes.
- Full tile-treatment ledgers now cover all 425 imported maps. See
  [tile coverage](TILE_COVERAGE.md); classification is not visual approval.

## Available

- Native Game3 field pass integration, separate from Gen1/Gen2 facade patches.
  The finished scene uses the public display-resolution world override; text
  and menus retain the separate native UI plane.
- Outdoor terrain from the engine's native 16-pixel metatile atlases, including
  their under/over layers, connected-map borders and animated native textures.
- Illustrated tree families, grounded trunks, depth occlusion and shared shadows.
- Pallet house/lab profiles, shared General Mart/Center/civic buildings and
  Viridian house profiles, with consistent eave heights across doorway columns.
  Oak's lab stays flat with a separate chimney; houses use straight gables.
  Source grass is removed from reviewed roof silhouettes, while green Viridian
  roofing stays intact. Rear walls close the buildings for free-camera views; internal dividers are
  culled so cropped roof backgrounds cannot expose fins behind the lab.
- Cached generated tileset names resolve without ROM reads, enabling later
  cities' common General scenery. Native header mapType keeps caves/ships separate; cached environment alone is unreliable.
- Initial Building-primary home profiles: room walls, tables with legs, chairs,
  kitchen counter, cabinet, television, computer desk and horizontal bed.
  These are complete drawing matches, never collision-based wall guesses.
- Animated native player/NPC sprites. Neighbor ghosts are read, never ticked by
  the renderer. Native visibility, steps, collision and script movement remain
  engine-owned.
- Press **3** to cycle OFF, FULL, 15, 35, 50, 75, first person and rotating third
  person. **Hold the right mouse button and drag** to look in the last two modes.
  Static views keep foliage fixed; free views face foliage toward the camera.
  The mod manager exposes **2.5D CAMERA** and saves the selection.
- Camera-relative native grid walking, including both new key presses and held
  input. Ordinary buttons and scripted movement are preserved.
- GPU/render failure returns to the native field and disables camera-relative
  walking. OFF keeps the engine renderer, including its own saved tilt.

## Native fallbacks and unfinished work

Specialty interiors and caves retain native rendering pending dedicated profiles.
The reviewed `house`, `player_house` and `oak_lab` tileset families now use initial depth
profiles; many of their secondary decorations still remain flat.
Healing, door animations, shops, battle transitions and active special field effects also use the
native presentation. They must not disappear for the sake of a 3D screenshot.
Camera rotation therefore does not turn those fallback scenes into 3D.

The unreleased 3D BATTLE STAGE now renders a cleared terrain scene behind
FireRed's native battle sprites. Overhead status cards follow each sprite's
visible head; lower-right commands use the shared silver/pixel UI theme.
Native battle mechanics, animation, messages and special prompts retain their
owners, with native fallback when the scene cannot render. FireRed battlers
are still native screen sprites, not depth-tested world-space cards. Crystal's
full-body providers, double-battle mod, riding, followers, multiplayer
companions and optional post-processing controls are not ported. Do not install
Crystal-only companions on FireRed on the basis of this mod's compatibility.

Other city-specific buildings and their architecture, rocks, cliff faces, remaining fence/ledge variants and decorations still need FireRed-specific recipes. Unclassified
art stays on the terrain rather than being guessed into a wall from collision.
FireRed roof materials retain native art; decorative materials still need
individual treatment. Flat and gabled roofs should keep their own profiles. First-person views expose these remaining flat features.
This is not Gamma Emerald visual parity or an all-map certification.

## Verification performed

Actual Linux0.2.73, disposable profiles using the user's already imported data.
The beta3 view driver passes37 captures: Pallet, Route1, Viridian, Celadon,
Cerulean, both player-house floors, a Cerulean house, Oak's initial depth interior, and a native Diglett's Cave fallback.
HD scenes receive static/first/rotating-third/OFF checks, real native movement,
hotkey cycling, foliage orientation and display-resolution world handoff
assertions. A separate1440p Pallet roof driver captures static plus eight free
views and three rear checks, and checks the lab chimney. Captures are evidence for selected views,
not every object, location or lighting condition.

The current source-art census visits425 maps/60 tileset pairs:150 maps are eligible
for the current HD scene, and96 whole-object props match on19 maps. All425
maps being counted does not mean they have all been visually approved.
Reproduce with `tests/gen3_coverage_driver.lua` and `SHOT_DIR` in the disposable
`firered-hd2d-qa` identity; its CSV contains counts/identifiers, no imported art.

Native battle entry reached the command phase, followed by the engine's abort
and a successful HD field return. No combat/multiplayer certification is made.
Crystal:45 native captures across five cities, three static and six free-camera
views each; stacked-house and foliage assertions pass. Headless checks pass:
181 Gen1/Gen2 support,102 Gen2 tile-shape checks, FireRed adapter/roof tests and
the existing roof/material geometry checks. Six pre-existing MK301 findings
remain in static validation; this is not a clean modkit validation.

Drivers: `tests/gen3_views_driver.lua`, `tests/gen3_roof_views_driver.lua`,
`tests/gen3_battle_driver.lua`, `tests/gen3_coverage_driver.lua`.
Local evidence: `/tmp/firered-hd2d/{candidate-views,roof-1440p,crystal-city-views}`.

Beta3 adds native checks for all eight gym exteriors plus the Fighting Dojo (32 camera captures), outdoor details and flower-clock/material refresh (27 captures), and Crystal radio desk priority (nine captures). These are focused scene checks; gym puzzles and battles were not re-certified.

Unreleased battle QA on the actual 0.2.73 AppImage at 2560×1440 verifies
head-card rendering, command directions, move selection, native HP damage,
stage lifetime through actions and return to the overworld without moving
the player. Full FireRed doubles, multiplayer, capture, fainting and level-up
sequences have not been certified by this test. Exact reference parity remains
in progress.
