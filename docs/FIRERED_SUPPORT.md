# FireRed HD-2D preview

Version **1.21.0-beta.1**, tested with the actual Linux **Gen1Recomp 0.2.73**
AppImage payload. Requires 0.2.73+. Import the mod ZIP into FireRed separately;
the Johto sealed cart still targets Crystal and stays on stable Battle Art.
Supply/import your own FireRed ROM through the engine. No ROM or imported art
is included in this repository or mod ZIP.

## Available

- Native Game3 field pass integration, separate from Gen1/Gen2 facade patches.
- Outdoor terrain from the engine's native 16-pixel metatile atlases, including
  their under/over layers, connected-map borders and animated native textures.
- Illustrated tree families, grounded trunks, depth occlusion and shared shadows.
- Pallet house/lab roof and facade profiles scoped to Pallet's secondary tileset.
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

Interiors and caves retain native rendering pending dedicated profiles.
Healing, door animations, shops and active special field effects also use the
native presentation. They must not disappear for the sake of a 3D screenshot.
Camera rotation therefore does not turn those fallback scenes into 3D.

FireRed battles remain entirely native. This update does not port Crystal's
staged battles, full-body battle providers, double-battle mod, riding, followers,
multiplayer companions or optional post-processing controls. Do not install
Crystal-only companions on FireRed on the basis of this mod's compatibility.

Other city buildings and their architecture, rocks, ledges, fences, flowers,
tall grass and decorations still need FireRed-specific recipes. Unclassified
art stays on the terrain rather than being guessed into a wall from collision.
The Pallet roof profiles are a starting point, not the finished ceramic detail
of Crystal's roofs. First-person views expose these remaining flat features.
This is not Gamma Emerald visual parity or an all-map certification.

## Verification performed

On 0.2.73, using a separate disposable FireRed profile and the user's already
imported assets: Pallet Town, Route 1, Viridian City and the starting bedroom.
Thirteen screenshots cover three outdoor maps in static, first-person,
rotating-third-person and OFF modes, plus the native interior fallback.
The driver asserts real camera-relative steps, native hotkey cycling and foliage
orientation. A separate native battle entry/render/abort/field-return smoke
check passed; that is not a combat or multiplayer validation.

Crystal also booted and built New Bark's native HD-2D scene with the new entry
branch. Headless adapter tests and 181 Gen1/Gen2 support checks passed against
0.2.73 engine modules. Existing Crystal roof geometry/material tests passed.
Static modkit validation still reports the six pre-existing MK301 findings;
no new FireRed cache-read finding was added.

Drivers: `tests/gen3_views_driver.lua` and `tests/gen3_adapter_test.lua`.
The native driver refuses any identity other than `firered-hd2d-qa`.
