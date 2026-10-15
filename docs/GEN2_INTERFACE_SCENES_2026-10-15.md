# Gen2 selected-art scene consumers — 2026-10-15

Gold/Silver/Crystal trade, revealed hatchlings, Bill's PC and Oak's Pokemon
pictures now consume selected animated frames and animation-wide FIT/FULL.
The original public picture/draw methods still own layout, trade scrolling,
native updates, sounds, completion callbacks, input and storage/gameplay.

Trade uses the actual given/received records, including DVs, shiny status,
sender and OT IDs. Hatch substitution begins only at native `showMon`; egg,
cracks, shell fragments and native animation/cry timing stay original.
Bill's PC uses its stored mon record. Oak retains native wipe, alpha fade and
flip geometry; indexed palette rotation deliberately uses native art until
the effect completes. Trainer portraits and new-game choices are untouched.

`Gen2PictureScope` shares the existing evolution adapter's draw-only override.
Native animation objects and picture readers are restored even on errors.
OFF, missing artwork, eggs, Unown forms and Crystal pack ownership keep their
original paths. Oak restores its image/palette after every draw and preserves
native palette handling outside GBC color mode.

## Verification

Latest official release checked before this batch: Gen1Recomp0.3.89, published
2026-10-15 at16:20UTC. Official .love and matching Linux x86_64 AppImage verified
against published SHA256 sums. The release omits test helpers: the public
0.3.88 `tests/drivers/util.lua` and mocked SDK support files were copied into
the isolated runtime; no older production engine files were overlaid.

The new release requires Gen2 cachev16 / Crystal8. All three provided ROMs
were reimported into disposable profiles. Earlier0.3.88 evidence keeps its
original label. Fresh fixtures use Gen5 selected art,480x432, voxelOFF and
llvmpipe; no user save writes or companion/model changes.

All three games pass actual native scene fixtures:

- Complete Chikorita-to-shiny-Cyndaquil trade animation and native B skip;
  selected/native picture comparisons preserve OT/DV identity and frame state.
- Egg, shell reveal and hatch completion; Crystal's native picture runner is
  also exercised. Gold/Silver have no corresponding native animated sheet.
- PC deposit-list preview without storage mutation.
- Oak demo and custom Pokemon pictures; FIT/FULL/OFF, native wipe/flip state
  and original indexed rotation. This draws the native scene directly and
  does not claim end-to-end new-game naming or save creation.

Inspected captures include Gold trade/PC, Silver hatch/wipe and Crystal
selected/native animated hatch, custom Oak picture and palette rotation.
The selected shiny Cyndaquil is brown; its original Crystal shiny uses the
native magenta/yellow palette. Shell fragments and native text/layout remain.
These are specific species/scene checks, not every asset or custom script.

Current all-eleven native options checks pass: R/B/Y/G/S/C each119 schema
rows; FR/LG/Ru/Sa/E each121; zero missing rows, and inversion changed/restored
through each native menu. All final scene/menu processes exited0. Menu row
coverage proves registration and the tested inversion consumer, not full
behavioral parity for every listed feature.

Focused tests:15 trade/hatch,13 Oak,18 interface ownership/unload,14 evolution,
26 shared native-interface and549 native option-consumer checks. SDK1173/1173
passes against0.3.89 production source. Generated123-row-per-generation JSON
and TSV inventories match `OptionSupport.lua`; whitespace checks pass.

Drivers: `tools/qa/gen2-trade-hatch-art.lua`,
`tools/qa/voxel-native-options.lua`. Private fixtures/logs/captures live in
`.scratch/voxel-parity-20261015/trade-hatch/{gold,silver,crystal}` and
`.scratch/voxel-parity-20261015/results-0389/<game>`. The Crystal driver bound
was increased to allow its extra native animation frames; it completes at
native trade frame2244. Initial old-cache importer waits are not passing runs.

## Remaining non-model parity

The Gen2 interface rows remain partial because Oak's indexed palette-rotation
reveal still intentionally draws the native image, then resumes selected art.
Gen2 cinematic titles lack the Gen1 cycling-starter reader and retain their
original art. Unown forms and eggs retain native ownership by design.

Gen3 trainer-card/intro/Hall-of-Fame Crystal player portraits were added in
the later `GEN3_CRYSTAL_PORTRAITS_2026-10-15.md` batch. Crystal-specific shiny
reveal choreography still needs a separate native adapter. Broader native audio,
HUD sizing, regional backdrop routing and terrain/cache consumer gaps remain
in the option inventory. Optional-provider rows remain provider-dependent.
This batch does not establish full feature parity or model coverage.
