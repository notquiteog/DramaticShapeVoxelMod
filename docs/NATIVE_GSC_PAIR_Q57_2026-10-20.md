# GSC paired Legendary release subjects

The paired native painter previously supplied one combined canvas for each
team, while Q57 addressed only the leading slots. Applying release material to
that canvas would alter both teammates. The renderer now receives independent
actor cards only during an exactly identified release. Their matrices reproduce
every original composite pixel, anchor and orientation; the existing camera
and native HUD remain unchanged.

The adapter saves a body-only copy before original smoke is painted, retaining
both canvases. Q57 volume and subject use the selected actor's exact world
matrix. Original picture-size commands govern progress; no additional body
scaling or timer changes are introduced. Shiny stars, cries, native completion,
OFF, model-provider precedence and missing/failed geometry retain native
ownership. Failed body copying keeps original smoke and restores graphics
state. No models, artwork, gameplay or companion implementation changed.

## Verification

Latest official engine0.3.91 was checked before the batch. Unmodified official
core, Linux NVIDIA LÖVE shell, all seven independent mods, isolated QA profiles.
Each Gold/Silver/Crystal fixture starts an original trainer battle on ROUTE29,
cell10,6 facing down, camera4, WORLD backs, ROM art, shadowsOFF and distance16.
The party is Cyndaquil/Totodile; the opposing pair is Sentret/Pidgey, with the
second opponent shiny. Each original sendout is replayed with the option OFF
and ON. No normal player save is written.

All three editions pass:

- Player, player2 and enemy:39/39 native animation frames.
- Shiny enemy2:108/108, including native star choreography.
- Exact four mon identities and HP retained; only selected actor draws Q57.
- Forced material failure retains the native body/smoke.
- Mid-release OFF clears Q57 without replacing the original event or clock.

Eighteen final captures were inspected: four slot releases, failure and restored
scene in each edition. Teammates retain their native art and positions; native
HUD/commands remain above the release. Crystal's debug caption uses the engine's
GOLD label, while the selected runtime/profile and dataset are Crystal.
Scratch evidence is `voxel-parity-20261020/pair-q57-final-0391`, driven by
`native-gen2-pair-q57.lua`; this is functional/visual evidence, not a timing
benchmark or phone-platform certification.

Focused tests verify mirrored/rotated matrix equivalence, exact event/mon
ownership, no duplicate pass, provider/missing-material/OFF paths and failed
canvas-copy cleanup. Combined suite:348 passed,0 failed,58 external-fixture
skips, including the concurrently stable camera batch. Inventories regenerated.

## Remaining boundaries

Native GBA ball particles expose an anonymous public pool rather than exact
actor ownership, so their original painter remains. Mixed simultaneous audio
variants retain original sound. Specialty ball models, missing optional audio,
model deformation/poses and unadapted scenery families are separate constraints;
this change does not establish full eleven-game feature parity. Physical mobile
and Windows runtime validation remains separate from this Linux evidence.
