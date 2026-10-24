# Dotted Hole native stone checkpoint — 2026-10-23

FRLG Ruin Valley(24,24) now has the original continuous braille slab, paired
closed white columns and a recessed arched opening in its native Cut-opened
state. This is native-art geometry, not imported modern-model coverage.
**Rendered acceptance remains held for shared shadow acne.** Default shadows
produce diagonal bands on the slab and columns; an otherwise identical final
source run with shadows off is clean. The release owner owns that renderer fix.
The adapter does not disable or change user shadows.

Exact original 3×2 art/permissions, native warp destination and northern cliff
profile guard the assembly. Closed855/collision7 stays solid; original Cut
flag739 invokes the original compiled map script and yields856/public113. No
production flags, collision, floor, warp or native-map data are changed. The
original script is [Ruin Valley](https://github.com/pret/pokefirered/blob/master/data/maps/SixIsland_RuinValley/scripts.inc).
The closed twelve-pixel braille crop remains one upright face. Opened state has
real eight-pixel reveal depth. White columns are closed twelve-sided solids,
20px high, contained entirely in the original blocked row. Their bottom rings
recess0.05px without translating upper geometry. Native lower projection cells
remain walkable and have only their source-proven court floor: both original
822/879 lower eight rows exactly equal native198, and differ from lawn1.
Narrow rock niches keep native cliff contacts. No new textures or source packs.

Actual emitted geometry:296 closed /316 open triangles, no degenerate triangles
or positive-area coplanar intersections. Source UVs remain bounded. Scene's
existing generic prepare/append hook dispatches the optional child module;
`Gen3Terrain.solid` respects explicit `terrainSupport=false` on only the two
floor-only projections. Existing default support and Hoenn callbacks retain
their prior behavior. Missing/foreign art or permissions leave native fallback.

Official runtime v0.3.96, LÖVE11.5, standalone API3 Battle Art in isolated own
profiles. Final closed and opened native cases in **both** editions all PASS,
process0, no teardown errors. Actual opened entry/return and sealed bump pass;
both original projection lanes are walked and then stopped by original column
collision. Within-state native hashes remain unchanged. Front, sides,
threshold, overview and projection views inspected. LeafGreen also runs the
original compiled onLoad after changing its original Cut flag, without map
reload: same map object, one native door cell changes, geometry refreshes.
This tests original script progression, not the party HM selection menu.
Neighbor MtMoon entrance still passes actual entry/return. Full LeafGreen
426-map building census remains135 assemblies/84 eligible/84 accepted/51 gaps;
no cave geometry is counted as modern source coverage. Twenty-two native cave
entrances/edition remain accepted, one Dotted Hole render hold, seven Tanoby
stone entrances unmodeled, independent summit stair transfer still separate.

From the owned checkout, reproduce (repeat with `leafgreen`):

```sh
QA_DRIVER=$PWD/tools/qa/frlg-dotted-hole-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered dotted-paint-closed
QA_DOTTED_OPEN=1 QA_DRIVER=$PWD/tools/qa/frlg-dotted-hole-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered dotted-paint-open
QA_DOTTED_SHADOWS=off QA_DRIVER=$PWD/tools/qa/frlg-dotted-hole-review.lua python3 .scratch/frlg-exteriors/api3-resume/run.py firered dotted-paint-shadow-off
QA_DRIVER=$PWD/tools/qa/frlg-dotted-hole-transition.lua python3 .scratch/frlg-exteriors/api3-resume/run.py leafgreen dotted-live-transition
```

The helper selects DayNight=`day`, render distance16, no haze, pitch0.12.
Front: player(24,26), up, yaw0, camera level6. Threshold(24,25); side views
(22,26)/yawπ/6 and(26,26)/yaw−π/6. Overview level3. Shadow-off diagnostic restores
the old option. Scientist hide flag142 is changed only for unoccluded QA views.

Excluded evidence is under `.scratch/frlg-exteriors/api3-resume/out/`:
`dotted-paint-{closed,open}-{firered,leafgreen}`, contact sheet
`dotted-paint-contact.png`; same-current-source shadow comparison
`dotted-paint-closed-firered/front.png` against
`dotted-paint-shadow-off-firered/front.png`. All four production hashes match
the committed source; ON/OFF hashes identical. Raw `results.json` stays
renderedVerified=false; separate `geometry-reviewed-results.json` explicitly
records the shadow hold. Additional evidence: `dotted-live-transition-leafgreen`,
`dotted-neighbor-cave-regression-leafgreen`, `dotted-ledger-leafgreen`.
The live transition precedes the final UV-only paint crop repair; its control
flow and geometry are unchanged. No captures/caches/raw native data committed.

Focused geometry/native-art proof, cave coplanar geometry, terrain5043 samples,
cave profiles, outdoor classification and Scene cache suites pass. Changed Lua
compiles. No version bump, push or publish; root consolidates release and shared
shadow fix. New source intake stopped at this committed checkpoint.
