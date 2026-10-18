# Native GBA last-wild capture — 2026-10-17

`Gen3Capture` now follows either surviving opponent in a native doubles battle.
Doubles passes the original catch sequence a detached view selecting its target.
The voxel adapter associates that view with the public live battle only when
its battler table and selected enemy match, the target is ID1 or3, and the other
opponent is no longer alive. It retains the detached view as the shared prop's
owner, while rendering its arena and intake material at the live selected slot.
Unrelated views, two living opponents, absent geometry and OFF retain fallback.
Native odds, item removal, actor transforms, timing and storage remain original.

## Verification

Latest official release rechecked through the GitHub releases API: v0.3.89.
Actual NVIDIA desktop LÖVE runs used isolated imported FR/LG/Ruby/Sapphire/Emerald
profiles, all seven companions installed, native UI explicitly selected,
Littleroot/Pallet at7,8 facing down, 35-degree world battle camera, LOW distance,
shadows OFF and ROM sprites. The public Doubles organic encounter/partner APIs
create Rattata/Pidgey against Charizard/Blastoise. No model or engine code changed.

Committed driver: `tools/qa/native-gen3-pair-capture.lua`. First, explicit native
absence flags stage each last-foe case and replay original zero-shake breakout
presentation with OFF and ON. This is a presentation fixture, not a gameplay KO.
All five editions finish **221/221 frames for both target IDs**, preserve native
identity/HP, party and bag, and clear capture ownership. The final fixture waits
for native particles/fade before recording the restored scene.

Then each edition invokes the real public `gen3Capture.choose` command with a
Master Ball for the surviving partner. Native odds guarantee the catch; the
checks confirm one item removed, the unrelated Poke Ball stack unchanged and
exactly the selected partner stored once. No catch result or storage method is
mocked. The earlier replay does not spend items or store Pokemon.

Scratch evidence: `voxel-parity-20261017/gen3-pair-capture-nvidia-0389/` contains
per-edition logs, two intake captures and restored views. Fifteen final scene
captures were inspected: the prop and bright intake follow the correct original
opponent; the other visible cards remain normal and the native HUD remains clear.
The post-catch image can be a native scene-transition fade; storage verification
comes from state assertions, not that image. Preliminary fixture setup lacked a
player name, and its first modern-UI run was not native-HUD evidence; both were
corrected before the recorded final batch. User saves were not written.

Focused capture/tint/world-card checks pass, including independent target
selection, wrong-owner/two-foe fallback, departed-scene cleanup and graphics-state
restoration. Shared suite: **335 passed, 0 failed, 58 explicit external-fixture
skips**. Live inventory validation: **549 checks**, generated123-key inventories
match source. Counts and partial status remain unchanged.

GSC last-wild capture, GSC actor-targeted animation/release, native ownerless
release particle replacement and provider-specific model deformation are
separate remaining work. This batch does not certify physical mobile devices,
optional audio recordings, arbitrary partners, every specialty-ball visual or
complete feature parity.
