# Native Gen2 capture audio — 2026-10-17

Gen2BallAudio now consumes the original capture runner's throw/open/bounce/shake/
breakout cues even when specialty balls, contest Park Balls or trainer-blocked
throws retain their native visual presentation. Successful optional playback
suppresses only that cue; missing/failed playback, OFF, unrelated sounds and
stale runners call the original hook. Supported 3D capture keeps exclusive
ownership, including failed-playback fallback. The native caught jingle still
owns its message wait. No animation clocks, RNG, inventory or capture rules change.

Verification used official engine0.3.89 (latest release rechecked2026-10-17),
its packaged Linux LÖVE shell and isolated Gold/Silver/Crystal QA profiles.
`tools/qa/native-gen2-capture-audio.lua` starts a native Route29 battle at(10,6),
facing down, voxel4, distance16, shadowsOFF, 3D battleON and Ember selected.
It then calls the public original capture-animation entry with Love/Park/Poke
and blocked-throw parameters. Each runs OFF, successful sink and failed sink.
These are original-script integration checks, **not complete item/contest turns**.
Optional recordings are not bundled; the explicit playback sink does not verify
audible content. No rendered appearance changes or visual acceptance are claimed.

All36 script runs passed. Each ordinary escape retained324 native ticks and one
RNG call; each blocked throw retained55 ticks and zero RNG calls. Successful
playback replaced4 ordinary cues or1 blocked cue. Failed playback restored all5
ordinary native sounds or the1 blocked sound. Party/enemy identity and HP stayed
unchanged. Focused mocked checks:29 new checks plus existing capture and send-out
suites pass, including real production wrapper order and no double retry.

Reproduction runner: `run-gen2-capture-audio-0389.sh` in the session's
`voxel-parity-20261017` scratch directory; logs are under
`gen2-capture-audio-0389/{gold,silver,crystal}/run.log`. All processes exited0;
normal saves untouched. Playback hooks were restored before exiting.

Remaining limits: specialty/contest/blocked visuals retain native animation;
doubles remain native, recall has no separate native sound/animation cue,
result jingles keep their native timing ownership, and optional audio asset
coverage remains unverified. Overall parity remains partial.

## Native GBA specialty and ghost audio

Gen3Capture now gives the seven native specialty balls and ghost dodge their own
optional audio session, retaining their native props, transforms and trajectory.
Only successful playback suppresses throw/open/shake/breakout/click cues. Caught
result jingles remain native. Reset/OFF/uninstall dispose owned audio; no shared
3D capture prop is created. Unsupported targets/doubles/headless remain native.

The same official0.3.89 runtime passed120 original-sequencer runs across FR/LG/
Ruby/Sapphire/Emerald: seven specialty balls and a ghost-dodge Poke Ball, each
OFF/successful sink/failed sink. Each specialty escape retained339 native ticks;
each ghost throw retained52. Native sound calls were restored exactly on failure;
party identity/HP and native geometry ownership remained unchanged. This runs
public CatchSeq/Anim updates in a native battle, not full item turns or auditory
or rendered acceptance. Focused capture/shared-audio/sendout suites pass.

Fixture: `tools/qa/native-gen3-specialty-audio.lua`; scratch runner
`run-gen3-specialty-audio-0389.sh`, logs
`gen3-specialty-audio-0389/<edition>/run.log`.480x320, native level3, shadowsOFF,
distance16, wild Rattata battle from the edition's starter town. Processes exited0;
isolated QA profiles only. Source-only after the Gen2 audio checkpoint d537a44.

A separate source audit corrected the Oak limitation: native defaultSteps rotates
only Oak/player trainer portraits. Its Pokemon demo uses the already-adapted wipe.
Custom Pokemon rotation remains a guarded fallback, not a missing vanilla route.
