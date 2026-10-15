# Tower reception interiors — 2026-10-15

## Scope and design

Continues the1.40.0 tower exterior release with three distinct native reception
layouts: FRLG Trainer Tower, Emerald's four reception lanes, and Ruby/Sapphire's
single U desk. Closed component models replace projected desktops, PCs and wall
consoles. Staff gaps retain their native flooring and remain completely clear.
Door frames have closed sides/backs/undersides and original-art panes; active
native animation frames use the exact same inset and source crop.

Trainer Tower's eight halls gain both stair families, round pier groups, a closed recessed downward stairwell and
eight separately matched floor-number displays. Native stair warps are directional
(east/west); the physical treads/closed sloping handrails face those approaches.
Surrounding wall context is retained. Each source display remains continuous on
its own closed relief; no lettering, fixtures or replacement game art is invented.

A recipe can validate a complete drawing while claiming a subset of its cells.
Previously an earlier-row screen/elevator prevented a reception desk from matching.
Only unowned modeled cells are claimed; already-owned context remains with its
original model. Full native identifiers and collision values still must match.
This behavior is available to additional native recipe families; third-party
changes to walking permissions fail open. Base collision/warps/scripts are never
patched. Characters/Pokémon/flowers remain HD-2D; all partner mods are optional.

## Reproduction and evidence

Latest official `bryanthaboi/gen1recomp` checked again before this separate batch:
0.3.89, published2026-10-15T16:20:04Z. Native Linux LÖVE desktop runtime, isolated
QA imports/profiles, no Continue or save writes. Production engine is unchanged;
QA-only harness helpers retained from0.3.88 because0.3.89 omits them. Rendered
captures are desktop evidence; no Android/performance certification is claimed.

Scratch: `/home/admin/Projects/.scratch/gen3-tower-interiors-20261015/`.
Worktree: `/home/admin/Projects/.scratch/tower-worktree-20261015/`.
Engine shell: `/home/admin/Projects/.scratch/runtime-0.3.89/engine-towers/` with
`mods/BATTLE_ART_VOXEL_FORK` resolving to that worktree. Profiles are disposable
copies at `/home/admin/Projects/.scratch/gen3-towers-20261015/profiles/`;
identities `gen3-<edition>-qa`, never player progress.

Native source diagrams: `FR_TRAINER_TOWER_LOBBY-source.png`,
`FR_TRAINER_TOWER_1F-source.png`,
`EM_BATTLE_FRONTIER_BATTLE_TOWER_LOBBY-source.png`,
`RU_BATTLE_TOWER_LOBBY-source.png`, plus source layout tables for all eight floor
number variants. Active imported atlases supply all runtime texture pixels.
No native art/reference image/ROM/cache/capture is committed or packaged.

`tools/qa/gen3-scene-review.lua` uses the production renderer with a QA orbit
lens for front, both sides, rear and eye captures. Five-edition lobby views,
all eight FireRed halls, LeafGreen upper hall/stair closeups, and Emerald's
multi-partner room (reused doorway) are inspected. Source-specific flights preclaim their drawings before the generic
stair adapter, preventing duplicate floor projections. Census uses this same
production preparation order. Earlier rejected captures
remain scratch evidence: initial doorway gaps, dark frame returns, northward
stair flights and missed FR desks were corrected before acceptance.

`tools/qa/gen3-tower-interiors.lua` captures OFF/native fallback and actual1ST
camera views, then uses ordinary held movement in the native-direction camera.
After QA map loads it resets the player to the checked approach cell, preventing
native arrival movement from invalidating fixture coordinates. A wandering NPC
may occupy one front-aisle direction; the other direction is tried without
changing objects/collision. Earlier incorrect fixture positions/directions are
rejected runs, not passes. Native destinations remain engine-controlled.

| Edition | Lobby / native internal door approach | Destination |
| --- | --- | --- |
| FireRed | FR_TRAINER_TOWER_LOBBY17,9 | FR_TRAINER_TOWER_ELEVATOR |
| LeafGreen | FR_TRAINER_TOWER_LOBBY17,9 | FR_TRAINER_TOWER_ELEVATOR |
| Emerald | EM_BATTLE_FRONTIER_BATTLE_TOWER_LOBBY6,2 | EM_BATTLE_FRONTIER_BATTLE_TOWER_BATTLE_ROOM |
| Ruby | RU_BATTLE_TOWER_LOBBY6,2 | RU_BATTLE_TOWER_BATTLE_ROOM |
| Sapphire | SA_BATTLE_TOWER_LOBBY6,2 | SA_BATTLE_TOWER_BATTLE_ROOM |

`tools/qa/gen3-tower-interior-census.lua` inventories every native placement of
the new components, including atlas reuse, and checks all-height face bounds
against complete permission0 walking cells. This is separate from runtime input
and visual approval; native objects and figure drawings remain independently
owned.49 five-edition source/geometry fixtures cover complete matching, permission
changes, preclaimed drawing context, UVs, closed shells and animated pane mapping.
Broad suite299 passed,0 failed,58 missing-external-fixture skips.

## Remaining large interiors

This batch does not certify all regional interiors. Remaining queues include
RS museum/Devon/Space Center family parity, distinct facility/contest/hideout
fixtures, museum exhibition details and other large institutional rooms. The
native walkable bench drawings and figural reception ornaments retain their
existing presentation; they are not silently turned into solid walking obstacles
or full3D Pokémon. Broader inventory/coverage ledgers remain authoritative.
Exact-package inventory/input/partner results are recorded below before release.

## Verified release archive

Exact1.41.0 package in `engine-tower-interior-package`, standalone:
FireRed78/LeafGreen78/Emerald8/Ruby3/Sapphire3 new component placements
(170 total),0 solid-face intersections with native walking cells at any height.
Level floor surfaces at height0 are intentionally excluded from solid flags.
The census follows production preparation order: authored tower flights first,
then generic stairs, then other furniture. It records the partner-room doorway
reuse rather than silently assuming every frontier room was reviewed.

All five native front-aisle walks and all five internal doorway transitions pass.
FRLG additionally pass six ordinary directional stair transitions: lobby→1F,
1F→2F and1F→lobby in each edition. Production camera recovery remains active
without failures. Exact archive OFF/native, actual1ST and destination captures
are inspected. Final source-specific closed stairwell and neighboring Oak lab
views are inspected (`package-neighbors/`), preserving unrelated lab furniture.

Exact archive with all six optional partner mods (`package-all-native/`) passes
Emerald's aisle/internal-door fixture; rendered first-person capture inspected.
Versions: wild_skies1.15.1, dramatic-sky-ride0.5.4, double-battles-gen20.14.2,
gen1online-plus0.11.1, overworld-spawn-mod2.6.3, modern-ui0.4.1. All six local
checkouts are clean and match their latest published tags. Online's latest tag
was absent locally; the remote v0.11.1 and main both match local0a48e10. No
uncommitted or unreleased partner changes were found in this audit. The combined
fixture uses the published online package, as in the previous tower release.

Package:11,376 files,480 Lua files compile;ZIP integrity passes; manifest hard
dependencies remain empty. Runtime bytes are hash-compared after the final
evidence-only repackage. Only docs/handoff change after these archive checks.
QA processes exit normally; player progress is untouched. This batch is fully
reviewable and releasable, with the remaining interior queues listed above.
