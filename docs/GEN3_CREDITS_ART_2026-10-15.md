# Native Hoenn credits interface art — 2026-10-15

Ruby, Sapphire and Emerald credit slides now use the shared selected-interface
picture scope. Their original renderer resolves `dexFrontPic` during each draw
and sizes/centers from the returned image dimensions, so it retains native
slide transforms, animation, fading, backgrounds and edition-specific text.
The scope now preserves explicit `frontPic` shiny/personality arguments when
there is no supplied mon; previously those arguments were discarded. Supplied
mon fields override only when present. OFF/MODDED, unavailable artwork and
special forms continue through the original reader, and unload restores draw.

This source batch follows release checkpoint4bc557a. No release metadata or
archive changed; it is not claimed included in the existing1.41.1 package.

## Verification

Official **v0.3.89** and its native Linux shell; latest official release API
rechecked before runtime verification. Production engine source unchanged;
public QA support originates from0.3.88. Driver:
`tools/qa/native-gen3-credits-art.lua`; scratch runner `run-credits-art-0389.sh GAME`.
Isolated Ruby/Sapphire/Emerald profiles, fresh Littleroot fixture, Crystal art,
480x320 native UI, no companions. The fixture marks Pikachu caught in its fresh
Dex, then starts the original credits and lets the original tasks advance.

All three reach a visible native slide after1119 driver wait frames. FIT/FULL/
OFF are changed live, the original slide timer advances, scale reaches256 and
the native blend phase follows. Original finish calls the callback exactly once;
reopening/resetting clears state without calling completion. Party/Dex object
ownership and the original picture reader are unchanged. The fixture does not
play an entire ending or save completion progression.

All12 final captures inspected: `credits-fit`, `credits-full`, `credits-native`
and `credits-fade` for each edition. Original backgrounds, text and independent
slide fades remain visible. Native Dex default PID0/nonshiny identity is checked
in actual draws; true/false explicit shiny and arbitrary PID propagation are
covered by the mocked reader test, not claimed as actual shiny credit footage.
Evidence: `.scratch/voxel-parity-20261015/credits-art-0389/{ruby,sapphire,emerald}`.
No player saves written. Focused interface77/inventory549 checks pass. Shared
broad suite306 passed,0 failed,58 external prerequisite skips, SDK1173 included;
log `suite-credits-final.log` in the scratch parent.

## Remaining renderer contracts

FireRed/LeafGreen credits use a native full picture only at reveal stage0, then
private cropped-frame data (`credits.lua`, `draw_mon_scene`, `mon.frames`) at
later stages. Merely wrapping its picture reader would mix selected and native
art mid-reveal. Hoenn starter selection draws a private fixed64x64 quad with
origin32, which can crop FULL artwork larger than64. Ruby/Sapphire hatch uses
indexed PPU art. These remain native until their complete contracts can be
preserved; Pokemon Jump's per-player image cache and Dodrio's custom pose sheets
also need separate treatment. Interface inventory remains partial, and this
batch makes no full parity or model-family coverage claim.
