#!/usr/bin/env python3
"""Read-only source proof; explicit external BCH/decoder arguments required."""
import argparse, copy, hashlib, json, sys, tempfile
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import import_oras_boat as I

p=argparse.ArgumentParser(description=__doc__)
for name in ('model','textures','decoder','nitrogen'):p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();root=Path(__file__).resolve().parents[1]
load,decode,png=I.decoder(a.decoder)
sys.path.insert(0,str(a.nitrogen))
from nitrogen.platforms.ctr.bch import open_bch
model=load(a.model.read_bytes())[0];independent=open_bch(a.model.read_bytes()).models[0]
saved=copy.deepcopy(model);parts,proof=I.bake(model,independent)
assert model==saved and proof['inverseBindMaxError']==0
assert proof['independentPositionsUvIndicesAndRigidPalettesEqual']
assert proof['vertexLightingCleanup']['changedRgbVertices']==223
original=copy.deepcopy(parts);closure=I.close_hull(parts)
assert parts[:-1]==original and closure['authoredTriangles']==16
assert min(v[1]for part in parts for v in part['vertices'])==min(v[1]for part in original for v in part['vertices'])
for part in parts:
    for v in part['vertices']:assert v[6:9]==[1.,1.,1.] and 0<=v[9]<=1
for mode in ('rotation','weights','inverse','positions','uv'):
    m,n=copy.deepcopy(model),copy.deepcopy(independent)
    if mode=='rotation':m.bones[0].rotation=(.1,0,0)
    elif mode=='weights':m.submeshes[0].bones[0]=[1,2];m.submeshes[0].weights[0]=[.5,.5]
    elif mode=='inverse':n.skeleton[1].inverse_bind[11]=0
    elif mode=='positions':n.meshes[0].positions[0]=(999,0,0)
    elif mode=='uv':n.meshes[0].texcoords[0]=(999,0)
    try:I.bake(m,n)
    except ValueError:pass
    else:raise AssertionError('accepted unreviewed '+mode)
with tempfile.TemporaryDirectory()as tmp:
    out=Path(tmp);data,report=I.convert(a.model,a.textures,a.decoder,a.nitrogen,out)
    assert (out/'lib/OrasBoatData.lua').read_bytes()==(root/'lib/OrasBoatData.lua').read_bytes()
    folder=Path('assets/scenery/oras-briney-boat')
    assert report==json.loads((root/folder/'provenance.json').read_text())
    for name,texture in report['textures'].items():
        content=(out/folder/(name+'.png')).read_bytes()
        assert content==(root/folder/(name+'.png')).read_bytes()
        assert hashlib.sha256(content).hexdigest()==texture['pngSha256']
print('PASS deterministic genuine boat source, independent rigid bind/geometry/UV/index proof, strict pose rejection,223vertex-AO cleanup, unchanged alpha/textures and bounded16triangle keel')
