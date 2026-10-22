#!/usr/bin/env python3
"""Read-only fence census of an existing user-imported RSE GBA cache.

Prints metadata only. Does not extract a ROM or modify maps, permission bits,
source art, saves, settings or the mod. This is an audit, not a coverage claim.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import struct

MAPS = {'LittlerootTown', 'OldaleTown', 'PetalburgCity', 'RustboroCity',
        'DewfordTown', 'PetalburgWoods', 'RusturfTunnel',
        *(f'Route{n}' for n in (101, 102, 103, 104, 105, 106, 116))}


def census(root):
    tree = root / 'map_tree'
    out = {'status': 'source audit; modern fence adapters not implemented',
           'maps': [], 'white149Cells': 0}
    for path in sorted((tree / 'maps').glob('*/header.json')):
        header = json.loads(path.read_text())
        if header.get('id') not in MAPS:
            continue
        width, height = header['width'], header['height']
        raw = (path.parent / 'grid.bin').read_bytes()
        if len(raw) != width * height * 2:
            raise ValueError(f'{header["id"]}: unexpected native grid size')
        values = struct.unpack('<' + 'H' * (width * height), raw)
        cells = [{'x': n % width, 'y': n // width, 'mid': value & 1023,
                  'rawPermission': value >> 10 & 3, 'elevation': value >> 12}
                 for n, value in enumerate(values) if value & 1023 == 0x149]
        primary = tree / 'tilesets' / header['primaryTileset']
        metatiles = (primary / 'metatiles.bin').read_bytes()
        native149 = struct.unpack_from('<8H', metatiles, 0x149 * 16)
        entry = {'map': header['id'], 'width': width, 'height': height,
                 'primary': header['primaryTileset'], 'secondary': header['secondaryTileset'],
                 'white149Cells': cells, 'white149TileEntries': native149,
                 'gridSha256': hashlib.sha256(raw).hexdigest()}
        if header['id'] == 'RustboroCity':
            # The native city has a distinct ornate railing. Its full corner/
            # vertical vocabulary still needs reviewed model-placement guards.
            entry['confirmedOrnateHorizontal2fcCount'] = sum(v & 1023 == 0x2FC for v in values)
            entry['usedNativeMids'] = dict(sorted(collections.Counter(
                f'{v & 1023:03x}' for v in values).items()))
        out['maps'].append(entry)
        out['white149Cells'] += len(cells)
    missing = MAPS - {entry['map'] for entry in out['maps']}
    if missing:
        raise ValueError('missing corridor maps: ' + ', '.join(sorted(missing)))
    return out


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('gba_root', type=Path)
    print(json.dumps(census(parser.parse_args().gba_root), indent=2))
