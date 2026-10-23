# Five-edition native interior inventory

The official latest engine release was checked before this batch: **0.3.95**,
published 2026-10-21T02:42:51Z. The official Linux LÖVE shell and matching source
ran separate disposable edition profiles. No player saves were used.

Every entry in each edition's `game.data.maps` was decoded, classified and
hashed before/after extraction. All five drivers emitted their final census;
the Linux shell returned 1 on shutdown. No clean process-exit claim is made.

| Edition | Maps | Framed non-cave rooms | Native wall finish rooms | Extracted furniture | Modern placement candidates |
| --- | ---: | ---: | ---: | ---: | ---: |
| Emerald | 519 | 301 | 79 | 1830 | 49 |
| Ruby | 395 | 231 | 84 | 1210 | 49 |
| Sapphire | 395 | 231 | 84 | 1210 | 49 |
| FireRed | 426 | 253 | 65 | 2937 | 28 |
| LeafGreen | 426 | 253 | 65 | 2937 | 28 |

The ledger is [maps.jsonl](coverage/gen3-interiors-2026-10-23/maps.jsonl).
It records every map, native pair/header, dimensions, source-layout SHA-256,
room adapter and extracted furniture families. The companion
[families.json](coverage/gen3-interiors-2026-10-23/families.json) groups source
candidates and edition/map occurrences. These are identifiers and counts only;
no ROM data, raw pixels, model archives, caches or captures are included.

Every row has `renderedAccepted: false`. Candidate placement does not prove
successful mesh/texture upload or visual acceptance. Furniture counts include
walls, attachments and walkable cushions owned by the furniture extractor.
They do not prove that every native object was recognized. Existing continuous
native finishes do not constitute imported modern room coverage. The per-map
`sourceCandidates` counts furniture owners; the total candidate count includes
multiple physical placements belonging to one owner, such as truck cargo.

Do not filter by edition map prefix: both Kanto editions also contain eight
unprefixed `SEVII_ONE_ISLAND*` maps. LeafGreen retains canonical `FR_` map IDs.

The census identifies an actionable framing gap in both Ruby and Sapphire:
`SS_TIDAL_CORRIDOR`, `SS_TIDAL_LOWER_DECK`, `SS_TIDAL_ROOMS`, and
`ROUTE114_FOSSIL_MANIACS_TUNNEL`. Weather-suppressed outdoor docks/islands
remain separate and must not acquire ceilings. Native Ruby before-images were
inspected for all four gaps and Brendan's first-floor room. Their existing
native furniture remains a source-import gap.

Reproduce with `tools/qa/gen3-all-map-inventory.lua` in the matching engine,
an isolated `*-qa` identity, and explicit `QA_UTIL` / `SHOT_DIR`. Summarize the
five edition JSONL files in Emerald, Ruby, Sapphire, FireRed, LeafGreen order
using `tools/summarize_gen3_map_inventory.py`. No visual acceptance is inferred.
