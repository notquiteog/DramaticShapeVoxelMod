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
    # All nineteen reviewed corridor header cells have NORMAL attributes, so
    # the public under atlas is bottom only, with roof pixels in over instead.
    lawn = grass[:4]
    path = (0x290A, 0x211A, 0x211A, 0x290A)
    paving = (0x82E1, 0x82E0, 0x82E2, 0x82E0)
    reviewed = {
        10: {0x48: lawn, 0x49: lawn, 0x282: path, 0x283: path,
             0x28: lawn, 0x29: (0x2002, 0x2003, 0x2002, 0x2002)},
        0: {mid: lawn for mid in (0x48, 0x49, 0x4A, 0x4B)},
        3: {mid: paving for mid in (0x256, 0x25E, 0x25F, 0x257,
                                  0x325, 0x267, 0x326)},
    }
    for mapnum, mids in reviewed.items():
        h = json.loads((tree / f'maps/0_{mapnum}/header.json').read_text())
        ts = [tree / 'tilesets' / h[key]
              for key in ('primaryTileset', 'secondaryTileset')]
        for mid, bottom in mids.items():
            source = ts[mid >= 512]
            offset = (mid % 512) * 16
            parts = struct.unpack_from('<8H', (source / 'metatiles.bin').read_bytes(), offset)
            attr = struct.unpack_from('<H', (source / 'attributes.bin').read_bytes(), (mid % 512) * 2)[0]
            assert attr == 0, f'{mid:03X} no longer NORMAL-layer clean source'
            assert parts[:4] == bottom, f'{mid:03X} clean underlay source changed'
            assert any(parts[4:]), 'test must inspect actual roof-overlay drawing'
    print(f'PASS {root}: Oldale dark001/body, mixed overhang and19 reviewed clean native underlay cells')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('gba_root', type=Path, nargs='+')
    args = parser.parse_args()
    for root in args.gba_root:
        check(root)
