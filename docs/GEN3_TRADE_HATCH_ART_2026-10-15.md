# Native Gen3 trade/hatch interface art — 2026-10-15

`NativeInterfaceArt` now scopes selected pictures to all five native trade
scene draws and FireRed/LeafGreen/Emerald hatch draws. The original scene owns
its timers, trade transitions, callbacks, egg fragments, cries, prompts and
completion. Both trade partners retain their individual PID/OT/shiny context,
including the native received-mon reader. Wrappers preserve nil-containing
return tuples and restore all picture readers after success or errors.

Egg shells and traded eggs remain native. Spinda PID spots and Deoxys edition
forms also remain native instead of being replaced by species-only artwork.
Unavailable selected pictures, OFF and MODDED preserve native/provider art.
No gameplay, model assets or independent companion ownership is changed.

The runtime checks also exposed an existing Crystal FIT/FULL bug: raw Crystal
textures lacked BattleArt's CPU bounds, so fitting silently returned the raw
56-pixel frames. The adapter now decodes only its owned source PNGs through
public `Assets.imageData` and prepares the full animation once, without GPU
readback or recoloring. FIT and FULL then use the same animation union and
64-pixel target as other selected art. Missing CPU data falls back to native
art and does not retry disk reads every draw. Asset release clears ownership.

## Evidence

Official **v0.3.89**, matching native Linux shell, isolated imported profiles,
no companion mods. The release API was checked before the batch. Production
engine is untouched; public QA support comes from0.3.88 because0.3.89 omits it.
Driver: `tools/qa/native-gen3-trade-hatch-art.lua`.

All five editions pass full original trade visual sequences with live
FIT/FULL/OFF changes, correct outgoing/incoming shiny identity, exactly one
swap notification and completion callback, unchanged party ownership and
restored readers. This is a visual-sequence fixture with observed callbacks;
it is not a network trade or a live peer/party-exchange verification.

FireRed, LeafGreen and Emerald also pass original hatch sequences using a real
native egg with a PID chosen to remain shiny after native hatch OT assignment.
Egg shell stays native; revealed selected art draws at64x64, FIT/FULL/OFF work,
nickname cancellation and completion run, the egg flag clears, and the same
single party object remains. Native hatch gameplay owns those state changes.

Final FIT/FULL/native trade captures and selected/native hatch captures were
inspected. FULL top-aligns the authored animation union; FIT bottom-aligns it.
The selected shiny Cyndaquil keeps its Crystal purple flames, while OFF shows
the native GBA picture. Shell capture is early in the original fade and dark;
its native ownership is also asserted. An initial pre-fix FireRed FULL capture
was incomplete and is not accepted evidence; the final corrected image shows
the complete animated Pikachu.

Evidence: workspace `.scratch/voxel-parity-20261015/trade-hatch-art-0389/`, one
folder per game with `run.log`, `trade-{fit,full,native}.png`, plus supported
`hatch-{shell,fit,full,native}.png`. Runner:
`.scratch/voxel-parity-20261015/run-trade-hatch-art-0389.sh GAME`. Native
Pallet/Littleroot fresh fixture, cell7,8 down, 480x320, voxel level0, selected
Crystal pack and synthetic trade party; no player save writes. Processes exit
and reader/instrumentation state is restored.

Focused interface checks53, Crystal reader/cache checks and inventory549 pass.
Shared final broad suite **300 passed, 0 failed, 58 external prerequisite
skips**, including SDK1173, passes with the root boundary/sampler batch. Log:
`suite-trade-hatch-final.log` in the scratch parent. LuaJIT compile, generated
inventory consistency and diff whitespace checks pass.

## Remaining interface consumers

Ruby/Sapphire hatch still uses native indexed PPU pictures. In0.3.89,
`rs/egg_hatch.lua` setup converts raw native RGBA with `Vram.indexedPic`, then
renders GBA OAM through `m.ppu:draw`. `contest_vram.lua` reduces that sheet to
15 opaque colors and `gba_ppu.lua` draws indexed pixels under its palette,
priority, blend and affine rules. There is no per-object RGBA picture callback
in that draw. Replacing an arbitrary selected image there would require a
separate compositor adapter or color reduction; this batch preserves native
pixels/effects rather than claiming that scene is supported.

The public-reader audit also finds unscoped PokeNav condition/ribbon pictures,
Pokeblock feeding/use, contest entry pictures, Battle Factory selection,
minigame pictures, credits and some scripted overworld/start-selection pictures.
Their layout, animation and special species rules still need individual audits.
These are concrete remaining consumers, so interface rows stay **partial**.
This does not close model-specific capture materials, native send-out geometry,
specialty/doubles captures, Gen2 recall cue limitations or regional model parity.
