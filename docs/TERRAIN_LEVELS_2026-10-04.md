# Native terrain levels — 2026-10-04

## Implementation

Terrain remains presentation-only: no collision, warp, encounter, native
layer or save changes. Original source pixels supply every tread and face.
Raw GBA collision-layer numbers are not multiplied into arbitrary elevations.

- Gen1 retains its authored CAVERN shelves/steps and existing outdoor profiles.
- Crystal retains its reviewed cave, stage, gym, pier and outdoor floor drawings.
  The shared solver now supports unequal-length flights meeting common landings.
- FRLG retains semantic stair behavior 0x2A and its existing terrace/deck profiles.
- Emerald's equivalent behavior is seaweed, NOT stairs. Hoenn normal-behavior
  tread artwork (General AF/CF, Sootopolis 244/245, Lavaridge 2AF) and Meteor
  Falls cave-encounter tread 202 now drive both geometry and floor topology.
  Secondary IDs are scoped to their native tileset; blocked tree copies stay trees.
- A native mountain-top landing south of a stair identifies south-up mound
  access. Treads, retaining-edge support and actor/camera contact agree.
- A linear uphill graph solver preserves minimum native flight rises while
  allowing unequal-length paths to share one landing height. Impossible ascent
  cycles are reported and bounded, not silently inflated.
- Fortree's variable-layer bridges join their east/west banks without merging
  the ground at their sides. Other tilesets retain their layer connectivity.
- Mesh cache revision 86 invalidates old stored geometry.

## Evidence

Official Linux Gen1Recomp 0.3.51; isolated profiles only. Scratch reproduction
scripts, source diagrams and captures: `/home/admin/Projects/.scratch/elevation-20261004`.
Native source reviewed: Mossdeep, Sootopolis, Route 119, Jagged Pass, Meteor Falls,
Blackthorn, Route 45, Dark Cave and Dance Theater. No imported art is committed.

Full imported-map topology census (not all-map visual approval):

| Game | Maps | Maps with raised floors | Stair flights | Height conflicts |
| --- | ---: | ---: | ---: | ---: |
| Crystal | 388 | 71 | 69 | 0 |
| FireRed | 426 | 48 | 293 | 0 |
| LeafGreen | 426 | 48 | 293 | 0 |
| Emerald | 519 | 58 | 317 | 0 |

Emerald previously recognized zero flights. Updated elevation_review_driver.lua
supports Emerald boot/targets as well as Crystal/FRLG. Census records source
layout unchanged; fields are presentation data, not gameplay edits.

Inspected rendered views include Mossdeep, Sootopolis, Route 119, Meteor Falls,
LeafGreen Mt. Ember, Crystal Dark Cave, and Yellow Victory Road. Overview and
first-person fixtures completed across all five editions. One initial Mossdeep
sample on shallow-water effects used the native fallback; the dry stair-landing
fixture was used for 3D verification. Yellow's generic landing finder did not
find the requested complete stair pattern, so it used a native walkable sample;
no new Gen1 walking claim is made.

Actual walking checks (native input, 55 frames):
- FireRed Mt. Ember: support 24 to 36, maximum per-frame change 1.5.
- Emerald Sootopolis: support 0 to 6, maximum change 1.5.
- Emerald Route 119 south-up mound: support 12 to 18, maximum change 1.5.
- Crystal Dance Theater: support 0 to 6, maximum change 1.5.
- Gen3 first-person eye tracked the final floor plus native eye height (13.5).

Standalone final suite: **112 pass / 11 existing fail / 85 skip**. Added guards
for native Hoenn stair scope, seaweed exclusion, shared unequal-flight landings,
south-up tread contact and bridge-side separation. No new failures.

## Remaining limits

These are verified terrain relationships, not a declaration that every area is
finished. Other unreviewed Hoenn cave/terrain drawings, arbitrary bridge
underpasses with simultaneous actor layers, waterfall volumes, distant fill,
and scenery foundations near sharp terrain boundaries still need work. The
normal stairs and selected cave profiles are covered; unknown art is not raised
based only on its color or blocked collision. Building/vegetation polish remains
separate. No mod/cart release is made by this change.
