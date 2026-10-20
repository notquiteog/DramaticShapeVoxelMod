#!/usr/bin/env python3
"""Validate selected public source bytes and fully opaque bank UV windows."""
import hashlib
import json
from pathlib import Path
from PIL import Image

root=Path(__file__).resolve().parents[1]/'assets/scenery/shore-banks'
manifest=json.loads((root/'provenance.json').read_text())
checked=0
for key,entry in manifest['materials'].items():
    path=root/entry['bundled_file']
    assert hashlib.sha256(path.read_bytes()).hexdigest()==entry['texture_sha256'], key+' source bytes changed'
    image=Image.open(path).convert('RGBA')
    assert list(image.size)==entry['size']
    windows=[entry['uv_pixel_centers']]
    if 'bare_cliff_uv_pixel_centers' in entry:
        windows.append(entry['bare_cliff_uv_pixel_centers'])
    for window in windows:
        x0,y0,x1,y1=window
        for y in range(int(y0),int(y1)+1):
            for x in range(int(x0),int(x1)+1):
                assert image.getpixel((x,y))[3]==255, key+' has an open/transparent bank corner'
                checked+=1
print(f'PASS3 unchanged source PNG hashes and {checked} opaque UV texel checks including stone-only cliff faces')
