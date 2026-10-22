# Newer HGSS Viridian house adapter — 2026-10-22

The ordinary native FR/LG `viridian_house` exterior uses the house and original
separate door from [HGSS Viridian City, Kuramapika1, September1,2026](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/).
Original game art: Nintendo / Creatures / GAME FREAK. This is the region-specific
`to_h01_001-mesh`, with `ko_door1_001-mesh` at its source-relative transform.
Town, character, Pokémon and flower geometry is excluded. The native flower
house remains separate; this adapter does not replace that family.

The original240triangles(including8door triangles), UVs, PNG bytes, sampler
and alpha values remain intact. The green curved roof, wall palette, window,
chimney, actual entrance recess and door stay proportional. Source rear wall,
side gable cuts and roof underside were open. Separately named authored faces
close those measured boundaries, continue the actual side-wall bands across
the rear and use original roof trim UVs for its rear return. A foundation0.05
below the original shadow closes the bottom without coplanar flicker. Final
geometry has274triangles. Source/provenance/hashes and all authored parts are
recorded in `assets/scenery/viridian-house/provenance.json`.

`tools/import_viridian_house.py` reproducibly selects those two source objects
and generates the independent `ViridianHouseData` module. Original ZIP/DAE/FBX,
ROM art, imported caches, captures and fixtures stay outside source control.
The original native drawing was inspected from its imported metatile atlas:
green roof, upper chimney, left entrance and right window. Regional HGSS source
geometry keeps its own source chimney position; no extra native chimney mesh
should be emitted on the imported building.

`Gen3ImportedViridianHouses.build(g,cells,newMesh,parts)` consumes an existing
ordinary civic group. It requires the exact complete5×4drawing, original pair,
family, all native permissions(rear row0, body7, original left door0x71), level
ground and no boundary/hidden/prop cells. Model geometry occupies only the
three blocked rows beneath the walkable roof-header row. Uniform fit uses the
original door anchor; whole footprint is about65×47.5px of80×48px available.
Source physical body is about53pxwide; the roof silhouette about60pxwide.
Existing native civic ground retains local neighboring surfaces, including
Viridian's stone ground; no imported town ground is substituted.

Success marks `g.importedViridianHouse`. Failed uploads retain native fallback.
`doorSurface` supplies the original native animation panel on the source portal.
`chimney(g)` returns the actual fitted source outlet for optional native smoke.
Native collision, warp, input and actors are unchanged.

Existing imported FR and LG grids each identify one eligible building:
Viridian City(24,8), entrance(25,11). Other house sizes/art/flower variants retain
fallback. Tests pass exact drawing/permission/elevation/prop/boundary guards,
missing-PNG fallback, source door/alpha, blocked bounds, portal and actual chimney
alignment. Seven source and seven closed asset-viewer angles were inspected on
the0.3.95LÖVE11.5shell with Mesa llvmpipe. Parent scene integration and native
static/orbit/first-person, held-input door/collision, local-ground, smoke and
fallback checks remain required before native visual acceptance.
