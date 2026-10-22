# Release and recall boundaries on official 0.3.95

Source inspection on 2026-10-22; this is not a runtime visual certification.
Applies to FR/LG/Ru/Sa/E releases and G/S/C recalls. No production engine edits
or assumed timing have been introduced.

## GBA release ownership

`src/core/game3/battle/ball_open.lua` still receives a side in `start` (402),
but the particle task (407–412) and private `spawn` record (224–230) discard it.
`particles()` (498) returns these anonymous records; `draw` (546) draws all of
them in one call. `startParticles` and capture stars can also produce particles
without an actor identity.

Battle Art already implements the safe subset in `NativeGen3ReleaseParticles`:
an idle public `start` gives an exclusive owner epoch. Native particles follow
that actor's projected ground anchor. A second start, anonymous particle start,
actor replacement, battle replacement, OFF or cancellation relinquishes the
claim. This is usable release support, not a missing option. It does not claim
simultaneous ownerless effects or substitute guessed screen-coordinate owners.

To close simultaneous-release parity in a distributable mod, the engine must
carry the canonical battler ID from `start` through its particle task and spawn
records and expose it at each particle draw. An optional explicit owner on
`startParticles` is also needed where callers know it. Unowned capture stars and
unrelated effects must remain unowned. This can preserve existing public
signatures and native scheduling, unlike a mod that rewrites private tasks.

## GSC recall timing

`src/battle/gen2/Battle.lua` `switch` (4410) queues only a `send` event; the
immediate `battle.battler_switched` notification describes logical state, not a
presentation clock. `switchEnemy` (4927) adds a localized withdrawal message
followed by `send`. `src/ui/gen2/BattleState.lua` (2366–2410) handles send-out
animation and cry but has no recall presentation or recall sound event.

A correct closure requires an engine recall presentation event before send-out,
with original outgoing actor identity and ROM-accurate animation/audio timing.
It must distinguish voluntary switches, faint replacements, forced switches and
Pursuit outcomes, respect BATTLE SCENE OFF, and preserve the native event queue.
The mod can then attach its optional shell/audio to that cue. Translating message
text, firing sound at logical switch notification, or waiting an arbitrary
interval cannot provide equivalent behavior.

These two engine seams are absent from the inspected release. Existing native
fallbacks remain correct; neither gap can honestly be marked fully implemented
by adding another settings row or by passing mocked tests.

## Capability adapter prepared in this batch

The mod now optionally consumes `BallOpen.currentParticleOwner()` during each
native particle draw. The public function must return `nil` for unowned effects
or `{state=battleState, id=canonicalBattlerId, actor=originalBattler,
mon=originalMon}` captured at creation. The engine must scope it to the current
particle draw and restore it afterwards, including errors. IDs are integers0–3;
the mod validates state, actor and mon against the live battle before use.
Invalid/error ownership retains native projection, never another actor's anchor.
Anonymous particles may use the existing exclusive epoch only when that epoch
was independently proven; overlapping anonymous effects remain native.

This is an optional adapter contract, **not an API present in engine0.3.95**.
Older engines keep exactly the existing exclusive-epoch behavior. Mocked
regressions cover the future capability, all four identities, stale ownership,
anonymous effects, OFF and query errors. Runtime capability verification awaits
an engine implementing this public seam.

Verification after the coordinated code batch: `luajit
 tests/native_gen3_release_particles_test.lua` and `luajit
 tests/gen3_world_battle_test.lua` both pass; `git diff --check` passes.
These are CPU/mocked ownership and projection regressions. No runtime visual or
physical-device claim is made for the proposed engine capability.
