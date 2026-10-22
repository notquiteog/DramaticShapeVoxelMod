#!/usr/bin/env python3
"""Bake the supplied ORAS evergreen archive; original packs stay outside Git."""
import argparse,collections,copy,hashlib,io,json,zipfile
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image
from import_scenery_models import dae_static,normalize
from import_oras_grass import lua,NS

MODEL='oras_evergreen_tree'
SOURCE='ORAS_Evergreen/ORAS_Evergreen.dae'
BINDINGS={'chip_wood_a-effect':'chip_wood_a.png','Material_001-effect':'Chip_Wood_B.png'}

def source_parts(raw):
    root=ET.fromstring(raw);tag=lambda s:'{'+NS['c']+'}'+s
    images=root.find('c:library_images',NS)
    assert images is not None and not list(images),'archive texture bindings changed'
    # This particular Blender export omitted image/sampler links. Its included
    # readme explicitly requests binding the two included, already UV-mapped PNGs.
    for effect,texture in BINDINGS.items():
        ET.SubElement(ET.SubElement(images,tag('image'),{'id':effect+'-image'}),tag('init_from')).text=texture
        profile=root.find('c:library_effects/c:effect[@id="'+effect+'"]/c:profile_COMMON',NS)
        surface=ET.SubElement(ET.SubElement(profile,tag('newparam'),{'sid':effect+'-surface'}),tag('surface'),{'type':'2D'})
        ET.SubElement(surface,tag('init_from')).text=effect+'-image'
        sampler=ET.SubElement(ET.SubElement(profile,tag('newparam'),{'sid':effect+'-sampler'}),tag('sampler2D'))
        ET.SubElement(sampler,tag('source')).text=effect+'-surface'
        diffuse=profile.find('c:technique/c:phong/c:diffuse',NS);diffuse.clear()
        ET.SubElement(diffuse,tag('texture'),{'texture':effect+'-sampler','texcoord':'UVMap'})
    parts=dae_static(ET.tostring(root))
    assert [(p['texture'],len(p['vertices'])//3)for p in parts]==[('chip_wood_a.png',12),('Chip_Wood_B.png',96)]
    for p in parts:
        p.update(name='source_bark'if p['texture']=='chip_wood_a.png'else'source_canopy',
                 role='tree_trunk'if p['texture']=='chip_wood_a.png'else'tree_canopy',alphaMode='cutout',opacity=1.,diffuse=[1.,1.,1.])
    return parts

def bark_closure(part):
    points={tuple(round(v[i],4)for i in range(3)):v for v in part['vertices']}
    def at(x,y,z):return copy.deepcopy(points[x,y,z])
    left=[at(-16.299,-11.2596,-3.7843),at(-9.495,-3.2124,-3.8813),at(-6.912,5.2586,-3.2713),at(-6.075,21.8836,-3.1193)]
    right=[at(16.29,-11.2596,-3.7843),at(9.969,-2.6804,-3.8813),at(6.405,4.2846,-3.2713),at(4.899,21.2336,-3.1193)]
    vertices=[]
    def tri(*vs):
        for v in vs:
            q=copy.deepcopy(v);q[3:5]=[.75390625,.5078125];vertices.append(q)
    for i in range(3):
        tri(left[i],right[i],right[i+1]);tri(left[i],right[i+1],left[i+1])
    tri(left[-1],right[-1],at(-.04,22.7146,3.7767))
    ring=[left[0],at(-6.982,-11.2596,5.0227),at(-.139,-11.2596,14.3206),at(7.113,-11.2596,5.0706),right[0]]
    center=[sum(v[i]for v in ring)/len(ring)for i in range(3)]+[.75390625,.5078125,1.]
    for a,b in zip(ring,ring[1:]+ring[:1]):tri(center,a,b)
    hull=collections.Counter()
    for i in range(0,len(part['vertices']+vertices),3):
        q=[tuple(round(n,4)for n in v[:3])for v in (part['vertices']+vertices)[i:i+3]]
        for a,b in zip(q,q[1:]+q[:1]):hull[tuple(sorted((a,b)))]+=1
    assert set(hull.values())=={2},'bark hull remains open'
    closure=copy.deepcopy(part);closure.update(name='bark_back_top_and_ground',vertices=vertices,authored=True)
    # The original bark's root cutouts stay intact. A closed inset bark shell
    # prevents seeing the far cap through them, without changing source bounds.
    backing=[];cx=(min(v[0]for v in part['vertices'])+max(v[0]for v in part['vertices']))/2
    cz=(min(v[2]for v in part['vertices'])+max(v[2]for v in part['vertices']))/2
    cy=(min(v[1]for v in part['vertices'])+max(v[1]for v in part['vertices']))/2
    for v in part['vertices']+vertices:
        q=copy.deepcopy(v);q[0]=cx+(q[0]-cx)*.996;q[2]=cz+(q[2]-cz)*.996;q[1]=cy+(q[1]-cy)*.999;q[3:5]=[.75390625,.5078125];backing.append(q)
    inner=copy.deepcopy(part);inner.update(name='bark_inset_backing',vertices=backing,authored=True)
    return [closure,inner]

def convert(archive,output):
    raw=Path(archive).read_bytes();output=Path(output)
    with zipfile.ZipFile(io.BytesIO(raw))as z:
        dae=z.read(SOURCE);parts=source_parts(dae)
        original=copy.deepcopy(parts)
        source_bounds=[min(v[i]for p in original for v in p['vertices'])for i in range(3)]+[max(v[i]for p in original for v in p['vertices'])for i in range(3)]
        parts.extend(bark_closure(parts[0]));meta=normalize(parts)
        canopy=min(v[1]for v in parts[1]['vertices'])
        folder=output/'assets/scenery/oras-pine';folder.mkdir(parents=True,exist_ok=True);textures={}
        for name in BINDINGS.values():
            png=z.read('ORAS_Evergreen/'+name);(folder/name).write_bytes(png);im=Image.open(io.BytesIO(png)).convert('RGBA')
            textures[name]={'sha256':hashlib.sha256(png).hexdigest(),'size':list(im.size),'alphaRange':list(im.getextrema()[3])}
        for p in parts:p['texture']='assets/scenery/oras-pine/'+p['texture']
        data={MODEL:{'parts':parts,'bounds':meta['bounds'],'anchors':{'canopyBottom':[0,canopy,0]}}}
        (output/'lib/ImportedPineTreeData.lua').write_text('-- Original ORAS evergreen triangles and source UVs; generated by tools/import_oras_pine.py.\nreturn '+lua(data)+'\n')
        report={'asset':293576,'sourcePage':'https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/293576/','title':'Pine Tree / Evergreen Tree','author':'Fallenleader (RSRazr)','submitted':'2015-08-29','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(raw).hexdigest(),'sourceFile':SOURCE,'sourceSha256':hashlib.sha256(dae).hexdigest(),'sourceBoundsYUp':source_bounds,'sourceTriangles':108,'addedBarkClosureTriangles':12,'addedInsetBarkTriangles':24,'barkHullClosed':True,'sourceTextureBindings':BINDINGS,'textures':textures,'normalization':meta,'sourceRetention':'All original108triangles, UVs and both PNG bytes retained. No canopy rotations, stretching, added foliage or source deletion. New bark faces use an existing opaque bark texel; original cutouts retain an inset backing. Open alpha-cutout leaf edges remain foliage.','bindingsNote':'Archive DAE has no image/sampler nodes; included readme requests assigning the UV-mapped textures. Material chip_wood_a maps to chip_wood_a.png, Material_001 maps to Chip_Wood_B.png.'}
        (folder/'provenance.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
        return data,report
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('archive');parser.add_argument('--output-root',default='.');args=parser.parse_args();_,report=convert(args.archive,args.output_root);print(json.dumps({k:report[k]for k in ['sourceTriangles','addedBarkClosureTriangles','addedInsetBarkTriangles','barkHullClosed']}))
