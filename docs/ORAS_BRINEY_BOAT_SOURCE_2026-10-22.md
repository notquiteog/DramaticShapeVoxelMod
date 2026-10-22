# Original ORAS Briney boat — 2026-10-22

OrasBoatData returns one SceneryModels definition, registered by its caller as
oras_briney_boat. It contains the genuine com_bm_boat01 from local ORAS
a/0/2/3 BM0086 slot0, with hagiship_01/02/03 decoded from AD0010 slot1.
The matching AD0012 copies have identical decoded RGBA hashes. Raw game files
and external decoder checkouts remain outside Git; the importer requires both
explicit source BCH paths and explicit n3ds_importer/Nitrogen checkout roots.

All eight source bones have identity rotation and unit scale. Their accumulated
translations exactly match independently decoded stored inverse binds. Both
decoders also agree on every position, UV, triangle index and rigid bone palette.
The exporter rejects nontranslation poses, weighted blends, changed inverse
binds or mismatching independent geometry. All936 original structural triangles
and original texture pixels/repeating UVs remain. The separate66-triangle hamon
water/ripple sheet is excluded; the native water and wake retain ownership.

The original lower hull has an open planar18-vertex keel rim. Sixteen triangles
close that exact underside, inside the original source bounds, using an actual
lower-hull bottom-edge texture sample. Deck, cabin, real openings and original
faces remain intact. Source and completed side/front/rear/top/underside views
were rendered and inspected outside Git.

The user's requested lighting cleanup sets exported vertexRGB to1 while retaining
original vertex alpha. This removes baked AO from223 of912 source structural
vertices, including the harsh black cabin rear. Painted navy/black trim and the
original texture windows remain. Provenance records the original color-stream
hash/range/count and decoded texture hashes. No generated/repainted texture is
used. Original PICA lighting/TEV and skeletal/texture animation are not emulated;
the source bind pose is used.

Canonical bow is+Z; Y remains up. Normalization uses the original longitudinal
span134.4271330823 with a rigid quarter turn and uniform division. The hull
minimum isY0; anchors.waterline is{0,0.04909797515613,0}. A32×32 fit with0.25
padding yields uniform scale31.5, waterlineFitY1.5465862, and X/Z bounds inside
the original native slot in all four headings. Subtract the fitted waterlineY
from the native water surface when positioning the boat. Native graphics88,
travel positions, heading, scripts and actor collision remain the caller's
responsibility. This commit adds no scene or gameplay hooks.

Passed: deterministic external-source re-export/PNG/metadata comparison; strict
pose, weight, inverse-bind, position and UV rejection tests; source-input
immutability; source-bounded closed keel; transparent-water-sheet exclusion;
vertex-alpha/RGB policy; all four32×32 fits; source waterline and draft.
Native0.3.95 actor, reflection and travel acceptance belongs to scene integration.
