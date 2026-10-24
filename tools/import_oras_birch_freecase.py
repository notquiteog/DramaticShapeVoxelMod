#!/usr/bin/env python3
"""Original ORAS freestanding case, forty-four books and independent carton."""
import argparse,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components,merge_parts
from import_oras_oldale_sink import rims
from import_oras_flower_bookcase import cap


def pack(groups,sub):
    """Separate intersecting original book groups inside each original bay.

    Whole groups translate only in X. Their original leaning angles, internal
    geometry, proportions, colored PNG and UVs remain unchanged.
    """
    bins={};bounds={};shifts={}
    for start,g in groups.items():
        ps=[sub.positions[n]for i in g for n in sub.triangles[i]];lo=min(v[0]for v in ps);hi=max(v[0]for v in ps);row=min(v[1]for v in ps)>20;right=(lo+hi)/2>-179.55
        bins.setdefault((row,right),[]).append(start);bounds[start]=(lo,hi)
    for (_,right),ids in bins.items():
        left,last=(-177.55780029296875,-147.55780029296875)if right else(-211.53419494628906,-181.53419494628906)
        ids.sort(key=lambda k:bounds[k][0]);width=[bounds[k][1]-bounds[k][0]for k in ids];positions=[bounds[k][0]for k in ids];gap=.01
        need(sum(width)+gap*(len(ids)-1)<last-left-.04,'original book groups cannot fit inside their original bay')
        positions[0]=max(positions[0],left+.02)
        for i in range(1,len(ids)):positions[i]=max(positions[i],positions[i-1]+width[i-1]+gap)
        positions[-1]=min(positions[-1],last-.02-width[-1])
        for i in range(len(ids)-2,-1,-1):positions[i]=min(positions[i],positions[i+1]-gap-width[i])
        positions[0]=max(positions[0],left+.02)
        for i in range(1,len(ids)):positions[i]=max(positions[i],positions[i-1]+width[i-1]+gap)
        need(positions[-1]+width[-1]<=last-.02+1e-7,'repaired books exceed their original blocked bay')
        for k,position in zip(ids,positions):shifts[k]=position-bounds[k][0]
    return shifts


