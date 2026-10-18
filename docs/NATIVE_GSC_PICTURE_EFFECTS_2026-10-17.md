# Native GSC lifted pictures and LCD effects — 2026-10-17

`Gen2Staged` now composes original one/two-row lifted picture bands into the
world actor. The remaining picture follows native slide while the lifted band
retains its original X. Public `BattleAnimView.scanlines` and `bgpBands` supply
native global SCX/SCY, per-row offsets, blank rows and indexed palette changes;
contiguous equal rows share a draw. The final lifted band bypasses LCD shifts,
matching the engine's presentation order. Source-slot scaling maps both small
ROM images and larger selected frames into the world card without moving its
fixed foot anchor. Native 160px viewport clipping remains authoritative.

No animation, gameplay, sound, HP or party state is changed. Scissor, canvas,
color and palette state restore after successful or failed draws. Graphics
failures retain native ownership. Shaderless BGP keeps the original engine
veil painter instead of silently dropping the effect. Ordinary true-color GBC
art retains its original palette ownership.

Focused contracts cover fitted/short/resized frames, signed scroll, native
viewport bounds, grouping, lifted-source exclusion, BGP rows and restoration on
errors. The Gen2 engine SDK passes202/202 and native option consumers pass549.
The updated source inventory retains123 keys/generation with unchanged status
counts: this closes specific behaviors, not all aggregate parity rows.

Native Linux NVIDIA/LÖVE verification uses official0.3.89, latest checked
2026-10-17, isolated QA profiles and `tools/qa/native-gen2-staged-bands.lua`.
Route29(10,6), down,480x432, level4, distance16, shadowsOFF, ROM/WORLD pictures,
Legendary ballsOFF, Cyndaquil30 versus Sentret3. The fixture discovers original
one/two-row moves through public imported script/constants: ACID_ARMOR and
AGILITY. Both sides run original scripts with the stage OFF then ON; the
original frame counts stay83 and118 respectively, with unchanged HP and battle/
party identity. Counts include texture preparation while OFF and are not a
count of exclusively visible staged frames. This exercises original animation
scripts, not gameplay move costs or damage.

All three Gold/Silver/Crystal runs exit0, each observing724 band preparations
and520 raster preparations. Twenty-four current captures were inspected.
Processes closed; isolated QA settings/saves do not overwrite player saves.

Evidence is in session scratch `gen2-staged-bands-nvidia-0389/<edition>/run.log`
and edition PNGs. Captures show the lifted actor retained in world space,
vertically displaced Acid Armor rows, native HUD/message/menu layers, and
restored bodies after each script. Earlier exploratory `band.png` is excluded
from final capture review. Shaderless behavior, selected-frame fitting and BGP
per-row palettes have focused unit evidence; the actual captures use ROM art
and shader-enabled native rendering. These Linux fixtures do not certify
Android, iOS or Windows execution.

Combined substitute/faint with lifted/LCD effects and animated doubles still
retain the native painter. Full Legendary send-out energy, multi-actor capture/
release ownership, special-pose assets and other limits are listed in
`PARITY_AUDIT_2026-10-17.md`. Full feature parity remains incomplete.
