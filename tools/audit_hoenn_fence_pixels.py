#!/usr/bin/env python3
"""Verify Rustboro fence decisions against native driver atlas/census dumps.

Inputs are local QA captures, not ROMs. Emits metadata only; no source art or
cache is copied into the repository. Sprite pixels use half-open pixel edges.
"""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image

# Independent native-art witnesses for the regression, not a neighboring-MID
# classifier. Three dark/light/dark source pixels encode each depth stripe.
STRIPES = {0x2C6: 2, 0x2C7: 11, 0x2DC: 11, 0x2DE: 2, 0x2DF: 11,
           0x2EC: 11, 0x315: 2, 0x318: 10, 0x319: 3, 0x31D: 11}
GROUND = {
    0x2C6: [(0x2BB, q) for q in range(4)],
    0x2C7: [(0x2BB, q) for q in range(4)],
    0x2DC: [(0x2BD, 0), (0x2BB, 1), (0x2BD, 2), (0x2BD, 3)],
    **{mid: [(1, q) for q in range(4)]
       for mid in (0x2D7, 0x2DE, 0x2DF, 0x2E6, 0x2E7)},
}
RAIL_RGB = {(41, 49, 90), (66, 74, 107), (99, 99, 123)}


def audit(folder):
    raw = (folder / 'rustboro-fences.json').read_bytes()
    data = json.loads(raw)
    slots = {row['mid']: row['slot'] for row in data['slots']}
    atlas = Image.open(folder / 'rustboro-native-base-atlas.png').convert('RGBA')

    def tile(mid):
        slot = slots[mid]
        x, y = slot % data['atlasCols'] * 16, slot // data['atlasCols'] * 16
        return atlas.crop((x, y, x + 16, y + 16))

    for mid, left in STRIPES.items():
        source = tile(mid)
        for y in range(16):
            dark = [x for x in range(16)
                    if source.getpixel((x, y))[:3] in RAIL_RGB]
            assert dark == list(range(left, left + 3)), (hex(mid), y, dark)
    for mid, refs in GROUND.items():
        source = tile(mid)
        for quadrant, (ref_mid, ref_quad) in enumerate(refs):
            reference = tile(ref_mid)
            for y in range(8):
                for x in range(8):
                    actual = source.getpixel((quadrant % 2 * 8 + x,
                                              quadrant // 2 * 8 + y))
                    expected = reference.getpixel((ref_quad % 2 * 8 + x,
                                                   ref_quad // 2 * 8 + y))
                    # Occluded ground cannot be recovered from sprite pixels;
                    # require every visible terrain pixel to match exactly.
                    assert actual[:3] in RAIL_RGB or actual == expected, (
                        hex(mid), quadrant, x, y, actual, expected)
    omitted = [row for row in data['grid'] if row['mid'] in GROUND]
    assert len(omitted) == (15 if data['edition'] == 'emerald' else 16) and all(row['collision'] == 7 for row in omitted)
    assert len(data['grid']) == 2400 == len(data['scene'])
    owners = [row for row in data['scene'].values() if row['eligible']]
    assert len(owners) == 180 and all(row['importedFence'] for row in owners)
    return {'edition': data['edition'], 'map': data['map'],
            'uniqueNativeCells': len(data['grid']), 'reviewedBuiltCells': len(owners),
            'formerlyOmittedCells': omitted,
            'sourcePixelSha256': {f'{mid:03x}': hashlib.sha256(tile(mid).tobytes()).hexdigest()
                                  for mid in sorted(set(STRIPES) | set(GROUND))},
            'nativeGridSha256': hashlib.sha256(json.dumps(data['grid'], sort_keys=True).encode()).hexdigest(),
            'result': 'PASS exact native stripes and visible ground witnesses'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('census_folders', type=Path, nargs='+')
    args = parser.parse_args()
    print(json.dumps([audit(folder) for folder in args.census_folders], indent=2))
