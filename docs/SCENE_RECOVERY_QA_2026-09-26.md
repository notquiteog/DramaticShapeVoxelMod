# Scene recovery and native voxel scenery — 2026-09-26

## Scope and causes

Crystal's Double Battles HUD owns singles as well as doubles. Battle Art previously checked only `battle.doubles`; both renderers therefore painted complete HUDs during singles. `Gen2BattleUI` now checks the companion's public `usesModernDoublesHud()` seam. The companion remains optional; disabling its HUD returns ownership to Battle Art. Gen 3 already has a separate public `nativeHudOwned()` handshake; this Crystal-specific change does not replace it.

Gen 3 field and battle adapters used session-long failure booleans. One exception permanently disabled the corresponding presentation. The new recovery gate retries after one and two seconds, quarantines a persistent fault only for that scene, and resets on scene change/manual camera selection. This prevents permanent lockout but does not identify the user's original Pallet exception, which was not reproduced in clean 0.3.20 profiles.

Constant wall UVs on exact pixel boundaries alternated between neighboring palette colors because interpolated floats rounded to either side. Shadow-OFF isolation showed the same defect. Pixel-center sampling removes it; sloping siding tips also stay above their course base.

Native trees now have closed voxel volumes derived from original silhouettes and colors. Greedy face merging removes interior faces and joins equal-color coplanar faces. Templates are cached by source artwork/detail; terrain and boundary trees share the selected presentation. Existing original/illustrated cards remain selectable; modeled art defaults only when no saved art choice exists. Full, Balanced and Handheld use one-, two- and four-pixel sampling. Native cave rock masks retain only the main connected rock, with no rectangular support plate. Gen 1 retains its existing tree/rock models.

Kanto Ascendant's repository identifies separate renderers; the supplied video is titled “Pokémon Voxel Ascendant Just Got Another Huge Update! 3.0.44.” YouTube playback required sign-in, so the video was not watched. Voxel Ascendant's MIT source at `22c2bb5502290d4396aa3ab11d075ee2fb70e341` was inspected as a reference; no assets or runtime code were imported. The new hull implementation is local, using the original games' already-imported art.

## Environment and fixtures

Official Gen1Recomp **0.3.20**, Linux bundled LÖVE runtime, RTX 5060 Ti. Release checksum validated before extraction. FireRed and LeafGreen ROMs freshly imported from the user's own ROM folder. Crystal/Yellow caches copied into isolated identities; user saves/options untouched. Six companion mods enabled: Battle Art, Online0.8.0, Wilds2.4.1, Ride0.4.0, Doubles0.12.0, Wild Skies1.13.1.

Persistent workspace: `/home/admin/Projects/.scratch/ascendant-20260926`; drivers and rendered evidence are outside Git. The engine's POKEPORT_DRIVER loop bypasses the normal PlatformHooks/core.update path; clock/recovery fixtures explicitly dispatch that public hook. Production gameplay already dispatches it and needs no engine patch.

- `camera-recovery.lua`: FireRed and LeafGreen, ordinary southward Route1→Pallet map connection at (12,39), one injected Pallet draw failure followed by successful automatic recovery; three persistent failures bounded to Pallet; Viridian (22,19) renders; Pallet (10,8) renders on return; first, rotating third and static camera selection remain active. Both passed. The recovered Pallet capture was inspected. The exception is a controlled fixture, not the unidentified user-save trigger.
- `crystal-battle.lua`: Crystal Route29 (12,6), Cyndaquil18 versus Sentret20; all companion mods enabled. Reached command phase and inspected the rendered capture: one card per mon and one command hub.
- `scenery-options.lua`: LeafGreen Pallet (10,8), rotating camera yaw0.8/pitch0.25. All three native model detail selections and return to original cards rendered. Balanced and original-card captures inspected. Previous Pallet/forest and Oak's Lab scene captures also rendered; only Pallet/forest were visually inspected.
- `cave-rock.lua`: LeafGreen Rock Tunnel1F boulder (7,1), view (7,3), rotating camera yaw0.6/pitch0.20. Native darkness mask disabled only in the fixture (`flashLevel=0`) because that effect intentionally uses the engine's 2D fallback. Inspected grounded large/small voxel rocks without support squares. This does not verify dark-cave 3D rendering.
- `side-probe.lua` / `side-fixed.lua`: Pallet (10,8), same yaw/pitch, shadows ON/OFF. Initial noise persisted without shadows; corrected shaded siding capture inspected.

Focused Lua regressions pass: recovery, voxel hull closure/grounding, original tree art, Crystal HUD ownership (17 checks), native options (389 checks), native menu defaults, shared 3D-BTL legacy migration, scene caching, outdoor/fence/ledge scope, roofs, civic geometry, escalator camera continuity and cave profiles. Updated obsolete cave assertions to expect the existing semantic ladder and safe unknown-art fallback. All 261 production main/lib/data Lua files compile with LuaJIT bytecode generation. The Python compile helper could not run because its optional Lupa dependency is absent; direct LuaJIT compilation was used instead.

## Limits

No all-tile/all-angle or multiplayer regression certification. Gen 3 still renders native battle actors on its UI plane over the 3D field, rather than full Gen 1 world-space camera parity. Many Gen 1 settings still lack complete Gen 2/3 consumers; unsupported rows remain explicitly read-only. Gen 2 rock modeling, dark caves, specialty effects and untouched furniture/roof families still need work. No general FPS improvement is claimed for the new geometry. Physical controller input and the user's exact problematic save were not tested this batch.
