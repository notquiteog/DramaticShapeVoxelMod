#!/usr/bin/env python3
"""Select one complete original Mt. Pyre memorial, closing omitted source backs."""
import argparse,hashlib,json,math,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components,merge_parts
from import_oras_oldale_sink import rims


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(hashlib.sha256(raw).hexdigest()=='bc49e4041ce0598ad47ed8734b0e89eaf6d5fa90bce8d538e7e62c711ea3ab1f','reviewed memorial source changed')
    need(m.name=='d108r0101_00_00'and not m.bones,'unreviewed original cemetery')
    sub=m.submeshes[0];need(sub.material=='Comb1'and len(sub.triangles)==13564,'original memorial batch changed')
    need(next(x for x in m.materials if x.name=='Comb1').base_color_texture=='d108_obj1','source memorial texture binding changed')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0].meshes[0]
    need(sub.positions==other.positions and sub.uv0==other.texcoords,'independent memorial positions/UV differ')
    need(len(other.submeshes)==1 and [n for t in sub.triangles for n in t]==other.submeshes[0].indices,'independent memorial indices differ')
    groups=components(sub);selected=[]
    for start,count in [(12,72),(1113,36),(1133,16)]:
        g=next(g for g in groups if g[0]==start);need(len(g)==count,'reviewed memorial component changed');selected.append(g)
    texture='assets/scenery/oras-pyre-memorial/d108_obj1.png'
    parts=[source_part(sub,texture,[sub.triangles[i]for i in g])for g in selected]
    for p,name in zip(parts,['source_memorial_arch','source_memorial_base','source_memorial_plaque']):p['name']=name
    cap,body,plaque=parts;closures=[]
    def polygon(points,name):
        # These reviewed polygons are convex, including collinear source rim
        # subdivisions. A center fan retains every original boundary edge.
        center=[sum(v[k]for v in points)/len(points)for k in range(3)];uv=[40.5/64,12.5/64]
        p={k:v for k,v in body.items()if k not in('vertices','indices','colors')}
        p.update(name=name,vertices=[center+uv+[1]]+[list(q)+uv+[1]for q in points],indices=[n for i in range(len(points))for n in(1,i+2,(i+1)%len(points)+2)],colors=[[1,1,1,1]]*(len(points)+1),authored=True);closures.append(p)
    # The base's open rim includes its underside and stepped rear profile.
    # Close each rear strip at the source angle instead of fanning a folded
    # sheet across the complete nonplanar opening.
    br=rims(body);need(len(br)==1 and len(br[0])==14,'original base rear/underside rim changed')
    points=[v[:3]for v in body['vertices']];ys=sorted({p[1]for p in points});need(len(ys)==5,'original base profile changed')
    profile=[]
    for y in ys:
        row=[p for p in points if p[1]==y];back=min(p[2]for p in row);edge=sorted({tuple(p)for p in row if p[2]==back});profile.append(edge)
    need([len(p)for p in profile]==[2,2,2,2,3],'reviewed rear profile vertices changed')
    for lower,upper in zip(profile,profile[1:]):polygon([lower[0]]+upper+[lower[-1]],'authored_source_angled_rear')
    bottom=[p for p in br[0]if p[1]==ys[0]];need(len(bottom)==5,'source underside changed');polygon(bottom,'authored_source_underside')
    cr=rims(cap);need(len(cr)==1 and len(cr[0])==16,'source arch rim changed')
    rear=min(v[2]for v in cap['vertices']);back=[p for p in cr[0]if abs(p[2]-rear)<1e-6];need(len(back)==13,'source arch rear profile changed');polygon(back,'authored_original_arch_rear')
    # The exported arch floats 0.03775 source units over its original plinth.
    # Extend only a thin skirt to that existing platform; no new underside
    # cap coincides with or duplicates the original plinth top.
    low=min(v[1]for v in cap['vertices']);base={tuple(v[:3])for v in cap['vertices']if v[1]==low};need(len(base)==5,'source arch foot changed')
    cx=sum(v[0]for v in base)/len(base);cz=sum(v[2]for v in base)/len(base)
    base=sorted(base,key=lambda p:math.atan2(p[2]-cz,p[0]-cx));need(0<low-ys[-1]<.04,'original arch joint changed')
    for a,b in zip(base,base[1:]+base[:1]):polygon([a,b,[b[0],ys[-1],b[2]],[a[0],ys[-1],a[2]]],'authored_arch_joint_skirt')
    pr=rims(plaque);need(len(pr)==1 and len(pr[0])==6,'source plaque rim changed')
    front=max(p[2]for p in points if ys[2]<=p[1]<=ys[3]);need(abs(front-105.99829864501953)<1e-6,'source plaque backing plane changed')
    need(all(0<p[2]-front<.06 for p in pr[0]),'source plaque joint changed')
    # Its existing case face closes this joint. Add perimeter thickness only,
    # retaining the original beveled plaque and avoiding a duplicate back cap.
    for a,b in zip(pr[0],pr[0][1:]+pr[0][:1]):polygon([b,a,[a[0],a[1],front],[b[0],b[1],front]],'authored_plaque_joint_skirt')
    closure=merge_parts(closures);closure['name']='authored_reviewed_memorial_closures'
    model,meta=normalized(parts+[closure]);data={'oras_pyre_memorial':model}
    t=next(t for t in load_textures(blob)if t.name=='d108_obj1');need((t.width,t.height)==(64,64)and set(t.rgba[3::4])=={255},'reviewed memorial PNG changed');content=png(t.rgba,t.width,t.height)
    folder=output/'assets/scenery/oras-pyre-memorial';folder.mkdir(parents=True,exist_ok=True);(folder/'d108_obj1.png').write_bytes(content)
    (output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/ImportedPyreMemorialData.lua').write_text('-- Genuine ORAS Mt. Pyre memorial; generated by tools/import_oras_pyre_memorial.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO86 -> AD53 -> MM47 -> GR301',model=m.name,submesh=0,sourceComponents=[dict(firstTriangle=g[0],triangles=len(g))for g in selected],sourceTriangles=124,authoredClosureTriangles=len(closure['indices'])//3,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textureRgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),sourceFront='+Z',**meta,processing='One complete original memorial arch, stepped base and beveled plaque selected from the 106-instance cemetery batch. All124 source triangles, positions/UV and original opaque PNG preserved; grayscale vertex shading removed. Omitted base back closed along its exact angled source profile and underside, arch rear closed. Tiny original arch/plaque gaps gain perimeter skirts to the existing plinth/case surfaces, without duplicate internal caps. No cemetery floor, source shadow, light or neighboring prop is selected. Uniform native single blocked-cell fit; physical bottom recess only.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output).items():print(name,len(m['parts']),sum(len(p['indices'])//3 for p in m['parts']))
