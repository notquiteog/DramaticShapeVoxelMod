"""Read-only original fence underlay proof; no pixels or caches are modified."""
import argparse
import json
from pathlib import Path
import struct


def check(root):
    tree = root / 'map_tree'
    headers = [json.loads(p.read_text()) for p in (tree / 'maps').glob('*/header.json')]
    route = next(h for h in headers if h.get('id') == 'Route104')
    data = (tree / 'tilesets' / route['primaryTileset'] / 'metatiles.bin').read_bytes()
    entries = lambda mid: struct.unpack_from('<8H', data, mid * 16)
    assert entries(0x149)[:4] == entries(1)[:4], 'original fence ground no longer matches native lawn'
    assert any(entries(0x149)[4:]) and not any(entries(1)[4:]), 'paint exclusion no longer exercised'
    print(f'PASS {root}: fence149 original base exactly equals clean native lawn1')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('gba_root', type=Path, nargs='+')
    for root in parser.parse_args().gba_root:
        check(root)
