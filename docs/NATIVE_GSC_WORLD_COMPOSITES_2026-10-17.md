# Native GSC substitute/faint world cards — 2026-10-17

`Gen2Staged` now draws the original public `substituteDoll` image/quad in the
actor's world card. Native front/back facing,16px size and species/shiny palette
are retained; normal card metrics prevent an inflated species-sized doll. An
explicit native `anim.pic='mon'` restores the actual selected body. Missing doll
art and doubles keep original native ownership.

Native `faintSink` pixels now move the body downward inside a canvas clip at the
fixed world ground. Selected frames convert the native clock through the public
fitted slot dimensions/scale, so larger artwork does not remain half-visible at
the end. Fully sunk cards remain transparent owners of their flat slot. Scissor,
canvas and draw color restore after success or failed drawing; failed rendering
returns native ownership. No battle timer, damage, action, sound or party mutation
is introduced in production.

Focused staged/capture/audio contracts pass, including shader/palette ownership,
larger selected fitted slots, doubles fallback and graphics error restoration.
The original engine Gen2 support SDK passes202/202. Official0.3.89 (latest checked
2026-10-17), native Linux LÖVE/NVIDIA fixtures pass on Gold/Silver/Crystal:
12 native faint observations and72 native doll reads each. The fixture executes
the original substitute animation, checks its public volatile-state portrait,
toggles3D-BTL OFF/ON, restores the mon and performs an actual native damaging
attack/KO. The isolated wild enemy is set to1HP for that fixture; production does
not alter HP. Actual battle/party identity is preserved.

`tools/qa/native-gen2-staged-composites.lua` uses isolated QA profiles,
Route29(10,6), down,480x432, level4, distance16, shadowsOFF, ROM/WORLD art and
Legendary ballsOFF. Twelve world-doll/native-OFF/restored/faint captures were
inspected: small dolls retain their original art, the body returns after the
substitute ends, and fainting crops toward the world ground without a duplicate
flat actor. Native HUD/menu/message layers remain. Evidence: session scratch
`gen2-staged-composites-nvidia-0389/<edition>/run.log` and `contact.png`.
The first Crystal fixture used a status move and did not KO; the corrected
fixture selects a native move with positive power and all final runs exit0.

Substitute HP cost/gameplay was not separately exercised; only its original
animation/reader and restoration were. Selected art fitting is unit-verified;
these runtime captures use ROM pictures. Lifted-row composites, animated doubles
and full Legendary release choreography remain incomplete. This is not full
feature parity or a performance claim.
