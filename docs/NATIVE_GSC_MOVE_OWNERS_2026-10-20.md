# GSC paired move ownership and projection

Doubles now preserves both native context slots and their original identities
on emitted events. Its optional `nativeAnimationActors()` reader binds this
descriptor to the exact native runner, including the pending after-animation.
Native picture state, HUD clearing, cry/flying readers and object palettes use
that context without swapping live gameplay slots. Failed/stale identities and
unrelated runners retain the original route.

Battle Art consumes this public descriptor to compose each actor independently.
The runner's logical player/enemy picture boxes are separate from the actor's
actual facing, so an ally targeted by its teammate retains its back sprite while
receiving the correct native effect rows. Uninvolved actors keep their own pose.

The original native OBJ painter renders to a small transparent canvas. Its plane
is then projected between the exact actor centers from the same card matrices.
The existing native panel is repainted above the projected effect, preserving
its own HUD-clear state and text. No move timeline, input, sound or damage rules
are replaced. Missing projections, unavailable canvases and optional Stadium
models retain the native particle route. The paired release-particle adapter
also declines model-replaced cards.

## Verification

Official engine **0.3.91**, unmodified `.love` core, existing Linux NVIDIA LÖVE
shell, all seven independent mods and isolated G/S/C QA profiles. Route 29,
(10,6), down-facing, native paired HUD, ROM art/world backs, LOW distance and
shadows/Legendary balls disabled.

Each edition replayed real native move events with staging OFF and ON:

| Context | Native script frames OFF/ON |
|---|---:|
| Player partner → enemy partner, Tackle | 81/81 |
| Enemy partner → player partner, Growl | 212/212 |
| Player partner → player lead, Tackle | 81/81 |
| Enemy partner → enemy lead, Tackle | 74/74 |

All four world cards and both projected centers were asserted during staged
scripts. Actor identity, exact BG/HUD ownership and final cleanup passed.
Twenty-seven final OFF/ON/restored captures were inspected. Scratch evidence:
`move-friendly-0391`; the fixture waits for stage publication before replay.
These are explicit presentation replays of events emitted by the real native
simulator, not a claim of exhaustive full-turn combat verification.

The combined voxel suite passes **346/0/58**. The first run reported fifteen
missing `tests.modkit` dependencies; all fifteen passed after copying the
existing QA-only `modkit`/`fixture_data` directories into the isolated runtime.
No engine source overlay was used. Doubles' native core passes **88 contracts**
using the imported original battle-rule table; its old synthetic fixture needed
raw accuracy bytes and a noncritical Reflect sample. Focused move/release,
projection/failure, paired picture and native layout suites pass.

## Remaining limits

This covers ordinary queued moves and their chained after-animation, including
both friendly-target directions. It is not exhaustive coverage of every move.
Standalone secondary damage-event naming still needs an exact target audit.
Native identity/form proxies that cannot prove the original queued mon retain
fallback. Optional model deformation, paired Legendary Q57 release and GBA's
anonymous native particle pool remain separate work. No full parity claim.
