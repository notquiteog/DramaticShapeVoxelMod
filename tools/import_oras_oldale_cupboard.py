#!/usr/bin/env python3
"""Preserve the genuine Oldale china cupboard, dishes and transparent doors."""
import argparse,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components,merge_parts
from import_oras_oldale_table import solid_cloth


def caps(part,expected,sample):
    """Cap reviewed small convex vessel/handle rims at exact source vertices."""
    from collections import Counter
    points={};edges=Counter();direction={}
    for i in range(0,len(part['indices']),3):
        ps=[]
        for n in part['indices'][i:i+3]:
            v=part['vertices'][n-1];key=tuple(round(x,4)for x in v[:3]);points.setdefault(key,v[:3]);ps.append(key)
        for a,b in zip(ps,ps[1:]+ps[:1]):key=tuple(sorted((a,b)));edges[key]+=1;direction[key]=(a,b)
    need(all(n<=2 for n in edges.values()),'nonmanifold vessel source')
    adjacent={}
    for key,n in edges.items():
        if n==1:
            a,b=direction[key];need(a not in adjacent,'branching vessel rim');adjacent[a]=b
    loops=[]
    while adjacent:
        at=start=next(iter(adjacent));q=[]
        while True:
            q.append(points[at]);at=adjacent.pop(at)
            if at==start:break
        loops.append(q)
    need(sorted(map(len,loops))==sorted(expected),'reviewed vessel rims changed')
    out=[];uv=[(sample[0]+.5)/128,(sample[1]+.5)/128]
    for q in loops:
        center=[sum(p[k]for p in q)/len(q)for k in range(3)];n=len(q)
        p={k:v for k,v in part.items()if k not in('vertices','indices','colors')}
        p.update(name='authored_vessel_rim',vertices=[center+uv+[1]]+[list(v)+uv+[1]for v in q],indices=[i for at in range(n)for i in(1,(at+1)%n+2,at+2)],authored=True)
        # A cap retains its vessel's original ceramic tint, not source shading.
        p['colors']=[part['colors'][0][:]for _ in p['vertices']];out.append(p)
    return out


