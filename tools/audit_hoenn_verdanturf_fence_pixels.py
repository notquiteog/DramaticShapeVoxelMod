#!/usr/bin/env python3
"""Prove the native gray-post vocabulary, actual pair and exact visible lawn."""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image
FENCE={(132,132,140,255),(66,74,107,255),(189,206,230,255),(255,255,255,255),(156,181,222,255)}
def audit(folder):
    d=json.loads((folder/'verdanturf-native-census.json').read_text())
    slots={r['mid']:r['slot']for r in d['slots']}
    layers=[Image.open(folder/('verdanturf-native-'+layer+'-atlas.png')).convert('RGBA')for layer in ('base','over')]
    def tile(layer,mid):
        slot=slots[mid];x,y=slot%d['atlasCols']*16,slot//d['atlasCols']*16
        return layers[layer].crop((x,y,x+16,y+16))
    base,over,donor=tile(0,0x34d),tile(1,0x34d),tile(0,0x34e)
    visible=0
    for y in range(16):
        for x in range(16):
            pixel=base.getpixel((x,y))
            if pixel not in FENCE:
                assert pixel==donor.getpixel((x,y)),(x,y,pixel)
                visible+=1
            pixel=over.getpixel((x,y))
            assert pixel[3]==0 or pixel in FENCE,(x,y,pixel)
    assert visible==110 and donor.tobytes()!=tile(0,1).tobytes()
    rows=[(r,c)for r in d['maps']for c in r['cells']]
    assert len(rows)==4
    assert all(r['pair']=='general__mauville'and r['map'].endswith('VERDANTURF_TOWN')and c['collision']==7 and c['mid']==0x34d and c['y']==12 and 4<=c['x']<=7 for r,c in rows)
    return {'edition':d['edition'],'nativePair':'general__mauville','cells':4,'mid':'34d',
        'groundDonor':'34e','visibleGrassWitnessPixels':visible,
        'nativeSha256':hashlib.sha256(base.tobytes()+over.tobytes()).hexdigest(),
        'claim':'All visible lawn equals exact dense-lawn donor; terrain hidden by fence paint is not asserted. Green390/391 art is house roof, not a railing.'}
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('folder',type=Path);a=p.parse_args()
    print(json.dumps(audit(a.folder),indent=2))
