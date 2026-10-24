# FRLG recessed native cave entrances

Reproduced original flat native169/838 mouth drawings on current official.96
at MtMoon/Diglett/Ember. Exact map/pair/origin/warp destination/collision113,
north/side cliff art and unchanged front floor guard21 original open mouths.
Native support marks only those mouth cells; unaffected cliff profiles retain
their global heights. Actual sampled terrain clearance drives12/16/32px masses.
A native ten-pixel arch is cut from the local mass: real side reveals, angled
underside and a recessed back12px inside the original16x16 cell. Original native
rock/cap/dark/threshold paint is sampled directly. No new PNG or source archive.
Native floors, upper terraces, collision, warps and source metatiles untouched.

Navel Rock's mixed coastal elevation profile had zero-height cap corners. Its
one-cell rock hood copies the original rendered4px-grid perimeter, including
interpolation, with rock confined to the native mouth cell. No surrounding
floor or cliff moves. A floor owns every zero-height triangle; degenerate and
coplanar internal triangles are omitted.58 triangles per regular profile;
irregular hood has separate coplanar/edge regression.

The old route2_east_checkpoint recipe was a misclassified Diglett north cliff
assembly (native warp17,11 to DiglettsCave_NorthEntrance), not a gate. Remove
only that erroneous recipe; the two real forest gate assemblies remain.
Historical gate census corrected; exterior-building denominator becomes135.

Generic Scene hook prepares after region/elevation binding and emits the
reviewed mesh before generic flat art. Supports real triangle faces as well
as existing quads. Shared Terrain solid predicate recognizes only explicitly
claimed mouth support. Optional protected Hoenn prepare dispatch and per-source
append callback follow the coordinated Hoenn adapter contract; missing optional
module falls back atomically without a raw/private-asset path.

QA uses isolated completed-story flags: Cerulean guard hidden, Four Island
post-Rival introduction, National Dex completed Dunsparce Tunnel, native trainers
defeated. Real original cave preview/transition runs normally. Native north
step exits require stepping off and back into their warp; arrow exits use their
original direction. No production progression/input/collision changes.

Final six official.96 native jobs pass process0,21 placements per edition:
all42 actual entries/returns and original native map hashes, with exact runtime
source hashes in each raw receipt. All front, threshold, angled and overview
images inspected; nearby Center, native cliff and NPC occlusions are documented
rather than removing them. The generic camera remains native OFF in a dark
unflashed cave when its existing policy requires that; this checkpoint claims
outdoor geometry only. Fresh full426-map ledgers in both editions preserve all
852 hashes. Native source atlas proof and whole-map completion are separate.

Identifier-only complete native census has31 outdoor-to-underground-type warp
records per edition:21 open-mouth reveals accepted, nine separate closed/stone
entrance states remain pending (Ruby Path, Dotted Hole and seven Tanoby chamber
entrances), plus the MtEmber summit stair transfer, which is not a cave hole.
Cave inventory records exact gaps and does not count these native-art meshes as
modern source models. Corrected building ledger:135 assemblies,84 eligible and
84 accepted original source assemblies,51 unmatched per edition;6232 unclassified
blocked cells unchanged. No whole-map/game completion claim.

Exact final native commands from the checkout (each edition separately):

```sh
QA_START=1 QA_END=7 QA_DRIVER=$PWD/tools/qa/frlg-cave-entrance-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered cave-accept-a
QA_START=8 QA_END=14 QA_DRIVER=$PWD/tools/qa/frlg-cave-entrance-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered cave-accept-b
QA_START=15 QA_END=21 QA_DRIVER=$PWD/tools/qa/frlg-cave-entrance-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered cave-accept-c
```

Repeat with `leafgreen`. Evidence is excluded under
`.scratch/frlg-exteriors/api3-resume/out/cave-accept-{a,b,c}-{firered,leafgreen}`;
manual `reviewed-results.json` is separate from original `results.json`.
Native before evidence is `cave-before-firered`, initial candidate is
`cave-candidate-firered`; final contact sheets are `cave-accept-*-contact*.png`.
Complete native inventories are `cave-inventory-{firered,leafgreen}`; full map
ledgers are `cave-ledger-{firered,leafgreen}`. No runtime/caches/captures committed.

Focused suites: native reveal identity/geometry, emitted-triangle positive-area
coplanar audit, terrain5043-sample regression, cave palette/ladder profiles,
outdoor classification, scene cache, native route gates and review-history.
Both real neighboring Route2 forest gate exteriors also retain native entry/return
and visible roofs/porches in both editions, process0; final images inspected.
Reproduce with `QA_DRIVER=$PWD/tools/qa/frlg-cave-neighbor-gates.lua` and
`run.py EDITION cave-gate-regression`. Changed Lua compilation and whitespace
checks pass. No version bump/push;
root owns integration/release. Remaining stone/closed states are the next task.


## Native story-opened Ruby Path continuation

Ruby Path at MtEmber Exterior(42,39) now joins the guarded grey-mouth family
only after its original script changes the sealed857 rock to838. Original
[map script](https://github.com/pret/pokefirered/blob/master/data/maps/MtEmber_Exterior/scripts.inc)
opens it when the One Island Center scene variable reaches4. Although the raw
script requests collision0, official.96 public map inspection reports the live
warp as collision113/elevation0; the adapter follows that authoritative native
cell. No production story flag or collision writes are added.

Both FRLG story-opened states pass actual entry/return and front/threshold/
angled/overview inspection, process0, unchanged within-state map hash. Both
original closed states remain857/collision7 solid rock and block the original
native approach, process0; unoccluded native views inspected. Original Rocket
hide flag is set only in the isolated QA fixture. The default closed-state
native inventory hash is distinct from the engine-script-opened state hash;
this is original progression, not a geometry edit to native data. Geometry and
all21 existing default-mouth guards remain unchanged; new guard tests reject
closed rock and unreviewed public permissions. Coplanar/terrain proof still pass.

Native-art inventory now has22 unique reviewed entrances/edition:21 initial
open mouths plus Ruby Path closed/open states. Eight separate stone entrance
families remain (Dotted Hole and seven Tanoby shrines), with the independent
summit stair transfer still outside mouth scope. Modern source-building counts
remain84 accepted of135 assemblies. Raw and inspected receipts:
`ruby-path-final-{firered,leafgreen}`; original closed-state evidence:
`ruby-path-sealed-final-{firered,leafgreen}` in the existing own output tree.

```sh
QA_STORY=ruby_path QA_DRIVER=$PWD/tools/qa/frlg-cave-entrance-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered ruby-path-final
QA_DRIVER=$PWD/tools/qa/frlg-ruby-path-sealed.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered ruby-path-sealed-final
```

Repeat with LeafGreen. This extends the checkpoint without a version bump.
