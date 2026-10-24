#!/usr/bin/env python3
"""Audit actual fitted Harbor body/fixtures and the public paired-door geometry."""
import json,subprocess,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from oras_geometry_audit import coplanar_overlaps
SCRIPT=r'''
local function j(v)if type(v)=='number'or type(v)=='boolean'then return tostring(v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='table'then local o={};if #v>0 then for _,q in ipairs(v)do o[#o+1]=j(q)end;return'['..table.concat(o,',')..']'else for k,q in pairs(v)do o[#o+1]=j(k)..':'..j(q)end;return'{'..table.concat(o,',')..'}'end end;error(type(v))end
local data=dofile('lib/ImportedSlateportHarborData.lua');local modules={SceneryModelData={},ImportedTreeData={},ImportedSlateportHarborData=data,ModelInstances={},BuildBudget={}}
local V={require=function(n)return assert(modules[n],n)end,mod={read=function()end}};local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local D=assert(loadfile('lib/Gen3HarborDoors.lua'))(V);assert(S.register('oras_slateport_harbor',data.oras_slateport_harbor,{read=function()end}));local parts,fit=S.vertices('oras_slateport_harbor',{width=112,depth=80,padding=.25,groundInset=.05,anchor='door',targetX=56,targetZ=74.25});assert(parts,fit);fit.model='oras_slateport_harbor'
for _,p in ipairs(parts)do for _,v in ipairs(p.vertices)do v[3]=v[3]+16 end end
local g={cx=0,cy=0,kind='harbor',width=7,depth=6,groundHeight=0,importedHoenn=fit,custom={family='rse',name='slateport_harbor'}};local out={}
for state=0,2 do local model={};for _,p in ipairs(parts)do model[#model+1]=p end;for i,p in ipairs(assert(D.geometry(g,fit,state)))do p.name='door_'..i;model[#model+1]=p end;out[#out+1]=model end;print(j({models=out,scale=fit.scale,x=fit.x,z=fit.z}))
'''
result=json.loads(subprocess.check_output(['luajit','-e',SCRIPT],text=True));models=result['models']
for state,parts in enumerate(models):
 overlaps=coplanar_overlaps(parts,distance=.00005,area=1e-7)
 assert not overlaps,(state,overlaps[:20])
 cap=next(p for p in parts if p['name']=='authored_closed_underside');assert all(abs(v[1]+.05)<1e-7 for v in cap['vertices'])
 if state==0:
  left=next(p for p in parts if p['name']=='door_1');right=next(p for p in parts if p['name']=='door_2');assert min(v[0]for v in right['vertices'])-max(v[0]for v in left['vertices'])>.0999,'closed original leaf caps still share a plane'
assert len(models)==3
print('PASS3 actual Harbor poses, all body/cap/rear/leaf coplanar area zero; original bounds and ground inset preserved')

def side_hit(parts,y,z):
 hits=[]
 for part in parts:
  for at in range(0,len(part['indices']),3):
   rows=[part['vertices'][i-1]for i in part['indices'][at:at+3]];a,b,c=rows
   den=(b[2]-c[2])*(a[1]-c[1])+(c[1]-b[1])*(a[2]-c[2])
   if abs(den)<1e-12:continue
   u=((b[2]-c[2])*(y-c[1])+(c[1]-b[1])*(z-c[2]))/den;v=((c[2]-a[2])*(y-c[1])+(a[1]-c[1])*(z-c[2]))/den
   if min(u,v,1-u-v)>-1e-8:hits.append((u*a[0]+v*b[0]+(1-u-v)*c[0],part['name']))
 return min(hits)if hits else None
point_y=20/267*result['scale'];point_z=(100-171)/267*result['scale']+result['z']+16
for parts in models:
 hit=side_hit(parts,point_y,point_z);assert hit and hit[1]=='Comb2',('original physical wall omitted',hit)
 old=side_hit([p for p in parts if p['name']!='Comb2'],point_y,point_z);assert not old or old[0]>hit[0]+1,('wall coverage regression fixture no longer detects omission',old,hit)
print('PASS original Comb2/t106_02 side-wall ray coverage; omission baseline rejected')
