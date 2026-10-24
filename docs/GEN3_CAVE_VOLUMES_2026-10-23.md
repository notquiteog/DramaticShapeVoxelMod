# Native cave interior volumes

The official engine release checked before this batch was 0.3.96. Native LÖVE
runs used independent disposable profiles with genuine imports, API3, this mod
standalone, modern interiors and native actors. No ROM pixels, source archives,
profile data or captures are included here.

## Defect and change

Hoenn's regional classifier returned `flat` before the cave vocabulary could
resolve. Granite Cave 1F had 628 flat cells and two ladder cells: the native
rock walls and boulders were painted on the floor in first person.

`Gen3CaveProfiles` now resolves reviewed brown/green cave and shared alternate
rock/ice drawings before that fallback. Exact native palette/cap/face identities
and solid collision are both required. Walkable cap copies, native water,
stairs, ladder behavior and unknown art retain their existing treatment.
Connected walls use the existing shared terrain height samples, giving closed
raised caps and beveled sides within the blocked cells. Boulders surrounded by
solid cap cells sit on that mass instead of cutting a square well through it;
boulders beside a walking lane remain independent at floor level.

The cave emitter drops terrain grid quads that lie entirely at ground height:
the native floor is the sole surface owner there. Ordinary terrain, Scene,
actors, collision, warps, floors, wall heights and source assets are unchanged.
No Scene hook is required.

## Current evidence

- All 2,161 maps have identical native mid/collision/elevation hashes. Furniture
  identities and civic inventories also match (civic order is non-semantic).
- Classification changes 116 Hoenn cave maps: Emerald44 / Ruby36 / Sapphire36.
  New cave-wall cells are 21,032 /14,841 /14,841; independent rocks284 /218 /218.
  FRLG classifications and every outdoor map are unchanged.
- Native final runs PASS 18 edition-map cases: Granite1F, Rusturf, Shoal ice and
  Meteor Falls1F1R in RSE; Moon1F, Seafoam1F and Icefall entrance in FRLG.
  Each asserts identical live native cells/elevations and warp records before
  and after rendering. Native/overview and all four first-person directions
  were inspected, including connected cap/boulder geometry and walking lanes.
- `gen3_hoenn_cave_volumes_test.lua`: 581 identity, dispatch, palette, unique
  floor, cap union, blocked-footprint and portal-lane checks PASS. Existing
  Hoenn, cave palette and all-generation enclosure suites PASS.

`docs/coverage/gen3-caves-2026-10-23/maps.jsonl` records all 116 changed maps,
source-profile hash, native source identifier/hash and before/after family
counts. `native-runs.jsonl` separates actual representative native checks from
classification. Every whole-map rendered acceptance remains false.

## Remaining queue

Meteor Falls retains flat walls, especially its distinct Ruby/Sapphire art.
Its water/stairs/terraces need a separate reviewed profile. Alternate shared
palettes have source-sheet/identity coverage here, not full room visual approval.
The outer cave enclosure still uses the existing generic stone material and
needs native rock finish/depth. Other natural families (volcanic, Navel Rock,
Mirage Tower and Seafloor variants), true interior mouths and further cave floor
relief remain under review. No imported ORAS cave map is claimed by this batch;
original dungeon models were located for the following source/geometry work.
