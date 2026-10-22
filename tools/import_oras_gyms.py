#!/usr/bin/env python3
"""Export reviewed ORAS corridor Gyms, notice and original hinged door states.
External decoders and user RomFS extraction are explicit inputs, never bundled.
"""
import argparse,collections,hashlib,json,math,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def sha(b):return hashlib.sha256(b).hexdigest()
def bounds(rows):return[min(v[k]for v in rows)for k in range(3)]+[max(v[k]for v in rows)for k in range(3)]
def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path)
 sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-hoenn-gyms';folder.mkdir(parents=True,exist_ok=True)
 textures={t.name:t for t in load_textures((root/'mapart-nitrogen/4/0009/011.bch').read_bytes())};textures.update({t.name:t for t in load_textures((root/'mapart-nitrogen/4/0009/001.bch').read_bytes())})
 texture_report={}
 def texture(name):
  if name not in texture_report:
   t=textures[name];data=png(t.rgba,t.width,t.height);(folder/(name+'.png')).write_bytes(data)
   texture_report[name]=dict(size=[t.width,t.height],rgbaSha256=sha(t.rgba),pngSha256=sha(data))
  return'assets/scenery/oras-hoenn-gyms/'+name+'.png'
 def part(s,m):
  need(not s.colors or all(abs(c[3]-1)<1e-8 for c in s.colors),'nonopaque source vertex alpha requires review')
  name=next(a.base_color_texture for a in m.materials if a.name==s.material)
  return dict(name=s.material,texture=texture(name),vertices=[list(p)+[uv[0],1-uv[1],1.]for p,uv in zip(s.positions,s.uv0)],indices=[n+1 for t in s.triangles for n in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat')
 raws={k:(root/f'mapgr-nitrogen/9/{k:04d}/001.bch').read_bytes()for k in(7,8,22,33)}
 models={k:load(v)[0]for k,v in raws.items()}
 m=models[7];need(m.name=='world02_02_02'and not m.bones,'unexpected Gym source')
 selected=[s for s in m.submeshes if s.material.startswith('poke_gym')and s.material!='poke_gym_light']
 need([len(s.triangles)for s in selected]==[488,412,106,6,28],'Gym physical topology changed')
 second=open_bch(raws[7]).models[0]
 for s in selected:
  i=m.submeshes.index(s);n=second.meshes[i]
  need(n.positions==s.positions and n.texcoords==s.uv0 and n.submeshes[0].indices==[v for t in s.triangles for v in t],'independent Gym positions/UVs/triangles differ')
 parts=[part(s,m)for s in selected];b=bounds([v for p in parts for v in p['vertices']]);span=b[3]-b[0];origin=[(b[0]+b[3])/2,b[1],(b[2]+b[5])/2]
 # Exact18 source bottom vertices describe angled corners and recessed doorway.
 rim=[(-77.5859,274.5858),(23.5857,274.5858),(31.9999,283),(31.9999,306),(31.9999,329),(22.8871,338),(3.1472,338),(-6.6159,358),(-12.0001,358),(-12.0001,350),(-42.0001,350),(-42.0001,358),(-47.3843,358),(-57.1474,338),(-76.8873,338),(-86.0001,329),(-86.0001,306),(-86.0001,283)]
 waku=parts[1];vs=[]
 for x,z in rim:
  found=next((v for v in waku['vertices']if abs(v[0]-x)<.0001 and abs(v[1]-.5)<.0001 and abs(v[2]-z)<.0001),None);need(found is not None,'reviewed Gym underside rim changed');vs.append(found[:])
 # Ear clipping keeps the actual concave portal recess, with no crossing fans.
 loop=list(range(len(vs)));indices=[]
 def cross(a,b,c):return(b[0]-a[0])*(c[2]-a[2])-(b[2]-a[2])*(c[0]-a[0])
 while len(loop)>3:
  for j,n in enumerate(loop):
   a,c=loop[j-1],loop[(j+1)%len(loop)]
   if cross(vs[a],vs[n],vs[c])<=1e-8:continue
   if any(all(cross(vs[u],vs[v],vs[k])>=-1e-8 for u,v in((a,n),(n,c),(c,a)))for k in loop if k not in(a,n,c)):continue
   indices.extend([a+1,n+1,c+1]);loop.pop(j);break
  else:raise ValueError('Gym underside cannot be triangulated')
 indices.extend([i+1 for i in loop]);parts.append(dict(name='authored_closed_underside',texture=waku['texture'],vertices=vs,indices=indices,role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 def norm(p):return[(p[i]-origin[i])/span for i in range(3)]+p[3:]
 for p in parts:p['vertices']=[norm(v)for v in p['vertices']]
 anchor=norm([-27.0001,.5,350]);data={'oras_hoenn_gym':dict(parts=parts,anchors={'door':anchor,'doorLeft':norm([-42.0001,.5,350]),'doorRight':norm([-12.0001,.5,350]),'doorTop':norm([-27.0001,47.5,350])})}
 comparisons={}
 for k,offset in[(22,(0,-18,-216)),(33,(72,-.25,-270))]:
  other=[s for s in models[k].submeshes if 'poke_gym'in s.material and not s.material.endswith('_light')and not s.material.endswith('_sign')]
  need(len(other)==5,'unexpected town Gym parts')
  errors=[]
  for source,copy in zip(selected,other):
   need(source.triangles==copy.triangles and source.uv0==copy.uv0,'town Gym topology/UV family differs')
   errors.extend(abs(a[i]+offset[i]-c[i])for a,c in zip(source.positions,copy.positions)for i in range(3))
  comparisons[str(k)]=max(errors);need(max(errors)<.0003,'town Gym geometry differs')
 # Notice is a separate standing object, not a projected texture or attached sign.
 sign=next(s for s in models[8].submeshes if s.material=='poke_gym_sign');sp=part(sign,models[8]);sb=bounds(sp['vertices']);ss=sb[3]-sb[0];so=[(sb[0]+sb[3])/2,sb[1],(sb[2]+sb[5])/2]
 # Close the two exact source leg bottoms only, retaining the open leg gap.
 bottom=[]
 for left,right in((21.9017,24.2208),(33.4972,35.8163)):
  first=len(bottom)
  for x,z in((left,-315.1674),(right,-315.1674),(right,-312.8484),(left,-312.8484)):
   v=next((v for v in sp['vertices']if abs(v[0]-x)<.0001 and abs(v[1])<1e-8 and abs(v[2]-z)<.0001),None);need(v is not None,'Gym notice leg rim changed');bottom.append(v[:])
 cap=dict(sp);cap.update(name='authored_notice_leg_undersides',vertices=bottom,indices=[1,2,3,1,3,4,5,6,7,5,7,8])
 for p in(sp,cap):p['vertices']=[[(v[i]-so[i])/ss for i in range(3)]+v[3:]for v in p['vertices']]
 data['oras_hoenn_gym_notice']=dict(parts=[sp,cap],anchors={'ground':[0.,0.,0.]})
 # Independent rigid palette fixes the decoder's missing weight=1 fallback on
 # mixed-palette rigid glass: first10 vertices left, final8 right, never allleft.
 raw=(root/'mapprops-nitrogen/3/0010/000.bch').read_bytes();door=load(raw)[0];ind=open_bch(raw).models[0];need(door.name=='com_bm_gymdoor01','unexpected Gym door')
 worlds=[];bind_errors={}
 for i,bone in enumerate(ind.skeleton):
  need(all(abs(v)<1e-8 for v in bone.rotation),'unreviewed Gym bone rotation')
  t=[[bone.scale[r]if r==c else bone.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if bone.parent>=0:t=mul(worlds[bone.parent],t)
  worlds.append(t);ib=[bone.inverse_bind[k:k+4]for k in range(0,16,4)];check=mul(t,ib);bind_errors[bone.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(bind_errors[door.bones[i].name]for i in(0,1,2))<1e-5,'Gym moving inverse binds disagree')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0010/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward)
 need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'unexpected Gym animation')
 tracks={b.name:b.rotation[1].keys for b in a[0].bones if b.name in('anim_door_left','anim_door_right')};need(len(tracks)==2,'Gym hinge animation absent')
 dparts=[];poses=[[],[],[]];bindings=[]
 for i,s in enumerate(door.submeshes):
  if s.material=='Comb7':continue
  n=ind.meshes[i];draw=n.submeshes[0];need(s.positions==n.positions and s.uv0==n.texcoords and draw.indices==[v for t in s.triangles for v in t],'independent Gym door geometry differs')
  palette=draw.bone_indices;need(draw.skinning==2 and set(palette)<=set((1,2)),'Gym door is not rigid')
  owners=[palette[q[0]]for q in n.bone_indices]if n.bone_indices else[palette[0]]*len(s.positions);bindings.append(owners)
  p=part(s,door);p['role']='source_gym_door';dparts.append(p)
  for state,frame in enumerate((0.,2.5,5.)):
   rows=[]
   for pos,uv,owner in zip(s.positions,s.uv0,owners):
    angle=sample(tracks[door.bones[owner].name],frame);c,si=math.cos(angle),math.sin(angle);rotation=[[c,0,si,0],[0,1,0,0],[-si,0,c,0],[0,0,0,1]];matrix=mul(worlds[owner],rotation)
    point=[sum(matrix[r][k]*(pos[k]if k<3 else 1)for k in range(4))for r in range(3)]
    rows.append(norm([point[0]-27.0001,point[1]+.5,point[2]+350,uv[0],1-uv[1],1.]))
   poses[state].append(rows)
  p['vertices']=poses[0][-1]
 door_data=dict(id='oras_hoenn_gym_doors',parts=dparts,poses=poses)
 (output/'lib/ImportedHoennGymData.lua').write_text('-- Source ORAS GR0007/0008 Gym and notice; generated by tools/import_oras_gyms.py.\nreturn '+lua(data)+'\n')
 (output/'lib/ImportedHoennGymDoorData.lua').write_text('-- Source ORAS BM0010 original hinged Gym doors; three native states.\nreturn '+lua(door_data)+'\n')
 report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',graphicsBchSha256={str(k):sha(v)for k,v in raws.items()},textureBchSha256={str(k):sha((root/f'mapart-nitrogen/4/0009/{k:03d}.bch').read_bytes())for k in(1,11)},doorModelSha256=sha(raw),doorAnimationSha256=sha(anim),sourceBounds=b,origin=origin,divisor=span,sourceTriangles=1040,undersideTriangles=len(indices)//3,noticeBounds=sb,noticeTriangles=len(sign.triangles),noticeUndersideTriangles=4,townGeometryMaximumTranslationError=comparisons,doorBindErrors=bind_errors,doorRigidPalettes=bindings,doorPhysicalTriangles=sum(len(p['indices'])//3 for p in dparts),doorAngles=[[sample(tracks['anim_door_'+side],f)for side in('left','right')]for f in(0.,2.5,5.)],textures=texture_report,processing=['Original physical source triangles/UVs/texture pixels retained; source RGB exposure tint omitted, alpha preserved by original PNGs.','Two source Gym glow triangles and24 BM light-effect triangles omitted; native renderer owns lighting.','Sixteen underside triangles use exact18 source bottom-rim vertices and original UVs; concave source portal recess remains.','GR22/33 genuine town Gyms independently match GR7 source geometry, topology and UVs within recorded translation error.','BM mixed rigid glass palette checked using Nitrogen per-vertex attributes, avoiding incorrect all-left fallback in n3ds_importer. Original source +/-90degree hinge tracks sampled at0/2.5/5; native scripts own timing.'],limitations=['No global texture AO recoloring performed. Native dynamic lighting is applied to original painted textures.','Original PICA/TEV and emissive effect animation are not emulated.'])
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data,door_data,report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in('root','decoder','nitrogen','output'):p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();_,_,r=convert(a.root,a.decoder,a.nitrogen,a.output);print('Gym',r['sourceTriangles'],'+',r['undersideTriangles'],'notice',r['noticeTriangles'],'door',r['doorPhysicalTriangles'])
