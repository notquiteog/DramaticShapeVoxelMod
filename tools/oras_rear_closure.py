"""Close unmodeled ORAS rear surfaces using original side profiles and source paint.
Original vertices/UVs/indices are immutable. New backings sit inside the actual
side silhouette; roof/trim material remains in front. Horizontal joins subtract
existing coplanar source faces, so closures cannot duplicate source roof planes.
"""
import math
from oras_scenery_source import need

def _cross(a,b,c):return(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
def _area(poly):return sum(a[0]*poly[(i+1)%len(poly)][1]-a[1]*poly[(i+1)%len(poly)][0]for i,a in enumerate(poly))/2

def _clip(poly,a,b,inside):
 out=[]
 if not poly:return out
 prev=poly[-1];old=_cross(a,b,prev)*(1 if inside else -1)
 for p in poly:
  d=_cross(a,b,p)*(1 if inside else -1)
  if(old>=0)!=(d>=0):
   t=old/(old-d);out.append([prev[k]+t*(p[k]-prev[k])for k in[0,1]])
  if d>=0:out.append(p)
  prev,old=p,d
 return out

def _subtract(poly,triangle):
 if _area(triangle)<0:triangle=triangle[::-1]
 out=[];remaining=poly
 for i in range(3):
  a,b=triangle[i],triangle[(i+1)%3];outside=_clip(remaining,a,b,False)
  if len(outside)>2 and abs(_area(outside))>1e-14:out.append(outside)
  remaining=_clip(remaining,a,b,True)
  if len(remaining)<3:break
 return out

def close_rear(parts,material,uv,span,profile_materials=None):
 side=next(p for p in parts if p['name']==material);need(side['opacity']==1,'unreviewed rear-wall material opacity')
 profiles=[p for p in parts if p['name']in(profile_materials or[material])];source=[v for p in profiles for v in p['vertices']];tris=[[p['vertices'][i-1]for i in p['indices'][j:j+3]]for p in profiles for j in range(0,len(p['indices']),3)]
 side_tris=[]
 for tri in tris:
  a,b,c=tri;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];length=math.sqrt(sum(x*x for x in n))
  if length>1e-12 and abs(n[0])/length>.1 and max(p[1]for p in tri)-min(p[1]for p in tri)>1e-8:side_tris.append(tri)
 def section(y):
  points=[]
  for tri in side_tris:
   if not min(p[1]for p in tri)<y<max(p[1]for p in tri):continue
   for j,a in enumerate(tri):
    b=tri[(j+1)%3]
    if(a[1]<y)!=(b[1]<y):
     t=(y-a[1])/(b[1]-a[1]);points.append([a[k]+t*(b[k]-a[k])for k in range(3)])
  if not points:return None
  center=(min(p[0]for p in points)+max(p[0]for p in points))/2
  left=min((p for p in points if p[0]<center),key=lambda p:p[2]);right=min((p for p in points if p[0]>center),key=lambda p:p[2])
  lo,hi=left[0],right[0]
  # Both rear corners are inside their original side surfaces, with a real
  # separation from any original backing rather than a depth-order trick.
  z=max(left[2],right[2])+.1/span
  return(lo,hi,z)
 levels=sorted(set(v[1]for v in source));bands=[]
 for lo,hi in zip(levels,levels[1:]):
  if hi-lo<1e-7:continue
  eps=min((hi-lo)*1e-4,1e-7);a,b=section(lo+eps),section(hi-eps)
  if a and b:bands.append((lo,hi,a,b))
 need(bands and bands[0][0]<1e-6,'rear closure does not reach original foundation')
 out=dict(side,name='authored_closed_rear',vertices=[],indices=[]);out.pop('colors',None)
 def emit(poly):
  if len(poly)<3:return
  first=len(out['vertices']);out['vertices'].extend([list(p)+list(uv)+[1.]for p in poly])
  for i in range(1,len(poly)-1):
   a,b,c=poly[0],poly[i],poly[i+1];u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];cross=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
   if sum(n*n for n in cross)>1e-20:out['indices'].extend([first+1,first+i+1,first+i+2])
 previous=None
 for lo,hi,a,b in bands:
  emit([[a[0],lo,a[2]],[b[0],hi,b[2]],[b[1],hi,b[2]],[a[1],lo,a[2]]])
  if previous:
   y,p=previous
   if abs(y-lo)<1e-6 and max(abs(p[k]-a[k])for k in range(3))>1e-6:
    join=[[p[0],p[2]],[p[1],p[2]],[a[1],a[2]],[a[0],a[2]]]
    if abs(_area(join))>1e-14:
     if _area(join)<0:join=join[::-1]
     polygons=[join]
     for part in parts:
      vs=part['vertices']
      for i in range(0,len(part['indices']),3):
       tri=[vs[k-1]for k in part['indices'][i:i+3]]
       if all(abs(v[1]-lo)<1e-7 for v in tri):
        cut=[[v[0],v[2]]for v in tri]
        if abs(_area(cut))>1e-14:polygons=[q for poly in polygons for q in _subtract(poly,cut)]
     for poly in polygons:emit([[pt[0],lo,pt[1]]for pt in(poly[::-1]if a[2]>p[2]else poly)])
  previous=(hi,b)
 need(out['indices'],'empty rear closure')
 return out,dict(authoredRearTriangles=len(out['indices'])//3,profileBands=len(bands),sourcePaintTexel=list(uv),insetSourceUnits=.1)
