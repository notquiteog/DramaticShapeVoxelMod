#!/usr/bin/env python3
"""Export own ORAS Rustboro Cutters/House1/House2/School bodies and BM0013 hinges."""
import argparse,hashlib,json,math,sys,struct
from pathlib import Path
from oras_scenery_source import decoder,need,garc,mini
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-rustboro-homes';folder.mkdir(parents=True,exist_ok=True)
 banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0011/{k:03d}.bch').read_bytes())}for k in[1,11]};textures={}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-rustboro-homes/'+key+'.png'
 # Bind each selected static body to the actual source BM13 placement and warp.
 grarchive=garc((root/'alpha-sapphire-romfs/a/0/3/9').read_bytes());zoarchive=garc((root/'alpha-sapphire-romfs/a/0/1/3').read_bytes())
 entities=mini(zoarchive.single(16),'ZO')[1];nf,nn,nw,nt=struct.unpack_from('<4B',entities,4);warps={}
 for i in range(nw):
  record=entities[12+nf*20+nn*48+i*24:12+nf*20+nn*48+(i+1)*24];destination=struct.unpack_from('<H',record)[0];x,_,z=struct.unpack_from('<3h',record,8);warps[destination]=(x,z)
 portals={}
 for name,gr,x,z,destination in [('cutters',37,2115,3753,300),('house1',33,2727,3321,296),('house2',33,2727,3681,295),('school',33,2565,3681,289)]:
  objectgr=38 if name in['house2','school']else gr
  records=mini(grarchive.single(objectgr),'GR')[3];count=struct.unpack_from('<I',records)[0];objects=[struct.unpack_from('<I10f',records,4+i*44)for i in range(count)]
  need(any(o[0]==13 and o[1:4]==(1.,1.,1.)and o[4:7]==(0.,0.,0.)and o[7:10]==(x,0.,z)for o in objects),'original Rustboro BM13 placement differs')
  need(warps[destination]==(x,z),'original Rustboro warp differs');portals[name]=dict(zone=16,bodyGr=gr,objectGr=objectgr,bm=13,world=[x,0,z],destination=destination)
 data={};report={};span=131.
 for name,gr,cx,cz,destination in [('cutters',37,315,-207,300),('house1',33,207,81,296),('house2',33,207,441,295),('school',33,45,441,289)]:
  raw=(root/f'mapgr-nitrogen/9/{gr:04d}/001.bch').read_bytes();m=load(raw)[0];ind=open_bch(raw).models[0];parts=[];counts={};base=0 if name=='school'else .25;bottom=[]
  for j,sub in enumerate(m.submeshes):
   if sub.material not in ['kanazumi_house13','kanazumi_komono','chip_mado']:continue
   ni=ind.meshes[j];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[v for t in sub.triangles for v in t],'independent Rustboro source differs')
   selected=[]
   for tri in sub.triangles:
    inside=[abs(sub.positions[i][0]-cx)<75 and abs(sub.positions[i][2]-cz)<100 for i in tri]
    need(all(inside)or not any(inside),'triangle crosses Rustboro house selection')
    if all(inside):selected.append(tri)
   if not selected:continue
   need(not any(all(abs(sub.positions[i][1]-base)<1e-6 for i in t)for t in selected),'source ground plane needs audit')
   groups={}
   for tri in selected:
    alpha=[sub.colors[i][3]if sub.colors else 1. for i in tri];need(max(alpha)-min(alpha)<1e-8,'varying physical alpha needs review');need(alpha[0]in[1.,.6],'unexpected physical opacity');groups.setdefault(alpha[0],[]).append(tri)
   for opacity,tris in groups.items():
    used=sorted(set(i for t in tris for i in t));remap={n:i+1 for i,n in enumerate(used)};vs=[[sub.positions[i][0]-cx,sub.positions[i][1]-base,sub.positions[i][2]-cz,sub.uv0[i][0],1-sub.uv0[i][1],1.]for i in used]
    part=dict(name=sub.material+('_alpha06'if opacity<1 else ''),texture=texture(next(a.base_color_texture for a in m.materials if a.name==sub.material),11),vertices=vs,indices=[remap[i]for t in tris for i in t],role='structure',alphaMode='blend'if opacity<1 else 'cutout',opacity=opacity,wrapS='repeat',wrapT='repeat');parts.append(part);counts[part['name']]=len(tris)
    if sub.material=='kanazumi_house13':bottom=[v[:]for v in vs if abs(v[1])<1e-6]
    if name=='school'and part['name']=='kanazumi_komono':
     # Two original window returns overlap the original column sides at X±37.5.
     # Keep both source paints; narrow only those four coplanar return triangles
     # to their exposed Z6.5..7 strip, interpolating the original affine UVs.
     changed=0;original=list(part['indices']);newindices=[]
     for at in range(0,len(original),3):
      ids=original[at:at+3];rows=[part['vertices'][i-1]for i in ids]
      plane=abs(abs(rows[0][0])-37.5)<1e-6 and all(abs(v[0]-rows[0][0])<1e-6 and 29.5-1e-6<=v[1]<=44.5+1e-6 and 5-1e-6<=v[2]<=7+1e-6 for v in rows)
      if plane:
       changed+=1
       for v in rows:
        row=v[:]
        if row[2]<6.5:
         other=next(q for q in vs if abs(q[0]-row[0])<1e-6 and abs(q[1]-row[1])<1e-6 and abs(q[2]-7)<1e-6);t=(6.5-row[2])/(other[2]-row[2]);row[3:5]=[row[k]+t*(other[k]-row[k])for k in[3,4]];row[2]=6.5
        part['vertices'].append(row);newindices.append(len(part['vertices']))
      else:newindices.extend(ids)
     need(changed==4,'reviewed school window returns changed');part['indices']=newindices

  need(len(parts)==(4 if name=='school'else 3) and counts['kanazumi_house13']==(422 if name=='school'else 338),'unexpected Rustboro topology')
  unique={tuple(round(v[k],5)for k in[0,2]):v for v in bottom};need(len(unique)==(20 if name=='school'else 16),'original Rustboro rim changed')
  center=[sum(v[k]for v in unique.values())/len(unique)for k in[0,2]];bottom=sorted(unique.values(),key=lambda v:math.atan2(v[2]-center[1],v[0]-center[0]))
  # A single original bottom-wall texel closes the underside without projecting windows.
  for v in bottom:v[3:5]=[9.5/128,80.5/128]
  def cross(a,b,c):return(b[0]-a[0])*(c[2]-a[2])-(b[2]-a[2])*(c[0]-a[0])
  loop=list(range(len(bottom)));ii=[]
  while len(loop)>3:
   for j,n in enumerate(loop):
    a,c=loop[j-1],loop[(j+1)%len(loop)]
    if cross(bottom[a],bottom[n],bottom[c])<=1e-8:continue
    if any(all(cross(bottom[u],bottom[v],bottom[k])>=-1e-8 for u,v in((a,n),(n,c),(c,a)))for k in loop if k not in(a,n,c)):continue
    ii.extend([a+1,n+1,c+1]);loop.pop(j);break
   else:raise ValueError('Rustboro underside triangulation failed')
  ii.extend([i+1 for i in loop]);cap=dict(next(p for p in parts if p['name']=='kanazumi_house13'),name='authored_closed_underside',vertices=bottom,indices=ii);parts.append(cap)
  for p in parts:p['vertices']=[[v[0]/span,v[1]/span,v[2]/span]+v[3:]for v in p['vertices']]
  data['oras_rustboro_'+name]=dict(parts=parts,anchors={'door':[0,0,0],'doorLeft':[-12/span,0,0],'doorRight':[12/span,0,0],'doorTop':[0,45/span,0]})
  report[name]=dict(gr=gr,model=m.name,sourceTrianglesByMaterial=counts,undersideTriangles=len(ii)//3,sourceOrigin=[cx,base,cz],originalZoneDestination=destination,sourceBchSha256=hashlib.sha256(raw).hexdigest(),originalHorizontalGroundFaces=0)
 # Original GR object placement BM13 c104_bm_door01, source -80degree hinge.
 raw=(root/'mapprops-nitrogen/3/0013/000.bch').read_bytes();m=load(raw)[0];ind=open_bch(raw).models[0];need(m.name=='c104_bm_door01','unexpected Rustboro door');worlds=[];errors={}
 for b in ind.skeleton:
  need(all(abs(v)<1e-8 for v in b.rotation),'unreviewed bind rotation');mat=[[b.scale[r]if r==c else b.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if b.parent>=0:mat=mul(worlds[b.parent],mat)
  worlds.append(mat);check=mul(mat,[b.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[b.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(errors[b]for b in['c104_door','anim_door'])<1e-5,'Rustboro moving inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0013/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'unexpected hinge animation')
 track=next(b.rotation[1].keys for b in a[0].bones if b.name=='anim_door');angles=[sample(track,f)for f in[0,2.5,5]];poses=[[],[],[]];dparts=[]
 for i,sub in enumerate(m.submeshes):
  if sub.material=='Comb7':continue
  need(not sub.colors or all(abs(v[3]-1)<1e-8 for v in sub.colors),'physical door alpha needs review');ni=ind.meshes[i];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and ni.submeshes[0].indices==[v for t in sub.triangles for v in t],'independent Rustboro door differs');need(all(b==[1]for b in sub.bones)and all(w==[1.]for w in sub.weights),'door ownership differs')
  for state,angle in enumerate(angles):
   c,s=math.cos(angle),math.sin(angle);mat=mul(worlds[1],[[c,0,s,0],[0,1,0,0],[-s,0,c,0],[0,0,0,1]]);rows=[]
   for pos,uv in zip(sub.positions,sub.uv0):
    pt=[sum(mat[r][k]*(pos[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append([pt[0]/span,pt[1]/span,pt[2]/span,uv[0],1-uv[1],1.])
   poses[state].append(rows)
  dparts.append(dict(name=sub.material,texture=texture(next(a.base_color_texture for a in m.materials if a.name==sub.material),1),vertices=poses[0][-1],indices=[v+1 for t in sub.triangles for v in t],role='source_rustboro_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data['door']=dict(id='oras_rustboro_home_doors',parts=dparts,poses=poses);(output/'lib/ImportedRustboroHomesData.lua').write_text('-- Original ORAS Rustboro houses and BM0013; tools/import_oras_rustboro_homes.py.\nreturn '+lua(data)+'\n')
 result=dict(source='Supplied Alpha Sapphire RomFS, original Rustboro ZO16/AD11/MM4',variants=report,sourcePortals=portals,schoolPhysicalAlpha06Triangles=8,schoolCoplanarWindowReturnTrianglesClipped=4,doorTopCapNativeInset=.05,normalizationSpan=span,door='BM0013 c104_bm_door01',doorPhysicalTriangles=150,doorAnglesRadians=angles,movingInverseBindMaximumError=max(errors[b]for b in['c104_door','anim_door']),textures=textures,sha256=dict(door=hashlib.sha256(raw).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Original physical geometry/UVs/indices independently checked. Source exposure RGB and24 nonphysical light faces omitted. No source ground/fences; original bottom rim closed and recessed at upload, portals fixed. Four school return triangles are clipped to the exposed strip to remove original coplanar column overlap; door top-cap contact vertices recess .05 native units under their original lintel at upload.')
 (folder/'provenance.json').write_text(json.dumps(result,indent=2)+'\n');return result
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
