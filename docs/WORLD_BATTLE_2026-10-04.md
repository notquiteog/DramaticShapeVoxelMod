# World battle projection and Littleroot — 2026-10-04

Engine: official Gen1Recomp 0.3.51, same verified release/hash as the
[preceding QA](EMERALD_QA_2026-10-04.md). Linux isolated QA profiles only.
Scratch fixtures and rendered captures: `.scratch/world-battle-20261004`.

## Implementation

Gen3 native drawing is split at the background and healthbox seams. Actors,
trainers, balls and local effects are captured with their native transforms,
flashes and masks into pooled transparent cards. These cards stand upright in
the actual world pass, sharing terrain depth, lighting and shadow casting.
No enemy-only scale multiplier remains in the world path. No gameplay state,
targeting, damage, native animation clock or source map collision is replaced.
Global full-screen flashes remain screen overlays. Native bag, party, dialogue,
Dex and naming screens retain ownership.

Gen1's shared BattleCam supplies orbit/pitch/zoom and the authored opening rig;
doubles have wider physical slots and framing. Status cards project from the
same actor matrices. Scenery clears camera-to-actor sightlines. Capture balls
use native row floor coordinates independently of selected sprite padding.
Capture resources and active state clear at battle exit. Unavailable native
scene support retains the existing native fallback.

Nine Birch lab recipes add separate CRT/keyboard desks, research books, starter
cabinet, bookcases, server and round machine, with native plant artwork.
Littleroot's two house profiles and Birch lab now have complete modeled shells,
recessed openings, overhangs and a raised circular roof extractor. Hoenn signs
use their native white noticeboard style. This brings Emerald to 50 interior
recipes and six building profiles, not complete Hoenn coverage.

## Verification

- FireRed, LeafGreen and Emerald: native wild introductions, actor projection,
  Flamethrower artwork, orbit, run/return, successful Master Ball catch and
  native post-catch flow. Driver-built parties/encounters; original save files
  untouched. FireRed/LeafGreen/Emerald source captures were visually inspected.
- LeafGreen at 2560×1440: same attack/run/capture sequence and projected HUD.
- Two Emerald clients: native online single/double command screens, four world
  actors and distinct HUD cards; native trade selection and disconnect party
  restoration still pass. This is not complete online battle-outcome or trading
  verification.
- Birch lab and Littleroot: overview, first-person and rotating side/rear
  captures; inspected original native art and modeled render. Tile/collision
  arrays unchanged. Native trucks remain sprite objects; not new truck models.
- Lua regression coverage checks capture/UI separation, error unwind, upright
  ground contact, source scale, retained HUD projection and Hoenn recipe/family
  isolation. Production libraries compile under LuaJIT. The repository suite
  reports 110 passed, 11 pre-existing failures and 85 skipped; its existing
  failure ceiling was not increased.

## Remaining coverage

The world projection adapter is implemented; this is not exhaustive verification
of every move, special battle, provider, trainer pair or screen aspect ratio.
Full-screen animation backgrounds retain native presentation. Online completed
outcomes, all specialty scenarios and Android still need dedicated QA. Gen2/3
map/model coverage remains incomplete outside the documented authored regions;
no claim is made that every tile, interior or exterior is finished.
