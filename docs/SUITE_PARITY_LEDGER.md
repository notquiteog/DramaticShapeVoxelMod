# Suite parity ledger — 2026-10-09

This replaces generation-level assumptions with an explicit seven-mod × eleven-game audit. **No row means complete parity.** Source adapters can exist without a tested game, screen or network transition. Runtime evidence below covers only the named scenario, not the entire mod. All manifests currently declare zero required companion dependencies.

## 2026-10-11 target-row and native fallback batch — engine 0.3.74

- Gen3 LeafGreen/Emerald native trainer doubles: Left/Right enemy slots, Down allied row, Up remembered enemy; cancellation and partner command pass. Hover blink uses the same opaque sprite head anchor instead of falling back to native screen coordinates. Both blink phases visually inspected.
- Gen1 Red: native row controls and cancellation pass; complete 10-turn local ENet battle with ally-directed moves, switch/faint replacement, matching mirrored hashes, unchanged source parties and retained chat transport passes. Native ally menu inspected. This is Red evidence, not a new eleven-game battle certification.
- Gen2 Crystal: native target prompt remains present with Modern UI disabled; row navigation and three mirrored core turns including ally targeting pass. 65 native mechanics assertions include friendly damage, own Reflect, genuine bench phazing and paired-trainer bench ownership. Gen1/2 wire tests reject self, fractional/out-of-range and fainted ally targets; both peers need the updated target-slot vocabulary.
- Gen2 cached stage ownership now yields native pictures when 3D-BTL is disabled. The guard and diagnostic override have regression coverage; native back sprites visibly return. The short UI fixture skips send-out setup, so its capture does not certify front send-out animation.
- Sky Ride's GB follower lookup now uses the optional public sprite provider and owned fallback, removing private companion directory/source scanning. All six GB editions independently pass paired native Surf, shoreline dismount, remote pose removal and retained chat on 0.3.74. Red/Crystal/Gold native renders inspected. Gen3 paired Surf evidence remains attributed to 0.3.73.

Evidence: `.scratch/parity-073-20261011/results/{red-gen1-online-ally,crystal-gen2-online-ally,leafgreen-gen3-target-rows,emerald-gen3-target-rows}-host/`; the directory name is historical, those runs use official 0.3.74 via `run-074.sh`. Runtime fixtures are tracked in Doubles tests and Battle Art `tools/qa`; focused tests cover mechanics and native presentation opt-out. Exhaustive move/effect, option and custom-region parity remains incomplete.

## 2026-10-11 native movement and spread-mechanics follow-up — engine 0.3.74

Ride ground/Surf removal now preserves native moving/progress/vertical offsets instead of cancelling hops or warps. Ruby, Sapphire and Emerald independently pass native Dive descent, underwater traversal, emergence and Surf overlay restoration; mounting underwater is refused while the native avatar owns movement. Emerald underwater render inspected. The fixture is `dramatic-sky-ride/tests/gen3_dive_ride_driver.lua`; native Waterfall traversal remains a separate unverified case.

Gen2 now implements the existing Gen1 spread policy and public spread registration: native primary damage plus three-quarter additional hits, one PP debit, correct opposing/allied recipients, native Protect/Substitute/screens and Fly/Dig legality. Interrupted moves do not ripple. 85 native core checks pass; Gold/Silver/Crystal independently finish mirrored native Surf battles with matching signatures. Fixture: `double-battles-gen2/tests/gen2_online_spread_driver.lua`.

Gen1 auditing exposed two real online spread desynchronizations: unseeded secondary damage and differing Explosion recipient order on mirrored peers. Both are fixed, alongside native interruption gates and Substitute/Bide/Counter/Rage damage handling. Red/Blue/Yellow independently finish 10-turn actual loopback ENet sleep/Surf battles with identical final hashes, retained transport and unchanged source parties. Red additionally verifies Explosion secondary hits and faint replacement with matching hashes. Fixture: `double-battles-gen2/tests/gen1_online_spread_driver.lua`; `QA_EXPLOSION=1` selects the latter case. Complete move/effect and offline simultaneous-wipe matrices remain unverified.

## 2026-10-11 Waterfall and real Gen2 transport closure — engine 0.3.75

Official `.love` and Linux AppImage SHA256 verified against the release checksum file; existing isolated caches boot without reimport. No older evidence is relabeled.

- Ride `790128a`: native Waterfall ascent/descent passes independently in Ruby, Sapphire and Emerald (Ever Grande) and FireRed/LeafGreen (Icefall Cave entrance). The latter uncovered and fixed an actual gate: native Surf overlays were incorrectly refused indoors. Ground/free-flight remain outdoors; inland dismount preserves native locomotion. Emerald/LeafGreen summit renders inspected. Fixture: Ride `tests/gen3_waterfall_ride_driver.lua`.
- Doubles `7eda2e8`: Gold, Silver and Crystal each complete a real local ENet native Surf double battle, including secondary damage, native queues, bench replacement, uneven peer update clocks, final mirrored hash verification, unchanged source parties and retained room/chat transport. Gold completes five turns; Silver/Crystal four. Fixture: Doubles `tests/gen2_online_transport_driver.lua`. This replaces the narrower simulated-transport qualification for this spread lifecycle.

