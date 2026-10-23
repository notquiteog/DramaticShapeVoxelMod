#!/usr/bin/env python3
"""Real source-model ray coverage and new closure coplanarity regression."""
import json,math,subprocess,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from oras_rear_closure import _clip,_area
SCRIPT=r'''
local function j(v)if type(v)=='number'or type(v)=='boolean'then return tostring(v)elseif type(v)=='string'then return string.format('%q',v)elseif type(v)=='table'then local o={};if #v>0 then for _,q in ipairs(v)do o[#o+1]=j(q)end;return'['..table.concat(o,',')..']'else for k,q in pairs(v)do o[#o+1]=j(k)..':'..j(q)end;return'{'..table.concat(o,',')..'}'end end;error(type(v))end
local out={};for _,n in ipairs{'HoennGym','HoennMart','OldaleHomes','PetalburgHomes','RustboroHomes'}do for k,m in pairs(dofile('lib/Imported'..n..'Data.lua'))do if k:match('^oras_')and not k:match('notice$')then out[k]=m end end end;print(j(out))
'''
models=json.loads(subprocess.check_output(['luajit','-e',SCRIPT],text=True))
def triangles(parts):
 for part in parts:
  for at in range(0,len(part['indices']),3):yield part['name'],[part['vertices'][i-1][:3]for i in part['indices'][at:at+3]]
def rear_hit(parts,x,y):
 out=[]
 for name,(a,b,c)in triangles(parts):
  den=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
  if abs(den)<1e-12:continue
  u=((b[1]-c[1])*(x-c[0])+(c[0]-b[0])*(y-c[1]))/den;v=((c[1]-a[1])*(x-c[0])+(a[0]-c[0])*(y-c[1]))/den
  if min(u,v,1-u-v)>-1e-8:out.append((u*a[2]+v*b[2]+(1-u-v)*c[2],name))
 return min(out)if out else None
def overlap(a,b):
 if _area(b)<0:b=b[::-1]
 for i in range(3):a=_clip(a,b[i],b[(i+1)%3],True)
 return abs(_area(a))if len(a)>2 else 0
rays=0;pairs=0
for name,model in models.items():
 parts=model['parts'];rear=next(p for p in parts if p['name']=='authored_closed_rear');original=[p for p in parts if p is not rear];vs=[v for p in original for v in p['vertices']];bounds=[min(v[k]for v in vs)for k in range(3)]+[max(v[k]for v in vs)for k in range(3)]
 assert all(bounds[k]-1e-6<=v[k]<=bounds[k+3]+1e-6 for v in rear['vertices']for k in range(3)),name+' closure changed source bounds'
 for yf in[.08,.2,.4]:
  for xf in[.25,.5,.75]:
   x=bounds[0]+(bounds[3]-bounds[0])*xf;y=bounds[1]+(bounds[4]-bounds[1])*yf;hit=rear_hit(parts,x,y);old=rear_hit(original,x,y)
   assert hit and hit[1]=='authored_closed_rear' and hit[0]<bounds[2]+(bounds[5]-bounds[2])*.3,(name,'unclosed rear',xf,yf,hit,old)
   rays+=1
 # Detect real overlapping coplanar area, including each new join against
 # original roof/trim and the other authored closure triangles.
 groups={}
 for part,tri in triangles(parts):
  a,b,c=tri;u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)];n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];length=math.sqrt(sum(q*q for q in n))
  if length<1e-12:continue
  n=[q/length for q in n];axis=max(range(3),key=lambda k:abs(n[k]));n=[q*(1 if n[axis]>0 else -1)for q in n];d=sum(n[k]*a[k]for k in range(3));groups.setdefault(tuple(round(q,6)for q in n),[]).append((d,part,[[q[k]for k in range(3)if k!=axis]for q in tri]))
 for group in groups.values():
  group.sort(key=lambda q:q[0])
  for i,a in enumerate(group):
   for b in group[i+1:]:
    if b[0]-a[0]>1e-6:break
    if 'authored_closed_rear'not in[a[1],b[1]]and not('oldale_home'in name and a[1]==b[1]=='chip_mado'):continue
    pairs+=1;assert overlap(a[2],b[2])<1e-8,(name,'coplanar rear overlap',a[1],b[1])
assert len(models)==15
print('PASS15 real source rear closures,',rays,'rear rays, unchanged bounds,',pairs,'coplanar pairs checked')
