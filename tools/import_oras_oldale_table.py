#!/usr/bin/env python3
"""Prepare the original ORAS Oldale checked dining table with solid cloth."""
import argparse,collections,hashlib,json,math,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,close_rims,normalized


def solid_cloth(part,thickness):
    rows=part['vertices'];normals=collections.defaultdict(lambda:[0.,0.,0.]);edges=collections.Counter();direction={}
    key=lambda v:tuple(round(x,4)for x in v[:3])
    for i in range(0,len(part['indices']),3):
        ids=part['indices'][i:i+3];p,q,r=[rows[n-1]for n in ids]
        v=[q[k]-p[k]for k in range(3)];w=[r[k]-p[k]for k in range(3)]
        normal=[v[1]*w[2]-v[2]*w[1],v[2]*w[0]-v[0]*w[2],v[0]*w[1]-v[1]*w[0]]
        need(normal[1]>0,'source cloth orientation changed')
        for n in ids:
            at=normals[key(rows[n-1])]
            for k in range(3):at[k]+=normal[k]
        for a,b in zip(ids,ids[1:]+ids[:1]):
            edge=tuple(sorted((key(rows[a-1]),key(rows[b-1]))));edges[edge]+=1;direction[edge]=(a,b)
    inner=[]
    for row in rows:
        n=normals[key(row)];ln=math.sqrt(sum(v*v for v in n));need(ln>0,'degenerate cloth surface')
        inner.append([row[k]-n[k]/ln*thickness for k in range(3)]+row[3:])
    back={k:v for k,v in part.items()if k not in ('vertices','indices','colors')}
    back.update(name='authored_original_cloth_inner_surface',vertices=inner,
        indices=[part['indices'][i+j]for i in range(0,len(part['indices']),3)for j in (2,1,0)],
        colors=[[1,1,1,1]]*len(inner),authored=True)
    rim={k:v for k,v in back.items()if k not in ('vertices','indices','colors')}
    rim.update(name='authored_original_cloth_thin_rim',vertices=[],indices=[],colors=[])
    count=0
    for edge,n in edges.items():
        need(n<=2,'nonmanifold source cloth')
        if n!=1:continue
        a,b=direction[edge];start=len(rim['vertices'])
        rim['vertices'].extend([list(rows[b-1]),list(rows[a-1]),list(inner[a-1]),list(inner[b-1])])
        rim['colors'].extend([[1,1,1,1]]*4);rim['indices'].extend(start+n for n in [1,2,3,1,3,4]);count+=1
    need(count==12,'reviewed original cloth rim changed')
    return [back,rim]


def convert(model_path,texture_path,decoder_path,nitrogen_path,output,neighbor_path=None):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(m.name=='t102r0101_00_00'and not m.bones,'unreviewed original Oldale house')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    original=open_bch(raw).models[0];bank={t.name:t for t in load_textures(blob)};textures={}
    folder=output/'assets/scenery/oras-oldale-table';folder.mkdir(parents=True,exist_ok=True)
    def build(model,independent,neighbor=False):
        parts=[];body_index,cloth_index=(15,16)if neighbor else(13,14)
        cloth=model.submeshes[cloth_index]
        lo=[min(v[k]for v in cloth.positions)for k in range(3)];hi=[max(v[k]for v in cloth.positions)for k in range(3)]
        for index,material,triangles in [(body_index,'t102_table01',472 if neighbor else 236),(cloth_index,'t102_table01_o',84)]:
            s=model.submeshes[index];n=independent.meshes[index];body=index==body_index
            need(s.material==material and len(s.triangles)==triangles,'reviewed source component changed')
            need(s.positions==n.positions and s.uv0==n.texcoords,'independent source positions/UV differ')
            need(len(n.submeshes)==1 and [i for tri in s.triangles for i in tri]==n.submeshes[0].indices,'independent source indices differ')
            mat=next(mat for mat in model.materials if mat.name==material);need(mat.base_color_texture==material,'source material binding changed')
            # The second house batches its wall table and dining table into
            # one mesh. Only the dining table under the original cloth fits
            # the native furniture identity; do not import the extra desk.
            selected=[tri for tri in s.triangles if all(lo[0]-.01<=s.positions[n][0]<=hi[0]+.01 and lo[2]-.01<=s.positions[n][2]<=hi[2]+.01 for n in tri)]if neighbor and body else s.triangles
            need(len(selected)==(236 if body else 84),'reviewed dining table selection changed')
            part=source_part(s,'assets/scenery/oras-oldale-table/'+material+'.png',selected);parts.append(part)
            if body:parts.extend(close_rims(part,[12,8,8]+[4]*8,(24,24)))
            else:parts.extend(solid_cloth(part,.12))
            t=bank[material];need(collections.Counter(t.rgba[3::4])==({255:4096}if body else{255:3840,0:256}),'unreviewed source table alpha')
            content=png(t.rgba,t.width,t.height);(folder/(material+'.png')).write_bytes(content)
            textures[material]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest())
        return normalized(parts)
    model,meta=build(m,original);data={'oras_oldale_checked_table':model};neighbor_proof=None
    if neighbor_path is not None:
        neighbor_raw=neighbor_path.read_bytes();neighbor=load(neighbor_raw)[0]
        need(neighbor.name=='t102r0201_00_00'and not neighbor.bones,'unreviewed original neighbor house')
        data['oras_oldale_neighbor_table'],neighbor_meta=build(neighbor,open_bch(neighbor_raw).models[0],True)
        neighbor_proof=dict(nativeLink='ZO231 -> AD115 -> MM172 -> GR514',model=neighbor.name,
            modelBchSha256=hashlib.sha256(neighbor_raw).hexdigest(),**neighbor_meta,
            sourceDiningTableTriangles=320,authoredClosureTriangles=168,
            selection='Original main dining table and complete cloth only; separate wall table excluded.')
    (output/'lib/ImportedOldaleFurnitureData.lua').write_text('-- Genuine ORAS Oldale table; generated by tools/import_oras_oldale_table.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',
        nativeLink='ZO230 -> AD115 -> MM171 -> GR513',model=m.name,
        modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textures=textures,**meta,
        originalTriangles=320,authoredClosureTriangles=168,neighbor=neighbor_proof,
        independentValidation='Original selected positions, UV0 and triangle indices agree with Nitrogen. Source is unskinned.',
        processing='Original table body and complete checked cloth retained. Source table/leg rims closed independently. Cloth gets a 0.12-source-unit inner surface and thin boundary rim rather than a solid slab below the hanging fabric. Source vertex RGB is white; source shadows, floor and lights excluded. Uniform native footprint fit; original texture RGBA/UV unchanged.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return data


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    p.add_argument('--neighbor-model',type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output,a.neighbor_model).items():print(name,sum(len(p['indices'])//3 for p in m['parts']))
