#!/usr/bin/env python3
"""Select original ORAS Comfortable Bed geometry; source archives stay scratch."""
import argparse, hashlib, io, json, zipfile
from pathlib import Path, PurePosixPath
from PIL import Image
from import_scenery_models import obj, materials, normalize, safe_path
from import_oras_grass import lua

def closures():
    wood=[];cloth=[]
    def poly(out,points,xy):
        uv=[(xy[0]+.5)/128,(xy[1]+.5)/128]
        for i in range(1,len(points)-1):
            for p in (points[0],points[i],points[i+1]):out.append(list(p)+uv+[1])
    def panel(points):poly(wood,points,(20,20))
    def lining(points):poly(cloth,points,(100,50))
    # Curved rear-board caps follow the original exported outer rims.
    panel([[-.9003,.0003,-1.468652],[.9332,.0003,-1.468652],
           [.9332,.7871,-1.468652],[.7562,.8934,-1.468652],
           [.5125,.9679,-1.468652],[.2403,1.0228,-1.468652],
           [.0164,1.035193,-1.468652],[-.2075,1.0228,-1.468652],
           [-.4797,.9679,-1.468652],[-.7234,.8934,-1.468652],[-.9003,.7871,-1.468652]])
    panel([[-.9003,.0003,-1.468652],[.9332,.0003,-1.468652],
           [.9332,.0003,-1.35844],[-.9003,.0003,-1.35844]])
    rear=[[-.975718,.0756,1.3751],[.95806,.0756,1.3751],
          [.95806,.5525,1.3751],[.9182,.646,1.3751],[.8165,.7003,1.3751],
          [.5782,.746,1.3751],[.2741,.7776,1.3751],[-.0088,.7882,1.3751],
          [-.2917,.7776,1.3751],[-.5959,.746,1.3751],[-.8342,.7003,1.3751],
          [-.9358,.646,1.3751],[-.975718,.5525,1.3751]]
    panel(rear)
    for a,b in [(-.975718,-.8639),(.8462,.95806)]:
        panel([[a,-.006201,1.3751],[b,-.006201,1.3751],[b,.0756,1.3751],[a,.0756,1.3751]])
    for outline in [[(-.975718,1.3751),(-.8639,1.3751),(-.8639,1.4542),(-.8737,1.4843),(-.9198,1.494388),(-.9659,1.4843),(-.975718,1.4542)],
                    [(.8462,1.3751),(.95806,1.3751),(.95806,1.4542),(.9483,1.4843),(.9021,1.494388),(.856,1.4843),(.8462,1.4542)]]:
        panel([[x,-.006201,z]for x,z in outline])
    panel([[-.8639,.0756,1.3751],[.8462,.0756,1.3751],[.8462,.0756,1.4371],[-.8639,.0756,1.4371]])
    # Original base/frame underside, preserving space below the bed and its
    # leg silhouette. Blue blanket and white pillow keep their original tops.
    lining([[x,.101,z]for x,z in [(-.5939,-1.3311),(.6133,-1.3311),(.7915,-1.2661),(.8314,-1.135),
            (.8314,1.128),(.7915,1.2921),(-.7721,1.2921),(-.8119,1.128),(-.8119,-1.135),(-.7721,-1.2661)]])
    lining([[x,.2048,z]for x,z in [(-.8889,-.826),(.9185,-.826),(.9236,-.7846),(.9407,-.6435),
            (.9185,-.5302),(.8963,-.4632),(.9185,-.3843),(.9574,.2941),(.9185,1.4272),
            (-.8889,1.4272),(-.9277,.2941),(-.8889,-.3843),(-.8666,-.4632),(-.8889,-.5302),(-.911,-.6435),(-.8939,-.7846)]])
    for z,top in [(-.826,[(-.885,.3351),(-.7822,.4807),(-.471,.5451),(-.2745,.5539),(.0019,.5471),(.4749,.5318),(.8119,.5163),(.9147,.3351)]),
                  (1.4272,[(-.885,.3504),(-.7822,.496),(-.471,.5604),(-.2745,.5691),(.0019,.5624),(.4749,.5163),(.8119,.5163),(.9147,.3504)])]:
        lining([[-.8889,.2048,z],[.9185,.2048,z]]+[[x,y,z]for x,y in reversed(top)])
    lining([[x,.4357,z]for x,z in [(.3886,-.7393),(.4404,-.8814),(.4615,-1.0208),(.4404,-1.1602),(.3886,-1.3023),
             (.2158,-1.3278),(.0016,-1.3385),(-.2125,-1.3278),(-.3854,-1.3023),(-.4372,-1.1602),
             (-.4583,-1.0208),(-.4372,-.8814),(-.3854,-.7393),(-.2125,-.7138),(.0016,-.7035),(.2158,-.7138)]])
    return [{'name':'authored_'+name,'material':'authored_'+name,'texture':'sutekinabed.png',
             'diffuse':[.64,.64,.64],'opacity':1,'vertices':vertices,'wrapS':'repeat','wrapT':'repeat','authored':True}
            for name,vertices in [('board_rear_and_feet',wood),('bedding_and_base_undersides',cloth)]]


