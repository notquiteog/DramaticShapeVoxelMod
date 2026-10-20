# GSC faint/LCD composition — 2026-10-17

The world-card adapter previously declined a sinking picture whenever lifted
rows or LCD effects were present. It now moves the picture by the original fitted
slot's faint progress and intersects its ground crop with each existing band/
scanline clip. LCD displacement moves the source crop with that source row;
the final lifted pass retains its own position. Nested scissor, palette, canvas
and color state restore after successful, empty and failing draws.

This extends the existing fixed-ground faint presentation; it does not change
native faint duration, battle events, HP or the original animation runner.
Substitute dolls keep their native rule of ignoring the mon's faint crop.
Unsupported animated doubles continue through the native painter.

## Verification

Official latest release rechecked through GitHub API immediately before the
batch: v0.3.89 (`latest-faint-release.json` in scratch). Native Linux NVIDIA/LÖVE,
voxel alone, isolated Gold/Silver/Crystal QA profiles. Driver:
`QA_FAINT_COMBINED=1 tools/qa/native-gen2-staged-bands.lua` using the established
native desktop runner. Route29(10,6), down;480x432, voxel35, world back sprite,
ROM art, shadowsOFF, distance16, Legendary ballsOFF, ORIGINAL audio.

The fixture explicitly adds the original `faintSlide` presentation state while
an original imported move script has a lifted band. It discovers the affected
actor from `animPicState`; the animation's invoked side is not always the actor
its script lifts. This is a presentation-combination regression, **not** proof of
a naturally occurring gameplay KO with overlapping move animations. Native
update owns the resulting faint progress and animation pause/resume.

G/S/C all pass Acid Armor83/83 and Agility118/118 original OFF/ON runner frames,
both invoked sides, unchanged party/battler identity and HP. Each run observes
264 source-crop calls,104 lifted-band calls and260 raster calls (preparation
observations include OFF). Twelve overlap captures inspected: cropped/sinking
cards retain their lifted/LCD displacement and world grounding. Native scripts
blank the HUD during these effects; the mod does not fabricate its contents.
All processes exit0; no user saves or engine files modified.

Evidence in shared Projects scratch:
`.scratch/voxel-parity-20261017/gen2-faint-bands-nvidia-0389/{gold,silver,crystal}`,
with `contact.png`. Focused band/compositor, capture/release,549 option checks
and202 SDK checks pass. The preceding shared332/0/58 run predates this small
crop batch; it is not relabeled as a new broad run. Device mobile/Windows and
animated doubles remain unverified/unimplemented respectively.
