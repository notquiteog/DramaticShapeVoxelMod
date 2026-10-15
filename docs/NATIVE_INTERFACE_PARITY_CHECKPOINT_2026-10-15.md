# Native interface parity checkpoint — 2026-10-15

Current adapter source checkpoint: **cb6e7ff**, following release **4bc557a /
1.41.1**. The six following source commits are separate from the published
1.41.1 archive; they changed no release metadata, models or independent assets.

| Commit | Native consumer | Runtime evidence |
| --- | --- | --- |
| 044d136 | Scripted MonPic and Hoenn contest-entry pictures | All five GBA editions; three Hoenn contest-picture components;34 captures inspected |
| 8c037b9 | Emerald Factory rental/swap pictures | Original three-rental selection and accepted/cancelled swap callbacks;8 captures inspected |
| 27b5a5b | Hoenn Pokeblock selection/feed pictures | RU/SA/E cancellation and one original feed/stat update;24 captures inspected |
| 9d4caac | Hoenn credit slides | RU/SA/E natural slides/fades and finish/reset;12 captures inspected |
| f105648 | Pokemon Jump participant pictures | FR/LG/E renderer/Gfx components, native bounce and independent identities;15 captures inspected |
| cb6e7ff | Hoenn starter previews | RU/SA/E original choice flow, actual missing-art fallback and explicit test-provider oversized frames;15 captures inspected |

Each batch has a dated evidence document in this directory. Original UI,
timers, game data ownership and disabled/missing-art fallback remain native.
Component verification is not a complete contest, Frontier, linked minigame,
ending or opening-story playthrough. Starter selected-art screenshots use a
clearly labeled temporary test provider derived from the actual ROM pixels;
no Hoenn selected pack was added. Bundled Crystal artwork ends at species251.

Final shared Lua suite on official **0.3.89**: **308 passed,0 failed,58 external
prerequisite skips**, including SDK1173. Official engine production code was not
modified; its missing QA harness support was supplied from public0.3.88 tests.
Relevant focused tests and source inventory checks pass. Evidence logs live in
`.scratch/voxel-parity-20261015/`, including `suite-starter-final.log`.

## Final all-edition startup/options check

The latest official release API was checked again immediately before this
sweep and still reported0.3.89. The matching native Linux shell ran each isolated
profile serially with current source. `tools/qa/voxel-native-options.lua` traversed
the actual native menu hierarchy, found every declared voxel setting row and
changed/restored the inversion consumer. Results:

| Editions | Rows per edition | Missing rows |
| --- | ---: | ---: |
| Red, Blue, Yellow, Gold, Silver, Crystal | 119 | 0 |
| FireRed, LeafGreen, Ruby, Sapphire, Emerald | 121 | 0 |

Logs/captures: `results-parity-postrelease-0389/<game>/` in the scratch parent;
runner `run-options-postrelease-0389.sh`. These are automated startup/menu and
one-consumer checks. They are not every-option gameplay or visual acceptance.
Older registration evidence remains labeled with its original runtime/source.
All processes ended; isolated QA profiles were used, player saves untouched.

## Precise remaining non-model limits

- **Ruby/Sapphire hatch:** `rs/egg_hatch.lua` uses public `Vram.indexedPic` to
  create a15-color indexed sprite/palette, then GBA OAM/PPU compositing. There
  is no equivalent RGBA per-object draw hook in this hatch path. General
  selected frames require an indexed/color-reduction or compositor contract
  that preserves native affine, layer priority and hatch palette effects.
- **FRLG credits:** `Credits.state()` exposes the current mon, but later reveal
  stages use independently authored ROM pose frames extracted by
  `credits_extract.lua`. They are not simple crops of ordinary front pictures.
  Replacing only the first stage would mix selected and native styles; selected
  equivalents for the dedicated poses are absent.
- **Dodrio berry picking:** dedicated normal/shiny sheets carry head/neck action
  poses through `Draw.dodrios` and `sim:dodrioPose`. Ordinary front pictures are
  not substitutes for those gameplay cues; selected equivalents are absent.
- **Gen2 interface effects:** Oak's indexed palette-rotation reveal remains
  native until the reveal completes. Its cinematic title has no Gen1-style
  cycling-starter picture reader. Special forms/eggs retain native ownership.
- **Capture:** GSC specialty/contest/trainer-blocked/doubles paths remain native.
  GBA specialty/ghost-dodge/doubles paths, full model-specific material effects
  and selected send-out geometry are incomplete. Existing supported Safari/
  tutorial and normal-single adapters do not establish those paths.
- **Audio:** GSC recall has no dedicated native withdrawal animation/sound cue
  to replace. Optional Ember/cave recordings are absent; event routing tests do
  not establish shipped audible coverage.
- **Backdrops/providers:** Johto location/boss art and full map-family routing
  are incomplete. Stadium and standing-trainer features require compatible
  public providers. Modern semantic UI styling belongs to its independent
  provider across all generations; this shared contract is not by itself a
  cross-generation regression.

Scenery/model-family gaps and geometry-cache breadth remain separately listed
in `lib/OptionSupport.lua`; their ownership is outside this adapter batch.
The generated option inventory therefore remains **partial**. Complete parity,
every-map acceptance, universal frame-time targets and Android behavior are
not claimed.
