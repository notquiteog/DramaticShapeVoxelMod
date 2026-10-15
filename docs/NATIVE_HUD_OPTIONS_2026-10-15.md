# Native original HUD options — 2026-10-15

Original G/S/C HUDs now consume HUD SCALE together with their backplates.
Original FR/LG/Ru/Sa/E healthboxes consume HUD SCALE and HUD COLOR. Native data,
input, HP/EXP updates, clipping, visibility, slot centers and animation remain
engine-owned. These controls retain the existing optional Modern UI provider
gate; standalone behavior and setting defaults are unchanged.

## Implementation

`NativeHudLayer` captures the original drawing at its native logical resolution.
Compact layers are composed after the native frame at window resolution, one
integer pixel rung below the window-fit size. This preserves every source glyph
pixel. OG keeps native size. The native drawing executes once, and graphics
state/return values survive capture. Allocation/shader failures retain native
fallback; reusable canvases/shader release through the existing Assets owner.

`NativeGen3Hud` uses public Healthbox.draw/center and the Hoenn battle-chrome
manifest palette. FRLG's manifest omits that palette, so its adapter uses the
three fixed text/paper/shadow colors declared by the native healthbox drawing
implementation. Inverted mode maps only those colors, preserving HP, status
and gender colors. Native level-up palette flashes retain their own colors;
WHITE arena retains dark ink. Unknown/missing palette data stays native.

Gen2 native status drawing and its separately drawn backplates receive identical
left/right/top transforms. Companion-owned doubles retain their renderer and
scale. The public `nativeHudOwned` signal now includes Battle Art's original
HUD consumer, so the independent Modern UI companion does not repaint a second
unscaled backing or command layer behind it. The companion package is unchanged.

## Evidence

Official engine **0.3.89** and matching Linux native shell, latest release
rechecked by the parent for this batch. A separate hardlinked copy of the same
engine was used to add the actual optional **Modern UI 0.4.1** companion without
changing the parent's runtime mod directory. Production engine code is
unmodified. Public QA support files are from 0.3.88 because 0.3.89 omits tests.
Concurrent model/performance changes remain separately owned; this batch does
not change models, versions, releases or pushes.

- 14 layer contracts, 28 Gen3 consumer contracts and 24 Gen2 battle-option
  checks pass. These cover integer scaling, delayed window composition,
  original return/data identity, palette and flash ownership, native doubles
  centers, companion fallback, resource failure and graphics-state restoration.
- Native battle-options checks and SDK **1173/1173** pass.
- Final broad source suite: **295 passed, 0 failed, 58 skipped** (external
  dataset/fixture prerequisites). The final inventory-only edits also pass
  the 549 consumer checks and generated-inventory consistency check.
- Actual native runtime fixtures pass in **Gold, Silver, Crystal, FireRed,
  LeafGreen, Ruby, Sapphire and Emerald**. Inspected images show sharp compact
  text, native-size text, dark original HUDs, preserved HP/gender colors,
  unchanged modern presentation and provider-off native fallback. GSC command
  navigation also passes. GBA WHITE-arena ink is checked.

Drivers: `tools/qa/native-gen2-hud.lua`, `tools/qa/native-gen3-hud.lua`.
Scratch evidence (workspace root, outside this repository):
`.scratch/voxel-parity-20261015/hud-0389/{gold,silver,crystal,firered,leafgreen,ruby,sapphire}`.
Each has `run.log`, `original-color.png`, `compact-color.png`,
`compact-inverted.png`, `original-inverted.png`, `provider-off-native.png`,
`modern.png`; GBA additionally has `white-arena-native-ink.png`.
Runners: `run-gen2-hud-0389.sh`, `run-hud-0389.sh` in the same scratch parent.
Source-suite log: `suite-hud.log`.

Fixtures use isolated imported profiles and synthetic parties, with no player
save writes. GSC Route29 cell10,6 down at480x432; GBA Pallet/Littleroot cell7,8
down at480x320; staged battles, LOW distance and shadows OFF. GBA native battle
updates are held after the command phase while rendering choices are compared;
GSC navigation runs normally. All processes close. The GSC debug field label
and bright field palette are inherited setup behavior, not evidence of world
art/color parity. These are HUD checks, not complete battle playthroughs,
network/doubles companion tests, Android checks or performance benchmarks.

Initial compact captures lost text pixels because they were shrunk inside the
native UI canvas. That implementation was rejected and replaced with window
composition before the final eight-game checks. Earlier failed screenshots
are not used as final evidence.

## Remaining limits

HUD SCALE now has native and modern consumers. Independent Gen2 doubles
providers retain their own layout/scale. HUD COLOR remains explicitly partial:
the modern semantic-card provider's public `combatCard(...)` API hardcodes its
own palette and has no palette override. This is shared across all generations,
not a newly discovered native-generation divergence; the companion remains
independent. The inventory records this precise provider contract limitation.

Other unfinished non-model work includes specialty/tutorial/Safari/doubles
capture presentation, broader send-out/recall effects and optional audio;
regional backdrop/boss routing/artwork; native Gen2 indexed Oak palette-rotation
art and the different native title cinematics. The general native terrain/tree
cache remains distinct from authored-geometry persistence. Model-family
coverage is owned by the separate worker. Full feature parity is not claimed.
