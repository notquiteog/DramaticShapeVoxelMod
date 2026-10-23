#!/usr/bin/env python3
"""Prepare the original ORAS Oldale sink without duplicate internal caps."""
import argparse,collections,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components,merge_parts
from import_oras_oldale_cupboard import caps,quad


def rims(part):
    rows=part['vertices'];edges=collections.Counter();direction={};points={}
    for i in range(0,len(part['indices']),3):
        ps=[]
        for n in part['indices'][i:i+3]:
            v=rows[n-1][:3];k=tuple(round(x,4)for x in v);points.setdefault(k,v);ps.append(k)
        for a,b in zip(ps,ps[1:]+ps[:1]):key=tuple(sorted((a,b)));edges[key]+=1;direction[key]=(a,b)
    need(all(n<=2 for n in edges.values()),'unreviewed counter source topology')
    adjacent={}
    for key,n in edges.items():
        if n==1:
            a,b=direction[key];need(a not in adjacent,'branched counter rim');adjacent[a]=b
    out=[]
    while adjacent:
        at=start=next(iter(adjacent));q=[]
        while True:
            q.append(points[at]);at=adjacent.pop(at)
            if at==start:break
        out.append(q)
    return out


def area(poly):return sum(a[0]*b[1]-b[0]*a[1]for a,b in zip(poly,poly[1:]+poly[:1]))/2


