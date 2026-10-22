# Optional original ORAS shop blossoms — 2026-10-22

This batch adds optional source geometry for exactly three pink Pretty Petal
blossoms. HD2D remains the default. It does not claim all field flowers, every
source color, or BDSP coverage.

The source is Route104 archive364272, world04_02_06.dae material `_2_0-mesh`,
using the existing original r104_dif03.png. Of its19 living flower/leaf components,
components5,6,9 each describe a pink blossom with a yellow center. Each contains
eight original triangles. They are authored bent textured flower surfaces;
this adapter does not invent solid petals or stems, inflate the texture into a
new flower, or describe their source surfaces as sculpted opaque geometry.

The native shop body fits a96×48 blocked rectangle. Some original source flora
extends in front of that rectangle; restoring every source XYZ would intrude on
the native approach. Only the three selected whole blossoms fit both the
original planter bounds X[133.21,176.84]/Z[163.81,175.79] and the native body.
Every original vertex/UV/shade/RGBA is retained. The existing whole-shop uniform
normalization/fit applies directly; no flower is clamped, moved or stretched.
The three source faces stay in their authored orientation as the camera turns.

Gen3ImportedFlowers.build(g,fit,id,newMesh,parts,options) is connected to the
existing Hoenn shop adapter. It reads VisualStyles.get('flowers') through pcall;
a missing/failed/unknown setting resolves to HD2D. It supports:

- `hd2d`: the existing19 HD2D flower/leaf cards, with exactly the same geometry.
- `modern`: three source blossoms plus the remaining16 HD2D flower/leaf cards.
  Source IDs5/6/9 are excluded from the HD2D mesh, preventing duplicates or
  disappearing plants. Source/mesh failure unwinds the new parts and restores
  all19 HD2D components. If that also fails, the existing caller restores the
  full native Civic building.
- `voxel`: options.nativeVoxelBuild may provide original native GBA sprite
  geometry using the same owner/scene destination. Without a successful native
  provider, the adapter returns an explicit native-source-unavailable error.
  The Hoenn caller atomically rolls back its imported shop and restores its
  native-art Civic building. ORAS-textured cards are never reported as native
  GBA voxel flowers. Actual isolated native shop-flower voxel support remains
  separate work.

The optional provider takes(g,fit,id,newMesh,parts) and returns true only after
adding its scene-owned geometry. Failed/throwing providers have their new parts
released while older scene objects survive. The new source mesh enters the
scene-owned destination before image/upload yields. The existing architecture
provider owns the shared original atlas; scene teardown releases meshes only.

The Cards geometry/build API now accepts an optional exclusion set; omitting it
preserves the previous output exactly. Gen3ImportedFlowers.geometry validates
its exact shop family and original planter/native body bounds before uploading.
The caller's existing complete native drawing, blocked cells, elevation, door
and region eligibility still run first. The source geometry test verifies every
selected blossom vertex against the original native permission matrix, including
its walking entrance tile. No map pixels, permissions, warps or gameplay change.

Passed mocked LuaJIT checks: unchanged default HD2D vertices, original source
XYZ/UV/RGBA and flower identity, all-vertex planter/walking clearance,72 source
indices plus552 HD2D indices matching the original624 total, atomic modern
failure, missing-source fallback, provider failure cleanup, unrelated-family
exclusion and whole-building native fallback for unsupported voxel mode. The
existing shop fit/source/door tests still pass. Source CPU front/quarter/side/
rear/underside previews were generated; front and quarter views inspected.
Native GPU camera/option transitions and door/walking checks remain parent QA.

Rebuild with tools/import_oras_shop_flowers.py and a locally supplied364272 ZIP.
Original archive and previews remain outside Git. Source hashes, component
selection and limitations are recorded in
assets/scenery/oras-route104-shop/flowers-provenance.json. No extra image bytes
or duplicate texture resources are needed.
