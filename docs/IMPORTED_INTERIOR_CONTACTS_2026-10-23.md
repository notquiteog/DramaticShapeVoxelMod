# Source furniture contact and closure audit

All 158 existing ORAS PC, television and full blocked-bed placements were
rechecked in native engine 0.3.95: 34 Emerald, 34 Ruby, 34 Sapphire, 28 FireRed
and 28 LeafGreen. These comprise 87 PCs, 62 televisions and nine beds. The
latest official release was checked before the batch; isolated disposable
profiles used matching source and the official Linux LÖVE shell. Every map's
live native hash is identical before and after rendering. Native entry-script
changes are recorded separately in the component acceptance ledger.

The old bed underside used approximate fan caps. Seven positive-area coplanar
overlaps were confirmed. New closures follow the original five boundary loops
of 16, 18, 32, 32 and 34 vertices. A minimum-area boundary triangulation rejects
faces overlapping original source planes. All 534 original triangles, their
positions, UVs and PNG bytes remain identical. The new 122 authored triangles
replace the old 90; all welded model edges now have exactly two incident faces.
Nine source views, including both underside directions, were inspected.

PC, TV and bed physical Y0 contacts now use the existing 0.025-pixel recess.
Only eight authored PC cap vertices needed their residual normalized float
noise (3.87e-7) snapped to zero so that they share the exact body-bottom plane.
All 170 original PC triangles and every upper vertex are unchanged. Television
geometry is unchanged. A television's stand contacts its original native
cabinet at height six; native cabinet heights and room floors do not move.

Tests compare ordinary and recessed fits, requiring every upper Y coordinate
and every X/Z coordinate to remain exact. A geometric triangle clipping test
checks all nine imported furniture models for positive-area coplanar overlaps,
including differently triangulated duplicates. No depth bias hides internal
source intersections. Native overview and individual first-person captures
were inspected for all 158 placements. NPC and native wall occlusion remain
active. All 62 Emerald and FireRed fixture maps also pass absent-PNG fallback.
Every native tour emitted PASS; the shell returned one on shutdown, so no
clean process-exit claim is made.

Both changed source converters reproduce byte-identical model data and PNGs
from the original user archives. Source/contact, exact adapter guards, missing
resource, home/Kanto shell, stair aperture, diorama and shared model tests pass.
Only identifier/hash metadata and source repairs are committed. Full-map visual
acceptance and the remaining source furniture families remain outstanding.
