# Remaining feature/options parity — 2026-10-20

Update: see [2026-10-22 batch](PARITY_BATCH_2026-10-22.md) for richer RS hatch art,
release ownership capability and semantic HUD color. Counts below are historical.

Scope: R/B/Y, G/S/C, FR/LG/Ru/Sa/E on official0.3.91. This supersedes the
unfinished animation/release entries in the2026-10-17 audit, not its historical
runtime evidence. No model/art work is included here.

The live source inventory still has123 keys per generation: Gen1 has112 wired,
5 provider and6 other-engine rows; Gen2 has70 wired,44 partial,6 provider,
1 missing and2 other-engine rows; Gen3 has74 wired,42 partial,6 provider and
1 saved alias. These counts are controls, not independent unfinished adapters.
All eleven native menus previously passed119 GB/GBC or121 GBA editable rows on
0.3.91. Menu presence does not prove behavior, artwork coverage or device support.

## Historical adapter gaps closed

- GSC paired move scripts, secondary damage and Transform display copies now
  use the Doubles public exact-owner map. Native OBJ projection and independent
  card effects retain native timing and original fallback for unknown ownership.
- Paired GSC releases now have four separate native body subjects, equivalent
  world transforms, owner-aligned smoke/stars and shared Q57 shell/energy.
  Combined teammate canvases are never deformed. Native clocks, OFF, failure,
  cancellation, independent providers and original UI remain authoritative.
- GSC native water encounters now use public playerState/FieldMoves surfing,
  frozen at staging. An absent/stale Gen1-compatible player.surfing marker no
  longer sends a water encounter to the wrong arena/backdrop.
- GSC paired release audio now follows only the native cue and exact battle,
  runner and actor identity. All four slots pass played/failed/OFF checks on
  G/S/C; a redundant synthetic Q57 close cue was found and removed.

Evidence: NATIVE_GSC_MOVE_OWNERS, NATIVE_GSC_PAIR_Q57, NATIVE_GSC_SURF and
NATIVE_GSC_AUDIO_MOBILE documents dated2026-10-20. Their native checks are
separate from the shared349/0/58 current Lua suite.

## Exact remaining boundaries

| Area | Evidence and remaining scope |
| --- | --- |
| GBA release particles | Original0.3.91 `ball_open.lua:498` returns anonymous particles; `start` receives a side but spawn records do not retain it. Position guesses cannot prove ownership during simultaneous release. A public per-particle owner seam is needed for safe actor-targeted replacement; current native particles remain. |
| GSC recall | Original `Battle:switch`/`switchEnemy` emit send events and immediate battler_switched notifications before presentation. BattleState has no dedicated recall animation/sound cue. Translated message parsing or an invented delay is not equivalent native timing. |
| Ruby/Sapphire rich hatch artwork | Current selected64×64 binary-alpha,15-color RGB5 frames work through public indexed OAM/palette and retain native fade. Original `gba_ppu.lua:526/585` publicly exposes final render/draw; its internal OBJ/window/blend compositor is private. Unrestricted RGBA/FULL requires a supported insertion seam, not painting over the final masks/fade. |
| Native GSC doubles text | Fractional card scaling loses glyph pixels in the native160×144 raster. Doubles c09db78 now composes static cards at window resolution;12 G/S/C captures inspected, readable at640×480/360×640. Native animation/fade frames retain the original painter. Tiny1× layouts cannot fit full8px source glyphs into5px card text without a layout change; no phone-readability claim. |
| Optional artwork | Johto location/boss plates, Ember/cave audio and provider models are not bundled. Neutral terrain routing is live; missing art remains native/world. Selected egg, Unown, Spinda PID, Deoxys edition and special action/credit pose replacements need matching identity/pose assets; ordinary front art is not a valid substitute. Crystal ends at species251. |
| Independent providers | Modern UI owns its semantic-card palette equally across generations; its public combatCard API has no palette override. Standing trainer providers must declare generation support. Stadium requires its supported scene contract. These are dependencies, not missing option registration. |
| Scenery and caches | Authored model families, specialty ball geometry, GSC Safari reserve, generated sign text/wind and model-specific landscape coverage remain with the model owner. General terrain/tree compressed persistence is a separate renderer/cache scope. No completion follows from this interface audit. |
| Platforms | Linux native GL/GLES and small portrait/landscape simulations are evidence only for those configurations. All11 modern HUD safe-area simulations now pass two window sizes (NATIVE_SAFE_AREA_HUD_2026-10-20.md). Android/iOS physical-device rendering, memory pressure, safe areas and input remain unverified; Windows likewise needs its own runtime evidence. |

The seven mods remain independent: optional integrations preserve standalone
native behavior and do not require another package merely to open settings or
render the ordinary game. Upstream lineage is audited separately in
UPSTREAM_AUDIT_2026-10-20.md. Full feature/options parity is not complete.
