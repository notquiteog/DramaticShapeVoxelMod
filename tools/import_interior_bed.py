#!/usr/bin/env python3
"""Select original ORAS Comfortable Bed geometry; source archives stay scratch."""
import argparse, collections, hashlib, io, json, math, zipfile
from pathlib import Path, PurePosixPath
from PIL import Image
from import_scenery_models import obj, materials, normalize, safe_path
from import_oras_grass import lua


def closures(source):
    vertices=source['vertices'];points={};edges=collections.Counter();direction={}
    if len(vertices)!=1602:raise ValueError('Original 534-triangle bed stream changed')
    for i in range(0,len(vertices),3):
        q=[]
        for v in vertices[i:i+3]:k=tuple(v[:3]);points.setdefault(k,v[:3]);q.append(k)
        for a,b in zip(q,q[1:]+q[:1]):key=tuple(sorted((a,b)));edges[key]+=1;direction[key]=(a,b)
    if any(n>2 for n in edges.values()):raise ValueError('Nonmanifold original bed')
    adjacent={};loops=[]
    for e,n in edges.items():
        if n==1:
            a,b=direction[e]
            if a in adjacent:raise ValueError('Branching original bed rim')
            adjacent[a]=b
    while adjacent:
        at=start=next(iter(adjacent));loop=[]
        while True:
            loop.append(at);at=adjacent.pop(at)
            if at==start:break
        loops.append(loop)
    if sorted(map(len,loops))!=[16,18,32,32,34]:raise ValueError('Original bed rims changed')
    def cross(a,b):return[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
    def dot(a,b):return sum(x*y for x,y in zip(a,b))
    def delta(a,b):return[a[k]-b[k]for k in range(3)]
    original=[]
    for i in range(0,len(vertices),3):
        ps=[v[:3]for v in vertices[i:i+3]];normal=cross(delta(ps[1],ps[0]),delta(ps[2],ps[0]));length=math.sqrt(dot(normal,normal));normal=[x/length for x in normal]
        original.append((ps,normal,dot(normal,ps[0])))
    def overlapping(ps):
        normal=cross(delta(ps[1],ps[0]),delta(ps[2],ps[0]));length=math.sqrt(dot(normal,normal));normal=[x/length for x in normal]
        for qs,n,d in original:
            if abs(dot(n,normal))<1-1e-9 or any(abs(dot(n,p)-d)>1e-7 for p in ps):continue
            axis=max(range(3),key=lambda k:abs(n[k]));dims=[k for k in range(3)if k!=axis]
            flat=lambda p:(p[dims[0]],p[dims[1]])
            polygon=list(map(flat,ps));clip=list(map(flat,qs))
            side=lambda u,v,w:(v[0]-u[0])*(w[1]-u[1])-(v[1]-u[1])*(w[0]-u[0])
            sign=1 if side(*clip)>0 else -1
            for u,v in zip(clip,clip[1:]+clip[:1]):
                result=[]
                for a,b in zip(polygon,polygon[1:]+polygon[:1]):
                    da,db=side(u,v,a)*sign,side(u,v,b)*sign
                    if da>=-1e-11:result.append(a)
                    if da>0>db or da<0<db:
                        t=da/(da-db);result.append(tuple(a[k]+(b[k]-a[k])*t for k in range(2)))
                polygon=result
                if len(polygon)<3:break
            size=abs(sum(a[0]*b[1]-b[0]*a[1]for a,b in zip(polygon,polygon[1:]+polygon[:1])))/2
            if size>1e-10:return True
        return False
    out=[]
    for number,points in enumerate(loops):
        def area(i,k,j):
            a,b,c=points[i],points[k],points[j];u=[b[d]-a[d]for d in range(3)];v=[c[d]-a[d]for d in range(3)]
            return math.sqrt(sum(x*x for x in (u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0])))/2
        n=len(points);cost={};split={}
        for i in range(n-1):cost[i,i+1]=0
        for span in range(2,n):
            for i in range(n-span):
                j=i+span;best=math.inf
                for k in range(i+1,j):
                    size=area(i,k,j)
                    if size<1e-12 or overlapping([points[i],points[k],points[j]]):continue
                    candidate=cost.get((i,k),math.inf)+cost.get((k,j),math.inf)+size
                    if candidate<best:best=candidate;split[i,j]=k
                cost[i,j]=best
        if not math.isfinite(cost[0,n-1]):raise ValueError('Cannot close original bed rim')
        triangles=[]
        def visit(i,j):
            if j-i<2:return
            k=split[i,j];triangles.append((i,j,k));visit(i,k);visit(k,j)
        visit(0,n-1)
        xy=(20,20)if n in (18,34)else(100,50);uv=[(xy[0]+.5)/128,(xy[1]+.5)/128]
        rows=[list(points[i])+uv+[1]for t in triangles for i in t]
        out.append(dict(name='authored_exact_rim_closure_'+str(number),material='authored_exact_rim',texture='sutekinabed.png',diffuse=[.64,.64,.64],opacity=1,vertices=rows,wrapS='repeat',wrapT='repeat',authored=True))
    return out


