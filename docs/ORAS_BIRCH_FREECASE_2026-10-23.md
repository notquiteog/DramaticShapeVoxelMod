# Original Birch freestanding case — 2026-10-23

Six original-source furniture components accepted: one common and one end
owner in Professor Birch’s lab in each of Emerald, Ruby and Sapphire. Each
native 32×48 drawing keeps its walkable first row clear; the fitted case and
carton occupy only the two blocked rows. No map cells, collision, scripts,
wallpaper, floors, camera bounds or actor styles change.

Source: original Alpha Sapphire ZO227 → AD114 → MM168 → GR510
`t101r0301_00_00`, SHA256
`88c0fe278846a20cb8092c275567b98f1d2a5266d7e532966ac5d87bf3a5993e`.
Complete double-bay case, four bins, four shelves and forty-four books retain
original triangle geometry, proportions, angles, PNG and UV. Eighteen whole
book groups translate only in X inside the original shelf bays to eliminate
49 actual coplanar/intersecting contacts; maximum shift is 2.803 source units,
about 1.3 native pixels. Source vertex lighting/alpha is removed from opaque
original colored textures. Exact book/case/bin rims receive closures, retaining
collinear vertices and original tiny bin underside tilt. Buried shelf ends and
backs receive no duplicate planes.

The independent original taped carton uses ZO450 → AD200 → MM352 → GR743
`c103r0701_00_00`, submesh10 connected group0; SHA256
`2e58bae81d3799663f45f8f1ebbd4cdd43b4a73941fdc0e1d762ccc420076f41`.
Uniform fit gives a ten-pixel-wide carton resting exactly on the original case
top. Its original open base receives no coplanar cap. The complete 1094-triangle
assembly contains 820 original triangles and 274 authored closures, stays below
the native 32-pixel room ceiling at about 26.48 pixels, and has no positive-area
coplanar surface overlap. Only physical Y0 contacts recess .025 pixels below
the unchanged native floor. Upper geometry and X/Z remain unchanged by recess.

Official v0.3.96 was checked before the accepted batch. Verified native Linux
shell 0.3.96, isolated fresh QA identities; RSE caches remain valid at versions
23/8/8, and FRLG cache140 came from genuine fresh imports, without stamp edits.
The mod resolves to this worktree, standalone companions absent, modern
interiors/day/FAR64. Fresh-new-game driver teleports, no keyboard gameplay
claim. Every case received native-reference, room-overview and individual
front/left/distant whole-case review; nine source views include sides, rear,
top and both undersides. All six placements and all three missing-carton-PNG
atomic fallback runs pass; native fallback remains visible. GPU processes close
after the driver's PASS (packaged Linux shutdown returns1).

Data checks prove exact original book/bin/case closure, original carton support
without a duplicate base, source proportions, native blocked bounds and
cap-only floor recess. All fifteen imported furniture models pass geometric
positive-area coplanar checks. Existing extraction/atomic fallback, native
box-union and scenery-resource suites pass. A clean independent conversion
reproduces the committed Lua, provenance and textures byte for byte.

Identifier-only census repeated on 0.3.96 across all 2161 maps. Every native
cell hash matches the prior census. Source candidates total2047; component
acceptances total2002 across261 maps, with historical component evidence still
labeled0.3.95 and these six labeled0.3.96. Every map’s renderedAccepted remains
false: component review does not prove complete modern room/map coverage.

Scratch evidence (excluded from Git): `all-interiors-20261023/` contains
`birch-free-source96-{emerald,ruby,sapphire}`, matching `birch-free-missing96-*`,
`birch-free-inventory96-*` for all five editions, `viewer-birch-free` nine views,
`birch-freecase-repro96` and RGB review montages. Native hash/cell/family and
component acceptance metadata are committed under `docs/coverage/`.

Remaining: native fallback’s older archive box still clips the ceiling; this
batch corrects the genuine-source assembly only. Remaining native furniture,
irregular Mt. Pyre framing and other uncovered room/art families remain open.
No complete-game or complete-map claim is made.
