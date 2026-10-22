# Crystal mobile framing

Confirmed two presentation mismatches against official Gen1Recomp 0.3.95:

- The shared GB world scene used the entire OS drawable even when the public
  viewport hook or a touch layout reserved a smaller playfield. Crystal then
  cropped that image instead of showing the player in the intended view.
- Gen 2 draws a returned world pipeline canvas at unit scale; Gen 1 applies
  inverse DPI. Returning the same physical-pixel, density-1 canvas to both
  enlarged/cropped Gen 2 on high-density displays.

SceneSize now converts the pipeline's actual logical playfield dimensions to
physical pixels. A Gen 2-only final world-pipeline adapter retains those pixels
in a logical-size high-DPI presentation target after world postprocessing.
Density-1 presentation is zero-copy. Targets are reused and released on exit;
allocation/draw failures restore graphics state and fall back to native drawing.
Camera positions, screen-position preference, touch controls and gameplay do
not change. The shared viewport sizing also applies to Red/Blue/Yellow.

## Evidence

Latest official release checked October 22: 0.3.95. Native source runtime with
LÖVE 11.5 Linux shell from 0.3.89; isolated Crystal fresh world/New Bark Town
7,5 facing down, fixed camera rung3, no saved player data changed.

A 360×640 window with public render.viewport rectangle20,30,320,300 produced
360×640 scene before and320×300 after. Before/after screenshots inspected:
player was cropped near the bottom before, properly framed after. Full portrait
360×640 remains unchanged. Simulated2× drawable metrics produce640×600 scene
pixels with320×300 logical presentation; screenshot inspected and matched
framing. Source fixture/captures are under the local scratch directory
crystal-mobile-20261022. Initial fixture lacked the assets symlink and did not
boot Crystal; those failed attempts are not verification evidence.

Focused LuaJIT tests cover full/cropped/fractional-DPI sizes, presentation reuse,
non-voxel pass-through, density-1 bypass, graphics-state restoration, draw failure
and teardown. This is native Linux rendering with portrait/high-DPI simulation,
not physical Android/iOS verification or confirmation of the reporter's settings.
