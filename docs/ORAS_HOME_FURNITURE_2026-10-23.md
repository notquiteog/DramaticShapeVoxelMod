# Original ORAS Littleroot furniture

`Gen3ImportedInteriors` now replaces the exact RSE starting-house refrigerator
and pink dining-table drawings with the original ORAS components. The table
retains its original tabletop book. Emerald May's distinct yellow table stays
native pending its separate source adapter. Generic home tables are not aliases.

Source: user-supplied Alpha Sapphire RomFS, ZO223 → AD112 → MM164 → GR506,
`t101r0101_00_00`. The importer independently compares selected positions, UV0
and indices with Nitrogen. Original texture RGBA and UVs are retained. Raw
RomFS records and decoder checkouts stay outside the package. Attribution and
hashes are in `assets/scenery/oras-home-furniture/provenance.json`.

The table contains 100 source table triangles and 28 source book triangles,
plus 62 separately authored rim-closure triangles. The refrigerator contains
92 original triangles plus 14 underside-closure triangles. All welded edges
have two incident faces. Uniform fitting preserves source proportions and
stays inside the existing blocked footprint. The table's third native apron
row stays walkable. The refrigerator remains independent of the flat room wall.
Source vertex RGB is white; the renderer owns vertex lighting and shadows.
Source shadow/floor/light meshes are excluded. Native floors and wall heights
are unchanged. No native pixel overlay remains over successfully uploaded models.

Official latest engine 0.3.95 was checked before the batch. Its matching official
Linux LÖVE shell rendered both starting houses in Emerald, Ruby and Sapphire:
3, 4 and 4 actual source placements respectively. All drivers emitted PASS;
shell shutdown returned 1. Native layout/collision/elevation SHA-256 values
remain unchanged. Source front/side/rear/top/low views, native room overviews,
and four walkable first-person table views were inspected. Missing home textures
retain both complete native objects; NATIVE VOXEL retains native furniture.

Focused tests: `imported_home_furniture_data_test`,
`gen3_imported_home_furniture_test`, `gen3_imported_interiors_test`,
`gen3_home_rooms_test`, `gen3_kanto_homes_test`, `interior_diorama_test`.
The data test checks closure topology, uniform native fit and white vertex RGB.
The adapter test checks exact source identity, every native permission/height
guard and atomic upload failure. The importer compiles with Python; all changed
Lua files compile with LuaJIT. These checks do not imply complete interior
coverage; the five-edition census remains the inventory of outstanding families.

The shared contact fit now recesses only source Y0 vertices by 0.025 native
pixels. All upper vertices remain byte-for-byte equal to the ordinary fit.
This separates underside/leg contact faces from the unchanged native floor.
Native Emerald first-floor overviews and four walkable table views were repeated
on 0.3.95 after the contact change; the source placement/hash checks still pass.
