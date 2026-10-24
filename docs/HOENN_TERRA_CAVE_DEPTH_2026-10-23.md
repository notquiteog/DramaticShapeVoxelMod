# Native Terra weather cave depth — 2026-10-23

Adds the eight real Emerald weather-controlled Terra Cave entrances to the exact Hoenn native-art adapter. Production follows only a live open drawing, exact warp destination, same-level passage and blocked native neighbors. It never selects a weather state, changes collision, modifies a warp or opens rock. Ruby/Sapphire remain isolated. Existing geometric volume generation is unchanged.

| Native weather state | Map/cell | Header/mouth | Rock cap/side |
| --- | --- | --- | --- |
|1|Route114 (7,4)|347/34f|269/270 red Fallarbor|
|2|Route114 (6,46)|259/261|241/243 khaki|
|3|Route115 (21,6)|259/261|241/243 khaki|
|4|Route115 (36,10)|259/261|241/243 khaki|
|5|Route116 (59,13)|09f/0a7|06c/071 ordinary|
|6|Route116 (79,6)|09f/0a7|06c/071 ordinary|
|7|Route118 (42,6)|09f/0a7|06c/071 ordinary|
|8|Route118 (9,6)|09f/0a7|06c/071 ordinary|

Numbers in the drawing columns are hexadecimal. The [original abnormal-weather script](https://github.com/pret/pokeemerald/blob/master/data/scripts/abnormal_weather.inc) names these eight genuine openings. The two unused Route113 ROM warp records are excluded. Route114/115/116 retain their previously reviewed ordinary cave placements alongside the weather points. Each point has its own exact destination and, for114north, distinct red source-art profile; no map-wide MID/destination guess is used.

## Native evidence

Official latest engine checked for this batch: v0.3.96, commit0e92b587468c2db7c386f055fc272e6505b0f401. Final adapter SHA256:da9d2b8704b729ad08bbc3ed1fe02c8a0218821dcf108ee2d1939e3941409ca0.

A native census first loaded each real weather state through normal map on-load scripts and recorded all eight actual drawings/collision neighborhoods. Source comparison board and individual native screenshots were inspected. Actual mouth collision is113 and header collision7 at each active opening.

Final dedicated native run exits0 and reports8owners/16normal entry+returns, eight preserved closed states, unchanged native hashes and recovery0. The isolated fixture sets VAR_ABNORMAL_WEATHER_LOCATION to0 for each closed-state check, then its actual1..8 value for the matching open state; VAR_SHOULD_END_ABNORMAL_WEATHER stays0. These are test-only story/weather fixtures, not production mutations. Viewpoints must be native walkable, unoccupied land.

Every mouth has inspected native/front/first-person/side/rear captures. Every location was entered and returned by actual movement and native warps in2D and3D. Exact runtime meshes have92physical triangles each, zero positive-area coplanar intersections, one floor owner and22px recess; original terrain perimeter heights and floor anchors stay fixed. Existing actors/Pokémon/flowers and their defaults are unchanged.

Evidence root: `/home/admin/Projects/.scratch/hoenn-world-096-20261023/`:

* `terra-native-census/hoenn-cave-entrances/emerald/`: native state JSON, individual native captures, terra-native-board.jpg.
* `terra-native-final/hoenn-cave-entrances/emerald/`: run.log, hoenn-weather-cave-entrances.json, all48individual native/closed/3D captures, and four eight-image review boards.
* `terra-native-census.py` and `terra-native-final.py`: exact isolated runners; the latter runs tools/qa/hoenn-weather-cave-entrances.lua through the existing scratch Scene/Terrain hook. Production Scene remains integration-owned.

Passing checks:

```
luajit tests/gen3_hoenn_cave_entrances_test.lua
luajit tests/gen3_terrain_test.lua
luajit tests/gen3_terrain_uv_test.lua
luajit tests/gen3_ruby_sapphire_test.lua
luajit tests/gen3_hoenn_test.lua
python3 tools/audit_hoenn_cave_geometry.py <native-report>
```

The exact test covers all eight active drawings/destinations/art profiles, closed-state rejection, Ruby/Sapphire exclusion and unused Route113 exclusion. Prior conditional Magma/Altering and common/regional tests still pass. Native assets/caches/captures remain scratch.

There are now28 reviewed possible Emerald mouth placements, including eight mutually exclusive weather locations, plus16 each Ruby/Sapphire. This counts individually accepted positions, not28 simultaneous open mouths, full-map acceptance or original ORAS model coverage. White Sootopolis, underwater/water-facing and other distinct architectural openings remain pending; next work stays separate from this checkpoint.
