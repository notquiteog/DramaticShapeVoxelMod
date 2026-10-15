# Native Gen3 scripted and contest pictures — 2026-10-15

This batch follows release source checkpoint4bc557a (voxel1.41.1); it does not
change that release's metadata or claim inclusion in its archives.

`NativeScriptedArt` supplies selected art to native `MonPic.draw`, which uses a
cached image instead of reading Pokemon pictures during each draw. It substitutes
only that draw's image/dimensions, then restores the original cache, including
on error. Original windows, cries, scene timing, native animation translation,
rotation, flip and squash/stretch remain owned by the engine.

The native MonPic renderer scales pictures into64x64. For oversized FULL art,
the adapter compensates that viewport scale in a temporary animation transform,
retaining authored pixels and native centering/animation. FIT uses the ordinary
64-pixel prepared frame. The original transform object is restored afterward.

Hoenn contest entry pictures retain the original supplied species/PID and
packed32-bit OT identity, matching the engine's shiny calculation. Ignored
second entry requests do not replace the active identity. Show/hide/reset and
unload clear scoped context, so subsequent ordinary script pictures remain
regular. Eggs, alternate Unown shapes, Spinda PID spots and Deoxys edition forms
retain native art. OFF/MODDED, missing art and missing capabilities retain the
native presentation. No models, game rules or companion assets are changed.

## Verification

Official **v0.3.89** with matching native Linux shell; the release API was
rechecked before the batch. Production engine untouched; public QA support is
from0.3.88. `tools/qa/native-gen3-scripted-art.lua` verifies automatic production
installation on isolated imported profiles, without manually installing the
adapter. Fresh Pallet/Littleroot fixture, cell7,8 down, 480x320, native2D view,
Crystal pack, no companions or player-save writes.

All five editions pass scripted FIT/FULL/OFF pictures, native Spinda fallback,
hide/cache restoration and ordinary picture identity. Ruby/Sapphire/Emerald
also pass native `EntryPic.show` pictures with canonical shiny PID/packed OT,
FIT/FULL/OFF and original animation/hide lifecycle, followed by a normal script
picture without leaked shiny identity. This calls the original contest picture
component over the field fixture; it is not a full contest entry, scoring or
progression playthrough. FireRed/LeafGreen have no native contest and skip that
portion explicitly.

All34 final captures were inspected. Selected FIT and FULL have distinct
placement; OFF restores the native picture; contest shiny Cyndaquil retains
Crystal purple flames and subsequent ordinary Cyndaquil has normal flames.
Native Spinda spots remain original. Evidence:
`.scratch/voxel-parity-20261015/scripted-art-0389/{game}/`, `run.log` and named
script/contest PNGs; runner `run-scripted-art-0389.sh GAME` in the scratch parent.
The initial scratch-only FireRed run is superseded by final production evidence.

Focused lifecycle20, existing interface65 and inventory549 checks pass. A
separate test runs the real0.3.89 MonPic renderer with mocked graphics to verify
oversized FULL centering, pixel scale, animation transforms and restored native
cache. The live captures use bundled64-pixel Crystal output, so oversized
external art is covered by that renderer contract test, not a live asset pack.
Final broad suite **305 passed, 0 failed, 58 external prerequisite skips**,
including SDK1173, passes. Log: `suite-scripted-final.log` in the scratch parent.
Generated inventory and LuaJIT/whitespace checks also pass.

## Remaining scope

Interface rows remain partial: Ruby/Sapphire indexed hatch, Pokeblock cached
pictures, Factory selection/swap, minigames, credits and starter selection still
need consumers. Factory pictures are read during draw and can use the existing
scope; Pokeblock selection changes its selected index before its slide swaps the
cached image, requiring lifecycle identity tracking. Model-specific capture
materials, send-out geometry, specialty/doubles capture and regional model
coverage remain separate outstanding work. No full parity claim.
