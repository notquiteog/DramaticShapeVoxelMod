#!/usr/bin/env python3
"""Select original Littleroot table/fridge; raw user sources stay in scratch."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_grass import lua


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def source_part(sub, texture, selected=None):
    triangles=sub.triangles if selected is None else selected
    used=sorted(set(i for tri in triangles for i in tri))
    mapping={n:i+1 for i,n in enumerate(used)}
    return dict(name='source_'+sub.material,
        vertices=[list(sub.positions[n])+[sub.uv0[n][0],1-sub.uv0[n][1],1] for n in used],
        indices=[mapping[i] for tri in triangles for i in tri],
        texture=texture, colors=[[1,1,1,sub.colors[n][3]] for n in used] if sub.colors else [[1,1,1,1]]*len(used),
        role='source_house_furniture',alphaMode='cutout',opacity=1,wrapS='repeat',wrapT='repeat')


def close_rims(part, expected, sample):
    """Close only reviewed boundary loops along their original source rims."""
    points={}
    edges=collections.Counter()
    direction={}
    rows=part['vertices']
    for at in range(0,len(part['indices']),3):
        ids=part['indices'][at:at+3]
        ps=[]
        for i in ids:
            key=tuple(round(v,4) for v in rows[i-1][:3])
            points.setdefault(key,rows[i-1][:3]);ps.append(key)
        for a,b in zip(ps,ps[1:]+ps[:1]):
            key=tuple(sorted((a,b)));edges[key]+=1;direction[key]=(a,b)
    adjacent={}
    for edge,count in edges.items():
        need(count<=2,'nonmanifold source rim')
        if count==1:
            a,b=direction[edge]
            need(a not in adjacent,'branching source rim')
            adjacent[a]=b
    loops=[]
    while adjacent:
        start=next(iter(adjacent));loop=[];at=start
        while True:
            loop.append(at);at=adjacent.pop(at)
            if at==start:break
            need(len(loop)<=128,'source rim failed to close')
        loops.append(loop)
    need(sorted(map(len,loops))==sorted(expected),'reviewed source open rims changed')
    closures=[]
    for number,loop in enumerate(loops):
        ps=[points[v] for v in loop]
        # Table's 20-corner underside follows its original scalloped rim.
        # Its four low points remain on the source outline; the interior
        # underside meets the tabletop's broad underside plane.
        center=[sum(v[k] for v in ps)/len(ps) for k in range(3)]
        if len(loop)==20:
            need(max(v[1] for v in ps)-min(v[1] for v in ps)<3.56,'table apron changed')
            center[1]=max(v[1] for v in ps)
        elif len(loop)==10:
            # The original open stacked book has a stepped lower rim. The
            # closure follows that rim down to its existing lowest plane.
            need(max(v[1] for v in ps)-min(v[1] for v in ps)<.695,'book cover rim changed')
            center[1]=min(v[1] for v in ps)
        else:
            need(max(v[1] for v in ps)-min(v[1] for v in ps)<.001,'unreviewed nonhorizontal source rim')
        uv=[(sample[0]+.5)/64,(sample[1]+.5)/64]
        vs=[center+uv+[1]]+[list(p)+uv+[1]for p in ps]
        # Oppose each original directed edge; no source triangles are edited.
        indices=[]
        for i in range(len(ps)):
            indices.extend([1,(i+1)%len(ps)+2,i+2])
        cap={k:v for k,v in part.items()if k not in ('vertices','indices','colors')}
        cap.update(name='authored_rim_closure_'+str(number),vertices=vs,indices=indices,
            colors=[[1,1,1,1]]*len(vs),authored=True)
        closures.append(cap)
    return closures


def normalized(parts):
    vs=[v for p in parts for v in p['vertices']]
    b=[min(v[k]for v in vs)for k in range(3)]+[max(v[k]for v in vs)for k in range(3)]
    o=[(b[0]+b[3])/2,b[1],(b[2]+b[5])/2];span=b[3]-b[0]
    for p in parts:
        for v in p['vertices']:
            for k in range(3):v[k]=(v[k]-o[k])/span
    return dict(parts=parts,anchors={},revision=1),dict(sourceBounds=b,origin=o,uniformDivisor=span)


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    import sys
    load,load_textures,png=decoder(decoder_path)
    raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(m.name=='t101r0101_00_00' and not m.bones and len(m.submeshes)==31,'unreviewed original Littleroot room')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    original=open_bch(raw).models[0]
    selected={'oras_littleroot_dining_table':(18,'table01',[20]+[4]*8,(32,0)),
              'oras_littleroot_fridge':(8,'ref01',[14],(40,54))}
    bank={t.name:t for t in load_textures(blob)};models={};proof={};textures={}
    folder=output/'assets/scenery/oras-home-furniture';folder.mkdir(parents=True,exist_ok=True)
    for name,(index,material,rims,sample)in selected.items():
        sub=m.submeshes[index];other=original.meshes[index]
        need(sub.material==material and sub.positions==other.positions and sub.uv0==other.texcoords,'independent source positions/UV differ')
        need(len(other.submeshes)==1 and [i for tri in sub.triangles for i in tri]==other.submeshes[0].indices,'independent source indices differ')
        mat=next(mat for mat in m.materials if mat.name==material)
        need(mat.base_color_texture==material,'source material binding changed')
        t=bank[material];need((t.width,t.height)==(64,64),'source material size changed')
        need(set(t.rgba[3::4])=={255},'unreviewed source transparency')
        target='assets/scenery/oras-home-furniture/'+material+'.png'
        part=source_part(sub,target);caps=close_rims(part,rims,sample)
        parts=[part,*caps]
        detail_proof={}
        if name=='oras_littleroot_dining_table':
            books=m.submeshes[9];other_books=original.meshes[9]
            need(books.material=='books02' and books.positions==other_books.positions and books.uv0==other_books.texcoords,'independent source book positions/UV differ')
            need(len(other_books.submeshes)==1 and [i for tri in books.triangles for i in tri]==other_books.submeshes[0].indices,'independent book indices differ')
            selected_book=[tri for tri in books.triangles if all(-199<=books.positions[n][0]<=-161 and -91<=books.positions[n][2]<=-53 for n in tri)]
            need(len(selected_book)==28,'reviewed original tabletop book changed')
            book=source_part(books,'assets/scenery/oras-home-furniture/books02.png',selected_book)
            book_caps=close_rims(book,[10],(51,51));parts.extend([book,*book_caps])
            bt=bank['books02'];need((bt.width,bt.height)==(64,64)and set(bt.rgba[3::4])=={255},'source book material changed')
            content=png(bt.rgba,bt.width,bt.height);(folder/'books02.png').write_bytes(content)
            textures['books02']=dict(size=[bt.width,bt.height],rgbaSha256=sha(bt.rgba),pngSha256=sha(content))
            detail_proof=dict(sourceBookTriangles=28,bookClosureTriangles=10,bookRimSizes=[10])
        models[name],meta=normalized(parts)
        content=png(t.rgba,t.width,t.height);(folder/(material+'.png')).write_bytes(content)
        textures[material]=dict(size=[t.width,t.height],rgbaSha256=sha(t.rgba),pngSha256=sha(content))
        proof[name]=dict(**meta,sourceMaterial=material,sourceSubmesh=index,
            sourceTriangles=len(sub.triangles),closureTriangles=sum(len(p['indices'])//3 for p in caps),
            reviewedRimSizes=rims,**detail_proof)
    (output/'lib/ImportedHomeFurnitureData.lua').write_text('-- Genuine ORAS Littleroot furniture; generated by tools/import_oras_home_furniture.py.\nreturn '+lua(models)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',
        originalGameArt='Nintendo / Creatures / GAME FREAK',
        nativeLink='ZO223 -> AD112 -> MM164 -> GR506',model='t101r0101_00_00',
        modelBchSha256=sha(raw),textureBchSha256=sha(blob),textures=textures,components=proof,
        independentValidation='Every selected position, UV0 and triangle index agrees with Nitrogen; room is unskinned.',
        processing='Original geometry, source texture RGBA and UVs retained. Only separately identified underside/leg rim closures added. Source vertex RGB is white to remove baked lighting; renderer owns lighting and shadows. Uniform normalization; native adapter preserves proportions and blocked footprints. Room, floor, shadow and light meshes excluded.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return models


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['model','textures','decoder','nitrogen','output']:p.add_argument(name,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output).items():
        print(name,len(m['parts']),sum(len(p['indices'])//3 for p in m['parts']))
