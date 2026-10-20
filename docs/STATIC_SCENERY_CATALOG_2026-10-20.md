# Static scenery catalog and source building closures

Three user-selected public models are processed into optional scenery data.
The ORAS Pokémon Center and HGSS Oak's Lab are **prepared catalog models**;
they do not replace buildings automatically and add no city/interior coverage.
Native building placement still needs per-map blocked-footprint, door-clearance,
ground, original-art and 360-degree review. The selected BW2 sign has a separate
native adapter; its map/input evidence belongs to that adapter's batch.

| Catalog ID | Original source | Original / processed triangles | Material parts |
| --- | --- | ---: | ---: |
| `oras_pokemon_center` | [ORAS Pokémon Center, Fallenleader / RSRazr](https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/292908/) — June 21, 2015 | 1045 / 1148 | 8 |
| `hgss_oaks_lab` | [HGSS Oak's Lab, CheesyMac nCheese](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/294796/) — November 7, 2015 | 230 / 266 | 15 |
| `bw2_sign01` | [BW2 Sign01, pentaenix](https://models.spriters-resource.com/ds_dsi/pokemonblack2white2/asset/582551/) — July 30, 2026 | 28 / 28 | 2 |

Original game art belongs to Nintendo / Creatures / GAME FREAK. The source ZIPs
and original OBJ/DAE/MTL files remain outside the repository. Selected processed
geometry, original PNG bytes and per-model provenance are under
`assets/scenery/catalog/`; provenance records source pages, archive/model hashes,
texture bindings/hashes, original bounds, normalization and authored changes.
No characters, Pokémon or flowers are converted by this catalog.

## Source fidelity and authored closures

The two source building meshes omit their rear walls and undersides for the
original games' constrained cameras. They were inspected before editing. Added
rear walls follow their original wall-end vertices; roof returns close the rear
cornices, and the Center's rear skylight arch gains a solid inset cap. Closed
foundations cover the underside while the original front door recesses stay
open. Existing wall/roof texture islands supply these faces. No attachment,
lettering, new rear entrance or invented sign is added.

The Center foundation extends 0.05 original units below the original ground
face, preventing a coplanar underside/threshold conflict. X/Z bounds and original
geometry proportions remain unchanged; grounding includes this thin foundation.
Oak's foundation fills the source gap between its shadow plane at Y=1 and body
base at Y=2. The brick UV density follows the source side-wall island. Every
original source triangle and its UVs remain; additions are named `authored_*`
and separately recorded in provenance.

The Center MTL omits texture declarations. Its supplied readme says to assign
the named supplied images to the already UV-mapped materials, so the converter
records those explicit bindings. Oak's MTL references absent `lambert1.png` and
that solid material has NaN UVs. Those two triangles retain source Kd via a
recorded 1x1 solid-color material; no missing textured art or UV net is invented.
The source Kd/dissolve values remain material metadata. The ordinary voxel
vertex format carries albedo/UV/shade rather than full DCC Phong specular.

HGSS `h_kage` includes vertical source shading as well as its ground shadow and
has opacity 0.2903226. A future building adapter must honor its blend/material
pass before enabling Oak. It must not discard that whole part as ground shadow.
The current BW2 sign has opacity 1 parts; its actual ground-shadow card is labeled
`ground_shadow` and can be omitted from a native cast-shadow pass.

## Runtime API

`SceneryModels` uses the ordinary `{x,y,z,u,v,shade}` vertices and index maps.
There are no scene hooks, private-file access, companion requirements or implicit
model placements. Every definition has its own public byte-reader provider.

```lua
local Models = V.require('SceneryModels')
local parts, err = Models.buildBatches({
  {model='bw2_sign01', x=cellX*16, y=localGround, z=cellY*16,
   fit={width=16, depth=16, rotation=0}},
}, V.require('Voxel3D').newMesh, {parts=sceneOwnedParts})
```

Fit is uniform and grounded, with default 0.25px padding inside the caller's
blocked rectangle. Rotation is an integer quarter turn; an optional height cap
also scales uniformly. `Models.fit(id, options)` reports the fit, bounds and
transformed anchors. Buildings expose an authored `door` anchor. For example,
`{width=48,depth=32,anchor='door',targetX=24,targetZ=25}` centers the source
entrance and uniformly reduces the scale if needed to keep every face bounded.
An impossible alignment fails so the native renderer can remain in charge.
These example dimensions are API fixtures, not approvals of a particular map.

`Models.surface('bw2_sign01','message',fit)` returns six new mutable face
vertices, their indices and the rotated outward normal. UVs are local 0..1 so a
native adapter can map its regional sign artwork onto the original board face.
A small positive normal offset avoids fighting the original face; both stay
inside this sign's blocked rectangle. The source catalog does not replace any
regional lettering by itself.

Third-party authors use `Models.register(id, definition, {read=publicReader})`.
A definition contains multipart vertices/indices, PNG paths, wrap modes,
opacity/diffuse/role metadata and optional anchors/authored surfaces. Input data
is copied and validated. Registration rejects duplicates and invalid/nonfinite
geometry. Definitions must be grounded; materials use relative provider paths.
No model asserts compatibility with an unreviewed region or footprint.

Shared CPU prototypes and textures are cached with explicit model, geometry,
variant and byte budgets. PNG dimensions are checked before GPU upload.
`ModelInstances` combines repeated placements; unsupported drivers get a bounded
merged mesh. Unavailable images, shaders/upload capabilities or exceeded budgets
return an error so callers retain native art. Failed image attempts are cached
until reset. Providers retain independent image ownership.

All created batch parts enter `options.parts` before resources or cooperative
budget yields, allowing scene cancellation to release an abandoned build.
Failed appends unwind only their new parts. Call `Models.releaseBatches` when
releasing a scene. Release a provider's batches before `Models.unregister(id)`;
release all batches before `Models.release()` resets the complete resource cache.
Callers schedule opacity/blending and native shadows using returned material
metadata, rather than changing base-game UI or collision.

## Verification and limits

Six Python tests pass with the supplied external archives: negative OBJ indices,
material/group splits, V convention, invalid UV/missing-image/concave rejection,
original texture/UV/triangle retention, rear-plane coverage, bounded authored
surfaces, door anchors and sign-face topology. The Lua suite checks every model
at all four rotations inside rectangular bounds, height caps, asymmetric door
alignment, copied third-party registration, resource caching, instancing/merged
fallback, failure cleanup, negative caching and cancellation during a budget
yield. LuaJIT compile and whitespace checks pass.

The latest official release was rechecked as 0.3.91. LÖVE 11.5 from its verified
package rendered the original and processed models on NVIDIA/OpenGL with the
same cameras and neutral inspection lighting. Front, right, rear, left, front
quarter, low-eye and underside were inspected for all three models: 42 matched
source/processed captures. Building rears/undersides close while their original
front/side silhouettes and doorway recesses remain. The sign remains unchanged.
Captures and original archives stay in scratch; no native building coverage,
Android/GLES hardware performance or global manifold-topology claim follows
from these standalone source-model renders.

Rebuild with `python3 tools/import_scenery_models.py <external-archive-folder> .`.
The static DAE path reuses the grass converter's scene-transform/sampler parser;
its convex polylist and bundled TEXCOORD adaptation is in the scenery importer.
Animated/skinned scenery, concave untriangulated polygons and unsupported vertex
colors fail explicitly. Runtime loading needs only the processed Lua/PNG files,
not Python, original archives, a model viewer or another mod.
