# Gen3 native model coverage — ongoing

This checklist records inspected models, not inferred coverage from tile
classification. FireRed/LeafGreen/Emerald full-world coverage is unfinished.
Collision, native metatile IDs, warps and player saves are not modified.

## Verified batch: Mossdeep Space Center

- Complete 9×8 native building pattern; original facade and glazing.
- Closed two-wing shell, side/rear window bays, solid piers and cornices.
- Recessed native doorway, 24px headroom and aligned native door animation.
- Raised circular roof apparatus, concave dish, faceted central rocket,
  red lattice launch gantries with solid braces, separate short equipment frame.
- Exact complete 6×6 projected rocket/gantry pattern restores native water and
  grass beneath the original projected drawing. Incomplete/other patterns remain
  unconsumed; c.mid/collision/elevation are preserved.
- All geometry remains within the native blocked 9×8 building footprint.

Evidence: engine 0.3.52, existing isolated `emerald-port-emerald-qa` identity,
`/home/admin/Projects/.scratch/coverage-20261004/results/emerald-space-center-review`.
Native map and enlarged source composite inspected; production front, right,
rear, left, eye-height and native door animation captures inspected. Daytime
fixture uses actual production meshes with a controlled inspection camera.
This is appearance/geometry evidence, not normal input traversal evidence.

Focused tests: `gen3_space_center_test`, `gen3_civic_test`, `gen3_hoenn_test`,
`gen3_scene_cache_test`. Real-map building footprint census: Emerald 58 recognized
assemblies, zero low faces overlapping the central 8×8 of collision-0 cells.
This bounded audit does not establish universal collision safety or coverage.

## Next batches (source review required)

- [ ] Lilycove specialized exteriors: department store, museum/contest buildings.
- [ ] Rustboro Devon building and Slateport specialist buildings.
- [ ] Remaining Emerald city/facility structures and unusual foliage.
- [ ] Remaining FRLG specialized exteriors and interior/furniture families.
- [ ] FireRed dedicated runtime verification (shared FRLG code alone is not it).
- [ ] Exhaustive original-art census, with first-person/orbit evidence per family.

## Verified batch: Rustboro Devon Corporation

The complete 10×9 original drawing now has a raised central tower and lower
wings, original mosaic roofs, pointed windows, three facade storeys, parapets,
solid pilasters and a shallow winged medallion. Side/rear elevations continue
the native window vocabulary. Both native entrance cells retain separate door
surfaces and 28px headroom. The wings end before the front walking strip;
those exact native pavement cells retain their original source pixels.

Production evidence: same isolated Emerald engine/profile as above,
`results/emerald-devon-review`; source composite plus four directional, eye and
native door captures inspected. Focused Devon/SpaceCenter/Civic/Hoenn tests pass.
Emerald footprint census now recognizes 59 assemblies, zero flagged low faces.
The Space Center's entrance tunnel also gained a closed rear panel, avoiding
an unintended view through the entire building when the entrance is open.

Rustboro's other houses, Lilycove specialists and Slateport specialists remain
pending. These two individual buildings do not establish family-wide coverage.