def convert(model_path,texture_path,box_path,box_texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();boxraw=box_path.read_bytes();boxblob=box_texture_path.read_bytes();m=load(raw)[0];bm=load(boxraw)[0]
    need(hashlib.sha256(raw).hexdigest()=='88c0fe278846a20cb8092c275567b98f1d2a5266d7e532966ac5d87bf3a5993e','original Birch source changed')
    need(hashlib.sha256(boxraw).hexdigest()=='2e58bae81d3799663f45f8f1ebbd4cdd43b4a73941fdc0e1d762ccc420076f41','reviewed original carton changed')
    need(m.name=='t101r0301_00_00'and bm.name=='c103r0701_00_00'and not m.bones and not bm.bones,'unreviewed skinned room source')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0];bank={t.name:t for t in load_textures(blob)};parts=[];closures=[];textures={};shifts={}
    folder=output/'assets/scenery/oras-birch-freecase';folder.mkdir(parents=True,exist_ok=True)
    book_ids={64,68,72,104,108,134,138,142,146,150,166,170,174,178,182,186,190,194};case_ids={0,32,40,610,614,626,630}
    for index,wanted in[(0,book_ids),(3,case_ids)]:
        s=m.submeshes[index];q=other.meshes[index];need(s.positions==q.positions and s.uv0==q.texcoords,'independent original free-case positions/UV differ')
        need(len(q.submeshes)==1 and [n for t in s.triangles for n in t]==q.submeshes[0].indices,'independent free-case indices differ')
        groups={g[0]:g for g in components(s)if g[0]in wanted};need(set(groups)==wanted,'original free-case groups changed')
        t=bank[next(mat.base_color_texture for mat in m.materials if mat.name==s.material)];need(set(t.rgba[3::4])=={255},'reviewed opaque source changed')
        texture='assets/scenery/oras-birch-bookcase/'+t.name+'.png';selected=[s.triangles[i]for g in groups.values()for i in g];source=source_part(s,texture,selected);source['colors']=[[1,1,1,1]for _ in source['vertices']];parts.append(source)
        used=sorted({n for tri in selected for n in tri});mapping={n:i for i,n in enumerate(used)}
        if index==0:shifts=pack(groups,s)
        for start,g in sorted(groups.items()):
            p=source_part(s,texture,[s.triangles[i]for i in g]);p['colors']=[[1,1,1,1]for _ in p['vertices']];loops=rims(p)
            if index==0:
                for n in {n for i in g for n in s.triangles[i]}:source['vertices'][mapping[n]][0]+=shifts[start]
                for loop in loops:
                    for v in loop:v[0]+=shifts[start]
                need(len(loops)==1 and len(loops[0])in(6,8,16),'original open book rim changed');closures.append(cap(p,loops[0],[.5/64,.5/64],[1,1,1,1]))
            elif start==0:
                loop=loops[0];need(len(loops)==1 and len(loop)==22,'original double case rim changed');rear=min(v[2]for v in loop);bottom=min(v[1]for v in loop)
                closures.append(cap(p,[v for v in loop if abs(v[2]-rear)<1e-6],[24.5/128,24.5/128],[1,1,1,1]))
                closures.append(cap(p,[v for v in loop if abs(v[1]-bottom)<1e-6],[24.5/128,24.5/128],[1,1,1,1]))
            elif start in(32,40):
                need(sorted(map(len,loops))==[8,8,10],'original twin-bin rims changed')
                for loop in loops:
                    if len(loop)==8:closures.append(cap(p,loop,[80.5/128,80.5/128],[1,1,1,1]))
                    else:
                        rear=min(v[2]for v in loop);bottom=min(v[1]for v in loop)
                        closures.append(cap(p,[v for v in loop if abs(v[2]-rear)<1e-6],[80.5/128,80.5/128],[1,1,1,1]))
                        closures.append(cap(p,[v for v in loop if v[1]<bottom+.00002],[80.5/128,80.5/128],[1,1,1,1]))
            else:
                loop=loops[0];need(len(loops)==1 and len(loop)==6,'original free-case shelf rim changed')
                l,r=min(v[0]for v in loop),max(v[0]for v in loop);b=min(v[1]for v in loop);n,f=min(v[2]for v in loop),max(v[2]for v in loop)
                closures.append(cap(p,[[l,b,n],[r,b,n],[r,b,f],[l,b,f]],[24.5/128,24.5/128],[1,1,1,1]))
                # Existing case inner walls own all buried shelf ends/backs.
        content=png(t.rgba,t.width,t.height);existing=output/texture
        need(not existing.exists()or existing.read_bytes()==content,'shared original Birch texture changed');existing.parent.mkdir(parents=True,exist_ok=True);existing.write_bytes(content)
        textures[t.name]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),path=texture)
    # Original independent closed-top storage carton, selected from the two
    # original cartons in GR743. Its unpainted open base rests on the case's
    # existing top face; a second bottom plane there would cause Z-fighting.
    s=bm.submeshes[10];q=open_bch(boxraw).models[0].meshes[10]
    need(s.material=='pasted__box01'and s.positions==q.positions and s.uv0==q.texcoords,'independent carton positions/UV differ')
    need(len(q.submeshes)==1 and [n for t in s.triangles for n in t]==q.submeshes[0].indices,'independent carton triangles differ')
    g=components(s)[0];need(g[0]==0 and len(g)==10,'original carton selection changed');t=next(t for t in load_textures(boxblob)if t.name=='box01');need((t.width,t.height)==(128,64)and set(t.rgba[3::4])=={255},'original carton PNG changed')
    box=source_part(s,'assets/scenery/oras-birch-freecase/box01.png',[s.triangles[i]for i in g]);box['colors']=[[1,1,1,1]for _ in box['vertices']]
    body=parts[1]['vertices'];lo=[min(v[k]for v in body)for k in range(3)];hi=[max(v[k]for v in body)for k in range(3)];origin=[(lo[k]+hi[k])/2 for k in range(3)];width=hi[0]-lo[0];scale=(10/31.5*width)/(max(v[0]for v in box['vertices'])-min(v[0]for v in box['vertices']));bb=[min(v[k]for v in box['vertices'])for k in range(3)];bh=[max(v[k]for v in box['vertices'])for k in range(3)];bc=[(bb[k]+bh[k])/2 for k in range(3)]
    for v in box['vertices']:
        v[0]=(v[0]-bc[0])*scale+origin[0]-6/31.5*width
        v[1]=(v[1]-bb[1])*scale+hi[1]
        v[2]=(v[2]-bc[2])*scale+origin[2]-3.5/31.5*width
    parts.append(box);content=png(t.rgba,t.width,t.height);(folder/'box01.png').write_bytes(content);textures['box01']=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),path=box['texture'])
    for texture in sorted({p['texture']for p in closures}):
        p=merge_parts([p for p in closures if p['texture']==texture]);p['name']='authored_reviewed_freecase_closures';parts.append(p)
    model,meta=normalized(parts);data={'oras_birch_freestanding_case':model};(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/ImportedBirchFreecaseData.lua').write_text('-- Original ORAS free-standing case and independent storage carton; tools/import_oras_birch_freecase.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',sources=[dict(nativeLink='ZO227 -> AD114 -> MM168 -> GR510',model=m.name,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),bookGroups=sorted(book_ids),caseGroups=sorted(case_ids)),dict(nativeLink='ZO450 -> AD200 -> MM352 -> GR743',model=bm.name,modelBchSha256=hashlib.sha256(boxraw).hexdigest(),textureBchSha256=hashlib.sha256(boxblob).hexdigest(),submesh=10,group=0,triangles=10)],originalTriangles=820,authoredClosureTriangles=sum(len(p['indices'])//3 for p in closures),bookGroupXRepairs=shifts,cartonUniformScale=scale,textures=textures,sourceFront='+Z',**meta,processing='Complete original double-bay case, four bins, four shelves, forty-four books and an independent original storage carton. Original UV/PNG/triangles retained, vertex RGBA lighting removed. Whole book groups translate only in X inside their original bays to remove actual coplanar/intersecting contacts; original leaning angles and proportions retained. Exact original book/case/bin rims closed, including all collinear source vertices and bin underside tilt; buried shelf-back/end caps omitted. Carton uniformly fitted as an independent ten-pixel-wide item resting exactly on the original case top; its original open base receives no duplicate plane. Native full 32x32 blocked-body footprint and floor recess; no source floor/shadow/light geometry.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in['model','textures','box_model','box_textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.box_model,a.box_textures,a.decoder,a.nitrogen,a.output).items():print(name,sum(len(p['indices'])//3 for p in m['parts']))
