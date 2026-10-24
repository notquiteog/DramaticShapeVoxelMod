"""Read-only actual FR/LG native art proof for seven exact service underlays."""
import argparse,json
from pathlib import Path
from gen3_civic_native_ground_source_test import atlas

def check(root):
 def pair(name):
  tree=root/'map_tree';census=json.loads((tree/'census.json').read_text())
  m=next(m for g in census['groups']for m in g['maps']if m['id']==name)
  h=json.loads((tree/'maps'/m['slot']/'header.json').read_text())
  r=root/'native'/('general__rom_'+h['secondaryTileset'].removeprefix('ts_'))
  u,o=atlas(r/'mids.idx'),atlas(r/'mids_over.idx')
  return u,o,lambda m:bytes(b or a for a,b in zip(u[m],o[m]))
 u,o,composite=pair('CeruleanCity')
 lawn=set(u[1]);assert lawn=={8,13,14} and not any(o[1])
 # Both complete native Gym lower corners expose lawn across their bottom;
 # original roof header under layer is lawn13. Nearby road212/228 is distinct.
 for m,x in [(344,0),(350,15)]:
  assert composite(m)[-16:]==u[1][-16:]
  assert all(composite(m)[y*16+x]in lawn for y in range(8,16))
 for m in [313,314,315]:assert set(u[m])=={13} and any(o[m])
 for m in [212,228]:assert not set(u[m])<=lawn
 u,o,composite=pair('SaffronCity')
 floor=u[0x2e5];paving=set(floor)
 assert paving=={166,167,168,169,170,171} and not any(o[0x2e5])
 assert not paving&set(u[1]),'native paving confused with lawn'
 # Center/Mart exact lower corners retain a clean five-pixel paving margin
 # at their own original foundation. It matches the selected original donor
 # at the same coordinates; no facade pixels are accepted as a floor donor.
 for left,right in [(0x2df,0x307),(758,759)]:
  a,b=composite(left),composite(right)
  for y in range(11,16):assert a[y*16]==floor[y*16] and b[y*16+15]==floor[y*16+15]
  assert a[-16:-11]==floor[-16:-11] and b[-5:]==floor[-5:]
 for m in [829,835]:assert composite(m)[-16:]==floor[-16:] and set(composite(m)[-128:])<=paving
 # Service roof-header upper art is real; it must not be flattened as ground.
 for m in [760,761,762,763,764,765,766,774,767]:assert any(o[m])
 assert any(v not in paving for v in composite(735)), 'must retain foundation-art case'
 print('PASS',root,'native Cerulean lawn and Saffron service/Dojo paving margins; original clean donors exclude facade/roof art and neighboring wrong surfaces')
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('roots',type=Path,nargs='+')
 for root in p.parse_args().roots:check(root)
