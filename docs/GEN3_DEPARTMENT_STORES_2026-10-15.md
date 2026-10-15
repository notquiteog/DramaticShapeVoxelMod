# Gen3 department stores — 2026-10-15

## Batch scope and architecture

Two reviewed source families add five large placements: Celadon department store
in FireRed/LeafGreen, Lilycove department store in Emerald/Ruby/Sapphire. This is
an incremental architecture batch, not full large-building/landmark completion.
Only identifiers, dimensions, topology and source rectangles ship. All pixels
come from the user's native imports through the existing renderer.

Celadon uses the complete9x10 drawing at FR_CELADON_CITY(9,5). The first row is a
walkable roof projection and stays clear; every volume starts inside the solid
rows, with only the two explicit final-row0x294 native warp doors allowed. Three
chamfered glass bays have actual recessed apertures, with five glass storeys,
gold spandrels, the red-tiled white entrance piers and striped entry canopies.
The closed roof has recessed slotted channels, its raised pale terrace, native
white/green rails/posts, and clerestory panes. No rooftop equipment was invented.

Lilycove uses the complete9x7 visible facade at (23,0). Its top continues beyond
the native map's north edge; a quiet closed blue cap interprets that unseen roof.
Emerald keeps stepped arches; RS keeps square sash windows and different native
cladding. A continuous raised plaque preserves the original emblem. Four closed
orange/white awnings sit above real recessed shop windows. Their old projected
facade copies are repaired with native blank cladding, while untouched artwork
is retained in the second material half for the raised elements.

Both buildings have complete side/back elevations and undersides. Unseen window
placement is an architectural interpretation using the same native vocabulary.
Source proportions, storey count, colors, doors and details inform these models;
no claim is made that the 2D games contain an authoritative unseen elevation.

Exact source matching and permission guards reject partial art or a new walking
lane in third-party maps. Recipes match by tileset/drawing, not hard-coded map
coordinates; unit fixtures also instantiate them at translated coordinates.
Reviewed local grass/paving candidates select the underlay. The FRLG lower
projected foundation row remains native walking art. Engine collision, warps,
input, UI and quest/gameplay rules are unchanged. Mesh cache revision89.
Characters, Pokémon and flowers remain HD-2D; no actor/flower paths were changed.
No companion dependency or private-provider access was introduced.

## Runtime and source evidence

Latest official engine checked before this batch: Gen1Recomp0.3.88, published
2026-10-14. Used the official bundled Linux LÖVE executable and matching .love/
source helpers under `/home/admin/Projects/.scratch/runtime-0.3.88/` with NVIDIA
RTX5060Ti / Xvfb. Existing isolated five-edition native imports from0.3.86 were
reused; these are not fresh0.3.88 importer tests or normal player saves.

Evidence root: `/home/admin/Projects/.scratch/gen3-landmarks-20261015/`.
Private QA identities `gen3-<edition>-qa`, disposable new-game fixtures. QA maps
load through public map APIs; entry and rear-lane checks use actual native input.
No native damage/warp result is injected. No imported art/captures are committed.

- Source art: `fr-celadon-grid.png`, `fr-department.png`,
  `emerald/ruby-lilycove-grid.png`, `emerald/ruby-department.png`.
- Before: `fr-before/`, `em-before/` show the unmodeled stores.
- Iteration: `fr-after1/2`, `em-after1/2` caught/refined the upper fascia and
  duplicate projected canopies. Final Celadon relief positions match native
  red-tile rows; the full roof and all elevation reveals are closed.
- Final solo views: `firered/leafgreen/emerald/ruby/sapphire-final-views/`.
  Four cardinal orbit views and one native-ground eye-height view per edition.
  `QA_FOCUS_HEIGHT=42` for Celadon /48 for Lilycove centers tall structures;
  `QA_RENDER_DISTANCE=64` uses the public FAR setting to keep rear details clear.
  Earlier32-distance rear captures were hazy and are not the final rear review.
  Normal distance haze remains production-owned. Eye views may contain native
  foreground flowers/NPCs or nearby scenery; these are not removed for review.
- Native entrances: `firered-doors-final/`, `leafgreen-doors/`,
  `emerald-doors/`, `ruby-doors/`, `sapphire-doors/`.
  Seven entries total (both Celadon doors per FRLG edition, one per Hoenn
  edition), each through normal up input from native non-warp approach ground.
  All reach the native department-store1F interiors, retain camera3 and report
  zero camera recovery failures. FRLG also walks right across rear row5.
  Each entry fixture first captures the native camera0/2D fallback.
- `tools/qa/gen3-department-store-doors.lua` reproduces entry/rear-lane checks;
  `tools/qa/gen3-scene-review.lua` supplies the optional tall-building framing.

Solo scene fixtures load only Battle Art. All six partners remain optional;
final exact-archive compatibility checks are recorded in release evidence.
This scenery batch does not certify WAN multiplayer, controller hardware,
mobile performance or every room/landmark across the five games.

## Verification and remaining scope

278 Lua suites pass, zero failures, 58 external-fixture skips (`tests-release.log`).
New suite checks five-edition source/permission dispatch, translated maps, local
paving, bounds, surrounding glazing, door animation apertures, manifold roof
slabs and preservation of raised artwork during facade repair. Existing Hoenn
fixtures now provide native collision for the new strict source recipe.

Native recognized-building footprint census (`footprint-<edition>/`):

| Edition | Assemblies | Flagged walking-center intersections |
| --- | ---: | ---: |
| FireRed | 127 | 0 |
| LeafGreen | 127 | 0 |
| Emerald | 80 | 0 |
| Ruby | 74 | 0 |
| Sapphire | 74 | 0 |

This census tests low face bounding boxes against central8x8 of permission0
cells, not every point or every warp code. Exact permission/bounds tests and
real entry/rear-lane movement supply separate evidence. Geometry tests do not
replace inspected native renders.

The five stores claim344 previously unmodeled blocked cells; native warp cells
are counted separately by engine permissions. Expected remaining outdoor gap
cells after this batch: FRLG6512 each, Emerald11624, RS10119 each. Final archive
censuses confirm the packaged inventory before publication. Gaps are unclaimed
blocked source cells, not a count of remaining objects or buildings.

Next architecture queues include Indigo Plateau/Route23, Lilycove museum, RS
Devon/Space Center, regional landmarks and large interiors. The League facade
contains tree/statue composites that require their own contextual source work;
those were inspected but are not modeled by this batch.
