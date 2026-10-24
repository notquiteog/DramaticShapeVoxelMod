#!/usr/bin/env python3
"""Check actual fitted source bodies against all original runtime slider poses."""
import json,math,subprocess,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from oras_rear_closure import _clip,_area
SCRIPT=r'''
local function j(v)if type(v)=='number'or type(v)=='boolean'then return tostring(v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='table'then local o={};if #v>0 then for _,q in ipairs(v)do o[#o+1]=j(q)end;return'['..table.concat(o,',')..']'else for k,q in pairs(v)do o[#o+1]=j(k)..':'..j(q)end;return'{'..table.concat(o,',')..'}'end end;error(type(v))end
local modules={SceneryModelData={},ImportedTreeData={},ImportedHoennMartData=dofile('lib/ImportedHoennMartData.lua'),ImportedSlateportMartData=dofile('lib/ImportedSlateportMartData.lua'),ModelInstances={},BuildBudget={}}
local V={require=function(n)return assert(modules[n],n)end,mod={read=function()end}}
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local old=assert(loadfile('lib/Gen3MartDoors.lua'))(V);local slate=assert(loadfile('lib/Gen3SlateportMartDoors.lua'))(V);local out={}
for _,f in ipairs{{'oras_oldale_mart','oldale_mart'},{'oras_petalburg_mart','petalburg_city_mart'},{'oras_rustboro_mart','rustboro_city_mart'},{'oras_slateport_mart','slateport_city_mart'}}do
 local isSlate=f[1]=='oras_slateport_mart';local data=isSlate and modules.ImportedSlateportMartData or modules.ImportedHoennMartData;local D=isSlate and slate or old
 assert(S.register(f[1],data[f[1]],{read=function()end}));local body,fit=S.vertices(f[1],{groundInset=.05,width=64,depth=48,padding=.25,anchor='door',targetX=24,targetZ=isSlate and 41 or 44.5});assert(body,fit);fit.model=f[1]
 for _,p in ipairs(body)do for _,v in ipairs(p.vertices)do v[3]=v[3]+16 end;p.name='body_'..p.name end
 local g={cx=0,cy=0,kind='mart',width=4,depth=4,groundHeight=0,custom={family='rse',name=f[2]},importedHoenn=fit}
 for state=0,2 do local pieces={};for _,p in ipairs(body)do pieces[#pieces+1]=p end;for i,p in ipairs(assert(D.geometry(g,fit,state)))do p.name='door_'..i;pieces[#pieces+1]=p end;out[f[1]..':'..state]=pieces end
end;print(j(out))
'''
def overlap(a,b):
 if _area(b)<0:b=b[::-1]
 for i in range(3):a=_clip(a,b[i],b[(i+1)%3],True)
 return abs(_area(a))if len(a)>2 else 0
models=json.loads(subprocess.check_output(['luajit','-e',SCRIPT],text=True));pairs=0;bad=[]
for name,parts in models.items():
 groups={}
 for p in parts:
  vs=p['vertices']
  for i in range(0,len(p['indices']),3):
   tri=[vs[k-1][:3]for k in p['indices'][i:i+3]];a,b,c=tri;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];length=math.sqrt(sum(q*q for q in n))
   if length<1e-10:continue
   n=[q/length for q in n];axis=max(range(3),key=lambda k:abs(n[k]));n=[q*(1 if n[axis]>0 else -1)for q in n];d=sum(n[k]*a[k]for k in range(3));groups.setdefault(tuple(round(q,5)for q in n),[]).append((d,p['name'],i//3,[[q[k]for k in range(3)if k!=axis]for q in tri]))
 for group in groups.values():
  group.sort(key=lambda q:q[0])
  for i,a in enumerate(group):
   for b in group[i+1:]:
    if b[0]-a[0]>.00005:break
    if a[1].startswith('door_')==b[1].startswith('door_'):continue
    pairs+=1;area=overlap(a[3],b[3])
    if area>1e-7:bad.append((name,a[1:3],b[1:3],area))
assert not bad,repr(bad[:20])
assert len(models)==12
print('PASS12 actual fitted Mart/slider states,',pairs,'body-door coplanar candidates, zero overlapping area')
