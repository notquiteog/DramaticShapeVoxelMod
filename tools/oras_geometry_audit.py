"""Projected-area audit of actual indexed source or runtime geometry."""
import math
from oras_rear_closure import _clip,_area

def coplanar_overlaps(parts,distance=1e-6,area=1e-8):
 groups={}
 for part_index,part in enumerate(parts):
  vertices=part['vertices'];name=part.get('name',str(part_index))
  for at in range(0,len(part['indices']),3):
   tri=[vertices[k-1][:3]for k in part['indices'][at:at+3]];a,b,c=tri;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];length=math.sqrt(sum(n*n for n in normal))
   if length<1e-12:continue
   normal=[n/length for n in normal];axis=max(range(3),key=lambda k:abs(normal[k]));normal=[n*(1 if normal[axis]>0 else -1)for n in normal];d=sum(normal[k]*a[k]for k in range(3));groups.setdefault(tuple(round(n,5)for n in normal),[]).append((d,name,at//3,[[p[k]for k in range(3)if k!=axis]for p in tri]))
 overlaps=[]
 for group in groups.values():
  group.sort(key=lambda p:p[0])
  for i,a in enumerate(group):
   for b in group[i+1:]:
    if b[0]-a[0]>distance:break
    poly=a[3];clip=b[3]
    if _area(clip)<0:clip=clip[::-1]
    for j in range(3):poly=_clip(poly,clip[j],clip[(j+1)%3],True)
    amount=abs(_area(poly))if len(poly)>2 else 0
    if amount>area:overlaps.append(dict(first=[a[1],a[2]],second=[b[1],b[2]],area=amount))
 return overlaps
