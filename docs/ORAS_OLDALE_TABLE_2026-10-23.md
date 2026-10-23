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
