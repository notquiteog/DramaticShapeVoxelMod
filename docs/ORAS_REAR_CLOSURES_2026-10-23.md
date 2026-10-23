# ORAS exterior rear closures

The original ORAS Gym, Oldale/Petalburg/Rustboro Mart, two Oldale homes, three
Petalburg homes, and six Rustboro homes omit their rear walls. Earlier rear
screenshots showed the backs of front/interior faces through those openings;
that interpretation was incorrect. Earlier rear acceptance is withdrawn and
superseded by the ray and rendered checks recorded here. Prior native door,
collision, source identity and contact-ring tests remain relevant.

All fifteen models append an opaque rear closure from their own original
left/right rear profiles at every structural height. Each surface carries a
reviewed solid texel from that model's existing wall/foundation texture. No
new painted features, windows or textures are introduced. Backing planes sit
0.1 original source units inside the rear perimeter. Stepped joins subtract
existing coplanar source roof/trim triangles. Every original source vertex,
UV, index, part and doorway anchor compares exactly unchanged against the
preceding commit after the appended part is excluded. The original bounds,
source proportions, portal offsets and native blocked-footprint guards remain
unchanged. Existing underside/contact-ring recesses still apply; the added
rear vertical ring introduces no duplicate ground plane.

`tests/gen3_source_rear_closure_test.py` tests the actual generated source data:
135 rear rays at three heights across all fifteen bodies hit the new backs,
all added vertices remain in their original bounds, and113,442 coplanar
triangle candidates involving a new closure have zero overlapping area.
All51 existing mocked R/S/E source/door/clearance/fallback cases pass. All
fifteen source rear-quarter renders were inspected, retaining source roofs,
fixtures, side glass, original trim and depth.

Latest official engine was rechecked before the native batch:
[Gen1Recomp0.3.95](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Its matching Linux LÖVE shell uses isolated copied profiles with the physical
controller module disabled only in the QA engine configuration. Native driver
`tools/qa/hoenn-rear-closures.lua` checks exact successful facade ownership at
seventeen placements (all unique bodies plus town Gym copies), native layout
hashes, streaming completion and zero recovery failures. Front, sides, rear
first-person and overview captures from rear player positions use walkable native cells;
blocked viewpoints are explicitly logged instead of bypassing collision.
All51 placements pass across Emerald, Ruby and Sapphire. Native rear contact and each available surrounding view are inspected.
All17 Emerald placements also pass with all five source asset folders blocked: the facade claims zero source buildings and native fallback remains available.
No native collision, floor, warp, script or save is altered.

This correction adds no map coverage. The current census remains source
candidate39EM/38RU/38SA of244 recognized civic placements, with129 missing.
Source eligibility does not mean whole-map native acceptance. Devon, Rustboro
Flat2/tower and the other regional families remain in the source queue.

Separate existing-source issue found during this audit: two pairs of Oldale
southeast glass top/bottom return triangles have coplanar overlap. This is not
introduced by the new rear part; targeted cleanup continues next. There is no
global no-z-fighting acceptance claim for every remaining source family.
