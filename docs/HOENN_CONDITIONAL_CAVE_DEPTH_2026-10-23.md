# Emerald conditional outdoor cave mouths — 2026-10-23

Adds exactly two Emerald native-art rock reveals to the existing adapter:

| Native mouth | Required live drawing | Destination | Geometry |
| --- | --- | --- | --- |
| Jagged Pass (16,18) | Lavaridge256/25e; mouth collision113, projected header collision0 | Magma Hideout1F | Existing regional red rock profile |
| Route103 (45,6) | General09f/0a7; blocked header, mouth collision113 | Altering Cave | Existing ordinary rock profile |

This is native-art depth repair, not new original ORAS model intake. It adds no global rock height, collision, native warp, floor-height or story-state changes. Geometry generation is byte-for-byte unchanged; only the exact Emerald placement ledger grows. Ruby/Sapphire do not inherit these mouths.

Both mouths are conditional. Production claims only the actual open native drawing and exact destination/neighbor context. It never sets a flag or opens a closed cave. The [Jagged Pass native script](https://github.com/pret/pokeemerald/blob/master/data/maps/JaggedPass/scripts.inc) conceals the opening at states0/1 and reveals it at state2; the [native object definition](https://github.com/pret/pokeemerald/blob/master/data/maps/JaggedPass/map.json) owns the guard through FLAG_HIDE_JAGGED_PASS_MAGMA_GUARD. The [Route103 native script](https://github.com/pret/pokeemerald/blob/master/data/maps/Route103/scripts.inc) opens Altering Cave only after FLAG_SYS_GAME_CLEAR.

The held Altering draft's shorter profile was rejected by actual native on-load evidence:7c/91 is the closed wall drawing. The open postgame mouth is09f/0a7, so it uses the reviewed ordinary proportions. No speculative shortened hood ships.

## Native acceptance

Official latest engine checked before this batch: v0.3.96, commit0e92b587468c2db7c386f055fc272e6505b0f401. Exact adapter SHA256:15493eb7dfef7785e6a17cd7c2c6a777a31aa1f724bb3a298f28fa48dc55c18f.

Final isolated Emerald process exits0 and reports2owners/4entry-returns, unchanged grids, recovery0. Disposable story fixture explicitly sets VAR_JAGGED_PASS_STATE=2, FLAG_HIDE_JAGGED_PASS_MAGMA_GUARD=true, FLAG_SYS_GAME_CLEAR=true and the existing Regi flag. Closed Magma, Altering and Regi maps are verified before their respective fixture flags: no cave owner and unchanged native layout hash. Final viewpoints require native walkable, unoccupied dry land.

Both new entrances were entered and returned through real movement/warps in native2D and3D. Native drawing plus front, first-person, side and rear screenshots were inspected for each; the guard is hidden through its own story flag for unobstructed open-Magma views. No engine gameplay or actor code was replaced.

Evidence under `/home/admin/Projects/.scratch/hoenn-world-096-20261023/cave-conditional-review/hoenn-cave-entrances/emerald/`: run.log, hoenn-cave-entrances.json, `EM_JAGGED_PASS-16-18-*`, `EM_ROUTE103-45-6-*`, and all three `*-closed-native-preserved.png`. Runner: `.scratch/hoenn-world-096-20261023/cave-conditional-review.py`. Driver: tools/qa/hoenn-cave-entrances.lua; QA_MAP and QA_ENTRY_MAP accept pipe-separated Lua patterns to bound this new-family batch. Only the separate scratch Scene/Terrain hook was used; production shared hook remains integration-owned.

Native hash JaggedPass7726073b988e81361b7fd75475529a2dfb4c71b1edd8be7f1e327b4e2c74c88b; Route103cc7a0ab41bafeea597bf4abc39fa0a314efee450cbbdd43562fdda9cd0460045. Both match before/after actual entry and return.

Exact emitted geometry audit:92physical triangles per new mouth, zero positive-area coplanar intersections, one floor owner and22px recess. Existing boundary heights/native anchors remain unchanged.

Passing checks:

```
luajit tests/gen3_hoenn_cave_entrances_test.lua
luajit tests/gen3_terrain_test.lua
luajit tests/gen3_terrain_uv_test.lua
luajit tests/gen3_ruby_sapphire_test.lua
luajit tests/gen3_hoenn_test.lua
python3 tools/audit_hoenn_cave_geometry.py <native-report>
```

Coverage is now20 reviewed Emerald placements and16 each Ruby/Sapphire, with the previous18/16/16 native acceptance recorded separately. This batch verifies the two additions, not every existing placement again. Terra weather caves, water-facing/underwater mouths and the separate white Sootopolis facade remain pending. Whole-map/source-model coverage is incomplete. Raw sources/captures remain scratch; release is integration-owned.
