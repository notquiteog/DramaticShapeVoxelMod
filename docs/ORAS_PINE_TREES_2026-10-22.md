# ORAS evergreen source and Hoenn owner coverage — 2026-10-22

Next batch, independent of the frozen 1.57 building release. Native runtime QA
and central ImportedTrees integration are still required. This change adds the
real source asset and guarded selector; it does not claim every tree is imported.

## Cause and offline census

ImportedTrees previously used the Route104 broadleaf for eligible Hoenn owners,
but rejected every owner narrower than23.9px and every fitted tree shorter than20px.
The current native packing gives Hoenn evergreen owners16×16 or16×32 rectangles,
so all those owners retained the older solid model. Regional round fragments,
ash and saplings remain separate families, requiring their own source review.

The census decoded the imported native SVML permission grids and named pairs,
then ran current Hoenn shape, regional-tree and TreeFootprints preparation. It
included all cached General-pair maps, real in-map cells, and zero test base
height. It excluded streamed boundaries and did not run GPU/actors/civic claiming.
These are CPU eligibility counts, not released native placement totals.

| Edition | Tree owners / maps | Existing broadleaf | Rejected conifer | New pine owners / actual whole pines | Maps gaining pines |
| --- | ---: | ---: | ---: | ---: | ---: |
| Emerald | 8,447 /49 | 1,975 | 4,298 | 3,963 /6,951 | 24 |
| Ruby | 7,445 /42 | 1,781 | 3,853 | 3,608 /6,352 | 20 |
| Sapphire | 7,445 /42 | 1,781 | 3,853 | 3,608 /6,352 | 20 |

Per-map details: [CSV](coverage/hoenn-imported-tree-census-2026-10-22.csv).
Route104 gains247 owners/465 whole crowns in each edition. Route119 gains767
owners/1,420 crowns in Emerald and774/1,436 in each RS edition.

The native primary-sheet pixel comparison matters here: C6/C7 each display a
whole small evergreen crown. A16×32 owner commonly contains C6,C6 or C7,C7;
it represents two repeated whole crowns. It receives two rigid source trees,
one within each original blocked16×16 cell. It never receives one tiny source
tree centered across the two-cell rectangle. An isolated whole16×16 crown gets
one tree with the same scale.

Only whole crowns E/F/C6/C7 qualify, and every owner member must match. Clipped
1E/1F/2E/2F/CE drawings, Dewford's separate painted239/23A/243 art, ash, saplings,
round trees and all shrubs/flowers retain their native family. Emerald currently
mislabels blocked white rails3E/3F as conifers (77 roots in this census); this
selector explicitly rejects them, along with staircase CF. Their classification
is a separate correction; this commit does not alter it.

## Source and fit

Source293576, Pine Tree / Evergreen Tree, uploaded by Fallenleader (RSRazr),
2015-08-29. The included DAE has no image/sampler links. Its readme explicitly
requests binding the supplied, already UV-mapped textures. The bark material
uses chip_wood_a.png; the canopy uses Chip_Wood_B.png. The retained source has
12 bark triangles and96 canopy triangles. Both PNG byte streams and every
original vertex/UV survive conversion. No canopy stretch, repeated rotated
foliage shell or texture repaint is applied.

The original Y-up bounds are X[-37.16305,37.17694], Y[-11.259592,82.908230],
Z[-32.937988,28.620022]. One uniform normalization grounds the model and retains
its proportions. Twelve added triangles close the bark's back/top/ground; a
24-triangle inset bark backing closes its original root cutouts. These new
surfaces use an opaque texel from the original bark PNG. The original alpha-cutout
leaf edges remain foliage. The complete opaque bark hull has two faces per edge.

A16×16 blocked cell with0.25 padding gets a15.5-wide×12.835-deep source tree,
height19.634. Yaw quarter turns swap width/depth but preserve the same scale.
This fills97% of one ground axis and80% of the other. Each original cell is
verified blocked and owned; no source vertex enters a neighboring walking cell.
The shared full32×32 fit used by Kanto is31.5-wide×26.084-deep, height39.902.
No global broadleaf size threshold changes are part of this module.

## Integration and checks

Gen3ImportedHoennTrees.placements(c,cells,options) returns one/two ordinary
SceneryModels placements already fitted to their blocked cells. Every placement
uses the same original native owner as source and the same aggregate treeInfo,
whose bounds union both fitted crowns. Planning never hides the fallback.
The central adapter must validate its existing owner/level guards, consume the
whole list in one upload operation, and mark the owner only after all uploads
succeed. A failed/rejected specialized family must retain its native tree;
it must not silently retry the unrelated broadleaf.

The module registers ImportedPineTreeData lazily through the public provider.
The parent may also register that same module globally for the Kanto selector;
register() safely reuses an already registered definition. Source resources use
the existing SceneryModels ownership/release and shared-image lifecycle.

Passed: source conversion and bark edge closure, mocked LuaJIT source UV/fit and
all-vertex native blocked-cell checks, 1×1/1×2 owner packing, rail/stair/edge and
foreign-owner/height/region exclusions, and no pre-upload fallback mutation.
CPU front, rear, side, quarter and underside source/completed renders inspected;
canopy geometry and original textures match, closed bark fills previously open
rear/root geometry. Scratch captures stay outside Git. Native shader/material,
walking, connected boundaries, battles and device visuals remain parent QA.

Suggested native checks: Route104 early evergreen wall beside broadleaf forest,
Route119 dense wall/diagonal boundary, Route112 volcanic approach (ash preserved),
Dewford separate pine art (preserved), 2D/texture failure fallback, and neighboring
busy interior. Inspect35-degree and eye-level front/rear/rotating cameras and
assert every imported source vertex remains on its original blocked owner cells.
