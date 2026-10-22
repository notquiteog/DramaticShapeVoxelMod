#!/usr/bin/env python3
"""Prepare BM0086 Briney's boat from explicit local ORAS BCH inputs.

External decoder checkouts and game files are never bundled or downloaded.
Only the inspected rigid translation skeleton is accepted; stored inverse binds
are independently read through Nitrogen before any vertex is baked.
"""
import argparse, collections, hashlib, json, math, struct, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_grass import lua

ID='oras_briney_boat'
TEXTURES={'Comb7':'hagiship_01','Comb8':'hagiship_02','Comb9':'hagiship_03'}
BONES=['com_bm_boat01','body','floor','hamon','parts_a','parts_b','parts_c','room']

def sha(b):return hashlib.sha256(b).hexdigest()

def bake(model, nitrogen_model):
    need(model.name=='com_bm_boat01' and len(model.bones)==8,'unexpected boat model/skeleton')
    need([b.name for b in model.bones]==BONES,'unexpected source bone identities')
    need([b.name for b in nitrogen_model.skeleton]==BONES,'independent skeleton identities differ')
    global_t=[];errors=[]
    for i,b in enumerate(model.bones):
        need(all(abs(v)<1e-8 for v in b.rotation)and all(abs(v-1)<1e-8 for v in b.scale),'nontranslation bind pose not reviewed')
        parent=BONES.index(b.parent)if b.parent else None
        need(parent is None or parent<i,'unexpected bone hierarchy')
        t=[b.translation[k]+(global_t[parent][k]if parent is not None else 0)for k in range(3)]
        inv=[1.,0.,0.,-t[0],0.,1.,0.,-t[1],0.,0.,1.,-t[2],0.,0.,0.,1.]
        nb=nitrogen_model.skeleton[i]
        need(nb.parent==(-1 if parent is None else parent),'independent bone hierarchy differs')
        error=max(abs(a-b)for a,b in zip(inv,nb.inverse_bind));need(error<1e-5,'stored inverse bind does not match rigid translation')
        errors.append(error);global_t.append(t)
    parts=[];ripple=0;source_colors=[]
    need(len(model.submeshes)==len(nitrogen_model.meshes)==8,'independent source mesh count differs')
    for i,s in enumerate(model.submeshes):
        need(len(s.positions)==len(s.uv0)==len(s.bones)==len(s.weights),'missing source position/UV/rigid binding')
        independent=nitrogen_model.meshes[i]
        need(s.positions==[list(v)for v in independent.positions]or s.positions==independent.positions,'independent source positions differ')
        need(s.uv0==[list(v)for v in independent.texcoords]or s.uv0==independent.texcoords,'independent source UVs differ')
        need(len(independent.submeshes)==1 and independent.submeshes[0].skinning==2 and independent.submeshes[0].primitive_mode==0,'independent source is not rigid triangles')
        draw=independent.submeshes[0]
        need([n for t in s.triangles for n in t]==draw.indices,'independent source triangles differ')
        if s.material=='pasted__hamon':ripple+=len(s.triangles);continue
        need(s.material in TEXTURES,'unreviewed boat material')
        rows=[]
        for j,p in enumerate(s.positions):
            need(len(s.bones[j])==1 and s.weights[j]==[1.0],'weighted boat skin not reviewed')
            bone=s.bones[j][0];need(0<=bone<len(global_t),'bone index outside skeleton')
            need(draw.bone_indices==[bone],'independent rigid bone binding differs')
            xyz=[p[k]+global_t[bone][k]for k in range(3)]
            color=list(s.colors[j])if s.colors else[1.,1.,1.,1.]
            need(len(color)==4 and all(0<=v<=1 for v in color),'unreviewed vertex color')
            source_colors.append(color)
            # User-requested unlit source paint: remove baked vertex AO only.
            # Original texture pixels/UV and vertex alpha remain authoritative.
            rows.append(xyz+list(s.uv0[j])+[1.,1.,1.,1.,color[3]])
        indices=[n for t in s.triangles for n in t]
        need(all(0<=n<len(rows)for n in indices),'invalid source triangle')
        parts.append({'name':f'source_{i}_{s.material}','material':s.material,'texture':TEXTURES[s.material]+'.png',
            'vertices':rows,'indices':[n+1 for n in indices],'role':'structure','alphaMode':'cutout','opacity':1.,'wrapS':'repeat','wrapT':'repeat'})
    need(len(parts)==7 and sum(len(p['indices'])//3 for p in parts)==936 and ripple==66,'source topology changed')
    packed=struct.pack('<'+str(len(source_colors)*4)+'f',*(v for c in source_colors for v in c))
    return parts,{'bones':BONES,'globalBindTranslations':global_t,'inverseBindMaxError':max(errors),
        'independentPositionsUvIndicesAndRigidPalettesEqual':True,'sourceTriangles':936,'excludedWaterRippleTriangles':ripple,
        'vertexLightingCleanup':{'originalFloatRgbaSha256':sha(packed),'sourceVertices':len(source_colors),
            'originalRgbRange':[min(v for c in source_colors for v in c[:3]),max(v for c in source_colors for v in c[:3])],
            'changedRgbVertices':sum(c[:3]!=[1.,1.,1.]for c in source_colors),
            'processing':'User-requested RGB=1 removes source baked vertex AO; original vertex alpha and texture pixels retained.'}}


def close_hull(parts):
    # The lower hull has an18-vertex planar open keel rim. Close that exact
    # underside; deck, cabin, real openings and every original face stay intact.
    source=parts[1];need(source['material']=='Comb7' and len(source['indices'])==120,'unexpected lower hull')
    rows=source['vertices'];edges=collections.Counter();points={}
    def key(i):
        p=rows[i-1];k=tuple(round(v,4)for v in p[:3]);points[k]=p;return k
    for i in range(0,len(source['indices']),3):
        tri=[key(n)for n in source['indices'][i:i+3]]
        for a,b in zip(tri,tri[1:]+tri[:1]):edges[tuple(sorted((a,b)))]+=1
    lowest=min(p[1]for p in rows);adj=collections.defaultdict(list)
    for (a,b),count in edges.items():
        if count==1 and abs(a[1]-lowest)<1e-4 and abs(b[1]-lowest)<1e-4:adj[a].append(b);adj[b].append(a)
    need(len(adj)==18 and all(len(v)==2 for v in adj.values()),'unreviewed open keel boundary')
    loop=[];current=min(adj);previous=None
    while current not in loop:
        loop.append(current);ns=sorted(v for v in adj[current]if v!=previous);previous,current=current,ns[0]
    need(len(loop)==18 and current==loop[0],'keel boundary is not one closed ring')
    area=sum(a[0]*b[2]-b[0]*a[2]for a,b in zip(loop,loop[1:]+loop[:1]))
    if area<0:loop.reverse()
    # Retain the lower hull's actual dark bottom-edge texel and source color.
    swatch=points[loop[0]][3:];vertices=[points[p][:3]+swatch for p in loop]
    indices=[]
    for i in range(1,len(loop)-1):indices.extend([1,i+1,i+2])
    out={k:v for k,v in source.items()if k not in('vertices','indices')}
    out.update(name='authored_keel_underside',vertices=vertices,indices=indices,authored=True)
    parts.append(out)
    return {'planarKeelVertices':18,'authoredTriangles':16,'rawKeelY':lowest,'sourceHullBottomUv':swatch[:2],
            'note':'Only the missing underside at the exact lower-hull rim is closed. Original source deck/cabin/openings remain unchanged.'}


def convert(model_path, textures_path, decoder_path, nitrogen_path, output):
    load,read_textures,png=decoder(decoder_path)
    sys.path.insert(0,str(Path(nitrogen_path).resolve()))
    from nitrogen.platforms.ctr.bch import open_bch
    need(Path(sys.modules['nitrogen'].__file__).resolve().is_relative_to(Path(nitrogen_path).resolve()),'unexpected independent decoder module')
    raw=Path(model_path).read_bytes();blob=Path(textures_path).read_bytes();models=load(raw);second=open_bch(raw).models
    need(len(models)==len(second)==1,'unexpected source model count')
    parts,proof=bake(models[0],second[0]);closure=close_hull(parts)
    texture_map={t.name:t for t in read_textures(blob)}
    folder=output/'assets/scenery/oras-briney-boat';folder.mkdir(parents=True,exist_ok=True)
    texture_proof={}
    for name in TEXTURES.values():
        need(name in texture_map,'missing original boat texture '+name);t=texture_map[name]
        need(set(t.rgba[3::4])=={255},'unreviewed source boat alpha')
        data=png(t.rgba,t.width,t.height);(folder/(name+'.png')).write_bytes(data)
        texture_proof[name]={'size':[t.width,t.height],'decodedRgbaSha256':sha(t.rgba),'pngSha256':sha(data)}
    vertices=[v for p in parts for v in p['vertices']]
    bounds=[min(v[k]for v in vertices)for k in range(3)]+[max(v[k]for v in vertices)for k in range(3)]
    span=bounds[3]-bounds[0];cx=(bounds[0]+bounds[3])/2;cz=(bounds[2]+bounds[5])/2;y0=bounds[1]
    need(span>100 and bounds[4]>30 and y0<0,'unexpected boat source dimensions')
    for p in parts:
        p['texture']='assets/scenery/oras-briney-boat/'+p['texture'];p['colors']=[v[6:]for v in p['vertices']]
        # Y-up; rigid quarter-turn makes the original bow canonical+Z.
        p['vertices']=[[(v[2]-cz)/span,(v[1]-y0)/span,-(v[0]-cx)/span,*v[3:6]]for v in p['vertices']]
    anchors={'waterline':[0.,-y0/span,0.],'bow':[0.,-y0/span,.5],'stern':[0.,-y0/span,-.5]}
    data={'parts':parts,'anchors':anchors}
    (output/'lib').mkdir(exist_ok=True)
    (output/'lib/OrasBoatData.lua').write_text('-- Generated by tools/import_oras_boat.py; original ORAS BM0086, provenance in assets/scenery/oras-briney-boat.\nreturn '+lua(data)+'\n')
    report={'id':ID,'game':'Pokémon Omega Ruby / Alpha Sapphire','originalGameArt':'Nintendo / Creatures / GAME FREAK',
       'source':'User-supplied local decrypted ORAS RomFS; no ROM/archive/decoder bundled',
       'modelRecord':'a/0/2/3 BM0086 slot0 com_bm_boat01','textureRecord':'a/0/1/4 AD0010 or AD0012 slot1',
       'modelBchSha256':sha(raw),'texturesBchSha256':sha(blob),'textures':texture_proof,
       'sourceBounds':bounds,'sourceLength':span,'normalization':{'origin':[cx,y0,cz],'uniformDivisor':span,'axisMap':['+sourceZ','+sourceY','-sourceX'],'canonicalBow':'+Z'},
       'anchors':anchors,'rigidBindProof':proof,'authoredClosure':closure,
       'processing':['Validated all8 identity-rotation/scale bind transforms against independently decoded stored inverse binds; baked source rigid translations.',
          'Retained all936 original structural triangles, UV0 coordinates, repeat samplers, vertex alpha and decoded source texture pixels. User-requested RGB=1 removes original baked vertex AO; source lighting statistics/hash recorded.',
          'Excluded only the separate66-triangle hamon ripple/water sheet; native water/wake/gameplay remains authoritative.',
          'Closed the original planar18-vertex keel rim with16 underside triangles inside source bounds. Uniform normalization and rigid quarter-turn only.'],
       'limitations':['Original PICA lighting/TEV and boat skeletal/texture animation are not emulated. Geometry uses the source bind pose. No native scripts, actors, collisions or paths are changed by this data module.']}
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return data,report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('model','textures','decoder','nitrogen','output'):p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();_,proof=convert(a.model,a.textures,a.decoder,a.nitrogen,a.output)
    print(ID,'source936 + underside16 triangles; bow+Z; waterline',proof['anchors']['waterline'])
