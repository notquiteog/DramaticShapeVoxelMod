# FireRed HD-2D preview

Version **1.21.0-beta.2**, tested with the actual Linux **Gen1Recomp 0.2.73**
AppImage payload. Requires 0.2.73+. Import the mod ZIP into FireRed separately;
the Johto sealed cart still targets Crystal and stays on stable Battle Art.
Supply/import your own FireRed ROM through the engine. No ROM or imported art
is included in this repository or mod ZIP.

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
  cities' common General scenery. Map environment keeps caves/ships separate.
- Initial Building-primary home profiles: room walls, tables with legs, chairs,
  kitchen counter, cabinet, television, computer desk and horizontal bed.
  These are complete drawing matches, never collision-based wall guesses.
- Animated native player/NPC sprites. Neighbor ghosts are read, never ticked by
  the renderer. Native visibility, steps, collision and script movement remain
  engine-owned.
- Press **3** to cycle OFF, FULL, 15, 35, 50, 75, first person and rotating third
  person. **Hold the right mouse button and drag** to look in the last two modes.
  Static views keep foliage fixed; free views face foliage toward the camera.
  The mod manager exposes **HD-2D CAMERA** and saves the selection.
- Camera-relative native grid walking, including both new key presses and held
  input. Ordinary buttons and scripted movement are preserved.
- GPU/render failure returns to the native field and disables camera-relative
  walking. OFF keeps the engine renderer, including its own saved tilt.

## Native fallbacks and unfinished work

Specialty interiors and caves retain native rendering pending dedicated profiles.
The reviewed `house` and `player_house` tileset families now use initial depth
profiles; many of their secondary decorations still remain flat.
Healing, door animations, shops, battle transitions and active special field effects also use the
native presentation. They must not disappear for the sake of a 3D screenshot.
Camera rotation therefore does not turn those fallback scenes into 3D.

FireRed battles remain entirely native. This update does not port Crystal's
staged battles, full-body battle providers, double-battle mod, riding, followers,
multiplayer companions or optional post-processing controls. Do not install
Crystal-only companions on FireRed on the basis of this mod's compatibility.

Other city-specific buildings and their architecture, rocks, ledges, fences, flowers,
tall grass and decorations still need FireRed-specific recipes. Unclassified
art stays on the terrain rather than being guessed into a wall from collision.
FireRed roof materials retain native art; decorative materials still need
individual treatment. Flat and gabled roofs should keep their own profiles. First-person views expose these remaining flat features.
This is not Gamma Emerald visual parity or an all-map certification.

## Verification performed

Actual Linux0.2.73, disposable profiles using the user's already imported data.
The beta2 view driver passes33 captures: Pallet, Route1, Viridian, Celadon,
Cerulean, both player-house floors, a Cerulean house, and Oak's native interior.
HD scenes receive static/first/rotating-third/OFF checks, real native movement,
hotkey cycling, foliage orientation and display-resolution world handoff
assertions. A separate1440p Pallet roof driver captures static plus eight free
views and three rear checks, and checks the lab chimney. Captures are evidence for selected views,
not every object, location or lighting condition.

The new source-art census visits425 maps/60 tileset pairs:258 maps are eligible
for the current HD scene, and67 furniture objects match on10 maps. All425
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
