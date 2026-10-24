#!/usr/bin/env python3
"""Original ORAS Meteor cave rock spike, with exact missing rear/base closures."""
import argparse,copy,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components
from import_oras_oldale_sink import rims
from import_oras_devon import triangulate
from import_oras_grass import lua


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,textures,png=decoder(decoder_path)
    raw,blob=model_path.read_bytes(),texture_path.read_bytes()
    need(hashlib.sha256(raw).hexdigest()=='b48097b15e70f96d1c99d47e0323d2ae99029a12167f99f686d6d1792ea18773','reviewed original Meteor cave changed')
    model=load(raw)[0]
    need(model.name=='d101r0101_00_00'and len(model.bones)==1,'original cave changed')
    bone=model.bones[0]
    need(bone.parent is None and tuple(bone.translation)==(0,0,0)and tuple(bone.rotation)==(0,0,0)and tuple(bone.scale)==(1,1,1),'original identity root changed')
    sub=model.submeshes[0]
    need(sub.material=='gake_basic'and len(sub.triangles)==2308,'original native rock mass changed')
    need(next(m.base_color_texture for m in model.materials if m.name==sub.material)=='d101r_gake01','rock material binding changed')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0].meshes[0]
    need(sub.positions==other.positions and sub.uv0==other.texcoords,'independent original rock position/UV mismatch')
    need(len(other.submeshes)==1 and[n for t in sub.triangles for n in t]==other.submeshes[0].indices,'independent original rock indices mismatch')
    need(all(b==[0]for b in sub.bones)and all(w==[1.]for w in sub.weights),'original rock identity root ownership changed')
    need(other.submeshes[0].bone_indices==[0]and other.submeshes[0].skinning==2,'independent original rock root binding mismatch')
    selected=next(g for g in components(sub)if g[0]==441)
    need(selected==list(range(441,461)),'original complete spike component changed')
    texture=next(t for t in textures(blob)if t.name=='d101r_gake01')
    need((texture.width,texture.height)==(128,256)and set(texture.rgba[3::4])=={255},'original opaque cave texture changed')
    path='assets/scenery/oras-meteor-stalagmite/d101r_gake01.png'
    source=source_part(sub,path,[sub.triangles[i]for i in selected]);source['name']='original_complete_rock_spike_441'
    loop=rims(source);need(len(loop)==1 and len(loop[0])==10,'original rear/base rim changed')
    closures=copy.deepcopy(source);closures.update(name='authored_exposed_rear_and_underside',vertices=[],indices=[],colors=[],authored=True)
    def triangle(points):
        for p in points:
            v=min(source['vertices'],key=lambda v:sum((p[k]-v[k])**2 for k in range(3)))
            need(sum((p[k]-v[k])**2 for k in range(3))<1e-8,'closure moved original edge')
            closures['vertices'].append(list(p)+v[3:]);closures['indices'].append(len(closures['vertices']));closures['colors'].append([1,1,1,1])
    a,b=[192,144,-294],[202,144,-294]
    u,v,w=[195,162,-292],[198,162,-293],[200,162,-292]
    # Only the rear skin and actual seven-vertex foot are absent in this
    # source component. There is no cap across the ring at source Y162.
    for q in [[a,v,u],[a,b,v],[b,w,v]]:triangle(q)
    foot=[[190,-288],[192,-294],[202,-294],[206,-288],[204,-282],[198,-280],[192,-282]]
    for q in triangulate(foot):triangle([[x,144,z]for x,z in reversed(q)])
    need(len(closures['indices'])//3==8,'exact exposed closure count changed')
    joined=copy.deepcopy(source);joined['vertices']=source['vertices']+closures['vertices'];joined['indices']=source['indices']+[n+len(source['vertices'])for n in closures['indices']]
    need(not rims(joined),'closed original rock has open edges')
    result,meta=normalized([source,closures]);need(meta['sourceBounds']==[190.0,144.0,-294.0,206.0,190.0,-280.0],'original source proportions changed')
    folder=output/'assets/scenery/oras-meteor-stalagmite';folder.mkdir(parents=True,exist_ok=True)
    image=png(texture.rgba,texture.width,texture.height);(folder/'d101r_gake01.png').write_bytes(image)
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedMeteorStalagmiteData.lua').write_text('-- Original ORAS cave rock spike; tools/import_oras_meteor_stalagmite.py.\nreturn '+lua({'oras_meteor_stalagmite':result})+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO71 -> AD107 -> MM32 -> GR260',model=model.name,submesh=0,material='gake_basic',componentTriangles=[441,460],originalTriangles=20,authoredClosureTriangles=8,finalTriangles=28,sourceModelSha256=hashlib.sha256(raw).hexdigest(),sourceTextureBankSha256=hashlib.sha256(blob).hexdigest(),pngSha256=hashlib.sha256(image).hexdigest(),whiteVertexLighting=True,normalization=meta)
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return result,report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args();_,report=convert(a.model,a.textures,a.decoder,a.nitrogen,a.output);print('oras_meteor_stalagmite',report['finalTriangles'])
