#!/usr/bin/env python3
"""Export both actual ORAS Oldale homes and BM0003 hinged door states.
Explicit external decoders and user source only; no raw game data bundled.
"""
import argparse,hashlib,json,math,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_center_doors import mul,sample
from oras_rear_closure import close_rear

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-oldale-homes';folder.mkdir(parents=True,exist_ok=True)
 banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0008/{k:03d}.bch').read_bytes())}for k in [1,11]};textures={}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];b=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(b);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(b).hexdigest())
  return 'assets/scenery/oras-oldale-homes/'+key+'.png'
 raw=(root/'mapgr-nitrogen/9/0004/001.bch').read_bytes();model=load(raw)[0];ind=open_bch(raw).models[0]
 origin=[153.588,0,163.094];span=97.
 def norm(v):return[(v[i]-origin[i])/span for i in range(3)]+v[3:]
 rim=[(109.305,131.765),(198.047,131.765),(198.047,135.179),(198.047,149.137),(198.047,163.094),(198.047,177.051),(198.047,191.008),(198.047,194.422),(196.004,196.465),(192.59,196.465),(181.676,196.465),(170.176,196.465),(158.676,196.465),(151.676,196.465),(149.59,196.465),(147.676,195.094),(147.676,192.094),(123.676,192.094),(123.676,195.094),(122.676,196.465),(114.703,196.416),(111.289,196.416),(109.305,194.422),(109.305,191.008),(109.305,177.051),(109.305,163.094),(109.305,149.137),(109.305,135.179)]
 data={};reports={}
 for side,dx,dz in [('southeast',0,0),('northwest',-270,-270)]:
  parts=[];count=0
  for sub in model.submeshes:
   if sub.material not in ['t102_01','chip_mado']:continue
   ni=ind.meshes[model.submeshes.index(sub)];need(sub.positions==ni.positions and sub.uv0==ni.texcoords and ni.submeshes[0].indices==[v for t in sub.triangles for v in t],'independent house geometry differs')
   selected=[]
   for tri in sub.triangles:
    inside=[100<v[0]-dx<205 and 120<v[2]-dz<205 for v in [sub.positions[i]for i in tri]]
    need(all(inside)or not any(inside),'source triangle crosses selected house boundary')
    if all(inside):selected.append(tri)
   if not selected:continue
   used=sorted(set(i for t in selected for i in t));remap={v:i+1 for i,v in enumerate(used)}
   vs=[[sub.positions[i][0]-dx,sub.positions[i][1],sub.positions[i][2]-dz,sub.uv0[i][0],1-sub.uv0[i][1],1.]for i in used]
   name=next(a.base_color_texture for a in model.materials if a.name==sub.material)
   parts.append(dict(name=sub.material,texture=texture(name,11),vertices=vs,indices=[remap[i]for t in selected for i in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'));count+=len(selected)
  need(len(parts)==2 and count in [1030,1038],f'unexpected original house pieces {side} {len(parts)} {count}')
  body=parts[0];bottom=[]
  for x,z in rim:
   v=next((v for v in body['vertices']if abs(v[0]-x)<.0006 and abs(v[1])<.0001 and abs(v[2]-z)<.0007),None);need(v is not None,'original house rim changed');row=v[:];row[3:5]=[220.5/256,16.5/128];bottom.append(row)
  def cross(a,b,c):return(b[0]-a[0])*(c[2]-a[2])-(b[2]-a[2])*(c[0]-a[0])
  loop=list(range(len(bottom)));ii=[]
  while len(loop)>3:
   for j,n in enumerate(loop):
    a,c=loop[j-1],loop[(j+1)%len(loop)]
    if cross(bottom[a],bottom[n],bottom[c])<=1e-8:continue
    if any(all(cross(bottom[u],bottom[v],bottom[k])>=-1e-8 for u,v in((a,n),(n,c),(c,a)))for k in loop if k not in(a,n,c)):continue
    ii.extend([a+1,n+1,c+1]);loop.pop(j);break
   else:raise ValueError('cannot close exact source house rim')
  ii.extend([i+1 for i in loop]);parts.append(dict(body,name='authored_closed_underside',vertices=bottom,indices=ii))
  for p in parts:p['vertices']=[norm(v)for v in p['vertices']]
  rear,rearproof=close_rear(parts,'t102_01',[220.5/256,16.5/128],span);parts.append(rear)
  data['oras_oldale_home_'+side]=dict(parts=parts,anchors={'door':norm([135.676,0,192.094]),'doorLeft':norm([123.676,0,192.094]),'doorRight':norm([147.676,0,192.094]),'doorTop':norm([135.676,45.62,192.094])})
  reports[side]=dict(sourcePhysicalTriangles=count,rearClosure=rearproof,sourceTrianglesByPart=[len(p['indices'])//3 for p in parts],sourceWorldOffset=[dx,0,dz],selection='Own complete source triangles inside actual house region, never clipped or substituted',sourceWindowDetails='Actual southeast14-triangle or northwest6-triangle source glass retained')
 # Independent rigid bind and original -80degree Y hinge track.
 rawdoor=(root/'mapprops-nitrogen/3/0003/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='t102_bm_door01','unexpected Oldale door')
 worlds=[];errors={}
 for b in di.skeleton:
  need(all(abs(v)<1e-8 for v in b.rotation),'unreviewed Oldale door bind rotation')
  mat=[[b.scale[r]if r==c else b.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if b.parent>=0:mat=mul(worlds[b.parent],mat)
  worlds.append(mat);check=mul(mat,[b.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[b.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(errors[b]for b in ['t102_bm_door01','anim_door'])<1e-5,'Oldale moving bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0003/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'unexpected Oldale door animation')
 track=next(b.rotation[1].keys for b in a[0].bones if b.name=='anim_door');angles=[sample(track,f)for f in [0,2.5,5]];poses=[[],[],[]];dparts=[]
 # Closed source panel right147.676 meets original doorway right edge exactly;
 # its25-unit original panel overlaps the24-unit opening under the left trim.
 right=max(v[0]for s in dm.submeshes if s.material!='Comb7'for v in s.positions)+worlds[1][0][3];offsetX=147.676-right
 for i,sub in enumerate(dm.submeshes):
  if sub.material=='Comb7':continue
  ni=di.meshes[i];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[v for t in sub.triangles for v in t],'independent Oldale door geometry differs')
  need(all(b==[1]for b in sub.bones)and all(w==[1.]for w in sub.weights),'unexpected Oldale door ownership')
  for state,angle in enumerate(angles):
   c,s=math.cos(angle),math.sin(angle);mat=mul(worlds[1],[[c,0,s,0],[0,1,0,0],[-s,0,c,0],[0,0,0,1]]);rows=[]
   for pos,uv in zip(sub.positions,sub.uv0):
    pt=[sum(mat[r][k]*(pos[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append(norm([pt[0]+offsetX,pt[1],pt[2]+192.094,uv[0],1-uv[1],1.]))
   poses[state].append(rows)
  dparts.append(dict(name=sub.material,texture=texture(next(a.base_color_texture for a in dm.materials if a.name==sub.material),1),vertices=poses[0][-1],indices=[v+1 for t in sub.triangles for v in t],role='source_oldale_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data['door']=dict(id='oras_oldale_home_doors',parts=dparts,poses=poses)
 (output/'lib/ImportedOldaleHomesData.lua').write_text('-- Own authentic ORAS Oldale home variants+hinged source door; tools/import_oras_oldale_homes.py.\nreturn '+lua(data)+'\n')
 report=dict(source='User-supplied Alpha Sapphire RomFS',body='GR0004 world01_02_02 t102_01/chip_mado',variants=reports,door='BM0003 t102_bm_door01',doorPhysicalTriangles=84,doorAnglesRadians=angles,movingInverseBindMaximumError=max(errors[b]for b in ['t102_bm_door01','anim_door']),sourceNormalizationOrigin=origin,sourceNormalizationSpan=span,doorAlignment=dict(closedOriginalRight=right,originalOpeningRight=147.676,instanceX=offsetX,instanceZ=192.094),textures=textures,sha256=dict(body=hashlib.sha256(raw).hexdigest(),door=hashlib.sha256(rawdoor).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Exact original body and door positions/UVs/triangles independently checked with Nitrogen. Source exposure RGB and24 nonphysical light-effect triangles omitted. Each own house variant retains every source fixture and its own front/side glass. Exact source bottom rim closes below floor at upload using one reviewed solid original foundation texel; original source body has no horizontal y0 floor triangles. No source terrain, fences, sprites or flowers included.')
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in ['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
