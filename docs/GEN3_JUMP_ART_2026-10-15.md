# Native Pokemon Jump participant art — 2026-10-15

`NativeJumpArt` gives the original Pokemon Jump renderer a temporary selected
picture cache for its actual participants. Entries use the native species/PID/
shiny cache key and selected frame dimensions. The original renderer retains
centering, sprite priority, visibility, vertical movement, vines and UI. Each
draw restores the original cache on success or error; selected frames never
persist in simulation state. OFF/MODDED/missing art use the original cache.
Egg, alternate Unown, Spinda and Deoxys pictures remain native. Independent
players of the same species retain their individual PID/shiny context.

This is a source follow-up after release4bc557a, not part of the existing1.41.1
archive. No release metadata, model assets, protocol or game rules changed.

## Verification

Latest official release API rechecked: **v0.3.89**, matching native Linux shell.
Engine production code unchanged; public QA harness support from0.3.88.
`tools/qa/native-gen3-jump-art.lua`, scratch runner `run-jump-art-0389.sh GAME`,
uses isolated FireRed/LeafGreen/Emerald imports, fresh Pallet/Littleroot fixture,
480x320 native UI, Crystal selected art, no companions. These editions contain
the native minigame assets; Ruby/Sapphire do not add this minigame through the mod.

The fixture creates the original two-player simulation and draws it through the
original renderer on a temporary native UI stack layer. It supplies synthetic
player identities and advances original Gfx updates, without network peers,
matchmaking, score progression or saving. Native pictures first populate their
cache. FIT/FULL/OFF then switch live; both normal Pikachu and shiny Cyndaquil
remain distinct. The original intro bounce reaches16 vertical positions and
completes. A changed second-player PID/shiny value is reflected immediately.
Original cache objects/entries, player/identity tables, zero scores and picture
readers remain unchanged. The temporary UI layer is removed afterward.

All three runtime fixtures pass. All15 final captures inspected: `jump-fit`,
`jump-full`, `jump-native`, `jump-bounce`, `jump-changed-player` per edition.
Original Venusaur pose sheets, vines, score text and backgrounds remain native;
selected images follow the original participant movement. Evidence:
`.scratch/voxel-parity-20261015/jump-art-0389/{firered,leafgreen,emerald}`.
Focused cached-picture15/interface77/inventory549 checks pass. Broad suite307
passed,0 failed,58 external prerequisite skips, including SDK1173;
`suite-jump-final.log` in the scratch parent. No full linked match is claimed.

## Remaining interface contracts

RS indexed hatch, Hoenn starter selection's fixed64 quad and native clipping,
and FRLG credit reveal pictures remain native. The latter exposes its current
mon through public `Credits.state()`, but stages1/2 use separately authored ROM
pose images extracted from dedicated assets, not a simple crop of frontPic;
replacing only stage0 would mix art sources. Dodrio likewise uses dedicated
head/neck pose sheets that convey gameplay actions. No selected equivalents
are supplied for these poses. These concrete art/renderer constraints remain
explicit; option registration and these component tests do not establish full
non-model parity or regional-model coverage.