- Gen3 native trainer doubles: all five editions pass target rows/cancel/partner selection, stable projected card anchors in both blink phases, actual attacks, enemy bench replacement and completion. Ruby capture inspected. Fixture: Battle Art `tools/qa/gen3-target-lifecycle.lua`.
- Wilds land followers and Pokemon-control no longer replace/follow the native underwater diver; underwater trails are discarded. Focused test and actual Emerald Dive roundtrip pass on 0.3.75; underwater capture visibly retains only the native avatar.

Evidence: `.scratch/parity-073-20261011/results/*-gen3-waterfall-ride-host` and `*-gen2-online-transport-host`, executed by `run-075.sh`. The directory name is historical. Authored scenery-setting adapters and provider-dependent features below remain separate work.

## Native authored-model CPU cache — engine 0.3.75

Gen3 now consumes RAM PRECACHE MB for compressed authored building and furniture records. OFF performs no retention or disk reads; LIVE CACHE retains only session-generated records; numeric budgets bound compressed CPU data; FULL removes that budget. Persistent reads preload actual current/connected-map records. Native source pixels, atlas slots, effective options and sorted mod Lua/data contents fingerprint each record. Invalid, corrupt, unavailable or unsupported records rebuild normally; decoding completes before emitting any replayed faces. Wind anchors and authored chimney metadata survive replay. This does not change GPU budgets or certify every terrain/tree mesh family.

Actual Emerald Oldale rebuild replays all four authored buildings (22,891 compressed bytes); LeafGreen Oak's lab replays 21 furniture records (44,358 bytes). Captures inspected. Real LÖVE codec/storage tests cover source-list order, source/art/options invalidation, OFF/LIVE/FULL, bounded retention, corruption and failed writes. Fixtures: `tools/qa/native-geometry-cache.lua`, `tools/qa/native-geometry-replay.lua`; latest result directories use the isolated `run-075.sh` runtime. General terrain and native tree CPU stream caching remain work, so the option inventory is explicitly partial.

## Feature and option scope

| Mod | Features required | Option source | Remaining work |
|---|---|---|---|
| Battle Art | Rendering, camera, Legendary, sprites, capture, native options | [docs/OPTION_PARITY.tsv](../../DramaticShapeVoxelMod/docs/OPTION_PARITY.tsv) | Remaining missing/partial/provider rows; per-map and per-game verification incomplete. |
| Wild Skies | Ecology, sky art/options, encounter claims, host-owned flock | [options.lua](../../wild-skies-gen2/options.lua) | All-edition host roster convergence verified; simultaneous claims, rejoin and wider ecology transitions remain. |
| Sky Ride | Ground/Surf/flight, mount selection, rider art/options, remote mount sync | [lib/gen3/settings.lua](../../dramatic-sky-ride/lib/gen3/settings.lua) | Basic standalone ground/flight/Surf and paired ground/flight verified all editions; paired Surf verified all six GB editions on 0.3.74 and all five GBA editions on 0.3.73; native GBA Waterfall verified all five on 0.3.75, Hoenn Dive all three on 0.3.74. Remaining special movement paths tracked separately. |
| Double Battles | Wild/trainer doubles, targeting, native Gen3 doubles, online doubles | [main.lua](../../double-battles-gen2/main.lua) | Gen1 complete ENet spread lifecycle verified all three editions on 0.3.74; Gen2 equivalent native transport lifecycle verified all three on 0.3.75. Gen3 native trainer targeting, status blink anchoring, partner choice, foe bench replacement and completion verified all five on 0.3.75; special effects retain native legality. |
| Online | Remote actors, walk-up trade/battle, singles/doubles, chat/bubbles, host encounter authority | [main.lua](../../gen1online-plus/main.lua) | Basic paired singles/doubles/trades and shared rosters verified all editions; lifecycle, disconnect edges and custom-region cases remain. |
| Wilds | Visible encounters, followers, throwing, art/options, host-authoritative ground roster | [options.lua](../../overworld-spawn-mod/options.lua) | Basic standalone and host-reserved guest capture verified all editions; simultaneous throws, full-PC network storage and follower lifecycle remain. |
| Modern UI | Optional command/status/party screens, native fallback, special screens | [main.lua](../../modern-ui/main.lua) | GB roster implemented; specialized screens and all-edition complete UI review pending. |

## Game-specific status

