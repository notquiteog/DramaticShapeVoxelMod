#!/usr/bin/env python3
"""Bake genuine ORAS BM0008 Center sliding panels from a supplied local RomFS.

External public decoders are explicit arguments; neither decoder nor ROM enters Git.
"""
import argparse,hashlib,json,math,sys
from pathlib import Path
from import_oras_grass import lua

def mul(a,b):return[[sum(a[i][k]*b[k][j]for k in range(4))for j in range(4)]for i in range(4)]
def sample(keys,frame):
    if frame<=keys[0].frame:return keys[0].value
    if frame>=keys[-1].frame:return keys[-1].value
    a,b=next((a,b)for a,b in zip(keys,keys[1:])if a.frame<=frame<=b.frame)
    h=b.frame-a.frame;t=(frame-a.frame)/h
    return(2*t**3-3*t*t+1)*a.value+(t**3-2*t*t+t)*h*a.slope+(-2*t**3+3*t*t)*b.value+(t**3-t*t)*h*b.slope

def convert(model,animation,textures,source_tools,decoder_path,nitrogen_path,output):
    sys.path.insert(0,str(source_tools));from oras_scenery_source import decoder
    load,load_textures,png=decoder(decoder_path)
    raw=model.read_bytes();m=load(raw)[0];assert m.name=='com_bm_pcdoor01'
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    independent=open_bch(raw).models[0];assert len(independent.skeleton)==len(m.bones)==10
    worlds=[];errors={}
    for i,b in enumerate(independent.skeleton):
        assert b.name==m.bones[i].name and all(abs(x)<1e-8 for x in b.rotation)
        t=[[b.scale[r]if r==c else b.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
        if b.parent>=0:t=mul(worlds[b.parent],t)
        worlds.append(t);ib=[b.inverse_bind[k:k+4]for k in range(0,16,4)];check=mul(t,ib)
        errors[b.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
    assert max(errors[m.bones[i].name]for i in (0,1,2))<1e-6,'moving-bone bind transforms disagree'
    from ctr.formats.bch.header import read_header,relocate
    from ctr.binstream import BinStream
    from ctr.formats.bch.contents import read_contents
    from ctr.formats.bch.animation import read_animations
    a=animation.read_bytes();h=read_header(BinStream(a));rel=relocate(a,h);motions=read_animations(rel,read_contents(rel,h),h.backward)
    assert len(motions)==1 and motions[0].frame_count==6 and not motions[0].looping
    tracks={b.name:b.translation[0].keys for b in motions[0].bones if b.name in ['anim_door_left','anim_door_right']}
    assert set(tracks)=={'anim_door_left','anim_door_right'}
    selected=[]
    for sub in m.submeshes:
        if sub.material not in ['chip_mado0_70','pc_door00']:continue
        bone=sub.bones[0][0];assert bone in(1,2)and all(x==[bone]for x in sub.bones)and all(x==[1.]for x in sub.weights)
        assert len(sub.positions)==4 and len(sub.triangles)==2 and not sub.colors
        matrix=worlds[bone];vs=[]
        for pos,uv in zip(sub.positions,sub.uv0):
            p=[sum(matrix[r][k]*(pos[k]if k<3 else 1)for k in range(4))for r in range(3)]
            # Native 3DS UVs are bottom-origin; the PNG/renderer uses top-origin.
            vs.append(p+[uv[0],1-uv[1],1.])
        selected.append({'name':('left'if bone==1 else'right')+'_'+sub.material,'leaf':'left'if bone==1 else'right',
                         'material':sub.material,'texture':'pokecen_mado.png'if sub.material=='chip_mado0_70'else'pokecen_door.png',
                         'vertices':vs,'indices':[i+1 for tri in sub.triangles for i in tri],
                         'opacity':1.,'alphaMode':'cutout','role':'source_center_door','wrapS':'repeat','wrapT':'repeat'})
    assert len(selected)==4
    allv=[v for p in selected for v in p['vertices']];b=[min(v[k]for v in allv)for k in range(3)]+[max(v[k]for v in allv)for k in range(3)]
    span=b[3]-b[0];origin=[(b[0]+b[3])/2,b[1],b[5]]
    poses=[]
    for frame in [0.,2.5,5.]:poses.append({side:sample(tracks['anim_door_'+side],frame)-tracks['anim_door_'+side][0].value for side in ['left','right']})
    for p in selected:
        for v in p['vertices']:
            for k in range(3):v[k]=(v[k]-origin[k])/span
    folder=output/'assets/scenery/oras-center-doors';folder.mkdir(parents=True,exist_ok=True)
    loaded={t.name:t for t in load_textures(textures.read_bytes())};texture_hashes={}
    for name in ['pokecen_mado','pokecen_door']:
        t=loaded[name];content=png(t.rgba,t.width,t.height);(folder/(name+'.png')).write_bytes(content)
        texture_hashes[name]={'size':[t.width,t.height],'sha256':hashlib.sha256(content).hexdigest()}
    for p in selected:p['texture']='assets/scenery/oras-center-doors/'+p['texture']
    # These portal dimensions are original292908 opening-edge vertices. Its
    # recessed gray backplane stays in the building as the hallway background.
    aperture={'width':30.242005,'height':44.103495,'buildingSpan':116.807983,'insetFromDoorAnchor':31.67667-26.636368+.025}
    data={'id':'oras_center_sliding_panels','parts':selected,'sourceSpan':span,'sourceHeight':b[4]-b[1],'sourceBounds':b,'sourceOrigin':origin,'poses':poses,'aperture':aperture}
    (output/'lib/ImportedCenterDoorData.lua').write_text('-- Genuine ORAS BM0008 sliding panels; generated by tools/import_oras_center_doors.py.\nreturn '+lua(data)+'\n')
    report={'source':'User-supplied Pokemon Alpha Sapphire RomFS','modelArchive':'a/0/2/3 BM0008 slot0','modelName':m.name,'animationArchive':'a/0/2/3 BM0008 slot1','textureArchive':'a/0/1/4 AD0008 slot1',
            'sha256':{'modelBch':hashlib.sha256(raw).hexdigest(),'animationBch':hashlib.sha256(a).hexdigest(),'textureBch':hashlib.sha256(textures.read_bytes()).hexdigest()},
            'triangles':8,'sourceBoundsYUp':b,'sourceOrigin':origin,'sourceUnitSpan':span,'movingBones':['anim_door_left','anim_door_right'],
            'movingBoneInverseBindMaximumError':max(errors[m.bones[i].name]for i in(0,1,2)),
            'sourceAnimation':{'frames':6,'looping':False,'samples':[0,2.5,5],'poses':poses,'tracks':{name:[{'frame':k.frame,'value':k.value,'slope':k.slope}for k in keys]for name,keys in tracks.items()}},
            'textures':texture_hashes,'aperture':aperture,'originalGameArt':'Nintendo / Creatures / GAME FREAK',
            'processing':'Both moving rigid bones have weight1 and no rotation. Original local positions transformed by composed source TRS; independently checked against stored inverse bind matrices. All8 source triangles and UV islands retained (V origin converted once). Sampled original Hermite X tracks at closed/half/open; native engine owns timing/warp. Source floor-light effect intentionally omitted; door geometry/texture colors are not invented. Uniform fit to the existing source292908 aperture; original static gray recess remains.'}
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return data,report
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--model',type=Path,required=True);p.add_argument('--animation',type=Path,required=True);p.add_argument('--textures',type=Path,required=True);p.add_argument('--source-tools',type=Path,required=True);p.add_argument('--decoder',type=Path,required=True);p.add_argument('--nitrogen',type=Path,required=True);p.add_argument('--output-root',type=Path,default=Path('.'));a=p.parse_args();d,r=convert(a.model,a.animation,a.textures,a.source_tools,a.decoder,a.nitrogen,a.output_root);print(json.dumps({'triangles':r['triangles'],'bindError':r['movingBoneInverseBindMaximumError'],'poses':r['sourceAnimation']['poses']}))
