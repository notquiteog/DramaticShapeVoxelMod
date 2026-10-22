#!/usr/bin/env python3
import copy,hashlib,json,sys,tempfile,zipfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import import_dewford_house as I
if len(sys.argv)!=2:raise SystemExit('Usage: python3 tests/dewford_house_import_test.py /path/to/364274.zip')
archive=Path(sys.argv[1]);root=Path(__file__).resolve().parents[1]
with zipfile.ZipFile(archive)as z,tempfile.TemporaryDirectory()as tmp:
 source,selection=I.extract(z.read(I.SOURCE));saved=copy.deepcopy(source);added,completion=I.complete(source)
 assert source==saved and [len(p['vertices'])//3 for p in source]==[938,54,4]
 assert completion['authoredTriangles']==18 and all(p['matchingOriginalCopies']==2 and p['matchingCopyMaxPositionDelta']<1 for p in selection)
 bounds=I.bounds([v for p in source for v in p['vertices']])
 for p in added:
  for v in p['vertices']:assert all(bounds[a]-.00001<=v[a]<=bounds[a+3]+.00001 for a in range(3))
 out=Path(tmp);(out/'lib').mkdir();data,report=I.convert(archive,out)
 assert (out/'lib/ImportedDewfordData.lua').read_bytes()==(root/'lib/ImportedDewfordData.lua').read_bytes()
 assert report==json.loads((root/'assets/scenery/oras-dewford-house/provenance.json').read_text())
 for name,meta in report['textures'].items():
  png=(out/'assets/scenery/oras-dewford-house'/name).read_bytes();assert png==z.read(name)
  assert hashlib.sha256(png).hexdigest()==meta['sha256']
 model=data[I.MODEL];assert len(model['parts'])==4 and min(v[1]for p in model['parts']for v in p['vertices'])==0
 assert sum(p['triangles']for p in model['parts'])==1014
print('PASS deterministic narrow-house selection,996 unchanged triangles, original repeated-family UV/RGB, bounded completion and source PNG bytes')
