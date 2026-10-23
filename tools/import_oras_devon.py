#!/usr/bin/env python3
"""Export original ORAS Devon Corporation and BM0014 paired doors from supplied source."""
import argparse,hashlib,json,math,struct,sys
from pathlib import Path
from oras_scenery_source import decoder,need,garc,mini,decompress
from oras_rear_closure import close_rear,_subtract,_area
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def triangulate(poly):
 def cross(a,b,c):return(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
 clean=[]
 for point in poly:
  if not clean or max(abs(a-b)for a,b in zip(point,clean[-1]))>1e-9:clean.append(point)
 if len(clean)>1 and max(abs(a-b)for a,b in zip(clean[0],clean[-1]))<1e-9:clean.pop()
 poly=clean
 changed=True
 while changed and len(poly)>3:
  changed=False
  for i in range(len(poly)):
   if abs(cross(poly[i-1],poly[i],poly[(i+1)%len(poly)]))<1e-12:poly.pop(i);changed=True;break
 if len(poly)<3 or abs(_area(poly))<1e-14:return []
 if _area(poly)<0:poly=poly[::-1]
 loop=list(range(len(poly)));out=[]
 while len(loop)>3:
  for at,n in enumerate(loop):
   a,c=loop[at-1],loop[(at+1)%len(loop)]
   if cross(poly[a],poly[n],poly[c])<1e-14:continue
   if any(all(cross(poly[u],poly[v],poly[k])>=-1e-14 for u,v in[(a,n),(n,c),(c,a)])for k in loop if k not in[a,n,c]):continue
   out.append([poly[a],poly[n],poly[c]]);loop.pop(at);break
  else:raise ValueError('Devon source underside cannot be triangulated')
 out.append([poly[k]for k in loop]);return out

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-devon';folder.mkdir(parents=True,exist_ok=True);textures={};banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0011/{k:03d}.bch').read_bytes())}for k in[1,11]}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-devon/'+key+'.png'
 grarchive=garc((root/'alpha-sapphire-romfs/a/0/3/9').read_bytes());gr=mini(grarchive.single(33),'GR');raw=(root/'mapgr-nitrogen/9/0033/001.bch').read_bytes();need(decompress(gr[1])==raw,'original Devon static source differs')
 objects=gr[3];need(any((lambda o:o[0]==14 and o[1:4]==(1.,1.,1.)and o[4:7]==(0.,0.,0.)and o[7:10]==(2205.,0.,3141.))(struct.unpack_from('<I10f',objects,4+i*44))for i in range(struct.unpack_from('<I',objects)[0])),'Devon BM14 placement differs')
 entities=mini(garc((root/'alpha-sapphire-romfs/a/0/1/3').read_bytes()).single(16),'ZO')[1];nf,nn,nw,nt=struct.unpack_from('<4B',entities,4);warps=[]
 for i in range(nw):
  record=entities[12+nf*20+nn*48+i*24:12+nf*20+nn*48+(i+1)*24]
  if struct.unpack_from('<3h',record,8)[::2]==(2205,3141):warps.append(struct.unpack_from('<H',record)[0])
 need(len(warps)==1,'Devon original zone doorway absent')
 model=load(raw)[0];ind=open_bch(raw).models[0];parts=[];counts={};span=198.;origin=[-315.,.25,-99.]
 for i,sub in enumerate(model.submeshes):
  if sub.material not in['devon_waku','devon_corp','mado_devon1']:continue
  ni=ind.meshes[i];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[k for t in sub.triangles for k in t],'independent Devon static geometry differs');need(not sub.colors or all(abs(c[3]-1)<1e-8 for c in sub.colors),'Devon physical alpha needs review')
  need(not any(all(abs(sub.positions[k][1]-.25)<1e-7 for k in tri)for tri in sub.triangles),'Devon source ground plane needs review')
  rows=[[(p[k]-origin[k])/span for k in range(3)]+[uv[0],1-uv[1],1.]for p,uv in zip(sub.positions,sub.uv0)];parts.append(dict(name=sub.material,texture=texture(next(m.base_color_texture for m in model.materials if m.name==sub.material),11),vertices=rows,indices=[k+1 for t in sub.triangles for k in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'));counts[sub.material]=len(sub.triangles)
 need(counts==dict(devon_waku=876,devon_corp=629,mado_devon1=92),'Devon original topology changed')
 # Exact body footprint, including the actual curved entrance and portal recess.
 corp=next(p for p in parts if p['name']=='devon_corp');bottom=[v for v in corp['vertices']if abs(v[1])<1e-7];poly=[(-93,-96.5),(93,-96.5),(93,-57.5),(93,-16.5),(64,-16.5),(39,-16.5),(28.4279,-4.7642),(20.9319,-.2346),(13.9762,2.16),(13.9762,-3.5),(-13.9762,-3.5),(-13.9762,2.16),(-20.9319,-.2346),(-28.4279,-4.7642),(-39,-16.5),(-64.5,-16.5),(-93,-16.5),(-93,-57.5)]
 exact=[]
 for x,z in poly:
  v=next((v for v in bottom if abs(v[0]*span-x)<.001 and abs(v[2]*span-z)<.001),None);need(v is not None,'Devon bottom perimeter changed');exact.append([v[0],v[2]])
 caps=triangulate(exact)
 # Pedestal bottoms extend outside the main curved wall; subtract the existing
 # body cap before adding them, avoiding hidden duplicate coplanar undersides.
 waku=next(p for p in parts if p['name']=='devon_waku')
 for side in[-1,1]:
  polygon=[]
  for x,z in[(39,-19),(39,-4.5),(28,-4.5056),(28,-11.5)]:
   v=next((v for v in waku['vertices']if abs(v[0]*span-side*x)<.001 and abs(v[1])<1e-7 and abs(v[2]*span-z)<.001),None);need(v is not None,'Devon pedestal base changed');polygon.append([v[0],v[2]])
  fragments=[polygon]
  for tri in caps:fragments=[q for p in fragments for q in _subtract(p,tri)]
  caps.extend(tri for p in fragments for tri in triangulate(p))
 uv=[12.5/256,80.5/128];cap=dict(corp,name='authored_closed_underside',vertices=[[v[0],0.,v[1]]+uv+[1.]for tri in caps for v in tri],indices=list(range(1,len(caps)*3+1)));parts.append(cap)
 rear,rearproof=close_rear(parts,'devon_corp',uv,span,['devon_corp','devon_waku']);parts.append(rear)
 body=dict(parts=parts,anchors={'door':[0.,0.,0.],'doorLeft':[-13.9762/span,0,0],'doorRight':[13.9762/span,0,0],'doorTop':[0.,46./span,0.]})
 # BM14 owns two original leaves, each with its own deep rigid hinge pivot.
 rawdoor=(root/'mapprops-nitrogen/3/0014/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='c104_bm_door02','unexpected Devon paired door');worlds=[];errors={}
 for bone in di.skeleton:
  need(all(abs(v)<1e-8 for v in bone.rotation),'unreviewed Devon bind rotation');mat=[[bone.scale[r]if r==c else bone.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if bone.parent>=0:mat=mul(worlds[bone.parent],mat)
  worlds.append(mat);check=mul(mat,[bone.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[bone.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(errors[di.skeleton[i].name]for i in[0,1,2])<1e-5,'Devon moving inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0014/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'Devon original animation changed');tracks={b.name:b.rotation[1].keys for b in a[0].bones if b.name in['anim_door_left','anim_door_right']};need(len(tracks)==2,'Devon paired hinge tracks absent');poses=[[],[],[]];dparts=[]
 for i,sub in enumerate(dm.submeshes):
  if sub.material=='Comb7':continue
  ni=di.meshes[i];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[k for t in sub.triangles for k in t],'independent Devon door geometry differs');owner=i+1;need(all(b==[owner]for b in sub.bones)and all(w==[1.]for w in sub.weights),'Devon paired leaf ownership differs')
  for state,frame in enumerate([0,2.5,5]):
   angle=sample(tracks[di.skeleton[owner].name],frame);c,s=math.cos(angle),math.sin(angle);mat=mul(worlds[owner],[[c,0,s,0],[0,1,0,0],[-s,0,c,0],[0,0,0,1]]);rows=[]
   for p,uv0 in zip(sub.positions,sub.uv0):
    pt=[sum(mat[r][k]*(p[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append([pt[0]/span,(pt[1]-.25)/span,pt[2]/span,uv0[0],1-uv0[1],1.])
   poses[state].append(rows)
  dparts.append(dict(name=sub.material+'_'+str(owner),texture=texture(next(m.base_color_texture for m in dm.materials if m.name==sub.material),1),vertices=poses[0][-1],indices=[k+1 for t in sub.triangles for k in t],role='source_devon_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data={'oras_rustboro_devon':body,'door':dict(id='oras_rustboro_devon_doors',parts=dparts,poses=poses)};(output/'lib/ImportedRustboroDevonData.lua').write_text('-- Original ORAS Devon Corporation and paired BM0014 hinges; tools/import_oras_devon.py.\nreturn '+lua(data)+'\n')
 report=dict(source='Supplied Alpha Sapphire RomFS, original Rustboro GR33/ZO16/AD11/BM14',sourceBchSha256=hashlib.sha256(raw).hexdigest(),normalizationOrigin=origin,normalizationSpan=span,sourceTrianglesByMaterial=counts,undersideTriangles=len(caps),rearClosure=rearproof,sourceDoorPlacement=[2205,0,3141],originalZoneDestination=warps[0],doorPhysicalTriangles=46,nativeFit=dict(width=160,depth=128,padding=4,doorAnchor=[80,0,118],groundInset=.05),doorBottomContactSnapToleranceSourceUnits=.0016,doorAngles=[[sample(tracks[side],f)for side in['anim_door_left','anim_door_right']]for f in[0,2.5,5]],movingInverseBindError=max(errors[di.skeleton[i].name]for i in[0,1,2]),textures=textures,sha256=dict(door=hashlib.sha256(rawdoor).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Original physical positions/UVs/indices independently checked. Source exposure RGB and24 nonphysical light faces omitted. Actual body/pedestal bottoms close without overlap, and rear follows source profiles. No source terrain or fences. Native fit/entry acceptance is separate.')
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