def quad(template,points,sample=(10,20)):
    uv=[(sample[0]+.5)/128,(sample[1]+.5)/128]
    p={k:v for k,v in template.items()if k not in('vertices','indices','colors')}
    p.update(name='authored_case_closure',vertices=[list(v)+uv+[1]for v in points],indices=[1,2,3,1,3,4],colors=[[1,1,1,1]]*4,authored=True)
    return p


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(hashlib.sha256(raw).hexdigest()=='93158e5006309bdc48a0b2aa4d06edbd5405ad521398100e19eef3286ed275c0','reviewed source case coordinates changed')
    need(m.name=='t102r0101_00_00'and not m.bones,'unreviewed original Oldale room')
    sub=m.submeshes[10];need(sub.material=='t102_shelf02'and len(sub.triangles)==242,'reviewed cupboard changed')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0].meshes[10]
    need(sub.positions==other.positions and sub.uv0==other.texcoords,'independent cupboard positions/UV differ')
    need(len(other.submeshes)==1 and [n for t in sub.triangles for n in t]==other.submeshes[0].indices,'independent cupboard triangles differ')
    texture='assets/scenery/oras-oldale-cupboard/t102_shelf02.png';source=source_part(sub,texture)
    used=sorted({n for t in sub.triangles for n in t})
    for row,n in zip(source['colors'],used):
        c=sub.colors[n]
        if max(c[:3])-min(c[:3])>.001:row[:3]=c[:3]
    groups=components(sub)
    need([(g[0],len(g))for g in groups]==[(0,16),(16,16),(32,16),(48,16),(64,16),(80,16),(96,30),(126,30),(156,30),(186,2),(188,30),(190,4),(194,4),(204,8),(228,4),(232,4)],'reviewed cupboard connectivity changed')
    closures=[]
    for g in groups:
        start=g[0];p=source_part(sub,texture,[sub.triangles[i]for i in g])
        tint=sub.colors[sub.triangles[g[0]][0]]
        if max(tint[:3])-min(tint[:3])>.001:
            for c in p['colors']:c[:3]=tint[:3]
        if start in(0,32,64,80):closures.extend(caps(p,[6],(90,105)))
        elif start in(16,48):closures.extend(caps(p,[4,4],(90,105)))
        elif start in(96,126,156):closures.extend(caps(p,[10],(90,105)))
        elif start in(186,190,194):
            # Real thin panel thickness; inward faces are separated from the
            # front surface. Original transparent door texels remain intact.
            # Their boundary ends are buried in the case/shelf walls. A
            # duplicate perimeter strip there would coincide with those
            # original surfaces; only the separated inward face is missing.
            closures.append(solid_cloth(p,.03,normal_axis=2,expected_rim=4 if start==186 else 6)[0])
        elif start==204:closures.extend(caps(p,[4,4],(10,20)))
    # The case has an open outer underside and an open inner ceiling. Its
    # original rear-panel T seams are retained; a fan over that branch would
    # overlap original planes. Close only these two missing rectangles.
    closures.append(quad(source,[[-232,3.5,-286],[-200,3.5,-286],[-200,3.5,-272],[-232,3.5,-272]]))
    closures.append(quad(source,[[-230,28,-286],[-230,28,-272],[-202,28,-272],[-202,28,-286]]))
    # Source shelves already have top/front faces. Close their backs and
    # undersides; lower shelf sides end in the case's existing inner walls.
    for left,right,top,bottom,back,front,sides in [(-229.5,-202.5,20.6371,19.69344,-285.50269,-273.88361,True),(-230,-202,15,13.5,-285.69141,-272.2063,False)]:
        # Keep the source's exact float positions, rather than rounded bounds.
        g=next(g for g in groups if g[0]==(228 if sides else 232));ps=[sub.positions[n]for i in g for n in sub.triangles[i]]
        left,right=min(v[0]for v in ps),max(v[0]for v in ps);bottom,top=min(v[1]for v in ps),max(v[1]for v in ps);back,front=min(v[2]for v in ps),max(v[2]for v in ps)
        closures.append(quad(source,[[left,bottom,back],[right,bottom,back],[right,bottom,front],[left,bottom,front]]))
        closures.append(quad(source,[[left,bottom,back],[left,top,back],[right,top,back],[right,bottom,back]]))
        if sides:
            closures.append(quad(source,[[left,bottom,back],[left,bottom,front],[left,top,front],[left,top,back]]))
            closures.append(quad(source,[[right,bottom,front],[right,bottom,back],[right,top,back],[right,top,front]]))
    closure=merge_parts(closures);closure['name']='authored_reviewed_cupboard_closures'
    model,meta=normalized([source,closure]);data={'oras_oldale_china_cupboard':model}
    t=next(t for t in load_textures(blob)if t.name=='t102_shelf02');need((t.width,t.height)==(128,128),'cupboard PNG dimensions changed')
    content=png(t.rgba,t.width,t.height);folder=output/'assets/scenery/oras-oldale-cupboard';folder.mkdir(parents=True,exist_ok=True);(folder/'t102_shelf02.png').write_bytes(content)
    (output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/ImportedOldaleCupboardData.lua').write_text('-- Genuine ORAS china cupboard; generated by tools/import_oras_oldale_cupboard.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO230 -> AD115 -> MM171 -> GR513',model=m.name,submesh=10,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textureRgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),sourceTriangles=242,authoredClosureTriangles=len(closure['indices'])//3,sourceFront='+Z',**meta,processing='All original case, six cups/handles, three dishes, two doors and drawer surfaces retained. Original UV/PNG alpha and chromatic ceramic vertex tints retained; grayscale source shading removed. Reviewed open vessel bottoms/handle ends, panels, case underside/ceiling and shelf backs/undersides closed. Lower shelf side caps omitted where source inner case walls already cover them. Original case rear T seams are retained; no blanket branched-rim fan. No source floor, shadow or light geometry. Uniform native fit and physical bottom recess.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output).items():print(name,len(m['parts']),sum(len(p['indices'])//3 for p in m['parts']))
