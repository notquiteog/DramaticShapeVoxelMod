#!/usr/bin/env python3
"""Export reviewed physical ORAS fence modules from explicit local BCH inputs.

No decoder or raw game archives are bundled. Source paint/UVs remain original;
only absent backs, bottoms and repeat cut ends are authored from edge paint.
"""
import argparse, hashlib, itertools, json, math
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_grass import lua

def sub(a,b):return tuple(x-y for x,y in zip(a,b))
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return(a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def norm(a):return math.sqrt(dot(a,a))
def area(t):return norm(cross(sub(t[1],t[0]),sub(t[2],t[0])))/2

def primitive(s,start,end,extra=()):
    tris=[[list(s.positions[i])+list(s.uv0[i]) for i in t]for t in s.triangles[start:end]]
    points=sorted(set(tuple(p[:3])for t in tris for p in t)|set(extra));planes={}
    for p,q,r in itertools.combinations(points,3):
        n=cross(sub(q,p),sub(r,p));length=norm(n)
        if length<1e-7:continue
        n=tuple(v/length for v in n);d=dot(n,p);ds=[dot(n,v)-d for v in points]
        if min(ds)<-1e-6 and max(ds)>1e-6:continue
        if max(ds)>1e-6:n=tuple(-v for v in n);d=-d
        key=tuple(round(v,5)for v in n+(d,));planes[key]=(n,d)
    authored=0
    for n,d in planes.values():
        ps=[p for p in points if abs(dot(n,p)-d)<1e-5]
        c=tuple(sum(p[k]for p in ps)/len(ps)for k in range(3));u=sub(ps[0],c);u=tuple(v/norm(u)for v in u);v=cross(n,u)
        ps.sort(key=lambda p:math.atan2(dot(sub(p,c),v),dot(sub(p,c),u)))
        full=sum(area([ps[0],ps[j],ps[j+1]])for j in range(1,len(ps)-1))
        present=sum(area([p[:3]for p in t])for t in tris if all(abs(dot(n,p[:3])-d)<1e-5 for p in t))
        if abs(full-present)<1e-4:continue
        need(present<1e-4,f'partial unsupported primitive face {start}:{end}: {present}/{full}')
        # Actual nearest source edge texel. Never sample an invented UV origin.
        edge=min((p for t in tris for p in t),key=lambda p:sum((p[k]-c[k])**2 for k in range(3)))[3:]
        for j in range(1,len(ps)-1):tris.append([list(p)+edge for p in(ps[0],ps[j],ps[j+1])]);authored+=1
    return tris,authored

def part(name,texture,tris):
    vertices=[list(p[:3])+[p[3],1-p[4],1]for t in tris for p in t]
    return dict(name=name,texture=texture,vertices=vertices,indices=list(range(1,len(vertices)+1)),role='structure',vertexColorRole='lighting',alphaMode='cutout',opacity=1,wrapS='repeat',wrapT='repeat')

def rural(m):
    need(m.name=='world04_03_07' and m.submeshes[2].material=='chip_steps01a','unexpected rural fence source')
    s=m.submeshes[2];need(len(s.triangles)==724,'rural source topology changed')
    a,na=primitive(s,27,38);b,nb=primitive(s,38,50)
    # The rail source omits its rear/bottom and two end faces: infer the two
    # unrepresented lower-rear corners from its exact physical prism bounds.
    rail,nr=primitive(s,50,54,((7.,11.75,-351.75),(11.,11.75,-351.75)))
    out=[]
    for tris,cx,target in((a,4.5,4),(b,13.5,12)):
        out.extend([[[target+(p[0]-cx)*.5,(p[1]-.25)*.5,8+(p[2]+351)*.5]+p[3:]for p in t]for t in tris])
    for lo,hi in((0,2.75),(5.25,10.75),(13.25,16)):
        out.extend([[[lo+(p[0]-7)/4*(hi-lo),(p[1]-.25)*.5,8+(p[2]+351)*.5]+p[3:]for p in t]for t in rail])
    return dict(parts=[part('source_posts_and_repeating_rail','assets/scenery/oras-fences/chip_steps01.png',out)],anchors={}),dict(sourcePostTriangles=23,sourceRailTriangles=4,closedPostTriangles=na+nb,closedRailTriangles=nr,repeatWidth=16,height=10.25,sourcePostScale=.5,processing='Uniform source posts at native centers4/12; only straight rail span length fits each native repeat; original cross sections/UVs retained. No source shadow sheets or baked vertex RGB.')

def convert(model_path,textures_path,decoder_path,output):
    load,textures,png=decoder(decoder_path);raw=model_path.read_bytes();txraw=textures_path.read_bytes();models=load(raw)
    need(len(models)==1,'unexpected rural model count');data,proof=rural(models[0]);tx={t.name:t for t in textures(txraw)}
    folder=output/'assets/scenery/oras-fences';folder.mkdir(parents=True,exist_ok=True)
    t=tx['chip_steps01'];need((t.width,t.height)==(128,128)and set(t.rgba[3::4])=={255},'rural source texture changed')
    blob=png(t.rgba,t.width,t.height);(folder/'chip_steps01.png').write_bytes(blob)
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',rural=dict(model='a/0/3/9 GR0042 slot1 world04_03_07 chip_steps01a',textures='a/0/1/4 AD0011 slot11 chip_steps01',modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(txraw).hexdigest(),textureRgbaSha256=hashlib.sha256(t.rgba).hexdigest(),**proof))
    (output/'lib/ImportedFenceData.lua').write_text('-- Genuine ORAS physical fence modules; tools/import_oras_fences.py.\nreturn '+lua({'oras_rural_fence':data})+'\n')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in('model','textures','decoder','output'):p.add_argument('--'+n,type=Path,required=True)
    x=p.parse_args();print(json.dumps(convert(x.model,x.textures,x.decoder,x.output),indent=2))
