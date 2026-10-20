# Native four-actor release ownership — 2026-10-17

`NativeGen3SendoutShell` now resolves unique native ball cards to the public
`Anim.stage().balls[id]` event for battler IDs0–3. Each event has a separate
cached shell. Doubles trajectories project relative to that owner's native
anchor/world position rather than the default move attacker/target pair.
Coincident ambiguous cards, unsupported ball artwork/effects and capture
sequences retain their native painter. Single-actor projection stays unchanged.

`NativeGen3Release` now retains up to four independent Q57 volume/subject
entries. Original reveal scale drives each pose; native cards keep their own
texture and transforms. Completion, replacement or ambiguity releases only
the affected event's mesh. OFF, provider ownership and battle cleanup clear
everything. A failed individual GPU volume leaves that actor's native shading intact while other events continue. Original ball particles remain because the public pool does not
identify their owners. No animation clock, HP, party, RNG or battle action
changes. The original native 12-frame reveal remains authoritative.

Latest official release was rechecked as0.3.89. The native NVIDIA/LÖVE fixture
`QA_MULTI_RELEASE=1 tools/qa/native-gen3-release.lua` passed all five GBA editions
in isolated voxel-only profiles. It starts a native trainer double battle with
Charizard/Blastoise against Rattata/Pidgey, then explicitly replays all four
public `Anim.sendOutMon` calls simultaneously. This is presentation verification,
not a gameplay four-way switch. Pallet/Littleroot(7,8),down,480×320,camera level3,
distance16,shadowsOFF,original audio. Both OFF/ON runs take36frames; every edition
observes four concurrent release owners,19 volume frames and44 subject draws.
All four identities and HP, final visible/full scale, native particle settling
and OFF cleanup pass; all processes exit0.

Fifteen captures were inspected in shared Projects scratch
`.scratch/voxel-parity-20261017/gen3-multi-release-nvidia-0389`. They confirm shared
shells/material and settled OFF art, but expose a separate native doubles camera
problem: two actors are covered by HUD panels. The camera worker fixed
that issue with an explicit native-pair layout; only that layout uses lateral
±12 and row depth±40 world units, without changing actor scale or gameplay
positions. Ordinary/provider layouts retain±32/±24. Its final all-five rerun
passes the same36/36-frame/four-owner/44-subject checks. Ten final OFF/peak
captures in `.scratch/camera-polish-20261017/gba-pair-*` were inspected: all four
actors now clear the original HUD/commands. A frame-count-only FireRed intro
wait proved unreliable at uncapped speed; the fixture now waits up to30seconds
of real time and captures a timeout, leaving native clocks unchanged.
The first exploratory trainer fixture lacked required trainer text fields and
failed before verification; the final fixture supplies them without engine edits.

Focused single/multi release,31 shell and world-projection tests pass;549option
consumer checks and the generated inventory agree. The combined suite passes
335/0/58 explicit external-fixture skips with both batches. A final isolated
GPU-failure subject guard and stronger cleanup assertions were added afterward;
single/multi release and world-actor focused suites pass again. Remaining: owner-specific replacement of
the unlabelled native particle pool, full optional model deformation and
multi-actor capture. Physical Android/iOS/Windows remain unverified.
