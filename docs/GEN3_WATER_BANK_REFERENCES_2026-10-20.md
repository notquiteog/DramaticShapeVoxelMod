# Reviewed water-bank dimensions

The user requested visible terrain and water depth using actual ORAS Hoenn and
HGSS Kanto/Johto maps. This records source measurements and the helper contract;
native game/packaged visual verification follows scene integration.

| Public source | Original inspected geometry | Reviewed relative bank height |
| --- | --- | --- |
| [ORAS Route104, asset364272](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/364272/) — MasterPengo, submitted2025-06-29 | `world04_03_06.dae`: soil/main landY0, `chip_river_a/b`Y−5, `r104a_gake01`Y0/−2.25/−5 | 5source units across the recurring36unit map grid; normalized to a16px native cell:20/9px |
| Same ORAS source, coastal assemblies | `world03_02_02.dae`: upper groundY0, coastal terrace/`chip_gake_sea_ground`Y−18, sea and lower bankY−27 | Near-water bank9source units =4px at the same scale. The upper18unit cliff is a separate terrain level. |
| [HGSS Pallet Town, asset592847](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592847/) — Kuramapika1, submitted2026-09-01 | `map32_11c-mesh`: land/roadY16, `sea_on`Y8, `sea_un`Y7; bank faces/rim approximatelyY6.40625–18.03125 | Upper water gap8 at the source16unit grid =8native pixels |

These Y measurements use the restored upright source coordinates: each DAE
declaresZ_UP and its map-node rotation restores Y-up after coordinate conversion.
Object translations do not change the relative differences in each map mesh.
The ORAS36→16 normalization follows its recurring source map grid; it does not
interpret native GBA collision-layer numbers as heights. Reference PNGs inspected
include `r104a_gake01/02`, `chip_gake_sea`, `chip_gake_sea_ground`, river/sea/soil.
The separate `pool_water01` geometry isY0 and receives no blanket inferred drop.

Original archive SHA256:

- ORAS364272: `0d849831180a5bf9484efff71e8947d420558fb6019417cfebb124e673a9257b`
- HGSS592847: `8cce4d10885adebb7e0e2362cc8d1bd07ac9d49ef9bc94b61a66d51ce9e178bc`

Full map archives/textures are reference material and remain outside the package.
The user explicitly authorized use of the public scenery assets and their edits.

`Gen3Water.bind(cells, options)` returns the existing wet-rock count plus a full
water field. Supply `regions` after native elevation binding, `region='hoenn'`
or`'kanto'`, `outdoor(def)` and an optional build-budget `tick`. Native public
`src.core.game3.mb.nameOf` identifies ocean/deep/seaweed behaviors; native
`collision.isSurfable` already owns the scene's water classification. Connected
same-datum bodies share a sheet, choosing the coastal depth when a river meets
the sea. Water at an already lower datum stays there, including raised-deck pools.
Distinct native water heights are never flattened together. Full native floor
fields keep the level stable when banks leave a moving render window; missing
fields/banks retain the reviewed profile fallback. Interior water is preserved.

Third-party controls: per-cell shape`bankDepth`, absolute`waterLevel`, local
`waterline`, or`preserveWaterLevel=true`; region`def.voxelWater=false` opts out,
or a table supplies the same controls. A region waterLevel is local to its
aligned map datum. An explicit depth works for a custom interior pool.

Scene integration uses `localLevel(c)` for ordinary water mesh emission,
`surface(c, layer)` for underpasses, and`at(field,x,z,layer)` before the existing
native ground support query. Wet rock underlays/hulls inherit that same sheet;
reflection groups derive their heights from the actual emitted vertices.
Underpass support requires its exact native layer and leaves the upper deck
unchanged. Collision, elevations, metatiles, native base/floor objects and input
remain untouched.

`ShoreBanks.append` emits absolute vertical faces exactly on the native tile
boundary, with native land/retaining material. Call after normal per-cell lifting
and suppress the old water-neighbor riser with`skipRiser`; other terrain risers
remain. Native bridge/underpass authority excludes solid walls across crossings.
The faces meet at corners without extending into either cell's walking area.
Grass cutting does not remove the bank. Characters, Pokémon and flowers retain
their HD-2D paths, and no optional companion is required.

Focused tests cover mixed river/ocean components, multiple datums, existing
recessed pools, author optouts/overrides, absent-bank/full-map stability, wet rock
elevation, exact-layer underpasses, corner closure, original land/material use,
native source immutability and Cut standdown. Existing water and submerged-rock
tests pass. The bounded native integration checks below establish reviewed
scenes; they do not claim complete regional coverage or a performance target.

## Historical fixture correction

