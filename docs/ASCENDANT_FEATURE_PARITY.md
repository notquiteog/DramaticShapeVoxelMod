# Ascendant integration and cross-generation work

Scope confirmed by the user: rendering, camera, atmosphere and quality of life; not Kanto Ascendant's quests/species/post-game campaign. Reference: Voxel Ascendant 2.0.2, commit `22c2bb5502290d4396aa3ab11d075ee2fb70e341`. Its MIT weather module is adapted with credit; other references are an implementation comparison, not a claim that code was copied.

| Feature family | Current fork | Remaining |
| --- | --- | --- |
| Voxel/card art, roofs, props and cutaway interiors | Source-colored 3D models, native art, explicit model/card options; Gen1 authored scenery retained | Every-map Gen2/3 visual review and missing specialty models |
| First/orbit/static cameras and input | All three native paths; shared menus and saved choices | Physical-controller and broad cutscene/transition matrix |
| AA, tilt shift, water, curved horizon, shadows | Existing shared/native consumers; optional FSR 1 | Shadow artifacts and device/performance tuning; no DLSS/frame generation |
| Weather | Adapted CLEAR/AUTO/RAIN/SNOW/FOG/STORM, outdoor-only, all three engines | Battle-specific visual QA, platform orientation QA |
| Daytime, sky and biome atmosphere | Shared lighting, native forest/cave/tower controls | VASC's world-bearing celestial/event system, native moving ground mist |
| Connected-map scenery and void fill | Native biome donors, stable placements, render-distance controls | Complete edge/corner/art review |
| Preload and caching | GB budgeted generation/disk/RAM cache; native Gen3 scene dependency cache | Equivalent native RAM preload control |
| 3D battle staging and minimal status cards | Shared world stages and world-space actors across Gen1/2/3; optional modern projected HUD | Full battle transition/animation parity and wider visual QA |
| User sprite and music providers | Battle Art collections; optional Ride/Skies/Wilds providers | VASC general loose-file replacement menu and complete KASC quality-of-life menu audit |

## Five independent core mods

- **Battle Art:** `option-support.json` distinguishes implemented/partial/missing consumers. Read-only diagnostics do not count as working settings. Native all-map quality and original Gen1 feature parity remain incomplete.
- **Wilds:** shared schema and host-owned visible rosters; direct selected-ball throws, hidden HUD, aliases, quick desktop taps and modifier cancellation. Native ball artwork and optional shortcut-ownership export added. Native long-form follower interactions/PMD timings still differ; see Wilds' `GENERATION_SETTINGS_PARITY.md`.
- **Ride:** optional public Wilds key ownership resolves bound G conflicts. Mount/flight/music/online pose adapters remain independent. Native Stadium mounts and external Gen3 registered music remain gaps documented in Ride's `GENERATION_OPTION_SUPPORT.md`.
- **Online:** existing chat, bubbles, remote actors, trades, battle and host encounter contracts. No new two-client gameplay validation in this batch; Gen1 online doubles still require native two-client validation and advanced move/disconnect coverage.
- **Doubles:** existing native adapters and optional Online provider. No new mechanics changes in this batch; complete special-move, replacement, cancellation and native link validation remains open.

This inventory is a work list, not a full-parity certification. No new hard companion dependency is introduced.


## Upstream refresh, 2026-10-04

Kanto Ascendant `40582034` is current with its origin/main at this audit. Its
README delegates scenery to separate renderers; it does not bundle all the
Voxel Ascendant assets. No unlicensed Kanto assets were copied. Existing weather,
render-distance, map-boundary fill and atmosphere adaptations remain. Live views
through interior windows and remaining special terrain families are still gaps.
The new optional Modern Pokemon UI owns opt-in HUD styling; scenery and gameplay
mods retain native UI without it. This audit does not mean all referenced features
have been imported.

## 2026-10-05 update

Modern UI is independently packaged with Battle Art's optional live theme
consumer. Native Legendary master/profile controls now work in Gen3 for
implemented consumers. This does not implement the remaining window portals,
world-bearing celestial events, Gen3 RAM preload, specialty models or general
loose-file replacement menu listed above. Native-UI audit findings are in
NATIVE_UI_AUDIT_2026-10-05.md.
