"""Projected-area audit of actual indexed source or runtime geometry."""
import collections,math
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

def subtract_reviewed_overlaps(part,pairs,distance=1e-6):
 """Keep original triangles except explicitly reviewed covered portions.
 New boundary coordinates, UVs and optional physical alpha use the original
 target triangle's affine interpolation. The union silhouette stays fixed.
 """
 from oras_rear_closure import _subtract
 original=list(part['indices']);vertices=part['vertices'];cuts={};report=[]
 for target,covered in pairs:cuts.setdefault(target,[]).append(covered)
 replacement={}
 for target,covered in cuts.items():
  rows=[vertices[k-1]for k in original[target*3:target*3+3]];a,b,c=rows;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];normal=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];length=math.sqrt(sum(q*q for q in normal));assert length>1e-12
  normal=[q/length for q in normal];axis=max(range(3),key=lambda k:abs(normal[k]));axes=[k for k in range(3)if k!=axis];poly=[[v[k]for k in axes]for v in rows];remaining=[poly]
  for index in covered:
   clip=[vertices[k-1]for k in original[index*3:index*3+3]];assert all(abs(sum(normal[k]*(v[k]-a[k])for k in range(3)))<distance for v in clip),'reviewed coplanar contact moved'
   remaining=[q for p in remaining for q in _subtract(p,[[v[k]for k in axes]for v in clip])]
  aa,bb,cc=poly;den=(bb[1]-cc[1])*(aa[0]-cc[0])+(cc[0]-bb[0])*(aa[1]-cc[1]);ids=[]
  for polygon in remaining:
   for at in range(1,len(polygon)-1):
    for point in[polygon[0],polygon[at],polygon[at+1]]:
     x=((bb[1]-cc[1])*(point[0]-cc[0])+(cc[0]-bb[0])*(point[1]-cc[1]))/den;y=((cc[1]-aa[1])*(point[0]-cc[0])+(aa[0]-cc[0])*(point[1]-cc[1]))/den;weights=[x,y,1-x-y];vertices.append([sum(w*v[k]for w,v in zip(weights,rows))for k in range(6)]);ids.append(len(vertices))
     if part.get('colors'):part['colors'].append([sum(w*part['colors'][index-1][k]for w,index in zip(weights,original[target*3:target*3+3]))for k in range(4)])
  replacement[target]=ids;report.append(dict(originalTriangle=target,coveredBy=covered,remainingTriangles=len(ids)//3))
 part['indices']=[k for at in range(len(original)//3)for k in replacement.get(at,original[at*3:at*3+3])]
 return report

def components(sub):
 parent=list(range(len(sub.triangles)));owners={}
 def root(a):
  while parent[a]!=a:parent[a]=parent[parent[a]];a=parent[a]
  return a
 for at,tri in enumerate(sub.triangles):
  for i in tri:
   key=tuple(round(q,3)for q in sub.positions[i]);old=owners.setdefault(key,at);parent[root(at)]=root(old)
 groups=collections.defaultdict(list)
 for at,tri in enumerate(sub.triangles):groups[root(at)].append(tri)
 return list(groups.values())

def hull(points):
 points=sorted(set(tuple(p)for p in points))
 if len(points)<3:return []
 def cross(a,b,c):return(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
 def half(seq):
  result=[]
  for p in seq:
   while len(result)>1 and cross(result[-2],result[-1],p)<=1e-12:result.pop()
   result.append(p)
  return result
 return half(points)[:-1]+half(points[::-1])[:-1]
