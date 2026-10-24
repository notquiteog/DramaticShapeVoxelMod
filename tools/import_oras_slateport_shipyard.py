#!/usr/bin/env python3
"""Export the original ORAS Stern Shipyard, its crane and original BM0039 hinge."""
import argparse,collections,hashlib,json,math,struct,sys
from pathlib import Path
from oras_scenery_source import decoder,need,garc,mini,decompress
from oras_rear_closure import close_rear,_subtract
from oras_fixture_shells import close_fixture_shells
from oras_geometry_audit import coplanar_overlaps,subtract_reviewed_overlaps,components,hull
from import_oras_devon import triangulate
from import_oras_grass import lua
from import_oras_center_doors import mul,sample

def convert(root,decoder_path,nitrogen_path,output):
 load,load_textures,png=decoder(decoder_path);sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
 folder=output/'assets/scenery/oras-slateport-shipyard';folder.mkdir(parents=True,exist_ok=True);textures={};banks={k:{t.name:t for t in load_textures((root/f'mapart-nitrogen/4/0020/{k:03d}.bch').read_bytes())}for k in[1,11]}
 def texture(name,bank):
  key=str(bank)+'_'+name
  if key not in textures:
   t=banks[bank][name];data=png(t.rgba,t.width,t.height);(folder/(key+'.png')).write_bytes(data);textures[key]=dict(size=[t.width,t.height],rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(data).hexdigest())
  return 'assets/scenery/oras-slateport-shipyard/'+key+'.png'
 gr=mini(garc((root/'alpha-sapphire-romfs/a/0/3/9').read_bytes()).single(152),'GR');raw=(root/'mapgr-nitrogen/9/0152/001.bch').read_bytes();need(decompress(gr[1])==raw,'original Shipyard static source differs');m=load(raw)[0];ind=open_bch(raw).models[0];need(m.name=='c102_01_01','unexpected Shipyard source')
 records=gr[3];need(any((lambda o:o[0]==39 and o[1:4]==(1.,1.,1.)and o[4:7]==(0.,0.,0.)and o[7:10]==(855.,18.,891.))(struct.unpack_from('<I10f',records,4+i*44))for i in range(struct.unpack_from('<I',records)[0])),'original BM39 Shipyard placement differs')
 entities=mini(garc((root/'alpha-sapphire-romfs/a/0/1/3').read_bytes()).single(14),'ZO')[1];nf,nn,nw,nt=struct.unpack_from('<4B',entities,4);need(any(struct.unpack_from('<H',entities,12+nf*20+nn*48+i*24)[0]==267 and struct.unpack_from('<3h',entities,20+nf*20+nn*48+i*24)==(855,18,891)for i in range(nw)),'Shipyard ZO14→267 doorway differs')
 origin=[855.,18.5,891.];offset=[1080.,0.,1080.];span=226.;parts=[];counts={};ground_profiles=[];clipped=0;physical_alpha={}
 for i,s in enumerate(m.submeshes):
  if s.material not in['tent_shipyard','museum_waku','chip_mado']:continue
  ni=ind.meshes[i];need(ni.positions==s.positions and ni.texcoords==s.uv0 and ni.submeshes[0].indices==[k for t in s.triangles for k in t],'independent Shipyard source geometry differs')
  groups=collections.defaultdict(list)
  for group in components(s):
   vs=[s.positions[i]for t in group for i in t];lo=min(v[2]+1080 for v in vs);hi=max(v[2]+1080 for v in vs)
   need(hi<970 or lo>970,'Shipyard/south-crane/house source boundary crosses a component')
   if lo>970:continue
   name=s.material
   if name=='tent_shipyard':name+='_' +('crane'if max(v[0]+1080 for v in vs)>960 else'body')
   groups[name].append(group)
  material=next(a for a in m.materials if a.name==s.material);alphas=set(s.colors[j][3]if s.colors else 1. for gg in groups.values()for g in gg for t in g for j in t);need(len(alphas)==1,'varying physical source alpha needs review');alpha=next(iter(alphas));physical_alpha[s.material]=alpha
  for name,gg in groups.items():
   vertices=[];indices=[];lookup={};section_profiles=[]
   for group in gg:
    section=[]
    for tri in group:
     poly=[[(s.positions[j][k]+offset[k]-origin[k])/span for k in range(3)]+[s.uv0[j][0],1-s.uv0[j][1],1.]for j in tri]
     before=poly;poly=[];prev=before[-1]
     for v in before:
      if(prev[1]>=0)!=(v[1]>=0):
       t=prev[1]/(prev[1]-v[1]);p=[prev[k]+t*(v[k]-prev[k])for k in range(6)];p[1]=0.;poly.append(p)
      if v[1]>=0:poly.append(v)
      prev=v
     if any(v[1]<0 for v in before):clipped+=1
     for v in poly:
      if abs(v[1]*span)<.0001:v[1]=0.
      if v[1]==0:section.append([v[0],v[2]])
     for at in range(1,len(poly)-1):
      for v in[poly[0],poly[at],poly[at+1]]:
       key=tuple(v)
       if key not in lookup:lookup[key]=len(vertices)+1;vertices.append(v)
       indices.append(lookup[key])
    profile=hull(section)
    if profile:section_profiles.append(profile)
   counts[name]=len(indices)//3;ground_profiles.extend(section_profiles);part=dict(name=name,texture=texture(material.base_color_texture,11),vertices=vertices,indices=indices,role='structure',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat')
   if alpha!=1:part.update(colors=[[1.,1.,1.,alpha]for v in vertices],vertexColorRole='lighting')
   parts.append(part)
 cleanup={}
 for name,pairs in [('tent_shipyard_body',[(449,423),(449,438),(455,426),(455,428)]),('tent_shipyard_crane',[(154,116),(155,116),(155,118)]+[(target,covered)for target in[480,481]for covered in[8,9,44,45,51,53,90,91]])]:
  cleanup[name]=subtract_reviewed_overlaps(next(p for p in parts if p['name']==name),pairs)
 # The original missing rear has no rim edge; preserve its exact side corners
 # and the real concave portal recess when closing the body underside.
 outline=[(813,815),(951.5,815),(951.5,894.9744),(949.6478,897),(867.9058,897),(867.9058,880.5),(842.83,880.5),(842.83,897),(815.9351,897),(813,894.9744)]
 caps=[]
 def append(poly):
  fragments=[poly]
  for triangle in caps:fragments=[q for p in fragments for q in _subtract(p,triangle)]
  caps.extend(triangle for p in fragments for triangle in triangulate(p))
 sourcepoints=[v for p in parts for v in p['vertices']]
 for x,z in outline:need(any(abs(v[0]*span+855-x)<.001 and abs(v[2]*span+891-z)<.001 and v[1]==0 for v in sourcepoints),'Shipyard foundation corner differs')
 append([[(x-855)/span,(z-891)/span]for x,z in outline])
 for profile in ground_profiles:append(profile)
 body=next(p for p in parts if p['name']=='tent_shipyard_body');uv=[32.5/256,201.5/256];cap=dict(body,name='authored_closed_underside',vertices=[[v[0],0.,v[1]]+uv+[1.]for tri in caps for v in tri],indices=list(range(1,len(caps)*3+1)));cap.pop('colors',None);parts.append(cap)
 rear,rearproof=close_rear(parts,'tent_shipyard_body',uv,span);parts.append(rear)
 # Roof fixtures are inspected separately; never profile the crane across the
 # main building or fill space between its four original supports.
 waku=next(p for p in parts if p['name']=='museum_waku');metal=banks[11][next(a.base_color_texture for a in m.materials if a.name=='museum_waku')]
 def paint(tri):
  u=sum(v[3]for v in tri)/3%1;v=sum(v[4]for v in tri)/3%1;x=int(u*metal.width);y=int(v*metal.height);need(metal.rgba[(y*metal.width+x)*4+3]==255,'roof hardware backing paint alpha');return[(x+.5)/metal.width,(y+.5)/metal.height]
 shell,shellproof=close_fixture_shells(waku,parts,(110-18.5)/span,span,paint);shelloverlaps=coplanar_overlaps([shell],distance=1e-7,area=1e-14);shellproof['coplanarCleanup']=subtract_reviewed_overlaps(shell,[(max(a['first'][1],a['second'][1]),min(a['first'][1],a['second'][1]))for a in shelloverlaps]);parts.append(shell)
 rawdoor=(root/'mapprops-nitrogen/3/0039/000.bch').read_bytes();dm=load(rawdoor)[0];di=open_bch(rawdoor).models[0];need(dm.name=='c102_bm_door03','unexpected Shipyard original hinge');worlds=[];errors={}
 for bone in di.skeleton:
  need(all(abs(v)<1e-8 for v in bone.rotation),'Shipyard bind rotation needs review');mat=[[bone.scale[r]if r==c else bone.translation[r]if c==3 else 0 for c in range(4)]for r in range(3)]+[[0,0,0,1]]
  if bone.parent>=0:mat=mul(worlds[bone.parent],mat)
  worlds.append(mat);check=mul(mat,[bone.inverse_bind[k:k+4]for k in range(0,16,4)]);errors[bone.name]=max(abs(check[r][c]-(r==c))for r in range(4)for c in range(4))
 need(max(errors[di.skeleton[i].name]for i in[0,1])<1e-5,'Shipyard moving inverse bind differs')
 from ctr.formats.bch.header import read_header,relocate
 from ctr.binstream import BinStream
 from ctr.formats.bch.contents import read_contents
 from ctr.formats.bch.animation import read_animations
 anim=(root/'mapprops-nitrogen/3/0039/001.bch').read_bytes();h=read_header(BinStream(anim));rel=relocate(anim,h);a=read_animations(rel,read_contents(rel,h),h.backward);need(len(a)==1 and a[0].frame_count==6 and not a[0].looping,'Shipyard animation differs');tracks={b.name:b.rotation[1].keys for b in a[0].bones if b.name=='anim_door'};need(len(tracks)==1,'original Shipyard hinge absent');poses=[[],[],[]];dparts=[]
 for i,s in enumerate(dm.submeshes):
  if s.material=='Comb7':continue
  ni=di.meshes[i];draw=ni.submeshes[0];need(ni.positions==s.positions and ni.texcoords==s.uv0 and draw.indices==[k for t in s.triangles for k in t],'independent Shipyard door geometry differs');need(draw.skinning==2 and draw.bone_indices==[1]and all(b==[1]for b in s.bones)and all(w==[1.]for w in s.weights),'Shipyard rigid hinge owner differs');need(all(c[3]==1 for c in s.colors),'Shipyard door opacity differs')
  for state,frame in enumerate([0,2.5,5]):
   angle=sample(tracks['anim_door'],frame);c,t=math.cos(angle),math.sin(angle);mat=mul(worlds[1],[[c,0,t,0],[0,1,0,0],[-t,0,c,0],[0,0,0,1]]);rows=[]
   for p,uv0 in zip(s.positions,s.uv0):
    v=[sum(mat[r][k]*(p[k]if k<3 else 1)for k in range(4))for r in range(3)];rows.append([v[0]/span,(v[1]-.5)/span,v[2]/span,uv0[0],1-uv0[1],1.])
   poses[state].append(rows)
  dparts.append(dict(name=s.material+'_'+str(i),texture=texture(next(a.base_color_texture for a in dm.materials if a.name==s.material),1),vertices=poses[0][-1],indices=[k+1 for t in s.triangles for k in t],role='source_shipyard_door',alphaMode='cutout',opacity=1.,wrapS='repeat',wrapT='repeat'))
 data={'oras_slateport_shipyard':dict(parts=parts,anchors={'door':[0.,0.,0.]}),'door':dict(id='oras_slateport_shipyard_door',parts=dparts,poses=poses)};(output/'lib/ImportedSlateportShipyardData.lua').write_text('-- Original ORAS Stern Shipyard and BM0039 hinge; tools/import_oras_slateport_shipyard.py.\nreturn '+lua(data)+'\n')
 report=dict(source='Supplied Alpha Sapphire RomFS; original Slateport GR152/ZO14→267/AD20/BM39',sourceStaticOrigin=offset,sourceOrigin=origin,normalizationSpan=span,sourceTrianglesByMaterial=counts,sourcePhysicalAlpha=physical_alpha,reviewedCoplanarCleanup=cleanup,belowGroundTrianglesClipped=clipped,undersideTriangles=len(caps),rearClosure=rearproof,roofFixtureShells=shellproof,sourceDoorPlacement=[855,18,891],doorPhysicalTriangles=sum(len(p['indices'])//3 for p in dparts),doorAngles=[sample(tracks['anim_door'],f)for f in[0,2.5,5]],movingInverseBindError=max(errors[di.skeleton[i].name]for i in[0,1]),textures=textures,sha256=dict(body=hashlib.sha256(raw).hexdigest(),door=hashlib.sha256(rawdoor).hexdigest(),animation=hashlib.sha256(anim).hexdigest()),processing='Original visible source coordinates/UVs independently checked. Only below-ground source triangles clipped at original18.5 ground; original BM placement retained. Source RGB exposure and24 light triangles omitted; physical alpha preserved. Native fit/acceptance separate.')
 (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 for name in['root','decoder','nitrogen','output']:p.add_argument('--'+name,type=Path,required=True)
 a=p.parse_args();print(json.dumps(convert(a.root,a.decoder,a.nitrogen,a.output),indent=2))