def annulus(part,outer,inner):
    """Partition a convex counter underside around the open cabinet join.

    Sequential half-plane clipping emits disjoint convex outside pieces. It
    never caps the inside cabinet footprint at the same height twice.
    """
    y=outer[0][1];need(all(abs(p[1]-y)<1e-5 for p in outer+inner),'counter/base join heights differ')
    outer=[[p[0],p[2]]for p in outer];inner=[[p[0],p[2]]for p in inner]
    if area(outer)<0:outer.reverse()
    if area(inner)<0:inner.reverse()
    def side(u,v,p):return(v[0]-u[0])*(p[1]-u[1])-(v[1]-u[1])*(p[0]-u[0])
    def half(poly,u,v,inside):
        out=[]
        for a,b in zip(poly,poly[1:]+poly[:1]):
            da,db=side(u,v,a),side(u,v,b)
            if (da>=-1e-9 if inside else da<=1e-9):out.append(a)
            if (da>1e-9 and db<-1e-9)or(da<-1e-9 and db>1e-9):
                f=da/(da-db);out.append([a[0]+(b[0]-a[0])*f,a[1]+(b[1]-a[1])*f])
        # Remove coincident and collinear points before triangulation.
        unique=[]
        for p in out:
            if not unique or sum((p[k]-unique[-1][k])**2 for k in range(2))>1e-16:unique.append(p)
        if len(unique)>1 and sum((unique[0][k]-unique[-1][k])**2 for k in range(2))<1e-16:unique.pop()
        changed=True
        while changed and len(unique)>3:
            changed=False
            for i,p in enumerate(unique):
                if abs(side(unique[i-1],unique[(i+1)%len(unique)],p))<1e-8:unique.pop(i);changed=True;break
        return unique
    remaining=outer;pieces=[]
    for u,v in zip(inner,inner[1:]+inner[:1]):
        outside=half(remaining,u,v,False)
        if len(outside)>=3 and abs(area(outside))>1e-8:pieces.append(outside)
        remaining=half(remaining,u,v,True)
    need(abs(sum(abs(area(p))for p in pieces)-(abs(area(outer))-abs(area(inner))))<1e-5,'counter join area mismatch')
    p={k:v for k,v in part.items()if k not in('vertices','indices','colors')};p.update(name='authored_counter_join_annulus',vertices=[],indices=[],colors=[],authored=True)
    uv=[40.5/128,110.5/128]
    for q in pieces:
        offset=len(p['vertices']);p['vertices'].extend([[a,y,b]+uv+[1]for a,b in q]);p['colors'].extend([[1,1,1,1]]*len(q))
        for i in range(1,len(q)-1):p['indices'].extend([offset+1,offset+i+1,offset+i+2])
    return p,abs(area(outer))-abs(area(inner))


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(hashlib.sha256(raw).hexdigest()=='93158e5006309bdc48a0b2aa4d06edbd5405ad521398100e19eef3286ed275c0','reviewed Oldale sink source changed')
    need(m.name=='t102r0101_00_00'and not m.bones,'unreviewed original Oldale room')
    sub=m.submeshes[12];need(sub.material=='sink01'and len(sub.triangles)==484,'reviewed sink stream changed')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0].meshes[12]
    need(sub.positions==other.positions and sub.uv0==other.texcoords,'independent sink positions/UV differ')
    need(len(other.submeshes)==1 and [n for t in sub.triangles for n in t]==other.submeshes[0].indices,'independent sink triangles differ')
    texture='assets/scenery/oras-oldale-sink/sink01.png';source=source_part(sub,texture)
    used=sorted({n for t in sub.triangles for n in t})
    for row,n in zip(source['colors'],used):
        c=sub.colors[n]
        if max(c[:3])-min(c[:3])>.001:row[:3]=c[:3]
    groups=components(sub);need([(g[0],len(g))for g in groups]==[(0,50),(10,50),(20,50),(30,24),(38,24),(46,28),(54,52),(78,172),(256,34)],'reviewed sink connectivity changed')
    closures=[];counter=base=None
    for g in groups:
        p=source_part(sub,texture,[sub.triangles[i]for i in g]);tint=sub.colors[sub.triangles[g[0]][0]]
        if max(tint[:3])-min(tint[:3])>.001:
            for c in p['colors']:c[:3]=tint[:3]
        if g[0]in(0,10,20):closures.extend(caps(p,[10],(103,75)))
        elif g[0]in(30,38):closures.extend(caps(p,[8],(103,75)))
        elif g[0]==78:counter=p
        elif g[0]==256:base=p
    cr=rims(counter);br=rims(base);need(sorted(map(len,cr))==[4,16]and sorted(map(len,br))==[17,17],'reviewed counter/base rims changed')
    outer=next(q for q in cr if len(q)==16);seam=next(q for q in cr if len(q)==4)
    need(max(p[2]for p in seam)-min(p[2]for p in seam)<1e-5,'source collinear counter seam changed')
    top=max(br,key=lambda q:sum(p[1]for p in q));bottom=min(br,key=lambda q:sum(p[1]for p in q))
    ring,join_area=annulus(source,outer,top);closures.append(ring)
    # Cap only the cabinet's bottom; its top is joined to the countertop.
    p={k:v for k,v in base.items()if k not in('vertices','indices','colors')};p.update(vertices=[],indices=[],colors=[])
    for q in bottom:p['vertices'].append(q+[40.5/128,110.5/128,1]);p['colors'].append([1,1,1,1])
    center=[sum(q[k]for q in bottom)/len(bottom)for k in range(3)];p['vertices'].append(center+[40.5/128,110.5/128,1]);p['colors'].append([1,1,1,1]);n=len(bottom)
    for i in range(n):p['indices'].extend([n+1,(i+1)%n+1,i+1])
    p['authored']=True;closures.append(p)
    # Three open spout edges meet a source internal seam. Close this actual
    # top opening only; the stem bottom is already covered by the countertop.
    ps=sub.positions
    wanted=[(-284.71921,21.03552,-244.9957),(-284.13589,21.16004,-244.4124),(-284.13589,21.16004,-243.5876),(-284.71921,21.03552,-243.0043)]
    exact=[]
    for q in wanted:
        at=min(ps,key=lambda p:sum((p[k]-q[k])**2 for k in range(3)));need(sum((at[k]-q[k])**2 for k in range(3))<1e-7,'spout rim changed');exact.append(at)
    closures.append(quad(source,exact,(40,110)))
    closure=merge_parts(closures);closure['name']='authored_reviewed_sink_closures';model,meta=normalized([source,closure]);data={'oras_oldale_kitchen_sink':model}
    t=next(t for t in load_textures(blob)if t.name=='sink01');need((t.width,t.height)==(128,128),'sink PNG dimensions changed');content=png(t.rgba,t.width,t.height)
    folder=output/'assets/scenery/oras-oldale-sink';folder.mkdir(parents=True,exist_ok=True);(folder/'sink01.png').write_bytes(content)
    (output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/ImportedOldaleSinkData.lua').write_text('-- Genuine ORAS Oldale kitchen sink; generated by tools/import_oras_oldale_sink.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO230 -> AD115 -> MM171 -> GR513',model=m.name,submesh=12,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textureRgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),sourceTriangles=484,authoredClosureTriangles=len(closure['indices'])//3,counterJoinArea=join_area,sourceFront='+X',nativeQuarterTurn=1,**meta,processing='Complete original sink basin, faucet, worktop, drawers, three dishes and two colored cups. Original positions/UV/PNG and chromatic ceramic tints retained; grayscale vertex shading removed. Vessel bottoms, actual spout top and base underside closed. Counter underside is a disjoint annulus around the open base top; no duplicate coplanar internal caps. Source collinear countertop T seam has zero area and receives no face. Faucet stem bottom joins the original counter surface without another cap. No floor, shadow or source light geometry. Uniform native blocked-body fit with quarter-turn and physical bottom recess.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output).items():print(name,len(m['parts']),sum(len(p['indices'])//3 for p in m['parts']))
