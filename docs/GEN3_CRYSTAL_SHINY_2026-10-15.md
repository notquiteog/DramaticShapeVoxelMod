# Native Gen3 Crystal shiny reveal — 2026-10-15

The selected Crystal pack now supplies its bundled seven-star reveal and
sparkle sound in FireRed, LeafGreen, Ruby, Sapphire and Emerald. Other packs,
missing assets and headless execution keep the native shiny sequence.

## Implementation and ownership

`NativeCrystalShiny` wraps the public `Anim.launchShiny` call and substitutes
only that call's VM script. The original method resolves battler IDs, sides,
caller options and reversal. The adapter registers a namespaced sprite callback
in the public animation registry; ordinary no-graphics VM sprites draw the
bundled four-frame sparkle atlas. Two shiny battlers use two native anchors and
one sound. The seven offsets/frame intervals match the existing Crystal reveal,
translated relative to each native battler center.

The VM owns visual completion and the original `onEnd` continuation. Lifetime
uses the bundled sound duration converted to VM frames; mute or a silent audio
driver cannot leave battle logic waiting on audio playback. The sound follows
native SFX volume, including a live change to zero. Reset, VM interruption,
pack changes, asset release and uninstall stop owned sound/sprites without
calling a cancelled continuation. Scoped VM replacement is restored even when
the native launch raises an error. No shiny calculation, party data, battle
result, cry callback, protected callback or companion asset is replaced.

## Verification

Official engine **0.3.89** with its matching Linux native shell; the parent
rechecked the latest GitHub release before this batch. Production engine source
is unmodified. Public QA harness support comes from 0.3.88 because the official
0.3.89 bundle omits it. Mod revision before this batch: `79eb7fb`; concurrent
performance/model edits are separate and excluded from this commit.

- 23 focused shiny contracts pass: native return/options/ID preservation,
  caller-context isolation, authored timing/offsets, color restoration,
  single/double sound, native SFX volume/mute, completion ownership, headless
  and missing-asset fallback, live pack change, interruption, reset, error
  cleanup and uninstall.
- Gen3 integration adapter contract and SDK **1173/1173** pass.
- Broad source suite: **291 passed, 0 failed, 58 skipped**. Skips require
  external datasets/fixtures; this is not all-game gameplay verification.
- Generated option inventories match live source, 123 catalog entries per
  generation. No option schema was added or removed; the prior all11 native
  registration evidence remains the menu evidence, not proof of full parity.
- Actual bounded native fixtures pass in **all five GBA editions**. Each
  launches a native wild battle on an isolated new-game state, then stages
  native `ShinySeq` calls over the real battle drawing. Tests cover nonshiny
  rejection, enemy/player IDs, two shiny IDs, exactly one continuation per
  sequence, selected-art fallback, live pack change and reset. Voxel-stage
  checks explicitly assert that the stage is active.
- Inspected captures show Crystal black-and-white stars over the native and
  voxel battle presentation, unchanged HUD/commands, and native gold stars
  after selecting the other pack. The player's upper sparkles can overlap the
  native HUD, consistent with that HUD retaining foreground ownership.

Driver: `tools/qa/native-crystal-shiny.lua`.
Scratch runner: `.scratch/voxel-parity-20261015/run-shiny-0389.sh` (workspace
scratch root, outside this repository). Evidence folders:
`.scratch/voxel-parity-20261015/shiny-0389/{firered,leafgreen,emerald,ruby,sapphire}`.
Each contains `run.log`, `single-native-stage.png`, `player-voxel-stage.png`,
`double-voxel-stage.png` and `selected-native-sparkles.png`.

Fixture details: FireRed/LeafGreen Pallet Town and Hoenn Littleroot Town,
cell7,8 facing down; camera35, 480x320, LOW distance, shadows OFF. Selected
Crystal pack, no external companions. Party and shiny PID/OT records are
synthetic QA setup, not player progress. The double check uses native IDs1/3
and public double-coordinate selection; it is not a full double-battle
playthrough. Rendering is frozen between explicit native VM frame steps so
screenshots are reproducible. Null audio output verifies source playback and
volume handling, not audible speaker output. No new saves are written; all
processes close and the pack is restored before exit.

An initial fixture used an invalid FR route identifier and did not assert the
voxel stage. Its appearance was rejected; the final five-game checks use the
valid towns and stage assertions above. Earlier captures are not substituted
for the final checks.

## Remaining non-model parity

Full feature parity remains incomplete. The live inventory keeps these limits:

- Gen2 selected interface art retains native Oak art during indexed palette
  rotation. Native cinematic title scenes have no equivalent of Gen1's
  cycling-starter picture reader.
- Gen2 original HUD scale and Gen3 original HUD scale/color remain native;
  modern HUD consumers work.
- Native specialty-ball, tutorial, Safari and double capture presentation,
  broader send-out/recall effects, Legendary actor materials and optional
  audio remain incomplete. Native gameplay/presentation remains the fallback.
- Regional background/boss artwork and complete map-family routing remain
  incomplete. General Gen3 terrain/tree compression is outside the existing
  authored-geometry cache adapter.
- Standing trainers require an independent compatible public provider.
  Authored scenery/model families have their own unfinished coverage and are
  owned by the separate model worker.

No release, version bump, push or model changes are part of this batch.
