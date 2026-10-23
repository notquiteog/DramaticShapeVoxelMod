# Original ORAS checked home table

The exact `hoenn_home_table_yellow` drawing now uses the original Oldale table
from the user's Alpha Sapphire source: ZO230 → AD115 → MM171 → GR513,
`t102r0101_00_00`. All 39 native occurrences were rendered and inspected on
official engine 0.3.95: 13 maps each in Emerald, Ruby and Sapphire. This covers
one furniture family, not the other furniture or complete rooms.

The source contains 236 table-body triangles and 84 checked-cloth triangles.
Their positions, UV0 and original indices independently agree with Nitrogen.
The 168 added triangles close original body/leg rims and give the hanging
cloth a thin inner surface and rim. The original cloth silhouette, transparent
scalloped edge and space beneath the table remain visible from low views.
Original texture RGBA/UVs are retained; vertex RGB is white. Source floor,
shadow and lighting meshes are excluded. Uniform fitting stays inside the
four existing blocked cells. Native floor and wall planes do not change.

Depth checks: zero duplicate source/closure triangles; every welded edge has
two incident faces; cloth inner/outer surfaces remain separated by 0.12 source
units (about 0.10 native pixels). Native source overviews, first-person front,
left, right and rear views and separate source front/side/rear/top/low views
were inspected. There is no native table overlay over the source model and
no imported floor beneath it. Missing source textures retain complete native
furniture in all 13 Emerald rooms. Native metatile/collision/elevation hashes
match the original census after every placement.

All native drivers emitted PASS; the Linux shell returned 1 on shutdown.
Latest official release metadata was checked again before this batch and
remained v0.3.95, published 2026-10-21T02:42:51Z. Dedicated disposable edition
profiles were used. Source inputs, decoder checkouts and captures remain in
scratch; only selected model data, PNGs and attribution/hashes are packaged.

`imported_home_furniture_data_test` checks original triangle counts, closure
topology, no duplicate faces, separated cloth surfaces, white vertex RGB and
uniform native bounds. `gen3_imported_home_furniture_test` checks exact native
identity, all cell permissions, elevation consistency and atomic resource
failure. Public-PC and existing home/interior regressions remain passing.

The neighboring `hoenn_home_table_plain` family now has its own original ORAS
component from ZO231 → AD115 → MM172 → GR514, `t102r0201_00_00`. The source
batches its dining table and a separate wall desk into one mesh; only the
236-triangle dining body under the original 84-triangle cloth is selected.
The native drawing covers 38 placements: 12 Emerald, 13 Ruby, 13 Sapphire.
All 38 were rendered and inspected on the same 0.3.95 runtime. Native front,
side/rear, source low/top/side views, and all 12 Emerald missing-texture
fallbacks were inspected. Existing tests now cover both original variants.
No ground, wallpaper, floor, source shadow or extra wall desk is imported.

Live native hashes are taken after the engine's entry scripts and compared
again after source rendering. In RS Mossdeep Game Corner 1F, the native script
closes the secret stair at (3,0) and (3,1), changing metatiles 0x203→0x28d and
0x219→0x295 (the latter also changes collision 0x72→7). This occurs at camera
level 0 before modern meshing. Those live engine changes are recorded separately
from the static adapter census; the mod preserves the post-script layout.
