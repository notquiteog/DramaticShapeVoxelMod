# Native presentation implementation checkpoint — 1.23.0-test.9

This is a source-design checkpoint for the pending test release. No gameplay or new rendered engine captures were run. Full Gen1 option parity is still incomplete. The live export `optionSupport` and [machine-readable snapshot](option-support.json) list every one of the 89 declared controls, its consumer, and its remaining limitation. Exposing a row does not count as implementing it; absent consumers remain visible on the native support page.

| Generation | Implemented consumers | Partial | Missing | Provider required | Other engine |
|---|---:|---:|---:|---:|---:|
| Gen1 | 83 | 0 | 0 | 1 | 5 |
| Gen2 | 38 | 34 | 13 | 2 | 2 |
| Gen3 | 31 | 4 | 53 | 1 | 0 |

These counts describe audited source paths, not visual/gameplay certification. The Gen1 column starts from the established Gen1 source catalog and is not a fresh exhaustive gameplay audit.

## Concrete consumers added

- Native Game3 options persist through its `game.options` / `persistOptions` contract. Native scenery uses shared AA, day clock/tint/sky, world fill, tilt shift, invert Y, and water FULL/SKY/OFF passes. `gen3Camera` exposes native yaw/pitch and movement vectors for optional Ride integration; native Ride altitude and ground particles render through its public exports.
- Gen2 status/command drawing consumes visibility, textbox fill and HUD ink. The shared modern HUD consumes scale; original native HUD sizing remains engine-owned. `backPlacement=ui` relinquishes the player stage slot and selected front flipping is respected.
- Native selected battle images retain the exact four-slot mon identity, including same-species shiny variants. Gen3 Summary receives the mon's PID/OT identity. Summary/Dex selected images use animation-union FIT/FULL sizing. Gen2 Summary/Dex uses its native 56px block and keeps eggs, Unown forms, unseen entries and Crystal's menu ownership.
- Selected Gen2 trainer portraits follow its real slide. Gen3 uses the native trainer-picture readers and builds the original five 64px player send-out frames; the engine still chooses the animation frame and timing. Missing optional artwork and scripted trainer roles keep their native picture.
- Gen3 WHITE/GEN6/PNG arenas, crop offset and boss choice consume the existing optional art collections through native map/trainer/species identity. Missing art retains the ordinary world. BLUE still needs a compatible Stadium provider. Sprite light multiplies native sprite flash/fade by day tint; native UI-plane actors do not yet cast world shadows. Native world back placement remains missing.
- Root's contemporaneous Gen3 HUD work supplies native visibility/text panels and modern card palette/scale. Original native HUD palette/size stays engine-owned.

## Reviewed interior additions

Fifteen exact whole-object recipes match 137 objects across the native museum, Silph, Power Plant and Mansion layouts. Cabinets/servers/terminals use complete matched drawings with their source floor/wall margins excluded from the facade; plants use native cutouts. A recipe cannot claim a partial object or cross tileset pairs. Additional wall profiles explicitly exempt reviewed floors, including museum primary metatiles 0x109 and 0x111.

The complete fixture list, native source diagrams and read-only atlas decoder are under `/tmp/parity-20260922/furniture/`. Examples (inclusive native cell bounds):

| Object | Map | First cell | Last cell |
|---|---|---|---|
| Museum bookcase | FR_PEWTER_CITY_MUSEUM_1F | 17,0 | 18,2 |
| Silph server | FR_SILPH_CO_2F | 11,15 | 11,17 |
| Power Plant server | FR_POWER_PLANT | 29,14 | 29,16 |
| Mansion terminal | FR_POKEMON_MANSION_B1F | 3,2 | 3,3 |

## Reported lab overlap

Inspected user screenshot `Screenshot_2026-09-22_18-29-25.png` and the native Oak layout/art. The table drawing covers rows 4 and 5, but only x8..10/y4 is blocked; y5 is a walkable script approach. The previous model extended through world z94, overlapping the leaned player/rival billboards in row5. The table now ends at z79, crops only the source tabletop, and places supported starter-ball feet three pixels back inside it. Only that table's footprint changes; actor lean, collision and script positioning are unchanged.

`tests/gen3_lab_driver.lua` now requires official0.3.1 and an isolated QA identity, and creates a disposable exact approach fixture: player(8,5), rival(10,5), both facing up. It captures15/35/50/70-degree static angles and four rotating views, plus the existing machine/room views and native fallback. **Prepared, not run. The screenshot defect is code-fixed but not visually verified.**

## Validation

System LuaJIT bytecode compilation passed for222 production Lua files. Focused mocked checks passed: native options385, native interface20, native battle identity22, native backdrop/trainer/tint31, Gen2 interface8, Gen2 battle options15, added furniture15, lab source geometry, staged pair ownership, first-person inversion/dialogue lock, external interface atlas25 and underlay5. Official0.3.1 SDK load fixture passes181/181 across Gold/Silver/Crystal/Red. `git diff --check` passes.

Run focused tests from the mod checkout with `luajit tests/<name>.lua`. The SDK fixture must run from `/tmp/release-031-20260922/engine` with `DS_MOD_PATH=../../../home/admin/Projects/DramaticShapeVoxelMod luajit /home/admin/Projects/DramaticShapeVoxelMod/tests/gen2_support_test.lua`.

Remaining families include native capture/Legendary effects, many generation-specific environment options, native world actor back placement/shadows, Stadium model contracts, and interface screens beyond the reviewed Summary/Dex seams. No commits, version bumps or publication were performed by this subtask. Exact packaged visual/gameplay verification follows release as requested.
