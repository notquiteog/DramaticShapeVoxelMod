#!/usr/bin/env python3
"""Audit actual emitted Hoenn cave quads from the isolated native QA report.

No ROM data, textures or expected screenshot pixels are required. The tunnel is
joined to the existing cliff perimeter, rather than a freestanding closed box.
"""
import argparse,json,math
from pathlib import Path
from oras_geometry_audit import coplanar_overlaps

def audit(report):
    assert report['closedRegiPreserved'] and report['recovery']==0
    assert len(report['entries'])>=2 and len(report['entries'])%2==0 and all(e['returned']and e['level']in(0,3)for e in report['entries'])
    results=[]
    for owner in report['owners']:
        key=f"{owner['map']}:{owner['x']}:{owner['y']}";quads=report['geometry'][key]
        assert len(quads)==46,(key,'incomplete mouth surfaces')
        x,z=quads[0]['vertices'][0][0],quads[0]['vertices'][0][2]+16
        vertices=[];indices=[];floor=back=roof=physical=0
        for q in quads:
            ps=[[p[0]-x,p[1],p[2]-z]for p in q['vertices']]
            for p in ps:assert all(math.isfinite(v)for v in p)and 0<=p[0]<=16 and -16<=p[2]<=16 and 0<=p[1]<=25,(key,p)
            floor+=all(abs(p[1])<1e-8 for p in ps)
            back+=all(abs(p[2]+10)<1e-8 for p in ps)
            roof+=all(p[2]in(-10,12)and p[1]>0 for p in ps)
            at=len(vertices);vertices.extend(ps);indices.extend(at+i for i in[1,2,3,1,3,4])
            for a,b,c in[[ps[0],ps[1],ps[2]],[ps[0],ps[2],ps[3]]]:
                u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)]
                physical+=sum(n*n for n in[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]])>1e-12
        overlaps=coplanar_overlaps([dict(name=key,vertices=vertices,indices=indices)])
        assert not overlaps,(key,overlaps)
        assert(floor,back,roof)==(1,3,3),(key,floor,back,roof)
        results.append(dict(map=owner['map'],x=owner['x'],y=owner['y'],triangles=physical,coplanarOverlaps=0,floorOwners=1,recessDepth=22))
    return dict(edition=report['edition'],mouths=len(results),sourceSha256=report['sourceSha256'],results=results)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('report',type=Path);x=p.parse_args()
    print(json.dumps(audit(json.loads(x.report.read_text())),indent=2))
