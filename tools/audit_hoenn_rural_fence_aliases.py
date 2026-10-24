#!/usr/bin/env python3
"""Find exact secondary duplicates of reviewed primary rural fence art.

Reads an existing local imported cache and actual edition-native outdoor map
census. Reports only exact composited RGBA matches and original permissions;
these are review candidates, not automatic production classifier mappings.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import zlib
from PIL import Image

FENCE = (0x138, 0x139, 0x13A, 0x140, 0x141, 0x142, 0x148, 0x149, 0x14A)


def key(name):
    return re.sub('[^A-Z0-9]', '', name.upper())


def native_pair(folder):
    idx = zlib.decompress((folder / 'mids.idx').read_bytes())
    assert idx[:6] == b'SVMI\x01\x02'
    count, cols, rows = struct.unpack_from('<HHH', idx, 6)
    slots = {mid: i for i, mid in enumerate(struct.unpack_from('<' + 'H' * count, idx, 12))}
    layers = [Image.frombytes('RGBA', (cols * 16, rows * 16),
                             zlib.decompress(next(folder.glob('atlas_' + layer + '_*.rgba')).read_bytes()))
              for layer in ('u', 'o')]
    layers[0].alpha_composite(layers[1])

    def pixels(mid):
        slot = slots[mid]
        x, y = slot % cols * 16, slot // cols * 16
        return layers[0].crop((x, y, x + 16, y + 16)).tobytes()

    refs = {pixels(mid): mid for mid in FENCE}
    return {mid: (refs[pixels(mid)], hashlib.sha256(pixels(mid)).hexdigest())
            for mid in slots if mid >= 512 and pixels(mid) in refs}


def audit(cache, census):
    headers = {}
    for path in (cache / 'map_tree/maps').glob('*/header.json'):
        header = json.loads(path.read_text())
        headers[key(header['id'])] = path, header
    pairs, matches = {}, []
    for row in census['maps']:
        pair = row['pair']
        assert pair.startswith('general__')
        if pair not in pairs:
            pairs[pair] = native_pair(cache / 'native' / pair)
        aliases = pairs[pair]
        if not aliases:
            continue
        path, header = headers[key(row['map'].split('_', 1)[1])]
        raw = (path.parent / 'grid.bin').read_bytes()
        assert len(raw) == header['width'] * header['height'] * 2
        for i, (value,) in enumerate(struct.iter_unpack('<H', raw)):
            mid = value & 1023
            if mid in aliases:
                reference, digest = aliases[mid]
                matches.append({'map': row['map'], 'pair': pair,
                                'x': i % header['width'], 'y': i // header['width'],
                                'mid': mid, 'reference': reference,
                                'rawPermission': value >> 10 & 3,
                                'compositedPixelSha256': digest})
    return {'edition': census['edition'], 'generalOutdoorMaps': len(census['maps']),
            'matches': matches,
            'result': 'Exact source pixel matches; region/collision and native scene review still required'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('gba_root', type=Path)
    parser.add_argument('native_census', type=Path)
    args = parser.parse_args()
    print(json.dumps(audit(args.gba_root, json.loads(args.native_census.read_text())), indent=2))
