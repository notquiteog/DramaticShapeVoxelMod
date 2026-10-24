#!/usr/bin/env python3
"""Export actual original Verdanturf pointed pickets; explicit local inputs only."""
import argparse
import hashlib
import json
from pathlib import Path
from types import SimpleNamespace
from import_oras_fences import part,primitive
from import_oras_grass import lua
from oras_scenery_source import decoder,need

def export(model_path,texture_path,decoder_path,output):
    load,textures,png=decoder(decoder_path)
    raw,tex_raw=model_path.read_bytes(),texture_path.read_bytes()
    model=load(raw)[0];need(model.name=='world06_02_02','unreviewed Verdanturf source')
    s=model.submeshes[3];need(s.material=='sidake_house_sidake_waku'and len(s.triangles)==2102,'source topology changed')
    tx=next(t for t in textures(tex_raw)if t.name=='sidake_waku')
    need((tx.width,tx.height)==(128,128),'source paint changed')
    triangles=[];proof=[]
    for low,high,target,expected in [(317,322,3.5,12),(308,313,11.5,11)]:
        ids=[i for i,t in enumerate(s.triangles)if all(low<=s.positions[k][0]<=high and -29<=s.positions[k][2]<=-25 and 0<=s.positions[k][1]<=22 for k in t)]
        need(len(ids)==expected,'reviewed source picket changed')
        selected=SimpleNamespace(positions=s.positions,uv0=s.uv0,triangles=[s.triangles[i]for i in ids])
        closed,added=primitive(selected,0,len(ids))
        center=(low+high)/2
        triangles.extend([[[target+(v[0]-center)*.5,v[1]*.5,14+(v[2]+27)*.5]+v[3:]for v in tri]for tri in closed])
        proof.append(dict(sourceTriangles=ids,authoredClosureTriangles=added,nativeCenter=target))
    folder=output/'assets/scenery/oras-verdanturf-fence';folder.mkdir(parents=True,exist_ok=True)
    (folder/'sidake_waku.png').write_bytes(png(tx.rgba,tx.width,tx.height))
    data={'oras_verdanturf_pickets':dict(parts=[part('original_verdanturf_closed_pointed_pickets','assets/scenery/oras-verdanturf-fence/sidake_waku.png',triangles)],anchors={'center':[8,0,8]})}
    (output/'lib/ImportedVerdanturfFenceData.lua').write_text('-- Original GR0054/AD0013 pointed pickets; no raw inputs bundled.\nreturn '+lua(data)+'\n')
    report=dict(source='User supplied original Alpha Sapphire RomFS',model='GR0054 slot1 world06_02_02 submesh3 sidake_house_sidake_waku',textures='AD0013 slot11 sidake_waku',modelSha256=hashlib.sha256(raw).hexdigest(),textureSha256=hashlib.sha256(tex_raw).hexdigest(),sourceScale=.5,originalSourcePostHeights=[21.5,22],pickets=proof,processing='Original alternating pointed pickets and original paint/UVs. Absent source backs/undersides close using source edge paint. No invented rails, source shadow sheets or baked vertex lighting. Native activation evidence separate.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return report
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for k in ('model','textures','decoder','output'):p.add_argument('--'+k,type=Path,required=True)
    a=p.parse_args();print(json.dumps(export(a.model,a.textures,a.decoder,a.output),indent=2))