| Mod | Game | Implementation | Options verification | Runtime verification in this audit |
|---|---|---|---|---|
| Battle Art | red | Partial; Gen1 adapter | Gen1 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Celadon rooftop model capture only; not all features; isolated standalone boot passed (six companions disabled) |
| Battle Art | blue | Partial; Gen1 adapter | Gen1 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Celadon rooftop model capture only; not all features; isolated standalone boot passed (six companions disabled) |
| Battle Art | yellow | Partial; Gen1 adapter | Gen1 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Celadon rooftop model capture only; not all features; isolated standalone boot passed (six companions disabled) |
| Battle Art | gold | Partial; Gen2 adapter | Gen2 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Battle Art | silver | Partial; Gen2 adapter | Gen2 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Battle Art | crystal | Partial; Gen2 adapter | Gen2 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Standing-trainer public test provider ON/OFF; actual companion models provider-dependent; isolated standalone boot passed (six companions disabled) |
| Battle Art | ruby | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Scene boots; Oldale buildings/trees visibly flat, coverage incomplete; isolated standalone boot passed (six companions disabled) |
| Battle Art | sapphire | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Scene boots; Oldale buildings/trees visibly flat, coverage incomplete; isolated standalone boot passed (six companions disabled) |
| Battle Art | emerald | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Raised masonry four colors/OFF only; isolated standalone boot passed (six companions disabled) |
| Battle Art | firered | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Battle Art | leafgreen | Partial; Gen3 adapter | Gen3 inventory remains partial/provider-dependent; native WORLD inversion changed/restored; declared native schema rows reachable (all-mod run) | Standing-trainer public test provider ON/OFF; actual companion models provider-dependent; isolated standalone boot passed (six companions disabled) |
| Wild Skies | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | ruby | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | Native regional bird pool; guest empty-before-snapshot and host flying replica verified; actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | sapphire | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | Native regional bird pool; guest empty-before-snapshot and host flying replica verified; actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | emerald | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | firered | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Wild Skies | leafgreen | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot passed (six companions disabled) |
| Sky Ride | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot; paired ground mount/dismount and flight/landing replication passed; standalone owned ground/flight/landing and native Surf shoreline lifecycle passed |
| Sky Ride | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot; paired ground mount/dismount and flight/landing replication passed; standalone owned ground/flight/landing and native Surf shoreline lifecycle passed |
| Sky Ride | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot; paired ground mount/dismount and flight/landing replication passed; standalone owned ground/flight/landing and native Surf shoreline lifecycle passed |
| Sky Ride | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot; paired ground mount/dismount and flight/landing replication passed; standalone owned ground/flight/landing and native Surf shoreline lifecycle passed |
| Sky Ride | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot; paired ground mount/dismount and flight/landing replication passed; standalone owned ground/flight/landing and native Surf shoreline lifecycle passed |
| Sky Ride | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot; paired ground mount/dismount and flight/landing replication passed; standalone owned ground/flight/landing and native Surf shoreline lifecycle passed |
| Sky Ride | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Two actual clients: remote ground mount, flight/height and dismount; local mount unchanged; other ride cases pending; isolated standalone boot passed (six companions disabled); standalone owned ground/flight/landing and native Surf shoreline lifecycle passed; G/H shortcuts and PageUp altitude checked |
| Sky Ride | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Two actual clients: remote ground mount, flight/height and dismount; local mount unchanged; other ride cases pending; isolated standalone boot passed (six companions disabled); standalone owned ground/flight/landing and native Surf shoreline lifecycle passed; G/H shortcuts and PageUp altitude checked |
| Sky Ride | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot passed (six companions disabled); standalone owned ground/flight/landing and native Surf shoreline lifecycle passed; G/H shortcuts and PageUp altitude checked |
| Sky Ride | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot passed (six companions disabled); standalone owned ground/flight/landing and native Surf shoreline lifecycle passed; G/H shortcuts and PageUp altitude checked |
| Sky Ride | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | isolated standalone boot passed (six companions disabled); standalone owned ground/flight/landing and native Surf shoreline lifecycle passed; G/H shortcuts and PageUp altitude checked |
| Double Battles | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual paired clients: complete double battle, matching turn hash, mirrored win/lose outcome, world return and saved HP/PP preserved. Wider target/switch/edge-case matrix remains; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual paired clients: complete double battle, matching turn hash, mirrored win/lose outcome, world return and saved HP/PP preserved. Wider target/switch/edge-case matrix remains; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual paired clients: complete double battle, matching turn hash, mirrored win/lose outcome, world return and saved HP/PP preserved. Wider target/switch/edge-case matrix remains; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual paired clients: complete double battle, matching turn hash, mirrored win/lose outcome, native world return and saved HP/PP preserved. Wider target/switch/edge-case matrix remains; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual paired clients: complete double battle, matching turn hash, mirrored win/lose outcome, native world return and saved HP/PP preserved. Wider target/switch/edge-case matrix remains; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual paired clients: complete double battle, matching turn hash, mirrored win/lose outcome, native world return and saved HP/PP preserved. Wider target/switch/edge-case matrix remains; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual online native double: four actors/cards, complete turn and normal end; faint/switch matrix pending; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual online native double: four actors/cards, complete turn and normal end; faint/switch matrix pending; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Double Battles | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled); standalone native organic double, enemy damage and natural field return passed |
| Online | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Paired native single/double outcomes, saved HP/PP preserved; native trade consent/exchange/save/return; isolated standalone boot passed; host ground/sky roster convergence and reserved guest capture passed |
| Online | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Paired native single/double outcomes, saved HP/PP preserved; native trade consent/exchange/save/return; isolated standalone boot passed; host ground/sky roster convergence and reserved guest capture passed |
| Online | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Paired native single/double outcomes, saved HP/PP preserved; native trade consent/exchange/save/return; isolated standalone boot passed; host ground/sky roster convergence and reserved guest capture passed |
| Online | gold | Partial; Gen2 adapter | Native options; online manifest enables all Gen2 editions; declared native schema rows reachable (all-mod run) | Two actual clients: native consent, live trade exchange/save; Onix + Metal Coat evolves to Steelix, consumes item, returns to world. Native single replacement and completed doubles verified; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Online | silver | Partial; Gen2 adapter | Native options; online manifest enables all Gen2 editions; declared native schema rows reachable (all-mod run) | Two actual clients: native consent, live trade exchange/save; Onix + Metal Coat evolves to Steelix, consumes item, returns to world. Native singles and completed doubles verified; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Online | crystal | Partial; Gen2 adapter | Native options; online manifest enables all Gen2 editions; declared native schema rows reachable (all-mod run) | Two actual clients: native consent, live trade exchange/save; normal Pikachu exchange returns to world. Native single replacement and completed doubles verified; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Online | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Two actual clients: chat/remote actors, single/double complete turn, normal end and original HP/PP restore; actual trade exchange/save; disconnect and ghost cleanup; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Online | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Two actual clients: chat/remote actors, single/double complete turn, normal end and original HP/PP restore; actual trade exchange/save; disconnect and ghost cleanup; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Online | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Two actual clients: chat/remote ride actors, single/double complete turn, normal end and original HP/PP restore; native trade exchange/save; disconnect cleanup; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Online | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Two actual clients: chat/remote ride actors, single/double complete turn, normal end and original HP/PP restore; native trade exchange/save; disconnect cleanup; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Online | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Two actual clients: chat/remote ride actors, single/double complete turn, normal end and original HP/PP restore; native trade exchange/save; disconnect cleanup; isolated standalone boot passed (six companions disabled); host ground/sky roster convergence and reserved guest capture passed |
| Wilds | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run);24 real native submenu apply/restore callbacks passed | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run);24 real native submenu apply/restore callbacks passed | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run);24 real native submenu apply/restore callbacks passed | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run);24 real native submenu apply/restore callbacks passed | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run);24 real native submenu apply/restore callbacks passed | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run);24 real native submenu apply/restore callbacks passed | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | ruby | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | Native regional town residents; guest empty-before-snapshot and host ground replica verified; actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | sapphire | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | Native regional town residents; guest empty-before-snapshot and host ground replica verified; actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | emerald | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | firered | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Wilds | leafgreen | Partial; Gen3 adapter | Shared native schema unit-tested; full options/runtime not complete; declared native schema rows reachable (all-mod run) | actual paired host/guest non-empty ground AND sky ID/species/level rosters converge; isolated standalone boot; bound selected-ball throw and targeted native capture/storage passed (six companions disabled); paired guest bound capture stored only on guest, one debit, shared actor removed on both |
| Modern UI | red | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | blue | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | yellow | Partial; Gen1 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | gold | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | silver | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | crystal | Partial; Gen2 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | ruby | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual online single/double/trade entry captures inspected; no complete screen audit; isolated standalone boot passed (six companions disabled) |
| Modern UI | sapphire | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Actual online single/double/trade entry captures inspected; no complete screen audit; isolated standalone boot passed (six companions disabled) |
| Modern UI | emerald | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | firered | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |
| Modern UI | leafgreen | Partial; Gen3 adapter | Source inventory; not complete runtime proof; declared native schema rows reachable (all-mod run) | Unverified; isolated standalone boot passed (six companions disabled) |

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

