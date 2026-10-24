#!/usr/bin/env python3
"""Export own ORAS Slateport Harbor body and original BM0093 paired sliders."""
import argparse,hashlib,json,math,struct,sys
from pathlib import Path
from oras_scenery_source import decoder,need,garc,mini,decompress
from oras_rear_closure import close_rear
from import_oras_devon import triangulate
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-slateport-harbor';folder.mkdir(parents=True,exist_ok=True);textures={};banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0020/{k:03d}.bch').read_bytes())}for k in[1,11]}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-slateport-harbor/'+key+'.png'
 gr=mini(garc((root/'alpha-sapphire-romfs/a/0/3/9').read_bytes()).single(150),'GR');raw=(root/'mapgr-nitrogen/9/0150/001.bch').read_bytes();need(decompress(gr[1])==raw,'Slateport original harbor body differs');m=load(raw)[0];ind=open_bch(raw).models[0];need(m.name=='c102_01_00','unexpected harbor source')
 records=gr[3];need(any((lambda o:o[0]==93 and o[1:4]==(1.,1.,1.)and o[4:7]==(0.,0.,0.)and o[7:10]==(927.,0.,171.))(struct.unpack_from('<I10f',records,4+i*44))for i in range(struct.unpack_from('<I',records)[0])),'original BM93 harbor placement differs')
 entities=mini(garc((root/'alpha-sapphire-romfs/a/0/1/3').read_bytes()).single(14),'ZO')[1];nf,nn,nw,nt=struct.unpack_from('<4B',entities,4);need(any(struct.unpack_from('<H',entities,12+nf*20+nn*48+i*24)[0]==275 and struct.unpack_from('<3h',entities,20+nf*20+nn*48+i*24)==(927,0,171)for i in range(nw)),'harbor original ZO14→275 warp differs')
 origin=[927.,0.,171.];offset=[1080,0,360];span=267.;parts=[];counts={};clipped=0
 for i,s in enumerate(m.submeshes):
  if s.material not in['c106_01','c106_window','Comb2']:continue
  ni=ind.meshes[i];need(ni.positions==s.positions and ni.texcoords==s.uv0 and ni.submeshes[0].indices==[k for t in s.triangles for k in t],'independent Harbor geometry differs');need(not s.colors or all(c[3]==1 for c in s.colors),'Harbor physical opacity needs review')
  vertices=[];indices=[];lookup={}
  for source_index,tri in enumerate(s.triangles):
   if s.material=='Comb2'and source_index in[40,41,42,43]:
    # Original PICA portal-effect mask, behind the physical sliding panels.
    # It samples the atlas's neon marker and is not a physical wall or door.
    need(all(abs(s.positions[j][2]+360-153.45)<.001 and 6-.001<=s.positions[j][1]<=45+.001 and 907.301<=s.positions[j][0]+1080<=946.699 for j in tri),'original Harbor portal mask moved')
    tex=banks[11]['t106_02'];u=sum(s.uv0[j][0]for j in tri)/3%1;v=(1-sum(s.uv0[j][1]for j in tri)/3)%1;at=(int(v*tex.height)*tex.width+int(u*tex.width))*4;color=tex.rgba[at:at+4];need(color[0]>200 and color[1]<30 and color[2]>200,'original PICA portal mask marker differs');continue
   before=[[(s.positions[j][k]+offset[k]-origin[k])/span for k in range(3)]+[s.uv0[j][0],1-s.uv0[j][1],1.]for j in tri]
   for v in before:
    if abs(v[1]*span)<.0001:v[1]=0.
   poly=[];prev=before[-1]
   for v in before:
    if(prev[1]>=0)!=(v[1]>=0):
     t=prev[1]/(prev[1]-v[1]);q=[prev[k]+t*(v[k]-prev[k])for k in range(6)];q[1]=0.;poly.append(q)
    if v[1]>=0:poly.append(v)
    prev=v
   if any(v[1]<0 for v in before):clipped+=1
   for at in range(1,len(poly)-1):
    for v in[poly[0],poly[at],poly[at+1]]:
     key=tuple(v)
     if key not in lookup:lookup[key]=len(vertices)+1;vertices.append(v)
     indices.append(lookup[key])
  counts[s.material]=len(s.triangles);parts.append(dict(name=s.material,texture=texture(next(a.base_color_texture for a in m.materials if a.name==s.material),11),vertices=vertices,indices=indices,role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 need(counts==dict(c106_01=1068,c106_window=48,Comb2=174),'Harbor original topology changed')
 # Original lower side/front perimeter. The entrance steps keep their real
 # shape and source heights; only their missing ground-facing surface closes.
 outline=[(795,56.48401),(1059,56.48401),(1059,176.367),(1020,176.367),(1020,167),(964.325,167),(964.325,176.367),(889.675,176.367),(889.675,167),(834,167),(834,176.367),(795,176.367)]
 body=next(p for p in parts if p['name']=='c106_01');sourcepoints=body['vertices']
 for x,z in outline:need(any(abs(v[0]*span+927-x)<.001 and abs(v[2]*span+171-z)<.001 and v[1]==0 for v in sourcepoints),'Harbor actual foundation corner differs')
 caps=triangulate([[(x-927)/span,(z-171)/span]for x,z in outline]);uv=[185.5/256,113.5/256];cap=dict(body,name='authored_closed_underside',vertices=[[v[0],0.,v[1]]+uv+[1.]for tri in caps for v in tri],indices=list(range(1,len(caps)*3+1)));parts.append(cap)
 rear,rearproof=close_rear(parts,'c106_01',uv,span);parts.append(rear)
 model=dict(parts=parts,anchors={'door':[0.,0.,0.]})
 rawdoor=(root/'mapprops-nitrogen/3/0093/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='com_bm_portdoor01','unexpected harbor paired door');worlds=[];errors={}
 for bone_index,bone in enumerate(di.skeleton):
  need(bone_index not in[0,1,2]or all(abs(v)<1e-8 for v in bone.rotation),'harbor bind rotation needs review');mat=[[bone.scale[r]if r==c else bone.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if bone.parent>=0:mat=mul(worlds[bone.parent],mat)
  worlds.append(mat);check=mul(mat,[bone.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[bone.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(errors[di.skeleton[i].name]for i in[0,1,2])<1e-5,'harbor moving inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0093/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'harbor original animation differs');tracks={b.name:[t.keys for t in b.translation]for b in a[0].bones if b.name in['anim_door','anim_door1']};need(len(tracks)==2,'paired original slider tracks absent');poses=[[],[],[]];dparts=[];owners=[]
 for i,s in enumerate(dm.submeshes):
  if s.material=='pasted__Comb12':continue
  need(not s.colors or all(abs(c[3]-1)<1e-8 for c in s.colors),'harbor door physical opacity needs review')
  ni=di.meshes[i];draw=ni.submeshes[0];need(ni.positions==s.positions and ni.texcoords==s.uv0 and draw.indices==[k for t in s.triangles for k in t],'independent harbor door geometry differs');need(draw.skinning==2 and len(draw.bone_indices)==1 and draw.bone_indices[0]in[1,2],'harbor rigid leaf owner differs');owner=draw.bone_indices[0];need(all(b==[owner]for b in s.bones)and all(w==[1.]for w in s.weights),'harbor owner/weight differs');owners.append(owner)
  for state,frame in enumerate([0,2.5,5]):
   mat=[row[:]for row in worlds[owner]];rows=[]
   for axis in range(3):mat[axis][3]=worlds[0][axis][3]+sample(tracks[di.skeleton[owner].name][axis],frame)
   for p,uv0 in zip(s.positions,s.uv0):
    v=[sum(mat[r][k]*(p[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append([v[0]/span,v[1]/span,v[2]/span,uv0[0],1-uv0[1],1.])
   poses[state].append(rows)
  dparts.append(dict(name=s.material+'_'+str(i),texture=texture(next(a.base_color_texture for a in dm.materials if a.name==s.material),1),vertices=poses[0][-1],indices=[k+1 for t in s.triangles for k in t],role='source_harbor_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data={'oras_slateport_harbor':model,'door':dict(id='oras_slateport_harbor_doors',parts=dparts,poses=poses,owners=owners,angles=[[0.,0.]for f in[0,2.5,5]],meetingPlane=(max(v[0]for v in poses[0][0])+min(v[0]for v in poses[0][1]))/2)};(output/'lib/ImportedSlateportHarborData.lua').write_text('-- Original ORAS Slateport Harbor and BM0093 paired sliders; tools/import_oras_slateport_harbor.py.\nreturn '+lua(data)+'\n')
 report=dict(source='Supplied Alpha Sapphire RomFS; original Slateport GR150/ZO14→275/AD20/BM93',sourceStaticOrigin=offset,sourceOrigin=origin,normalizationSpan=span,sourceTrianglesByMaterial=counts,excludedPicaPortalMaskTriangles=[40,41,42,43],undersideTriangles=len(caps),rearClosure=rearproof,belowGroundTrianglesClipped=clipped,sourceDoorPlacement=[927,0,171],doorPhysicalTriangles=sum(len(p['indices'])//3 for p in dparts),closedLeafContactNativeInset=.05,nativeFit=dict(width=112,depth=80,padding=.25,doorAnchor=[56,0,74.25],groundInset=.05),rigidLeafOwners=owners,doorSliderX=[[sample(tracks[b][0],f)for b in['anim_door','anim_door1']]for f in[0,2.5,5]],movingInverseBindError=max(errors[di.skeleton[i].name]for i in[0,1,2]),textures=textures,sha256=dict(body=hashlib.sha256(raw).hexdigest(),door=hashlib.sha256(rawdoor).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Original physical source vertices/UVs/indices independently checked. Original BM ground/portal placement retained; hidden geometry below sourceY0 clipped. Source exposure RGB,24 nonphysical BM light faces and4 original PICA portal-mask marker faces omitted. Original foundation caps and rear follow actual profiles. Native fit and contact acceptance remain separate.')
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
