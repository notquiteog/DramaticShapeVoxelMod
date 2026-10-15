# Regional Gen3 models and RS houses — 2026-10-15

Runtime: official Gen1Recomp **0.3.88**. The Linux x86_64 AppImage and `.love`
match the release's SHA-256 manifest. Native shell: bundled LÖVE, Bash, Xvfb,
NVIDIA RTX 5060 Ti. Matching official source supplies QA drivers. Existing
private `gen3-{edition}-qa` ROM imports from the 0.3.86 batch were reused with
0.3.88's native providers; these are not newly imported 0.3.88 datasets. No
player saves, ROMs, imported pixels, generated caches or captures are committed.

## Model inventory

`Gen3RegionalTrees` owns/refines these inspected source families. Counts are
placements handled by that module, including Safari roots previously modeled
by the older forest pass; they are not a net count of newly converted objects.

| Edition | Regional tree placements | Claimed solid cells | Walking intersections |
| --- | ---: | ---: | ---: |
| FireRed | 530 | 3,765 | 0 |
| LeafGreen | 530 | 3,765 | 0 |
| Emerald | 289 | 501 | 0 |
| Ruby | 289 | 501 | 0 |
| Sapphire | 289 | 501 | 0 |

- FRLG Berry Forest: original yellow broad crowns, complete repeated/isolated
  native crown groups, closed stems and local lawn. Yellow leaves have their
  own palette rule; green baked shadows no longer color the canopy.
- FRLG Safari: northern overlapping crowns plus existing lower broad groups.
  Water/cliff composites stay native. Each new root owns a complete blocked
  rectangle; incomplete drawings remain in the existing/native path.
- Hoenn Fallarbor/Route 113: native three-lobed crowns and stems, with distinct
  ash (`218`) / volcanic (`279`) grounds. The first attempted `206` underlay
  was rejected during visual review because it contains crown artwork.
- Hoenn Mt. Chimney: ash-encrusted forked stems and broken crown lobes. Narrow
  roots fit one blocked cell; complete wide bases fit their three blocked cells.
  Verified projected walkable caps receive ground without a second trunk.

Models use greedy closed hulls with shared source pixels and separate cached
width/depth variants. Source-art, procedural and optional replacement paths
respect the new widths/depths. Native collision, warps and actors are untouched.
Mesh revision **87** invalidates previous generated geometry. This is not a
claim that every older tree model or every optional style was visually audited.

## Ruby/Sapphire houses

Six independently enabled families add **eight placements in each edition**:
Verdanturf west/east (one drawing), Verdanturf center, Mossdeep west, north
(two placements), northeast and east. Stevens' larger Emerald house drawing
is still excluded from RS; the native RS Steven entrance uses the reviewed
west-family drawing.

Verdanturf RS has an uninterrupted green sheet roof and round windows, unlike
Emerald's ridged green roof and square windows. The new roof is a closed panel;
front/side/rear circular frames join recessed native glazing. Mossdeep retains
RS's timber/slate roof and wider dark glazing, with closed siding around the
unseen elevations. Unseen side/rear window placement is an architectural
interpretation using the original front art.

Every source cell must match. Body cells must be native solid except the
explicit native `0x71` door tile in the last row (`3A1` / `2A1`). Introducing
another walking lane rejects the recipe. The model envelope excludes the
projected rear row and contains roof edges, ridges, frames and sills. Existing
native ground selection continues lawn/paving beneath the assembly.

Final `building-footprint-census.lua`: **65 recognized assemblies, 0 flagged
walking-cell overlaps** in Ruby and Sapphire. That older census samples low
face bounding boxes against central 8x8 cell regions; it is not a universal
collision proof. New unit checks additionally bound every new-house vertex
within its source body rectangle, validate native warp permissions and reject
third-party walking-lane edits.

## Verification and reproduction

Scratch root: `/home/admin/Projects/.scratch/gen3-20261015`.
Official runtime: `/home/admin/Projects/.scratch/runtime-0.3.88`.

- `tools/qa/gen3-regional-tree-census.lua`: exact complete-cell rectangle audit
  across all native outdoor maps in each edition, with unchanged permission
  assertions and identifier-only CSV output.
