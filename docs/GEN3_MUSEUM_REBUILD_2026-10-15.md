# Lilycove Museum architectural rebuild — 2026-10-15

## Direction and scope

The user rejected the previous folded native façade and supplied a Lilycove
Museum ORAS image. They additionally directed that Omega Ruby / Alpha Sapphire
be used as architectural references for distinctive buildings and interiors.
This overrides literal sprite-wrapping when it cannot produce a convincing 3D
building. Retain native map footprint, doors, routes and gameplay. The user
explicitly rejected added “Museum” lettering; the final fascia is decorative.
Reference artwork is not included in the repository or release.

1.39.0 replaces the museum in Emerald, Ruby and Sapphire, at native Lilycove
origin (7,0), 10×7 cells. Other landmark models are unchanged. Remaining regional
buildings/interiors are not complete. Battle Tower work is parked separately.

## Architecture and materials

`Gen3Museum` authors three closed architectural masses, a taller central hall,
lower wings, inset blue glazing with closed reveals and modeled white frames,
slate foundations, pale brass capitals and narrow decorative fascia panels.
All four elevations continue the architectural vocabulary. Roof lanterns have
pitched glass, end closures, undersides, ridges and closed crossbars. Roof decks,
parapets, corners, structural piers and entry trim are separate modeled parts.

The 324×112 material atlas is generated at runtime from original ceramic,
slate, blue-glass, white-frame and pale-brass materials. No external texture,
reference image, native RGBA or game pixels ship. Native door animation still
uses the original engine source and its exact recessed portal. There is no
invented sign text. Window panes retain the existing building-light contract.

Both projected rear rows and the original row6 walking corridor remain clear
at every modeled height. Exact complete source/permission matching supports
translated third-party reuse and refuses changed walking lanes. Native museum
landing art is preserved; ground under claimed structure uses the existing
reviewed neighboring ground selection. Actors, Pokémon, flowers, collision,
warps and base UI retain their native ownership. No dependency was added.

Two cliff cells immediately beside the stairs previously rose to height36 over
a height12 landing. `Gen3Museum.prepare` recognizes the complete two-row native
stair/terrace apron before annotating its existing 079 retaining cells.
`Gen3Terrain` then meets that museum's entrance foundation instead of adding a
second cliff height. Changed art, pair or permission receives no override;
unrelated cliffs keep their prior heights. No global wall-height change.
Mesh cache92 invalidates the previous building/terrace geometry.

## Verification

Latest official engine checked: bryanthaboi/gen1recomp v0.3.89, published
2026-10-15T16:20:04Z. User confirmed the existing isolated 0.3.89 QA runtime.
Engine source is the official release with its matching AppImage LÖVE shell;
the release omitted test helpers, so the preceding public QA harness is used
without changes to production engine code. GPU FPS is not established.

Disposable copies of the existing private GBA imports, fresh new-game fixtures,
identities `gen3-<edition>-qa`, `--no-sync`, no Continue/save overwrite. Mod ID
BATTLE_ART_VOXEL_FORK. All scenery views use the production renderer; orbit and
low-eye captures use the QA inspection lens. Separate first-person fixtures
use the actual production 1ST camera. Native entry fixtures use camera35 and
normal held input after teleporting to a known walking approach.

Evidence root: `/home/admin/Projects/.scratch/museum-redesign-20261015/`.
Source checkout: `/home/admin/Projects/.scratch/museum-worktree-20261015/`.
Runtime shell: `/home/admin/Projects/.scratch/runtime-0.3.89/engine-museum/`.

- `emerald-v1/`: reproduced the museum terrace spikes beside the newly modeled
  building; `approach/run.log` diagnoses native source/permissions/floor heights.
- `emerald-final/`, `ruby-final/`, `sapphire-final/`: front/right/rear/left and
  low-eye production-rendered captures after removing the invented lettering.
  EM1280×720, RS960×540; day, focusheight42, FAR64, center(11,4), radius9.
- `<edition>-doors/`: both original native door entries from (11,6)/(12,6)
  reach that edition's museum1F. Six entries and three native rear walks from
  (10,1) pass, camera35 retained, zero recovery failures. Native camera0 views
  preserve the original drawing/UI. Source door artwork/warp remains native.
- `emerald-route121/`: unrelated outdoor map with the same Lilycove tileset
  retains its terrain/stairs. `firered-lab/`: unrelated busy Oak lab retains
  modeled furniture, native item balls and HD-2D actors. Rendered views inspected.
- `tests-release.log`: 289 suites pass, zero fail,58 explicit absent-external-
  fixture skips. New museum test covers authored material allocation without a
  source atlas, palette/glass gradient, exact apron guard and unchanged unrelated
  cliff heights. Existing nine-landmark test covers full all-height bounds,
  source permissions, translated reuse, portal clearance and closed undersides.

Private captures/imports/cache files stay outside Git and release assets.
Prototype captures containing the rejected text are not final visual evidence.
QA-only drivers add resolution controls and museum-only door scope; the low-eye
inspection camera now resamples support after moving clear of the player sprite.

## Ecosystem audit and limits

All six partner worktrees were clean and matched their origin/main. Exact
user-named fork releases checked: wild_skies1.15.1, dramatic-sky-ride0.5.4,
double-battles-gen2 0.14.2, gen1online-plus0.11.1,
overworld-spawn-mod2.6.3, modern-ui0.4.1. Optional providers remain optional.
This batch does not claim new network gameplay verification or all-map parity.

The isolated baseline includes already committed native-interface/performance
work recorded in the root handoff, including Gen3 Crystal portraits and the separately verified shiny-VM adapter.
The adapter's five-edition evidence is recorded in
`GEN3_CRYSTAL_SHINY_2026-10-15.md`; its runtime source was inspected and
its focused contracts repeated before this release. Current
uncommitted scene/uniform/mask edits in the shared primary checkout are excluded
and preserved. Full scenery coverage and the parked tower batch remain open.

## Release-archive checks

The Git-archive package excludes tests/tools, ROMs, private native pixel data,
imports, saves and caches. All packaged Lua files compile and the ZIP passes
its integrity check. Original archive standalone first-person checks passed
in Emerald (day/night) and Ruby (day), with actual1ST camera, from native
(11,9)/(11,6). Captures were inspected; the final entry fascia has no lettering.
Sapphire archive night views with all six optional partners loaded pass; all
seven IDs/versions are present without loader/driver errors. No new network
gameplay claim is made. Final archive additionally includes the already
verified committed shiny adapter; final source/compatibility checks are below.
