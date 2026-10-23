#!/usr/bin/env python3
"""Read-only proof of native Gym notice ground and indexed source identities.
Takes an imported edition's generated/gba directory. Writes metadata/hashes only.
"""
import argparse,hashlib,json,struct,zlib
from pathlib import Path
FAMILIES=[('PetalburgCity','general__petalburg',17,10,0x130,0x131,1),('DewfordTown','general__dewford',11,16,0x208,0x210,0x121),('RustboroCity','general__rustboro',23,19,0x2cc,0x2d4,0x2bb)]
def proof(root):
 tree=root/'map_tree';out=[]
 for name,pair,x,y,top,bottom,ground in FAMILIES:
  hp=next(p for p in(tree/'maps').glob('*/header.json')if json.loads(p.read_text()).get('id')==name);h=json.loads(hp.read_text())
  p=tree/'tilesets'/h['primaryTileset'];s=tree/'tilesets'/h['secondaryTileset'];m=(p/'metatiles.bin').read_bytes()+(s/'metatiles.bin').read_bytes();grid=(hp.parent/'grid.bin').read_bytes()
  entries=lambda mid:struct.unpack_from('<8H',m,mid*16)
  assert entries(top)[:4]==entries(bottom)[:4]==entries(ground)[:4],'underlying native ground differs'
  assert entries(ground)[4:]==(0,0,0,0),'ground donor contains source upper art'
  for yy,mid,coll in [(y-1,top,0),(y,bottom,1)]:
   cell=struct.unpack_from('<H',grid,2*(yy*h['width']+x))[0]
   assert cell&1023==mid and cell>>10&3==coll,'native placement/permission differs'
  signatures={}
  for key,file in [('under','mids.idx'),('over','mids_over.idx')]:
   blob=zlib.decompress((root/'native'/pair/file).read_bytes());assert blob[:4]==b'SVMI';count=struct.unpack_from('<H',blob,6)[0];mids=struct.unpack_from('<'+'H'*count,blob,12)
   signatures[key]={}
   for mid in [top,bottom,ground]:
    start=12+2*count+256*mids.index(mid);pixels=blob[start:start+256];assert len(pixels)==256
    signatures[key][str(mid)]=dict(adler32=zlib.adler32(pixels),sha256=hashlib.sha256(pixels).hexdigest())
  out.append(dict(map=name,pair=pair,x=x,y=y,top=top,bottom=bottom,ground=ground,underEntries=list(entries(ground)[:4]),signatures=signatures,nativeGridSha256=hashlib.sha256(grid).hexdigest()))
 return dict(status='PASS exact source underlayer and native hard-blocked notice body',placements=out)
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('gba_root',type=Path);a=p.parse_args();print(json.dumps(proof(a.gba_root),indent=2))
