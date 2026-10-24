#!/usr/bin/env python3
"""Audit actual fitted Museum body/fixtures and the public paired-door geometry."""
import json,subprocess,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from oras_geometry_audit import coplanar_overlaps
SCRIPT=r'''
local function j(v)if type(v)=='number'or type(v)=='boolean'then return tostring(v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='table'then local o={};if #v>0 then for _,q in ipairs(v)do o[#o+1]=j(q)end;return'['..table.concat(o,',')..']'else for k,q in pairs(v)do o[#o+1]=j(k)..':'..j(q)end;return'{'..table.concat(o,',')..'}'end end;error(type(v))end
local data=dofile('lib/ImportedSlateportMuseumData.lua');local modules={SceneryModelData={},ImportedTreeData={},ImportedSlateportMuseumData=data,ModelInstances={},BuildBudget={}}
local V={require=function(n)return assert(modules[n],n)end,mod={read=function()end}};local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3MuseumDoors.lua'))(V);assert(S.register('oras_slateport_museum',data.oras_slateport_museum,{read=function()end}));local parts,fit=S.vertices('oras_slateport_museum',{width=96,depth=64,padding=.25,groundInset=.05,anchor='door',targetX=48,targetZ=59.25});assert(parts,fit);fit.model='oras_slateport_museum'
for _,p in ipairs(parts)do for _,v in ipairs(p.vertices)do v[3]=v[3]+16 end end
local g={cx=0,cy=0,kind='oceanic_museum',width=6,depth=5,groundHeight=0,importedHoenn=fit,custom={family='rse',name='slateport_oceanic_museum'}};local out={}
for state=0,2 do local model={};for _,p in ipairs(parts)do model[#model+1]=p end;for i,p in ipairs(assert(D.geometry(g,fit,state)))do p.name='door_'..i;model[#model+1]=p end;out[#out+1]=model end;print(j(out))
'''
models=json.loads(subprocess.check_output(['luajit','-e',SCRIPT],text=True))
for state,parts in enumerate(models):
 overlaps=coplanar_overlaps(parts,distance=.00005,area=1e-7)
 assert not overlaps,(state,overlaps[:20])
 cap=next(p for p in parts if p['name']=='authored_closed_underside');assert all(abs(v[1]+.05)<1e-7 for v in cap['vertices'])
 source=[v for p in parts[:3]for v in p['vertices']];bounds=[min(v[k]for v in source)for k in range(3)]+[max(v[k]for v in source)for k in range(3)]
 shell=next(p for p in parts if p['name']=='authored_roof_fixture_shells');assert all(bounds[k]-1e-6<=v[k]<=bounds[k+3]+1e-6 for v in shell['vertices']for k in range(3))
 if state==0:
  left=next(p for p in parts if p['name']=='door_1');right=next(p for p in parts if p['name']=='door_2');assert min(v[0]for v in right['vertices'])-max(v[0]for v in left['vertices'])>.0999,'closed original leaf caps still share a plane'
assert len(models)==3
print('PASS3 actual Museum poses, all body/cap/roof-shell/leaf coplanar area zero; original bounds and ground inset preserved')
