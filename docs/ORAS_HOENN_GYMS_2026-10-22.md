# Genuine ORAS corridor Gym assets and guarded adapter

Prepared from the user-supplied Alpha Sapphire RomFS using external
n3ds_importer and Nitrogen decoders. No ROM archives or decoder code is bundled.
`tools/import_oras_gyms.py` takes explicit extraction, decoder and output paths.
Processed PNGs and provenance are in `assets/scenery/oras-hoenn-gyms`.

GR0007 world02_02_02 contains the Petalburg Gym. GR0022 world03_04_07 and
GR0033 world04_03_04 contain the same actual Gym physical geometry with town
translations; topology and UVs match, maximum positional differences are recorded
in provenance. Retains1040 original physical triangles in five material parts.
Omits the two-triangle nonphysical glow sheet. Adds16 underside triangles using
exactly18 original bottom-rim vertices/UVs, preserving angled corners and the
concave entrance. Source paint/PNGs survive; vertex exposure RGB is omitted.
Possible lighting painted into textures has not been globally recolored.

GR0008 world02_02_03 supplies the actual separate Gym notice:191 original
triangles, plus four triangles closing its two exact leg bottoms. Its open leg
gap, original front, back and lettering remain. The notice asset is registered
through `Gen3ImportedGyms.register(noticeId)`, but its native two-row source
selector/ground handling is not yet implemented. It is not counted as runtime
sign coverage. Emerald source probes locate native sign bottoms Petalburg
(17,10) MID131, Dewford(11,16) MID210, Rustboro(23,19) MID2D4 (hex).

`Gen3ImportedGyms.eligible/build` validates exact native family/map/coordinates,
MIDs, permissions, ownership and body level. It supports only the three reviewed
corridor Gym families. Uniform fit within96×64 has source extent79.5000×57.0123,
with source entrance at56/54. The full fit bounds are approximately
16.2500/5.6634 to95.7500/62.6758. This leaves the native projected rear row and
walkable front-row lawn cells untouched. All physical projected triangles are
clipped against native cells; checking vertex positions alone is insufficient.
The source underside is .05units below native ground, and doors share that base.
Native collision, native floors, scripts and warp at x+3/y+4 are unchanged.

BM0010 com_bm_gymdoor01 supplies the actual split hinged doors:60 physical
triangles across panels and glass, original +/-90degree source hinge tracks
sampled at0/2.5/5. Omits24 light-effect triangles. Nitrogen independently checks
positions, UVs, triangle indices and stored moving-bone inverse binds. The
n3ds_importer rigid-glass fallback incorrectly assigns its mixed-palette glass
entirely to the left hinge; the exporter instead reads independently decoded
per-vertex palette indices (10left/8right). Three cached mesh-state arrays retain
proper panel/glass binding and never rebuild per frame.

`Gen3GymDoors` exposes build/commit/release/ownsDoor/state/draw, mirroring the
Dewford helper; success marker is `g.importedGymDoors`. Body and door source
failures unwind new resources and retain native fallback. SceneryModels owns
textures; the helper releases only its cached meshes. Parent integration must
route Gym building candidates, draw helper states in opaque/shadow passes,
release them with scenes and bypass the matching native door effect only after
successful atomic preparation. Existing Gen3ImportedHoenn routing remains
unchanged until those Scene hooks are ready.

## Evidence and remaining acceptance

The external exporter ran successfully and independently compared original
sources. LuaJIT `gen3_imported_gyms_test.lua` passes nine family/edition candidate
fixtures, physical closure counts, exact warp anchors, all three source door
states, triangle walking clearance, missing-source rollback and resource release.
These candidate fixtures do not prove native gameplay acceptance in all editions.

Official0.3.95 native Emerald flat/front source captures were inspected for all
three towns, confirming actual Gym drawings, irregular blocked footprints,
walkable lawn/sand/paving corners and separate notices. Original ORAS source
front, sides, rear and underside were rendered and inspected. Final post-Scene
native front/first/side/rear and actual entry/return in R/S/E are still pending;
this source snapshot is not a claim that modern Gyms/notices are active in the
published build. Final native notice two-row art/floor guards remain pending.

## Paired native notice adapter — 2026-10-23

`Gen3ImportedGymNotices` now recognizes the exact two native drawing cells and
original indexed-art identities in all nine R/S/E corridor placements. Source
metatile entries prove that Petalburg130/131 contain grass1 underneath,
Dewford208/210 contain sand121, and Rustboro2CC/2D4 contain paving2BB. This is
not inferred from neighboring tiles. `native-notice-proof.json` records both
edition-specific native indexed signatures and original grid hashes; the
read-only `tools/audit_gen3_gym_notices.py` reproduces it from imported caches.
The real source notice fits wholly within the blocked lower16×16 footprint.
Only successful complete mesh upload marks both drawing cells for replacement;
any source, ownership, permission, height or upload failure keeps native art.

Latest official release rechecked on2026-10-23: v0.3.95. Isolated official Linux
shell/native engine verified all nine placements with actual imported tilesets,
GPU mesh upload, wrong-source/permission/height rejection and atomic failed-upload
rollback. Reusable driver: `tools/qa/hoenn-gym-notices.lua`. This verifies the
adapter and resource lifecycle, not final Scene drawing or user interaction.
Parent Scene must call build before terrain under modern props, then draw the
returned batches normally and use `floor(c)` for both marked cells instead of
the full original art. The pre-existing Gym body/hinged doors still need parent
Scene integration and final native exterior/entry/return inspection.

Notice ground-overlap correction: only the two authored horizontal leg-bottom
caps upload0.05units below the original native floor. All191 original triangles,
source legs, fit bounds and original ground anchor are unchanged. Original cap
metadata is retained; the adapter copies only the uploaded eight cap vertices.
Official0.3.95 native R/S/E checks verify all nine notices upload exactly eight
below-floor cap vertices, while the original notice minimum stays at zero;
source/permission/height guards and atomic failed-upload fallback still pass.
Final native Scene visual/interaction acceptance remains separate.

Shared contact-ring follow-up: Gym/Mart bodies now use `groundInset=.05`;
only sourceY0 vertices recess. Original body placement, upper geometry and
portal anchors stay at their exact source/native base. Gym doorY0 vertices use
the same inset; upper door vertices remain exact. All nine Gym and nine corridor
Mart native0.3.95 upload/state/rollback fixtures pass after this change. Notice
and Oldale home cap-only uploads remain separate and are not inset twice.

## Actual Petalburg Scene ownership correction

The integrated0.3.95 Scene already claims Petalburg130/131 as the native
`hoenn_field_gym_notice` two-row prop before preparing modern notices. Simplified
source-cell fixtures missed that owner and therefore previously passed while the
real Scene reported zero modern Petalburg notices. Actual Scene cell inspection
reproduced this in an isolated engine/profile.

The adapter now permits only that exact shared16×32 legacy owner, original
recipe/rows/pair/variant, location and source signatures. All other prop owners,
mismatched top/bottom owners, changed width or hidden legacy props are rejected.
Only successful complete source upload marks the old prop. The facade's new
`ownsProp(p)` lets Scene suppress that exact legacy geometry after success.
Native ownership and fallback source data remain intact. Actual integrated Scene
preparation now reports one notice in each R/S/E Petalburg, with source/owner
rejection and failed-upload marker rollback passing. Reusable driver:
`tools/qa/hoenn-petalburg-notice-owner.lua`. Final combined visual acceptance
requires the Scene props loop to use `ownsProp`; source-count success alone does
not prove that duplicate legacy geometry has been suppressed.
