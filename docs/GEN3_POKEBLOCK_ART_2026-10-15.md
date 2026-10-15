# Native Hoenn Pokeblock interface art — 2026-10-15

Ruby, Sapphire and Emerald now use selected interface portraits in their native
Pokeblock selection and feeding screens. `NativePokeblockArt` observes the public
`Pokemon.monFrontPic` calls during original show/update, then substitutes the
cached image only during original draw. It restores readers and images on both
success and error, retaining exact return tuples. Source identity follows the
cached picture: changing the cursor must not relabel the outgoing portrait while
it slides away. Native feeding affine transforms, windows, input, timing, cries,
party ownership, inventory consumption and condition/stat updates remain original.

FIT/FULL and OFF/MODDED follow the shared selected-art contract. Missing art,
eggs, alternate Unown, Spinda and Deoxys retain native pictures. Reset, a new
opening and unload clear associations. This separate source batch follows
release checkpoint 4bc557a; it changes no release metadata and is not claimed
included in the existing 1.41.1 archive.

## Verification

Official **v0.3.89**, matching native Linux shell; release API rechecked before
the batch. Engine production source unchanged; public QA support from 0.3.88.
`tools/qa/native-gen3-pokeblock-art.lua` runs isolated Ruby/Sapphire/Emerald
profiles, fresh Littleroot fixtures, 480x320 native 2D UI, Crystal selected art,
no companions. Scratch runner: `run-pokeblock-art-0389.sh GAME`.

The fixture gives the original native UI two mons and one red Pokeblock with
spicy10/feel20. Selection switches FIT/FULL/OFF live, navigates to shiny
Cyndaquil, then cancels. Eight real outgoing draws per game retain Pikachu's
identity after the cursor moves. Cancellation consumes nothing and changes no
stats. Reopening and feeding Cyndaquil runs the original animation and result
screen; exactly one native feed consumes the block and changes only Cyndaquil's
cool to10 and sheen to20. Both original party objects, the first mon's zero
condition values, native reader and exit callback counts remain intact.

All three runs pass. All24 captures were inspected: selection FIT/FULL/native/
shiny and feeding FIT/FULL/native/results-shiny for each edition. Original
chrome, condition graph and feeding device remain; selected feeding art follows
the original mirrored/affine presentation. The result capture precedes the
native stat application; the fixture checks final values afterward. This is
an original-screen/component fixture, not an end-to-end berry blending or
contest progression test. No player save was written.

Evidence: `.scratch/voxel-parity-20261015/pokeblock-art-0389/{ruby,sapphire,emerald}`,
`run.log` and named PNGs. Focused cached-image16/interface71/inventory549 checks
pass. Final broad suite: 306 passed, 0 failed,58 external prerequisite skips,
including SDK1173; `suite-pokeblock-final.log` in the scratch parent.

## Remaining interface work

Ruby/Sapphire indexed-PPU hatch, minigames, credits and starter-selection pictures
remain native. These need their actual renderer contracts audited rather than
being counted from option registration. Interface inventory remains partial;
full non-model parity and regional-model coverage are not claimed.
