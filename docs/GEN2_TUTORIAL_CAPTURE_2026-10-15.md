# Native Gen2 tutorial capture — 2026-10-15

The existing shared capture adapter now accepts the DUDE's ordinary Poke Ball
throw in Gold, Silver and Crystal. Original `startBallAnim`, sound, wobble and
caught events drive the same prop/intake/result presentation used by normal
wild captures. The tutorial has no player Pokemon; the original DUDE backpic,
menu, temporary pack and automatic input remain engine-owned. No native phase,
result, timer, bag or party mutation is introduced.

OFF, missing stage/unsupported balls and contest Park Balls retain native
presentation. Tutorial capture uses the original guaranteed result and its
no-storage return; ordinary wild catches still use the existing native odds.
Audio continues to replace native sound only after optional playback succeeds.

## Evidence

Latest official release was rechecked through the GitHub releases API for this
batch: **v0.3.89**, published2026-10-15T16:20:04Z. Matching native Linux shell and
unmodified production engine source;0.3.88 public QA support files supply the
harness absent from the0.3.89 archive.

Gold, Silver and Crystal ON each pass **one native throw, one shared start,
one poof and one caught edge**. Crystal OFF passes one native throw and zero
shared capture events. Final capture/returned-world screenshots were inspected
for all four cases. Focused capture/audio contracts and549 inventory checks
pass. Final broad suite: **299 passed, 0 failed, 58 external prerequisite
skips**, including SDK1173/1173; log `suite-gen2-tutorial-final.log` in the scratch
parent. No source/model/version/release changes outside this scoped adapter.

The fixture starts `World:startCatchTutorial` with the original CatchTutorial
auto-input stream, then lets native menus, pack selection, throw, catch and exit
run. It does not force the result or skip tutorial phases. The driver performs
the caller's normal input-stream cleanup after return. It checks one native
throw, one shared capture start/poof/caught edge, original DUDE/empty-party
identity, restored player name/text speed, unchanged real party/bag and no
caught-dex registration. A dedicated OFF case checks native ownership.

Driver: `tools/qa/native-gen2-catch-tutorial.lua`. Workspace evidence under
`.scratch/voxel-parity-20261015/gen2-catch-tutorial-0389/`; each game directory
has `run.log`, `capture.png`, `returned.png`. Isolated QA profiles, synthetic
one-mon party, seven real Poke Balls/three Potions, Route29 cell10,6 down,
480x432, LOW distance and shadows OFF. Native route-script movement after the
demo is not suppressed. No progression save writes. The initial Crystal return
capture was still inside the original white exit fade; final verification waits
90 frames before the returned-world capture.

## Remaining scope

Contest Park Ball art, other specialty balls, trainer-blocked throws and doubles
retain native capture presentation. Send-out geometry and full native actor
material effects remain separate parity gaps; Gen2 recall audio still lacks a
dedicated native display cue. This batch does not author models or reframe the
native tutorial HUD. Optional audio-file contents and complete regional art
coverage are unverified. Inventory stays partial; no full-parity claim.
