# Battle details and party popup repair

Gen2/3 custom battle cards retain native gender (no invented gender for Gen1
or genderless species), wild caught indicators, HP/status/level/name and the
player EXP bar. Gen2 doubles uses the same details with standalone fallback.
Pixel-drawn gender symbols avoid missing glyphs in the bundled font. Card
heights reserve a metadata row; empty EXP still has a visible track.

Modern UI gives native party popup text dark ink after the light popup frame
is drawn. It preserves roster text colors, native input and OFF/unload behavior.

Official Gen1Recomp0.3.76 verified latest2026-10-11. Isolated Emerald native
party selection/actions/Summary/return passed; screenshot inspected, every
popup action readable. Emerald battle male/female cards and Crystal battle
cards through the optional doubles owner inspected. Evidence:
`.scratch/ui-bugfix-20261011/{emerald-party,emerald-battle,crystal-battle}`.
Focused panel/contrast/icon and Gen2 HUD regression tests pass. Caught-icon
geometry is tested; these runtime fixtures used uncaught foes. No new release.
