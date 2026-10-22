#!/usr/bin/env python3
"""Prepare the genuine ORAS BM0006 truck, without source shadow overlays."""
import argparse, collections, hashlib, json, math, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_grass import lua

ID='oras_opening_truck'
MATERIALS={'trackMAT':'track','pasted__trackMAT':'in','pasted__trackMAT1':'track'}

def sha(data): return hashlib.sha256(data).hexdigest()

def undersides(part, source):
    edges=collections.Counter();points={}
    def key(n):
        p=source.positions[n];k=tuple(round(v,4) for v in p);points[k]=n;return k
    for tri in source.triangles:
        p=[key(n) for n in tri]
        for a,b in zip(p,p[1:]+p[:1]):
            if a!=b:edges[tuple(sorted((a,b)))]+=1
    out=[]
    for height,count in ((6.76161,4),(17.6783,6)):
        adj=collections.defaultdict(list)
        for (a,b),n in edges.items():
            if n==1 and abs(a[1]-height)<.001 and abs(b[1]-height)<.001:adj[a].append(b);adj[b].append(a)
        need(len(adj)==count and all(len(v)==2 for v in adj.values()),'reviewed truck underside rim changed')
        loop=[];previous=None;current=min(adj)
        while current not in loop:
            loop.append(current);ns=sorted(v for v in adj[current] if v!=previous);previous,current=current,ns[0]
        need(len(loop)==count and current==loop[0],'truck underside rim is not closed')
        area=sum(a[0]*b[2]-b[0]*a[2] for a,b in zip(loop,loop[1:]+loop[:1]))
        if area<0:loop.reverse()
        rows=[part['vertices'][points[p]][:] for p in loop]
        indices=[]
        for i in range(1,len(loop)-1):indices.extend([1,i+1,i+2])
        closed={k:v for k,v in part.items() if k not in ('vertices','indices','colors')}
        closed.update(name='authored_underside_'+str(count),vertices=rows,indices=indices,authored=True)
        out.append(closed)
    return out

