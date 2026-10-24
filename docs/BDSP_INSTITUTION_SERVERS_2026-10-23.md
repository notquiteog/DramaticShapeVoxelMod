# Original BDSP institution server racks

The original BDSP Galactic warehouse server now replaces 61 exact native rack
drawings across 25 maps in all five GBA editions: one Birch Lab rack per RSE
edition and 29 racks per Kanto edition (Oak's Lab, Silph Co., Power Plant and
Pokémon Mansion). This is a semantic server-rack replacement using genuine
newer Pokémon source art, not a complete-room replacement.

The user-supplied archive `361484.zip`, `1F.dae`, contains the original static
`P_C_001_Server_01-mesh` and `T_C_001_Server_01_C.png`. Its 36 original triangles,
Collada hierarchy/meter/Y-up transforms and UVs are retained. The opaque
256×256 source PNG is byte-identical. One six-triangle underside cap follows
the existing six-edge rim. Only original underside precision noise below
1e-6 normalized units is snapped to the bottom plane; every upper source
vertex is unchanged apart from uniform normalization. RGB remains white;
source shadow planes, floors, glow/effect textures and unrelated room props
are excluded. Provenance records archive, scene and texture hashes.

The complete 42-triangle model is closed, with every welded edge incident to
two triangles. A geometric triangle-intersection test rejects positive-area
coplanar overlaps, including differently triangulated surfaces. No depth bias
hides source intersections. Uniform native 16×16 fitting preserves the original
server's proportions and stays within the single blocked body cell. Height
remains below native 32. Only Y0 contacts use the shared 0.025-pixel recess;
upper source geometry and native floor elevations do not move.

Each adapter requires the exact native family, pair, design, complete three-row
metatile pattern, collision rows and uniform height. The actual Kanto Mansion
and Power Plant apron is native collision 43; it remains unchanged and walkable.
Birch's native header permission is 0. Changed or third-party drawings stand
down. LeafGreen's pair aliases are resolved by the existing scene adapter.
Missing source resources retain the complete native rack without partial claims.

Before verification, the official latest engine release was checked: 0.3.95,
published 2026-10-21T02:42:51Z. Matching source and the official Linux LÖVE shell
ran disposable profiles for all five editions. All 61 placements were visited
and their native room overviews and individual first-person views inspected,
together with source front/back/left/right/quarter/top/low views. Large maps
used FAR distance to include every fixture. Native walls and neighboring
furniture retain their real occlusion; the original game's live dialogue may
remain visible during the tour. Counts and unchanged live native hashes pass.
All 11 FireRed fixture maps and Sapphire's lab also pass missing-PNG fallback.
Drivers emitted PASS; the shell returned 1 at shutdown, so no clean-exit claim
is made. No source archive, raw scene, native pixels, caches or captures are
committed. Identifier/hash-only component acceptance is separate from maps.

`tools/import_bdsp_institution_server.py ARCHIVE OUTPUT` reproduces conversion;
regenerated model data and PNG were byte-identical. Source topology, manifold
closure, exact guard/fallback, contact-depth, positive-area coplanar overlap and
existing home/Kanto/diorama/shared-model tests pass. Full-map source coverage
and whole-map visual acceptance remain outstanding.
