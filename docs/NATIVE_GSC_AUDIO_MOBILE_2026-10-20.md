# GSC release audio and mobile resource checks — 2026-10-20

Official engine 0.3.91, isolated Gold/Silver/Crystal profiles, all seven companions,
original trainer doubles on Route29 at10,6/down, ROM world cards, camera35,
shadowsOFF and distance16. The current native send-out runner owns the sound
clock; its visual size step no longer emits a second legacy Q57 close cue.
Audio hooks also retain their originating battle identity, release voices when
that battle is replaced, and leave terminal phases to the original sound path.

Each edition passes all four slots with successful optional playback, failed
playback and OFF: respectively1/0,1/1,0/1 optional/native cue counts. Normal and
shiny actors retain their own variants, identity and HP. These are playback-sink
routing checks, not certification of optional recordings or audible quality.

Gen2 staged canvases now use native logical pixels (DPI1), explicitly release
replaced allocations and register for public Assets cleanup. A failed allocation
is not retried every frame at the same size; smaller retained artwork still works
and cleanup resets the failure memo. Focused tests cover these transitions.

Six rendered screenshots were inspected at320×240 and240×360. Actors and command
panels remain in frame, but native doubles HUD lettering loses pixels in its
existing fractional low-resolution composition. This remains follow-up work;
these images do not establish small-screen text readability or device parity.
The original engine debug overlay also labels Crystal as Gold in portrait; this
is its GS-family label, not a different loaded game.

The standalone actual-driver `tests/q57_shader` probe passes volume/subject draw,
visible-pixel readback and shader/color restoration on NVIDIA desktopOpenGL3.3
and GLES3.2. This is not an Android/iOS-device test. Native phone lifecycle,
notches, thermal/memory pressure and touch keyboards remain unverified.

Shared current-source suite:349 passed,0 failed,58 missing external-fixture skips.
Includes the concurrent camera source; Python importer checks are separate.
Scratch evidence: `voxel-parity-20261020/pair-audio-mobile-final-0391`,
`q57-shader-gl.log`, `q57-shader-gles.log`, `audio-mobile-suite.log`.
The engine archive SHA256 remains
`3b297362a871c6decf2d6d78681a601adf2546c29b436a5bce2ee7ce5ac11de4`.
Native runs use the existing extracted LÖVE shell and official engine core;
only the QA harness support comes from the older test distribution.
