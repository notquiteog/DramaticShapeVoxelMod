# Own ORAS Rustboro homes and school

The dispatcher now supplies original, separate Cutters' house, House1, House2
and school models. The native indexed Rustboro map was rendered and inspected
before adaptation. Native warp destinations identify their purposes. Source
ZO16/AD11/MM4 warp records and original GR object placements independently bind
these doors to BM0013 `c104_bm_door01`:

| Native civic origin | Native door | Own static source | Source world door / destination |
| --- | --- | --- | --- |
| Cutters(7,34) |(9,38)|GR37|(2115,3753)→ZO300|
| House1(31,15) |(33,19)|GR33|(2727,3321)→ZO296|
| House2(28,24) |(30,28)|GR33|(2727,3681)→ZO295|
| School(24,30) |(27,34)|GR33|(2565,3681)→ZO289|

The school/House2 static meshes extend across their original chunk boundary;
their BM door placements are correctly in GR38. The reproducible exporter
checks these original transforms and destinations rather than inferring door
ownership from a material name. Every selected position, UV and triangle is
independently compared with Nitrogen. Native source arrays remain separate even
where the resulting architecture looks alike.

Each home retains614 physical source triangles; the school retains710. Eight
school trim faces have original constant vertex alpha0.6: these are preserved
as a separate physical part at opacity0.6. Source exposure RGB is omitted.
Four school window-return triangles originally overlap the column side faces.
Only those returns are clipped to their exposed Z6.5–7 strip with interpolated
source UVs; all original triangles/paint remain on the exposed surfaces.
Original body models contain zero horizontal base ground faces. Original16/20
bottom-rim points close the home/school undersides with14/18 triangles using a
solid source bottom-wall texel. Shared `groundInset=.05` recesses only Y0 contact
vertices and closures. Native ground, doorway anchors and upper geometry stay
fixed; no source terrain, lawn or fence mesh is copied.

The actual BM13 door retains132 panel and18 glass triangles, original rigid
ownership, inverse binds and the original six-frame hinge sampled at0/2.5/5.
The source door top cap is only0.000015 units above the lintel; only top-contact
vertices recess0.05 native units to remove that near-coplanar overlap in every
pose. Hinges, portals and all other upper vertices remain fixed.
No native animation timer or warp is replaced. Exact edition/map, native MIDs,
permissions, owner, region, level, size and civic family guard each building.
Uniform fits preserve source proportions; full projected-triangle checks cover
every body face and all door states against native blocked cells.

Official latest was checked before this batch: [Gen1Recomp0.3.95](https://github.com/bryanthaboi/gen1recomp/releases/tag/v0.3.95).
Its matching Linux LÖVE shell ran isolated Emerald/Ruby/Sapphire profiles. All12
native adapter/dispatcher uploads, hinge states, native door coordinates,
contact caps at−0.05 and forced failed-upload cleanup pass. Four candidates were
added per edition to the571-map census; native map-grid hashes are unchanged.
Source front/sides/rear/top/underside renders were inspected for all four source
variants. Relevant source/dispatcher and prior Petalburg suites pass.

A separate integrated test used the parent Scene from f24ff378 (Scene blob
09e0b2aee1fdd34f692f69e05e18a9644d40fede) with only this facade/source override
in an isolated mod assembly. All four sources activate simultaneously. All12
actual R/S/E door entries and returns pass; unchanged native map hashes and zero
streaming recovery failures are asserted. Emerald forced missing-source mode
retains all four complete native buildings and passes the same entry/return
checks. First/front/side/rear and opening/returned captures were inspected;
some side views are partly obscured by native trees. Source all-angle views
supplement those obscured views. Visible source door bases and wall/ground
contacts are clean in the inspected first/rotated views. Ruby/Sapphire ground
palette and native grass around House2 remain native.

This is bounded family evidence, not whole-map acceptance. Remaining Rustboro
families: Flat1, Flat2, southern House3, nonenterable tower and Devon. Their
source/placement and visible contact review continue separately.
