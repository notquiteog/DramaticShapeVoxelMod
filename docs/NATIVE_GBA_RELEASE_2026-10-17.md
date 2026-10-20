# Native GBA shared release material — 2026-10-17

`NativeGen3Release` connects the original single-actor send-out to the existing
Q57 volume and subject material. It accepts the exact visible `Anim.stage().balls`
event/battler identity already matched by `NativeGen3SendoutShell`, then reads
`Anim.present(id).scale`. The original twelve-frame reveal maps onto the shared
release profile; native throw/reveal duration is unchanged. The subject uses the
same native card texture/matrix, including its already-baked scale, offset and
mask. It is not scaled or deformed a second time.

The volume uses the actor's world anchor and the existing shell aperture. Its
GPU mesh is reused for that event and released at completion, OFF, cancellation,
owner change or scene teardown. Missing GPU resources/material, unsupported
balls, ambiguous cards, absent actors, capture, doubles and independent release
providers retain native presentation. Shadows continue using the original card
and existing shell caster.

Native ball particles remain untouched. The public `BallOpen.particles()` list
has no actor/event identifier, while `BallOpen.draw()` draws the whole pool.
Replacing it globally could hide another effect; this adapter does not read or
mutate private task arrays. Actor-specific native particle replacement and full
provider-model deformation remain unfinished. This is a real shared-material
consumer, not a claim of complete release/capture parity.

## Native verification

Official0.3.89 (latest rechecked2026-10-17), native Linux NVIDIA/LÖVE, voxel-only
isolated `native-options-{firered,leafgreen,ruby,sapphire,emerald}-qa` profiles.
Driver: `tools/qa/native-gen3-release.lua`. Pallet or Littleroot cell(7,8), down;
480x320, voxel level3, distance16, shadowsOFF, Legendary ON/OFF, ORIGINAL audio.
The fixture creates a level35 Charizard and a native Rattata encounter, reaches
command mode, and calls the original `Anim.sendOutMon` presentation with its
original completion callback. This is not a gameplay switch assertion. Test
foreground focus is deterministic; no user save or engine source is changed.

All five editions pass OFF/ON36/36-frame equality,10 shared-volume and11 shared-
subject draws, unchanged battle/actor identity and HP, original final visibility/
scale, fully settled native ball fade/particles and OFF cleanup. All exit0.
Fifteen captures inspected: opening, peak blue-white volume/white subject,
restored original artwork for each edition. Early preliminary OFF shots were
still in the native purple color fade; the final fixture waits for `BallOpen.active()`
to clear. A preliminary rerun lost desktop focus before command mode; the final
foreground fixture resolves that test setup failure.

Evidence: shared Projects scratch
`.scratch/voxel-parity-20261017/gen3-release-nvidia-0389/{firered,leafgreen,ruby,sapphire,emerald}`
plus `contact.png`. This validates these native single-actor pictures/materials;
it does not certify every camera angle, all ball species, provider models,
Windows/iOS/Android hardware or arbitrary concurrent effects.

Focused native release, shell27 assertions, actor capture/shadow, capture tint
and549 option-consumer checks pass. One shared full suite on current root/camera/GSC/GBA source passes332, fails0,
and skips58 explicit external-fixture cases (`shared-release-tests.log`). This
includes the new shader failure test; no failed case was silently skipped.
