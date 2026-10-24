"""Source-faithful closure/card/determinism proof; takes authorized Celadon ZIP, never ships it."""
import argparse,math,sys,tempfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from import_celadon_short_house import convert

def cross(a,b,c):return(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
def area(p):return abs(sum(a[0]*b[1]-a[1]*b[0]for a,b in zip(p,p[1:]+p[:1])))/2

def overlap(a,b):
 if cross(*b)<0:b=list(reversed(b))
 for c,d in zip(b,b[1:]+b[:1]):
  out=[]
  for p,q in zip(a,a[1:]+a[:1]):
   cp,cq=cross(c,d,p),cross(c,d,q)
   if cp>=-1e-10:out.append(p)
   if(cp>0 and cq<0)or(cp<0 and cq>0):
    t=cp/(cp-cq);out.append((p[0]+t*(q[0]-p[0]),p[1]+t*(q[1]-p[1])))
  a=out
  if not a:break
 return area(a)if a else 0

def triangles(p):
 vs=p['vertices'];ind=p['indices']
 return [[vs[j-1]for j in ind[i:i+3]]for i in range(0,len(ind),3)]

def check(archive):
 root=Path(__file__).resolve().parents[1]
 with tempfile.TemporaryDirectory()as folder:
  out=Path(folder);data,report=convert(archive,out);source=data['hgss_celadon_short_house']
  for p in out.rglob('*'):
   if p.is_file():assert p.read_bytes()==(root/p.relative_to(out)).read_bytes(),'source regeneration differs'
  assert report['sourceTriangles']==156 and report['physicalSourceTriangles']==130
  assert report['processedArchitectureTriangles']==140 and report['hd2dFlowers']['sourceTriangles']==24
  for p in source['parts']:
   for a,b,c in triangles(p):
    u=[b[i]-a[i]for i in range(3)];v=[c[i]-a[i]for i in range(3)]
    n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
    assert sum(x*x for x in n)>1e-18,'duplicate wall/ceiling split emitted degenerate face'
  # Give every coplanar physical patch exactly one owner, including new
  # rear/soffit/foundation joins and the original source architecture.
  physical=[]
  for p in source['parts']:
   for tri in triangles(p):
    a,b,c=tri;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)]
    n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
    length=math.sqrt(sum(x*x for x in n));n=[x/length for x in n]
    physical.append((tri,n,sum(n[k]*a[k]for k in range(3))))
  for i,(a,n,d)in enumerate(physical):
   for b,_,_ in physical[i+1:]:
    if max(abs(sum(n[k]*v[k]for k in range(3))-d)for v in b)>1e-7:continue
    drop=max(range(3),key=lambda k:abs(n[k]));xy=[k for k in range(3)if k!=drop]
    projected=lambda t:[[v[k]for k in xy]for v in t]
    assert overlap(projected(a),projected(b))<1e-8,'coplanar architecture overlap'
  for card in source['hd2dCards']:
   ts=triangles(card)
   for i,a in enumerate(ts):
    for b in ts[i+1:]:assert overlap([v[:2]for v in a],[v[:2]for v in b])<1e-8,'projected flower triangles overlap'
  glass=next(p for p in source['parts']if p['texture'].endswith('/h_mado.png'))
  body=next(p for p in source['parts']if not p.get('authored')and p['texture'].endswith('/ta_h01.png'))
  for a in triangles(glass):
   for b in triangles(body):
    if all(abs(v[2]-a[0][2])<1e-8 for v in a+b):assert overlap([v[:2]for v in a],[v[:2]for v in b])<1e-8,'glass/frame coplanar overlap'
 print('PASS deterministic original source/PNG/UV,140 nondegenerate architecture faces,24 nonoverlapping HD2D flower triangles, no positive-area coplanar architecture overlap')
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('archive',type=Path);check(p.parse_args().archive)
