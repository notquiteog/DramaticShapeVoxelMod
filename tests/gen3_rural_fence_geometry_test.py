"""Actual original-source rural unions remain closed at joins and within cells."""
import json
import collections
from pathlib import Path
import subprocess
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from oras_geometry_audit import coplanar_overlaps
root = Path(__file__).resolve().parents[1]
encoder = r'''local function j(v)if type(v)=='number'then return string.format('%.17g',v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='boolean'then return tostring(v)end local a={}if #v>0 then for _,x in ipairs(v)do a[#a+1]=j(x)end return '['..table.concat(a,',')..']'end for k,x in pairs(v)do a[#a+1]=j(tostring(k))..':'..j(x)end return '{'..table.concat(a,',')..'}'end io.write(j(dofile('lib/ImportedRuralFenceData.lua')))'''
models = json.loads(subprocess.check_output(['luajit', '-e', encoder], cwd=root))
assert len(models) == 9
for name, model in models.items():
    assert not coplanar_overlaps(model['parts']), name
    assert model['anchors']['center'] == [8, 0, 8]
    # Split T-junction edges before counting. The clipping factory may add a
    # midpoint on one face while its closed neighbor retains the longer edge.
    points = {tuple(round(v[k], 6) for k in range(3))
              for p in model['parts'] for v in p['vertices']}
    edges = collections.Counter()
    for part in model['parts']:
        for i in range(0, len(part['indices']), 3):
            triangle = [part['vertices'][n - 1] for n in part['indices'][i:i + 3]]
            for j in range(3):
                a, b = [tuple(round(v[k], 6) for k in range(3))
                        for v in (triangle[j], triangle[(j + 1) % 3])]
                d = [b[k] - a[k] for k in range(3)]
                length = sum(v * v for v in d)
                if length < 1e-12:
                    continue
                cuts = []
                for point in points:
                    t = sum((point[k] - a[k]) * d[k] for k in range(3)) / length
                    if -1e-7 <= t <= 1 + 1e-7 and sum((point[k] - a[k] - t * d[k]) ** 2 for k in range(3)) < 1e-12:
                        cuts.append((t, point))
                cuts.sort()
                for (_, x), (_, y) in zip(cuts, cuts[1:]):
                    if x != y:
                        edges[tuple(sorted((x, y)))] += 1
    assert all(count == 2 for count in edges.values()), (name, collections.Counter(edges.values()))
    vertices = [v for p in model['parts'] for v in p['vertices']]
    assert min(v[1] for v in vertices) == 0 and max(v[1] for v in vertices) == 10.25
    for p in model['parts']:
        assert p['texture'] == 'assets/scenery/oras-fences/chip_steps01.png'
        assert p['vertexColorRole'] == 'lighting' and p['opacity'] == 1
        for v in p['vertices']:
            assert 0 <= v[0] <= 16 and 0 <= v[2] <= 16, (name, v)
            assert 0 <= v[3] <= 1 and 0 <= v[4] <= 1 and v[5] == 1, (name, v)
print('PASS9 real rural source unions, closed atomic edges, zero coplanar area, original paint/UV/material/height and blocked bounds')
