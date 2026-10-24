#!/usr/bin/env python3
"""Audit complete native Mauville railing vocabulary and visible grass donors.

Reads isolated native QA atlas/census dumps; no native artwork ships. Hidden
terrain under baked fence paint/shadows is explicitly not byte-exact evidence.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
from PIL import Image
FENCE={0x273,0x280,0x282,0x288,0x28a,0x290,0x291,0x292,0x2b1,0x2b2,0x2ba}
BAKED={0x290,0x291,0x292,0x2b1,0x2b2}
BROWN={(107,90,90,255),(165,99,90,255),(222,148,115,255),(255,197,148,255)}
SHADOW=(25,165,107,255)
def audit(folder):
    data=json.loads((folder/'mauville-native-census.json').read_text())
    slots={r['mid']:r['slot']for r in data['slots']}
    layers=[Image.open(folder/('mauville-native-'+layer+'-atlas.png')).convert('RGBA')for layer in ('base','over')]
    def tile(layer,mid):
        s=slots[mid];x,y=s%data['atlasCols']*16,s//data['atlasCols']*16
        return layers[layer].crop((x,y,x+16,y+16))
    grass=tile(0,1);proof={}
    for mid in sorted(FENCE):
        base,over=tile(0,mid),tile(1,mid);visible=0
        if mid not in BAKED:
            assert base.tobytes()==grass.tobytes(),hex(mid)
            assert over.getbbox(),hex(mid)
            visible=256
        else:
            assert not over.getbbox(),hex(mid)
            for y in range(16):
                for x in range(16):
                    pixel=base.getpixel((x,y))
                    if pixel not in BROWN|{SHADOW}:
                        assert pixel==grass.getpixel((x,y)),(hex(mid),x,y,pixel)
                        visible+=1
        proof[f'{mid:03x}']={'visibleGrassWitnessPixels':visible,
            'nativeSha256':hashlib.sha256(base.tobytes()+over.tobytes()).hexdigest(),
            'baseByteExactGrass':mid not in BAKED}
    # 281 is a building facade; its native yellow bricks and roof differ from
    # the four brown fence paints. It is not an omitted railing family.
    wall=tile(1,0x281)
    assert any(wall.getpixel((x,y))==(239,239,90,255)for y in range(16)for x in range(16))
    cells=[c for r in data['maps']for c in r['cells']]
    assert len(cells)==132 and all(c['collision']==7 and c['mid']in FENCE for c in cells)
    counts=collections.Counter(f'{c["mid"]:03x}'for c in cells)
    return {'edition':data['edition'],'pairMaps':len(data['maps']),'cells':len(cells),
        'byMid':dict(sorted(counts.items())),
        'previouslyMissingCornerCells':sum(c['mid']in{0x292,0x2b1}for c in cells),
        'sourcePixels':proof,'excludedBuildingMID':'281',
        'groundClaim':'Exact original base on six layered families; all visible terrain outside baked fence and its green shadow on five others. Hidden terrain is not asserted.'}
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('folder',type=Path);a=p.parse_args()
    print(json.dumps(audit(a.folder),indent=2))
