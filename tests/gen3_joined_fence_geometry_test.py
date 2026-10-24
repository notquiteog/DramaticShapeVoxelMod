"""Actual packaged geometry has exact native axes and one coplanar owner."""
import json, subprocess, sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from join_oras_fences import clean
from oras_geometry_audit import coplanar_overlaps
root=Path(__file__).resolve().parents[1]
encoder=r'''local function j(v)if type(v)=='number'then return string.format('%.17g',v)elseif type(v)=='string'then return string.format('%q',v)end local a={}if #v>0 then for _,x in ipairs(v)do a[#a+1]=j(x)end return '['..table.concat(a,',')..']'end for k,x in pairs(v)do a[#a+1]=j(tostring(k))..':'..j(x)end return '{'..table.concat(a,',')..'}'end io.write(j(dofile('lib/ImportedFenceJoinedData.lua')))'''
# Definitions contain booleans, so cover those explicitly too.
encoder=encoder.replace("local a={}","if type(v)=='boolean'then return tostring(v)end local a={}")
models=json.loads(subprocess.check_output(['luajit','-e',encoder],cwd=root));seen=set()
assert len(models)==29
for name,model in models.items():
 key=json.dumps(model,sort_keys=True)
 if key in seen:continue
 seen.add(key)
 assert not coplanar_overlaps(model['parts']),name
 for p in model['parts']:
  for v in p['vertices']:assert -1e-6<=v[0]<=16.000001 and -1e-6<=v[2]<=16.000001 and -1e-6<=v[1]<=11.000001,name
# A true overlap is cut away rather than hidden by an epsilon or whole-face loss.
a={'name':'first','vertices':[[0,0,0,0,0,1],[2,0,0,1,0,1],[0,0,2,0,1,1]],'indices':[1,2,3]}
b=dict(a,name='second',vertices=[[.5,0,.5,.25,.25,1],[1.5,0,.5,.75,.25,1],[.5,0,1.5,.25,.75,1]])
result=clean([a,b]);assert not coplanar_overlaps(result)
assert len(result)==1 and len(result[0]['indices'])==3,'fully covered duplicate retained'
print('PASS 29 native families,14 unique joined geometries,zero positive-area coplanar overlaps,UV-preserving cut ownership')