Gen2 paired battle follow-up: Crystal and Gold native singles exercised fainted-slot replacement and returned without mutating saved HP/PP. Gold, Silver and Crystal doubles independently completed with mirrored win/lose outcomes and matching turn hashes. Fixture explicitly checks native battle.over and rejects doubleRoom.failed; replacement selection uses the native party menu. Other encounter/switch/edge cases remain unverified.

Red, Blue and Yellow were subsequently run independently through paired online doubles: each pair completed with mirrored win/lose result, verified turn hash and preserved saved HP/PP. The fixture uses native party-menu replacement and native actions; no direct battle result injection. Full singles/trades and wider disconnect/switch matrices are still distinct open work.

All eleven editions independently passed real paired host/guest field-roster convergence: both non-empty ground and SKY ID/species/level fingerprints match across separate processes. This validates common visible actors; it does not yet verify every contact claim, simultaneous throw, rejoin, remote-map lifecycle or motion frame. Fixture: `tools/qa/native-online-roster.lua`.

### Native RS options and standalone dependency checks

All 77 mod×edition isolated boots pass on engine0.3.52: every target initializes and runs its native world with all six companions disabled; the fixture asserts the loaded-mod list contains only the target. This is startup/world-loop fallback evidence, not proof of every standalone feature or battle.

The actual Ruby/Sapphire Options check found six composed InGameOptions adapters dropping the native cartridge-row argument from Rows.build. This forced FRLG text lookup and crashed native RS Options. All six now forward every argument; focused tests cover active and unloaded wrappers. Native RS Options now opens and WORLD inversion changes/restores its real setting. A scoped native RS overflow adapter now clips only each mod’s label column and scrolls the selected full name in integer pixels, retaining upstream names/values/native font. Native rows and value text are unchanged. Ruby and Sapphire before/after-scroll captures were inspected; focused tests cover ownership and unload.

All five Gen3 editions independently passed standalone selected-ball input: native input.key press on the configured throw key launches the selected GREAT BALL, debits its native bag count exactly once, and removes the completed projectile. These clear-field throws do not substitute for targeted capture/PC overflow/network reservation verification. Wilds c8b10e5b replaces its added Gen3 black/text overlay with native Window/Font framing and integer scaling; native battle/trade suppression remains covered by the 66-assertion catch binding test. Ruby native frame inspected; LeafGreen follow-up captured separately.

Red, Blue, Yellow, Gold, Silver and Crystal also independently passed standalone configured-key GREAT BALL throws, exactly-one inventory debit and native projectile cleanup. Together with the GBA passes this covers the basic selected throw in all eleven editions; catching a targeted actor, PC overflow and simultaneous network throws remain separate cases.

