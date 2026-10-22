# Ordinary Kanto imported tree selection — 2026-10-22

The coverage mismatch is in source selection. The native common General tree
does not set `treeFamily`; `Gen3TreeFootprints` uses the fallback label
`conifer`. `ImportedTrees` previously allowed Kanto broad/round families only,
so it rejected ordinary complete town/route trees. The native drawing itself
is a pointed tree with three foliage tiers, reconstructed from General mids
`{{14,15},{28,29},{36,37}}`. The mapping is based on that art, rather than the
default family label.

The newest downloaded HGSS town scenes were compared first:
[Pallet 592847](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592847/),
[Viridian 592881](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/)
and [Pewter 592849](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592849/).
Their `tree01gs.png`, `tree01_re.png` and `tree01_un.png` bytes match across all
three scenes. The front/rear geometry is sloped cards; the underside is a
repeated flat sheet. Their rounded broadleaf picture also differs from the
ordinary native pointed tiered tree. Viridian's separate `Tree_*` objects are
two-triangle cards of a small cut-tree/sapling. These sources are not promoted
to closed mature models. `tools/audit_hgss_kanto_tree_sources.py` records their
hashes, geometry/material names, connected-component triangle counts and
source height levels from the local archives.

The real volumetric [ORAS Pine Tree 293576](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/293576/)
has the matching pointed, tiered silhouette and physical trunk. Its source
provider, closed bark geometry, original UV/material data and PNG provenance
are owned by `ImportedPineTreeData` in the separate evergreen-source batch.
This module reuses `oras_evergreen_tree`; it does not duplicate or recolor that
source. Original game art: Nintendo / Creatures / GAME FREAK.

`Gen3ImportedKantoTrees.select(c,options)` returns that model only for an
ordinary native General tree owner, verified common-tree mid, known canonical
native pair, Kanto map/context, and a complete 32×32 blocked owner rectangle.
Explicit provider models, special rows/palettes, forest crowns and other tree
families stand down. Narrow 16×32, shallow 32×16 and single-cell fragments keep
their original solid native models: a uniform mature source fit would leave
too much of those blocked bodies empty. Full 32×32 source fit is approximately
40 pixels high, comparable to the original mature portrait.

Parent `ImportedTrees` integration must register the evergreen provider, use
this source selection before its broad/round fallback, retain complete-cell
collision/elevation/ownership checks, and suppress a native model only after
successful upload of all material parts. Selection itself changes no cells.
Source settings, optional custom Forest/Safari overrides, native collision,
local ground, actors, Pokémon and HD2D flowers retain existing behavior.

An identifier-only census of existing imported FR/LG layouts finds 3,310 full
32×32 candidates across 42 maps per edition, 6,620 total. Per edition examples:
Pallet 29, Pewter 183, Viridian 147 and Route 1 68. Other ordinary owners are
365 shallow, 24 narrow and 55 single-cell fragments. Separate forest-tiered,
Safari/round and gold broadleaf art is not included in this mapping. Census
uses all native layouts and existing footprint preparation, excludes generated
outside-map boundary fill, and is eligibility evidence rather than a visual
acceptance count. CSVs with every root, source mid, bounds and selected/fallback
family remain outside source control for parent QA.

Focused tests cover source/pair/context identity, full footprint size,
fragment and foreign-family standdown, source-selection immutability and the
existing uploader's walkable-corner/elevation guards. Native current-engine
camera, held-input collision, local-ground, source silhouette, missing-asset,
saved-card/custom overrides and connected-map views remain required before
release acceptance.
