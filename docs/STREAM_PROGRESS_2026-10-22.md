# Destination progress and XD identity — 2026-10-22

Fix: a destination window moving laterally no longer cancels an unfinished
prefetch when its native context, providers and coverage still match. Completed
nearby views can be reused before crossing, not only retained return views.
New atlas readiness and native edits still cancel. Gen3 immutable scene builds
also skip redundant per-cell signature strings; replay/unkeyable layouts retain
full fingerprinting. Forced completion cost is now visible in exported metrics.

Verified on official Gen1Recomp0.3.95 with LÖVE11.5 shell from0.3.89,
NVIDIA5060Ti/615.71.09, isolated profiles, all seven companions. Ten focused
stream/cache/effect/budget suites passed. Native running connections pass in all
five GBA editions, with current camera ownership and native-neighbor sampling.
The long FRLG approach is blocked by native terrain, so its fixture starts two
cells before entry; RSE starts12cells away. Final1440p wall p95/max(milliseconds):

| Game | p95 | max | Forced completion |
|---|---:|---:|---:|
| FireRed |19.56|160.33|150.17|
| LeafGreen |20.69|178.88|163.85|
| Ruby |19.88|26.15|0|
| Sapphire |20.29|32.11|0|
| Emerald |18.99|27.35|0|

These are bounded running fixtures, not165FPS certification. Very late cold
entry still has synchronous work; this release does not claim to remove it.
Physical phones remain untested. Source checks caught and fixed a provider-
readiness invalidation regression before release.

Shared XD identity changes are in fe78440: native Unown/Deoxys selection,
cache invalidation, substitute/ghost/Transform ownership and GBA model heading.
Four Lua suites and five native form/option checks passed. Model packs remain
gated; full materials, shiny/particles/subanimations, GB paired ownership and
installation acceptance are still incomplete. See XD_IMPORT_STATUS.md.