def convert(model_path, texture_path, decoder_path, nitrogen_path, output):
    load,load_textures,png=decoder(decoder_path)
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0];second=open_bch(raw).models[0]
    need(m.name=='t101_bm_truck' and len(m.submeshes)==5,'unexpected original truck model')
    need([b.name for b in m.bones]==['sptrack','locator1','polySurface63'],'unexpected original truck bones')
    for i,b in enumerate(m.bones):
        need(all(abs(v)<1e-8 for v in b.translation+b.rotation) and all(v==1 for v in b.scale),'truck bind is not identity')
        n=second.skeleton[i];need(n.name==b.name and n.parent==(-1 if i==0 else 0),'independent truck skeleton changed')
        need(max(abs(v-(k in (0,5,10,15))) for k,v in enumerate(n.inverse_bind))<1e-8,'independent inverse bind differs')
    parts=[];colors=[];excluded={}
    for i,s in enumerate(m.submeshes):
        n=second.meshes[i];draw=n.submeshes[0]
        need(s.positions==n.positions and s.uv0==n.texcoords,'independent source positions/UVs differ')
        need([v for t in s.triangles for v in t]==draw.indices and draw.bone_indices==[1] and draw.skinning==2,'independent rigid triangle binding differs')
        if s.material not in MATERIALS:
            need(s.material in ('pasted__kageMAT','shadow1'),'unreviewed truck material')
            excluded[s.material]=len(s.triangles);continue
        need(s.uv0 and all(b==[1] for b in s.bones) and all(w==[1.] for w in s.weights),'missing truck UV/rigid binding')
        rows=[]
        for j,p in enumerate(s.positions):
            c=list(s.colors[j]) if s.colors else [1.,1.,1.,1.];colors.append(c)
            rows.append(list(p)+[s.uv0[j][0],1-s.uv0[j][1],1.,1.,1.,1.,c[3]])
        parts.append(dict(name=s.material,texture=MATERIALS[s.material]+'.png',vertices=rows,
            indices=[n+1 for t in s.triangles for n in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
    need([len(p['indices'])//3 for p in parts]==[1642,86,376] and excluded=={'pasted__kageMAT':136,'shadow1':54},'truck source topology changed')
    parts.extend(undersides(parts[0],m.submeshes[0]))
    # The actual source underbody edge proves the longitudinal heading. A rigid
    # Y rotation aligns the cabin left, matching native graphics94, without skew.
    dx,dz=22.218199,68.899661;length=math.hypot(dx,dz);a,b=dx/length,dz/length
    for p in parts:
        for v in p['vertices']:v[0],v[2]=a*v[0]+b*v[2],-b*v[0]+a*v[2]
    allv=[v for p in parts for v in p['vertices']]
    bounds=[min(v[k] for v in allv) for k in range(3)]+[max(v[k] for v in allv) for k in range(3)]
    span=bounds[3]-bounds[0];origin=[(bounds[0]+bounds[3])/2,bounds[1],(bounds[2]+bounds[5])/2]
    folder=output/'assets/scenery/oras-opening-truck';folder.mkdir(parents=True,exist_ok=True)
    tx={t.name:t for t in load_textures(blob)};textures={}
    for name in sorted(set(MATERIALS.values())):
        t=tx[name];need(set(t.rgba[3::4])=={255},'unreviewed truck texture alpha')
        data=png(t.rgba,t.width,t.height);(folder/(name+'.png')).write_bytes(data)
        textures[name]=dict(size=[t.width,t.height],rgbaSha256=sha(t.rgba),pngSha256=sha(data))
    for p in parts:
        p['texture']='assets/scenery/oras-opening-truck/'+p['texture'];p['colors']=[v[6:] for v in p['vertices']]
        p['vertices']=[[(v[k]-origin[k])/span for k in range(3)]+v[3:6] for v in p['vertices']]
    data=dict(parts=parts,anchors={'ground':[0.,0.,0.]})
    (output/'lib/ImportedTruckExteriorData.lua').write_text('-- Genuine ORAS BM0006; generated by tools/import_oras_truck_exterior.py.\nreturn '+lua(data)+'\n')
    report=dict(id=ID,source='User-supplied Pokemon Alpha Sapphire RomFS',model='a/0/2/3 BM0006 slot0 t101_bm_truck',texturesRecord='a/0/1/4 AD0008 slot1',originalGameArt='Nintendo / Creatures / GAME FREAK',modelBchSha256=sha(raw),textureBchSha256=sha(blob),textures=textures,
        independentValidation='All source positions, UV0, triangle indices, rigid palettes and identity inverse binds agree with Nitrogen.',sourcePhysicalTriangles=2104,authoredUndersideTriangles=6,excludedShadowTriangles=excluded,
        axisAlignment=dict(sourceRearAxis=[a,0,b],yawRadians=math.atan2(b,a),alignedBounds=bounds,uniformDivisor=span,origin=origin,canonicalCabin='-X',canonicalOpenRear='+X'),
        sourceVertexRgbRange=[min(v for c in colors for v in c[:3]),max(v for c in colors for v in c[:3])],
        processing=['All2104 physical source triangles, original PNG pixels, UVs and vertex alpha retained. Rigid rotation and uniform normalization only.','User clean-lighting preference: source baked vertex RGB tints,136 cargo-shadow overlay triangles and54 ground-shadow sheet triangles omitted.','Closed only the exact original planar4/6-vertex underside rims with6 triangles using their source edge UVs. Genuine rear loading doors remain open, including original interior cargo.'],
        limitations=['Original ORAS TEV and skeletal/texture animation are not emulated. Source bind pose has open rear doors. Native sprite actor owns visibility, position, scripts and lifetime.'])
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data,report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('model','textures','decoder','nitrogen','output'):p.add_argument('--'+name,type=Path,required=True)
    x=p.parse_args();_,r=convert(x.model,x.textures,x.decoder,x.nitrogen,x.output);print(r['id'],r['sourcePhysicalTriangles'],'source +',r['authoredUndersideTriangles'],'closed underside triangles')
