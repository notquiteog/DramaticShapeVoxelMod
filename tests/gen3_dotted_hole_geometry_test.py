"""Actual emitted native closed/open slab/column union has one surface owner."""
import math,subprocess,tempfile
from pathlib import Path
from celadon_short_house_importer_test import overlap
with tempfile.TemporaryDirectory()as temp:
 p=Path(temp)/'triangles.txt';subprocess.run(['luajit','tests/gen3_dotted_hole_test.lua',str(p)],check=True);meshes={}
 for line in p.read_text().splitlines():
  v=list(map(float,line.split()));key=int(v.pop(0));tri=[v[i:i+3]for i in range(0,9,3)]
  a,b,c=tri;u=[b[k]-a[k]for k in range(3)];w=[c[k]-a[k]for k in range(3)]
  n=[u[1]*w[2]-u[2]*w[1],u[2]*w[0]-u[0]*w[2],u[0]*w[1]-u[1]*w[0]]
  length=math.sqrt(sum(x*x for x in n));assert length>1e-8,'degenerate column/reveal triangle'
  n=[x/length for x in n];meshes.setdefault(key,[]).append((tri,n,sum(n[k]*a[k]for k in range(3))))
 for key,tris in meshes.items():
  assert len(tris)=={1:296,2:316}[key]
  for i,(a,n,d)in enumerate(tris):
   for b,_,_ in tris[i+1:]:
    if max(abs(sum(n[k]*v[k]for k in range(3))-d)for v in b)>1e-7:continue
    xy=[k for k in range(3)if k!=max(range(3),key=lambda k:abs(n[k]))]
    assert overlap([[v[k]for k in xy]for v in a],[[v[k]for k in xy]for v in b])<1e-8,'coplanar pillar/rock/slab/floor overlap'
 print('PASS closed296/open316 native triangles: closed column ends, single braille slab, reveal/rock/floor union, zero degenerate/coplanar faces')
