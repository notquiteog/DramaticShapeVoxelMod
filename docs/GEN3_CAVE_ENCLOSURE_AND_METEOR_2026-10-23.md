# Native cave enclosure and Meteor Falls

This continues the volumetric Hoenn cave checkpoint using official engine
0.3.96 (latest release checked again before this batch), native LÖVE, isolated
imports/saves, API3 and standalone Battle Art. Scene is untouched.

Meteor Falls now uses explicit native rock cap/face identities in all three
Hoenn editions. Ruby/Sapphire retain their gold native art; Emerald retains
violet art. The original terrace sampler keeps raised walkable floors, real
retaining heights, water, the bridge and stairs. Golden wall seams sample their
own native source drawings. The separate two-cell golden pillars remain
unclaimed, pending their own independent fixture model; they are not wallpaper.

The synthetic outer stone bands are replaced for GBA caves with known rock
walls by a closed rock strip outside the native bounds. A dominant actual wall
source selects a single composed native BG1/BG2 material. Front rock strata
share exact vertices, with shallow faceted relief; the back, cap, base and
corner wedges close the mass. No internal box-contact faces are retained.
Native passage intervals are merged, then cut through both sides of the mass
with real jambs, lintel and threshold. Cutaway keeps its low foundation.
Foundation and ceiling material ownership stays separate from wall UVs.

Validation:

- 597 Hoenn identity/dispatch/palette/blocked-footprint contracts PASS.
- 5,532 shell contracts PASS: every triangle has nonzero area; all geometry is
  outside the native play bounds; passage faces are absent; neighboring exit
  tiles share one aperture; exact edge incidence is two everywhere in the
  closed four-wall shell; no duplicate triangles; cutaway stays below ground.
- All-generation enclosure tests also verify dominant native material selection
  and that wall UVs do not leak into foundation/ceiling.
- Native final 18 edition-map cases PASS across all five GBA games. Four
  first-person directions, native and overview views were inspected. Live
  native cells/elevations and warps are identical across rendering. Water,
  bridge/stair lanes and HD2D actors remain native.
- A fresh census of all 1,309 Hoenn maps changes only Meteor Falls family
  classifications (E5/R4/S4). Cave walls +2,541/+1,753/+1,753 and independent
  rocks +56/+35/+35. Native hashes, furniture and civic inventories match the
  previous full-five-game checkpoint. The total changed Hoenn cave set is129.

Metadata-only `meteor-maps.jsonl` and `meteor-shell-native-runs.jsonl` in
`docs/coverage/gen3-caves-2026-10-23` record source/profile/shell hashes, native
identifiers/hashes and actual exercised scenes. Every whole-map acceptance
remains false. This is component evidence, not full cave or game approval.

Remaining work includes independent Meteor golden pillars, additional volcanic,
Navel Rock, Mirage/Seafloor variants, interior mouths/floor relief and matching
original ORAS dungeon components. Native wall materials repeat at their source
scale; no external source map or unrelated texture is substituted. Raw native
pixels, captures and original archive/model inputs stay out of the repository.
