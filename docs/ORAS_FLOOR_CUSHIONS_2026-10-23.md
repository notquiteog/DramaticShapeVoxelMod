# Original floor cushions — 2026-10-23

All54 Emerald `hoenn_home_cushion` owners on13 maps now use the matching
original ORAS Trick House floor cushion. Native atlas244 shows the same
cross-pattern low yellow cushion on floor229. Every owner is a walkable
collision0/elevation3 cell; no collision, scripts, native floor, walls, room
bounds or HD2D actor settings change. Other editions/art families are not
inferred from this Emerald-specific native pattern.

Source ZO372 → AD165 → MM279 → GR629 `r110r0102_00_00`, SHA256
`336673b46f560347ad3d9f2f66ae2bb3ef0482e00834c66df536a957287c67af`,
submesh2/component0:128 original triangles. Independent Nitrogen positions,
UVs and indices match. Original white vertex RGBA and opaque64×64 cloth PNG
remain unchanged. Fourteen underside triangles close the exact sixteen-vertex
original rim. No source floor/shadow/light geometry. Uniform native fit keeps
source proportions, width15.5/depth15.5/height3.416 within one walking cell.
Only Y0 contacts recess.025 below the unchanged native floor. Exact edge and
plane checks prove a closed model with zero positive-area coplanar overlaps.

Latest officialv0.3.96 checked before the native batch; verified0.3.96 Linux
shell, own isolated QA profile, standalone companions absent, fresh-new-game
teleports, modern interiors/day/FAR64. All54 native reference/individual front
views, all45 available rotated left views, all13 source room overviews and
nine source-model views including both undersides inspected. Native actors
can partially occlude cushions they stand on; exposed cushions remain visible.
All54 source uploads pass. Missing-PNG atomic fallback passes all54 owners on
all13 maps; representative fallback views across the rooms inspected. Driver
PASS is followed by packaged Linux shutdown exit1. No keyboard gameplay claim.

Native render hashes remain constant during every source/fallback room check.
Motel1F’s entry script changes(10,1) from[542,7,0] to[3,7,0]; TrickHouseEnd’s
entry script changes(10,1) from[523,114,3] to[539,7,3]. Both deltas are identical
in before-source, source and missing-source runs and recorded separately in the
component ledger. All2161 raw native census hashes still match the previous
0.3.96 census. Emerald candidate count465; five-game total2101. Accepted
source components2056 across274 maps retain their actual runtime labels;
whole-map renderedAccepted stays false everywhere.

Five focused LuaJIT suites pass: source closure/proportion/footprint/contact,
exact extraction/atomic fallback, all16 imported-model plane intersections,
native case solid union and scenery resources. LuaJIT compilation, Python
syntax, clean source conversion and byte-identical PNG/Lua/provenance checks
pass. No raw sources, native pixels, caches or captures committed.

Scratch `all-interiors-20261023/floor-cushion-{before,final,missing}96-emerald`
holds captures/logs/contacts; `floor-cushion-inventory96-emerald`, `cushion-repro96`
and `viewer-cushion` hold census, reproducibility and nine source views.
Other furniture families, native wallpaper/partition framing and complete
modern room/map coverage remain unfinished.
