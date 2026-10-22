#!/usr/bin/env python3
import copy,hashlib,json,sys,tempfile,zipfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import import_lavaridge_houses as I
if len(sys.argv)!=2:raise SystemExit('Usage: python3 tests/lavaridge_houses_import_test.py /path/to/353301.zip')
archive=Path(sys.argv[1]);root=Path(__file__).resolve().parents[1]
with zipfile.ZipFile(archive)as z,tempfile.TemporaryDirectory()as tmp:
 selected=I.extract(z.read(I.SOURCE));source=copy.deepcopy(selected)
 for model,parts in selected.items():
  r=I.RECIPES[model];added,completion=I.complete(parts,r);assert parts==source[model]
  assert completion['authoredTriangles']==36
  b=I.bounds([v for p in parts for v in p['vertices']])
  for p in added:
   for v in p['vertices']:assert all(b[a]-.00001<=v[a]<=b[a+3]+.00001 for a in range(3))
  # Original side glass is on opposite elevations; front glass stays shared.
  glass=parts[3]['vertices'];side=[v for v in glass if v[2]<150]
  x=side[0][0];assert all(abs(v[0]-x)<1e-5 for v in side)
  assert(x<(b[0]+b[3])/2)==(r['sideWindow']=='left')
 out=Path(tmp);(out/'lib').mkdir();data,report=I.convert(archive,out)
 assert (out/'lib/ImportedLavaridgeData.lua').read_bytes()==(root/'lib/ImportedLavaridgeData.lua').read_bytes()
 assert report==json.loads((root/'assets/scenery/oras-lavaridge-houses/provenance.json').read_text())
 for name,meta in report['textures'].items():
  png=(out/'assets/scenery/oras-lavaridge-houses'/name).read_bytes();assert png==z.read(name)
  assert hashlib.sha256(png).hexdigest()==meta['sha256']
 for model,d in data.items():
  assert len(d['parts'])==5 and min(v[1]for p in d['parts']for v in p['vertices'])==0
  assert sum(p['triangles']for p in d['parts'])==sum(I.RECIPES[model]['triangles'])+36
  assert report['models'][model]['nativeAdaptation']['totalShortening']==8
print('PASS deterministic original west/east selection, distinct side windows,2528 retained source triangles/UV/RGBA/PNG bytes and bounded rear completion')
