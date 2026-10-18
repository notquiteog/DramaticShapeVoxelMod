# Native GSC Legendary send-out — 2026-10-17

`NativeGen2Sendout` reads the public live screen's `afterSendOut`, `activeMon`,
and animation ID/parameter. The event table is the identity: a repeated send
creates a new cue, while the native shiny arm cannot start another release.
`BattleScene.updateSendout` feeds that cue to the existing shared Q57 shell and
energy. The native picture reveal, grow, cry, shiny script and gameplay keep
their original clocks. Native completion/B cancellation clears the effect.

The native normal particle painter is suppressed only after shared geometry
successfully draws for that exact event; shiny stars always remain native.
OFF, unavailable stage/geometry, wild opponents, doubles, capture ownership,
stale identities and unrelated animations retain their native routes. An
independent `legendaryModelRelease` provider keeps precedence over this reader.
No native runner fields, battlers, HP, inventory or animation callback results
are rewritten.

## Verification

Official engine0.3.89 (latest rechecked2026-10-17), native Linux NVIDIA/LÖVE,
isolated `native-options-{gold,silver,crystal}-qa` profiles, voxel alone. Driver:
`tools/qa/native-gen2-sendout.lua`. Route29 cell(10,6), down; 480x432, voxel35,
world back sprite, ROM art, arena fillOFF, shadowsOFF, distance16, ORIGINAL audio.
The fixture creates a shiny level30 Cyndaquil and a native Sentret encounter,
then invokes the original send-out presentation, not a gameplay party switch.

All G/S/C pass original OFF/ON script108/108-frame equality, unchanged battle/
mon identity and HP, one cue across the shiny arm, native B cancellation and
empty release pose after OFF. Each native process exits0; user saves untouched.
Nine captures inspected: normal shell opening, later native shiny reveal and
restored OFF for all three games. The original species colors/flames remain
unchanged; the Cyndaquil flame artwork in the later captures is not evidence of
release energy. Early captures show the shared shell and its small central
energy. Native indexed shiny flashes can briefly affect HUD colors; they restore.
Evidence: `.scratch/voxel-parity-20261017/gen2-release-nvidia-0389/{gold,silver,crystal}`
and `contact.png` under the shared Projects scratch root.

Focused cue/particle-ownership, capture, audio, dependency and Q57 control tests
pass;549 option-consumer checks and202 SDK checks pass. No broad-suite count is
inferred from these targeted reruns.

## Remaining scope

Trainer-enemy eligibility is unit-tested, not an actual trainer-send-out fixture
in this batch. Multi-actor release/capture ownership and GBA full shared release
remain unfinished. Selected model subject materials depend on that provider;
this does not manufacture missing models. Device Android/iOS/Windows execution,
audible optional recordings and arbitrary camera/HUD framing are unverified.
