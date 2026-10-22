#!/usr/bin/env python3
import copy,hashlib,json,sys,tempfile,zipfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import import_route104_house as I
if len(sys.argv)!=2:raise SystemExit('Usage: python3 tests/route104_house_import_test.py /path/to/364272.zip')
archive=Path(sys.argv[1]);root=Path(__file__).resolve().parents[1]
with zipfile.ZipFile(archive)as z,tempfile.TemporaryDirectory()as tmp:
 source=I.extract(z.read(I.SOURCE));saved=copy.deepcopy(source);added,completion=I.complete(source)
 assert source==saved and [len(p['vertices'])//3 for p in source]==[874,454]
 assert completion['supportBoxesCompleted']==29 and completion['authoredTriangles']==234
 bounds=I.bounds([v for p in source for v in p['vertices']])
 for p in added:
  for v in p['vertices']:
   assert all(bounds[a]-.00001<=v[a]<=bounds[a+3]+.00001 for a in range(3))
 out=Path(tmp);(out/'lib').mkdir();data,report=I.convert(archive,out)
 assert (out/'lib/ImportedHoennData.lua').read_bytes()==(root/'lib/ImportedHoennData.lua').read_bytes()
 assert report==json.loads((root/'assets/scenery/oras-route104-house/provenance.json').read_text())
 for name,meta in report['textures'].items():
  png=(out/'assets/scenery/oras-route104-house'/name).read_bytes();assert png==z.read(name)
  assert hashlib.sha256(png).hexdigest()==meta['sha256']
 model=data[I.MODEL];assert len(model['parts'])==5 and model['anchors']['door'][0]<0
 assert min(v[1]for p in model['parts']for v in p['vertices'])==0
 assert sum(p['triangles']for p in model['parts'])==1562
print('PASS deterministic selected-source conversion,1328 unchanged source triangles/UV/RGB, bounded closures,29 support caps and original PNG bytes')
