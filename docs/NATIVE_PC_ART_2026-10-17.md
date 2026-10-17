# Native PC portrait art — 2026-10-17

The native storage monitor now consumes selected interface art in all five GBA
editions through public `PcChrome.drawLeftDataPanel`. The existing scoped picture
reader retains the hovered mon's PID, OT IDs and shiny identity, animation-wide
FIT/FULL dimensions and native OFF/MODDED/missing-art fallback. Empty slots,
eggs, Spinda spots and edition-specific forms retain native ownership. Original
mosaic, shader/effect layers, screen composition, metadata, input and storage
operations remain unchanged. Readers restore after success/error and on unload.

RS native opening/closing bars exposed an unrelated official 0.3.89 loader
mismatch: the manifest supplies `data/generated/gba/pokemon/storage/pc_screen_bar.png`,
while `pc_chrome.load_texture` prepends the storage directory again. The PNG and
VERSION 6 manifest were already present in the isolated imports; reimporting
would not fix the duplicated path. `NativePcAssets` scopes the public
`Assets.image` reader inside `PcChrome.ensure`, retrying only the two exact
mis-prefixed native bar paths after the original lookup fails. Supplied images
win. The native original image, draw order and bar animation remain authoritative.
No private fields, engine edits, asset copies or save changes are involved.
The compatibility fallback also applies with selected interface art OFF.

## Verification

Focused interface checks: 92 passed. Dedicated native path fallback checks:
9 passed, including supplied image ownership, missing original art, errors,
unchanged unrelated paths, exact return tuples and unload. Inventory checks:
549 passed. Source compilation and generated inventory checks pass.

Official latest remains 0.3.89, checked by the coordinating worker on October 17.
The matching native Linux shell runs isolated five-edition fixtures at 480x320,
fresh Pallet/Littleroot starts, native 2D, bundled Crystal selected art, FIT/FULL
and OFF, no companion mods. `tools/qa/native-gen3-pc-art.lua` verifies real
storage opening, cursor moves, normal/shiny box portraits, party drawer,
original mosaic progression, two close callbacks and unchanged box/party mon
ownership. All five final runs pass with 214 draws each restoring the native
picture readers and shader, mosaic reaching 10, and two original close callbacks.
Each starts with interface art OFF before toggling selected FIT/FULL and back.
All 30 final captures were inspected: native/selected box portraits, normal and
shiny identities, FULL placement and native party drawers. No draw errors remain.
No box/party mon moved or changed through the verification sequence. Runtime
processes ended and only isolated QA profiles were used; player saves untouched.

Initial RS component assertions had passed while its native transition logged
the missing-image error; those earlier runs were not full-render acceptance.
The final reruns include the narrow native path fallback. No broad suite was
repeated during the coordinating worker's performance measurements; the focused
and actual graphics checks above are the evidence for this batch.

Scratch evidence: `.scratch/voxel-parity-20261017/pc-art-0389/<game>/`, runner
`run-pc-art-0389.sh`. Runtime code is the official release; only missing public
QA support files were carried forward from the 0.3.88 test harness.

This batch changes no release metadata or models and is not part of published
1.44.0. It verifies the portrait consumer, not every storage operation, release,
linked trade or independent UI provider. Overall parity remains partial: RS
indexed hatches still restrict frame dimensions/colors, FRLG credits and Dodrio
need dedicated selected pose assets, and the broader capture/backdrop/provider
limits remain recorded in `NATIVE_INTERFACE_PARITY_CHECKPOINT_2026-10-15.md`.
