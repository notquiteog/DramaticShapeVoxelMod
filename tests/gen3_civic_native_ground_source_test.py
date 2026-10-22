"""Read-only proof against user-imported GBA caches; no ROM/pixel data ships here.

Usage: python3 tests/gen3_civic_native_ground_source_test.py GENERATED_GBA_ROOT [...]
"""
import argparse
import json
from pathlib import Path
import struct


def check(root):
    tree = root / 'map_tree'
    header = json.loads((tree / 'maps/0_10/header.json').read_text())
    tilesets = [tree / 'tilesets' / header[key]
                for key in ('primaryTileset', 'secondaryTileset')]

    def entries(mid):
        data = (tilesets[mid >= 512] / 'metatiles.bin').read_bytes()
        return struct.unpack_from('<8H', data, (mid % 512) * 16)

    grass = entries(1)
    assert grass == (0x2002, 0x2003, 0x2003, 0x2002, 0, 0, 0, 0)
    # Original Center roof art actually overlays this exact four-tile lawn.
    assert entries(0x48)[:4] == grass[:4]
    assert entries(0x49)[:4] == grass[:4]
    # Both original lower side borders retain the same native grass quadrants.
    assert entries(0x60)[0] == grass[0] and entries(0x60)[2] == grass[2]
    assert entries(0x63)[1] == grass[1] and entries(0x63)[3] == grass[3]
    for mid in (0x1D0, 0x1D8, 0x1D9, 0x1E0, 0x1E1):
        assert entries(mid)[:4] != grass[:4], 'light path mistaken for dark lawn'
    # Honest limitation: the right roof overhang has a path background. This
    # does not make the building's foundation lawn light, and raw bottom-layer
    # reuse for every building cell would also project wall/foundation pixels.
    assert entries(0x282)[:4] == entries(0x283)[:4] != grass[:4]
    assert entries(0x61)[:4] != grass[:4]
    print(f'PASS {root}: Oldale Center source dark lawn001; path/structure layers distinct')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('gba_root', type=Path, nargs='+')
    args = parser.parse_args()
    for root in args.gba_root:
        check(root)
