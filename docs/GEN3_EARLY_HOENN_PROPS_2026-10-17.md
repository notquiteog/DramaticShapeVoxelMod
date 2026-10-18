# Early Hoenn native field fixtures — 2026-10-17

This batch adds three source families across Emerald, Ruby and Sapphire:

- Petalburg's complete two-row gym notice (`130/131`): closed clipped-corner
  board, rear, edge and center post; original GYM artwork on one front plane.
  All geometry stays in the lower blocked cell; the upper drawing is walkable.
- Petalburg's paired garden troughs (`007`): two closed timber containers per
  cell, raised lips and recessed soil. Native green/bud pixels stay flat HD-2D
  cards. The separate walkable flower beds remain native HD-2D scenery.
- Berry soil (`28D` and `14C`): closed, shallow native dirt edges underneath
  the native field-object layer. No berries, crops, growth or harvesting logic
  are generated or replaced.

Native source layouts contain ten fixture placements per Hoenn edition:
Petalburg four trough drawings and one notice; Route 102 two soil cells;
Route 103 three soil cells. Source IDs, canonical tileset, complete drawing and
exact permissions guard each recipe. Missing permissions, a changed walkable
cell, unknown art and other tilesets stand down. Canonical tileset aliases
continue through the existing public resolver. Characters, Pokémon, flowers,
UI, collision, native scripts and optional-partner independence remain intact.

The four shoreline corner drawings (`164/165/16C/16D`, eight placements per
edition) use the existing character-height 16-pixel rock enclosure and native
water underlay. Complete sea-boulder and sea-stack groups remain owned by
`Gen3SeaRocks`; no duplicate owner is introduced.

## Verification

`tests/gen3_early_props_test.lua` covers all twelve recipe/edition combinations,
source/tileset/permission fallbacks, bounded geometry, notice depth and its
walking-row clearance, shallow soil, separate closed containers and flat native
foliage cards. The garden's face and rim sample actual brown timber pixels;
the original dark outline is used only for recessed soil.

Native rendered/source comparison uses official Gen1Recomp 0.3.89 with a
separate disposable profile per edition. Four views plus eye level cover the
notice, garden, Route 102 soil and Route 103 shoreline (20 captures per
edition). This candidate review precedes the final archive checks. The final
wood swatch correction is additionally reviewed in actual first person.

`tools/qa/gen3-early-prop-walks.lua` performs native bumps against all three
field-fixture families, reads the gym notice and berry-soil dialogue through
normal A/B input, and captures OFF and actual first-person modes. The garden
approach is the native walkable flower cell `(24,24)` south of the two-row
trough cluster; `(24,23)` is itself a blocked trough drawing. The fixture never
changes native collision, objects, scripts or the VM.

These are presentation fixtures, not a claim of full-city completion, a
manual keyboard session, every berry-growth state, multiplayer or networking
verification. Final release evidence should record the packaged rerun and its
process status separately.

Candidate native runs passed in all three editions: nine blocked approaches,
six dialogues (three notices and three berry interactions), and 24 inspected
OFF/first-person/dialogue captures. Normal B input declined the berry choice and
returned through the native VM. These prove the interaction path, not every
berry-growth state. All three candidate scene surveys passed their four spots
with 60 inspected orbit/eye captures, before the final timber UV correction;
the 24 input captures include that corrected timber in actual first person.

The restricted-shell wrapper returned status 1 after each otherwise completed
candidate run. A separate empty `xvfb-run -a true` reproduced status 1 in the
restricted shell and status 0 with the approved escalated shell. Candidate
assertions and captures are retained, without claiming clean native process
exit. The final package rerun uses the approved native shell and records its
own exact status in the release evidence.
