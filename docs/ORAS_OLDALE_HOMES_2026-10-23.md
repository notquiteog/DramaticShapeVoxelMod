# Own authentic ORAS Oldale homes and hinged doors

GR0004 `world01_02_02` contains the actual northwest and southeast homes. Whole
original triangles from `t102_01`/`chip_mado` are selected with explicit closed
source bounds; crossing triangles are rejected. All1024 body faces survive per
home. The northwest six-face and southeast fourteen-face glass are distinct
original variants, not inferred rear/front windows. Every original position,
UV and triangle index is independently checked against Nitrogen. Source vertex
exposure RGB is omitted. Original static AD0008 slot11 paint remains unchanged.
Other source terrain, fence components, flowers and actors are excluded.

The actual28-point bottom rim closes each underside with26 triangles. Authored
caps sample a reviewed solid original foundation texel; they do not project
facade vents across the underside. Original bodies contain no horizontal y0
floor triangles. Only the uploaded authored cap vertices move0.05units below
native floor. Original body/door positions, source anchors and ground remain
unchanged. There is no duplicate source lawn or ground plane.

BM0003 `t102_bm_door01` supplies84 physical triangles, including actual glass,
and the original six-frame -80degree hinge motion. Closed/half/open states use
source0/2.5/5 samples. Bone/vertex ownership and moving inverse binds are checked
independently. Door and body glass come from their separate native texture banks
(they have different original pixels). The24-face nonphysical light effect is
omitted. The original25-unit panel overlaps the24-unit opening under left trim;
its original right edge aligns with the original frame, without flattening or
scaling the panel separately.

Adapters accept only the six exact native R/S/E Oldale placements, original
MIDs, hard-blocked body cells, level, owner, region and native doorway. Uniform
fitting keeps all source triangles and all animated door states inside the
three native body rows; the rear drawing row stays clear. Native x+1/y+3 warp,
collision, scripts and original floor remain engine-owned.

Latest official release rechecked2026-10-23: Gen1Recomp0.3.95. All six native
source drawings were inspected. Isolated official Linux native mesh upload,
all hinge states, exact below-floor cap upload and failed-upload atomic rollback
pass in R/S/E. Source front/sides/rear/top/underside renders were inspected.
Lua regression covers all six candidates and native walking clearance. Driver:
`tools/qa/hoenn-oldale-homes.lua`.

Parent Scene still must route `Gen3ImportedOldaleHomes.build` and draw/release
`Gen3OldaleDoors` for successful `g.importedOldaleDoors`, using its `ownsDoor`
only after successful complete preparation. Final native front/first/side/rear,
all-angle ground-depth review and actual entry/return remain pending integration.
This source/adapter batch is not a whole-map or published visual acceptance.
