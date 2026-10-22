# Imported home TV — guarded native family

This batch adds selected original ORAS TV geometry to true native home-TV
recipes in all five GBA editions. It preserves each native low cabinet and the
FRLG wall note as separate native-art components. Walls, floors, interactions,
warps, collision and actors remain engine-owned.

## Identity and native inventory

Official 0.3.95 native profiles were inspected through the public native tileset
and interaction providers. Exact eligible drawings are:

| Edition | Recipe | Pair | Original rows | Native placements |
| --- | --- | --- | --- | ---: |
| Ruby | hoenn_home_small_tv | building__generic_building | 230,21E,238 | 15 |
| Sapphire | hoenn_home_small_tv | building__generic_building | 230,21E,238 | 15 |
| Emerald | hoenn_home_small_tv | building__generic_building | 230,21E,238 | 14 |
| FireRed | living_television / neighbor_living_television | player_house / house | 02D,035,03D | 9 |
| LeafGreen | living_television / neighbor_living_television | player_house / house | 02D,035,03D | 9 |

All 62 source placements contain the actual native TV interaction behavior
`86` on the middle row (`EventScript_TV` in RSE and
`EventScript_PlayerFacingTVScreen` in FRLG). The adapter requires this behavior,
complete exact artwork, original row permissions `7,7,0`, ownership, equal ground
and unobstructed native approach. Missing/changed sources retain native models.

The older `hoenn_home_tv` and `hoenn_home_rustic_tv` labels are not evidence of
TV identity: inspected source art draws glass cupboards/drawers and has no TV
interaction behavior. Those are excluded. Starting-house wide drawings without
the native TV behavior also remain native pending separate event/art review.
This is coverage of the verified true-TV family, not every household fixture.

## Selected source and processing

[TV, ORAS, asset 294979](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/294979/),
submitted by Hallow on 2015-11-15. Original game art: Nintendo / Creatures /
GAME FREAK. The modern television has a gray flat screen/frame and small stand;
it is a television rather than a PC, desk, cupboard or cabinet assembly.

The supplied OBJ includes alternate coplanar screens/glow and a planar ground
shadow. Select the original static `terebi0` body/off-screen once (84 source
triangles); world shadows remain renderer-owned. Original PNG bytes and original
source geometry are preserved. The exported screen's bottom UV touches unused
green atlas pixels; clamp it to the last original grayscale texel center.

The raw model has an open rear and missing stand undersides. A separately
credited 20-triangle closure follows those original rims using a source case
swatch; a concave stand cap is ear-clipped without extending the silhouette.
Final model: 3 parts, 104 triangles. Source page, archive/model/PNG hashes,
selection, repairs and closure authorship are in neighboring provenance.

The TV is uniformly fit to the middle blocked 16x16 cell with .25 padding,
filling over 15.4 units of width. It stands at the native cabinet height 6;
its source proportions and separate native cabinet depth are retained. It
cannot enter the native walkable approach row.

## Scene integration

The existing `build(cells,newMesh,parts)` API handles PC and TV source families
and marks `p.importedInterior` only after successful uploads. A TV marker is
`oras_home_tv`. Its native component remainder is intentionally explicit:

`Gen3ImportedInteriors.remainder(p,emit,uvFor)` emits the original cabinet at
height <=6.05 and the FRLG wall note at height >=23, excluding the original CRT.
Call it with the ordinary native furniture wall-attachment/elevation callback
while skipping the original CRT mesh. PCs return false and retain their previous
whole-object imported path. A remainder must not reuse a previously cached full
native TV mesh without applying this component filter.

## Verification

- Native source art and interaction inventory inspected for all five editions.
- Official 0.3.95 LÖVE 11.5, NVIDIA OpenGL 3.3 source preview: front, back, both
  sides, quarter, low eye and underside rendered and inspected. Screen edge,
  source proportions, stand, closed rear and underside inspected.
- LuaJIT tests verify all-five exact TV eligibility, native cabinet/note retention,
  changed behavior and approach rejection, missing-source fallback, original
  source counts/PNG, authored closure and bounded uniform fit.
- Existing imported-PC eligibility and ON/OFF regressions pass; LuaJIT compile
  and whitespace checks pass.

Original archives, source sheets and preview captures stay in scratch. Parent
integration owns native in-game camera/interaction acceptance and release tests.
Source previews are not a physical-phone or full-native-map visual certification.