- `tools/qa/gen3-scene-review.lua`: native source-map loading and safe dry
  viewpoints, four cardinal orbit views plus an eye-height inspection view.
  Forest location previews are dismissed through public engine APIs. The
  driver waits until the streaming start/completion/cancellation counters
  settle and asserts the active scene map and camera. Fixed waits had captured
  an earlier window after a large same-map jump; those captures were rejected.
- `tools/qa/gen3-regional-house-doors.lua`: native upward walking into two
  Verdanturf layouts and the Mossdeep west/Steven entrance, in both RS editions.
  All **six** checks reach the correct interior and retain the selected 3D
  camera without recovery failures. Fixture teleports only set the initial
  exterior approach; the tested entry uses the engine's normal input/warp path.
- Full mod suite on 0.3.88: **276 pass, 0 fail, 58 skip** (external baseline,
  generated-art and other unavailable fixtures; see the suite's skip records).
- Partner focused checks: **16 pass** across all six repositories. Two older
  Wild Skies suites require the absent `tests.modkit` harness and are unavailable;
  the native Gen3 Wild Skies unit suite passes. No partner runtime was changed.

Inspected captures: `fr-final`, `lg-final` (Berry/Safari), `em-red-tree-final`
(Fallarbor final ground/volcanic variant), `em-final` (ash trees),
`ru-final-verified`, `sa-final-verified` (final house variants and Ruby grove),
`ru-east-closed-final` / `sa-east-closed-final` (final eastern rear-wall/window clearance), `sa-houses-final` (final grove),
`ru-final-allmods` / `sa-final` (ash trees), and `ru-doors` / `sa-doors`.
Source sheets and rejected intermediate renders are retained separately in
scratch. The Mt. Chimney eye fixture is close to a native tree/cliff and is
partly obstructed; its four orbit views establish the form. Captures are not
proof of normal keyboard/focus behavior beyond the explicit entry fixtures.

Example (Bash; private imported profile required):

```sh
QA_SPOTS='FR_THREE_ISLAND_BERRY_FOREST,9,11,7' \
  /home/admin/Projects/.scratch/runtime-0.3.88/run.sh firered \
  /home/admin/Projects/DramaticShapeVoxelMod/tools/qa/gen3-scene-review.lua \
  /tmp/berry-review /home/admin/Projects/.scratch/gen3-20261014/profiles \
  gen3-firered-qa
```

## Optional ecosystem and extensions

Fetched all seven `origin` repositories. The current optional partner versions
are Wild Skies 1.15.1, Dramatic Sky Ride 0.5.4, Double Battles 0.14.2,
Gen1 Online Plus 0.11.0, Overworld Wild Spawns 2.6.3 and Modern UI 0.4.1.
Ruby's paired run loads all seven mods without mod errors; solo runs expose
only Battle Art in `mods/`. This is a load/render smoke check, not a new
multiplayer/doubles/capture/flight protocol certification.

The primary manifest still has no hard dependencies. New code reads native
provider art and adds no companion imports or base-UI changes. Modern styling
remains owned by the optional Modern UI provider. Characters, Pokemon and
flowers remain HD-2D. Existing companion provider contracts are unchanged;
see `docs/VOXEL_COMPANION_API_V1_HOST.md` for their actual supported scope.
Third-party maps can reuse the checked native drawings with their original
permissions; changed/partial source groups stay native. New art families still
need authored scoped recipes, native source review and footprint validation.

## Remaining scope

This is an incremental model release, **not completion of all five games**.
The outdoor unclaimed non-walkable census is now FR/LG **6,649** each,
Emerald **11,770**, RS **10,481** each (previous 8,815 / 12,271 / 11,081).
Those counts include legitimate flat/non-object surfaces and partial/composite
art; they are a triage queue, not a missing-object count.

Remaining targets include Route 23/Indigo architectural walls, Viridian forest
composites, sea/island rock-edge partials, Rustboro RS urban/Devon drawings,
Lilycove department store, Sootopolis carved homes, Battle Frontier, Sky Pillar,
remaining regional tree composites and the interior inventory. Original terrain
terraces, complete source-faithful 360-degree surfaces for older recipes and
exhaustive first-person/walkability review remain open. No release note should
claim Gamma Emerald/BW2 visual equivalence or universal collision safety from
these representative checks.
