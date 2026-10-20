# Native GSC partner identity — 2026-10-17

`Gen2Staged` now reads the partner through `screen:activeMon(side..'2')`, matching
the native painter's queued/shown identity and independent Doubles command-slot
reader. Reading `battle.player2/enemy2` directly could display a replacement
before the native queue presented it. Missing partner artwork or a failed
identity reader now returns the whole side to native drawing: claiming a lead
world card while its pair failed could suppress the partner under either mod
load order. This changes no party/core fields or battle actions.

Focused staged-pair tests cover shown/core mismatch, missing partner art,
failed identity lookup, complete-pair ownership and existing native effects.
Native NVIDIA0.3.89 Gold/Silver/Crystal runs pass with all seven mods loaded,
using the isolated all-seven runtime and usual QA profiles. Driver:
`tools/qa/native-gen2-pair-identity.lua`; Route29(10,6), down;640x480,35,world backs,
ROM art, distance16, shadowsOFF, LegendaryOFF, native doubles HUD. The fixture
uses Doubles' public `registerPartnerSource` and `tagOrganic` APIs to obtain
Cyndaquil/Totodile against Sentret/Pidgey, then explicitly separates the queued
shown partner from the core slot to exercise the regression. No gameplay switch
or KO is inferred from that deliberate presentation-state mismatch.

All four native actor IDs match; the queued Pidgey remains selected while the
core fixture points at Hoothoot, then restoration passes. All processes exit0.
Six captures inspected in shared Projects scratch
`.scratch/voxel-parity-20261017/gen2-pair-identity-nvidia-0389/{gold,silver,crystal}`.
The native HUD obscures much of the opposing pair at this framing, so four
rendered identities are **not** a claim of four unobstructed visible actors.
That concrete framing issue was handed to the camera worker. Animated doubles
and multi-actor capture/release remain separate unfinished presentation work.
No engine/user saves/models/release metadata changed.

The optional public Doubles `nativeSceneLayout()` reader now forwards a
`sceneLayout` hint from `Gen2Staged.textures` for the camera worker's framing
fix. Standalone, invalid and failing readers leave metadata absent. Focused
tests pass in both repositories; this seam alone does not establish corrected
framing or animated-pair parity. Modern HUD ownership remains with its provider.
