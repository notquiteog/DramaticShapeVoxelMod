#!/usr/bin/env python3
"""Export the two original Littleroot houses and BM0002 hinge from supplied ORAS source."""
import argparse,hashlib,json,math,struct,sys
from pathlib import Path
from oras_scenery_source import decoder,need,garc,mini,decompress,matrix
from oras_rear_closure import close_rear
from oras_geometry_audit import components,hull,coplanar_overlaps
from import_oras_devon import triangulate
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-littleroot-homes';folder.mkdir(parents=True,exist_ok=True)
 banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0008/{k:03d}.bch').read_bytes())}for k in[1,11]};textures={}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-littleroot-homes/'+key+'.png'
 gr=mini(garc((root/'alpha-sapphire-romfs/a/0/3/9').read_bytes()).single(6),'GR');raw=(root/'mapgr-nitrogen/9/0006/001.bch').read_bytes();need(decompress(gr[1])==raw,'original Littleroot static geometry differs')
 mm=matrix(garc((root/'alpha-sapphire-romfs/a/0/4/0').read_bytes()).single(1));need(mm['width']==8 and mm['graphics'][34]==6,'Littleroot original MM1 placement differs')
 zo=mini(garc((root/'alpha-sapphire-romfs/a/0/1/3').read_bytes()).single(6),'ZO');need(struct.unpack_from('<H',zo[0],2)[0]==8 and struct.unpack_from('<H',zo[0],4)[0]==1,'Littleroot ZO6 area/matrix differs')
 entities=zo[1];nf,nn,nw,nt=struct.unpack_from('<4B',entities,4);warps={}
 for i in range(nw):
  rec=entities[12+nf*20+nn*48+i*24:12+nf*20+nn*48+(i+1)*24];warps[struct.unpack_from('<H',rec)[0]]=struct.unpack_from('<3h',rec,8)
 objects=[struct.unpack_from('<I10f',gr[3],4+i*44)for i in range(struct.unpack_from('<I',gr[3])[0])]
 m=load(raw)[0];ind=open_bch(raw).models[0];need(m.name=='world01_02_04','unexpected Littleroot static model')
 data={};reports={};span=112.
 for name,x,world,destination,box in [('west',-99.,1701.,223,(-180.,-55.)),('east',117.,1917.,225,(72.,185.))]:
  need(warps[destination]==(int(world),0,3087),'original Littleroot home portal differs')
  need(any(o[0]==2 and o[1:4]==(1.,1.,1.)and o[4:7]==(0.,0.,0.)and o[7:10]==(world,0.,3087.)for o in objects),'original Littleroot BM2 placement differs')
  origin=[x,0.,-153.];parts=[];counts={}
  for at,s in enumerate(m.submeshes):
   if s.material not in['t01_01','t01_02','chip_mado']:continue
   ni=ind.meshes[at];need(ni.positions==s.positions and ni.texcoords==s.uv0 and ni.submeshes[0].indices==[i for tri in s.triangles for i in tri],'independent Littleroot source differs')
   selected=[]
   for group in components(s):
    points=[s.positions[i]for t in group for i in t]
    inside=[box[0]<v[0]<box[1] and -230<v[2]<-130 for v in points]
    need(all(inside)or not any(inside),'original component crosses Littleroot house boundary')
    if all(inside):selected.extend(group)
   if not selected:continue
   used=sorted(set(i for t in selected for i in t));remap={v:i+1 for i,v in enumerate(used)}
   need(not s.colors or all(abs(s.colors[i][3]-1)<1e-8 for i in used),'Littleroot physical alpha needs review')
   vertices=[[(s.positions[i][k]-origin[k])/span for k in range(3)]+[s.uv0[i][0],1-s.uv0[i][1],1.]for i in used]
   for v in vertices:
    if abs(v[1]*span)<.0001:v[1]=0.
   p=dict(name=s.material,texture=texture(next(a.base_color_texture for a in m.materials if a.name==s.material),11),vertices=vertices,indices=[remap[i]for t in selected for i in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat');parts.append(p);counts[s.material]=len(selected)
  need(counts==dict(chip_mado=4,t01_01=1191,t01_02=324),'original Littleroot home topology differs')
  body=next(p for p in parts if p['name']=='t01_01');rim=hull([[v[0],v[2]]for v in body['vertices']if v[1]==0]);caps=triangulate(rim);uv=[141.5/256,53.5/256];need(banks[11]['t101_01'].rgba[(53*256+141)*4+3]==255,'actual original wall texel is not opaque')
  parts.append(dict(body,name='authored_closed_underside',vertices=[[v[0],0.,v[1]]+uv+[1.]for tri in caps for v in tri],indices=list(range(1,len(caps)*3+1))))
  rear,proof=close_rear(parts,'t01_01',uv,span);parts.append(rear)
  data['oras_littleroot_home_'+name]=dict(parts=parts,anchors={'door':[0.,0.,0.],'doorLeft':[-13.429/span,0.,0.],'doorRight':[13.429/span,0.,0.],'doorTop':[0.,45./span,0.]})
  reports[name]=dict(sourcePhysicalTriangles=counts,sourceOrigin=origin,sourceWorld=[world,0,3087],zone=6,destination=destination,undersideTriangles=len(caps),rearClosure=proof,coplanar=coplanar_overlaps(parts,distance=1e-6,area=1e-8))
 rawdoor=(root/'mapprops-nitrogen/3/0002/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='t101_bm_door01','unexpected Littleroot hinge source');worlds=[];errors={}
 for b in di.skeleton:
  need(all(abs(v)<1e-8 for v in b.rotation),'unreviewed Littleroot bind rotation');mat=[[b.scale[r]if r==c else b.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if b.parent>=0:mat=mul(worlds[b.parent],mat)
  worlds.append(mat);check=mul(mat,[b.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[b.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(errors['anim_door']<1e-5,'Littleroot moving inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0002/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);animations=read_animations(rel,read_contents(rel,h),h.backward);need(len(animations)==1 and animations[0].frame_count==6 and not animations[0].looping,'original Littleroot hinge animation differs')
 tracks=next(b.rotation[1].keys for b in animations[0].bones if b.name=='anim_door');angles=[sample(tracks,f)for f in[0,2.5,5]];poses=[[],[],[]];doorparts=[]
 for at,s in enumerate(dm.submeshes):
  if s.material=='Comb7':continue
  ni=di.meshes[at];need(ni.positions==s.positions and ni.texcoords==s.uv0 and ni.submeshes[0].indices==[i for t in s.triangles for i in t],'independent Littleroot hinge geometry differs');need(all(b==[1]for b in s.bones)and all(w==[1.]for w in s.weights),'Littleroot hinge ownership differs')
  for state,angle in enumerate(angles):
   c,sn=math.cos(angle),math.sin(angle);mat=mul(worlds[1],[[c,0,sn,0],[0,1,0,0],[-sn,0,c,0],[0,0,0,1]]);vertices=[]
   for pos,uv in zip(s.positions,s.uv0):
    v=[sum(mat[r][k]*(pos[k]if k<3 else 1)for k in range(4))/span for r in range(3)]+[uv[0],1-uv[1],1.]
    if abs(v[1]*span)<.0001:v[1]=0.
    vertices.append(v)
   poses[state].append(vertices)
  doorparts.append(dict(name=s.material,texture=texture(next(a.base_color_texture for a in dm.materials if a.name==s.material),1),vertices=poses[0][-1],indices=[v+1 for t in s.triangles for v in t],role='source_littleroot_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data['door']=dict(id='oras_littleroot_home_doors',parts=doorparts,poses=poses)
 (output/'lib/ImportedLittlerootHomesData.lua').write_text('-- Original GR6/AD8 Littleroot houses and BM2 hinge; tools/import_oras_littleroot_homes.py.\nreturn '+lua(data)+'\n')
 result=dict(source='User-supplied ORAS Alpha Sapphire RomFS',graphics=6,zone=6,area=8,matrix=1,staticWorldOrigin=[1800,0,3240],normalizationSpan=span,variants=reports,doorPhysicalTriangles=sum(len(p['indices'])//3 for p in doorparts),doorAnglesRadians=angles,movingInverseBindMaximumError=errors['anim_door'],textures=textures,sha256={'body':hashlib.sha256(raw).hexdigest(),'door':hashlib.sha256(rawdoor).hexdigest(),'animation':hashlib.sha256(anim).hexdigest()},processing='Original positions, UVs, indices and physical alpha independently checked. Source exposure RGB, terrain, vegetation, outdoor mailboxes and nonphysical door light faces omitted. Native ground/portal remains authoritative; source undersides/rears close separately.')
 (folder/'provenance.json').write_text(json.dumps(result,indent=2)+'\n');return result

if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
