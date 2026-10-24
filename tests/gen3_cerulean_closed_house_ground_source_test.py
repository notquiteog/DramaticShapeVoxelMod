"""Read-only native Cerulean lawn proof; takes imported generated/gba roots."""
import argparse,json,struct
from gen3_civic_native_ground_source_test import atlas
from pathlib import Path
def check(root):
 tree=root/'map_tree';census=json.loads((tree/'census.json').read_text())
 m=next(m for g in census['groups']for m in g['maps']if m['id']=='CeruleanCity')
 h=json.loads((tree/'maps'/m['slot']/'header.json').read_text())
 native=root/('native/general__rom_'+h['secondaryTileset'].removeprefix('ts_'))
 under,over=atlas(native/'mids.idx'),atlas(native/'mids_over.idx')
 lawn=set(under[1]);assert lawn=={8,13,14} and not any(over[1])
 def composite(mid):return bytes(b or a for a,b in zip(under[mid],over[mid]))
 # All top eight rows exposed by the original roof silhouette are lawn,
 # including the middle headers whose bottom layer contains roof colour.
 # Never flatten/reuse those whole roof-bearing native MIDs as ground.
 for mid in (672,673,665,674):
  assert set(composite(mid)[:128])<=lawn and any(over[mid])
 assert not set(under[673])<=lawn,'proof must retain roof-bearing header case'
 # Native lower-left foundation has an eight-pixel lawn margin, not sand.
 assert all(composite(696)[y*16]in lawn for y in range(8))
 assert not(set(under[212])<=lawn) and not(set(under[228])<=lawn),'roads must differ'
 print('PASS',root,'native header/foundation grass pixels; clean1 donor excludes road212/228 and roof artwork')
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('roots',type=Path,nargs='+')
 for root in p.parse_args().roots:check(root)
