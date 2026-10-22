# Route115 → Rustboro imported tree fallback

Focused source fix; genuine ORAS tree defaults, source vertices/UVs/materials,
native collision/elevation, map layouts and source ground are retained.

## Reproduction and cause

Official latest release checked 2026-10-22: `bryanthaboi/gen1recomp` v0.3.95.
An isolated native0.3.95 renderer used the existing imported R/S/E data, disposable
QA identities and this worktree. Started Route115 at native(21,76), walked south
with ordinary input for115frames, and crossed into Rustboro at(21,4). The shared
runtime mod link and player saves were untouched. Before/after captures and
JSON resource/owner diagnostics are scratch evidence, not bundled game assets.

Cold Emerald before:357 imported placements on Route115,429 after crossing,
no tree upload errors. Resource use was5→7 models,6→11 textures,659712→909568
texture bytes. After visiting10 towns, resource use reached14 models,33 textures,
3236096 texture bytes, without errors; the same cold fallback remained. The
shared64 model/texture or8MiB texture limits did not cause this reproduction.
No limits are increased. SceneryModels.stats exposes copied read-only resource
accounting so future failures can be identified from the public module API.

Two guards caused confirmed false fallback:

- Complete32×32 native round-tree owners span a six-pixel terrace step. Their
  four blocked source cells can inherit different rendering heights, while the
  original tree is still one complete crown/trunk assembly. Strict per-cell
  height equality rejected roots(13,74),(32,70),(34,70),(36,70),(38,70),(22,62)
  on Route115. The narrow exception requires the exact reviewed2×2 source
  drawing, one root, shared owner/pair/region, native permission7/layer0 on all
  four cells, and exactly two heights separated by6px. The complete original
  broadleaf remains at its unchanged trunk/root ground; floor fields are not
  flattened. Larger height jumps, walks, foreign ownership and custom palettes
  retain fallback.
- The ordinary native adapter already approves generated boundary forest as
  blocked ownership, but the shallow Hoenn adapter rejected all boundary flags.
  Fully synthetic32×16 forest owners can now use the existing reviewed source
  depth variant when every cell has permissionnil, boundary='forest', matching
  source owner/pair/region and level. Mixed native/synthetic ownership remains
  rejected. This introduces no miniature tree or additional source variant.

## Results and limits

Final Emerald cold and warm counts:379 imported placements before crossing,
471 afterward, with no tree upload failures and unchanged model/texture totals.
The extra22/42 placements include the six native terrace trees and16/36 fully
owned synthetic forest rectangles in the respective render windows. First-person,
side and overview captures were inspected: the previously bright native crowns
are replaced, trunks meet local ground and the source canopy stays within the
blocked footprint. Native source layout hashes remain stable on repeat visits.
Actual R/S boundary walks exercise the same terrace family; final edition totals
are recorded in the scratch run logs. This is a rendering/input-driver check,
not a claim of physical keyboard or mobile testing.

Remaining explicit fallback is tracked in scratch remaining-tree-owners.csv.
Emerald's fixed Route115 view has69 remaining owners:44 narrow synthetic border
owners,21 narrow native owners across connected maps, three native12px terrain
spans, and one unreviewed source fragment. The Rustboro view has77 remaining
owners. They need source/ownership work; this fix does not count them as modern
model coverage or shrink a mature tree into a half-empty clipped owner.

Checks: new terrace/atomic-failure/resource-accounting tests; existing Hoenn,
imported-tree, multi-owner, source-model and scenery resource suites; production
LuaJIT2.1 compilation. Runtime evidence paths are reported to the parent task.
