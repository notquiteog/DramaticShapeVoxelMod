# GB/GBC imported grass and source-referenced water

Source verification uses official Gen1Recomp0.3.91, published2026-10-19 and
checked again2026-10-20. Native renders used LÖVE11.5 and NVIDIA OpenGL3.3
on an RTX5060Ti. Each game ran alone in its own disposable imported-cache
profile, with no companion mod loaded. These are visual/correctness checks;
concurrent quality-review runs provide no performance measurement.

## Imported ORAS encounter grass

`Structures.grassPlacements` uses the same source grass-art AND native
encounter-cell predicate as the original grass mesher. Each eligible8px subtile
receives one imported `oras_green` clump, preserving native Gen2 floor elevation.
Decorative ground, actors, Pokémon, flowers, authored Safari vegetation and
native encounter/Cut permissions retain their existing representation.

`ChunkMesher` owns instanced/fallback batches, registers pending resources before
uploads can yield, and releases only its own scene batches. FULL/BODY jobs can
interleave or cancel without freeing each other's pending buffers. Missing
texture/upload support restores the original grass cards and their anchors.
Cut immediately hides the affected original rectangle; rebuild restores only
the current source mask. Zero-count batches never draw. World, neighbour and
staged-battle draws retain their map matrices and physical depth.

Native `tools/qa/gb-grass-models.lua` reviews:

| Games | Native map | Imported8px source placements per game | Captures per game |
| --- | --- | ---: | ---: |
| Red, Blue, Yellow | ROUTE_1 |416|14|
| Gold, Silver, Crystal | ROUTE_29 |640|14|

All six source masks match exactly. Each game verifies an actual native input
step,16 immediate presentation-Cut removals, source-mask restoration, missing
asset fallback and ordinary mesh upload when instancing is unavailable. Tile,
walkable and encounter-mask hashes remain unchanged. The Cut rectangle is a
presentation API fixture, not a claim to exercise the native HM interaction.

All84 captures were inspected: native flat source,35°, four1ST directions,
walk, Cut, original cards and ordinary meshes. Crystal's final overview was
repeated with the real Zoom reset and nested option set to FIT. Earlier OUT4
survey overviews are excluded from acceptance.

## HGSS water and shoreline banks

The inspected HGSS Pallet source has landY16 and upper waterY8 on a16unit
walking grid. That gives the reviewed8px bank. The exact source/provenance is
recorded in `GEN3_WATER_BANK_REFERENCES_2026-10-20.md` and
`assets/scenery/shore-banks/provenance.json`.

`GBWater` copies resolved outdoor native water shapes formerly at−2 to−8.
It does not mutate shared tileset classes, source tiles, collision or elevation.
Indoor water, deeper/raised authored surfaces, steps and bridge/deck shapes
retain their source heights. Third-party maps can set `def.voxelWater=false`,
`preserveWaterLevel`, relative `waterline`, or `bankDepth`; shapes can provide
those explicit preservation/relative-depth fields as well.

Claimed coastal-rock water underlays follow the same presentation profile.
Actor/Surf support, first-person head height and planar actor reflection use
the drawn water level. Connected-map sheets with distinct planes are grouped
before reflection capture; the ordinary shared-plane case adds no per-frame
group allocation. Bank edges use the original HGSS soil texture, cover only
the below-floor strip and lie0.002px into non-walkable water to avoid coplanar
fighting with the closed native fallback. Texture/upload failure keeps that
original closed terrain. Scene eviction/block refresh releases bank buffers;
shared textures are released only by the overall provider shutdown.

A combined GB map water mesh still uses its dominant source-water reflection
plane. Separate neighbour maps with different heights are captured separately;
a hypothetical same-map mixture of authored water heights would need separate
water meshes for exact actor reflections at every height. No such mixture was
established in the reviewed native fixtures. Authored geometry itself is not
flattened to the dominant reflection plane. Bottom-left support sampling follows
the engine's native cell contact convention; reviewed partial shores did not
establish a conflicting stock contact surface.

The terrain, water-plane and bank-mesh caches include the complete live GB
water policy, including explicit/default/disabled state and finite relative
waterline/depth values. The terrain key captures that policy before native snapshot
canonicalization, so−8, opt-out−2 and extension depths cannot share terrain
bytes. Unchanged grass/flower AUX records keep their original key.

Native `tools/qa/gb-water-banks.lua` reviews Red/Blue/Yellow PALLET_TOWN and
Gold/Silver/Crystal CHERRYGROVE_CITY. Every game verifies actual uploaded water
vertex Y−8, opt-out−2, restored−8; soil draws;35°/1ST FULL, SKY and OFF;
missing-soil-texture closed fallback; and native movement onto water. Gen1 Surf
uses an explicitly documented disposable surfing-state fixture followed by
native input; Gen2 uses the native Surf script special. No saved progression
or field-move eligibility is claimed. Native tile/collision digests stay equal.
Each game produces11 inspected captures,66 total. Upload samples are384water
vertices per Kanto game and4416 per Johto game.

Visual review found an unrelated existing native Gen1 Surf camera fault:
`SurfCamera.measure` invented a180px clearance boom without a model provider.
It now requires an actual provider seat/mount before selecting that fallback.
Native HD-2D Surf stays at the source head; measured Stadium mounts and
unavailable-buffer provider clearance remain covered by focused tests.

## Focused verification

- `gb_grass_models_test`: exact source mask/elevation, original fallback anchors,
  no duplicate native uploads, Cut, ordinary upload and interleaved cancellation.
- `gb_water_banks_test`: source-derived depth, shared-shape immutability,
  preservation/extension policies, bridge exclusion and elevated floor closure.
- `native_surf_camera_test`: native HD-2D head view and measured/missing-buffer
  optional-provider clearance, Fly/exit lifecycle.
- `restored_world_features_test`:34checks including real mixed-plane actor
  matrices and actual persistent-cache fingerprint differences.
- Existing Gen2 tile-shape114, water-cast52, water precision12, cache-format45,
  storage7 and battle sidecar43 checks pass, alongside native elevation,
  publish-before-cache and grass/Cut regressions.

This document records source evidence. The release process separately verifies
the exact packaged archive across all11 games before publication.
