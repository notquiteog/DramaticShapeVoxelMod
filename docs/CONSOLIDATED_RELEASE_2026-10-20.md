# Consolidated snapshot — 2026-10-20

Release 1.54.0 combines published 1.53.0 scenery with the pending camera,
paired GSC battle, native audio and safe-area HUD work. This is a fixed snapshot;
concurrent edits made after capture are preserved separately, not claimed here.

## Captured work and history

- Published scenery parent: `34d04377c7e9f9e897a0ee47b00576574b167b09`.
- Primary main: `2ab69d1028c91d9fd026b9a13ee261bb3764c22f`.
- Working tree frozen at 2026-10-20 11:21:24 UTC:
  `053d534e8afac7ce5646a345ef9c8149df8236d1`.
- Earlier pending snapshot `2624802` is also retained in merge ancestry.
- Historical master branch's main-release trigger fix is merged. The
  feature/voxel-cache-1.8 branch contains a Misty PNG deletion already integrated
  by an equivalent commit; an ancestry-only merge records that reconciliation.
  All other captured local/origin development branches are included by ancestry.
  Third-party upstream development branches are reference sources, not pending
  project work. Foreign-history tags are not merged as code branches.

The release workflow now uses manifest versions and v-prefixed tags consistently,
never invents another version when a reviewed tag exists, and uses the same
source-pack/test/ROM exclusions as the reviewed portable release builder.

## Result and limits

Camera mode changes retain continuity and ground clearance; native water support
and imported scenery remain in the merged world renderer. Paired native GSC
release/animation subjects and guarded native audio retain optional integration.
HUD command/card layouts consume the public engine safe rectangle while native
input stays authoritative. Characters and Pokémon remain HD-2D, and no companion
mod becomes required.

XD source intake, offline conversion and a dormant mesh/pose prototype are
preserved in Git. XD is **not playable** and is not exposed in settings; see
[XD status](XD_IMPORT_STATUS.md). Raw discs and model packs are excluded.

The requested category choices Modern 3D models / Sprite Art accurate models /
HD2D are queued after this consolidation; this release does not claim that UI or
complete model placement across eleven games. Existing saved scenery controls
remain available. Expanded coverage remains tracked in the all-eleven inventory.

## Verification

Latest official engine checked: v0.3.91, published 2026-10-19; source
`3806bf3df53f650e235b09f8d76feb731c30a076`. Source suite: 370 passed, zero failed,
58 explicit external-fixture skips. Focused camera, realistic water, banks,
reflection, optional battle adapters, audio and safe-area checks pass. Earlier 1.53.0 captures are not evidence of this merged runtime.

Exact candidate ZIP from `56bf331`:
`31dfe965b5889acf9a4bb79dcc9b0041e318ac9ac72dbb3c259defe5c4403534`.
All eleven standalone runners exited successfully; 183 captures were inspected
(156 water views plus 27 Surf/camera views). Each runner checked 533 actual
mounted source/asset hashes (499 Lua and 34 other files), 5,863 checks total.
Four GPU programs compiled; eight variant requests retain sampler counts
8/5/8/5. Actual underwater color/alpha and curved transmission guards pass.
Native Surf movement, support heights, 1ST/3RD interpolation, yaw and upward
clearance pass. GBA Surf uses an explicit disposable avatar-state fixture before
real directional input; this is not a complete HM-menu progression test.

A combined Crystal runner used the exact Battle Art, Double Battles0.14.5 and
Modern UI0.4.3 packages. Six inspected captures verify four independent Q57
release subjects, unchanged native clocks (39/39/39/108 frames), identities/HP,
failed-material fallback and mid-release OFF restoration.

A separate exact-package FireRed runner verifies normal, shiny, mixed, failed
and OFF native intro audio routing; all six captures were inspected. A playback
sink substitutes optional audio files: this proves routing and native fallback,
not audible timbre. No optional audio pack is bundled.

These are Linux NVIDIA OpenGL quality checks, not an FPS comparison or physical
mobile certification. Existing third-person scenery occlusion can still occur;
upward clearance does not claim obstacle avoidance. Player saves were isolated.
Scratch records: `merged-runtime-water-20261020/final-water-summary.json`,
`consolidation-20261020/doubles/final-pair-crystal`, and
`consolidation-20261020/mixed-firered`. Final documentation-only packaging must
retain the exact tested runtime hash map; published ZIP digest is recorded
separately in release checksums.
