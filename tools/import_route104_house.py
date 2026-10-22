#!/usr/bin/env python3
"""Prepare Briney's original ORAS Route104 house; the raw route stays external."""
import argparse,collections,copy,hashlib,io,json,zipfile
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image
from import_oras_grass import NS,sources,inputs,lua
from import_scenery_models import dae_static,normalize
from import_route104_tree import bounds,components,URL

MODEL='oras_route104_briney_house'
SOURCE='world03_03_02.dae'
MATERIALS={'_10_0-mesh':'hagi_house01.png','_11_0-mesh':'hagi_komono01.png'}

def extract(raw):
 root=ET.fromstring(raw)
 for g in root.findall('c:library_geometries/c:geometry',NS):
  if g.get('id')not in MATERIALS:
   mesh=g.find('c:mesh',NS)
   for p in list(mesh):
    if p.tag.rsplit('}',1)[-1]in('triangles','polylist'):mesh.remove(p)
 parts=dae_static(ET.tostring(root))
 for p in parts:
  mesh=next(g.find('c:mesh',NS)for g in root.findall('c:library_geometries/c:geometry',NS)if g.get('id')==p['geometry'])
  prim=mesh.find('c:triangles',NS);pin=inputs(prim);src=sources(mesh)
  stride=1+max(n[1]for n in pin.values());stream=list(map(int,prim.findtext('c:p',namespaces=NS).split()));colors=src[pin['COLOR'][0]]
  for i,v in enumerate(p['vertices']):v.extend(colors[stream[i*stride+pin['COLOR'][1]]][:3]+[1.])
  assert p['texture']==MATERIALS[p['geometry']]
  p.update(name=p.pop('geometry'),material=p['texture'],opacity=1.,diffuse=[1.,1.,1.],role='structure',authored=False)
  p.pop('triangle_count',None);p.pop('skinned_bind_pose',None)
 assert [len(p['vertices'])//3 for p in parts]==[874,454]
 return parts

def complete(parts):
 additions=[]
 def make(source,name,vs):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name=name,vertices=vs,authored=True);additions.append(p)
 def quad(out,points,uv=(.5390625,.734375,.6796875,.984375)):
  l,t,r,b=uv;ts=[(l,t),(r,t),(r,b),(l,b)];vs=[list(p)+list(tc)+[1.,.7,.7,.7,1.]for p,tc in zip(points,ts)]
  for i in (0,1,2,0,2,3):out.append(vs[i])
 shell=[]
 # The ripped model omits the rear wall and the main floor. Flat plank
 # elevations follow the existing body endpoints, with no projected art.
 def boards(l,r,b,h,z):
  # Repeat the actual native-source plank crop at its original proportions.
  # Atlas UVs cannot use sampler-repeat without spilling onto other fixtures.
  yy=b
  while yy<h-.0001:
   top=min(h,yy+13.65);xx=l
   while xx<r-.0001:
    right=min(r,xx+26.742)
    uv=(.6875,.984375-(top-yy)/13.65*.25,.6875+(right-xx)/26.742*.1484375,.984375)
    quad(shell,[[xx,top,z],[right,top,z],[right,yy,z],[xx,yy,z]],uv);xx=right
   yy=top
 boards(-226.5,-115.5,9,66,219)
 quad(shell,[[-226.5,9,219],[-115.5,9,219],[-115.5,9,266],[-226.5,9,266]])
 # Interior ceiling closes the roof underside while keeping the original
 # corrugated surfaces, side gables and ridge completely unchanged.
 quad(shell,[[-226.5,65.98,219],[-115.5,65.98,219],[-115.5,65.98,266],[-226.5,65.98,266]])
 # Source deck surfaces have open undersides. These bounded rectangular
 # boards occupy the existing deck thickness; the threshold stays clear.
 for l,r in [(-244.5,-205),(-173,-115.5)]:
  quad(shell,[[l,9.064,202],[r,9.064,202],[r,9.064,284],[l,9.064,284]])
 quad(shell,[[-204,2.001,271],[-174,2.001,271],[-174,2.001,282],[-204,2.001,282]])
 make(parts[0],'authored_rear_floor_and_deck_closure',shell)
 # Every source six-triangle support is an open three-face box. Close its
 # absent back, top and bottom at exactly its existing endpoints. Reuse
 # that support's own UVs; unrelated scenery is never added.
 support_count=0
 for source in parts:
  vs=[]
  for component in components(source['vertices']):
   if len(component)!=18:continue
   b=bounds(component);l,y,n,r,h,f=b;support_count+=1
   uv=(min(v[3]for v in component),min(v[4]for v in component),max(v[3]for v in component),max(v[4]for v in component))
   quad(vs,[[l,h,n],[r,h,n],[r,y,n],[l,y,n]],uv)
   quad(vs,[[l,h,n],[r,h,n],[r,h,f],[l,h,f]],uv)
   quad(vs,[[l,y,f],[r,y,f],[r,y,n],[l,y,n]],uv)
  make(source,'authored_support_caps_'+source['name'],vs)
 assert support_count==29
 return additions,{'sourceTriangles':1328,'supportBoxesCompleted':support_count,'authoredTriangles':sum(len(p['vertices'])//3 for p in additions),
  'notes':'Original source surfaces, UVs and vertex colors retained. Rear wall, main floor, ceiling, deck undersides and missing support-box faces authored inside source bounds. Original fabric, oars and lifebuoy remain source geometry.'}

def convert(archive_path,output_root):
 archive=Path(archive_path).read_bytes()
 with zipfile.ZipFile(io.BytesIO(archive))as z:
  raw=z.read(SOURCE);parts=extract(raw);source_bounds=bounds([v for p in parts for v in p['vertices']]);added,completion=complete(parts);parts.extend(added)
  meta=normalize(parts);origin=meta['sourceOrigin'];span=meta['sourceUnitSpan']
  # Source front opening is x=-201..-177, y=9..54 at z=266. The native
  # doorway target is in the center cell; all source geometry stays rigid.
  anchors={name:[(v[i]-origin[i])/span for i in range(3)]for name,v in {'door':[-189,9,266],'doorTop':[-189,54,266]}.items()}
  folder=output_root/'assets/scenery/oras-route104-house';folder.mkdir(parents=True,exist_ok=True);textures={}
  for p in parts:
   name=p['texture'];png=z.read(name);(folder/name).write_bytes(png);im=Image.open(io.BytesIO(png)).convert('RGBA');textures[name]={'sha256':hashlib.sha256(png).hexdigest(),'size':list(im.size),'alphaRange':list(im.getextrema()[3])}
   p['texture']='assets/scenery/oras-route104-house/'+name;p['colors']=[v[6:]for v in p['vertices']];p['vertices']=[v[:6]for v in p['vertices']];p['alphaMode']='cutout'
  data={MODEL:{'parts':parts,'bounds':meta['bounds'],'anchors':anchors}}
  (output_root/'lib/ImportedHoennData.lua').write_text('-- Generated by tools/import_route104_house.py; source credits in assets/scenery/oras-route104-house/provenance.json.\nreturn '+lua(data)+'\n')
  report={'asset':364272,'sourcePage':URL,'game':'Pokémon Omega Ruby / Alpha Sapphire','uploadedBy':'MasterPengo','submitted':'2025-06-29','originalGameArt':'Nintendo / Creatures / GAME FREAK',
   'archiveSha256':hashlib.sha256(archive).hexdigest(),'sourceModel':SOURCE,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometrySelection':MATERIALS,'selectedSourceBounds':source_bounds,**meta,'authoredCompletion':completion,'textures':textures,
   'processing':['Evaluated original static scene hierarchy, Z_UP conversion and asset unit using shared DAE converter.','Selected only the original house and its attached deck, railings, steps, blinds, oars and lifebuoy. Excluded terrain, water, trees, shadows, flowers and unrelated route props.','Preserved all1328 original triangles, UVs, source RGB colors and PNG bytes; uniform XYZ normalization only.'],
   'nativePlacement':'R/S/E Route104 Mr. Briney exterior only. Native5x4 drawing at15,47; three blocked body rows48..50. Door stays17,50. Adapter rejects unknown/mixed permissions, heights, hidden and boundary cells.'}
  (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
  return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('archive',type=Path);p.add_argument('--output-root',required=True,type=Path);a=p.parse_args();data,report=convert(a.archive,a.output_root);print(json.dumps(report['authoredCompletion']))
