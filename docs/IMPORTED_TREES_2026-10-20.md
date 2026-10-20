# Imported trees and preserved native ownership — 2026-10-20

Source integration, bounded paired timing and frozen 1.53.0 runtime archive
verification are complete for the fixtures below.

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

## Bounded paired timing

Four processes ran strictly serially on official 0.3.91 / NVIDIA RTX 5060 Ti,
driver 615.71.09. The before snapshot keeps the old native solid trees; after
uses the imported-tree integration. All eight captured timing views were
inspected. Both variants loaded identical final `Water.lua`,
`NativeWaterSurface.lua`, `Voxel3D.lua` and `WaterSurfacePass.lua` hashes, avoiding
an unrelated shader change in the tree comparison. Relevant shader hashes:

- Water: `9733cdad6ecdde234d5889c8cf17f18aeb972731c1ff10a29e4a40d3f97cdacf`
- Native surface: `03621aa9d8d68517df7805b3a5161214813698d1a364900f625e0d36aa6a75eb`

Each view used 90 warmup and 360 sampled frames, 1280×720, distance 16, AA off,
spatial upscale 1, high shadows, day, no world curve, SKY water, balanced tree
detail, vsync off and the engine's unpaced QA-driver mode. GBA samples asserted
that no scene rebuild began during measurement. These are single paired native
fixture observations, not a universal FPS or platform performance claim.

| Native fixture | Camera | Old mean / p95 ms | Imported mean / p95 ms |
| --- | --- | ---: | ---: |
| Emerald Petalburg `(29,19)` | 35° | 13.887 / 17.046 | 12.818 / 15.640 |
| Emerald Petalburg `(29,19)` | 1ST | 13.473 / 16.918 | 12.213 / 14.969 |
| Crystal Ilex `(10,20)` | 35° | 16.333 / 28.886 | 11.699 / 13.265 |
| Crystal Ilex `(10,20)` | 1ST | 14.236 / 22.905 | 11.554 / 12.943 |

The Emerald mean draw CPU cost rose modestly, 1.435→1.624ms at 35° and
1.329→1.438ms in 1ST, while the measured whole-frame interval fell. Crystal mean
draw CPU was 1.276→1.025ms and 1.011→1.015ms respectively. No prototype-merging
change was needed for this batch. The QA script sampled graphics draw-call
statistics after their presentation reset, producing zero; those values are
excluded. The older tree-cache vertex diagnostic omits instanced sidecars and
is also not used as evidence of total vertex reduction.

## Frozen 1.53.0 runtime archive

The installed release candidate repeated the native tree cases in all three
Hoenn and all three GSC editions on official 0.3.91 / NVIDIA RTX 5060 Ti. All six
processes exited 0. Each independently asserted all **529 public runtime/scenery
file hashes**, requested the eight water shader variants, checked solid-tree
defaults and the actual catalog canopy anchor, and recorded thirteen additional
tree/module/unchanged-PNG readback hashes. The QA control script stays external
when the package excludes developer tools; all exercised implementation and
assets came from the installed package.

All **78 frozen screenshots** were inspected: 48 across RSE and 30 across GSC.
The RSE set contains clear native Littleroot `(1,19)` front, side, rear and low
eye views, native source references, the Petalburg low eye view and all card,
missing-asset, merged and boundary-input cases. Four Petalburg orbit angles at
the auto-selected northern target were obscured by the existing distance fade;
they are recorded limitations, not accepted close-model evidence. The clear
Littleroot angles and Petalburg ground-level/fallback views provide that evidence.

All three RSE builds again blocked the move up from Petalburg `(20,2)` and
completed an adjacent native dry walking step. Actual GPU vertex readback
retained source XYZ/UV/shade/RGBA in both instance and deliberately merged paths;
native mids, collision and floor/layer values stayed unchanged through rebuilds.
All three GSC builds again preserved the Ilex digest, honored explicit cards,
restored closed native solids when textures were deliberately unavailable and
rendered the non-instanced fallback. New Bark remains a pipeline control.

The engine release was rechecked during this frozen verification and remained
0.3.91. Runtime hashes are retained independently of later evidence-only
documentation packaging; the original checked ZIP digest and per-run reports
are saved with the external frozen QA results. This verification does not add
unreviewed building, interior, conifer-family or whole-region coverage.
