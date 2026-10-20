#!/usr/bin/env python3
"""Source archive is explicit and remains external to the mod repository."""
import collections,copy,importlib.util,math,sys,tempfile,zipfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import import_route104_tree as I
if len(sys.argv)!=2:raise SystemExit('Usage: python3 tests/route104_tree_import_test.py /path/to/364272.zip')
with zipfile.ZipFile(sys.argv[1])as z:
 original,selection=I.extract(z.read(I.SOURCE));additions,completion=I.complete_tree(original)
 assert [len(p['vertices'])//3 for p in original]==[60,48]
 assert [len(p['vertices'])//3 for p in additions]==[24,144,84]
 assert selection['trunkComponents']==5 and selection['canopyComponents']==30 and completion['barkHullEdgesClosed']
 # No coincident authored half-turn faces may fight the retained source crown.
 faces=[]
 for p in original+additions:
  for n in range(0,len(p['vertices']),3):
   face=tuple(sorted(tuple(round(x,3)for x in v[:3])for v in p['vertices'][n:n+3]));faces.append(face)
 assert len(faces)==len(set(faces)),'authored completion duplicates coplanar source triangles'
 with tempfile.TemporaryDirectory()as tmp:
  root=Path(tmp);(root/'lib').mkdir();data,report=I.convert(Path(sys.argv[1]),root);model=data[I.MODEL]
  assert len(model['parts'])==5 and sum(p['triangles']for p in model['parts'])==360
  assert model['anchors']['canopyBottom'][1]>0
  for name in I.MATERIALS.values():assert(root/'assets/scenery/oras-trees'/name).read_bytes()==z.read(name)
  assert report['sourceBounds'][3]-report['sourceBounds'][0]>119 and report['sourceBounds'][5]-report['sourceBounds'][2]>119
  for part,source in zip(model['parts'][:2],original):
   assert len(part['indices'])==len(source['vertices'])
   for n,v in enumerate(source['vertices']):
    index=part['indices'][n]-1;out=part['vertices'][index]
    for a in range(3):assert math.isclose(out[a],(v[a]-report['sourceOrigin'][a])/report['sourceUnitSpan'],abs_tol=1e-10)
    assert out[3:]==v[3:6] and part['colors'][index]==v[6:],'original108tri source UV/shade/RGBA changed'
  first=(root/'lib/ImportedTreeData.lua').read_bytes();I.convert(Path(sys.argv[1]),root)
  assert first==(root/'lib/ImportedTreeData.lua').read_bytes()
print('PASS original108tri+UV/RGBA/PNG preservation, component pairing, closed bark, distinct authored crown faces and deterministic360tri catalog')