All five GBA editions additionally passed standalone targeted capture against an actual naturally seeded visible spawn. The configured key launches a selected MASTER BALL through native catch/storage logic; native party species, exactly-one inventory debit, and captured actor/projectile removal are asserted. Fixture freezes only the target movement for deterministic aiming; it does not force catch results or inject storage. Party-full/PC overflow, network claims and GB targeted catches remain separate unverified cases. Driver: `tools/qa/gen3-standalone-capture.lua`.

Red/Blue/Yellow/Gold/Silver/Crystal independently pass targeted native standalone MASTER BALL capture, native party species, inventory debit and actor removal. Combined with GBA this is all eleven editions for this case. Additional actual Yellow/Crystal full-PC checks exposed and verify Wilds `a3fd96d4`: rejected native storage now retains and unlocks the actor without marking the dex owned. Native full-storage warning captures inspected; shared native capture/storage test passes104 assertions and flow/Gen2 compatibility tests pass. `tools/qa/gb-standalone-capture.lua` supports `QA_FULL_PC=1`; simultaneous network claims remain unverified.

Actual paired Red/Blue/Yellow/Gold/Silver/Crystal flight and landing now pass alongside ground riding, with remote mount identity/height and no local-player mounting side effect. Ride `4466b4b` decouples network species from the optional Stadium render gate. Wilds `02e01db1` fixes follower suspension overwriting newer world-update wrappers, which froze Gen1 takeoff at zero altitude. Regression covers retained external update owner, inert suspended wrappers, and exactly-one follower tick after reinstall. Existing five-GBA paired ride checks remain distinct; Surf and all transition combinations are not yet exhausted.

Standalone GB Ride follow-up: all six editions pass bound flight shortcut, positive altitude, landing and ground mount/dismount with all companions disabled. Previously the GB builders could fail without an external follower sprite provider; owned six-facing HGSS assets now provide the fallback while public provider precedence remains. Sprite frames retain32px geometry and native Gen1 palette conversion preserves opaque orange/white pixels. Native Red/Crystal captures inspected; dedicated owned-asset/palette and network-pose tests pass. Surf fallback is implemented but its native traversal lifecycle remains unverified. Driver: `tools/qa/gb-standalone-ride.lua`.

Standalone native Surf also passes independently in all six GB editions: valid native shoreline, native SURF user (and Gen1 badge gate), native surf-start step, owned LAPRAS visual and stop cleanup. Red/Crystal native captures inspected. Crystal additionally asserts the real player reached a native water cell. This does not establish all ocean transitions, waterfalls, dive or paired Surf replication. Driver: `tools/qa/gb-standalone-surf.lua`.

Native schema reachability now checked independently in all eleven editions:202 primitive declared rows per GB edition and545 per GBA edition, including Ride advanced/per-species controls. Wilds24 GB submenu controls additionally execute their real apply/restore callbacks against native option storage. All rows are reachable; this does not prove every consumer or equal feature counts, and diagnostic/provider-dependent Battle Art rows retain the documented limitations. The old Gen2-only Online shiny_sparkles definition had no consumer and was removed in5f6f914 rather than expose a dead control. QA: `tools/qa/suite-native-options.lua`; Ruby/Sapphire use their own native option_menu.

Red/Blue/Yellow now independently pass paired native singles (mirrored completed outcomes, saved HP/PP preserved, world control restored) and native trades (real menu selection/consent, native animation/save, exchanged nicknamed party members, world return). Red trade/return captures inspected. These complement the prior doubles checks; Gen1 trade evolution, every switch/disconnect edge and all UI screens are not inferred. QA: `tools/qa/gen1-online-trade.lua` and existing Gen1 online battle fixture.

All eleven editions independently pass an actual host-reserved guest capture: naturally populated shared field actor, guest bound MASTER BALL throw, native guest party storage/exactly one ball debit, no host party/bag mutation, and matching actor removal on both clients. The fixture uses public native line-of-throw validation (walkable adjacency alone can face an impassable ledge), freezes only the chosen host actor's wander for reproducibility, and does not inject the catch/store result. Authority regression tests also pass for duplicate claims, replay, disconnect recovery and sky concurrency. Simultaneous actual input throws, late join/rejoin and full-PC network cases remain distinct unverified work. QA: `tools/qa/gb-online-capture.lua`, `tools/qa/gen3-online-capture.lua`.

All five GBA editions also pass standalone Ride G/H mount shortcuts, PageUp altitude change, landing/dismount cleanup, and native Surf hop into water/return to shore with owned Lapras (FRLG) or Pelipper (RSE) artwork. Native LeafGreen flight and Surf captures inspected; no companion loaded. Together with the GB checks this covers basic standalone ground/flight/Surf in every edition, not every field transition or multiplayer Surf. Drivers: `tools/qa/gen3-standalone-ride.lua`, `tools/qa/gen3-standalone-surf.lua`.

Doubles9bec5ee fixes a demonstrated Gen1 ownership regression: Red/Blue/Yellow visible Wilds encounters now keep exactly their supplied single enemy under ALWAYS. The old script-only exception/guard allowed conversion; current native queues can also bypass that script wrapper. Public optional pending provenance guards both and abandons an older sky rendezvous. Actual three-edition encounter assertions and37 source/provider regressions pass; next unowned organic encounter still doubles. Driver: `tools/qa/gen1-visible-double-guard.lua`.

