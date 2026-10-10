# Crystal model coverage checklist — 2026-10-09

This records bounded model work, not approval of every classified tile.

- [x] Department-store native window drawing (MART 14/15/28/29): recessed
  original reflection artwork, closed backing, dimensional frames and sill.
  The pane no longer appears on a cube's roof. All geometry stays inside its
  blocked 16px source cell; native map/collision/warp data is unchanged.
- [ ] Department-store stair/elevator wall fixtures: still generic source
  extrusions in the reviewed views; need independent native-art review.
- [ ] Other Crystal building/interior families: inventory and per-model review
  remain outstanding; classifier counts cannot close this item.

Validation: official engine 0.3.52, disposable `emerald-port-crystal-qa`
identity under `.scratch/coverage-20261004/profiles`; no portable.txt in the
engine root. Fixture `crystal-windows.lua` captured Celadon 1F/6F and Goldenrod
1F at overview, orbit side/rear and first person. Inspected Celadon 6F overview
and first-person, Goldenrod 1F side. Native pane reflections/frame and walking
floor are retained. Source reference: `results/crystal-source`. New renders:
`results/crystal-crystal-windows`. Native tile-grid invariant passed in all
three scenes; no collision/warp code changed. Player saves were not used.

Tests: `gen2_department_windows_test`, `house_department_models_test`,
`gen2_depth_furniture_test` pass. Tests bound all model vertices to the native
cell and protect the complete vertical glass crop. No version/release change.
