"""Prove actual emitted native cliff/reveal meshes have one surface owner."""
import math,subprocess,tempfile
from pathlib import Path
from celadon_short_house_importer_test import overlap
with tempfile.TemporaryDirectory()as tmp:
 p=Path(tmp)/'triangles.txt'
 subprocess.run(['luajit','tests/gen3_cave_entrances_test.lua',str(p)],check=True)
 groups={}
 for row in p.read_text().splitlines():
  values=list(map(float,row.split()));key=int(values[0]);v=values[1:]
  tri=[v[i:i+3]for i in range(0,9,3)];a,b,c=tri
  u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)]
  n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
  length=math.sqrt(sum(x*x for x in n));assert length>1e-9
  n=[x/length for x in n];groups.setdefault(key,[]).append((tri,n,sum(n[k]*a[k]for k in range(3))))
 for key,triangles in groups.items():
  if key<=3:assert len(triangles)==58
  for i,(a,n,d)in enumerate(triangles):
   for b,_,_ in triangles[i+1:]:
    if max(abs(sum(n[k]*v[k]for k in range(3))-d)for v in b)>1e-7:continue
    xy=[k for k in range(3)if k!=max(range(3),key=lambda k:abs(n[k]))]
    assert overlap([[v[k]for k in xy]for v in a],[[v[k]for k in xy]for v in b])<1e-8,'coplanar rock/reveal/floor overlap'
 print('PASS native12/16/32px cave mass:regular58-triangle profiles +irregular local hood, zero positive-area coplanar floor/cap/reveal/back intersections')
