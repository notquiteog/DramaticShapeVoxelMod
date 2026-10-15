# Native Gen2 send-out audio — 2026-10-15

`Gen2BallAudio` consumes the existing optional Ember sound/volume settings at
Gold, Silver and Crystal's original normal send-out poof. It wraps the public
`BattleState:animForId` runner sound hook only for `ANIM_SEND_OUT_MON`, parameter
0/nil. The separate parameter1 shiny-star arm, cries, move animations and capture
scripts retain their ownership. Selection uses the actual mon's canonical shiny
DVs. No gameplay, native animation timers, skip behavior or party records change.

Replacement suppresses the original cue only after optional playback succeeds.
Missing/failed/throwing playback, OFF, absent stage, stale runner or changed mon
retain the original sound call and returns. Successful voices follow the live
native SFX master and selected volume, and clear on stage disable/battle exit.
Idle updates do not poll assets. Shared capture audio retains its own adapter.

## Evidence

Official **0.3.89** engine and matching native Linux shell, latest release
rechecked by the parent. Production engine source is unchanged; public test
harness support is from0.3.88 because0.3.89 ships without tests.

- Gold, Silver and Crystal each pass **2 replaced send-out cues, 1 failed
  playback native fallback, 1 OFF native cue**, using actual native party
  switches, shiny DV identity and the live native SFX master.
- Focused contracts also cover the separate shiny-star arm, capture isolation,
  missing/throwing playback, exact native arguments/returns, stale runner,
  changed mon, absent stage, idle behavior and lifecycle cleanup.
- Shared final suite: **299 passed, 0 failed, 58 external prerequisite skips**;
  SDK **1173/1173**, native option consumers **549**, inventory consistency and
  diff checks pass. This includes the parent's final optimization batch.

The runtime fixture injects a successful/failed playback sink because optional
Ember files are absent. It observes original native stereo calls to detect
missing fallback or double playback. This proves routing, not audible timbre
or pack contents. Resulting shiny-sendout and OFF battle captures were inspected
for all three editions; actor/UI presentation is retained. This is not a broader
regional art or native HUD framing approval.

Driver: `tools/qa/native-gen2-ball-audio.lua`. Evidence in workspace scratch:
`.scratch/voxel-parity-20261015/gen2-ball-audio-0389/{gold,silver,crystal}/`
contains `run.log`, `shiny-sendout.png` and `off-native.png`; runner is
`run-gen2-ball-audio-0389.sh` in that scratch parent. Final broad log is
`suite-gen2-audio-final.log`. Isolated QA profiles, synthetic two-mon party,
Route29 cell10,6 down, native wild Sentret battle, 480x432, LOW distance,
shadows OFF, no progression save writes. No assets/models/version/release/push
changes.

## Remaining scope

Recall is a concrete engine-seam limitation in official0.3.89. Native
`src/battle/gen2/Battle.lua:Battle:switch` emits a send event without a recall
animation/sound event; `switchEnemy` additionally emits a generic translated
withdrawal message. `src/ui/gen2/BattleState.lua` has no dedicated recall cue.
The rule-level `battle.battler_switched` event fires before the display queue is
played. Using it would move sound timing, and parsing translated message text
would be fragile, so neither is used as a substitute.

Optional Ember files are not bundled. Full audible pack coverage and nonstandard
capture paths remain unverified. Shared send-out geometry/material effects,
Gen2 tutorial/contest capture presentation, specialty-ball art and remaining
native map/interface families remain separate work. Live inventory stays
partial; menu availability is not a full-parity claim.
