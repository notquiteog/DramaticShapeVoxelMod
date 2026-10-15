# Lilycove Museum ground and stairs — 2026-10-15

The user clarified that the museum building design was approved and the defect
was its ground and stairs.1.39.1 retains the1.39.0 architecture and materials.
No window, façade, sign, roof or building-proportion redesign is included.

## Defect and fix

The original stair drawing remained a flat textured plane. Museum foundation
support was sampled below the door, while the disconnected garden floor used
another height. In native Emerald, for example, the garden was height0 and
the lower approach12; neither matched a coherent upper museum terrace.

`Gen3MuseumApproach` requires the complete museum, two-row stair apron, blocked
cliff perimeter and walkable lower landing, with exact source IDs/permissions.
It identifies the two stair columns and assigns a logical same-floor identity
to the rear garden and front landing. `TerrainLevels` merges only explicitly
linked floor groups before solving the existing stair constraints. No link is
inferred from collision/elevation numbers or supplied to unrelated assemblies.
Changed art, an opened flank or a changed cliff boundary vetoes the site repair.
Translated complete third-party placements work without a map-ID hardcode.

The entire garden and entrance now sit at24 in the native Hoenn site, above a
lower path at12. Eight modeled treads use the same1.5-unit support increments
as actor contact. Side cheeks and concrete guards stay inside their native
blocked flank cells. Retaining faces meet the upper terrace; buried foundation
shells close lower views. Rear walkable cells use their solved floor height,
rather than being forced to an unrelated building datum. Gen3 camera support
samples the same cell center used by actor cards; native collision, movement,
doors and warps remain engine-owned. Cache94 invalidates previous geometry.

Characters, Pokémon and flowers remain HD-2D. Flowers stand on the corrected
garden height. Native UI and standalone/optional partner contracts are unchanged.

## Evidence

Official engine checked: bryanthaboi/gen1recomp0.3.89, published
2026-10-15T16:20:04Z. Uses the user-confirmed0.3.89 QA runtime, matching official
AppImage LÖVE shell, unmodified production engine and preceding public QA helpers
(the release omits test helpers). Disposable copied imports/new-game fixtures,
identities `gen3-<edition>-qa`, no sync, no Continue/save overwrite.

Scratch root: `/home/admin/Projects/.scratch/museum-stairs-20261015/`.
Isolated source: `/home/admin/Projects/.scratch/museum-stairs-worktree-20261015/`.
Runtime shell: `/home/admin/Projects/.scratch/runtime-0.3.89/engine-museum-stairs/`.

- `native-approach.png`: inspected source drawing and permissions, private QA
  export only. `before/`: reproduced the flat staircase on1.39.0.
- `groups/`, `groups2/`, `groups-final/`: public native floor/topology inspection
  diagnosed the garden/landing separation. No debug-upvalue or native-file edits.
- `<edition>-terrace-final/`: production-rendered front/sides/rear and low-eye
  scene inspections at Lilycove(11,4), FAR64, radius9, day, focusheight42.
  EM1280×720; RS960×540. The building design remains the approved model.
- `tools/qa/gen3-museum-stairs.lua`: native held input from(11/12,9) to the
  landing(11/12,6) and back, real1ST camera, both lanes. Each ascends12 and
  descends12, max contact delta1.5; camera eye matches floor plus sprite eye
  height. Original door warp to museum1F remains working. Initial fixture
  overshot the landing into the door; it was corrected to release input while
  the final native step is in progress. Failed fixture is not pass evidence.
- `firered-stairs/`: unrelated Mt.Ember natural stair walk24→36, max delta1.5,
  first-person eye49.5 = floor36 + eye13.5. `route121/`: unrelated terrain on the
  same Lilycove tileset. `leafgreen-lab/`: unrelated busy Oak lab. Captures inspected.
- `tests-terrace.log`: complete source suite. The new museum elevation test
  covers translated topology, garden/landing identity, tread contact/closed
  bounds, foundation datum, opened perimeter/flank vetoes and native-data
  immutability. Existing terrain, stairs and landmark contracts are retained.

Final archive and current merged test results are recorded after verification.
Captures, source artwork, imported pixels, caches and saves are excluded from Git
and release ZIPs. No new network-gameplay or all-map coverage claim is made.
Other large buildings/interiors remain incomplete; tower work is parked separately.
