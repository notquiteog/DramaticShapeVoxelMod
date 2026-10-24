"""Actual Mauville source solids, cutout holes, UVs and joined cell bounds."""
import collections
import json
from pathlib import Path
import subprocess
import sys
from PIL import Image
root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root / 'tools'))
from oras_geometry_audit import coplanar_overlaps
encoder = r'''local function j(v)if type(v)=='number'then return string.format('%.17g',v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='boolean'then return tostring(v)end local a={}if #v>0 then for _,x in ipairs(v)do a[#a+1]=j(x)end return '['..table.concat(a,',')..']'end for k,x in pairs(v)do a[#a+1]=j(tostring(k))..':'..j(x)end return '{'..table.concat(a,',')..'}'end io.write(j(dofile('%s')))'''
def load(path):
    return json.loads(subprocess.check_output(['luajit', '-e', encoder.replace('%s', path)], cwd=root))
def closed_atomic(model):
    # The exact source caps and rectangle-coalesced panels have T junctions.
    # Split at every physical vertex before testing closed boundary ownership.
    points = {tuple(round(v[k], 6) for k in range(3))
              for p in model['parts'] for v in p['vertices']}
    edges = collections.Counter()
    for part in model['parts']:
        for i in range(0, len(part['indices']), 3):
            tri = [part['vertices'][n - 1] for n in part['indices'][i:i+3]]
            for j in range(3):
                a,b = [tuple(round(v[k],6) for k in range(3))
                       for v in (tri[j],tri[(j+1)%3])]
                d = [b[k]-a[k] for k in range(3)]
                length = sum(v*v for v in d)
                if length < 1e-12:continue
                cuts = []
                for point in points:
                    t = sum((point[k]-a[k])*d[k] for k in range(3))/length
                    if -1e-7 <= t <= 1+1e-7 and sum((point[k]-a[k]-t*d[k])**2 for k in range(3))<1e-12:
                        cuts.append((t,point))
                cuts.sort()
                for (_,x),(_,y) in zip(cuts,cuts[1:]):
                    if x!=y:edges[tuple(sorted((x,y)))]+=1
    assert all(n==2 for n in edges.values()),collections.Counter(edges.values())
primitives = load('lib/ImportedMauvilleFencePrimitives.lua')
assert len(primitives)==8
for model in primitives.values():closed_atomic(model)
# Original source alpha remains physical holes rather than an opaque card.
image = Image.open(root/'assets/scenery/oras-mauville-fences/c103_saku.png').convert('RGBA')
assert image.size==(32,32) and sum(image.getpixel((x,y))[3]>0 for y in range(32)for x in range(32))==476
panel=primitives['oras_mauville_fence_16']['parts'][1]
def contains(p,tri):
    a,b,c=tri
    def cross(a,b,p):return (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0])
    side=[cross(a,b,p),cross(b,c,p),cross(c,a,p)]
    return min(side)>=-1e-10 or max(side)<=1e-10
front=[]
for at in range(0,len(panel['indices']),3):
    tri=[panel['vertices'][i-1]for i in panel['indices'][at:at+3]]
    if all(abs(v[2]-.06)<1e-8 for v in tri):front.append([[v[0],v[1]]for v in tri])
for y in range(32):
    for x in range(32):
        point=[(x+.5)*.5,10-(y+.5)*7/32]
        assert any(contains(point,t)for t in front)==(image.getpixel((x,y))[3]>0),(x,y)
models=load('lib/ImportedMauvilleFenceData.lua');assert len(models)==11
count=0
for name,model in models.items():
    assert not coplanar_overlaps(model['parts']),name
    assert model['anchors']['center']==[8,0,8]
    for p in model['parts']:
        assert p['texture'] in {'assets/scenery/oras-fences/chip_saku02.png','assets/scenery/oras-mauville-fences/c103_saku.png'}
        assert p['vertexColorRole']=='lighting' and p['opacity']==1
        count+=len(p['vertices'])
        for v in p['vertices']:
            assert all(-1e-8<=v[k]<=16.00000001 for k in (0,2)),(name,v)
            assert 0<=v[1]<=11 and 0<=v[3]<=1 and 0<=v[4]<=1 and v[5]==1
assert count<30000,count
print('PASS8 closed source primitives/476 exact alpha texels/11 joined native models: coplanarzero, original paint/UV, cell bounds and bounded catalog')
