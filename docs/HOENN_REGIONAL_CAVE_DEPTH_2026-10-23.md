# Fiery Path and Meteor Falls depth — 2026-10-23

Extends the reviewed Hoenn outdoor mouth adapter to both Fiery Path entrances
(native256/25e red rock) and both Meteor Falls entrances (259/261 khaki rock).
Each keeps its native regional cap/side art and the existing12px/16px outer
rock profile, with a standing arched ceiling, side reveals and22px recess.
Fiery Path's southern header is legitimately a walkable native projection;
only this exact header/art context permits collision0 beneath the high hood.
Native warps, collision, elevations, floor coordinates and openings stay intact.

Meteor Falls also exposed13 omitted native khaki rock-face variants around the
mouths:23b,23d,24b,24c,24d,253,254,255,25b,25c,263,264,265. They were flat among
already-raised pieces of the same mountain. Exact blocked copies now use the
existing16px cap241/side243 profile; native walking copies and mixed grass
corners stay native. No global wall-height change. Independent native RSE art
review found11 hash-identical families;255/263 retain separately inspected RS
stone-paint variations. Identifier/hash proof is in
`coverage/hoenn-khaki-cave-native-2026-10-23.json`; no native pixels ship.

The native Route115 perimeter lowers two outer cap triangles exactly to Y0.
The threshold floor already owns that plane. Remove only each duplicate ground
triangle, preserving its raised half, seam coordinates and original UVs. This
fixes the demonstrated positive-area overlap instead of raising whole models or
moving native portals/ground. New regression catches the previous overlap.

This remains a native-art geometry fix, not an original ORAS model intake. It
uses the shared optional prepare/append/support hook described in
HOENN_CAVE_ENTRANCE_DEPTH_2026-10-23.md; Scene/Gen3Terrain stay root/Kanto-owned.
Standalone/API3 and HD2D actor/Pokemon/flower defaults are unchanged.

## Exact acceptance

Latest official engine checked before the batch:0.3.96, commit
0e92b587468c2db7c386f055fc272e6505b0f401. Own isolated profiles and the same
scratch-only shared-hook overlay; no player saves, root engine or seeds changed.
Exact final adapter SHA-256:
`6f07c6b4725d157c9b11eb2fe6782f3cfa99b895730e9a8e7d62516449a8d572`.

| Edition | Cave owners | Newly raised khaki wall cells | Native entry/return cases | Result |
| --- | ---: | ---: | ---: | --- |
| Emerald |18/18|449|6|PASS |
| Ruby |16/16|441|6|PASS |
| Sapphire |16/16|441|6|PASS |

Each edition tests Rusturf, Fiery Path and Meteor Falls by normal held movement
from a native walkable approach, enters the actual interior, steps inside and
returns, at levels0 and3. Sealed Regi caves remain sealed in the default state;
the explicit in-memory opened-story fixture is retained for eligible-owner
review. All settled MID/collision/elevation hashes stay unchanged, recovery0.
The counts above refer to actual scene-owned mouths and live native classified
wall cells on Routes114/115, not broad source eligibility or complete Hoenn.

Every final emitted owner passes the independent geometry audit:90 or92
nondegenerate triangles, one floor owner, three ceiling segments, three recessed
rear segments,22px depth and zero positive-area coplanar overlaps. Route115's
removed ground halves account for the90-triangle variant. No cap/body or door
anchor translation was used.

Full native/front/first/side/rear regional captures were produced before and
after. Inspected Fiery Path/Meteor Falls first-person recesses, regional paint,
new continuous khaki masses, side views, native stairs and nearby ground. Final
exact-code Route115 front/first/side/rear captures in all editions confirm the
contact correction; audited coordinates/UVs, not a visual depth bias, establish
zero overlap. Unaffected initial14/12 mouths rerun in the same final native tour.

Focused Hoenn cave geometry/eligibility, complete Hoenn classification/furniture,
Ruby/Sapphire checked-family dispatch and existing cave-profile LuaJIT suites
PASS. The Hoenn suite now checks all13 new faces in each edition, native walking
copies and atlas isolation. Both QA drivers compile; diff whitespace passes.

Final evidence, excluded from Git:
`.scratch/hoenn-world-096-20261023/cave-regional-contact-final/`
contains per-edition geometry audits and
`hoenn-cave-entrances/{edition}/hoenn-cave-entrances.json`, exact SHA, live cell
counts, native hashes, six entry/return results, logs and final Route115 captures.
Earlier complete regional view sets are under `cave-regional-after`; the before
set is under `cave-regional-before`. Initial intermediate audits correctly found
the Route115 floor overlap and are superseded by the exact final zero-overlap
reports. These are source-hook-overlay checks, not released ZIP acceptance.

Remaining separate families: white Cave of Origin architecture, water-facing
Scorched Slab, shorter Emerald Altering Cave, conditional Emerald Magma/Terra/
Marine states and underwater cave entrances. Interiors belong to the interior
worker; original modern-source cave coverage remains separate and incomplete.
