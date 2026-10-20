# Native GSC substitute and LCD combinations — 2026-10-17

Substitute dolls now remain world actors during original lifted-row and LCD
scroll effects. They keep their native16px dimensions, fixed native picture
coordinates and species/shiny palette instead of inheriting Pokemon resize.
The final lifted pass retains the doll's slide: native `drawPic` deliberately
sets that X after normal lifted-pass handling. Frame ownership, gameplay,
animation timers, audio and original OFF behavior remain unchanged.

Focused tests cover combined raster/lifted placement,16px sizing, viewport
clipping at the enemy doll's112px origin, palette/scissor restoration and failed
render fallback. Existing picture, capture and audio contracts,549 native option
checks and202/202 engine Gen2 SDK checks pass. The preceding shared329 passing
suite coverage predates this follow-up; it is not relabeled as a new full run.

Gold/Silver/Crystal native Linux NVIDIA/LÖVE fixtures pass on official0.3.89,
latest checked2026-10-17. `native-gen2-staged-bands.lua` with `QA_SUBSTITUTE=1`
sets only fixture substitute state, then runs original ACID_ARMOR and AGILITY
scripts on both sides with3D OFF/ON. Both paths retain83/118-frame clocks, HP,
party and enemy identity. Each observes724 band and520 raster preparations,
including preparations while OFF. This does not test Substitute's gameplay HP
cost. All three processes exit0 and twelve current captures were inspected.

Route29(10,6), down,480x432, level4, distance16, shadowsOFF, ROM/WORLD art,
Legendary ballsOFF. The small doll stays on the world ground, original raster
stretching appears, and its ordinary portrait returns when each animation ends.
Native large HUDs obscure most of the small enemy doll at this resolution; this
existing camera/UI framing issue was reported to the camera worker. These
captures do not certify unobstructed enemy framing or mobile rendering.
Evidence: session scratch `gen2-substitute-effects-nvidia-0389/`, edition logs,
`contact.png`. Player saves are untouched.

Combined faint+raster/lifted effects, animated doubles and full Legendary
release choreography remain implementable gaps. Missing special-pose resources
and other provider limits stay documented in `PARITY_AUDIT_2026-10-17.md`.
