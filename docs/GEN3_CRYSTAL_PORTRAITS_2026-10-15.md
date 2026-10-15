# Native Gen3 Crystal player portraits — 2026-10-15

CRYSTAL's selected player portrait now reaches native trainer cards, the
Hall-of-Fame player slide, and the FRLG/Hoenn new-game player pictures across
FireRed, LeafGreen, Emerald, Ruby and Sapphire. These interfaces always use
the authored front portrait; BATTLE PIC=BACK still applies only in battle.
PLAYER / PLAYER+TRAINER / ALL opt in; NONE / TRAINER / OVERWORLD, DEFAULT,
other sprite packs and missing art retain the existing pictures.

The adapter uses original public draw methods. FRLG/Emerald cards keep their
private image caches: only the64x64 portrait draw at the native layout slot
is replaced, within that card's draw. Hoenn layout coordinates come from its
public manifest. Original flips, RS scanline transforms, fades, text, badges,
card data and input still run. The local card session must match the public
`Runtime.getSession()` result; link and other-session cards retain their own
identity. The mod sandbox's compatibility module cache is not used to infer
the live engine session.

Hall of Fame scopes its public `TrainerPic.front` reader to the current local
player picture ID. FRLG intro scopes `pic.image`; Hoenn scopes only the
Brendan/May sprite image/frame passed to `drawSprite`. Original positions,
transforms, alpha/palette fades, professor/rival/mon pictures, naming logic
and native timers remain untouched. All temporary readers, images and frame
fields restore even when drawing fails. No engine private upvalues, protected
callbacks, gameplay or companion assets are accessed.

## Verification

Official Gen1Recomp0.3.89 was rechecked as latest before the batch. Tests used
its verified Linux x86_64 native shell, isolated imported profiles from the
prior all-eleven menu fixture,480x320 and voxelOFF. The same prior-version
public QA helper is used because the official0.3.89 package omits tests; the
production engine source remains0.3.89. No player save writes.

All five editions pass `tools/qa/native-crystal-portraits.lua`, exit0:

- Selected Kris front and native fallback on the actual trainer card while
  BATTLE PIC=BACK is set; native front-to-back flip and closing input.
- FRLG/Emerald native back-to-front behavior; RS retains its own back-to-close
  behavior. RS link-card presentation flag leaves the peer portrait native.
- Hall-of-Fame local player preview with `dontSave=true`, `warp=false`, stable
  slide state, selected/native comparisons and original confetti/background.
- Actual native intro draw methods with selected/native player pictures,
  native scaling and partial fades, and custom-player-mode OFF fallback.

The intro fixture draws an initialized native scene with staged player/affine
state. It does not replay the full new-game script or claim naming/intro
completion. Hall of Fame similarly previews its native player phase rather
than replaying a league victory. Link-card protection is checked by source,
unit identity tests and the native RS presentation flag, not a live peer link.

Inspected all five editions' selected-card or Hall-of-Fame captures, plus FRLG
selected/native comparisons, Hoenn intro fade/scale, and RS native peer-card
fallback. The selected front remains inside the existing portrait area and
follows its transforms; menu text and backgrounds retain their original art.
Private evidence: `.scratch/voxel-parity-20261015/portraits-0389/<game>`.

Focused checks pass25 portrait contracts, the native Crystal preference/frame
suite,26 shared interface checks, and549 native option-consumer checks.
SDK1173/1173 passes against0.3.89. Inventory generation/check and whitespace
checks pass. There are no new settings; the preceding0.3.89 all-eleven menu
registration evidence remains applicable to the unchanged schema.

## Remaining limits

The three Gen3 Crystal trainer preference rows now have native consumers for
the audited portrait contexts. `spritePack` remains partial: Crystal-specific
shiny reveal choreography is still native. Missing custom portraits/species,
unusual forms, scripted battle roles and other players remain native by design.
Gen2 Oak indexed-rotation reveals retain native art during that effect. Other
capture/audio, original-HUD scaling, specialty geometry and optional-provider
limits remain in `OptionSupport.lua`. Full non-model and model parity are not
claimed. No model edits, version bump, release or push in this batch.
