#!/usr/bin/env python3
"""Export own ORAS Oceanic Museum body and original BM0040 paired doors."""
import argparse,hashlib,json,math,struct,sys
from pathlib import Path
from oras_scenery_source import decoder,need,garc,mini,decompress
from oras_rear_closure import close_rear,_subtract
from oras_fixture_shells import close_fixture_shells
from import_oras_devon import triangulate
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-slateport-museum';folder.mkdir(parents=True,exist_ok=True);textures={};banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0020/{k:03d}.bch').read_bytes())}for k in[1,11]}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-slateport-museum/'+key+'.png'
 gr=mini(garc((root/'alpha-sapphire-romfs/a/0/3/9').read_bytes()).single(150),'GR');raw=(root/'mapgr-nitrogen/9/0150/001.bch').read_bytes();need(decompress(gr[1])==raw,'Slateport original museum body differs');m=load(raw)[0];ind=open_bch(raw).models[0];need(m.name=='c102_01_00','unexpected museum source')
 records=gr[3];need(any((lambda o:o[0]==40 and o[1:4]==(1.,1.,1.)and o[4:7]==(0.,0.,0.)and o[7:10]==(1035.,18.,549.))(struct.unpack_from('<I10f',records,4+i*44))for i in range(struct.unpack_from('<I',records)[0])),'original BM40 museum placement differs')
 entities=mini(garc((root/'alpha-sapphire-romfs/a/0/1/3').read_bytes()).single(14),'ZO')[1];nf,nn,nw,nt=struct.unpack_from('<4B',entities,4);need(any(struct.unpack_from('<H',entities,12+nf*20+nn*48+i*24)[0]==273 and struct.unpack_from('<3h',entities,20+nf*20+nn*48+i*24)==(1035,18,549)for i in range(nw)),'museum original ZO14→273 warp differs')
 origin=[1035.,18.5,549.];offset=[1080,0,360];span=152.;parts=[];counts={}
 for i,s in enumerate(m.submeshes):
  if s.material not in['kaina_house01','museum_waku','chip_mado']:continue
  ni=ind.meshes[i];need(ni.positions==s.positions and ni.texcoords==s.uv0 and ni.submeshes[0].indices==[k for t in s.triangles for k in t],'independent original museum geometry differs');need(all(c[3]==1 for c in s.colors),'museum physical opacity needs review');need(not any(all(abs(s.positions[k][1]-18.5)<.0001 for k in tri)for tri in s.triangles),'source museum ground plane needs audit')
  vertices=[]
  for p,uv in zip(s.positions,s.uv0):
   v=[(p[k]+offset[k]-origin[k])/span for k in range(3)]+[uv[0],1-uv[1],1.]
   if abs(v[1]*span)<.0001:v[1]=0.
   vertices.append(v)
  parts.append(dict(name=s.material,texture=texture(next(a.base_color_texture for a in m.materials if a.name==s.material),11),vertices=vertices,indices=[k+1 for t in s.triangles for k in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'));counts[s.material]=len(s.triangles)
 need(counts==dict(kaina_house01=546,museum_waku=716,chip_mado=44),'museum source topology changed')
 body=next(p for p in parts if p['name']=='kaina_house01');waku=next(p for p in parts if p['name']=='museum_waku')
 def actual(x,z,part=body):
  v=next((v for v in part['vertices']if abs(v[0]*span+origin[0]-x)<.001 and abs(v[1])<1e-7 and abs(v[2]*span+origin[2]-z)<.001),None);need(v is not None,'original museum foundation point changed');return[v[0],v[2]]
 outline=[(963,470),(1107,470),(1107,538),(1089.5,538),(1080,538),(1070.353,543.98),(1059.352,548.423),(1051.232,554.388),(1035,556.084),(1018.768,554.388),(1010.648,548.423),(999.647,543.98),(990,538),(980.5,538),(963,538)]
 caps=triangulate([actual(x,z)for x,z in outline])
 def append(poly):
  fragments=[poly]
  for triangle in caps:fragments=[q for p in fragments for q in _subtract(p,triangle)]
  caps.extend(triangle for p in fragments for triangle in triangulate(p))
 # Four actual side-pier footprints, with their original sloped corner joins.
 for right in[False,True]:
  x,outer=(1107,1111)if right else(963,959)
  for back,intersection,front in[(481.5,484.015,490.5),(517.5,523.985,526.5)]:append([actual(x,intersection),actual(outer,back),actual(outer,front),actual(x,front)])
 # Original ornate front pedestals project outside the curved body. Union their
 # exact rims with the body cap rather than duplicating coplanar cap area.
 for polygon in[[(980,538),(990,538),(990,542),(980,542)],[(1080,538),(1090,538),(1090,542),(1080,542)],[(1010.1606,548.311),(1019.6619,550.49001),(1018.768,554.388),(1009.2668,552.21001)],[(1050.3381,550.49001),(1059.8394,548.311),(1060.7332,552.21001),(1051.232,554.388)]]:append([actual(x,z,waku)for x,z in polygon])
 uv=[81.5/256,157.5/256];cap=dict(body,name='authored_closed_underside',vertices=[[v[0],0.,v[1]]+uv+[1.]for tri in caps for v in tri],indices=list(range(1,len(caps)*3+1)));parts.append(cap);rear,rearproof=close_rear(parts,'kaina_house01',uv,span);parts.append(rear)
 metal=banks[11][next(a.base_color_texture for a in m.materials if a.name=='museum_waku')]
 def metal_paint(tri):
  u=sum(v[3]for v in tri)/3%1;v=sum(v[4]for v in tri)/3%1;x=int(u*metal.width);y=int(v*metal.height);need(metal.rgba[(y*metal.width+x)*4+3]==255,'fixture backing texel is not opaque');return[(x+.5)/metal.width,(y+.5)/metal.height]
 shell,shellproof=close_fixture_shells(waku,parts,102/span,span,metal_paint);parts.append(shell)
 model=dict(parts=parts,anchors={'door':[0.,0.,0.]})
 rawdoor=(root/'mapprops-nitrogen/3/0040/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='c102_bm_door04','unexpected museum paired door');worlds=[];errors={}
 for bone in di.skeleton:
  need(all(abs(v)<1e-8 for v in bone.rotation),'museum bind rotation needs review');mat=[[bone.scale[r]if r==c else bone.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if bone.parent>=0:mat=mul(worlds[bone.parent],mat)
  worlds.append(mat);check=mul(mat,[bone.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[bone.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(errors[di.skeleton[i].name]for i in[0,1,2])<1e-5,'museum moving inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0040/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'museum original animation differs');tracks={b.name:b.rotation[1].keys for b in a[0].bones if b.name in['anim_door','anim_door1']};need(len(tracks)==2,'paired original hinge tracks absent');poses=[[],[],[]];dparts=[];owners=[]
 for i,s in enumerate(dm.submeshes):
  if s.material=='pasted__Comb12':continue
  need(not s.colors or all(abs(c[3]-1)<1e-8 for c in s.colors),'museum door physical opacity needs review')
  ni=di.meshes[i];draw=ni.submeshes[0];need(ni.positions==s.positions and ni.texcoords==s.uv0 and draw.indices==[k for t in s.triangles for k in t],'independent museum door geometry differs');need(draw.skinning==2 and len(draw.bone_indices)==1 and draw.bone_indices[0]in[1,2],'museum rigid leaf owner differs');owner=draw.bone_indices[0];need(all(b==[owner]for b in s.bones)and all(w==[1.]for w in s.weights),'museum owner/weight differs');owners.append(owner)
  for state,frame in enumerate([0,2.5,5]):
   angle=sample(tracks[di.skeleton[owner].name],frame);c,t=math.cos(angle),math.sin(angle);mat=mul(worlds[owner],[[c,0,t,0],[0,1,0,0],[-t,0,c,0],[0,0,0,1]]);rows=[]
   for p,uv0 in zip(s.positions,s.uv0):
    v=[sum(mat[r][k]*(p[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append([v[0]/span,(v[1]-.5)/span,v[2]/span,uv0[0],1-uv0[1],1.])
   poses[state].append(rows)
  dparts.append(dict(name=s.material+'_'+str(i),texture=texture(next(a.base_color_texture for a in dm.materials if a.name==s.material),1),vertices=poses[0][-1],indices=[k+1 for t in s.triangles for k in t],role='source_museum_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data={'oras_slateport_museum':model,'door':dict(id='oras_slateport_museum_doors',parts=dparts,poses=poses,owners=owners,angles=[[sample(tracks[di.skeleton[b].name],f)for b in[1,2]]for f in[0,2.5,5]],meetingPlane=(max(v[0]for v in poses[0][0])+min(v[0]for v in poses[0][1]))/2)};(output/'lib/ImportedSlateportMuseumData.lua').write_text('-- Original ORAS Oceanic Museum and BM0040 paired hinges; tools/import_oras_slateport_museum.py.\nreturn '+lua(data)+'\n')
 report=dict(source='Supplied Alpha Sapphire RomFS; original Slateport GR150/ZO14→273/AD20/BM40',sourceStaticOrigin=offset,sourceOrigin=origin,normalizationSpan=span,sourceTrianglesByMaterial=counts,undersideTriangles=len(caps),rearClosure=rearproof,roofFixtureShells=shellproof,sourceDoorPlacement=[1035,18,549],doorPhysicalTriangles=sum(len(p['indices'])//3 for p in dparts),closedLeafContactNativeInset=.05,nativeFit=dict(width=96,depth=64,padding=.25,doorAnchor=[48,0,59.25],groundInset=.05),rigidLeafOwners=owners,doorAngles=[[sample(tracks[b],f)for b in['anim_door','anim_door1']]for f in[0,2.5,5]],movingInverseBindError=max(errors[di.skeleton[i].name]for i in[0,1,2]),textures=textures,sha256=dict(body=hashlib.sha256(raw).hexdigest(),door=hashlib.sha256(rawdoor).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Original physical source vertices/UVs/indices independently checked. Original0.5 source-ground difference to BM placement retained. Source exposure RGB and24 nonphysical light faces omitted. Foundation/pedestal caps union without duplicate area; rear follows structural profiles. Native fit and contact acceptance remain separate.')
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
