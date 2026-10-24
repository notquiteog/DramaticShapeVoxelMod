# Sootopolis Cave of Origin mouth — 2026-10-23

The exact native mouth at Sootopolis (31,16) now has a recessed white rock reveal in Emerald, Ruby and Sapphire. Ownership requires the native 221 mouth, 25b header, matching Cave of Origin warp, blocked neighbors and unchanged passage elevation. The cap/side use native white rock 2d9/2e1. Only the two mouth/header cells are claimed. The surrounding five-cell portico/apron remains native and flat, pending separate original-source intake; this is not complete Sootopolis landmark acceptance or an ORAS model import.

The local white hood rises over 12px to keep its outer rock cap above the inner rear ceiling even when Emerald's back perimeter reaches zero. Existing cave profiles retain their original 24px ramp. Perimeter elevations, opening/floor anchors, global walls, collisions, objects and warps are unchanged. The regression checks actual emitted cap clearance as well as the existing one-floor/closed-reveal geometry checks.

Latest official engine checked before this native batch: v0.3.96, commit 0e92b587468c2db7c386f055fc272e6505b0f401. Final adapter SHA256: 4b90995f1092c3e2707daa8e1c8cb4ec8b45e5a93ac62603802254a1b2f3a898.

Final native runs pass in all three editions: one exact mouth owner and two normal movement/warp entry-and-return cycles per edition (2D and 3D), unchanged native grid hashes and recovery0. Emerald has90 physical triangles, Ruby/Sapphire92, with zero positive-area coplanar intersections, one floor owner and22px recess. Native/front/first-person/side/rear captures were inspected. The final Emerald first-person capture confirms the initially observed outer-cap intrusion is removed; Ruby/Sapphire also have clear closed ceilings.

Ruby/Sapphire fixtures set their native FLAG_LEGEND_ESCAPED_SEAFLOOR_CAVERN and FLAG_LEGENDARY_BATTLE_COMPLETED flags to move the guard through original scripts. Emerald's guard remains. First-person and entry checks start at the native unoccupied walkable cell (31,17), past that guard. This proves the mouth/warp, not progression through a default story guard. No production flags or collision are changed.

Evidence root: `/home/admin/Projects/.scratch/hoenn-world-096-20261023/`:

* `sootopolis-cave-before/hoenn-cave-entrances/{emerald,ruby,sapphire}/`: native Scene census and before captures.
* `sootopolis-cave-after/hoenn-cave-entrances/{emerald,ruby,sapphire}/`: final JSON, run.log and five views per edition.
* `sootopolis-cave-after.py`: isolated official-runtime runner; `tools/qa/hoenn-cave-entrances.lua` is the committed driver. It uses QA_MAP and QA_ENTRY_MAP both `SOOTOPOLIS_CITY$`.

Passing checks:

```
luajit tests/gen3_hoenn_cave_entrances_test.lua
luajit tests/gen3_terrain_test.lua
luajit tests/gen3_terrain_uv_test.lua
luajit tests/gen3_ruby_sapphire_test.lua
luajit tests/gen3_hoenn_test.lua
python3 tools/audit_hoenn_cave_geometry.py <native-report>
```

Shared integration requires the generic cave adapter prepare/callback hooks and explicit cave terrain support; production Scene remains integration-owned. Current reviewed possible positions total29 Emerald (including eight mutually exclusive weather locations) and17 each Ruby/Sapphire. Water/underwater entrances and the larger white portico remain pending. Actors/Pokémon/flowers retain their existing HD2D defaults and standalone/API3 behavior.