def convert(path, output):
    raw_archive=path.read_bytes()
    with zipfile.ZipFile(io.BytesIO(raw_archive)) as z:
        if len(z.infolist())>32 or sum(i.file_size for i in z.infolist())>8388608:
            raise ValueError('Bed archive exceeds budget')
        names={PurePosixPath(safe_path(n)).name:n for n in z.namelist() if not n.endswith('/')}
        raw=z.read('Comfortable Bed/sutekinabed.obj')
        source,fixes=obj(raw,materials(z.read('Comfortable Bed/sutekinabed.mtl')),names)
        parts=[p for p in source if p['material']=='sutekinabed.png']
        if len(parts)!=1:raise ValueError('Unexpected bed source material split')
        parts.extend(closures())
        fixes.append('Separately authored board rear, foot-bottom, base, blanket-end/underside and pillow-underside caps follow original rims; source534 triangles and source UV/PNG unchanged.')
        meta=normalize(parts)
        folder=output/'assets/scenery/interiors/oras_bed';folder.mkdir(parents=True,exist_ok=True)
        textures={}
        for p in parts:
            name=PurePosixPath(p['texture']).name;content=z.read(names[name]);im=Image.open(io.BytesIO(content));im.verify()
            (folder/name).write_bytes(content)
            textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)}
            p['texture']='assets/scenery/interiors/oras_bed/'+name
            p['role']='structure';p['alphaMode']='cutout'
        data={'oras_comfortable_bed':{'parts':parts,'anchors':{},'revision':1}}
        (output/'lib/ImportedInteriorBedData.lua').write_text('-- Generated by tools/import_interior_bed.py; attribution is beside the selected texture.\nreturn '+lua(data)+'\n')
        report={'asset':294940,'title':'Comfortable Bed','game':'Pokémon Omega Ruby / Alpha Sapphire','author':'Hallow','submitted':'2015-11-15',
                'sourcePage':'https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/294940/',
                'originalGameArt':'Nintendo / Creatures / GAME FREAK',
                'archiveSha256':hashlib.sha256(raw_archive).hexdigest(),'sourceModelSha256':hashlib.sha256(raw).hexdigest(),
                'selection':'Original bed body, curved head/foot boards, blue spotted blanket and white pillow. Planar source shadow excluded; renderer owns shadows.',
                'textures':textures,'repairs':fixes,**meta,
                'parts':[{'name':p['name'],'material':p['material'],'triangles':p['triangles'],'authored':bool(p.get('authored'))}for p in parts]}
        (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
        return data

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    for name,model in convert(a.archive,a.output).items():print(name,len(model['parts']),sum(p['triangles']for p in model['parts']))
