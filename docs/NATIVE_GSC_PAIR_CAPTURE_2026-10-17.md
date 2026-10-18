# Native GSC last-wild capture — 2026-10-17

`Gen2Capture` now accepts the native doubles companion's last-wild capture only
when `activeMon('enemy')` is the living native primary and the publicly shown
partner is absent or fainted. The companion owns any promotion into that slot;
voxel neither selects targets nor rearranges combat state. Two living foes,
queued identity disagreement and reader failures preserve native presentation.
The audio-only adapter uses this same guard for supported native cues. Finished
or replaced runners now clear their shared capture resources on the next update.

Latest official release rechecked: v0.3.89. Actual NVIDIA desktop LÖVE fixtures
used isolated imported Gold/Silver/Crystal profiles with all seven companions,
native paired HUD, ROM sprites, world back cards, 35-degree camera, LOW render
distance and shadows OFF. Public Doubles encounter/partner APIs create
Sentret/Pidgey against Cyndaquil/Totodile on Route29 at10,6 facing down.

`tools/qa/native-gen2-pair-capture.lua` explicitly sets the partner's HP to zero
for a last-foe presentation replay. Original Poke Ball breakout scripts finish
in **324/324 frames with1/1 RNG calls** with effects OFF/ON in all three editions.
That comparison does not simulate a gameplay knockout or spend an item. Next,
the fixture marks the primary fainted and calls the actual native `useItem`
with a Master Ball. The companion promotes Pidgey; the native catch consumes
exactly one ball and adds that same partner to the party once. Native dialog
confirm input is required to progress the real catch; an initial no-input wait
stalled and was corrected. No odds/storage methods are mocked.

Six final intake captures were inspected across all three editions. The ordinary
and promoted native target receive their own ball/intake; allied cards remain
unchanged and the native HUD remains visible. Scratch evidence lives under
`voxel-parity-20261017/gen2-pair-capture-nvidia-0389/`, including per-game logs and
`review.png`. Crystal's native debug overlay says POKEMON GOLD because it uses
the engine's GS display field; the selected ROM and driver identify Crystal.
No player save was written. Naming and return-to-world were not independently
reverified by this bounded capture fixture.

Focused capture and audio tests cover target identity, two-foe/dead/reader-error
fallback, OFF, native return values, optional playback failure and runner cleanup.
The32-check native capture-audio test and549 option checks pass. Shared suite
results are recorded in the handoff. Partial inventory rows remain partial:
GSC actor-targeted move/release ownership, native ownerless release particles,
provider-specific models and absent optional assets remain separate work.
