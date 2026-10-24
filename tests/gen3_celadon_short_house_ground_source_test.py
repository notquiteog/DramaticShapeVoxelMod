"""Read-only native Celadon lawn/header evidence; takes imported generated/gba roots."""
import argparse,json
from pathlib import Path
from gen3_civic_native_ground_source_test import atlas

def check(root):
 tree=root/'map_tree';census=json.loads((tree/'census.json').read_text())
 m=next(m for g in census['groups']for m in g['maps']if m['id']=='CeladonCity')
 h=json.loads((tree/'maps'/m['slot']/'header.json').read_text())
 native=root/('native/general__rom_'+h['secondaryTileset'].removeprefix('ts_'))
 under,over=atlas(native/'mids.idx'),atlas(native/'mids_over.idx');lawn=set(under[1])
 assert lawn=={8,13,14}and not any(over[1]),'clean native lawn donor changed'
 for mid in (729,730,774):
  composite=bytes(b or a for a,b in zip(under[mid],over[mid]))
  assert set(composite[:128])<=lawn and any(over[mid]),'native roof margin is not lawn'
 for mid in (8,9,16):assert set(under[mid])<={8,12,13,14}and not any(over[mid]),'existing local grass donor changed'
 assert not set(under[365])<={8,12,13,14}and not set(under[374])<={8,12,13,14},'street mistaken for lawn'
 print('PASS',root,'source roof margins/local8,9,16 donors are lawn; road365/374 and roof artwork excluded')
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('roots',type=Path,nargs='+')
 for root in p.parse_args().roots:check(root)
