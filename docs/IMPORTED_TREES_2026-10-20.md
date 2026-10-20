# Imported trees and preserved native ownership — 2026-10-20

Source integration is verified; exact release-archive verification and paired
performance measurements are recorded separately when complete.

## Source and matching policy

The selected tree comes from MasterPengo's [ORAS Route 104 export](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/364272/).
Its actual broadleaf contains 60 trunk and 48 canopy triangles. The catalog
retains those 108 original triangles, UVs and vertex RGBA values, plus authored
closed bark, inset bark backing and rotated source canopy surfaces. The runtime
model has five material parts and 360 triangles. Original `wood_base.png` and
`forest_wood_a.png` bytes remain unchanged. Importer provenance and original
archive hashes are in `assets/scenery/oras-trees/provenance.json` and the static
scenery catalog evidence. The HGSS and ORAS two-triangle tree impostors were
examined and excluded as replacements for complete 3D trees.

The imported broadleaf is selected only for matching mature native families
with a fully checked blocked footprint. Reviewed Hoenn mature trees and GSC
Ilex broad trees can use it. Matching Kanto broad/round families are eligible;
distinct conifers, volcanic/golden/sapling families and small fragments retain
their existing closed original-art models. This is selective coverage, not an
assertion that every tree in eleven games has a matching imported asset.

`ImportedTrees` requires the complete owner rectangle, including corners, to
remain blocked and level. Walking crown projections, foreign props, furniture,
battle-cleared cells, water and missing cells cannot become tree ownership.
The whole imported model fits uniformly inside the rectangle with 0.25px
padding. A fitted mature tree shorter than 20px stands down; a 32×16 fragment
would otherwise shrink the source tree to roughly 14px. The complete 32×32 fit
is approximately 28.7px tall. Native mids, collision, layers and floor heights
are unchanged. Source/neighbor map identity preserves optional Forest/Safari
overrides even when an engine definition has no `id` field.

Native GB Ilex trees reuse the existing lower-left-owner, four-cell registry.
All four source cells must have native WALL permission and the same floor
height. No additional Gen1 registry, synthetic walkability or gameplay hook is
introduced. Third-party catalog definitions may be selected through
`shape.importedTreeModel` with the same full-footprint safeguards; custom region
adapters can provide `region` and `mapId` context.

## Defaults and resource ownership

TREE ART already defaulted to `modeled`; its label is now **3D MODELS**. The
default TREE TRUNKS preference changes from flat to solid. Existing explicitly
saved original/illustrated cards, flat trunks and optional community tree
families remain selected. Reading defaults writes no preference migration.
Preset changes do not force tree-art or trunk settings.

GBA queues imported batches before the ordinary tree branch and suppresses an
old tree only after all replacement material parts build successfully. Ambient
canopy effects use the actual fitted height and source canopy-bottom anchor.
GB batches belong to the existing budgeted tree sections; their cancellation
owner is registered before the first resource allocation or yield. Asset failure
restores the original closed native hull before section upload. Instances and
merged fallback preserve source RGBA through an explicit vertex format.
Missing public-reader assets retry on the next adapter rebuild. Character,
Pokémon and flower sprites, native UI and optional partner independence remain
unchanged.

## Source native review

Official engine 0.3.91 was rechecked before this batch. RSE used the isolated
`engine-water-import` shell; GSC used `engine-grass-gb` and copies of the existing
QA profiles. The NVIDIA vendor was requested explicitly. Frozen archive drivers
also assert the actual NVIDIA renderer and record the loaded public-file hashes.

The accepted source review inspected **93 tree screenshots**:

| Editions | Source fixtures and scope | Captures |
| --- | --- | ---: |
| Emerald/Ruby/Sapphire | Littleroot source/neighbor control; Petalburg native tree rows; four orbit angles and low eye views; explicit cards; missing-asset solid fallback; merged fallback; native blocked-edge input | 48 |
| Emerald/Ruby/Sapphire | Repeated clear Petalburg orbit/eye views | 15 |
| Gold/Silver/Crystal | Ilex native source, 35°, four first-person headings, explicit cards, missing-asset solid fallback, merged fallback; New Bark pipeline control | 30 |

Littleroot's house/truck occludes several close views; those are neighborhood
controls rather than isolated tree approvals. New Bark is a native pipeline
control rather than a claim that each conifer was individually examined. The
processed source model's separate multi-angle review supplies its rear and
underside inspection. Some distant perimeter foliage fades into the existing
sky/scene boundary; no broad distant-boundary overhaul is claimed.

RSE passed actual native movement at Petalburg `(20,2)`: a move up into the
blocked tree remained in place, then an adjacent native dry walking step
completed. Across the accepted RSE runs, the uploaded source XYZ/UV/shade/RGBA
and per-build native fields were checked, including intentionally merged
fallback. GSC repeatedly restored the old closed hull in deliberately missing
asset sections; all three original Ilex tile/collision/permission digests stayed
`c4afe9413063b4c7c28a9d535787c95f19a41ae438e6868bccac7da336c7676f`.
These counters repeat observations across rebuilds, not unique placements.

The original ORAS textures/vertex colors produce deep forest-green foliage
beside the lighter native palettes. Clear native views were inspected before
retaining those source colors; no unreviewed global brightening was applied.

## Native water-battle correction

Two additional native FireRed before/after captures reproduced an independent
presentation defect on Route 21 North `(9,43)`. A real native wild Tentacool
battle, with arena fill OFF and its center still on native water `(152,696)`,
used native floor 0 for both battle actors while the visible sheet was −8.
The scene now checks the actual current water support before using the native
battle floor fallback. Both actors and scene support became −8; native floor
remained 0, and native battle timing/state were unchanged. This proof covers
that specific battle fixture rather than all battle terrains.

## Focused verification

Passed: `tree_presentation_defaults_test.lua`, `imported_trees_test.lua`,
`imported_trees_gb_test.lua`, `imported_tree_models_test.lua`,
`route104_tree_import_test.py`, `legendary_tree_runtime_test.lua`,
`native_legendary_trees_test.lua` and `scenery_models_test.lua`. Coverage includes
saved card/flat optouts, mature-fit limits, hidden corners, neighbor map identity,
native source immutability, actual source UV/RGBA preservation, instanced/merged
formats, upload failure, late image retry and cancellation ownership.
