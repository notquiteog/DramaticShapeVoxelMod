# HGSS Pallet building adapter preparation — 2026-10-22

`Gen3ImportedKanto` imports three regional exterior models from [Pallet Town,
Kuramapika1, submitted September1,2026](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592847/).
Original game art: Nintendo / Creatures / GAME FREAK. The local archive and DAE
hashes, individual texture hashes, materials and authored closures are recorded
beside each model in `assets/scenery/pallet-buildings/*/provenance.json`.
`tools/import_pallet_buildings.py` reproduces the separate `PalletBuildingData`
module. The source ZIP, full town, flora, actors, ROMs and captures are excluded.

New source selection was compared with the prepared2015 `hgss_oaks_lab` OBJ:
its230body triangles have identical bounds and source vertex positions within
0.00001 source units; triangulation differs. The newer DAE retains valid solid
material information, explicit0.2903226 source shading alpha and a separately
positioned original door. It needs no missing-`lambert1.png` repair. This is a
newer export of the appropriate HGSS building, not evidence of a newer game
model. Red and rival houses use their own source geometries, including the
Red-home fixture and each independently placed original door.

The importer keeps original triangles, UVs, PNG bytes, source sampler defaults,
and source material alpha. Source white vertex colors are checked explicitly;
a changed nonwhite color stream fails rather than disappearing. Closure parts
are separately named and credited: measured rear siding/gable/roof cut and
foundation on houses, the previously measured Oak rear/roof/foundation closure.
Source fronts, actual roof silhouette, windows, fixtures and recessed entrances
remain intact. House source bodies+doors contain234/216triangles, closed260/239;
Oak234including door, closed270. Oak's translucent shading includes a vertical
part and must render with blending and depth writes disabled; it is retained.

`prepare(cells,regions)` discovers exact complete native drawings without
claiming cells. It returns candidates for only native `FR_PALLET_TOWN`:
Red house(5,3), rival house(14,3), Oak(13,9). Connected regions translate these
source coordinates. The exact tiles, canonical Pallet pair, secondary family,
all native permissions, level ground and absent props/boundaries are required.
The rear roof row stays walkable; uniform models occupy only the following
four blocked rows. Native lawn0x296 continues beneath each assembly. Door
anchors align to the original entrance tile, without changing collision or
warps. Successful `build` alone marks `g.importedKanto` and claims `c.civic`.
The caller should build before terrain emission and append only successful
groups to its ordinary civic list. Missing textures/upload failures retain
native columns. `doorSurface` provides the animated native door panel.

Unit checks pass native permission/base/boundary/tile changes, connected-map
translation, missing-texture fallback without claims, source alpha/doors,
bounded geometry and portal alignment. Actual existing FR and LG imported
Pallet layouts each discover exactly these three candidates. Standalone
LÖVE11.5 source and closed-model viewers rendered seven angles per model on the
current0.3.95 native shell (Mesa llvmpipe); fronts, both sides, rear, low eye and
undersides were inspected. Those are asset previews, not native in-game visual
acceptance. Parent integration, the final blended pass, native FR/LG static,
rotating and first-person views, held-input doors/collision and fallbacks remain
required. No other Kanto map, interior, Hoenn building or eleven-game completion
is claimed by this adapter.