All five GBA editions independently pass standalone organic wild doubles: native encounter roll/provenance, four battlers, enemy HP decreases, natural completion and field return, with six companions disabled. Native FRLG battle screenshot inspected. RSE native roll uses land classification; it is not inferred from FRLG. This does not exhaust move effects/capture/switching/trainer-pair cases. Driver: `tools/qa/gen3-standalone-double.lua`.

The six GB editions also independently pass standalone native organic doubles: actual native grass-step roll, both enemies, HP reduction and natural field return. Crystal command-screen render inspected after waiting through its native intro. Together with GBA this is all eleven editions for a basic standalone wild double; full move/target/switch/capture matrices remain unverified. Driver: `tools/qa/gb-standalone-double.lua`.


Gen2 native doubles layout follow-up: Doubles f683e8c reuses the native ROM sprite/animation and HUD methods in four non-overlapping slots, with per-slot HP/status/EXP identity. Gold/Silver/Crystal standalone and paired Crystal/Red battle completion pass; Crystal/Silver native menu captures inspected. All companions loaded with Modern UI and 3D-BTL disabled also retain the clean native layout. Optional scene backplates now share that slot layout instead of covering it with two single-battle boxes; absent render companions use the original native field.

Gen2 3D-BTL with overworld WORLD OFF previously built/suppressed actors without delivering the staged canvas. Gen2BattlePipeline now selects the existing guarded voxel pipeline only inside World.draw when a finished arena exists; saved settings and non-battle pipeline selection remain untouched, including failure cleanup. Crystal actual organic double with all companions loaded/Modern UI off was visually inspected and completed naturally; Gold independently passed and asserted the saved overworld level stayed zero. Scoped pipeline regression and Gen2 support202/202 pass. QA: tools/qa/gen2-offworld-double.lua (QA_STAGE=off selects native fallback). This closes that settings interaction, not every battle lifecycle/provider combination.


Online e9e5937 fixes a real reconnect failure: the native two-peer transport closed the LAN listener when its guest left. An established LAN host now cleans up the old activity/session and listens again on the same port; explicit Disconnect stops hosting, failed bind does not retry-loop, and relay behavior is unchanged. Red/Blue/Yellow/Gold/Silver/Crystal/Ruby/Sapphire/Emerald/FireRed/LeafGreen each independently passed paired disconnect, same-address rejoin, and fresh nonempty host ground+sky roster reconvergence. LeafGreen native field/chat capture inspected. Authority/discovery/sky lifecycle units pass. This uses a fresh authoritative session after reconnection; exact pre-disconnect spawn IDs are not promised. QA: tools/qa/native-online-rejoin.lua. Disconnect during trade/battle/capture remains a separate runtime matrix.


Full-storage network follow-up (engine0.3.52): all eleven editions independently passed both endpoints of a host-reserved guest capture whose native storage becomes full between the public request/grant callback and resolution. Native party and ball count remain unchanged, the exact shared actor is restored on both clients, and host inventory/party remain unchanged. The fixture fills storage at that race boundary; it does not replace catch/storage results. Wilds962af2cf adds the missing native catching-HUD rejection feedback; the LeafGreen warning was visually inspected. QA: tools/qa/gb-online-fullpc.lua and tools/qa/gen3-online-fullpc.lua. This evidence is not a recertification on engine0.3.73; simultaneous input and disconnect-mid-capture remain separate cases.


Engine0.3.73 paired native Surf follow-up: FireRed, LeafGreen, Ruby, Sapphire and Emerald each independently pass both endpoints: native shoreline hop, local water mount, remote species/mode, native shore return, remote mount removal and chat completion. Online now supplies the optional Gen3 `gen3Pose` metadata already represented by the GB wire contract; encoded native mount graphics remain unchanged. Missing/old Ride still falls back cleanly. LeafGreen native render inspected. All seven mods load; unrelated ground/sky contact encounters are disabled to isolate the transition. Four focused provider/authority/sky/reconnect suites pass. QA: tools/qa/gen3-online-surf.lua. GB paired Surf, waterfalls/Dive and interrupted transitions remain unverified.


Gen3 doubles target-row and hover-card regression (engine0.3.74): native LeafGreen and Emerald trainer doubles independently pass Left/Right foe-only navigation, Down teammate/Up remembered foe, horizontal no-op on ally, native cancel, and partner-turn selection. Visible/hidden native target-blink captures inspected in both editions; the selected status card keeps its world head projection instead of falling back to native2D coordinates. Focused world-projection and target-legality units pass, including self-allowed moves and absent partners;57 native adapter contracts pass. QA: tools/qa/gen3-target-rows.lua. Native unstaged target input uses the same optional Doubles wrapper; the modern appearance remains owned by Modern UI. Physical controller hardware was not separately tested (the native logical directions are shared). Gen1/2 ally resolver/wire support was subsequently implemented and verified in the 2026-10-11 batch above.

### 2026-10-11: native Legendary tunnel consumer (engine 0.3.76)

`NativeLegendaryTunnels` reuses the shared `UndergroundRoom` floor, closed panel
and lamp kit in the two FRLG underground corridors. Wall details are fitted wholly
inside native blocked cells; stairs, exits, warp behavior and collision remain
native. The original option label/values are registered in Game3 settings. OFF
restores source artwork. Entrance halls and other tunnel families remain
unadapted; this is a **partial** scenery consumer, not complete map coverage.

