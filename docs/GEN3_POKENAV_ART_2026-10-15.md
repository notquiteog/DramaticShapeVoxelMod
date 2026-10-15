# Native Hoenn PokeNav selected art — 2026-10-15

Ruby/Sapphire condition and ribbon views, plus Emerald condition and ribbon
summary views, now consume selected interface art during their native draws.
The existing scoped reader captures the actual mon supplied by each class
instance, retaining PID/OT/shiny identity. Native graph/stat/ribbon rendering,
sparkles, slide timing, description input and exit remain in their own screens.
OFF/MODDED and missing selected art retain their original pictures. FIT/FULL
uses the complete animation union, including the corrected Crystal CPU path.

Official **v0.3.89** and matching native Linux shell; release API rechecked for
this batch. Production engine untouched, public QA harness support from0.3.88.
`tools/qa/native-gen3-pokenav-art.lua` runs all three Hoenn editions on isolated
imported profiles with no companions, 480x320, native 2D world, Crystal pack,
a synthetic Pikachu/Cyndaquil party and one native Cool ribbon each.

All three pass real condition/ribbon FIT/FULL/OFF draws, native Down input to
the shiny second Pokemon, ribbon description A/B input and ordinary B exits.
Party table/object count, ribbon words and tested contest stats remain intact;
picture readers restore. Native screen entry uses public PokeNav shell methods
after ordinary shell opening; it is not a progression/unlock or full menu-route
playthrough. No player saves are written. Instrumentation and processes close.

All eight captures per game were inspected: condition FIT/FULL/native/shiny,
ribbons FIT/FULL/native and description. Selected art changes independently
of the original graph, ribbons and chrome; native art returns under OFF.
Emerald's fixture retains the same sparse native header/name rendering in OFF;
this batch does not claim to repair or validate every original UI detail.
Evidence is `.scratch/voxel-parity-20261015/pokenav-art-0389/{game}/`, with
`run.log` and named PNGs. Runner: workspace scratch
`run-pokenav-art-0389.sh GAME`. Release evidence: `latest-pokenav-release.json`.

Focused interface65 and inventory549 checks pass. Final broad suite300 passed,
0 failed,58 external prerequisite skips, including SDK1173; log
`suite-pokenav-final.log` in the scratch parent. Source-family coverage remains partial:
Ruby/Sapphire indexed hatch, Pokeblock cached pictures, contest entry/animation,
Factory selection, minigames, credits and some scripted portraits are still
native. Cached readers require their own lifecycle adapters, not merely a draw
wrapper. No models/assets/version/release/push changes.
