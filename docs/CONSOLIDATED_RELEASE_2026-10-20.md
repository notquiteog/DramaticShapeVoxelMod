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
  All other local/origin development branches are included by ancestry.
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
reflection, optional battle adapters, audio and safe-area checks pass. Native
archive checks and inspected render results are recorded below after completion;
earlier 1.53.0 captures are not evidence of this merged runtime.
