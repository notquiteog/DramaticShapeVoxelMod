#!/usr/bin/env python3
"""Summarize native map inventories. These contain IDs/counts, never art.

Usage: python3 tools/summarize_tile_coverage.py /path/to/native/SHOT_DIR
The native Crystal and FireRed coverage drivers must both have completed.
"""
import collections
import csv
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
for game, ledger, inventory, cell_column in (
    ('Crystal', 'crystal-tiles.csv', 'maps.csv', 'cells'),
    ('FireRed', 'firered-tiles.csv', 'firered-coverage.csv', 'cells'),
):
    with (root / ledger).open() as handle:
        tiles = list(csv.DictReader(handle))
    with (root / inventory).open() as handle:
        maps = list(csv.DictReader(handle))
    expected = sum(int(row[cell_column]) for row in maps)
    counts = collections.Counter()
    treatments = collections.Counter()
    for row in tiles:
        assert row['example_map'] in {m['map'] for m in maps}, row
        counts[row['treatment']] += int(row['cells'])
        treatments[row['treatment']] += 1
    assert sum(counts.values()) == expected, 'ledger missed or duplicated map cells'
    print(f'{game}: {len(maps)} maps, {expected:,} cells, {len(tiles):,} distinct treatment rows')
    for kind in sorted(counts):
        print(f'  {kind}: {counts[kind]:,} cells / {treatments[kind]:,} rows')
    print()
print('PASS: every inventoried map cell is accounted for; visual approval is separate.')
