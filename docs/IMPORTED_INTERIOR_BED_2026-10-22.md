# Imported Comfortable Bed — next batch, nine Hoenn placements

This separate batch selects actual full-blocked Hoenn home beds in R/S/E.
It does not expand a bed into native walking cells or shrink the source into
the single blocked foot cell of player/Lorelei/starter beds.

## Source and native identity

[Comfortable Bed, ORAS, asset 294940](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/294940/),
submitted by Hallow on 2015-11-15. Original game art: Nintendo / Creatures /
GAME FREAK. The original curved wooden headboard/footboard, blue spotted
blanket, white pillow and frame are retained with the original PNG bytes and
original 534 source body triangles. The planar source shadow is excluded;
the existing world renderer owns shadows.

The source exporter leaves rear boards and undersides open. Separate authored
caps (90 triangles) close board rears, foot bottoms, base and bedding/pillow
undersides along their original rims. The original curved silhouette, bedding
and UVs remain intact. Final model: 3 parts / 624 triangles. Attribution,
archive/model/PNG hashes, selection and authored closure are in provenance.
Raw archives and source previews stay outside Git.

Official 0.3.95 native source inspection confirms exact `hoenn_home_bed` art
`25A,25B / 262,263` on `building__generic_building` in these rooms:

| Edition | Native maps |
| --- | --- |
| Ruby | RU_MOSSDEEP_CITY_HOUSE4, RU_PETALBURG_CITY_HOUSE2, RU_SLATEPORT_CITY_HOUSE1 |
| Sapphire | SA_MOSSDEEP_CITY_HOUSE4, SA_PETALBURG_CITY_HOUSE2, SA_SLATEPORT_CITY_HOUSE1 |
| Emerald | EM_MOSSDEEP_CITY_HOUSE4, EM_PETALBURG_CITY_HOUSE2, EM_SLATEPORT_CITY_NAME_RATERS_HOUSE |

All four original cells are blocked (permission 7), with a recognizable blue
bed, pillow, headboard and frame. The adapter requires exact recipe/design,
family/pair/artwork, claimed ownership, uniform ground and all four blocked
permissions. Changed art/clearance preserves the native model.

## Placement and compatibility

Uniform source fit stays inside the original 32x32 blocked rectangle with .25
padding: approximately 20.56 wide, 31.5 deep and 11.07 high. The headboard remains
north-facing. Source proportions are preserved; no geometry reaches a walking
apron. The original native bed palette and source blanket differ, while both
retain the recognizable blue-bedding identity. No source texture is recolored.

The existing `Gen3ImportedInteriors.build(cells,newMesh,parts)` API discovers
this additional family and sets `prop.importedInterior='oras_comfortable_bed'`
only on successful uploads. Its whole native bed geometry is skipped through
the same existing imported-object hook. No new scene hook or remainder is
needed; floor, walls, actors, collision and gameplay stay native. PC and TV
APIs/markers retain their prior behavior.

## Verification

- Original source sheets, native artwork/permissions and all nine native
  placements inspected in official 0.3.95 profiles.
- Official 0.3.95 LÖVE 11.5 / NVIDIA OpenGL 3.3 source preview: front, back,
  both sides, quarter, low eye and underside rendered and inspected. Source
  bedding/boards, original silhouette and closed rear/undersides inspected.
- LuaJIT tests cover each Hoenn edition, full blocked ownership, changed walking
  cells/uneven ground, single-cell-family exclusion, exact source/closure counts,
  uniform bounded fit and missing-resource native fallback.
- Existing PC, TV, powered-PC and source-data tests pass; compilation and diff
  whitespace checks pass.

Parent native 3D/interaction acceptance and release packaging remain pending
for this next batch. This source preview is not native in-game or phone QA.