def convert(path, output):
    raw_archive=path.read_bytes()
    with zipfile.ZipFile(io.BytesIO(raw_archive)) as z:
        if len(z.infolist())>32 or sum(i.file_size for i in z.infolist())>8388608:
            raise ValueError('Bed archive exceeds budget')
        names={PurePosixPath(safe_path(n)).name:n for n in z.namelist() if not n.endswith('/')}
        raw=z.read('Comfortable Bed/sutekinabed.obj')
        source,fixes=obj(raw,materials(z.read('Comfortable Bed/sutekinabed.mtl')),names)
        parts=[p for p in source if p['material']=='sutekinabed.png']
        if len(parts)!=1:raise ValueError('Unexpected bed source material split')
        parts.extend(closures(parts[0]))
        fixes.append('Five original open rims are closed with 122 authored triangles at their exact source vertices. Minimum-area boundary triangulation excludes triangles overlapping original source planes. Original534 triangles, positions, UV and PNG are unchanged; former approximate concave fan caps are replaced.')
        meta=normalize(parts)
        folder=output/'assets/scenery/interiors/oras_bed';folder.mkdir(parents=True,exist_ok=True)
        textures={}
        for p in parts:
            name=PurePosixPath(p['texture']).name;content=z.read(names[name]);im=Image.open(io.BytesIO(content));im.verify()
            (folder/name).write_bytes(content)
            textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)}
            p['texture']='assets/scenery/interiors/oras_bed/'+name
            p['role']='structure';p['alphaMode']='cutout'
        data={'oras_comfortable_bed':{'parts':parts,'anchors':{},'revision':1}}
        (output/'lib').mkdir(parents=True,exist_ok=True)
        (output/'lib/ImportedInteriorBedData.lua').write_text('-- Generated by tools/import_interior_bed.py; attribution is beside the selected texture.\nreturn '+lua(data)+'\n')
        report={'asset':294940,'title':'Comfortable Bed','game':'Pokémon Omega Ruby / Alpha Sapphire','author':'Hallow','submitted':'2015-11-15',
                'sourcePage':'https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/294940/',
                'originalGameArt':'Nintendo / Creatures / GAME FREAK',
                'archiveSha256':hashlib.sha256(raw_archive).hexdigest(),'sourceModelSha256':hashlib.sha256(raw).hexdigest(),
                'selection':'Original bed body, curved head/foot boards, blue spotted blanket and white pillow. Planar source shadow excluded; renderer owns shadows.',
                'textures':textures,'repairs':fixes,**meta,
                'parts':[{'name':p['name'],'material':p['material'],'triangles':p['triangles'],'authored':bool(p.get('authored'))}for p in parts]}
        (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
        return data

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    for name,model in convert(a.archive,a.output).items():print(name,len(model['parts']),sum(p['triangles']for p in model['parts']))
