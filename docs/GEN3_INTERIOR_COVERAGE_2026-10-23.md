# Five-edition native interior inventory

The official latest engine release was checked before this batch: **0.3.95**,
published 2026-10-21T02:42:51Z. The official Linux LÖVE shell and matching source
ran separate disposable edition profiles. No player saves were used.

Every entry in each edition's `game.data.maps` was decoded, classified and
hashed before/after extraction. All five drivers emitted their final census;
the Linux shell returned 1 on shutdown. No clean process-exit claim is made.

| Edition | Maps | Framed non-cave rooms | Native wall finish rooms | Extracted furniture | Modern placement candidates |
| --- | ---: | ---: | ---: | ---: | ---: |
| Emerald | 519 | 301 | 79 | 2091 | 389 |
| Ruby | 395 | 231 | 84 | 1476 | 397 |
| Sapphire | 395 | 231 | 84 | 1476 | 397 |
| FireRed | 426 | 253 | 65 | 2937 | 398 |
| LeafGreen | 426 | 253 | 65 | 2937 | 398 |

The ledger is [maps.jsonl](coverage/gen3-interiors-2026-10-23/maps.jsonl).
It records every map, native pair/header, dimensions, source-layout SHA-256,
room adapter and extracted furniture families. The companion
[families.json](coverage/gen3-interiors-2026-10-23/families.json) groups source
candidates and edition/map occurrences. These are identifiers and counts only;
no ROM data, raw pixels, model archives, caches or captures are included.
JSON object keys are canonicalized recursively so repeated censuses do not
reorder unchanged native room metadata. All 2161 native hashes are unchanged;
the latest batch changes only 18 RSE Mt. Pyre maps, adding 793 recognized source owners.
All previous furniture-family counts and source candidates remain unchanged.

The refreshed census includes the verified Littleroot table/refrigerator and
both Oldale table adapters, and all 39 generic-home refrigerators,
the original BDSP server adapter for all 61 matching institutional racks,
the genuine ORAS china cupboard at all 74 matching RSE locations,
the original Oldale sink/worktop at all 39 matching RSE locations,
and the genuine Mt. Pyre memorial at 682 common Pokémon Tower grave locations and all 793 complete common/wall-shadow
graves on the 18 RSE Mt. Pyre floors.
The latest full census retains all 2161 native map entries. Separate
[accepted-furniture.jsonl](coverage/gen3-interiors-2026-10-23/accepted-furniture.jsonl)
records 1934 visually accepted component placements across 258 native maps in
all five editions, with exact family, model ID, cell and unchanged live native hash. Its acceptance
scope is the named furniture component only. Complete-map acceptance remains
false; the remaining furniture and room source gaps are still outstanding.

All twelve physical source models now opt into the shared 0.025-pixel contact
recess. Only source Y0 vertices move below the floor; every upper vertex and
all native floor/wall/gameplay cells remain identical. CPU checks compare both
fits, and native 0.3.95 checks include all 158 older PC, TV and bed placements
in all five editions. Individual first-person and room overview captures were
inspected; all 62 Emerald/FireRed fixture maps also pass missing-source fallback.
The bed's replacement exact-rim closures remove the prior concave cap overlaps.
Geometric tests find no positive-area coplanar triangles in all twelve models.
The native drivers emitted PASS
and the shell returned 1 at shutdown. The independent room-framing experiment
is held outside this batch; it does not change the census's room counts.

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
