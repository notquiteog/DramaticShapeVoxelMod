# Gen3 League, museum and RS science landmarks — 2026-10-15

## Scope and source work

Version1.38.0 completes the nine requested placements in four source families:

| Family | Native placement | Editions |
| --- | --- | --- |
| Indigo Plateau League | INDIGO_PLATEAU_EXTERIOR(6,0),11x7 source | FireRed, LeafGreen |
| Lilycove Museum | LILYCOVE_CITY(7,0),10x7 source | Emerald, Ruby, Sapphire |
| Devon Corporation | RUSTBORO_CITY(7,7),10x9 source | Ruby, Sapphire |
| Space Center | MOSSDEEP_CITY(60,6),9x8 source | Ruby, Sapphire |

Native source composites and the corresponding maps were inspected before
modeling. Only identifiers, dimensions and topology ship; all textures are read
from the active edition's native atlas. The dedicated module uses shared closed
shell/reveal primitives, not vertical texture nets or hidden opaque glazing boxes.

Indigo has timber wings, six narrow native-glass openings, a genuine pitched
central gable with closed ends/underside/ridge and raised chevron, recessed
sliding doors/grille, and four closed small ornamental trees. The exact source
mask leaves the statue drawings and walking/foundation cells in their native
presentation. Original tree composites no longer project onto the ground.
Native roof strips are mapped continuously; old diagonal pediment pixels are
not repeated on the flat facade. The rear central elevation starts above the
wing, avoiding overlapping coplanar rear faces.

The museum has two closed roof tiers with continuous native patterns, native
window recesses, blue fascia/yellow piers and an uninterrupted entrance grille.
RS keeps its stepped lower window shoulders; Emerald has square lower panes.
The first two source rows are a walkable roof projection: every model surface,
including high eaves, stays south of that row. The central portal stops at z96;
its walking corridor and the original row6 stair-landing tiles remain clear.
Rear and side elevations partition the shared wing/central edges, rather than
z-fighting overlapping windowed boxes.

RS Devon retains its own I-shaped/lancet window art and wall vocabulary. Two
native arched doorways sit in actual recessed openings beneath the taller
central bay. Roof slabs, cornices, sides, rear and underside are closed; the
native winged crest remains continuous on a shallow solid medallion. The wings
stop before the native walking strip on the final source row. Emerald's existing
Devon model is unchanged.

RS Space Center is its own green five-storey building with narrow horizontal
recessed glazing, a continuous inset central glass spine, source-colored piers
and horizontal divisions, and twin closed low roof vents. It does not inherit
Emerald's rocket, gantry or dish. The two native walkable roof cells stay clear
at every height; the complete shell/roof begins south of source row1. Emerald's
existing Space Center and launch-display recipe is unchanged.

Unseen elevations, roof depth and tree volume are interpretations of the native
architectural vocabulary; the source games have no authoritative 360-degree
geometry. Source proportions, colors, floor/window count and visible fixtures
inform them. No unrelated attachments or imported model/art packs are added.

## Spatial, compatibility and extension contracts

Complete drawing matches also require the exact source permission matrix,
including native warp cells and projected walking rows. Any changed permission
or missing/changed interior source identifier vetoes the whole recipe. The new
recipes remain position-independent; tests instantiate them at translated map
coordinates. RS replacement recipes are emitted only for the corresponding
input source family, preserving filtered third-party catalog behavior.

All vertices stay in the native footprint. Focused tests check face extents
against every permission0 cell at all heights, plus door-source/animation inset,
no opaque plane across the open portal, texture bounds, underside presence,
landing art, masks and altered third-party lane rejection. The geometry does
not alter engine collision, warps, input, quests, UI or actor/flower rendering.
Characters, Pokémon and flowers remain HD-2D. Mesh cache revision90 refreshes
these emitted vertices. Every companion remains optional, with dependencies[].

## Runtime, fixtures and evidence

Latest official engine checked before the batch: Gen1Recomp0.3.88, published
2026-10-14T22:24:46Z. Used its official Linux bundled LÖVE executable and matching
engine/source helpers, NVIDIA RTX5060Ti and Xvfb. Isolated0.3.86 five-edition
native imports were copied into a separate QA persistence root; this is not a
fresh0.3.88 importer test. No normal player save was used or overwritten.

