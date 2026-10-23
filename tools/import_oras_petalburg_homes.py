#!/usr/bin/env python3
"""Export the three actual ORAS Petalburg homes and original BM0004 hinges."""
import argparse,hashlib,json,math,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-petalburg-homes';folder.mkdir(parents=True,exist_ok=True)
 banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0009/{k:03d}.bch').read_bytes())}for k in [1,11]};textures={}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-petalburg-homes/'+key+'.png'
 data={};report={};span=134.;base=.5000134110450745
 for name,gr,cx,cz,width in [('wide',7,-189,281,5),('west',8,-117,-7,4),('east',8,99,101,4)]:
  raw=(root/f'mapgr-nitrogen/9/{gr:04d}/001.bch').read_bytes();m=load(raw)[0];ind=open_bch(raw).models[0];parts=[];allbottom=[];counts={}
  for sub in m.submeshes:
   if sub.material not in ['touka_house2','touka_waku01','chip_mado']:continue
   ni=ind.meshes[m.submeshes.index(sub)];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[v for t in sub.triangles for v in t],'independent Petalburg home differs')
   selected=[]
   for tri in sub.triangles:
    inside=[abs(sub.positions[i][0]-cx)<70 and abs(sub.positions[i][2]-cz)<75 for i in tri]
    need(all(inside)or not any(inside),'source triangle crosses selected Petalburg home')
    if all(inside):selected.append(tri)
   if not selected:continue
   need(not sub.colors or all(abs(sub.colors[i][3]-1)<1e-8 for t in selected for i in t),'physical source alpha needs review')
   need(not any(all(abs(sub.positions[i][1]-base)<1e-6 for i in t)for t in selected),'original horizontal ground face needs separate audit')
   used=sorted(set(i for t in selected for i in t));remap={n:i+1 for i,n in enumerate(used)}
   vs=[[sub.positions[i][0]-cx,sub.positions[i][1]-base,sub.positions[i][2]-cz,sub.uv0[i][0],1-sub.uv0[i][1],1.]for i in used]
   material=next(a.base_color_texture for a in m.materials if a.name==sub.material)
   part=dict(name=sub.material,texture=texture(material,11),vertices=vs,indices=[remap[i]for t in selected for i in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat');parts.append(part);counts[sub.material]=len(selected)
   allbottom.extend(v[:]for v in vs if abs(v[1])<1e-6)
  need(len(parts)==3 and counts['touka_house2']==(1054 if width==5 else 912),'unexpected Petalburg body source')
  left=-59.5 if width==5 else -23.5;side=left-1.5
  rim=[(left,-62.5),(59.5,-62.5),(61,-61),(61,-57),(61,-29),(61,-1),(61,3),(59.5,4.5),(55.5,4.5),(37.5,4.5),(19.5,4.5),(19.5,6),(12,6),(12,0),(-12,0),(-12,6),(-19.5,6),(-19.5,4.5)]
  if width==5:rim.extend([(-37.5,4.5),(-55.5,4.5)])
  rim.extend([(left,4.5),(side,3),(side,-1),(side,-29),(side,-57),(side,-61)])
  bottom=[]
  for x,z in rim:
   v=next((v for v in allbottom if abs(v[0]-x)<.0005 and abs(v[2]-z)<.0005),None);need(v is not None,f'Petalburg exact rim changed {name} {x} {z}');row=v[:];row[3:5]=[197.5/256,122.5/128];bottom.append(row)
  def cross(a,b,c):return(b[0]-a[0])*(c[2]-a[2])-(b[2]-a[2])*(c[0]-a[0])
  loop=list(range(len(bottom)));ii=[]
  while len(loop)>3:
   for j,n in enumerate(loop):
    a,c=loop[j-1],loop[(j+1)%len(loop)]
    if cross(bottom[a],bottom[n],bottom[c])<=1e-8:continue
    if any(all(cross(bottom[u],bottom[v],bottom[k])>=-1e-8 for u,v in((a,n),(n,c),(c,a)))for k in loop if k not in(a,n,c)):continue
    ii.extend([a+1,n+1,c+1]);loop.pop(j);break
   else:raise ValueError('Petalburg source underside triangulation failed')
  ii.extend([i+1 for i in loop]);cap=dict(next(p for p in parts if p['name']=='touka_house2'),name='authored_closed_underside',vertices=bottom,indices=ii);parts.append(cap)
  for p in parts:p['vertices']=[[v[0]/span,v[1]/span,v[2]/span]+v[3:]for v in p['vertices']]
  data['oras_petalburg_home_'+name]=dict(parts=parts,anchors={'door':[0,0,0],'doorLeft':[-12/span,0,0],'doorRight':[12/span,0,0],'doorTop':[0,45/span,0]})
  report[name]=dict(gr=gr,model=m.name,sourceTrianglesByMaterial=counts,undersideTriangles=len(ii)//3,sourceOrigin=[cx,base,cz],sourceBchSha256=hashlib.sha256(raw).hexdigest(),originalHorizontalGroundFaces=0)
 # Actual BM0004 rigid -80degree hinged panel and its own AD slot1 glass bank.
 raw=(root/'mapprops-nitrogen/3/0004/000.bch').read_bytes();m=load(raw)[0];ind=open_bch(raw).models[0];need(m.name=='c101_bm_door01','unexpected Petalburg door')
 worlds=[];errors={}
 for b in ind.skeleton:
  need(all(abs(v)<1e-8 for v in b.rotation),'unreviewed Petalburg bind rotation')
  mat=[[b.scale[r]if r==c else b.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if b.parent>=0:mat=mul(worlds[b.parent],mat)
  worlds.append(mat);check=mul(mat,[b.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[b.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(errors[b]for b in ['C101_door','anim_door'])<1e-5,'Petalburg moving inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0004/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'unexpected Petalburg hinge animation')
 track=next(b.rotation[1].keys for b in a[0].bones if b.name=='anim_door');angles=[sample(track,f)for f in [0,2.5,5]];poses=[[],[],[]];dparts=[]
 right=max(v[0]for s in m.submeshes if s.material!='Comb7'for v in s.positions)+worlds[1][0][3];offset=12-right
 for i,sub in enumerate(m.submeshes):
  if sub.material=='Comb7':continue
  need(not sub.colors or all(abs(v[3]-1)<1e-8 for v in sub.colors),'physical door alpha needs review')
  ni=ind.meshes[i];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[v for t in sub.triangles for v in t],'independent Petalburg door geometry differs')
  need(all(b==[1]for b in sub.bones)and all(w==[1.]for w in sub.weights),'Petalburg door ownership differs')
  for state,angle in enumerate(angles):
   c,s=math.cos(angle),math.sin(angle);mat=mul(worlds[1],[[c,0,s,0],[0,1,0,0],[-s,0,c,0],[0,0,0,1]]);rows=[]
   for pos,uv in zip(sub.positions,sub.uv0):
    pt=[sum(mat[r][k]*(pos[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append([(pt[0]+offset)/span,pt[1]/span,pt[2]/span,uv[0],1-uv[1],1.])
   poses[state].append(rows)
  dparts.append(dict(name=sub.material,texture=texture(next(a.base_color_texture for a in m.materials if a.name==sub.material),1),vertices=poses[0][-1],indices=[v+1 for t in sub.triangles for v in t],role='source_petalburg_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data['door']=dict(id='oras_petalburg_home_doors',parts=dparts,poses=poses)
 (output/'lib/ImportedPetalburgHomesData.lua').write_text('-- Actual ORAS Petalburg homes and BM0004 hinges; tools/import_oras_petalburg_homes.py.\nreturn '+lua(data)+'\n')
 result=dict(source='User-supplied Alpha Sapphire RomFS; authentic own town-home geometry',variants=report,normalizationSpan=span,door='BM0004 c101_bm_door01',doorPhysicalTriangles=76,doorAnglesRadians=angles,movingInverseBindMaximumError=max(errors[b]for b in ['C101_door','anim_door']),doorPanelOriginalRight=right,doorAlignmentOffsetX=offset,textures=textures,sha256=dict(door=hashlib.sha256(raw).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Original own-source positions/UVs/triangles independently checked with Nitrogen. No copied terrain/fences or source ground planes. Source exposure RGB and24 nonphysical light faces omitted. Native portal/ground remains fixed; only Y0 contact vertices recess at fit upload.')
 (folder/'provenance.json').write_text(json.dumps(result,indent=2)+'\n');return result
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in ['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
