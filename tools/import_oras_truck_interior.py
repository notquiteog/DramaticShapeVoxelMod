#!/usr/bin/env python3
"""Prepare physical cargo and clean finishes from original ORAS GR0653."""
import argparse, collections, hashlib, json, math, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_grass import lua

PREFIX='oras_truck_'

def sha(raw):return hashlib.sha256(raw).hexdigest()

def component(sub,triangles,name,texture):
    selected=sorted(set(n for ti in triangles for n in sub.triangles[ti]));mapping={n:i+1 for i,n in enumerate(selected)}
    vertices=[];colors=[]
    for n in selected:
        uv=sub.uv0[n];c=sub.colors[n] if sub.colors else [1.,1.,1.,1.]
        vertices.append(list(sub.positions[n])+[uv[0],1-uv[1],1.]);colors.append([1.,1.,1.,c[3]])
    return dict(name=name,vertices=vertices,indices=[mapping[n] for ti in triangles for n in sub.triangles[ti]],colors=colors,
        texture=texture,role='source_truck_cargo',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat')

def close_box(part):
    rows=part['vertices'];points={tuple(round(v,4) for v in row[:3]):i for i,row in enumerate(rows)}
    need(len(points)==8,'source carton is no longer an eight-corner box')
    bounds=[min(p[k] for p in points) for k in range(3)]+[max(p[k] for p in points) for k in range(3)]
    added=[]
    for axis in range(3):
        for side in (0,1):
            at=bounds[axis+side*3]
            face=[p for p in points if abs(p[axis]-at)<.001]
            need(len(face)==4,'source carton is not axis-aligned')
            present=any(all(abs(rows[part['indices'][j+i]-1][axis]-at)<.001 for i in range(3)) for j in range(0,len(part['indices']),3))
            if present:continue
            other=[k for k in range(3) if k!=axis];center=[sum(p[k] for p in face)/4 for k in range(3)]
            face.sort(key=lambda p:math.atan2(p[other[1]]-center[other[1]],p[other[0]]-center[other[0]]))
            a=[face[1][k]-face[0][k] for k in range(3)];b=[face[2][k]-face[0][k] for k in range(3)]
            cross=[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
            if cross[axis]*(1 if side else -1)<0:face.reverse()
            opposite=bounds[axis+(1-side)*3]
            source_tri=[part['indices'][j:j+3] for j in range(0,len(part['indices']),3)
                if all(abs(rows[part['indices'][j+i]-1][axis]-opposite)<.001 for i in range(3))]
            pool=sorted(set(n-1 for t in source_tri for n in t));need(pool,'opposite source carton face unavailable')
            vertices=[]
            for point in face:
                match=next(n for n in pool if all(abs(rows[n][k]-point[k])<.001 for k in other))
                vertices.append(list(point)+rows[match][3:])
            cap={k:v for k,v in part.items() if k not in ('vertices','indices','colors')}
            cap.update(name='authored_carton_closure_'+str(axis)+'_'+str(side),vertices=vertices,indices=[1,2,3,1,3,4],colors=[[1.,1.,1.,1.]]*4,authored=True)
            added.append(cap)
    need(len(added)==2,'reviewed two missing carton faces changed');return added

def normalize(parts):
    vs=[v for p in parts for v in p['vertices']]
    b=[min(v[k] for v in vs) for k in range(3)]+[max(v[k] for v in vs) for k in range(3)]
    origin=[(b[0]+b[3])/2,b[1],(b[2]+b[5])/2];span=b[3]-b[0]
    for p in parts:
        p['texture']='assets/scenery/oras-truck-interior/'+p['texture']+'.png'
        for v in p['vertices']:
            for k in range(3):v[k]=(v[k]-origin[k])/span
    return dict(parts=parts),dict(bounds=b,origin=origin,uniformDivisor=span)

def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    n=open_bch(raw).models[0];need(m.name=='sptruck_00_00' and not m.bones and len(m.submeshes)==13,'unreviewed original truck room')
    for s,t in zip(m.submeshes,n.meshes):
        need(s.positions==t.positions and s.uv0==t.texcoords,'independent truck-room positions/UVs differ')
        need(len(t.submeshes)==1 and [v for tri in s.triangles for v in tri]==t.submeshes[0].indices,'independent source indices differ')
    shelf=m.submeshes[7];need(shelf.material=='shelf02','source furniture material changed')
    groups={'north':[],'south':[],'wrapped':[]}
    for i,tri in enumerate(shelf.triangles):
        ps=[shelf.positions[n] for n in tri];x=sum(p[0] for p in ps)/3;z=sum(p[2] for p in ps)/3
        group='wrapped' if x < -285 else 'north' if z < -300 else 'south';groups[group].append(i)
    need({k:len(v) for k,v in groups.items()}=={'north':312,'south':288,'wrapped':42},'source furniture component boundaries changed')
    data={};proof={}
    for name in ('north','south'):
        p=component(shelf,groups[name],'source_'+name+'_dresser','shelf02')
        data[PREFIX+name+'_dresser'],proof[name]=normalize([p])
    box=m.submeshes[4];need(box.material=='box1','source carton material changed')
    selected=[i for i,tri in enumerate(box.triangles) if all(1.50<=box.positions[n][1]<=12.35 and box.positions[n][2]<-300 for n in tri)]
    need(len(selected)==8,'reviewed native-aligned carton changed')
    carton=component(box,selected,'source_cardboard_box','box');need(all(c[3]==1 for c in carton['colors']),'unreviewed carton alpha')
    closures=close_box(carton);data[PREFIX+'cardboard_box'],proof['box']=normalize([carton,*closures])
    # These retained original meshes establish the finish/UV provenance. Room
    # boundaries and clean floor are adapted separately to the native layout.
    floor=m.submeshes[2];wall=m.submeshes[3]
    floor_tri=[i for i,tri in enumerate(floor.triangles) if all(abs(floor.positions[n][1])<1e-7 for n in tri)]
    need(len(floor_tri)==16,'source flat floor component changed')
    mats=[component(floor,floor_tri,'source_clean_floor','yuka'),component(wall,list(range(len(wall.triangles))),'source_metal_panels','wall01')]
    data[PREFIX+'room_materials'],proof['finishes']=normalize(mats)
    folder=output/'assets/scenery/oras-truck-interior';folder.mkdir(parents=True,exist_ok=True)
    tx={t.name:t for t in load_textures(blob)};textures={}
    for name in ('box','shelf02','wall01','yuka'):
        t=tx[name];need(set(t.rgba[3::4])=={255},'unreviewed physical truck texture alpha')
        raw_png=png(t.rgba,t.width,t.height);(folder/(name+'.png')).write_bytes(raw_png)
        textures[name]=dict(size=[t.width,t.height],rgbaSha256=sha(t.rgba),pngSha256=sha(raw_png))
    payload=dict(models=data,wallRepeatAt40=(120.68598937988281/4.005342900753021)*40/43.0806999206543,
        floorUv=[.3153809905052185,1.,1.0013799667358398,.0006840229034423828])
    (output/'lib/ImportedTruckInteriorData.lua').write_text('-- Genuine ORAS GR0653 physical cargo/finishes; generated by tools/import_oras_truck_interior.py.\nreturn '+lua(payload)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO399 (also535) -> AD180 -> MM302 -> GR653',model='a/0/3/9 GR0653 slot1 sptruck_00_00',textureRecord='a/0/1/4 AD0180 slot11',modelBchSha256=sha(raw),textureBchSha256=sha(blob),textures=textures,
        independentValidation='Every original submesh position, UV0 and triangle index agrees with Nitrogen; room is unskinned.',components=proof,sourceSelectedCargoTriangles=608,authoredCartonClosureTriangles=4,sourceFinishTriangles=27,
        processing=['Native north/south cargo uses the original312/288-triangle strapped dressers. The original8-triangle cardboard box gains only its exact two missing rectangular faces, reusing opposite source-face UVs.','All selected source positions/UVs retained; independent component normalization is uniform. Static placement fits only reviewed native blocked cargo cells. Original texture PNG pixels and vertex alpha retained, baked vertex RGB tint removed per user preference.','The original flat-floor16 triangles and metal-panel11 triangles are retained as finish provenance. Runtime floor is one clean native80x80 plane with the original broad corrugated yuka UV band; native boundaries receive continuous original wall01 panels.'],
        exclusions=['No Azurill toy, plant or wrapped wardrobe substitutes for a native cardboard box. No floor-light effect, source shadow decal, untextured entrance-light plane or original source baked vertex RGB tint.','Raw ORAS room footprint differs from native RSE: original furniture is individually fitted; original collision/warps/scripts/animation are not moved to fit the source map.'],
        wallRepeatAt40=payload['wallRepeatAt40'],cleanFloorUv=payload['floorUv'])
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return payload,report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('model','textures','decoder','nitrogen','output'):p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();_,r=convert(a.model,a.textures,a.decoder,a.nitrogen,a.output);print('GR653:',r['sourceSelectedCargoTriangles'],'source cargo +4 closure;27 source finish triangles')
