"""Actual original Verdanturf pickets retain closed physical source geometry."""
import collections
import json
from pathlib import Path
import subprocess
import sys
root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root/'tools'))
from oras_geometry_audit import coplanar_overlaps
encoder=r'''local function j(v)if type(v)=='number'then return string.format('%.17g',v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='boolean'then return tostring(v)end local a={}if #v>0 then for _,x in ipairs(v)do a[#a+1]=j(x)end return '['..table.concat(a,',')..']'end for k,x in pairs(v)do a[#a+1]=j(tostring(k))..':'..j(x)end return '{'..table.concat(a,',')..'}'end io.write(j(dofile('lib/ImportedVerdanturfFenceData.lua')))'''
models=json.loads(subprocess.check_output(['luajit','-e',encoder],cwd=root))
assert set(models)=={'oras_verdanturf_pickets'}
m=models['oras_verdanturf_pickets'];assert m['anchors']['center']==[8,0,8]
assert not coplanar_overlaps(m['parts'])
p=m['parts'][0];v=p['vertices'];assert len(p['indices'])==102
assert p['texture']=='assets/scenery/oras-verdanturf-fence/sidake_waku.png'
assert p['vertexColorRole']=='lighting' and p['opacity']==1
edges=collections.Counter()
for i in range(0,len(p['indices']),3):
    tri=[v[j-1]for j in p['indices'][i:i+3]]
    for n in range(3):edges[tuple(sorted((tuple(tri[n][:3]),tuple(tri[(n+1)%3][:3]))))]+=1
assert all(n==2 for n in edges.values()),collections.Counter(edges.values())
for low,high,height in [(2.25,4.75,10.75),(10.25,12.75,11)]:
    post=[r for r in v if low<=r[0]<=high]
    assert len(post)>0 and min(r[0]for r in post)==low and max(r[0]for r in post)==high
    assert min(r[1]for r in post)==0 and max(r[1]for r in post)==height
    assert min(r[2]for r in post)==13 and max(r[2]for r in post)==15
assert all(0<=r[3]<=1 and 0<=r[4]<=1 and r[5]==1 for r in v)
print('PASS exact original alternating pickets/34 triangles/closed edges2/coplanarzero/source UV and native anchors')
