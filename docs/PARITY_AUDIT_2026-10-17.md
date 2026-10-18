# Feature/options consumer audit — 2026-10-17

Scope: voxel mod, R/B/Y, G/S/C, FR/LG/Ru/Sa/E; official0.3.89 public APIs.
The live inventory has123 keys per generation. A key with a registered row is
not evidence of a complete consumer. `implemented` means source wiring, not
exhaustive gameplay/visual certification. Current final effective counts:

| Editions | Implemented | Partial | Provider | Missing | Other |
| --- | ---: | ---: | ---: | ---: | --- |
| R/B/Y | 112 | 0 | 5 | 0 | 6 native-engine-only |
| G/S/C | 70 | 44 | 6 | 1 | 2 native-engine-only |
| FR/LG/Ru/Sa/E | 74 | 42 | 6 | 0 | 1 saved-key alias |

The alias is `fireredBattleStage`, migrated to shared `battles`; it is not a
missing second feature. `fireredCamera`/`fireredBattleStage` do not belong to the
GB pipeline. Gen1 native tree/surface selectors are likewise other-engine rows.
Existing all-eleven native menu fixtures validate registration/navigation,
with119 GB/GBC and121 GBA editable rows after ITEM BALL; that evidence does not
validate every setting on every map. This batch changes no registration.

## Historical gaps already closed by real consumers

The2026-10-15 list is historical. Gen2 evolution, trade, hatch, PC and Oak Pokemon
wipe adapters now exist. Gen3 trainer-card/intro and Crystal shiny reveal,
original HUD scaling, all five trade/PC routes and all five hatch routes now
exist with documented format/fallback limits. Tutorial/Safari capture and
specialty/blocked/ghost audio have native event adapters. Native send-out and
withdraw audio preserve native timing. Supported GBA send-out shells now render
in world space. GSC world cards now consume native hidden/airborne/resize/slide,
indexed palettes/shades and original Crystal animation frames. Native substitutes
and fainting rows now remain on the world stage as well. Native lifted bands,
global scroll and LCD/BGP scanline effects now compose into the world card; see
`NATIVE_GSC_PICTURE_EFFECTS_2026-10-17.md`.

These are not reasons to erase every associated partial row: each row covers
additional behaviors or asset families. See `OptionSupport.lua` and linked
native interface/capture/send-out/GSC evidence documents for the actual limits.

## Remaining implementable behavior work

| Scope | Current consumer and precise remaining work |
| --- | --- |
| G/S/C world animations | `Gen2Staged`: ordinary lifted bands, native scroll and LCD/BGP scanlines now compose into world cards. Substitute dolls now combine with lifted/LCD effects at native16px size and coordinates. Combined faint with raster or lifted effects and animated doubles still return to the native painter; those combinations need further adapters. |
| G/S/C Legendary send-out | `BattleScene.updateSendout` reads Gen1 grow-in/provider cues; the GSC native send-out reader does not yet drive the full shared Legendary shell/energy choreography. Native resize/effects/audio are retained. |
| FR/LG/Ru/Sa/E Legendary release | `NativeGen3SendoutShell` renders five existing shell models; native release particles remain original. Full shared Q57 release energy and model-specific subject materials are unfinished. |
| Native multi-actor effects | Capture/simultaneous release paths deliberately fall back for doubles or ambiguous ownership. Unique native battler IDs exist on GBA, but adapters still need per-actor event ownership and bounded cleanup. Native fallback is not full parity. |
| Native backdrops | `Gen2BattleBackdrop`, `Gen6Backdrop`, `Gen3BattleBackdrop` consume native identity/terrain and existing plates. Johto-specific routes/bosses and unsupported terrain require matching artwork; existing neutral sets can be audited for additional truthful routing. No substitute gym/location art should be invented. |
| Native scenery behavior | Wind, generated sign labels and map-specific ambience/landscape coverage remain mixed with authored geometry rows. They need consumer-level investigation with the model owner; this interface batch does not certify them. |

## Assets, formats and independent provider limits

- Modern UI owns its optional semantic cards across all generations; its
  `combatCard` contract has no palette override. Provider absence intentionally
  preserves standalone native UI. Standing trainers require a provider declaring
  the generation; Stadium requires its compatible public scene API. These are
  explicit optional dependencies, not absent menu wiring.
- Optional Ember/cave recordings and Gen6/boss background images are not bundled.
  Successful-playback routing is tested with sinks; this does not prove audible
  quality or missing image coverage. Native caught jingles/cry timing stays native.
- Dedicated Dodrio neck/head action sheets, FRLG later-credit poses, eggs,
  Spinda PID spots, Deoxys edition forms and Unown forms cannot be replaced with
  an ordinary front sprite while preserving identity. No matching selected
  custom-pose/form asset contract has been supplied. Crystal's bundled species
  coverage ends at251; missing Hoenn art intentionally stays native.
- Ruby/Sapphire hatch uses the original indexed PPU: supported selected frames
  are64x64, binary alpha and at most15 opaque RGB5 colors. Rich/translucent/large
  art falls back; a broader compositor remains additional work, not a claim of
  complete unrestricted FULL behavior.
- Vanilla GSC Oak Pokemon reveals use the supported wipe. Indexed rotation is
  for trainer portraits; a custom Pokemon rotation step retains native art.
  GSC cinematic title art has no equivalent Gen1 cycling-starter reader.

## Separately owned scenery/cache scope

The remaining GSC partial/missing inventory contains27 scenery/profile/audio
rows and18 battle/interface/audio rows; GBA contains25 scenery/profile/audio
rows and17 battle/interface/audio/cache rows. These counts group controls, not
unique missing features. GSC `communitySafari` remains the sole explicit missing
row; no complete native reserve-family adapter is established. It is not marked
unsupported merely because vanilla availability differs.

Authored room, forest, garden, road, wall, tower, casino, pillar and building
families remain with the model worker. `NativeGeometryCache` compresses supported
building/furniture CPU records; general terrain/tree streams remain a separate
performance-owner gap. No model/cache completion is inferred from this audit.

Full feature parity is **not complete**. Combined GSC picture effects,
release choreography and multi-actor ownership remain concrete
adapters to complete. Do not relabel native fallbacks as parity.
