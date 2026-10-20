> Historical checkpoint: current consumer gaps and resolved items are reconciled in
> [the2026-10-17 audit](PARITY_AUDIT_2026-10-17.md). Counts below describe this older batch.

# Voxel-only native options and interface follow-up — 2026-10-15

This audit covers Battle Art across Red/Blue/Yellow, Gold/Silver/Crystal and
FireRed/LeafGreen/Ruby/Sapphire/Emerald. No companion implementation changed.
Full feature parity is still incomplete.

## Changes

- Native Gen2 boss backgrounds now read the real trainer class (`classId`),
  including battle-screen wrappers, instead of assuming Gen1 `oppClass`.
  Native fishing battles read `BATTLETYPE_FISH`. Canonical map constraints,
  unknown trainer classes, link battles, missing images, frozen battle clocks
  and Gen1 encounter priority retain their fallbacks. No battle core mutation.
  This connects existing Kanto plates; it does not supply Johto artwork.
- SELECTED ART now applies INTERFACE SPRITES and animation-wide FIT/FULL to
  native Gen2 Hall-of-Fame front/back pictures. The original record/DVs reach
  the art reader. Native front animation yields only while a selected picture
  exists; OFF, missing artwork, Crystal ownership and Unown retain native art.
  Screen scrolling, animation timers, cries and saved records remain native.
- The September JSON inventory was stale despite the live Lua source and TSV
  advancing. Both inventories now generate from `OptionSupport.lua` with
  `python3 tools/update_option_inventory.py`; `--check` detects drift. The
  inventory records source consumers, not exhaustive gameplay certification.

## Verification

Official Gen1Recomp **0.3.88**, checked against the release API for this batch;
native Linux LÖVE shell at `.scratch/runtime-0.3.88/squashfs-root/bin/love`,
source `engine`, standalone voxel mod symlink. Disposable profile copies in
`.scratch/voxel-parity-20261015/profiles`; no live saves used. The three Gen1
ROMs were reimported from the supplied local files when older cache markers
prevented startup. Gen2/Gen3 private caches were reused.

- Every declared native voxel choice/toggle/number row is reachable through
  actual native menus in all eleven editions: **118 each in Gen1/2**, **120
  each in Gen3**, zero missing. Native Y inversion changes and restores in
  every edition. This is registration/navigation and one live consumer check,
  not proof that all rows have complete per-map consumers.
- Gold/Silver/Crystal each pass native Hall-of-Fame selected front/back,
  FIT/FULL, OFF restoration and timer/record checks. Actual Pikachu selected
  and native images were inspected in all three editions. The fixture freezes
  scroll position for comparisons, then verifies the native timer advances.
  It does not certify every species, shiny art or full induction gameplay.
- Focused tests: 58 native backdrop routing, 15 Gen2 interface ownership,
  26 shared native interface, 31 Gen3 presentation and 545 native option
  consumer checks. Shared SDK: 1173 checks. Inventory drift and diff checks
  pass. Gen2 backdrop tests use native-shaped records; no new rendered boss
  image certification is claimed.
- Yellow and Crystal additionally pass bounded native staged-battle/orbit
  checks at 480x432, distance 16, shadows OFF on llvmpipe. Both captures were
  inspected: native actors/UI remain visible, both visible foot anchors have
  zero pixel gaps, and the stage canvas survives orbit. This covers a Gen1
  and Gen2 runtime consumer of the concurrent shared-uniform optimization;
  it is not a timing benchmark or complete six-edition battle review. Fixture
  and evidence: `.scratch/voxel-parity-20261015/gb-battle.lua` and `battle/`.

Fixtures: `tools/qa/voxel-native-options.lua`, `tools/qa/gen2-hall-art.lua`.
Logs/captures are under `.scratch/voxel-parity-20261015/{results,hof}`. As with
the parallel performance batch, the native shell returns 1 after successful
capture/quit; explicit fixture assertions and captures are the evidence,
not a clean process-exit claim. Earlier failed setup runs were corrected
before the final successful captures.

## Remaining source inventory

Each generation has 122 catalog entries:

| Generation | Implemented | Partial | Provider | Missing | Other |
|---|---:|---:|---:|---:|---:|
| 1 | 111 | 0 | 5 | 0 | 6 not applicable |
| 2 | 68 | 45 | 6 | 1 | 2 not applicable |
| 3 | 70 | 45 | 6 | 0 | 1 legacy alias |

The explicit missing Gen2 control is `communitySafari`. Important non-model
gaps remain: specialty/tutorial/doubles capture presentations; broader native
send-out/recall audio ownership and optional sound files; Gen2 evolution
blackout choreography and other interface screens; Gen3 trainer-card/intro and
shiny-reveal adapters; original native HUD scaling; complete native background
location/boss routing and Johto plates. Gen3 fishing-versus-Surf provenance
was not inferred from terrain alone. Native RAM retention still excludes
general terrain/tree CPU streams. Provider rows require their compatible
optional provider, not just an editable menu option.

Authored scenery/model family gaps are unchanged by this batch and remain
listed individually in `docs/option-support.json`. No row or generation count
certifies every room, edition, setting combination or optional companion.
