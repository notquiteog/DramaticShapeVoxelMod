# Gold / Silver / Crystal service-room models — 2026-10-13

## Result

Native Center PCs now have their own recessed-screen cabinet, keyboard, lower
cupboard, closed rear and sides; bedroom PCs remain separate. Healing machines
have a recessed horizontal tray, stepped shoulders, rear green display and a
continuous front cross. Their adjacent blue status console is authored separately
rather than becoming a generic folded box. The lab machine remains unchanged.
Native healing timing/party count/palette animation remains engine-owned; balls
use the tray's support height (6), rather than the tallest rear display (12).
**Gen2 balls remain native projected sprites, not newly modeled spheres.**

Mart display cabinets retain the large native ball panel on one front surface,
with separate stock, shelf recesses, closed casing and source-colored top/back.
The former model fragmented that panel across arbitrary stock boxes. Existing
registers, coolers, department windows/directories, benches and elevators remain.

Upstairs, native link controls and red warp doors are separated; no CRT/desk
occupies the warp approach. Blue partitions have continuous closed casing and
cream caps; the central booth has native glass and control faces, side counters,
a closed rear and an open center approach. Native floor pads stay shallow.

The Center's north wall now sits behind the entire healer, rather than cutting
through its screen and tray. Indigo has its source L-shaped lobby and northern
alcove walls; exact dark padding tiles no longer stand as black blocks. Crystal's
department-store roof has no invented room enclosure/ceiling, uses the outdoor
sky/light gates, and has a low central curb with the native yellow floor drawing
horizontal. The lower source curb apron is walkable: it is retained flat and
excluded from the solid model. Roof benches use their source pink seat variant.

## Inventory and scope

Imported block-layout census: Gold/Silver each 11 layout groups; Crystal 13,
including the roof and unused/mobile admin office. The current engine expands
`POKECENTER_2F` to 20x8 cells in all three editions; the imported block census
alone is therefore not sufficient runtime coverage evidence.

| Reachable family | Runtime representative / edition coverage |
| --- | --- |
| Standard Center 1F | Cherrygrove, G/S/C; imported drawing shared by 21 named maps |
| Center upstairs | POKECENTER_2F, G/S/C; runtime expanded room verified |
| Indigo lobby | INDIGO_PLATEAU_POKECENTER_1F, G/S/C |
| Standard Mart | Cherrygrove, G/S/C; imported drawing shared by 13 named maps |
| Department floors 1–6 | Goldenrod each floor, G/S/C; paired Celadon imported layouts |
| Department elevator | Goldenrod, G/S/C; paired Celadon imported layout |
| Traditional shop rooms | Mahogany Mart and Mt. Moon Gift Shop, G/S/C; existing models reviewed |
| Department roof | Goldenrod, Crystal; native walking apron explicitly checked |

No claim that every named room was visited. Beta upstairs maps, unused/mobile
admin office, Japanese PokéCom variants, story-dependent secret-shop transitions,
and every individual legacy prop are not exhaustively verified. Existing
rooftop planters/parapets retain legacy source-mapped forms. This batch corrects
reviewed service fixtures; it is not an all-object 3D-completion claim.

## Runtime evidence

Exact engine: official 0.3.85 source/runtime in
`/home/admin/Projects/.scratch/runtime-0.3.85`, Linux LÖVE/Xvfb native game shell.
Parent verified official release selection. Isolated identities
`gold-clinics-qa`, `silver-clinics-qa`, `crystal-clinics-qa` under
`/home/admin/Projects/.scratch/gen2-clinics-20261013/profiles`.
Gold/Silver initial v13 caches did not reach the driver; v15 copies from isolated
parity QA profiles succeeded. Crystal used an isolated current QA copy. No player
save was opened or overwritten. Companions available in those profiles remained
independent; the Gold/Silver HUD differs from the Crystal HUD. Runtime version
assertions identify the editions, not the sometimes generic “POKEMON GOLD” label.

Evidence root: `/home/admin/Projects/.scratch/gen2-clinics-20261013`.

- `source.lua`, `census.lua`, `census.txt`: inventory and native artwork/tiles/
  collision rows; `gold-source-v15`, `silver-source-v15`, `crystal-source`.
- `views.lua`, `crystal-before`: original folded tray, fragmented Mart panel.
- `crystal-recess/CHERRYGROVE_POKECENTER_1F-{front,side,rear}.png`: detailed
  machine/console geometry and the exposed rear display after wall correction.
- `families.lua`, `{gold,silver,crystal}-families`: 13/13/14 room representatives,
  each native image plus front, side, rear and first-person view. Full native
  tile/collision grids remained equal before/after rendering.
- `final.lua`, `{gold,silver,crystal}-final`: revised Center, upstairs, Indigo,
  Mart (and Crystal roof pre-curb revision). Center shots include native healing.
- `final-detail.lua`, `{gold,silver,crystal}-detail`: final upstairs booth and
  Indigo. Gold/Silver finish; Crystal reaches two passes then correctly fails
  the first rooftop curb's walking-apron intersection at cell (6,4).
- `roof-final.lua`, `crystal-roof-final`: repaired low curb and unchanged flat
  walking apron; source, front, side, rear and eye views, open sky inspected.

All three editions' changed Center/Mart/upstairs/Indigo side/rear/eye captures
were inspected. Crystal room-family front captures and detailed source artwork
were compared, with Gold/Silver native comparisons and changed-model views.
Some rear views naturally show the enclosing wall; detailed machine orbit views
supply the closer casing evidence. These are rendered captures, not live keyboard
or warp-transition gameplay verification. Final PC keyboard wedge closure was
additionally checked in geometry tests; it does not move its source front/top.

Launch pattern (from the parent workspace):

```sh
bash .scratch/runtime-0.3.85/run.sh crystal \
  /home/admin/Projects/.scratch/gen2-clinics-20261013/roof-final.lua \
  /home/admin/Projects/.scratch/gen2-clinics-20261013/crystal-roof-final \
  /home/admin/Projects/.scratch/gen2-clinics-20261013/profiles crystal-clinics-qa
```

Positive-area generated fixture footprints were checked against native
`isWalkable` cells, including new booths, door approaches and the rooftop curb.
Thin doorway faces remain at native cell boundaries. Full tile/collision grids
were compared; no production collision, warps, event scripts or floor palettes
were changed. Floor donors remain native Center/Mart/roof tiles. The roof's final
outdoor rig follows the mod clock (night in the inspected render), even though
the native HUD says DAY. The shell wrapper can exit nonzero after the explicit
successful driver completion; logs distinguish that from the real intermediate
roof assertion failure above. Test processes ended.

## Checks

- `gen2_clinic_furniture_test.lua`: source bounds, independent Center/lab/bedroom
  recipes, closed volumes, continuous panels, tray support, wall recesses,
  irregular lobby aisle preservation, open roof and clear booth approaches.
- `gen2_bin_bed_test.lua`, `gen2_register_test.lua`,
  `gen2_department_windows_test.lua`, `gen2_directory_test.lua`,
  `gen2_interior_ceiling_camera_test.lua`, `interior_diorama_test.lua`: pass.
- `designed_interiors_test.lua`: 403 complete designed objects pass.
- Engine-integrated `gen2_tile_shape_test.lua`: 114/114; `gen2_support_test.lua`:
  202/202. Run from engine root with `DS_MOD_PATH=mods/BATTLE_ART_VOXEL_FORK`.
- Native LuaJIT loadfile compilation of changed Lua files and `git diff --check`.
  The Python compile helper was unavailable because system Python lacks Lupa;
  native LuaJIT compilation was used instead.