Evidence root: `/home/admin/Projects/.scratch/gen3-landmarks2-20261015/`.
Final source checkout: `/home/admin/Projects/.scratch/landmark-worktree-20261015/`.
Official engine shell: `/home/admin/Projects/.scratch/runtime-0.3.88/engine-landmarks2/`.
Private identities: `gen3-<edition>-qa` under evidence-root `profiles/`.

Concurrent unrelated battle/option edits appeared in the primary checkout.
This batch was isolated from commit409b7cf; those edits were preserved and are
excluded from the source snapshot and player ZIP. Earlier exploratory captures
precede isolation and are not final package acceptance.

- Source: `fr-exact.png`, `ruby/emerald-devon.png`,
  `ruby/emerald-space-source.png`, `ruby/emerald-museum-detail.png`, native map
  composites and complete source-ID/permission grids (private scratch only).
- Before: `firered-before/`, `emerald-before/`, `ruby-before/` show flat landmarks.
- Refinement: `*-after1/2` and `*-isolated1/` caught the old projected pediment,
  museum window offsets, repeated roof UVs, incorrect native swatches and
  overlapping rear elevations. These are iteration evidence, not final approval.
- Five-edition source views: `*-final/`, four cardinal production-rendered
  inspection orbits plus a low native-ground eye view for each of nine spots.
  Public FAR64; focus35 League /40 Emerald museum /48 RS; radii9..11 tiles.
  All five final scene-review processes exit0. Contact sheets inspected, with
  full-size source/front/rear checks; final League rear cleanup is rechecked
  from the exact installable archive before publication.
- `*-doors-final/`: fourteen actual native-input entries (FR1,LG1,EM2,RU5,SA5)
  reach the exact expected native interiors. Three Hoenn museum rear-row walks
  pass. Camera3 stays active with zero recovery failures across each entry;
  all five processes exit0. Every approach also captures native camera0
  fallback. Flat and interior captures inspected in
  `native-doors-fallback-sheet.jpg`.
- `tests-release.log`:279 suites pass,0fail,58 unavailable external-fixture skips.
  New `gen3_landmarks_test.lua` covers all nine edition instances. Existing RS
  and Hoenn fixture grids now supply the new exact native permissions.

Recognized-building native footprint census (`footprints-<edition>/`):

| Edition | Assemblies | Walking-center flags | Outdoor gap cells |
| --- | ---: | ---: | ---: |
| FireRed | 128 | 0 | 6,440 |
| LeafGreen | 128 | 0 | 6,440 |
| Emerald | 81 | 0 | 11,578 |
| Ruby | 77 | 0 | 9,922 |
| Sapphire | 77 | 0 | 9,922 |

Census processes exit0. The footprint census tests low face bounding boxes
against central8x8 of native permission0 cells, not every collision code/point.
Separate all-height bounds tests and real movement/warp checks supply stronger
scoped evidence for the new families. `source-gap-<edition>/` inventories have
no GAP ERROR: this batch replaces584 formerly unclaimed blocked cells (72 per
FRLG,46 Emerald,197 per RS). Gap cells are not remaining object/building counts.

## Release acceptance and limits

The exact committed root-layout ZIP is tested for archive integrity, packaged
Lua syntax, correct manifest/dependencies and exclusion of ROMs, imported native
RGBA, saves, caches, captures and private BYO battle/Legendary art. QA drivers
remain source-only. Release checksum is distributed in sha256sums.txt.

Before publication, the exact archive repeats five-edition inventories and runs
native render smoke checks with all six optional companions enabled. League
front/rear/eye, RS science landmarks/museum and an unrelated Celadon store are
reviewed from that package. Partner versions: Wild Skies1.15.1, Ride0.5.4,
Double Battles0.14.2, Online Plus0.11.1, Wilds2.6.3 and Modern UI0.4.1. All six
partner checkouts were clean/synced; no changes to them are needed by this batch.
This scenery smoke is not a new multiplayer/battle completion certification.

The nine requested landmark placements are covered. Full five-game architecture
and interior coverage remains open, including other regional landmarks, Route23
decorative composites, Lilycove's gold residence/Frontier variants and large
interiors. Native statue drawings, actors and flowers are not converted by this
batch. No Windows/mobile/controller/WAN coverage is claimed here.
