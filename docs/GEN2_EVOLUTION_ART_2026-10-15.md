# Native selected-art evolution — 2026-10-15

SELECTED ART now consumes INTERFACE SPRITES and animation-wide FIT/FULL in
Gold/Silver/Crystal evolution screens. Both the old and target pictures retain
the original mon's DVs/shiny identity. During native BLACKOUT, the selected
frame's alpha silhouette is tinted black; feeding colorful art into the
native red-indexed grayscale palette would otherwise erase bright pixels.

The adapter calls the original public `EvolutionAnim.drawPic` for placement.
It suppresses only the native animation's picture during that draw, restoring
the picture reader, animation object and graphics function even after errors.
Native update still owns the flash cadence, particles, cries, cancellation,
completion and party writeback. OFF/missing artwork, Crystal pack ownership,
eggs and Unown retain native drawing. No companion or model code changed.

## Evidence

Official Gen1Recomp0.3.88, Linux LÖVE shell and isolated profile copies from
the option-parity batch. Tests ran on llvmpipe at480x432 with the voxel pipeline
off, the actual native evolution screen and bundled Gen5 selected artwork.
No player save writes; source and target party records belong to the fixture.

Gold, Silver and Crystal each pass:

- Shiny Cyndaquil→Quilava old/target silhouettes in FIT and FULL.
- Colored selected reveal and live OFF native-picture restoration.
- Actual native B cancellation with the original party entry unchanged.
- Complete native evolution, party replacement and preserved DVs/shininess.

Representative silhouette and selected/native reveal captures were inspected
across all three editions. This verifies this species pair and presentation
path, not every evolution method, species, art pack or custom script.
Fixtures/logs/captures:
`tools/qa/gen2-evolution-art.lua` and
`.scratch/voxel-parity-20261015/evolution/{gold,silver,crystal}/`.
The shell retains the known exit1-after-quit behavior; explicit final PASS
records, assertions and inspected images supply the evidence.

Focused checks cover14 evolution selection/error-restoration contracts,
16 Gen2 interface ownership/unload contracts and26 shared native-interface
contracts. Source inventory and generated JSON/TSV now include the merged
upstream ITEM BALL control (123 catalog entries per generation).

## Remaining interfaces

Follow-up on official0.3.89 adds trade, hatch, BoxMenu and Oak picture
adapters; see `GEN2_INTERFACE_SCENES_2026-10-15.md` for current evidence.
The earlier0.3.88 evolution evidence above retains its original runtime label.
Gold/Silver/Crystal title graphics are their own cinematic art, without the
Gen1 cycling-starter reader; they are not equivalent title replacements.

Gen3 trainer-card and intro portrait adapters remain separate work. RS cards
and Hoenn intros expose scene-kit image readers. FRLG/Emerald trainer cards
load portraits into private local image caches; no `trainer_pic` reader is
called during those draws. Any further adapter must preserve card flips,
native fades, remote-link card identity and the public draw boundary rather
than access private upvalues. Gen3 native shiny effects similarly run through
the battle animation VM; the Crystal-specific reveal choreography is not yet
adapted. These limitations remain explicit in the source inventory.
