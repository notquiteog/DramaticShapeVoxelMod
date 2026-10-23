#!/usr/bin/env python3
"""Export genuine ORAS Oldale Poké Mart and original BM0009 sliding-door poses.
External decoders and supplied RomFS paths are explicit; raw game files stay out.
"""
import argparse,hashlib,json,math,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path)
 sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-hoenn-marts';folder.mkdir(parents=True,exist_ok=True)
 textures={t.name:t for t in load_textures((root/'mapart-nitrogen/4/0008/011.bch').read_bytes())}
 textures.update({t.name:t for t in load_textures((root/'mapart-nitrogen/4/0008/001.bch').read_bytes())});treport={}
 def texture(name):
  if name not in treport:
   t=textures[name];data=png(t.rgba,t.width,t.height);(folder/(name+'.png')).write_bytes(data)
   treport[name]={'size':[t.width,t.height],'rgbaSha256':hashlib.sha256(t.rgba).hexdigest(),'pngSha256':hashlib.sha256(data).hexdigest()}
  return 'assets/scenery/oras-hoenn-marts/'+name+'.png'
 raw=(root/'mapgr-nitrogen/9/0004/001.bch').read_bytes();m=load(raw)[0];s=next(s for s in m.submeshes if s.material=='friendlyshop');need(len(s.triangles)==703,'Mart topology changed')
 ind=open_bch(raw).models[0].meshes[m.submeshes.index(s)]
 need(ind.positions==s.positions and ind.texcoords==s.uv0 and ind.submeshes[0].indices==[v for t in s.triangles for v in t],'independent Mart geometry differs')
 name=next(a.base_color_texture for a in m.materials if a.name==s.material)
 p=dict(name=s.material,texture=texture(name),vertices=[list(v)+[uv[0],1-uv[1],1.]for v,uv in zip(s.positions,s.uv0)],indices=[i+1 for t in s.triangles for i in t],role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat')
 bounds=[min(v[k]for v in s.positions)for k in range(3)]+[max(v[k]for v in s.positions)for k in range(3)]
 span=bounds[3]-bounds[0];origin=[(bounds[0]+bounds[3])/2,bounds[1],(bounds[2]+bounds[5])/2]
 def norm(v):return[(v[i]-origin[i])/span for i in range(3)]+v[3:]
 # Exact original bottom-rim vertices retain every chamfer and portal recess.
 rim=[(88.0529,-178.538),(163.9471,-178.538),(175.751,-165.734),(175.751,-135.006),(175.751,-104.848),(175.02,-103.546),(163.9471,-91.474),(163.122,-91.474),(148.8131,-91.474),(132.289,-91.474),(131,-92.5),(103,-92.5),(101.9237,-91.474),(88.8549,-91.474),(88.0529,-91.474),(77.1013,-103.426),(76.2494,-104.848),(76.2494,-135.006),(76.2494,-165.734)]
 vs=[]
 for x,z in rim:
  v=next((v for v in p['vertices']if abs(v[0]-x)<.0001 and abs(v[1])<.0001 and abs(v[2]-z)<.0001),None);need(v is not None,'Mart bottom rim changed');vs.append(v[:])
 def cross(a,b,c):return(b[0]-a[0])*(c[2]-a[2])-(b[2]-a[2])*(c[0]-a[0])
 loop=list(range(len(vs)));ii=[]
 while len(loop)>3:
  for j,n in enumerate(loop):
   a,c=loop[j-1],loop[(j+1)%len(loop)]
   if cross(vs[a],vs[n],vs[c])<=1e-8:continue
   if any(all(cross(vs[u],vs[v],vs[k])>=-1e-8 for u,v in((a,n),(n,c),(c,a)))for k in loop if k not in(a,n,c)):continue
   ii.extend([a+1,n+1,c+1]);loop.pop(j);break
  else:raise ValueError('cannot close original Mart underside')
 ii.extend([i+1 for i in loop]);cap=dict(p,name='authored_closed_underside',vertices=vs,indices=ii)
 parts=[p,cap]
 for q in parts:q['vertices']=[norm(v)for v in q['vertices']]
 # Town copies differ in topology/UV details; do not substitute this Oldale
 # source for Petalburg/Rustboro or claim a universal shared model.
 comparisons={'8':'distinct original topology/UV; separate adaptation required','38':'distinct source positions/UV; separate adaptation required'}
 data=dict(parts=parts,anchors={'door':norm([117,.5295029878616333,-92.4347992017865]),'doorLeft':norm([103,.5295029878616333,-92.4347992017865]),'doorRight':norm([131,.5295029878616333,-92.4347992017865]),'doorTop':norm([117,45.52950298786163,-92.4347992017865])})
 # Genuine single sliding panel: all43 physical triangles share move bone5.
 rawdoor=(root/'mapprops-nitrogen/3/0009/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='com_bm_fsdoor01','unexpected Mart door')
 worlds=[];errors={}
 for bone in di.skeleton:
  need(all(abs(v)<1e-8 for v in bone.rotation),'unreviewed Mart bind rotation')
  mat=[[bone.scale[r]if r==c else bone.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if bone.parent>=0:mat=mul(worlds[bone.parent],mat)
  worlds.append(mat)
  ib=[bone.inverse_bind[k:k+4]for k in range(0,16,4)];check=mul(mat,ib);errors[bone.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(errors['move']<1e-5,'Mart moving inverse bind disagrees')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0009/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward)
 need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'unexpected Mart animation');track=next(b.translation[0].keys for b in a[0].bones if b.name=='move')
 dparts=[];poses=[[],[],[]]
 for i,sub in enumerate(dm.submeshes):
  if sub.material=='Comb7':continue
  ni=di.meshes[i];draw=ni.submeshes[0];need(ni.positions==sub.positions and ni.texcoords==sub.uv0 and draw.indices==[v for t in sub.triangles for v in t],'independent Mart door geometry differs')
  need(all(b==[5]for b in sub.bones)and all(w==[1.]for w in sub.weights),'Mart door ownership differs')
  dp=dict(p,name=sub.material,texture=texture(next(a.base_color_texture for a in dm.materials if a.name==sub.material)),indices=[v+1 for t in sub.triangles for v in t],role='source_mart_door')
  for state,frame in enumerate([0,2.5,5]):
   mat=[row[:]for row in worlds[5]];mat[0][3]=sample(track,frame)
   rows=[]
   for pos,uv in zip(sub.positions,sub.uv0):
    point=[sum(mat[r][k]*(pos[k]if k<3 else 1)for k in range(4))for r in range(3)]
    rows.append(norm([point[0]+117,point[1],point[2]-92.5,uv[0],1-uv[1],1.]))
   poses[state].append(rows)
  dp['vertices']=poses[0][-1];dparts.append(dp)
 door=dict(id='oras_hoenn_mart_doors',parts=dparts,poses=poses)
 (output/'lib/ImportedHoennMartData.lua').write_text('-- Genuine ORAS Oldale Mart and single sliding panel; tools/import_oras_marts.py.\nreturn '+lua({'oras_oldale_mart':data,'door':door})+'\n')
 report=dict(source='User-supplied Alpha Sapphire RomFS; Oldale exterior family',body='GR0004 world01_02_02 friendlyshop',matchingTownMaximumErrors=comparisons,bodySourceTriangles=703,undersideTriangles=len(ii)//3,doorSourceTriangles=43,sourceBounds=bounds,normalizationOrigin=origin,normalizationSpan=span,door='BM0009 com_bm_fsdoor01',animationSamples=[0,2.5,5],sourceXSamples=[sample(track,f)for f in [0,2.5,5]],movingInverseBindMaximumError=errors['move'],textures=treport,sha256={'body':hashlib.sha256(raw).hexdigest(),'door':hashlib.sha256(rawdoor).hexdigest(),'animation':hashlib.sha256(anim).hexdigest()},processing='Original positions/UVs/triangles independently compared to Nitrogen. Source vertex exposure RGB and24 nonphysical light triangles omitted. Exact source bottom rim closed beneath building; all physical source triangles and original texture paint retained. No native collision/scripts/warps changed.')
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in ['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
