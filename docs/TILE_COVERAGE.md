# Crystal and FireRed tile coverage

Snapshot: Battle Art 1.28.6, Gen1Recomp 0.3.20 Linux, 2026-09-26. Refreshed
from the native Crystal and FireRed inventories in disposable profiles. Ledgers
contain identifiers and counts, no ROM pixels. LeafGreen specialty scenes were
also rendered, but its complete census is not substituted for FireRed's.

| Game | Maps | Native cells accounted for | Distinct treatment rows |
| --- | ---: | ---: | ---: |
| Crystal | 388 | 147,500 | 2,376 |
| FireRed | 426 | 234,366 | 11,279 |

Every inventoried cell contributes exactly once. This is classification coverage,
**not** proof that every tile has an authored model or that every map, camera,
dynamic state, animation and multiplayer interaction has been visually approved.

- [Crystal ledger](coverage/crystal-tiles.csv): complete four-tile source drawing,
  collision, treatment, count and an example map/cell. `classified_*` describes
  the classifier; `generic_wall_review` includes both correct walls and props
  needing a more specific model.
- [FireRed ledger](coverage/firered-tiles.csv): native tileset pair/metatile,
  treatment, count and example map/cell. `reviewed_surface` is art intended to
  stay flat; `unreviewed` does not imply that a flat floor is wrong.
  `unmatched_building` did not form a recognized building column.

## Current review queue

Crystal: 24,754 generic wall cells still need semantic/visual review.
FireRed: 74,506 unreviewed cells and 297 unmatched building cells remain.

All 426 FireRed scenes are now enabled by the renderer; the old report's 105,756
native-fallback cells are no longer current. Enabling a scene is not finishing it.
The new complete patterns match 12 Crystal timber columns, one lighthouse
apparatus, four ship tables, and one FireRed museum space exhibit. Location
restrictions prevent the shared lighthouse/ship artwork receiving the wrong model.

Other specialty rooms, landmarks, cave walls, edge cases in terrain/buildings,
first-person close-ups and Gen3 battle actors/camera still need work. Gen1 remains
the reference, not a claim of exhaustive perfection. Existing exterior-only
[queue](coverage/exterior-maps.csv) predates this census and is not a current
visual sign-off. See [this pass's evidence](SPECIALTY_QA_2026-09-26.md).
