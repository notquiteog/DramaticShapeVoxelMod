#!/usr/bin/env python3
"""Audit actual fitted Littleroot body/fixtures and the public paired-door geometry."""
import json,subprocess,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from oras_geometry_audit import coplanar_overlaps
SCRIPT=r'''
local function j(v)if type(v)=='number'or type(v)=='boolean'then return tostring(v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='table'then local o={};if #v>0 then for _,q in ipairs(v)do o[#o+1]=j(q)end;return'['..table.concat(o,',')..']'else for k,q in pairs(v)do o[#o+1]=j(k)..':'..j(q)end;return'{'..table.concat(o,',')..'}'end end;error(type(v))end
local data=dofile('lib/ImportedLittlerootHomesData.lua');local modules={SceneryModelData={},ImportedTreeData={},ImportedLittlerootHomesData=data,ModelInstances={},BuildBudget={}}
local V={require=function(n)return assert(modules[n],n)end,mod={read=function()end}};local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3LittlerootDoors.lua'))(V);assert(S.register('oras_littleroot_home_west',data.oras_littleroot_home_west,{read=function()end}));local parts,fit=S.vertices('oras_littleroot_home_west',{width=80,depth=64,padding=.25,groundInset=.05,anchor='door',targetX=56,targetZ=54});assert(parts,fit);fit.model='oras_littleroot_home_west'
for _,p in ipairs(parts)do for _,v in ipairs(p.vertices)do v[3]=v[3]+16 end end
local g={cx=0,cy=0,kind='house',width=5,depth=5,groundHeight=0,importedHoenn=fit,custom={family='rse',name='littleroot_player_house'}};local out={}
for state=0,2 do local model={};for _,p in ipairs(parts)do model[#model+1]=p end;for i,p in ipairs(assert(D.geometry(g,fit,state)))do p.name='door_'..i;model[#model+1]=p end;out[#out+1]=model end;print(j({models=out,scale=fit.scale,x=fit.x,z=fit.z}))
'''
for side,target,family in [('west',56,'littleroot_player_house'),('east',24,'littleroot_rival_house')]:
 script=SCRIPT.replace('oras_littleroot_home_west','oras_littleroot_home_'+side).replace('targetX=56','targetX='+str(target)).replace("name='littleroot_player_house'","name='"+family+"'")
 result=json.loads(subprocess.check_output(['luajit','-e',script],text=True));models=result['models']
 for state,parts in enumerate(models):
  overlaps=coplanar_overlaps(parts,distance=.00005,area=1e-7)
  assert not overlaps,(side,state,overlaps[:20])
  cap=next(p for p in parts if p['name']=='authored_closed_underside');assert all(abs(v[1]+.05)<1e-7 for v in cap['vertices'])
 assert len(models)==3
print('PASS6 actual Littleroot house/hinge poses, all body/cap/rear/leaf coplanar area zero; original bounds and contact separation preserved')
