# Original ORAS Oldale refrigerator

The original Alpha Sapphire Oldale refrigerator replaces all 39 matching
RSE home drawings, 13 per edition. Its original case, two handles, six paper
notes and two solid magnets remain independent source geometry. Native
walls, floor, walking apron, collisions, interactions and scripts are unchanged.

Source: ZO230 → AD115 → MM171 → GR513, model `t102r0101_00_00`, submesh 8,
material `ref01`. The selected 166 original triangles, positions and UV0
independently match Nitrogen. The original opaque 64×64 texture is unchanged.
The committed provenance records source/model/texture hashes; no source
archives, ROM data, native pixels, caches or captures are included.

The model adds 200 closure triangles: the original eight-edge underside,
recessed handle/magnet attachment backs, and 0.03-source-unit inner surfaces
and rims for the original paper sheets. Attachment backs sit 0.05 source
units inside the case instead of duplicating its front plane. Every welded
edge has incidence two, and there are no duplicate triangles. All vertex RGB
is white so the renderer owns lighting. No floor, light or shadow geometry
was imported.

The source's +X front is rotated one quarter-turn to native +Z. A uniform
16×16 fit capped at native height 32 preserves source proportions; it fills
more than 85% of both blocked footprint axes. Only Y0 contact vertices use
the shared 0.025-pixel recess. Source upper geometry and native floors do not
move. Exact pair, complete metatile pattern, collision rows and consistent
native height are required; changed maps and missing resources retain the
complete native furniture.

Before native verification, the official latest engine release was checked:
0.3.95, published 2026-10-21T02:42:51Z. Isolated QA identities on that exact
source and official Linux LÖVE shell visited every occurrence in Emerald,
Ruby and Sapphire. All 39 room overviews were inspected, together with
source front/back/left/right/quarter/top/low views and native first-person
front/side/close views. Expected source counts and unchanged live native
hashes passed. All 13 Emerald missing-texture rooms retained native furniture;
no partial source furniture was hidden. Drivers emitted PASS; the shell
returned 1 at shutdown, so no clean-exit claim is made.

Reproduce source conversion with `tools/import_oras_oldale_fridge.py MODEL
AREA_TEXTURES DECODER NITROGEN_SRC OUTPUT`. The helper independently validates
source geometry and texture state before export. Data and source PNG
regeneration were byte-identical. The furniture data/adapter, existing
imported-interior, home, Kanto-home, stair, diorama and shared model suites
pass. Component acceptance is recorded separately from whole-map coverage.
