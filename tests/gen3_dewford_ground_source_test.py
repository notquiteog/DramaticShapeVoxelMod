"""Read-only Dewford underlay proof against user-imported GBA cache roots."""
import argparse
import json
from pathlib import Path
import struct


def check(root):
    tree = root / 'map_tree'
    headers = [json.loads(p.read_text()) for p in (tree / 'maps').glob('*/header.json')]
    header = next(h for h in headers if h.get('id') == 'DewfordTown')
    sets = [tree / 'tilesets' / header[k]
            for k in ('primaryTileset', 'secondaryTileset')]

    def entries(mid):
        source = sets[mid >= 512]
        raw = (source / 'metatiles.bin').read_bytes()
        attr = struct.unpack_from('<H', (source / 'attributes.bin').read_bytes(), (mid % 512) * 2)[0]
        if mid in (0x203, 0x204, 0x205, 0x206, 0x20B, 0x20C, 0x20D, 0x21A, 0x21B, 0x21C):
            assert attr >> 12 == 0, f'{mid:03X} is no longer a normal split-layer tile'
        return struct.unpack_from('<8H', raw, (mid % 512) * 16)

    sand = entries(0x124)[:4]
    assert sand == (0x5108, 0x5118, 0x5118, 0x5108)
    for mid in (0x203, 0x204, 0x205, 0x206, 0x20B, 0x20C, 0x20D, 0x216, 0x217, 0x21A, 0x21B, 0x21C):
        native = entries(mid)
        assert native[:4] == sand, f'{mid:03X} native building sand changed'
        assert any(native[4:]), 'fixture must include original roof/body overlay'
    for mid in (0x212, 0x218):
        assert entries(mid)[:2] == (0x201E, 0x241E), 'native tree-base background changed'
        assert entries(mid)[:4] != sand, 'tree-base exclusion no longer exercised'
    assert entries(0x209)[0] == sand[0] and entries(0x209)[2] == sand[2]
    assert entries(0x20A)[1] == sand[1] and entries(0x20A)[3] == sand[3]
    print(f'PASS {root}: original124 sand under Dewford buildings,10 clean header source MIDs (including Gym),2 native body backgrounds,2 tree-base exclusions')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('gba_root', type=Path, nargs='+')
    for root in parser.parse_args().gba_root:
        check(root)
