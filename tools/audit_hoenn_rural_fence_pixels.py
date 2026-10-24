#!/usr/bin/env python3
"""Source-art/collision evidence for the next white rural fence batch.

Does not activate source placement or claim native model acceptance. Reads
only QA driver dumps; no ROM, artwork, caches or captures are copied to git.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
from PIL import Image

FENCE = {0x138, 0x139, 0x13a, 0x140, 0x141, 0x142, 0x148, 0x149, 0x14a}
PAINT = {(132, 132, 140), (66, 74, 107), (189, 206, 230),
         (255, 255, 255), (156, 181, 222)}


def audit(census_path, atlas_folder):
    census = json.loads(census_path.read_text())
    metadata = json.loads((atlas_folder / 'rustboro-fences.json').read_text())
    assert census['edition'] == metadata['edition']
    slots = {r['mid']: r['slot'] for r in metadata['slots']}
    layers = [Image.open(atlas_folder / ('rustboro-native-' + layer + '-atlas.png')).convert('RGBA')
              for layer in ('base', 'over')]

    def tile(layer, mid):
        s = slots[mid]
        x, y = s % metadata['atlasCols'] * 16, s // metadata['atlasCols'] * 16
        return layers[layer].crop((x, y, x + 16, y + 16))

    grass = tile(0, 1)
    source_hashes = {}
    for mid in sorted(FENCE):
        base, over = tile(0, mid), tile(1, mid)
        if mid < 0x148:
            assert base.tobytes() == grass.tobytes(), ('base not original grass', hex(mid))
            assert over.getbbox(), ('missing native over art', hex(mid))
        else:
            assert not over.getbbox(), ('unexpected native over art', hex(mid))
            for y in range(16):
                for x in range(16):
                    a = base.getpixel((x, y))
                    assert a[:3] in PAINT or a == grass.getpixel((x, y)), (hex(mid), x, y, a)
        source_hashes[f'{mid:03x}'] = hashlib.sha256(base.tobytes() + over.tobytes()).hexdigest()
    rows = [c for row in census['maps'] for c in row['cells']]
    assert all(c['collision'] == 7 and c['mid'] in FENCE for c in rows)
    expected = 418 if census['edition'] == 'emerald' else 408
    assert len(rows) == expected
    counts = collections.Counter(f'{c["mid"]:03x}' for c in rows)
    return {'edition': census['edition'], 'generalOutdoorMaps': len(census['maps']),
            'whiteFenceCells': len(rows), 'cellsByMid': dict(sorted(counts.items())),
            'currentlySourceRecognized149': counts['149'],
            'missingVariantCells': len(rows) - counts['149'],
            'sourcePixelSha256': source_hashes,
            'result': 'PASS source-art and blocked-cell census; new variant models inactive'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('census_json', type=Path)
    parser.add_argument('atlas_folder', type=Path)
    args = parser.parse_args()
    print(json.dumps(audit(args.census_json, args.atlas_folder), indent=2))
