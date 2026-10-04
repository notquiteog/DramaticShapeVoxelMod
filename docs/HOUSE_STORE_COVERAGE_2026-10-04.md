# Native house and department-store models

Implementation on main, following 1.30.0. No new release in this pass.

## Changes

- Emerald: 15 pair-local recipes for generic/rustic house TVs, bookcases,
  refrigerator, drawers, recessed sink/tap, tables, inward-facing chairs,
  floor cushions and plants. CRTs, shelves, legs, backs and kitchen cases have
  closed geometry; artwork is sampled from the native runtime atlas.
- Crystal: complete department-store bench and vending-machine drawings now
  have authored geometry, retaining the original pink seats and machine art.
- FireRed/LeafGreen: continuous console-demo tables with raised equipment,
  glass display cases, and double-sided stock islands.
- Removed six erroneous single-tile Celadon recipes, including parquet 0x2c0
  being modeled as merchandise. Complete drawings replace isolated guesses.
- Coverage driver now boots Emerald in an Emerald map.

## Evidence

Official Gen1Recomp 0.3.51; isolated QA profiles, six companion mods loaded.
Scratch: `/home/admin/Projects/.scratch/coverage-20261004`.

Native source images were inspected before authoring. Render fixtures captured
fixed overview, rotating side/rear and first-person views in:

- Emerald Oldale House1, Wally's house, Route111 Old Lady's Rest Stop;
- Crystal Celadon Department Store 1F/6F;
- FireRed and LeafGreen Celadon Department Store 3F/5F.

Inspected overview and close/rotating captures; fixtures assert unchanged native
map/collision grids and no Gen3 scene error. Corrected the glass-case crop after
first-person review caught parquet pixels being sampled as case material.

Emerald full-map extraction changed from 50 furnished maps / 1,092 objects to
96 furnished maps / 1,390 objects: **298 additional fixtures across 46 additional
maps**. This counts recipe matches, not visual approval of every map. 519 maps,
75 tileset pairs, 495 enabled scenes. There are 65 Hoenn recipes in total.

Tests: house_department_models, gen3_hoenn, gen3_additional_furniture,
gen3_starting_furniture and gen2_depth_furniture pass. New regression checks
protect bare parquet, all-or-none matching, family isolation, source crop bounds
and nondegenerate closed components. Full standalone suite: 111 pass, 11 known
fail, 85 skip; failure ceiling unchanged. An initial run with the official
engine package path reported 33 failures because it does not ship the required
legacy tests.modkit/harness; standalone result is the comparable baseline.

## Still incomplete

Not an all-world sign-off. Emerald bedrooms, wall decorations, bins, other
furniture palettes, special interiors and most exterior families still need
review/model work. Crystal store wall windows remain generic extrusions;
FireRed store stairs, checkout and wall fixtures need further authored passes.
Other older single-tile recipes also need native-art audits. Inventory treatment
labels alone are not proof of faithful geometry. Battle/network behavior was
not changed or revalidated in this pass.
