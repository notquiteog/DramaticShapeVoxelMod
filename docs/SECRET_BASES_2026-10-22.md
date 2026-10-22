# Native secret-base 3D adapter — source audit

The native R/S/E maps contain 24 secret-base templates per edition: four layouts
for each red, blue, brown and yellow cave, shrub and tree family. They were
previously rejected because their primary tileset is `secret_base` and map type
is 9. Enablement is restricted to these six exact secondary tilesets and native
map type; unrelated primary/secondary names still stand down.

## Source inspection

Official 0.3.95 native QA profiles were used to inspect six original flat rooms
and their public native atlas per edition, plus all 72 cell grids, permissions
and warps. The 24 template grids, dimensions, pairs and warps match across
Ruby/Sapphire/Emerald after removing edition-prefixed IDs: canonical JSON SHA256
`cb39427daabdd1a58d66e50260d815916ec501ce1064e6bba8e361edb7651b3f`.
No source pixels or generated map caches are committed.

The source cave walls use the regional coloured rock art; shrub/tree walls use
native foliage. The tree floor is timber, shrub floor is earth, and cave floors
retain their own rock texture. Native wall outlines are irregular and include
narrow corridors, inward corners and offset exits; a rectangular house shell
would cut through several layouts.

The exact reviewed blocked wall IDs are `201,202,203,205,207,209,20B,20D,20F,
210,211,212,213` (hexadecimal). They use the existing continuous closed terrain
model, native cap `210`, clean native face `202`, native floor `20A`, and shared
32-unit height. Wall copies require original blocked permission 7. Native floor
`20A` and exit `204` remain at floor level; the exit retains native permission
`72`. Neither collision nor warp data is mutated.

`220` is a separate closed native-art PC with monitor, sloped keyboard and base.
`20C`, immediately behind the native exit warp, becomes a closed 32-unit frame
with a clear 12-by-24 entrance. The exact blocked pit drawings `222/223` use
their native charcoal pixel masks to retain the original rim, recessed bottom
at -8, and vertical sides; shared pit edges stay open. Their presentation bounds
stay inside original blocked cells. Unknown decorations retain native artwork.
The native walkable stones `20E/214` retain their floor clearance; this is not a
claim that every possible user decoration has a new furniture model.

Per edition the original templates contain 1628 modeled wall cells and 62
modeled PC/frame/pit cells. Every blocked permission-7 template cell has an
actual geometry path; none is counted through a flat fallback. The other 1444
cells retain native floor/warp/walkable art.

## Integration contract

`Gen3SecretBases.shape` is called before Hoenn's general classifier.
`Gen3Tilesets.supports` admits only the six reviewed families and map type 9.
`InteriorDiorama` uses a 32-unit ceiling and foundation, with no additional
rectangular walls across the native contours.

The coordinating scene adapter must:

- Route `shape.kind == 'secretBaseProp'` to
  `Gen3SecretBases.append(cells, c, emit, uvFor)`. This function owns its floor;
  apply the normal cell elevation to emitted vertices.
- Merge `Gen3SecretBases.openings(cells)` into the diorama's existing floor
  openings so its foundation does not fill the modeled pits.

The other walls already use the existing cave-wall terrain path. No imported
models, engine callback replacement, dependency on another mod, actor changes,
wallpaper baked into furniture, or gameplay changes are introduced.

## Verification state

The source audit ran in official 0.3.95 LÖVE 11.5 on NVIDIA OpenGL 3.3. Source
flat rooms and six family sheets were inspected for all three editions.
New LuaJIT tests verify all family/collision guards, separate bounded PC,
entrance clearance, real pit depth/sides and suppressed rectangular walls.
Existing terrain, room/diorama and generation-adapter tests pass (adapter test
needs the official engine module search path). LuaJIT compilation and whitespace
checks pass.

The new code still requires the coordinating worker's scene integration and
native 3D visual/warp tests. Source inspection and mocked geometry tests do not
constitute in-game visual acceptance or physical-phone verification.
