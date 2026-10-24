#!/usr/bin/env python3
"""Export Slateport's own ORAS pc_base Mart, its original bank pixels and BM0009 poses."""
import argparse,hashlib,json,math,struct,sys
from pathlib import Path
from oras_scenery_source import decoder,need,garc,mini,decompress
from oras_rear_closure import close_rear
from import_oras_grass import lua
from import_oras_center_doors import mul,sample
from import_oras_devon import triangulate

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-slateport-mart';folder.mkdir(parents=True,exist_ok=True);textures={};banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0020/{k:03d}.bch').read_bytes())}for k in[1,11]}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-slateport-mart/'+key+'.png'
 gr=mini(garc((root/'alpha-sapphire-romfs/a/0/3/9').read_bytes()).single(149),'GR');raw=(root/'mapgr-nitrogen/9/0149/001.bch').read_bytes();need(decompress(gr[1])==raw,'original Slateport GR149 differs');m=load(raw)[0];ind=open_bch(raw).models[0];need(m.name=='c102_00_00','unexpected Slateport model');sub=next(s for s in m.submeshes if s.material=='pc_base');ni=ind.meshes[m.submeshes.index(sub)];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[k for t in sub.triangles for k in t],'independent Slateport Mart source differs');need(len(sub.triangles)==703 and all(c[3]==1 for c in sub.colors),'Slateport physical source topology/alpha changed')
 records=gr[3];objects=[struct.unpack_from('<I10f',records,4+i*44)for i in range(struct.unpack_from('<I',records)[0])];need(any(o[0]==9 and o[1:4]==(1.,1.,1.)and o[4:7]==(0.,0.,0.)and o[7:10]==(675.,18.,441.)for o in objects),'Slateport original BM9 placement differs')
 entities=mini(garc((root/'alpha-sapphire-romfs/a/0/1/3').read_bytes()).single(14),'ZO')[1];nf,nn,nw,nt=struct.unpack_from('<4B',entities,4);need(any(struct.unpack_from('<H',entities,12+nf*20+nn*48+i*24)[0]==266 and struct.unpack_from('<3h',entities,20+nf*20+nn*48+i*24)==(675,18,441)for i in range(nw)),'Slateport ZO14 Mart warp differs')
 # c102_00_00's static origin is360,0,360 relative to actual GR object coords.
 origin=[315.,18.,81.];span=max(v[0]for v in sub.positions)-min(v[0]for v in sub.positions)
 def norm(v):return[(v[k]-origin[k])/span for k in range(3)]+v[3:]
 part=dict(name='pc_base',texture=texture(next(a.base_color_texture for a in m.materials if a.name==sub.material),11),vertices=[norm(list(p)+[uv[0],1-uv[1],1.])for p,uv in zip(sub.positions,sub.uv0)],indices=[k+1 for t in sub.triangles for k in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat');need(not any(all(abs(part['vertices'][k-1][1])<1e-7 for k in part['indices'][i:i+3])for i in range(0,len(part['indices']),3)),'Slateport source floor plane needs audit')
 for triangle,side in[(108,-1),(110,1)]:
  need(all(abs(part['vertices'][k-1][0]*span-side*14)<.0001 for k in part['indices'][triangle*3:triangle*3+3]),'reviewed Slateport source jamb plane changed')
 bottom={tuple(v[k]for k in[0,2]):v for v in part['vertices']if abs(v[1])<1e-7};need(len(bottom)==19,'Slateport original bottom rim changed');center=[sum(v[k]for v in bottom.values())/len(bottom)for k in[0,2]];rim=sorted(bottom,key=lambda v:math.atan2(v[1]-center[1],v[0]-center[0]));caps=triangulate(rim);uv=[16.5/256,220.5/256]
 cap=dict(part,name='authored_closed_underside',vertices=[[v[0],0.,v[1]]+uv+[1.]for tri in caps for v in tri],indices=list(range(1,len(caps)*3+1)));parts=[part,cap];rear,rearproof=close_rear(parts,'pc_base',uv,span);parts.append(rear);body=dict(parts=parts,anchors={'door':[0.,0.,0.]})
 rawdoor=(root/'mapprops-nitrogen/3/0009/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='com_bm_fsdoor01','unexpected original Slateport sliding door');worlds=[];errors={}
 for bone in di.skeleton:
  need(all(abs(v)<1e-8 for v in bone.rotation),'unreviewed sliding-door bind rotation');mat=[[bone.scale[r]if r==c else bone.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if bone.parent>=0:mat=mul(worlds[bone.parent],mat)
  worlds.append(mat);check=mul(mat,[bone.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[bone.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(errors['move']<1e-5,'moving original inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0009/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'unexpected original slider track');track=next(b.translation[0].keys for b in a[0].bones if b.name=='move');poses=[[],[],[]];dparts=[]
 for i,s in enumerate(dm.submeshes):
  if s.material=='Comb7':continue
  ni=di.meshes[i];need(ni.positions==s.positions and ni.texcoords==s.uv0 and ni.submeshes[0].indices==[k for t in s.triangles for k in t],'independent sliding source differs');need(all(b==[5]for b in s.bones)and all(w==[1.]for w in s.weights),'original slider ownership differs')
  for state,frame in enumerate([0,2.5,5]):
   mat=[row[:]for row in worlds[5]];mat[0][3]=sample(track,frame);rows=[]
   for p,uv0 in zip(s.positions,s.uv0):
    pt=[sum(mat[r][k]*(p[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append([pt[0]/span,pt[1]/span,pt[2]/span,uv0[0],1-uv0[1],1.])
   poses[state].append(rows)
  dparts.append(dict(name=s.material,texture=texture(next(a.base_color_texture for a in dm.materials if a.name==s.material),1),vertices=poses[0][-1],indices=[k+1 for t in s.triangles for k in t],role='source_slateport_mart_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data={'oras_slateport_mart':body,'door':dict(id='oras_slateport_mart_doors',parts=dparts,poses=poses,jambs=[-14/span,14/span])};(output/'lib/ImportedSlateportMartData.lua').write_text('-- Original ORAS Slateport own Mart and BM0009; tools/import_oras_slateport_mart.py.\nreturn '+lua(data)+'\n')
 report=dict(source='Supplied Alpha Sapphire RomFS, Slateport GR149/ZO14/AD20/BM9',model=m.name,sourceStaticOrigin=[360,0,360],bodyOrigin=origin,normalizationSpan=span,sourceBodyTriangles=703,undersideTriangles=len(caps),rearClosure=rearproof,originalGroundTriangles=0,originalWarpDestination=266,originalDoorPlacement=[675,18,441],doorPhysicalTriangles=43,doorSideContactNativeInset=.05,sourceSliderX=[sample(track,f)for f in[0,2.5,5]],movingInverseBindError=errors['move'],textures=textures,sha256=dict(body=hashlib.sha256(raw).hexdigest(),door=hashlib.sha256(rawdoor).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Own original physical source geometry/UVs/indices independently checked; source exposure RGB and24 nonphysical door light triangles omitted. Actual source rim closes underside, original side profiles close rear. Native fit and ground-contact acceptance are separate.')
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
