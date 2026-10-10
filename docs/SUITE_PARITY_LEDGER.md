# Suite parity ledger — 2026-10-09

This replaces generation-level assumptions with an explicit seven-mod × eleven-game audit. **No row means complete parity.** Source adapters can exist without a tested game, screen or network transition. Runtime evidence below covers only the named scenario, not the entire mod. All manifests currently declare zero required companion dependencies.

## Feature and option scope

| Mod | Features required | Option source | Remaining work |
|---|---|---|---|
| Battle Art | Rendering, camera, Legendary, sprites, capture, native options | [docs/OPTION_PARITY.tsv](../../DramaticShapeVoxelMod/docs/OPTION_PARITY.tsv) | Remaining missing/partial/provider rows; per-map and per-game verification incomplete. |
| Wild Skies | Ecology, sky art/options, encounter claims, host-owned flock | [options.lua](../../wild-skies-gen2/options.lua) | RSE regional pools fixed; each edition runtime and multi-client flight/claim checks pending. |
| Sky Ride | Ground/Surf/flight, mount selection, rider art/options, remote mount sync | [lib/gen3/settings.lua](../../dramatic-sky-ride/lib/gen3/settings.lua) | Per-edition mount, transition and two-client sync matrix pending. |
| Double Battles | Wild/trainer doubles, targeting, native Gen3 doubles, online doubles | [main.lua](../../double-battles-gen2/main.lua) | Per-edition complete turn/faint/switch/end matrix and standalone/native double coexistence pending. |
| Online | Remote actors, walk-up trade/battle, singles/doubles, chat/bubbles, host encounter authority | [main.lua](../../gen1online-plus/main.lua) | Protocol units pass; per-edition paired clients and custom-region lifecycle pending. |
| Wilds | Visible encounters, followers, throwing, art/options, host-authoritative ground roster | [options.lua](../../overworld-spawn-mod/options.lua) | RSE ambient pools fixed; per-edition capture/storage/follower and paired clients pending. |
| Modern UI | Optional command/status/party screens, native fallback, special screens | [main.lua](../../modern-ui/main.lua) | GB roster implemented; specialized screens and all-edition complete UI review pending. |

## Game-specific status

| Mod | Game | Implementation | Options verification | Runtime verification in this audit |
|---|---|---|---|---|
| Battle Art | red | Partial; Gen1 adapter | Gen1 inventory remains partial/provider-dependent | Celadon rooftop model capture only; not all features |
| Battle Art | blue | Partial; Gen1 adapter | Gen1 inventory remains partial/provider-dependent | Celadon rooftop model capture only; not all features |
| Battle Art | yellow | Partial; Gen1 adapter | Gen1 inventory remains partial/provider-dependent | Celadon rooftop model capture only; not all features |
| Battle Art | gold | Partial; Gen2 adapter | Gen2 inventory remains partial/provider-dependent | Unverified |
| Battle Art | silver | Partial; Gen2 adapter | Gen2 inventory remains partial/provider-dependent | Unverified |
| Battle Art | crystal | Partial; Gen2 adapter | Gen2 inventory remains partial/provider-dependent | Standing-trainer public test provider ON/OFF; actual companion models provider-dependent |
| Battle Art | ruby | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent | Scene boots; Oldale buildings/trees visibly flat, coverage incomplete |
| Battle Art | sapphire | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent | Scene boots; Oldale buildings/trees visibly flat, coverage incomplete |
| Battle Art | emerald | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent | Raised masonry four colors/OFF only |
| Battle Art | firered | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent | Unverified |
| Battle Art | leafgreen | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent | Standing-trainer public test provider ON/OFF; actual companion models provider-dependent |
| Wild Skies | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Wild Skies | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Wild Skies | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Wild Skies | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Wild Skies | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Wild Skies | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Wild Skies | ruby | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Native regional bird pool; guest empty-before-snapshot and host flying replica verified |
| Wild Skies | sapphire | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Native regional bird pool; guest empty-before-snapshot and host flying replica verified |
| Wild Skies | emerald | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Unverified |
| Wild Skies | firered | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Unverified |
| Wild Skies | leafgreen | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Unverified |
| Sky Ride | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Two actual clients: remote ground mount, flight/height and dismount; local mount unchanged; other ride cases pending |
| Sky Ride | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Two actual clients: remote ground mount, flight/height and dismount; local mount unchanged; other ride cases pending |
| Sky Ride | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Sky Ride | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Actual online native double: four actors/cards, complete turn and normal end; faint/switch matrix pending |
| Double Battles | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Actual online native double: four actors/cards, complete turn and normal end; faint/switch matrix pending |
| Double Battles | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Double Battles | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Online | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Online | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Online | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Online | gold | Partial; Gen2 adapter | Native options; online manifest enables all Gen2 editions | Two actual clients: native consent, live trade exchange/save; Onix + Metal Coat evolves to Steelix, consumes item, returns to world. Native singles/doubles still need end-to-end edition verification |
| Online | silver | Partial; Gen2 adapter | Native options; online manifest enables all Gen2 editions | Two actual clients: native consent, live trade exchange/save; Onix + Metal Coat evolves to Steelix, consumes item, returns to world. Native singles/doubles still need end-to-end edition verification |
| Online | crystal | Partial; Gen2 adapter | Native options; online manifest enables all Gen2 editions | Two actual clients: native consent, live trade exchange/save; normal Pikachu exchange returns to world. Native singles/doubles still need end-to-end edition verification |
| Online | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Two actual clients: chat/remote actors, single/double complete turn, normal end and original HP/PP restore; actual trade exchange/save; disconnect and ghost cleanup |
| Online | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Two actual clients: chat/remote actors, single/double complete turn, normal end and original HP/PP restore; actual trade exchange/save; disconnect and ghost cleanup |
| Online | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Two actual clients: chat/remote ride actors, single/double complete turn, normal end and original HP/PP restore; native trade exchange/save; disconnect cleanup |
| Online | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Two actual clients: chat/remote ride actors, single/double complete turn, normal end and original HP/PP restore; native trade exchange/save; disconnect cleanup |
| Online | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Two actual clients: chat/remote ride actors, single/double complete turn, normal end and original HP/PP restore; native trade exchange/save; disconnect cleanup |
| Wilds | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Wilds | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Wilds | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Wilds | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Wilds | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Wilds | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Wilds | ruby | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Native regional town residents; guest empty-before-snapshot and host ground replica verified |
| Wilds | sapphire | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Native regional town residents; guest empty-before-snapshot and host ground replica verified |
| Wilds | emerald | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Unverified |
| Wilds | firered | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Unverified |
| Wilds | leafgreen | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete | Unverified |
| Modern UI | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Actual online single/double/trade entry captures inspected; no complete screen audit |
| Modern UI | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Actual online single/double/trade entry captures inspected; no complete screen audit |
| Modern UI | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |
| Modern UI | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof | Unverified |

