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
