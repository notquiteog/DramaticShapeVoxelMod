#!/usr/bin/env python3
"""Preserve the genuine ORAS Oldale refrigerator, handles and magnet notes."""
import argparse,collections,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,close_rims,normalized
from import_oras_oldale_table import solid_cloth


def components(sub):
    owners=collections.defaultdict(set)
    key=lambda n:tuple(round(v,4)for v in sub.positions[n])
    for i,tri in enumerate(sub.triangles):
        for n in tri:owners[key(n)].add(i)
    left=set(range(len(sub.triangles)));out=[]
    while left:
        todo=[min(left)];group=set()
        while todo:
            i=todo.pop()
            if i not in left:continue
            left.remove(i);group.add(i)
            for n in sub.triangles[i]:todo.extend(owners[key(n)])
        out.append(sorted(group))
    return out


def attached_caps(part,expected):
    rows=part['vertices'];points={};edges=collections.Counter();direction={}
    for i in range(0,len(part['indices']),3):
        ps=[]
        for n in part['indices'][i:i+3]:
            p=rows[n-1];key=tuple(round(v,4)for v in p[:3]);points.setdefault(key,p[:3]);ps.append(key)
        for a,b in zip(ps,ps[1:]+ps[:1]):
            key=tuple(sorted((a,b)));edges[key]+=1;direction[key]=(a,b)
    adjacent={}
    for edge,count in edges.items():
        need(count<=2,'nonmanifold attached fixture')
        if count==1:
            a,b=direction[edge];need(a not in adjacent,'branching attached fixture rim');adjacent[a]=b
    loops=[]
    while adjacent:
        start=next(iter(adjacent));loop=[];at=start
        while True:
            loop.append(at);at=adjacent.pop(at)
            if at==start:break
        loops.append(loop)
    need(sorted(map(len,loops))==sorted(expected),'reviewed attached fixture rims changed')
    parts=[]
    for number,loop in enumerate(loops):
        front=[points[p]for p in loop]
        need(max(p[0]for p in front)-min(p[0]for p in front)<.001 and min(p[0]for p in front)>=-271.501,'unreviewed original attachment plane')
        # The original handle/letter backs meet the fridge's front plane.
        # Close them just inside that case, avoiding a coplanar duplicate.
        inner=[[-271.55,p[1],p[2]]for p in front]
        center=[sum(p[k]for p in inner)/len(inner)for k in range(3)]
        uv=[16.5/64,16.5/64];vertices=[list(p)+uv+[1]for p in front+inner+[center]]
        indices=[];n=len(front);middle=2*n+1
        for i in range(n):
            a,b=i+1,(i+1)%n+1
            indices.extend([b,a,a+n,b,a+n,b+n,middle,a+n,b+n])
        cap={k:v for k,v in part.items()if k not in('vertices','indices','colors')}
        cap.update(name='authored_recessed_attachment_'+str(number),vertices=vertices,indices=indices,colors=[[1,1,1,1]]*len(vertices),authored=True)
        parts.append(cap)
    return parts


def merge_parts(parts):
    out={k:v for k,v in parts[0].items()if k not in('vertices','indices','colors')}
    out.update(name='authored_original_rim_and_paper_closures',vertices=[],indices=[],colors=[],authored=True)
    for p in parts:
        start=len(out['vertices']);out['vertices'].extend([list(v)for v in p['vertices']]);out['indices'].extend(start+n for n in p['indices']);out['colors'].extend([list(c)for c in p['colors']])
    return out


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(m.name=='t102r0101_00_00'and not m.bones,'unreviewed original Oldale room')
    sub=m.submeshes[8];need(sub.material=='ref01'and len(sub.triangles)==166,'reviewed original refrigerator changed')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0].meshes[8]
    need(sub.positions==other.positions and sub.uv0==other.texcoords,'independent source positions/UV differ')
    need(len(other.submeshes)==1 and [n for tri in sub.triangles for n in tri]==other.submeshes[0].indices,'independent source indices differ')
    mat=next(mat for mat in m.materials if mat.name=='ref01');need(mat.base_color_texture=='ref01','source material changed')
    texture='assets/scenery/oras-oldale-fridge/ref01.png';groups=components(sub)
    need([(g[0],len(g))for g in groups]==[(0,46),(8,36),(20,36),(64,4),(67,4),(124,2),(126,10),(136,10),(146,6),(152,6),(158,6)],'original fixture connectivity changed')
    closures=[]
    for number,group in enumerate(groups):
        part=source_part(sub,texture,[sub.triangles[i]for i in group])
        if number==0:closures.extend(close_rims(part,[8],(16,16)))
        elif number in(1,2):closures.extend(attached_caps(part,[6,6]))
        elif number in(6,7):closures.extend(attached_caps(part,[4]))
        else:
            closed=solid_cloth(part,.03,normal_axis=0,expected_rim=4 if number==5 else 6)
            for p in closed:p['name']=p['name'].replace('cloth','paper')
            closures.extend(closed)
    source=source_part(sub,texture);model,meta=normalized([source,merge_parts(closures)])
    data={'oras_oldale_refrigerator':model};folder=output/'assets/scenery/oras-oldale-fridge';folder.mkdir(parents=True,exist_ok=True)
    t=next(t for t in load_textures(blob)if t.name=='ref01');need((t.width,t.height)==(64,64)and set(t.rgba[3::4])=={255},'source refrigerator texture changed')
    content=png(t.rgba,t.width,t.height);(folder/'ref01.png').write_bytes(content)
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedOldaleFridgeData.lua').write_text('-- Genuine ORAS Oldale refrigerator; generated by tools/import_oras_oldale_fridge.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO230 -> AD115 -> MM171 -> GR513',model=m.name,submesh=8,
        modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textureRgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),**meta,
        sourceTriangles=166,authoredClosureTriangles=200,sourceFront='+X',nativeQuarterTurn=1,
        independentValidation='Original selected positions, UV0 and triangle indices independently agree with Nitrogen; source is unskinned.',
        processing='Complete original case, two handles, six paper notes and two solid magnets retained. Source underside rim closed; handle/magnet backs close 0.05 source units inside the original case front to avoid coplanar faces. Paper sheets gain 0.03-source-unit inner surfaces and closed thin rims. Source vertex RGB is white; original PNG RGBA and UVs unchanged. No floor, source shadow or light geometry. Uniform native fit; quarter-turn aligns original west-wall front with native south-facing refrigerator.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return data


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output).items():print(name,len(m['parts']),sum(len(p['indices'])//3 for p in m['parts']))
