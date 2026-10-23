# Source-matched Viridian/Pewter Gyms — 2026-10-23

The two genuine regional sources are `to_gym_001-mesh` with
`gym_door_007-mesh` from [HGSS Viridian City](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/),
and `nbc_gym_001-mesh` with `gym_door_005-mesh` from
[HGSS Pewter City](https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592849/).
Both scenes were submitted by Kuramapika1 on September1,2026; original game art
is Nintendo / Creatures / GAME FREAK. The actual source badge colors distinguish
these regional variants. Other Kanto or Sevii Gyms are not substituted.

`tools/import_hgss_kanto_gyms.py` reproduces the original274 physical triangles
per regional source, excluding11 baked shadow triangles. Fifty-four authored
triangles close measured rear wall/belt/roof cuts, both roof soffits and the
foundation; total328 includes the independent8 source door triangles. Rear
wall and blue-belt caps sit0.015 source units behind their original cut edges
to prevent coplanar internal faces. Side-wall gray, belt blue and roof brown
come from measured original UV islands. The original roof silhouette, openings,
windows, columns, emblems, glass, PNG bytes and source local proportions remain.
No other town objects or ground are included.

`Gen3ImportedHGSSGyms` requires the complete original6×5 Viridian or7×5 Pewter
native drawing, every original permission, flat blocked body cells and original
civic ownership, with no hidden/boundary/prop conflict. The model occupies the
original blocked-cell union, including its native entrance tile and excluding
the walkable rear header and front corners. A source-preserving uniform fit
places its front door at localX56/Z49 relative to the blocked body origin,
which is1px inside the native entrance tile. AtZ54, the broad source front
columns would enter the walkable corners; the real source mask test rejects
that placement. Every source vertex and triangle is checked, using the existing
`Gen3ImportedGyms.clearance` triangle/tile clipping implementation. No source
building is stretched, flattened or trimmed to pass that mask.

`Gen3HGSSGymDoors` retains both curved source panels and all original8 triangles.
Native frames0/1/2 drive explicitly authored inward paired hinges at0/45/90
degrees; this is not an extracted HGSS animation track. Every pose is checked
against the same native permission mask. Missing images, partial upload failure
and cancelled scene construction unwind all temporary door meshes and preserve
native fallback. The static body never keeps a duplicate closed door behind
open animation frames.

## Building/ground contact

Both new Gym fits and the new Pewter-house fit explicitly use
`groundInset=.05`, provided by shared commit0fb2b673. This moves only the
source Y0 contact-ring vertices below native ground, including the matching
edges across source parts. Anchors, physical upper geometry, UVs and the native
ground are unchanged. It is not a whole-building translation.

Native FireRed before/after first-person views at the same Viridian fixture
showed fine ground striping between the original front columns before the
inset and clean contact afterward. LeafGreen independently rendered clean
contact. Closed/half/open source doors and real held-input entry/return still
passed after this change. The rear wall/roof separation fixes and the ground
contact fix address different coplanar surfaces.

## Native evidence and integration

Latest official runtime checked again: v0.3.95. The official Linux source and
LÖVE11.5 shell rendered both cities in FireRed and LeafGreen with isolated QA
profiles, Mesa llvmpipe and no companions. Default, first-person front/left/
right/rear, native2D, all source door frames, native interior and final returned
field captures were inspected. Both original Gym warps and return warps worked;
metatile/collision/elevation hashes were unchanged. The near-door fixture is a
QA teleport; it does not certify normal progression past Viridian's NPC/story
access. Missing-image LeafGreen fixtures retained native buildings and both
native warps. Drivers emitted PASS; shell shutdown returned1, not process0.

The reusable driver is `tools/qa/frlg-imported-exterior-review.lua`, with
`QA_FAMILY=gyms|houses`, an explicitly supplied `QA_UTIL` helper and a disposable
identity ending `-qa`. `QA_QUICK=1` omits side/rear camera inspection only;
`QA_MISSING_ASSETS=1` exercises source failure. At the end of this Gym batch the per-map source ledger
recorded25 eligible and107 unmatched assemblies per edition, with4 inspected
placements per edition. Later batches update the canonical ledger. It remains an inventory, not whole-game acceptance.

Production Scene remains parent-owned; native QA used a scratch overlay. Hooks:

- Cache successful `Gen3ImportedHGSSGyms.build(g,cells,newMesh,sceneryParts)`
  groups as `importedHGSSGyms`. Keep the complete native Civic fallback on false.
- Draw `Gen3HGSSGymDoors.draw(g,nativeAnim,draw)` in the ordinary opaque/depth/
  shadow pass and release its poses during scene teardown.
- Suppress a native animation card only when `ownsDoor(g,x,y)` returns true.
  Engine input, timing, sound, collision and warps stay authoritative.
- Expose `performanceSnapshot().scenery.hgssGyms` for the reusable QA driver.

The focused regional suite tests exact source/permission guards, positive and
negative full-triangle footprint examples, all source door poses, unavailable
images and late upload cleanup. Deterministic conversion re-creates every
output byte from the original local archives. Physical phones and the final
combined production Scene/package remain separate checks.

The preferred parent integration now uses the single
`Gen3ModernKantoBuildings` dispatcher for both verified houses and regional
Gyms. `build` returns `true,kind` only after the selected child completes;
`kind(g)` is `pewterHouses` or `hgssGyms` for per-family diagnostics. `draw`,
`release`, `ownsDoor`, optional `doorSurface` and `chimney` route only active
imported groups. Unknown drawings and failed uploads retain native fallback.
This dispatcher adds no Scene, companion or engine callback dependency.
