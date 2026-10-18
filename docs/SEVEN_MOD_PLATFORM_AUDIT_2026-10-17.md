# Seven-mod platform/source audit — 2026-10-17

Scope: voxel, Modern UI, Gen1Online+, Dramatic Sky Ride, Overworld Wild Spawns,
Wild Skies and Double Battles. Current official engine0.3.89. This audit covers
source/API contracts and focused mocked tests, not execution on every platform.

All seven manifests use API2, declare gen1/gen2/gen3 and resolve to all eleven
editions through the actual engine `Manifest.validate` and `ModTargets` implementations. Each declared
entry exists.650 production Lua files plus Sky Ride's concatenated source
compile in LuaJIT. Sky Ride fragments are intentionally not standalone chunks.
No unconditional FFI, OS process, desktop path or blocked system namespace was
found in the audited runtime trees. Standalone online server tooling is outside
the in-engine mod scope.

| Mod | Focused source/runtime-contract evidence |
| --- | --- |
| Voxel | Native art92, HUD14/28, PC9 and indexed hatch32 checks; native options/overflow/live consumers and sandbox-safe platform metadata pass. New selected-picture/trainer canvas failure fallback passes dedicated resource tests and24 identity checks. |
| Modern UI | Native command mapping across generations, OFF/unload ownership and argument/overflow tests pass. Native input remains authoritative. |
| Gen1Online+ | Host-address unavailable/timeout cleanup, LAN discovery lifecycle and room UI ownership tests pass. ENet, socket/broadcast, TLS and background-thread availability remain engine/platform requirements; unavailable optional discovery uses explicit fallback, not a cross-device network certification. |
| Dramatic Sky Ride | Native option arguments, native HUD delegation/scroll ownership and public follower-provider fallback pass. |
| Overworld Wild Spawns | Actual sandbox defect found in native image loading: blocked filesystem namespace silently discarded requested HGSS/PMD/swimmer pictures. Replaced with the engine's public asset API; strengthened settings fixture blocks filesystem access and confirms public image loads.56 settings checks plus sandbox, manifest, game compatibility, catch input and hidden-presentation checks pass. |
| Wild Skies | Native option arguments/overflow and74 native Gen3 behavior assertions pass. |
| Double Battles | Native option arguments/overflow and native Gen3/Gen2 target, cancel, partner, remembered foe, singles/link and spread-input ownership tests pass. |

Native Linux NVIDIA/LÖVE FireRed verification loads all seven source mods
successfully in an isolated engine/profile. Wilds HGSS32px×9 and swimmer16px×9
selected sheets pass assertions; overview/native2D/first-person and both sheets
were inspected. Hidden grass remains transparent and native walking advances.
Wilds scoped fix is70d2cfd7; detailed evidence lives in its
`docs/NATIVE_ASSET_API_2026-10-17.md`. This one Linux edition is not all-platform
execution evidence.

Source limits: touch camera controls and GLES renderer compilation are separately
owned work. The Android report is specifically that voxel loads but stays2D;
this audit does not prove its cause. Android/iOS/Windows execution, touch/editor
focus, controller devices, audio playback and cross-device networking require
actual runtime checks. Optional model/art/music files remain separate resources.
Manifest acceptance and native fallback are not full feature parity.

Shared voxel regression run:328 suites passed, one camera adapter test failed
on a missing headless graphics dependency,58 external-fixture skips. Camera
owner added the guard, then restored native menu stick forwarding exposed by
the same test; targeted `gen3_adapter_test.lua` now passes. Combined coverage
is329 passing suites,0 unresolved failures,58 skips; a second full run was not
performed after those targeted camera fixes.

Evidence: session scratch `platform-audit/parse.log`, Wilds sandbox/compat/input
logs, focused commands in task history and each mod's existing tests. Companion
source changes are scoped in their own repository; no versions/releases changed.
