# Native retaining masonry parity

WALLS & LEDGES now has a native Gen3 consumer for the vertical retaining faces
of elevated outdoor terrain. WALL & LEDGE COLOR uses the exact shared granite,
red brick, sandstone and slate palettes. The default BATTLE ART choice retains
the source texture. Pillars remain independent and keep their granite finish.

The retaining-course generator was extracted from the Gen1 mesher without
changing its geometry, cave variation, UV or AO inputs. Native cells use the
same four-pixel courses, six-pixel staggered joints and weathered corners, but
inset the relief into the owning high cell. No vertex extends into the lower
walkable cell. Native terrain heights/collision/warps are unchanged. Timber
docks, Fortree bridges, interiors and stage-cleared objects retain native faces.

Inspected on engine 0.3.52 in Emerald's Mossdeep: four palette captures and
BATTLE ART fallback at the same retaining corner. `tools/qa/native-masonry.lua`
provides the fixture. An attempted LeafGreen Lavender run has no qualifying
raised retaining faces; it does not prove FireRed/LeafGreen visual coverage.
The raised tower's separately modeled cliff is outside this adapter's scope.

Checks: deterministic geometry and bounds on all four sides; source palette
sharing; default/interior/timber/bridge fallback; 48 exact before/after Gen1
retaining/cave extraction comparisons; native Yellow Route 4 cave opening and
cliff-corner regression. Other cliff/ledge shapes and wall families remain
partial; this is not full scenery or material parity.
