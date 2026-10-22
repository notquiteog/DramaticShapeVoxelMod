# Imported source lighting cleanup

The user requested native dynamic lighting/shadows for imported scenery. The
modern `SceneryModels` path now sets `VertexShade` to1 and removes reviewed
vertex-light RGB multiplication; original alpha, XYZ, triangles, UVs, texture
bytes, anchors and blocked bounds remain intact. Native sprite voxel paint is
outside this path and is unchanged.

The current ORAS exposure streams are white/gray/blue across textured surfaces:
Briney's house has881 near-neutral dark and856 blue-tinted vertices, Pretty
Petal1360/711, Dewford445/436, Lavaridge home939/507, herbshop1063/389,
Route104 broadleaf79/68, and Center PC142/0. Blue canopy shadow RGB includes
(.4156863,.6235294,.882353); wood/paint/leaf color comes from the original PNGs.
Both runtime depth-adapted aliases and raw source IDs use this reviewed policy,
including the compact broadleaf and compact narrow-broadleaf derived IDs.
The new source truck also declares exposure RGB through its exact registered ID;
boat and pine source RGB were already neutral. No saturation threshold guesses
at whether an arbitrary provider's colored paint is light.

Unknown providers retain RGB by default. A definition or individual part can
explicitly set `vertexColorRole='lighting'` or `'paint'`; part metadata wins.
Fixed `VertexShade` is always lighting. Original registered input arrays remain
unchanged. Future imported sources must explicitly classify their vertex colors.
The original source flower cards and optional three modern pink blossoms also
use neutral vertex lighting, preserving textured flower identity and alpha.
Their HD2D/modern/native-voxel selection and native fallback are unchanged.

Parts marked `source_shading`, `ground_shadow`, or identified by `h_kage` material
or texture are lighting-only. They retain CPU source slots and canonical bounds
so authored surface indices and fit/portal geometry cannot drift. GPU batches
omit them, including both horizontal and vertical Pallet overlays. Their PNGs
are no longer needed for a successful import. Physical translucent surfaces and
closure caps still upload. A missing structural texture still atomically
releases the new batches and restores native presentation.

The prior Pallet flat-shadow lifting shim is removed. The separately verified
.05-unit closure burial and matching imported door base remain; removing the
shadow does not justify making the physical closure coplanar with native grass.

## Verification

Sixteen focused LuaJIT suites pass: source model/resource ownership, dedicated
lighting/paint/failure cases, actual tree and shallow-tree source fits, Pretty
Petal source/flowers, Lavaridge, Dewford, Pallet, Viridian houses, Hoenn/Kanto
Centers, genuine Center doors, Museum, native signs and scenery drawing.
The dedicated fixture checks missing shadow PNGs never load, missing physical
PNGs roll back without destroying prior scene resources, and explicitly painted
and unknown third-party vertex RGB survive.

Official0.3.95 isolated native driver captures were inspected for FireRed Pallet
Red/rival/Oak front, first-person, rear, side and low/yaw views, plus Emerald
Oldale Center and Route104 Briney house front/first/rear. Removed ground shading
and brighter original brown wood are visible; physical walls, source Center
panels and native lawn remain. Center and pine inputs already had neutral
lighting, so their source materials remain unchanged. Broadleaf neutralization
is verified against its actual arrays and all four bounded fits; this capture's
Route104 tree selection is pine, not a claim of broadleaf native visual review.
The native fixtures retain the prior isolated source checkout's terrain behavior;
parent integration owns current Scene ground and final release verification.

This does not certify that every source PNG lacks painted-in lighting. PNGs were
not globally recolored; possible texture AO requires individual source review.
