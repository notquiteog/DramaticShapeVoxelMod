# Hoenn rural field fences — 2026-10-23

Nine exact original General art variants now use the authentic ORAS field
fence already shipped for MID149. This adds the missing depth runs, upper
ends and four corral turns:138/139/13a/140/141/142/148/14a. MID149 remains the
straight horizontal repeat. Four-pixel white post caps center at native X4/12;
horizontal contact is at Z14. The old149 source centered at Z8. Each complete
joined model stays within its original blocked16x16cell. No native cell,
permission, elevation, portal, walkway or floor elevation changes.

The native source-art audit examines all General outdoor maps in each edition:
82 Emerald maps /75 Ruby /75 Sapphire. Primary-family inventories are418/408/408
cells, all collision7. Complete RGBA matching across all used secondary art
finds one additional exact duplicate: Emerald Frontier East3d7 at63,23 matches
primary142. This alias is guarded by its exact secondary tileset; arbitrary
3d7 cells elsewhere remain unchanged. Total reviewed owners are419/408/408.
The eight previously missing primary variants account for231/227/227 cells,
plus the one Emerald secondary duplicate. Other regional fence families remain
outside this batch, and complete Hoenn scenery coverage is not claimed.

## Original source geometry

Uses the existing original ORAS source `world04_03_07`, archive GR0042 slot1,
material `chip_steps01a` and original `chip_steps01` texture (existing provenance
in `assets/scenery/oras-fences/provenance.json`). The original source post twins
and rail cross-sections retain their paint, cap, original UVs and proportions.
Only straight rail spans vary. Reviewed corral graphs share the actual corner
post; rails stop at the correct face of each rotated source post. Original
primitive backs/undersides/endcaps remain closed. UV-preserving coplanar clipping
removes duplicate contact faces. Nine actual output models pass all atomic edge
counts2, zero positive-area coplanar overlaps, native bounds and height10.25.
Bottom contacts recess.025 locally; upper vertices and physical anchors stay put.

`tools/join_oras_fences.py --rural-only` emits `ImportedRuralFenceData.lua`
without rewriting released Rustboro data. The adapter owns all source pieces
and clean grass only after the complete upload succeeds. Original base grass
under138..142 matches native MID1 byte-for-byte. For baked148/149/14a,
independent native pixel checks prove every visible non-fence grass pixel;
terrain hidden by source fence pixels is not claimed recoverable byte-for-byte.

## Native acceptance and explicit long-tour blocker

Latest official release checked:0.3.96, source
0e92b587468c2db7c386f055fc272e6505b0f401. Isolated native engine/source/profile
fixtures run standalone. **32 fresh-map jobs pass**: all12 Emerald maps and
all10 Ruby /10 Sapphire maps containing this family. Actual post-classification
Scene references report **419/419,408/408,408/408 source-built**, with zero image
errors and zero streaming recovery failures. Native/35-degree/first-person/
side/rear captures were made at verified walkable cells. Representative Frontier
end, Route110 long runs, Route117 turns and contact views were inspected.
Native MID/collision/elevation data remains identical to settled native gameplay.
Normal Route111 on-load story scripts initialize some ordinary map cells before
presentation; the comparison begins after those native scripts settle.

A separate engine/mod fixture omits only `chip_steps01.png`. Its Emerald
Route110 missing-source check passes:66 original fence cells remain native,
zero source owners, unchanged native grid/recovery0. Rendered full native fence
fallback inspected. Original assets, active QA engines and user saves untouched.

**Long uninterrupted tour is not accepted yet.** All three edition tours encounter
atomic fence rollback on Route115 after previous maps, despite fresh Route115
passing21/21. The test-only image diagnostic proves the shared persistent source
image cache reaches8,388,608 bytes (134 textures, below the256 entry ceiling).
`SceneryModels.image` returns `scenery texture pixel budget exceeded`; the
catalog also approaches259,310/262,144 vertices. This affects other source doors
and buildings too. No budget is raised and no live resource is unregistered here.
The shared resource lifetime/dedup fix and repeated full tour are release blockers.

Scratch evidence lives under `.scratch/hoenn-world-096-20261023/`:
`rural-census/` (native source/alias proofs), `rural-per-map/results.json` and
per-edition/per-map Scene owner metadata/captures, `rural-missing/`, and
`rural-diagnostics/hoenn-rural-fence-source/ruby/run.log` (exact budget failures).
No caches, ROMs, raw source archives or captures are committed.

Focused tests pass the real9-model manifold/coplanar/material/UV/bounds checks,
all family and region/collision guards, full source-failure atomicity, recessed
contacts, and the released31-family Rustboro geometry regression. Standalone
API3 and default HD2D actors/Pokemon/flowers retain existing behavior.