The v1.52 wet-rock evidence used Mossdeep21,5 as a positive small submerged-rock
fixture, including24 repeated small-hull checks. That fixture was incorrectly
identified. Native0.3.91 shows a normal solid0x194 rock on an authored, walkable
foamy **shallow shore**. It has no adjacent native surfable water. The surrounding
white foam is original game art and remains in place; applying an animated water
sheet and centering this particular rock below it was incorrect. The previous
geometry checks established a hull midpoint, not valid native water ownership,
and are not relabeled as successful wet-placement evidence.

Small0xC5/0x18C/0x194 candidates now need adjacent native water proof, including
the complete native field beyond a render window. Synthesized boundary water
cannot satisfy this check. Dry copies keep the ordinary closed land hull,
their original blocked footprint and a local native ground donor. Source
metatiles, collision/elevation values and native floor heights remain unchanged.

Native Emerald checks at Mossdeep20,6→21,6 walk successfully; walking up into
the0x194 rock at21,5 remains blocked. OFF/orbit/first-person captures were
inspected and the full native cell digest stayed
`cf2f87ae3520a638879fe72950230e6d4b1a8bfda197166b37b7c296a14e8112`.
The actual uploaded water meshes contain no quad underneath that dry rock.
Its original shallow-water-looking ground is preserved using native donor0x19E.

A public native scan found11 wet placements among36 small-rock candidates in
Emerald: Lilycove65,8 has four genuine water neighbors and is the replacement
positive fixture. Its new rendered/uploaded-hull verification is recorded in
the final batch evidence separately from the historical Mossdeep checks.

## Accepted source integration checks

Official engine0.3.91, its matching AppImage/LÖVE11.5 and the isolated
`engine-water-import` shell used NVIDIA RTX5060Ti/driver615.71.09. The installed
mod was the resource-models source worktree at1.53/cache108, with one disposable
`gen3-<edition>-qa` identity per process. All runs exited0. These are source
checks, not a claim that a later release ZIP was already verified.

- FULL:21 captures each in FireRed/LeafGreen and41 each in Emerald/Ruby/Sapphire
  (165total). Pallet banks/sign fronts, the unchanged recessed Cerulean pool and
  Route24 bridge were inspected in both Kanto editions. Hoenn views cover
  Petalburg banks/signs, Route103 brown/grey sea rocks, Lilycove65,8 genuine wet
  rocks, Mossdeep21,5 dry rocks, the exposed Route10425,15 water/bridge, and
  Fortree31,14 bridge geometry in all three editions. Four orbit directions,
  inspection eye views and bridge underside views were examined. Existing trees
  obscure some eye angles; the corresponding orbit/source views remain the
  evidence for those objects, rather than claiming an unobstructed eye view.
- SKY/OFF:5 captures each per mode in FireRed,15 each per mode in Emerald
  (40total), preserving depressed water and bank geometry with each shader rung.
- Native dry-shore input:4 captures each in Emerald/Ruby/Sapphire (12total),
  including original OFF art, orbit and actual first-person views. Walk20,6→21,6
  and the blocked rock above remain native. Ruby/Sapphire native-cell digest is
  `3bbb8e094a710f2d199020948febf431fbe010fc6772e51a1cb9734dc9e76efc`;
  Emerald is recorded above. No water quad is uploaded underneath the dry rock.

All217 final captures were inspected. Earlier preliminary`full-*` tours that
preceded the dry-rock correction are superseded, and their small-rock counts
are excluded. The native field still reports Cerulean waterY0.05, Kanto exterior
waterY−8, Hoenn riverY−20/9 and seaY−4 where the reviewed native datum permits it.
Other already-lower or raised native datums remain distinct.

Across61 completed scene builds, public producer instrumentation confirmed
37,768 imported bank-face geometry/UV checks against actual uploaded Mesh
vertices,912 native bridge/underpass wall exclusions and1,286,831 unchanged
cell-field snapshots (including emitted boundary cells). These are repeated
build checks, not unique placements. Hoenn wet-rock audits cover37 builds,
9,659 wet-cell sheet checks,2,411 complete closed-hull midpoint/footprint checks
and15 **genuine** small wet-hull checks, including Lilycove65,8. Every audited
hull straddles its actual depressed uploaded sheet; the counts exclude dry
Mossdeep candidates after standdown.

The three bundled bank PNG hashes remain identical to the downloaded sources;
7,744 UV-texel checks include the fully opaque stone-only coastal window.
Bare cliff/cave faces use original stone rows36.5–49.5 from the same sea image,
leaving the grass rim on grass-topped banks. The full native cliff source and
the corrected first-person stone foot were inspected. Original native land,
shallow foam, collision and tile footprints remain; actors/Pokémon/flowers stay
HD-2D. These checks do not assert new walkable underpasses, full-city ORAS art
parity, physical Android verification, multiplayer coverage or a frame-rate gain.
