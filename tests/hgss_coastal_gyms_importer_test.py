"""Actual six-Gym original-source/closure proof; takes authorized ZIP folder."""
import argparse,math,sys,tempfile
from pathlib import Path,PurePosixPath
sys.path[:0]=[str(Path(__file__).resolve().parents[1]/'tools'),str(Path(__file__).resolve().parent)]
from import_hgss_kanto_gyms import convert,SPECS
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from celadon_short_house_importer_test import overlap,triangles

def check(archives):
 root=Path(__file__).resolve().parents[1]
 with tempfile.TemporaryDirectory()as folder:
  out=Path(folder);models,reports=convert(archives,out)
  for p in out.rglob('*'):
   if p.is_file():assert p.read_bytes()==(root/p.relative_to(out)).read_bytes(),'regeneration differs'
  for key,(asset,body,door,offset,_)in SPECS.items():
   data=models[key];report=reports[key];items,_=archive_items((archives/(str(asset)+'.zip')).read_bytes());raw=next(v for k,v in items.items()if k.endswith('.dae'));original=extract(raw,{key:body},{key:(door,offset)})[key]
   span=report['normalization']['sourceUnitSpan'];origin=report['normalization']['sourceOrigin'];allparts=data['parts']+data['doorParts'];byname={p['name']:p for p in allparts}
   for p in original:
    if p['texture']=='h_kage.png':continue
    current=byname[p['name']];ts=list(triangles(current))
    for i in range(0,len(p['vertices']),3):
     rawtri=p['vertices'][i:i+3];repair=p['texture']=='kn_gym_a.png'and all(v[2]<-40 and 35.4<v[1]<44.2 for v in rawtri)
     for old,new in zip(rawtri,ts[i//3]):
      assert all(abs((old[k]-origin[k])/span-new[k])<1e-12 for k in range(3)),'original upper/source-door geometry moved'
      assert new[3:5]==([25.5/32,.5]if repair else old[3:5]),'original source UV changed'
    source=next(v for n,v in items.items()if PurePosixPath(n).name==p['texture']);assert (out/current['texture']).read_bytes()==source,'original PNG changed'
   assert report['originalTriangles']==285 and report['processedTriangles']==328
   physical=[]
   for p in allparts:
    for tri in triangles(p):
     a,b,c=tri;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];length=math.sqrt(sum(x*x for x in n));assert length>1e-10,'degenerate source/closure'
     n=[x/length for x in n];physical.append((tri,n,sum(n[k]*a[k]for k in range(3))))
   for i,(a,n,d)in enumerate(physical):
    for b,_,_ in physical[i+1:]:
     if max(abs(sum(n[k]*v[k]for k in range(3))-d)for v in b)>1e-7:continue
     xy=[k for k in range(3)if k!=max(range(3),key=lambda k:abs(n[k]))]
     assert overlap([[v[k]for k in xy]for v in a],[[v[k]for k in xy]for v in b])<1e-8,'coplanar source/foundation/closed-door overlap'
 print('PASS six deterministic regional Gyms: original XYZ/UV/PNG/door preservation, measured contact skirts,328 nondegenerate triangles/model and zero positive-area coplanar overlap')
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('archives',type=Path);check(p.parse_args().archives)
