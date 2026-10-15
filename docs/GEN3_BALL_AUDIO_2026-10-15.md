# Native Gen3 send-out and recall audio — 2026-10-15

`NativeGen3BallAudio` adds consumers for the existing optional Ember sound and
volume settings during native send-outs and withdrawals. It uses the original
SE_BALL_OPEN event, public native intro/switch step data and stage ball records.
The initial allied intro emits sound before frame1; the adapter recognizes that
native step without delaying the cue. Explicit native switch IDs preserve the
second allied slot's identity. Shiny selection uses the actual native battler.

Only successful optional playback replaces the matching native sound. Capture
sequences retain Gen3Capture ownership. OFF, missing/failed playback, explicit
mixer options, headless/inactive battles, ambiguous simultaneous intro opens and
unrelated sounds retain their original call and return. The native sequencer's
return values and errors are preserved, and scoped withdraw context restores on
error. Optional voices follow the live native SFX master/selected volume and
clear on battle exit, disable or mod unload. With no played optional voice, the
update hook returns immediately; it does not poll assets every frame.

## Evidence

Official **0.3.89** engine and matching Linux native shell; latest official
release rechecked by the parent for this work. Production engine source is
unmodified. Public test harness support comes from0.3.88 because the official
0.3.89 package omits tests. No model, asset, version, release or push changes.

- Focused contracts pass for send-out/recall, initial sound-before-frame change,
  shiny/second-slot identity, native master, exact fallback arguments/returns,
  capture isolation, explicit mixer options, ambiguous double intros, missing,
  failed or throwing playback, lifecycle sync/cleanup and native error cleanup.
- Native FireRed and Emerald fixtures each pass **3 replaced cues, 2 failed
  replacement fallbacks, 2 OFF native cues**, with actual native party switches.
  Shiny routing and party count pass; resulting native battle images inspected.
- Final broad suite: **297 passed, 0 failed, 58 skipped** for external fixture
  prerequisites; SDK **1173/1173**, inventory consumers **549**, and generated
  inventory consistency pass. The integration fixture was updated to mock the
  new adapter dependency; no production fallback was weakened to satisfy it.

The runtime driver injects a successful/failed playback sink because optional
Ember files are **not bundled**. It observes original native mixer calls to
verify that successful replacement does not double-play, while failed/OFF
replacement still invokes native sound. This proves routing and native behavior,
not timbre, audible pack contents, audio-device quality or full asset coverage.
Native field/actor art and UI remain unchanged.

Driver: `tools/qa/native-gen3-ball-audio.lua`. Workspace evidence:
`.scratch/voxel-parity-20261015/ball-audio-0389/{firered,emerald}/run.log`,
`shiny-sendout.png`, `off-native.png`; runner `run-ball-audio-0389.sh` in that
scratch parent. Isolated QA profiles, native Pallet/Littleroot cell7,8 down,
480x320, LOW distance, shadows OFF, synthetic two-Pokemon party and wild battle,
no save writes. Final suite log `suite-ball-audio-final.log` in the same parent.
The initial FireRed fixture exposed the intro event order and was rejected;
the corrected final native checks are the accepted evidence.

## Remaining scope

All five native GBA games share these original engine seams, but actual runtime
audio routing here is verified in FR/E only. Individual double-switch IDs have
focused coverage; simultaneous double intros keep native audio because one cue
can refer to multiple battlers. Full doubles/link/tutorial audio playthroughs
and actual optional audio-file coverage remain unverified. Gen2 send-out/recall
still need their separate event adapter. Full shared send-out geometry/material
effects, other specialty-ball art, native Gen2 contest/tutorial captures and
remaining backdrop/interface specifics remain separate parity work. The live
inventory retains partial status; no full feature-parity claim is made.
