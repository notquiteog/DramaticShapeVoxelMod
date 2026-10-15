# Native GBA towers — 2026-10-15

## Architecture and bounds

Three distinct families cover both Sevii Trainer Towers, Emerald's Battle
Frontier tower, and Ruby/Sapphire's shorter Battle Tower. Active native pixels
supply every texture; no ROM art, references or caches ship in the package.
Blue ribbed cladding, native windows, red brick piers, colored stone strips and
entrance canopies retain their edition's source vocabulary. Rear/side window
placement and closed roof caps interpret unseen elevations. Actual window/door
recesses, chamfered glass bays and closed slabs replace folded sprite planes.
No invented lettering or roof equipment is added.

Full native identifier and permission matches are required. All-height tests
cover native walking cells, shell bounds, UV range, underside closure, original
door source and animated pane inset. Changed third-party source/permissions fail
open. Native collision, NPCs, warps and base UI are unchanged. HD-2D actors,
Pokémon and flowers remain native; all partner mods remain optional.

## Runtime evidence

Latest official `bryanthaboi/gen1recomp` release checked before this batch:
0.3.89, published2026-10-15T16:20:04Z. Its Linux LÖVE runtime and untouched
production engine are used with isolated disposable QA profiles, existing
native imports, no Continue/save writes. QA-only helpers retained from0.3.88
because0.3.89 does not ship its test harness. Linux NVIDIA rendered captures
are desktop evidence, not Android or an exhaustive performance claim.

Scratch root: `/home/admin/Projects/.scratch/gen3-towers-20261015/`.
Mod worktree: `/home/admin/Projects/.scratch/tower-worktree-20261015/`.
Engine shell: `/home/admin/Projects/.scratch/runtime-0.3.89/engine-towers/`;
`mods/BATTLE_ART_VOXEL_FORK` resolves to that reviewed worktree.
Profiles: `profiles/`, identities `gen3-<edition>-qa` (not player progress).

Source: native diagrams and metatile/permission exports in this scratch root.
`tools/qa/gen3-scene-review.lua` captures four orbit directions and an inspection
eye view. FAR64 removes the earlier review haze; earlier32-distance views are
retained as before/after evidence, not the final rear-view acceptance.

| Edition | Native map / focus | Native entrance approach → destination |
| --- | --- | --- |
| FireRed | FR_SEVEN_ISLAND_TRAINER_TOWER58,4 |58,8 → FR_TRAINER_TOWER_LOBBY |
| LeafGreen | FR_SEVEN_ISLAND_TRAINER_TOWER58,4 |58,8 → FR_TRAINER_TOWER_LOBBY |
| Emerald | EM_BATTLE_FRONTIER_OUTSIDE_EAST16,8 |16,15 → EM_BATTLE_FRONTIER_BATTLE_TOWER_LOBBY |
| Ruby | RU_BATTLE_TOWER_OUTSIDE14,4 |14,9 → RU_BATTLE_TOWER_LOBBY |
| Sapphire | SA_BATTLE_TOWER_OUTSIDE14,4 |14,9 → SA_BATTLE_TOWER_LOBBY |

`tools/qa/gen3-tower-doors.lua` uses native held-up input from a checked walking
approach. Camera0 fallback and camera3 native warp recovery pass all five;
no collision or warp data is patched. `tools/qa/gen3-tower-first-person.lua`
uses actual camera6 (1ST), separate from the QA inspection lens.

Broad suite:298 passed,0 failed,58 explicit missing-external-fixture skips.
Targeted tower geometry contracts include all five translated placements.
Published museum floor-link repair remains included alongside the previously
verified terrain allocation and cold-hull optimization. No primary uncommitted
work was incorporated. Exact-package checks are recorded below before release.

## Remaining work

Large interiors and other unique landmarks remain in progress. Recipe
classification does not certify every room or visual family. Unseen back/roof
surfaces are architectural interpretations using each game's native materials.

## Exact archive and partner checks

The1.40.0 archive installs standalone in `engine-tower-package`; all five
normal-input tower entries and camera recovery pass from this exact archive.
`engine-tower-package-all` adds all six partner mods: wild_skies1.15.1,
dramatic-sky-ride0.5.4, double-battles-gen20.14.2, gen1online-plus0.11.1,
overworld-spawn-mod2.6.3 and modern-ui0.4.1. Combined Sapphire tower entry and
front/side/rear views pass and captures were inspected. Partner checkouts were
clean at the audit; no partner code/dependencies were added to this release.

Exact archive footprint census: FireRed129/LeafGreen129/Emerald82/Ruby78/
Sapphire78 recognized buildings,0 flagged walking-center intersections each.
The census checks low-face bounding boxes against native cell centers; the new
tower tests separately check all heights and entire walking cells.

Exact archive museum regression: both native stair lanes ascend/descend in all
three Hoenn editions,12→24 support with1.5 maximum tread increments; native
entry warps and camera/actor contact remain authoritative. Rendered lower and
upper approach captures inspected. This carries the approved building unchanged.

Packaged Lua compiles,ZIP integrity passes,dependencies remain empty, no native
imports/caches/captures ship. The evidence-only final repackage preserves every
runtime file byte-for-byte from the archive used by the checks above. QA
processes quit; player saves are untouched.
