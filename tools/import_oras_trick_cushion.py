#!/usr/bin/env python3
"""Original Trick House floor cushion with an exact closed underside."""
import argparse,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components
from import_oras_oldale_sink import rims
from import_oras_flower_bookcase import cap


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,lt,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(hashlib.sha256(raw).hexdigest()=='336673b46f560347ad3d9f2f66ae2bb3ef0482e00834c66df536a957287c67af','reviewed Trick House source changed')
    need(m.name=='r110r0102_00_00'and not m.bones,'reviewed unskinned cushion source changed')
    s=m.submeshes[2];need(s.material=='cushions01','reviewed original material changed')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    q=open_bch(raw).models[0].meshes[2]
    need(s.positions==q.positions and s.uv0==q.texcoords,'independent source positions/UV differ')
    need(len(q.submeshes)==1 and [n for t in s.triangles for n in t]==q.submeshes[0].indices,'independent source indices differ')
    groups=components(s);need([(g[0],len(g))for g in groups]==[(0,128),(128,128),(256,128)],'reviewed three cushion components changed')
    p=source_part(s,'assets/scenery/oras-trick-house-cushion/cushions01.png',[s.triangles[i]for i in groups[0]])
    need(all(c==[1,1,1,1]for c in p['colors']),'original unlit cushion colors changed')
    loops=rims(p);need(len(loops)==1 and len(loops[0])==16 and all(abs(v[1]-1)<1e-7 for v in loops[0]),'reviewed open underside changed')
    closure=cap(p,loops[0],[8.5/64,8.5/64],[1,1,1,1]);closure['name']='authored_exact_cushion_underside'
    need(len(closure['indices'])//3==14,'exact original underside triangulation changed')
    t=next(t for t in lt(blob)if t.name=='cushions01');need((t.width,t.height)==(64,64)and set(t.rgba[3::4])=={255},'original opaque cushion texture changed')
    folder=output/'assets/scenery/oras-trick-house-cushion';folder.mkdir(parents=True,exist_ok=True);content=png(t.rgba,t.width,t.height);(folder/'cushions01.png').write_bytes(content)
    model,meta=normalized([p,closure]);(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/ImportedTrickCushionData.lua').write_text('-- Original ORAS Trick House floor cushion; tools/import_oras_trick_cushion.py.\nreturn '+lua({'oras_trick_house_floor_cushion':model})+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO372 -> AD165 -> MM279 -> GR629',model=m.name,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),submesh=2,component=0,originalTriangles=128,authoredClosureTriangles=14,textureSize=[64,64],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),**meta,processing='Original complete low floor cushion, original proportions, triangles, UV, opaque cloth texture and unlit white vertex RGBA retained. Exposed open underside closed at all sixteen exact original rim vertices; no floor, shadow or light source geometry. Uniform native one-cell fit and bottom-only .025 contact recess.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return model

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args();m=convert(a.model,a.textures,a.decoder,a.nitrogen,a.output);print('oras_trick_house_floor_cushion',sum(len(p['indices'])//3 for p in m['parts']))
