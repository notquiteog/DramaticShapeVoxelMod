#!/usr/bin/env python3
import copy,hashlib,json,sys,tempfile,zipfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import import_route104_shop as I
if len(sys.argv)!=2:raise SystemExit('Usage: python3 tests/route104_shop_import_test.py /path/to/364272.zip')
archive=Path(sys.argv[1]);root=Path(__file__).resolve().parents[1]
with zipfile.ZipFile(archive)as z,tempfile.TemporaryDirectory()as tmp:
 source=I.extract(z.read(I.SOURCE));saved=copy.deepcopy(source);added,completion=I.complete(source)
 assert source==saved and [len(p['vertices'])//3 for p in source]==[450,579,20,424,36]
 assert completion['excludedPlantFlowerTriangles']==208 and completion['authoredTriangles']==28
 # Only the original striped awning remains on the flower/leaf atlas.
 assert all(v[4]<.5 for v in source[2]['vertices'])
 bounds=I.bounds([v for p in source for v in p['vertices']])
 for p in added:
  for v in p['vertices']:assert all(bounds[a]-.00001<=v[a]<=bounds[a+3]+.00001 for a in range(3))
 out=Path(tmp);(out/'lib').mkdir();data,report=I.convert(archive,out)
 assert (out/'lib/ImportedHoennShopData.lua').read_bytes()==(root/'lib/ImportedHoennShopData.lua').read_bytes()
 assert report==json.loads((root/'assets/scenery/oras-route104-shop/provenance.json').read_text())
 for name,meta in report['textures'].items():
  png=(out/'assets/scenery/oras-route104-shop'/name).read_bytes();assert png==z.read(name)
  assert hashlib.sha256(png).hexdigest()==meta['sha256']
 model=data[I.MODEL];assert len(model['parts'])==7 and min(v[1]for p in model['parts']for v in p['vertices'])==0
 assert sum(p['triangles']for p in model['parts'])==1537
 assert report['nativeAdaptation']['shortenedBySourceUnits']==8
print('PASS deterministic shop selection/closures,1509 unchanged architectural triangles,208 excluded livingplant triangles, original PNG bytes and explicit bay adaptation metadata')
