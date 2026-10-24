#!/usr/bin/env python3
"""Isolate the original Birch laboratory case and fifteen books from its room."""
import argparse,collections,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components,merge_parts
from import_oras_oldale_sink import rims
from import_oras_flower_bookcase import cap


def quad(p,points,uv):return cap(p,points,uv,[1,1,1,1])


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(hashlib.sha256(raw).hexdigest()=='88c0fe278846a20cb8092c275567b98f1d2a5266d7e532966ac5d87bf3a5993e','reviewed original Birch room changed')
    need(m.name=='t101r0301_00_00'and not m.bones,'unreviewed original lab')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0];bank={t.name:t for t in load_textures(blob)};folder=output/'assets/scenery/oras-birch-bookcase';folder.mkdir(parents=True,exist_ok=True)
    parts=[];closures=[];textures={}
    for index,material,wanted in[(0,'t101r0301_book1',{154,158,162,198,202}),(3,'t101r0301_obj01_00',{48,92,110,114})]:
        s=m.submeshes[index];q=other.meshes[index]
        need(s.material==material and s.positions==q.positions and s.uv0==q.texcoords,'independent original positions/UV differ')
        need(len(q.submeshes)==1 and [n for t in s.triangles for n in t]==q.submeshes[0].indices,'independent original indices differ')
        mat=next(mat for mat in m.materials if mat.name==material);t=bank[mat.base_color_texture];need((t.width,t.height)==((64,64)if index==0 else(128,128)),'original texture changed')
        need(set(t.rgba[3::4])=={255},'unreviewed original bookcase texture alpha')
        texture='assets/scenery/oras-birch-bookcase/'+t.name+'.png';selected=[];groups={}
        for g in components(s):
            if g[0]in wanted:selected.extend(s.triangles[i]for i in g);groups[g[0]]=g
        need(set(groups)==wanted,'selected original case components changed')
        source=source_part(s,texture,selected);source['colors']=[[1,1,1,1]for _ in source['vertices']];parts.append(source)
        used=sorted({n for tri in selected for n in tri});mapping={n:i for i,n in enumerate(used)}
        for start,g in sorted(groups.items()):
            p=source_part(s,texture,[s.triangles[i]for i in g]);p['colors']=[[1,1,1,1]for _ in p['vertices']]
            if index==0:
                # Adjacent original three-book groups share overlapping back
                # planes over a 0.0566-source-unit sliver. Move this complete
                # group 0.06 left inside its original shelf to separate them.
                if start==162:
                    for n in {n for i in g for n in s.triangles[i]}:source['vertices'][mapping[n]][0]-=.06
                    for v in p['vertices']:v[0]-=.06
                loops=rims(p);need(len(g)==34 and len(loops)==1 and len(loops[0])==16,'original book rim changed')
                closures.append(cap(p,loops[0],[.5/64,.5/64],[1,1,1,1]))
            elif start in(110,114):
                vs=p['vertices'];l,r=min(v[0]for v in vs),max(v[0]for v in vs);b,h=min(v[1]for v in vs),max(v[1]for v in vs);n,f=min(v[2]for v in vs),max(v[2]for v in vs)
                closures.append(quad(p,[[l,b,n],[r,b,n],[r,b,f],[l,b,f]],[24.5/128,24.5/128]))
                # Shelf backs and ends already meet original case walls;
                # their caps would duplicate the original inner rear plane.
            elif start==92:
                # Exact rear silhouette includes original collinear T seams.
                loop=rims(p)[0];need(len(loop)==10,'original outer case rim changed')
                l,r=min(v[0]for v in loop),max(v[0]for v in loop);b,h=min(v[1]for v in loop),max(v[1]for v in loop);n,f=min(v[2]for v in loop),max(v[2]for v in loop)
                closures.append(cap(p,[v for v in loop if abs(v[2]-n)<1e-6],[24.5/128,24.5/128],[1,1,1,1]))
                closures.append(cap(p,[v for v in loop if abs(v[1]-b)<1e-6],[24.5/128,24.5/128],[1,1,1,1]))
            elif start==48:
                loops=rims(p);need(sorted(map(len,loops))==[8,8,10],'original twin drawer rims changed')
                for loop in loops:
                    if len(loop)==8:closures.append(cap(p,loop,[80.5/128,80.5/128],[1,1,1,1]))
                    else:
                        l,r=min(v[0]for v in loop),max(v[0]for v in loop);b,h=min(v[1]for v in loop),max(v[1]for v in loop);n,f=min(v[2]for v in loop),max(v[2]for v in loop)
                        closures.append(cap(p,[v for v in loop if abs(v[2]-n)<1e-6],[80.5/128,80.5/128],[1,1,1,1]))
                        # Keep the original 0.0000098-unit underside tilt
                        # and all collinear rim vertices, closing the seam
                        # exactly rather than flattening its rear edge.
                        closures.append(cap(p,[v for v in loop if v[1]<b+.00002],[80.5/128,80.5/128],[1,1,1,1]))
        content=png(t.rgba,t.width,t.height);(folder/(t.name+'.png')).write_bytes(content);textures[t.name]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest())
    for texture in sorted({p['texture']for p in closures}):
        p=merge_parts([p for p in closures if p['texture']==texture]);p['name']='authored_reviewed_birch_case_closures';parts.append(p)
    model,meta=normalized(parts);data={'oras_birch_bookcase':model};(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/ImportedBirchBookcaseData.lua').write_text('-- Original ORAS Birch laboratory bookcase; tools/import_oras_birch_bookcase.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO227 -> AD114 -> MM168 -> GR510',model=m.name,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textures=textures,selection={'bookSubmesh':0,'threeBookGroups':[154,158,162,198,202],'caseSubmesh':3,'caseGroups':[48,92,110,114]},originalTriangles=310,authoredClosureTriangles=sum(len(p['indices'])//3 for p in closures),sourceFront='+Z',**meta,processing='Complete original laboratory case, twin drawer bins, two shelves and fifteen books. Independent original positions/UV/indices validated. Original colored PNG/UV retained; vertex RGBA lighting removed for solid original opaque materials. One original three-book group moves 0.06 source units left to remove coplanar back-plane slivers. Exact book rims, case rear/bottom, twin drawer cutouts/rear/bottom and shelf undersides closed; shelf-back/end caps omitted where original case walls already cover them. Source floor, shadows, lights and unrelated room objects excluded. Uniform native fit and Y0 contact recess.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output).items():print(name,sum(len(p['indices'])//3 for p in m['parts']))
