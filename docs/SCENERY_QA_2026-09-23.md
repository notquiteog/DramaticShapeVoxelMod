# Scenery release evidence — 2026-09-23

Scope: native FireRed/LeafGreen Pokémon Center furniture and escalators, Crystal kitchen/workstation, Pewter Museum displays and counter, Gen 2/3 roof eave corner closures. Presentation only: original layout, collision, warps and NPC positions remain authoritative.

## Runtime and fixtures

Official Gen1Recomp **0.3.2**, released September 23; Linux AppImage and .love SHA-256 checked against release checksums. Scratch root `/tmp/scenery-polish-20260923`. Engine under `qa/engine`, copied/imported caches under `qa/profiles`; no player save or normal installation changed. FireRed re-imported from the user's `~/Apps/Gen1Recomp/ROMS` using the public `POKEPORT_IMPORT_ROM` import path. No ROM/cache/image committed.

`qa/run.sh GAME CASE` uses the packaged runtime with a disposable identity, developer frame driver, no sync, software GPU, null audio and reset physical input. Wrapper asserts engine version, mod version and isolated persistence. All six companion mods remain enabled. These are scripted Linux engine checks, not physical-controller or manual playthrough evidence.

Drivers: `centers.lua` enumerates complete escalator patterns in all 38 Center maps per native edition, captures both floors/museum/Pallet/Viridian, and checks source metatile/collision integrity. `reception.lua` captures static, rotating, first-person and reverse views on both floors with original staff positions. Nurse64 stands at (7,2); receptionist65 stands at (2,2), (6,2), (10,2). Counters are 7px high and begin beyond the full rotating 16px staff card footprint. The shared full-scene array includes 31 Center furniture recipes; collection matching gives whole drawings priority.

`escalator.lua` enters the actual native upward and downward warps via Player.tryMove, waits for normal arrival and checks camera ownership during travel. Special tile movement briefly stops between phases: the public Warp.isEscalatorActive flag keeps the scene renderer active through those gaps. Other unsupported effects still use the native renderer. Descending flights cut openings through the decorative room base.

`heal.lua` gives six fixture Pokémon through native Party.giveMon, runs the complete public healing effect, captures all six placed balls and checks camera continuity. `rooms.lua` captures five Crystal locations and four Yellow locations, asserts new Crystal furniture recognition and runs 36 GPU upright-canopy cases. Teleports are fixture setup; no new-game/save/story progression claim is made.

## Inspected visuals

Under `qa/results`: native Center static/orbit/first-person/reverse captures; downward escalator from first person; six-ball healing tray; museum L-counter and blue-glass fossil displays; Pallet/Viridian roofs; Crystal house kitchen/workstation and New Bark/Olivine roofs; Yellow shared room framing. An earlier fixture entered One Island with unmet Bill story flags and leaked dialogue into the next capture; that capture was discarded and the final museum run starts without that story fixture.

Wild Skies indoor defect reproduced in Center2F: native mapType8 but facade kind town/environment TOWN. Numeric indoor type now wins; no outdoor birds appear in the corrected Center captures. Unit regression additionally covers stale neighboring-map fields.

## Automated checks and limits

Targeted geometry, source UV, complete-pattern, pair isolation, room opening, native stairs, roof, lab, sprite anchor and escalator-camera regressions pass. Wild Skies native contract suite passes 59 assertions. Production Lua files compile with LuaJIT; git diff whitespace checks pass.

Two older broad test harnesses remain incompatible with the already-existing checkout: `battle_art_voxel_fork_test.lua` exceeds LuaJIT's 200-local limit, and `gen3_adapter_test.lua` expects the removed whole-room fallback and lacks current integration module stubs. They are not claimed passing. Focused replacement coverage verifies native scene support and map-type isolation; no production behavior was weakened to satisfy stale tests.

This release does not finish all maps/tiles, every furniture family or every building side texture. Museum machine art, additional special interiors, full roof/art audits and general cross-generation parity remain ongoing. No new online battle/trade, mobile or physical-controller verification is claimed.
