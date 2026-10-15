# Native Emerald Battle Factory interface art — 2026-10-15

The Factory rental and swap screens read `Common.monPic` during their draws.
They now join `NativeInterfaceArt`'s scoped picture readers, preserving each
actual mon's PID/OT/shiny identity. FIT/FULL and OFF/MODDED use the same contract
as the other native interfaces. The original ball/window transitions, menu
input, three-rental confirmation, swap decisions and callbacks stay native.
No game rules, models or independent provider assets are changed.

This is a separate source batch after release checkpoint4bc557a (voxel1.41.1).
It changes no release metadata and is not claimed included in that archive.
The earlier audit listed Factory among cached-picture follow-ups; detailed
source inspection found that these two screens resolve pictures during draw.

## Verification

Official **v0.3.89**, matching native Linux shell; official release API rechecked
before the batch. Engine production source unchanged; public QA support from
0.3.88. `tools/qa/native-gen3-factory-art.lua`, isolated Emerald import/profile,
fresh Littleroot fixture cell7,8 down, 480x320, Crystal selected art, no companions.

A synthetic six-mon rental pool runs the original native UI: open a rental,
switch FIT/FULL/OFF live, choose three mons, inspect the three-picture confirmation
and accept. Exactly one callback reports choices1,2,3. Original swap UI then
shows player FIT/FULL/OFF pictures, switches to the enemy pool, shows its shiny
picture and accepts the swap; another opening cancels it. Exactly one result
per opening reports the expected selected IDs/swapped flag. Original party
ownership and readers remain unchanged. Callbacks are observed rather than
connected to a real Factory tournament or session party exchange; this is not
a complete Frontier progression verification.

All eight final captures were inspected: rental FIT/FULL/native/three and swap
FIT/FULL/native/enemy-shiny. The three-picture confirmation shows independent
Pikachu, shiny Cyndaquil and Bulbasaur frames; the enemy confirmation uses shiny
Charmander. Original chrome and text remain. Initial QA attempts sent input
before the native close animation completed or with adjacent button edges;
the final driver waits for native animation completion and separates taps.
No production timing or input code was changed to make the fixture pass.

Evidence: `.scratch/voxel-parity-20261015/factory-art-0389/emerald/`, `run.log`
and named PNGs; scratch runner `run-factory-art-0389.sh emerald`. No player-save
writes. Selected settings/instrumentation use only the isolated QA profile.
Focused interface71 and inventory549 checks pass. Final broad suite305 passed,
0 failed,58 external prerequisite skips, including SDK1173. Log:
`suite-factory-final.log` in the scratch parent. Missing artwork and special-species/native-form fallbacks remain
covered by the shared reader contracts.

## Remaining interface work

Ruby/Sapphire indexed hatch, Pokeblock cached portraits, minigames, credits and
starter selection remain native. Factory exists in Emerald; absence in the
other editions is not a mod feature gap. Interface inventory stays partial;
full non-model or regional-model parity is not claimed.
