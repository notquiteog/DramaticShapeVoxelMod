# Genuine ORAS Center doors — 2026-10-22 hotfix

The previous imported-Center doorSurface projected a14×16 native RSE animation
quad at a fixed height in front of the ORAS arch. It used the wrong artwork and
scale while the ORAS source doorway remained underneath. Native warp behavior
was not the problem.

The public292908 Center OBJ contains the arch, threshold and recessed gray
hallway backplane, but omits the separate moving door object. The genuine object
is Alpha Sapphire BM0008 slot0, com_bm_pcdoor01, from a/0/2/3. Its slot1 contains
the original six-frame opening animation. AD0008 slot1 from a/0/1/4 supplies
pokecen_mado and pokecen_door: the actual source glass and lower trim textures.
The gray292908 backplane remains hallway background; it is not repainted or
split into a fabricated door.

The helper retains all eight original triangles from the two moving panels,
including their different glass/trim depths. Each vertex has exactly one bone
with weight1. Composed source parent/local TRS was independently checked against
Nitrogen's stored inverse-bind matrices; moving-bone maximum error is0.0. Source
UVs are retained with one bottom-origin→top-origin V conversion for the PNG
renderer. The optional original floor-light effect is excluded. No emulator,
external decoder or RomFS access is needed at runtime.

The original left/right Hermite tracks are sampled at source frames0,2.5,5:
closed, half-open and open. Their X shifts are approximately0,±7.545,±15 original
units. Native door frame0/1/2 selects those cached states; no helper advances the
engine animation, sound, scripts, input or warp. No matching animation means
closed. The same draw callback works for opaque and shadow passes.

The original292908 inner aperture is30.242005 wide×44.103495 high. Both source
panels receive one uniform scale into that aperture. Position comes from the
already shifted imported Center fit and its original doorway anchor; the doors
sit just behind the original arch/front wall so opening leaves slide into the
side pockets. Every vertex in all three poses remains inside the original64×48
body below the native roof-overhang row. The doorway/warp coordinate stays at
cx+1,cy+3, including elevated/water-supported placements.

Gen3CenterDoors.build(g,fit,newMesh) returns three cached arrays and sets
`g.importedCenterDoors` only after all door uploads succeed. A separate pending
owner enters BuildBudget before any upload can yield; commit(g) untracks it only
after the Center structure is also complete. release(g) frees meshes, never the
shared SceneryModels textures. There are no per-frame mesh uploads.

Gen3ImportedCenters.build now uploads doors first, then the structure. A missing
source/PNG, partial upload, cancellation or structure failure leaves the scene's
older parts intact and g.importedCenter unset, with all newly created meshes
released. The ordinary native building remains the honest fallback. Scene integration draws these source states in the opaque/depth/shadow pass,
releases them with each Center, and skips native doors.draw only when the matching
importedCenterDoors is ready.

Passed mocked LuaJIT checks: original panel UV/shade, left/right source movement,
all-state body bounds, default/matching native frame selection, shared-image
ownership, partial and suspended-build cleanup, structure-failure rollback and
missing-source native fallback. Existing Center fit/permission tests pass. Source
glass/trim atlases were inspected. Parent reports official0.3.95 Emerald actual
entry/return all three states, unchanged native tile hash, first/side/rear/2D
captures inspected; final native acceptance/release evidence belongs to its
isolated hotfix batch.

Rebuild with tools/import_oras_center_doors.py using explicit local model,
animation, texture BCH files and explicit public decoder paths. --source-tools
points to the separately supplied oras_scenery_source.py audit tool; --decoder
and --nitrogen identify the external public decoder checkouts. None is bundled
or imported by runtime code. Hashes, original tracks and provenance are recorded
in assets/scenery/oras-center-doors/provenance.json. Raw ROM/model intermediates
and screenshots stay outside Git.

## Native acceptance for1.57.2

Latest official engine checked October22: Gen1Recomp0.3.95, published October21
02:42:51UTC; native LÖVE11.5/OpenGL3.3/NVIDIA615.71.09 on RTX5060Ti. Separate
QA engine mounts only Battle Art; disposable per-edition profiles use existing
imported user data. Fixtures create fresh games without touching player saves.
Historical0.3.91 test-only driver helpers are not the running engine.

Before: Emerald Oldale shows an empty gray entrance at rest and the small native
RSE blue door during opening. After: original ORAS glass panels fill the arch and
slide behind its side pockets. All46 existing Hoenn Center placements render;
all metatile/collision/elevation hashes remain identical. Actual native input
enters and returns through Oldale in R/S/E plus Emerald Pacifidlog and Battle
Frontier, capturing frame0/1/2 for opening and closing. The initial exit frame2
occurs during the native fade; visible opening poses and returned closed doors
provide the unobscured source comparison. No engine callback/timing was replaced.

First-person front, left/right, rear and destination interiors were inspected
for all five fixtures. Emerald additionally verifies native-model fallback when
the new PNGs are missing and unchanged flat2D. Default actors/flowers and native
UI remain untouched. Initial390 suites pass,0 fail,58 explicitly skip unavailable
external fixtures. The final merged snapshot includes the concurrent main XD and
streaming/effect-cache fixes; its escalator fixture now loads the actual pool
module.526 production Lua files compile with native LuaJIT2.1.
The SDK test harness combines official0.3.95 modules with historical test-only
helpers missing from the official release. Physical phones are untested.

Scratch evidence: /home/admin/Projects/.scratch/center-doors-20261022/.
verify.lua/run.sh drive before/after, entry/return and missing-source checks;
census.lua drives all46 placements. Camera35 for fronts/animations and1ST with
8-degree pitch for other views; day,16-cell view distance, QA-only haze disabled.
Render/stream failures and native-hash changes are fatal assertions. All owned
processes exit normally. Final ZIP integrity, mounted source hashes and native
smoke checks are recorded with the release.
