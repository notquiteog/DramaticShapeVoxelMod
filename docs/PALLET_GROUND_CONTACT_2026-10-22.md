# Pallet imported building ground contact — 2026-10-22

Actual native0.3.95 FireRed captures reproduced broad horizontal/triangular
grass/grey striping at the modern HGSS player-house foundation. This was
independent of the Oldale roof-header double draw. Pallet's clean native
ground296 has no upper-layer pixels and matches the original house-header
underlay. Littleroot's native house kit did not reproduce this defect.

Both Pallet homes had16 original flat h_kage shade triangles at localY0, while
their authored closed-underside caps also lay atY0. Native ground occupies the
same plane. Camera movement exposed competing coplanar faces.

Gen3ImportedKanto now places its three Pallet models0.05 world units below
their native ground datum, keeping the closure below terrain. Only source
h_kage parts proven flat at localY0 receive a0.001 normalized vertical offset;
at the homes' fitted scale76, their shade is0.026 world units above native
ground. Original source opacity0.2903226, PNG bytes, UVs, X/Z footprint and all
rigid source geometry remain unchanged. Oak's vertical source shading receives
no local adjustment. The door surface follows the same model placement base.
Native groundHeight, floor fields, collisions, elevations and warps stay intact.

Native0.3.95 with its bundled Linux LÖVE shell: isolated copied FR/LG profiles,
both houses and Oak, MODERN3D and NATIVE VOXEL, original flat comparison,35°,
first person, low view, slight yaw, rear and left views. Modern foundation
striping disappeared; native voxel remained independent. All runs retained
native map hash030b91f9b950053655cc2851b566449a6bde3cbb3c3832bc5bebcf6cc3d36b02.
The native adapter tests verify below-ground closures, above-ground flat shade,
unchanged vertical source shading/UVs, original input definitions, exact portal
placement, footprint guards and missing-resource fallback. Shared scenery tests
also pass. Captures and source audit intermediates remain outside Git.

Separate limitation: Oak's original vertical translucent source shade retains
its prior facade stippling; this ground-contact change does not modify that
source decal or introduce a global rendering bias.
