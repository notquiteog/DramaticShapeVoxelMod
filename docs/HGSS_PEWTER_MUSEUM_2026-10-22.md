# HGSS Pewter Museum adapted to FR/LG — 2026-10-22

The selected Museum is `nbc_msem_001-mesh` from the newest available
[HGSS Pewter City scene, Kuramapika1, submitted September 1, 2026](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592849/).
Original game art: Nintendo / Creatures / GAME FREAK. Its pink two-tier roof,
Museum badge, tall windows, main arch and lower east wing match the regional
native drawing. Town ground, actors, Pokémon, flowers and other buildings are
excluded. The older standalone Museum asset 294786 is not used.

The source has 445 triangles, one main entrance, open rear/roof cuts and a
wing farther behind the main facade. An ordinary rectangular uniform fit
would cover the native walkable wing header and miss the native staff warp.
This adapter therefore makes explicit geometry edits to the actual Museum:

- Main width is fitted to 175.5 pixels, with the main aperture centered on
  native X88 and its arch front at Z110. Its aperture is narrowed to 16 pixels
  by widening the original piers; the original badge remains rigid.
- The original east wing moves forward and widens into its native side body:
  source X86–152 becomes X170.928571–255.75, and source Z−55.4375–−11.26562
  becomes Z32.25–79.75. The original roof and facade texture remain attached.
- Part of its middle window strip becomes a 14-pixel staff portal centered
  on X216. Original wall/trim textures form continuous flat side walls, head,
  sill and a four-pixel recess. No new sign or emblem is added.
- Rear walls, measured gable cuts, soffits and underside foundations are
  closed with the original wall/trim textures. Flat source shadows retain
  source opacity 0.2903226 and are clipped, with interpolated UVs, to the
  native blocked footprint.

All source PNG bytes, diffuse values and sampler modes are retained. The
geometry changes and authored parts are named and recorded, with archive,
model and image hashes, in `assets/scenery/pewter-museum/provenance.json`.
The final closed asset contains 557 triangles. Rebuild it with
`python3 tools/import_pewter_museum.py SOURCE.zip OUTPUT_TREE`.

`Gen3ImportedPewterMuseum.build(g,cells,newMesh,parts)` consumes the existing
`pewter_museum` civic group. It requires the exact full 16×7 native drawing,
pair, permissions, owned cells, flat ground and absence of hidden/boundary/
prop conflicts. Both native warp permissions must remain 0x71. Neither the
adapter nor its eligibility check changes cell ownership or collision.
Success marks `g.importedPewterMuseum`; upload failure retains native fallback.
Parent scene code must suppress native Museum geometry only after success.
`doorSurface(g,tx,ty)` supplies source-aligned native animation panels for
both original entrances. Existing civic ground supplies local native ground.

Allowed geometry is the union of these padded native rectangles in pixels:
main X0.25–175.75/Z0.25–95.75; wing X175.75–255.75/Z32.25–79.75; main arch
X64.25–111.75/Z95.75–111.75. The walkable roof header, side path, native trees
and shrubs stay outside that union. A native census identifies exactly one
eligible Museum in each existing FR and LG profile: Pewter City, group (12,0),
main entrance (17,6) and staff entrance (25,4).

Tests verify the complete drawing/permission/elevation/ownership guards,
missing-image fallback, both portal positions, source alpha and interior
triangle samples against the nonrectangular footprint. Original and adapted
assets were inspected from seven directions on the 0.3.95 LÖVE 11.5 shell,
including back, sides, low eye and underside. These are asset-viewer checks.
Parent integration and native static/orbit/first-person views, both held-input
warps, collision, animation occlusion, local ground and fallback remain
required before enabling this family in a release.
