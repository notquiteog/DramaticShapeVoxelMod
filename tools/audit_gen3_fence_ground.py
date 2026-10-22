#!/usr/bin/env python3
"""Verify modern fence ground against a user-imported native RSE cache.

Read-only, stdlib-only. Exports hashes/metadata, never game pixels or archives.
Native quadrant donors are checked against all original underlayer pixels,
not nearby map cells. Upper layer art must be empty on each clean donor.
"""
import argparse, hashlib, json, re, struct
from pathlib import Path


def proof(root, families):
    header=next(json.loads(p.read_text())for p in (root/'map_tree/maps').glob('*/header.json')if json.loads(p.read_text()).get('id')=='RustboroCity')
    tree=root/'map_tree/tilesets';primary=tree/header['primaryTileset'];secondary=tree/header['secondaryTileset']
    tiles=(primary/'tiles.4bpp').read_bytes()+(secondary/'tiles.4bpp').read_bytes()
    palettes=struct.unpack('<256H',(primary/'palettes.bin').read_bytes())[:96]+struct.unpack('<256H',(secondary/'palettes.bin').read_bytes())[96:]
    mids=(primary/'metatiles.bin').read_bytes()+(secondary/'metatiles.bin').read_bytes()
    def entries(mid):return struct.unpack_from('<8H',mids,mid*16)
    def pixels(mid):
        out=[]
        for entry in entries(mid)[:4]:
            rgba=bytearray()
            for y in range(8):
                for x in range(8):
                    sx,sy=(7-x if entry&0x400 else x),(7-y if entry&0x800 else y)
                    packed=tiles[(entry&1023)*32+sy*4+sx//2];index=packed>>(4*(sx%2))&15
                    value=palettes[(entry>>12)*16+index]
                    rgba.extend(tuple(round((value>>k&31)*255/31)for k in(0,5,10))+(255 if index else 0,))
            out.append(bytes(rgba))
        return out
    assert entries(0x149)[:4]==entries(1)[:4]and entries(1)[4:]==(0,0,0,0),'rural native underlayer mismatch'
    text=families.read_text().split('M.ground={',1)[1].split('\n}',1)[0];rows={}
    for mid,body in re.findall(r'\[(0x[0-9a-f]+)\]=\{(.*)\}',text):
        rows[int(mid,16)]=[(int(m,0),int(q))for m,q in re.findall(r'\{(0x[0-9a-f]+|[0-9]+),([0-3])\}',body)]
    assert len(rows)==17,'expected17 ornate source families'
    ground=[]
    for mid,row in sorted(rows.items()):
        assert len(row)==4;original=pixels(mid);reconstructed=[]
        for n,(donor,quadrant)in enumerate(row):
            assert entries(donor)[4:]==(0,0,0,0),'donor contains upper art'
            rendered=pixels(donor)[quadrant]
            assert original[n]==rendered,f'{mid:03x} quadrant{n} differs from native source'
            reconstructed.append(rendered)
        ground.append(dict(mid=mid,donors=row,sourceUnderRgbaSha256=hashlib.sha256(b''.join(original)).hexdigest(),reconstructedRgbaSha256=hashlib.sha256(b''.join(reconstructed)).hexdigest()))
    grids=[];count=0
    for hp in (root/'map_tree/maps').glob('*/header.json'):
        h=json.loads(hp.read_text())
        if h.get('id')not in('RustboroCity','Route104','PetalburgWoods'):continue
        raw=(hp.parent/'grid.bin').read_bytes();values=struct.unpack('<'+'H'*(len(raw)//2),raw)
        cells=[v for v in values if v&1023==0x149 or h['id']=='RustboroCity'and v&1023 in rows]
        assert all(v>>10&3==1 for v in cells),'fence is not native hard-blocked'
        count+=len(cells);grids.append(dict(map=h['id'],fenceCells=len(cells),nativeGridSha256=hashlib.sha256(raw).hexdigest()))
    return dict(status='PASS exact native source-ground preservation',ruralUnderEntries=list(entries(0x149)[:4]),ruralCleanDonor=1,rustboro=ground,maps=grids,totalReviewedFenceCells=count)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('gba_root',type=Path);p.add_argument('--families',type=Path,default=Path('lib/Gen3FenceFamilies.lua'))
    x=p.parse_args();print(json.dumps(proof(x.gba_root,x.families),indent=2))