Official 0.3.76 `.love` and Linux AppImage checksums verified. Isolated native
LeafGreen north/south (250 floor cells, 89 wall segments) and FireRed east/west
(144 floor cells, 77 wall segments) ON/OFF render checks passed; images inspected.
Tracked driver: `tools/qa/native-legendary-tunnels.lua`. Focused bounds, native
stairs, OFF/custom-map fallback, adapter and 541 option-consumer checks pass.
Evidence: `.scratch/parity-073-20261011/results/{leafgreen,firered}-native-legendary-tunnels-host`.
Follow-up: both corridors also verified in first person. Foreground walls respect
CUTAWAY in third person; inside-eye views retain all sides. Per-side meshes share
no unused vertex copies. The east/west fixture now starts on a real floor cell.

### 2026-10-11: native CITY GROUND consumer (engine 0.3.76)

The original CITY GROUND ladder now consumes the existing shared `LawnMaterial`
for Lavender and Fuchsia. Replacement polygons follow exact native turf-colored
floor pixels; sand paths, solid cells, native objects, elevations and original
OFF artwork remain authoritative. This is partial: authored garden fixtures,
courtyard details and non-flat ground families are not claimed complete.
Scene invalidation now includes CITY GROUND and TUNNELS, so live menu changes
rebuild their geometry rather than requiring a map transition.

Native isolated LeafGreen Lavender (618 source floor cells) and FireRed Fuchsia
(859) ON/OFF checks passed on official 0.3.76; paired renders inspected. Focused
source-mask/footprint/elevation/UV/option-invalidation checks, original roads
regression and 541 native option checks pass. Driver: `tools/qa/native-city-ground.lua`.
Evidence: `.scratch/parity-073-20261011/results/{leafgreen,firered}-native-city-ground-host`.

### 2026-10-11: native BUILDING STYLE consumer (engine 0.3.76)

The existing `ReferenceBuildings.model` kit now has a guarded FRLG Vermilion
adapter, using actual native warp coordinates for doors. Below-head detailing
stays inside the reviewed solid body; shapes with walkable body cells, missing
warps, unknown families or custom map IDs retain installed geometry. Native door
opening/closing art is projected into the authored doorway. The Gen3 default is
INSTALLED; saved upstream choice values remain authoritative. Gen1 is unchanged.

Both isolated editions rendered the native fan club replacement and INSTALLED
fallback on 0.3.76; first-person door captures inspected. LeafGreen additionally
awaited complete native open/close callbacks. Other house families are guarded
but were not replaced in this fixture: BUILDING STYLE remains **partial**, not
all Vermilion buildings or complete city coverage. Focused authored-geometry,
blocked-body, native-warp, fallback, generation-adapter and option checks pass.
Driver: `tools/qa/native-legendary-buildings.lua`; evidence in
`.scratch/parity-073-20261011/results/{leafgreen,firered}-native-legendary-buildings-host`.

### Gen2 BUILDING STYLE: shared native Vermilion models (0.3.76)

Gold, Silver and Crystal now consume the shared authored building kit on six
reviewed Vermilion house/club assemblies. Native warp doors and blocked body
cells bound the replacement; unknown shapes and walkable bodies keep installed
geometry. INSTALLED remains the native default; saved upstream values win.
The native mesh fingerprint includes the setting so toggling cannot replay the
opposite style from disk. Gen1 defaults and gameplay collision are unchanged.

All three isolated editions passed actual renderer ON/OFF, first-person and
fingerprint-difference checks on official 0.3.76. Gold/Crystal first-person and
Silver overview captures inspected. Shared constructor, native warp, clear-floor
rejection and source-palette tests pass; 541 option-consumer checks pass.
Driver: `tools/qa/gen2-native-buildings.lua`; evidence in
`.scratch/parity-073-20261011/results/{gold,silver,crystal}-gen2-native-buildings-host`.
This remains **partial**: unreviewed service buildings retain their existing
models; no claim of complete city or global model coverage.

### Native PRIZE ROOM wall panels (0.3.76)

FireRed/LeafGreen Celadon prize room now consumes the optional shared authored
PrizeRoom wall kit and palette on seven reviewed back-wall strips. Exact native
top/bottom metatile patterns, blocked cells and neighboring floor guard the
replacement. Brass ribs and fabric panels remain within the solid wall strip;
clerks, counters, floor, exits and native interaction logic are unchanged.
Native default/OFF restores its original artwork. The setting is registered
with the native options adapter and invalidates the scene on change.

Both editions passed official 0.3.76 ON/OFF and first-person renderer checks;
FireRed panels/first-person and LeafGreen original fallback captures inspected.
Shared geometry, source-pattern rejection, walkable-cell exclusion, custom-map
fallback and adapter tests pass, along with 541 option-consumer checks.
This remains **partial**: ceiling, full enclosure and authored furnishings are
not ported. Driver: `tools/qa/native-prize-walls.lua`; captures/logs under
`.scratch/parity-073-20261011/results/{firered,leafgreen}-native-prize-walls-host`.

### Native FENCES & COURTS: authored fence bays (0.3.85)

