# Native Gen3 capture-card intake color — 2026-10-15

The shared capture sequence already published its intake color/full-bright
state, but native GBA actor cards did not consume it. `NativeGen3CaptureTint`
now applies the same GB card effect to the active single-capture enemy card.
It leaves the original native sprite transform, shrink, mask, timing and
texture unchanged; applying the shared scale again would double-transform it.

The effect bypasses scene lighting and shadow lookup for that draw, then
restores tint, day tint, lighting and flatten state. A native draw failure also
restores this state before propagating its error. Other actors, trainers,
particles, shadow casters, disabled/unavailable captures and inactive intake
use the original renderer. No model or optional provider assets are changed.

## Evidence

Official **v0.3.89** and matching native Linux shell. The official release API
was rechecked immediately before this batch. Production engine source remains
unmodified; public QA harness support is from0.3.88 because0.3.89 omits tests.

FireRed A/B captures use the same native Safari fixture; the baseline bypasses
only the new tint consumer. Its ordinary purple Rattata remains visible during
shared intake. The enabled capture shows the shared red/full-bright conversion.
These are visual comparisons, not a pixel-identity benchmark; native incidental
identity, frame timing and animation can differ. Both preserve Safari balls
30→29, exactly one stored Pokemon, the ordinary bag and capture reset cleanup.

All five native editions pass actual intake draws: **FR26, LG21, RU25, SA27,
EM25**. All retain original counters, storage and reset behavior; intake captures
were inspected for each. FireRed OFF records **zero** tint/3D capture draws and
retains native animation; its capture/result images were inspected. Final broad
suite **300 passed, 0 failed, 58 external prerequisite skips**, including
SDK1173/1173; inventory consumers549 and generated consistency pass. Final log:
`suite-intake-tint-final.log` in the scratch parent.

Focused contracts verify actual-target isolation, unchanged card matrix/texture,
exact native returns, missing/disabled/inactive fallback, shaded/unlit restoration
and error cleanup. The native renderer regression retains ground placement,
shadow transforms, native UI isolation and target projection.

Driver: `tools/qa/native-gen3-capture-scenes.lua`, optional
`VERIFY_CAPTURE_TINT=1` instrumentation. Evidence under workspace scratch
`.scratch/voxel-parity-20261015/capture-tint-0389/`; `intake-tint.png`, native
capture frames/result and `run.log` per game. `firered-safari-before` uses
`TINT_BYPASS=1`, and `firered-safari-off` uses `CAPTURE_OFF=1`. Isolated profiles,
native Pallet/Littleroot fixture cell7,8 down, 480x320, LOW distance/shadows OFF,
synthetic Safari battle/party and no progression save writes.

## Remaining scope

This aligns the existing GB sprite-card intake color consumer. It does not
port model-specific Q57 rig materials, replace native actor transforms, add
send-out/recall geometry or invent specialty-ball models. Unmodeled specialty
balls, doubles/other targets and ghost-dodge paths retain native capture.
Independent model providers keep their ownership. Inventory remains partial;
full feature or regional-model parity is not claimed. A separate reader audit
also identified native Gen3 trade/hatch interfaces still outside
NativeInterfaceArt scope; the inventory now explicitly marks that gap.
