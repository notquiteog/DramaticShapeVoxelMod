"""Thicken open original roof-fixture surfaces without filling their silhouettes.
Original front vertices/UVs/indices stay untouched. A real backing and thin rim
close each open component; source roof faces cover coincident support bottoms.
"""
import collections,math
from oras_rear_closure import _subtract,need

def _normal(triangle):
 a,b,c=triangle;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];return[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
def _length(v):return math.sqrt(sum(n*n for n in v))
def _plane(triangle):
 normal=_normal(triangle);length=_length(normal)
 if length<1e-12:return None
 normal=[n/length for n in normal];axis=max(range(3),key=lambda k:abs(normal[k]));normal=[n*(1 if normal[axis]>0 else -1)for n in normal];return normal,axis,sum(normal[k]*triangle[0][k]for k in range(3))

def close_fixture_shells(part,parts,floor,span,paint,thickness=.1):
 vertices=part['vertices'];triangles=[[vertices[i-1]for i in part['indices'][at:at+3]]for at in range(0,len(part['indices']),3)];parent=list(range(len(triangles)));owners={}
 def key(v):return tuple(round(v[k]*span,4)for k in range(3))
 def root(a):
  while parent[a]!=a:parent[a]=parent[parent[a]];a=parent[a]
  return a
 for at,tri in enumerate(triangles):
  for v in tri:
   old=owners.setdefault(key(v),at);parent[root(at)]=root(old)
 components=collections.defaultdict(list)
 for at,tri in enumerate(triangles):components[root(at)].append(tri)
 planes=collections.defaultdict(list)
 for p in parts:
  vs=p['vertices']
  for at in range(0,len(p['indices']),3):
   tri=[vs[k-1][:3]for k in p['indices'][at:at+3]];plane=_plane(tri)
   if plane:
    n,axis,d=plane;planes[tuple(round(q,5)for q in n)].append((d,[[v[k]for k in range(3)if k!=axis]for v in tri]))
 bounds=[min(v[k]for p in parts for v in p['vertices'])for k in range(3)]+[max(v[k]for p in parts for v in p['vertices'])for k in range(3)]
 out=dict(part,name='authored_roof_fixture_shells',vertices=[],indices=[]);reports=[]
 def emit(tri,uv):
  plane=_plane(tri)
  if not plane:return
  n,axis,d=plane;axes=[k for k in range(3)if k!=axis];polygons=[[[v[k]for k in axes]for v in tri]]
  for distance,cut in planes[tuple(round(q,5)for q in n)]:
   if abs(distance-d)<1e-6:polygons=[q for p in polygons for q in _subtract(p,cut)]
  for polygon in polygons:
   lifted=[]
   for p in polygon:
    v=[0.,0.,0.];v[axes[0]],v[axes[1]]=p;v[axis]=(d-sum(n[k]*v[k]for k in axes))/n[axis];lifted.append(v)
   for at in range(1,len(lifted)-1):
    triangle=[lifted[0],lifted[at],lifted[at+1]]
    if _length(_normal(triangle))<1e-12:continue
    first=len(out['vertices']);out['vertices'].extend([v+list(uv)+[1.]for v in triangle]);out['indices'].extend([first+1,first+2,first+3])
 for tris in components.values():
  allvertices=[v for tri in tris for v in tri]
  if min(v[1]for v in allvertices)<floor-1e-6 or max(v[1]for v in allvertices)<floor+1e-6:continue
  edges=collections.defaultdict(list);points={};normals=collections.defaultdict(lambda:[0.,0.,0.])
  for tri in tris:
   normal=_normal(tri)
   for v in tri:
    k=key(v);points.setdefault(k,v[:3]);normals[k]=[normals[k][j]+normal[j]for j in range(3)]
   for at,a in enumerate(tri):
    b=tri[(at+1)%3];ka,kb=key(a),key(b)
    if ka!=kb:edges[tuple(sorted([ka,kb]))].append((ka,kb))
  boundary=[v[0]for v in edges.values()if len(v)==1]
  if not boundary:continue
  need(all(len(v)<=2 for v in edges.values()),'nonmanifold roof fixture needs explicit review');uv=paint(max(tris,key=lambda tri:_length(_normal(tri))));back={}
  for k,v in points.items():
   normal=normals[k];length=_length(normal);need(length>1e-12,'unoriented roof fixture corner');back[k]=[max(bounds[j],min(bounds[j+3],v[j]-normal[j]/length*thickness/span))for j in range(3)]
  before=len(out['indices'])//3
  for tri in tris:emit([back[key(v)]for v in tri[::-1]],uv)
  for a,b in boundary:
   quad=[points[a],back[a],back[b],points[b]];emit(quad[:3],uv);emit([quad[0],quad[2],quad[3]],uv)
  reports.append(dict(sourceTriangles=len(tris),boundaryEdges=len(boundary),backingAndRimTriangles=len(out['indices'])//3-before,paintTexel=list(uv)))
 need(reports and out['indices'],'no original roof fixture shells found')
 return out,dict(sourceThickness=thickness,preservesOriginalBounds=True,components=reports,addedTriangles=len(out['indices'])//3)
