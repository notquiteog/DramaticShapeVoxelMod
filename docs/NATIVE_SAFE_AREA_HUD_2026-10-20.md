# Modern battle HUD safe areas — 2026-10-20

Optional modern battle cards and command panels now use the original public
`src.core.SafeArea.rect()` viewport. Battle Art covers all three generations;
Modern UI covers its standalone native commands; Doubles covers its optional
GSC modern HUD. Projected actor anchors are converted into the same inset
coordinate space. Native fixed-layout UI, native inputs and gameplay remain
unchanged. Missing, invalid or failing safe-area readers retain the full window;
older independent providers remain supported. No desktop-only APIs are used.

## Verification

Latest official release checked before the batch: v0.3.91. The unmodified
0.3.91 engine archive was run with the established LÖVE 11.5 NVIDIA desktop
shell and isolated seven-mod profiles. Old QA harness helpers are test support,
not engine source overlays. Fixture options: camera35, distance16, shadowsOFF.

All eleven editions plus a separate Crystal paired battle pass actual card and
button draw-bound assertions at640×360 and360×640. Public safe rectangles were
simulated as(30,12,580,320) and(14,36,332,576). All24captures were inspected.
Yellow, Crystal and Emerald additionally pass both sizes with staging disabled;
six final native-command captures were inspected. The first Yellow OFF trial
switched staging after encounter initialization and is excluded; its final
rerun disables staging before starting the encounter.

Shared voxel suite:350 passed,0 failed,58 external-fixture skips. All15 Modern UI
suites and all6 Doubles Gen2 suites pass. Tests include invalid/throwing safe-area
readers, rotation, exact actor-anchor offsets and original fallback behavior.

Scratch evidence: `voxel-parity-20261020/safe-hud-0391`, including all eleven
edition directories, `crystal-pair`, `yellow-unstaged-final`, `crystal-unstaged`
and `emerald-unstaged`; drivers `native-gb-safe-hud.lua`,
`native-gen3-safe-hud.lua`, `native-gen2-pair-safe-hud.lua` and their staging-OFF
variants. Shared regression log: `safe-hud-suite.log` in the same scratch root.

## Limits

This verifies desktop rendering with simulated public safe-area insets, not
physical Android/iOS device behavior, memory pressure or touch certification.
GBA modern paired world actors can still clip horizontally in portrait; that
separate camera issue was handed to the camera owner. HUD rectangles fit the
safe area. Native tiny fractional text and optional artwork/provider limits
remain documented in PARITY_AUDIT_2026-10-20.md. Full parity is not claimed.