## Current verification evidence

- Wild Skies: `tests/gen3_skies_unit_test.lua` — 74 assertions, including independent Ruby/Sapphire/Emerald/FireRed/LeafGreen species pool cases; does not prove a game boot.
- Wilds: `tests/gen3_ambient_versions_test.lua` — all five native editions plus explicit custom RSE layout; `tests/gen3_settings_parity_unit_test.lua` — 53 assertions.
- Online: `shared_world_test`, `shared_catching_test`, `shared_skies_authority_edges_test` — host ownership, atomic claims, replay, disconnect, bounded restoration and direct-catch range. These are protocol units, not paired game sessions.
- Battle Art: `standing_trainer_native_test`, `gen3_world_battle_test`, `gen3_adapter_test`, `native_masonry_test`, 437 native option consumers and 37 scene-sidecar checks. Current engine fixture is 0.3.52; this is not a latest-release claim.

## Next verification gates

1. Ruby1.1 and Sapphire1.2 imported independently from supplied ROMs. Regional residents and guest snapshot ownership pass in real native runtimes; full paired transport still pending.
2. Host/guest ground and flying snapshots: guest generation disabled before first snapshot, host decides encounter/catch claims, failed/disconnected claims restore exactly once.
3. Paired per-edition walks, chat/bubbles, trading, online single/double battles and remote Ride state; companion missing/OFF fallbacks.
4. Every settings row: saved value, visible native row, real consumer, live/restart semantics and default. Native UI remains native unless Modern UI is enabled.
5. Custom region maps and optional quest states must use public adapters and preserve native collision, scripts and story state.

Actual Ruby/Sapphire fixture: `tools/qa/rse-suite-parity.lua`; captures in `.scratch/coverage-20261004/results/{ruby,sapphire}-rse-parity/replica.png`. Both inspected. All seven modules load; this does not verify every module feature. Real native map prefixes are RU_ and SA_, and remaining scenery gaps were reported to the Gen3 model owner.

## Paired Ruby/Sapphire check — engine 0.3.52

Two independent native clients passed ride pose/height/dismount, chat, battle invitation and native single/double setup, trade-menu opening, reconnect and exact original-party restoration on disconnect. Ruby/Sapphire require the native `ScrSpecial_HealPlayerParty` symbol; Online now selects that name without guessing numeric special IDs. Ten named/legacy party tests cover all five GBA editions. These checks do not establish completed turn, trade exchange, capture, or all-edition parity. Repeatable driver: `tools/qa/rse-online-entry.lua` (QA_ROLE host/guest, SHOT_DIR; private imported profiles and LAN port 18864).

## Completed native RSE activities

Online commits `713b82d` and `ac31d52` fix native Ruby/Sapphire healing and the Gen3 virtual-channel trade barrier. Separate actual two-client Ruby and Sapphire runs completed one native single and double turn, mutual run/end, restoration of original HP/PP, and a real trade exchange through native animation and save. Pokémon nicknames were exchanged and checked on both ends. The room continues using its own transport; neither `LT.loopbackCommit` nor native validation is bypassed. Matching native transaction digests are required; mismatch, malformed/replayed confirmations, forged guest commits, and pre-commit disconnects are tested. Post-commit crash recovery and exhaustive faint/switch/trade-evolution cases remain unverified. `tools/qa/rse-online-complete.lua` drives the native command seam only in QA; it does not replace battle rules.

### Live Gen2 trades and five-edition GBA network pass

Online e5e8eb4 replaces the incompatible offline-save Trade.remote API with the native Gen2 wire/consent state machine and host digest barrier. The live game retains trade animation, evolution, held-item consumption and save ownership. Gold/Silver were previously excluded by the Online manifest; they are now enabled and tested independently. Game2 returns to its world with an empty StateStack by design. No offline save writer is invoked.

The GBA paired matrix now also runs on Emerald, FireRed and LeafGreen: one native single and double turn, normal battle end, original HP/PP restoration, actual native trade, chat, remote mounts and disconnect cleanup. These checks do not prove all faint/replacement, special battle, crash recovery, regional quest, or settings paths. FireRed required a fresh isolated native importer cache; old QA cache landing in the launcher was not a mod failure.
