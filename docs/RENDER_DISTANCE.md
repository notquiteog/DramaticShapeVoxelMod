# Render distance and boundary scenery

Unreleased checkout implementation, tested on Gen1Recomp 0.2.73.
The same **R.DIST** setting is available in Crystal and FireRed:

| Choice | Scenery radius |
| --- | --- |
| Auto (default) | Medium on desktop; Low on mobile and consoles |
| Low | 16 cells / 256 world pixels |
| Medium | 32 cells / 512 world pixels |
| Far | 64 cells / 1024 world pixels |
| Full | Loaded connected-map neighborhood plus a scenery margin |

Full does not import or render the entire game world. Higher settings build
and draw more geometry. Existing saved numeric choices and Full remain valid.
Crystal retains its current-map terrain mesh and budgets neighboring maps,
vegetation and actors; FireRed also budgets its cell-based terrain build.

Actual connected maps take precedence over generated scenery. Outside those
maps, the nearest real boundary supplies water, raised rock terrain, or forest.
Unclassified edges retain safe ground; building facades and doors never repeat
into the void. This is presentation only: no added walkable cells, encounters,
warps or collision edits.

Forest fill uses the same tree builders, trunk setting, materials, shadows and
camera-facing rules as nearby trees. Johto, Ilex/Kanto and FireRed's larger
Viridian Forest trees retain their separate footprints. Positions and tree
variants are deterministic world-cell choices; turning the camera does not
rebuild or reshuffle them. Connected-map holes are checked before tree roots
are placed.

Distance haze uses the player's ground position, so an elevated fixed camera
does not wash out the foreground. Full fades toward the loaded region's bounds
instead of imposing a hidden fixed radius. Terrain and reflective water share
the fade; the default backing plane meets the sky without a cyan horizon seam.
Indoor rendering and existing Gen1 forest atmosphere retain their own behavior.

## Verification

`tests/boundary_scenery_test.lua` checks connected-map priority, boundary donors,
all five settings and the fade endpoint. `tests/boundary_scenery_driver.lua`
boots the actual engine in isolated QA profiles, captures static/first/rotating
views, and checks that camera rotation does not rebuild scenery. Fixtures:

- Crystal: Cherrygrove, Route 29, Blackthorn and Ilex Forest.
- FireRed: Pallet, Cinnabar, Route 3 and Viridian Forest.

These representative runtime checks are not an assertion that every map or
all existing scenery has received visual approval. The feature has not yet
been released or pinned into a cart.