Extracted the existing Gen1 post/collar/rail construction into the shared
LegendaryFenceKit without changing its geometry. Gen3's optional consumer uses
that kit with each reviewed native fence cell's original material, axis, bend
and endpoint. Rail halves are clipped to their own blocked cell, including
closed undersides; walkable cells never acquire geometry. Native OFF remains
unchanged. The native option is registered and invalidates its scene on change.

Official 0.3.85 .love and matching Linux AppImage were verified against release
SHA256 sums. Fresh isolated native imports and ON/OFF/first-person rendering
passed independently in FireRed and LeafGreen (Fuchsia, cell21,7). LeafGreen
first-person and FireRed original fallback captures inspected. Bounds, endpoint,
source-shape immutability, OFF/walkable rejection, existing native outdoor and
adapter tests pass; 541 option-consumer checks pass. This option stays **partial**:
authored courtyard paving and special landscaping are not yet adapted.
Driver `tools/qa/native-legendary-fences.lua`; evidence:
`.scratch/parity-073-20261011/results/{firered,leafgreen}-native-legendary-fences-host`.

### Native CASINO exterior consumer (0.3.85)

The optional Gen3 CASINO setting now installs the existing Gen1 CityArchitecture
and CasinoFacade models for Celadon's casino and prize annex. Exact native 7x5
and 3x4 drawing recipes are added only when enabled; native warp destinations
identify each building and source blocked-body guards preserve all walkways.
Shared neon/material tags remain intact. Native door animation draws ahead of
carved relief, preserving its native callbacks/timing. OFF retains original art.
No native map, collision, script, encounter or menu data is modified.

FireRed and LeafGreen fresh isolated official 0.3.85 imports each rendered two
actual models, first-person views and original fallback and completed native
door open/close callbacks. LeafGreen overview and FireRed final open-door renders
inspected; final door projection depth correction was visually checked in FireRed.
Shared model, native warp/destination rejection, low-footprint bounds, civic,
adapter and 541 option-consumer checks pass. CASINO remains **partial** because
native interiors and non-Celadon families still use their original presentation.
Driver: `tools/qa/native-legendary-casino.lua`; evidence under
`.scratch/parity-073-20261011/results/{firered,leafgreen}-native-legendary-casino-host`.


### Native mature TREES consumer (0.3.85)

Gen3 TREES now shares the actual Gen1 CommunityFlora mature builder, materials
and detail recipe through a CPU-only template API. Instanced prototypes reuse
GPU geometry; native source width/height determine scale. Low geometry must
fit blocked native cells, so unknown boundary cells and walkable footprints
retain native models. Dedicated forest/Safari families keep their own settings.
OFF restores original models. No map/collision/live Gen1 tree registry changes.

Fresh isolated FireRed and LeafGreen 0.3.85 each rendered 85 replacements;
Emerald Oldale rendered 128. Actual LeafGreen and Emerald overview renders
inspected, first-person and OFF captures produced. First Emerald boot fixture
exhausted its frame wait during initial build; the diagnostic rerun completed
with actual collision guards and OFF assertions. CPU template, cooperative
build-budget/context restoration, footprint, forest/OFF guards, Gen1 tree
regressions, native adapter and option-consumer tests pass. Ruby/Sapphire are
not runtime-verified for this batch; full wind and unknown/synthetic footprint
coverage remain partial. Driver: `tools/qa/native-legendary-trees.lua`; evidence
under `.scratch/parity-073-20261011/results/`, including
`emerald-trees-debug-host` and `{firered,leafgreen}-native-legendary-trees-host`.


Native mature-tree follow-up: explicit `boundary=forest` scenery outside real
connected maps now shares the same prototypes; real collision 0 always rejects
replacement, even with a forest label. Water/unknown boundaries stay native.
Emerald 0.3.85 rendered 613 trees including forest fill; independent fresh Ruby
and Sapphire identities each rendered 593, completed first-person/OFF checks,
and overview captures were inspected. Initial RS runs timed out before captures;
explicit NVIDIA GLX selection completed both unchanged fixtures. Their evidence
is `results/{ruby,sapphire}-native-legendary-trees085` under the same scratch root.
Full wind and unreviewed footprint coverage remain partial.

The stale Gen2/3 DISTANT BIRDS inventory rows now identify existing real
KantoFirstPerson/KfpBirdArt/KfpAtmosphere consumers: native public sprite
providers, owned-cache invalidation, outdoor gate and independent OFF default.
This is a source audit plus focused bird-cache/541-consumer regression checks;
it does not relabel prior sky captures as current or claim all-edition runtime QA.

### Native-effect camera input continuity (0.3.85)

Gen3 native fly/teleport/flash and other temporary presentations retain their
native artwork, but no longer suspend polled right-mouse look or third-person
boom controls merely because the voxel field did not draw that frame. The
current yaw/pitch/zoom remains live and returns with the next voxel frame.
Native menus still own input; unsupported effect renderers are not replaced.

Focused integration regressions cover effect entry, mouse motion, zoom, return
and menu ownership, plus existing escalator/boom checks. A real Emerald native
background flash on official 0.3.85 retained polled mouse direction and returned
to the voxel field; returned render inspected. Fixture:
`tools/qa/native-effect-camera.lua`; results
`.scratch/parity-073-20261011/results/emerald-native-effect-camera-host`.
This verifies input-state continuity, not 3D replacement of every native special
effect or an all-generation/all-transition camera claim.
