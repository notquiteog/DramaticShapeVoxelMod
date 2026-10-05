# Native windows and exterior-view research

Inspected Kanto Ascendant `40582034d1e55e4a5dd3b21bb90561633aa284db`
and Voxel Ascendant `22c2bb5502290d4396aa3ab11d075ee2fb70e341`.
The former integrates separate renderers. The latter's `DayNight.windowScene`
and `VoxelBattleStage.presentationWindowScene` supply sky tint/stars/moon to
painted battle-backdrop panes; this code is not a live exterior-map portal.
No donor code or art was copied in this change.

Implemented: remove generic luminous side-wall panels from the shared room
shell in all generations. Native recipes now exclusively own window placement.
Emerald Littleroot native windows use their original 15x11 frame/13x9 glass
proportions, recessed glass, closed reveals, central divider and sill. The old
crop included wallpaper and stretched it into an oversized pane. Characters
and Pokémon retain their sprite artwork.

QA: official 0.3.51, isolated Emerald starting-house driver in
`.scratch/coverage-20261004/starting.lua`. All four home fixtures complete with
native layout/collision assertions. Inspected Brendan 1F first-person capture;
window frame/recess visible and invented side panels absent. Interior shell
and complete furniture regression tests pass. This is not universal window
or exterior visual verification.

Outstanding: real exterior-map views. Resolve the room's native exit chain to
an outdoor doorway (upper floors may exit to another interior); never teleport
or change the live map to render a view. Native window detection must provide
an aperture, wall plane, orientation and corresponding exterior point. A
separate clipped render camera then uses the normal world renderer and native
assets with a bounded, cached update budget. Cache invalidation must include
map/terrain changes and time/weather. Indoor window art remains the fallback
for unresolved or ambiguous exits. Preserve native frame/reflection artwork;
do not invent scenery or universal windows in caves/windowless rooms.

Existing far-view controls already share Auto/Low/Medium/Far/Full; Gen3 Full
covers loaded region bounds with at least the Far connected-map frontier.
This is not unlimited whole-world streaming. Further work: distant geometry
LOD, transition audit, exterior-view budgeting and day/night pane lighting.
