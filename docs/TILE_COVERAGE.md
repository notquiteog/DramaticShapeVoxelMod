# Crystal and FireRed tile coverage

Snapshot: 1.21.0-beta.3, actual Gen1Recomp 0.2.73 Linux runtime, disposable
profiles and the user's already imported Crystal/FireRed data. No ROM pixels
or imported art are included in the ledgers.

| Game | Maps | Native cells accounted for | Distinct treatment rows |
| --- | ---: | ---: | ---: |
| Crystal | 388 | 147,500 | 2,295 |
| FireRed | 425 | 240,512 | 11,146 |

Every cell in these map inventories contributes to exactly one ledger row.
This does **not** mean every drawing has a custom model, every map was rendered,
or every model has been visually approved. Unused atlas art, dynamic map states,
actors, animations, cutscenes and all possible camera positions require separate
coverage. Shared IDs can receive different treatments in different contexts.

- [Crystal ledger](coverage/crystal-tiles.csv): tileset, four-tile drawing,
  collision, treatment, count, number of maps and example map/cell coordinates.
  `classified_*` records the production classifier, not a visual sign-off.
  `generic_wall_review` includes correct walls as well as unmodeled props.
- [FireRed ledger](coverage/firered-tiles.csv): native tileset pair/metatile,
  treatment, counts and an example location. `reviewed_surface` is art intended
  to remain flat; `unreviewed` is not an assertion that flat rendering is wrong.
  `unmatched_building` means a building tile did not form a recognized column.
  `native_fallback` is an intentionally retained engine scene, not a finished
  HD-2D model. Generated pair suffixes are opaque identifiers.

## Remaining review queue

Crystal still has31,353 generic wall cells across1,236 drawing signatures.
These need object/building review, especially specialty interiors, caves and
large landmarks. All82 furniture recipes now match at least once; the radio
reception desk's priority issue is fixed, but placement is not visual approval.

FireRed has66,740 unreviewed cells across4,191 tile/treatment rows,373 unmatched
building cells across149 rows, and105,756 cells in native fallback scenes.
Initial props occupy207 cells; classified tree/fence/flower/grass/ledge/shrub/
sign cells and reviewed floor/water surfaces have their own ledger categories.
Other city-specific houses/landmarks, rocks, cliff faces, specialty interiors,
gym interiors, optional post effects and battle integration still need work.
The Fighting Dojo exterior now has a complete drawing recipe alongside the
main gyms; its interior remains native.

## Reproduction and evidence

Run `tests/gen2_coverage_driver.lua` with `QA_INVENTORY_ONLY=1` in the disposable
Crystal identity, and `tests/gen3_coverage_driver.lua` in `firered-hd2d-qa`,
using the same external `SHOT_DIR`. Then run:

```
python3 tools/summarize_tile_coverage.py /path/to/SHOT_DIR
```

The summarizer verifies that ledger totals equal the native per-map totals.
Only identifiers/counts belong in source control. Native atlas catalogs and
screenshots stay outside the repository.

Focused beta3 native visual evidence:37 FireRed scene/mode captures,32 gym
exterior captures,27 outdoor-detail captures, and nine Crystal radio-room
captures. The gym driver checks all eight main exterior footprints and the
Fighting Dojo, with unchanged map cells. These checks do not certify gym puzzle
logic, battles or multiplayer.181 support and102 Crystal shape checks pass;
the static validator still has six pre-existing MK301 findings.
