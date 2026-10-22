#!/usr/bin/env python3
"""Prepare the original ORAS Pretty Petal exterior, excluding living plants."""
import argparse,copy,hashlib,io,json,math,zipfile
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image
from import_oras_grass import NS,sources,inputs,lua
from import_scenery_models import dae_static,normalize
from import_route104_tree import bounds,components,URL

MODEL='oras_route104_pretty_petal_shop'
SOURCE='world04_02_06.dae'
MATERIALS={'_0_0-mesh':'r104_dif02.png','_1_0-mesh':'r104_dif01.png','_2_0-mesh':'r104_dif03.png','_3_0-mesh':'r104_dif04.png','_4_0-mesh':'chip_mado_a_1.png'}

def extract(raw,include_cards=False):
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
 assert [len(p['vertices'])//3 for p in parts]==[450,579,228,424,36]
 foliage=parts[2];groups=components(foliage['vertices'])
 assert len(groups)==20 and len(groups[0])==60
 # Only this material's first component is architectural: the striped
 # awning. All nineteen remaining connected leaf/flower cards are omitted.
 foliage['vertices']=groups[0];foliage['name']='source_striped_awning'
 assert bounds(foliage['vertices'])[1]>49
 return (parts,groups[1:])if include_cards else parts

def complete(parts):
 additions=[]
 def part(source,name,vs):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name=name,vertices=vs,authored=True);additions.append(p)
 def quad(out,points,uv):
  vs=[list(p)+list(t)+[1.,.8,.8,.8,1.]for p,t in zip(points,uv)]
  for i in(0,1,2,0,2,3):out.append(vs[i])
 wall=[]
 # Rotate the same original vertical texture strips in the same direction
 # as the front/side wall UVs. V repeats safely inside the chosen strip.
 def elevation(l,r,b,h,z,strip):
  u0,u1=strip;quad(wall,[[l,h,z],[r,h,z],[r,b,z],[l,b,z]],[[u1,0],[u1,(r-l)/40],[u0,(r-l)/40],[u0,0]])
 elevation(61.2,178.2,.5,16.7,95.38,(.015,.23))
 elevation(64.8,174.6,16.7,60.14,95.38,(.255,.555))
 profile=[(64.8,64.7),(69.75,66.95),(84.6,71.45),(100.8,73.25),(117,74.15),(133.2,74.15),(153,71.45),(169.2,66.95),(174.6,64.25)]
 for (l,h),(r,k)in zip(profile,profile[1:]):
  # Seat this new wall inside the existing rear roof thickness, removing
  # subpixel slits without touching any original roof surfaces.
  h+=2.29997;k+=2.29997
  quad(wall,[[l,h,95.38],[r,k,95.38],[r,60.14,95.38],[l,60.14,95.38]],[[.255+(h-60.14)/43.44*.3,l/40],[.255+(k-60.14)/43.44*.3,r/40],[.255,r/40],[.255,l/40]])
 # Source walls stop at the foundation. The main floor and ceiling complete
 # that original shell; neither extends into native grass or the warp path.
 floor_uv=[[.015,0],[.23,0],[.23,2],[.015,2]]
 quad(wall,[[61.2,.501,91.80002],[178.2,.501,91.80002],[178.2,.501,163.8],[61.2,.501,163.8]],floor_uv)
 quad(wall,[[64.8,60.13,95.4],[174.6,60.13,95.4],[174.6,60.13,160.2],[64.8,60.13,160.2]],floor_uv)
 part(parts[1],'authored_rear_wall_floor_ceiling',wall)
 # The architectural planter stays; its live plant cards are deliberately
 # excluded. Close its existing open top with a dark source soil/brown texel.
 planter=[];uv=[[.55,.4]]*4
 quad(planter,[[133.21,16.69,163.81],[176.84,16.69,163.81],[176.84,16.69,175.79],[133.21,16.69,175.79]],uv)
 quad(planter,[[133.21,.501,163.81],[176.84,.501,163.81],[176.84,.501,175.79],[133.21,.501,175.79]],uv)
 part(parts[0],'authored_planter_caps',planter)
 return additions,{'sourceTriangles':1509,'hd2dSourceTriangles':208,'authoredTriangles':sum(len(p['vertices'])//3 for p in additions),
  'notes':'Original architectural triangles/UVs/RGB retained, including rigid flower-shaped sign. All19 living leaf/flower components stay separate as flat HD2D cards; native field flowers remain engine-owned. Rear wall, main floor/ceiling and planter caps close the incomplete source shell inside its existing footprint.'}

def convert(archive_path,output_root):
 archive=Path(archive_path).read_bytes()
 with zipfile.ZipFile(io.BytesIO(archive))as z:
  raw=z.read(SOURCE);parts,cards=extract(raw,True);source_bounds=bounds([v for p in parts for v in p['vertices']]);added,completion=complete(parts);parts.extend(added)
  meta=normalize(parts);origin=meta['sourceOrigin'];span=meta['sourceUnitSpan']
  anchors={name:[(v[i]-origin[i])/span for i in range(3)]for name,v in {'door':[117,.6,163.8],'doorTop':[117,47,163.8]}.items()}
  folder=output_root/'assets/scenery/oras-route104-shop';folder.mkdir(parents=True,exist_ok=True);textures={}
  for p in parts:
   name=p['texture'];png=z.read(name);(folder/name).write_bytes(png);im=Image.open(io.BytesIO(png)).convert('RGBA');textures[name]={'sha256':hashlib.sha256(png).hexdigest(),'size':list(im.size),'alphaRange':list(im.getextrema()[3])}
   p['texture']='assets/scenery/oras-route104-shop/'+name;p['colors']=[v[6:]for v in p['vertices']];p['vertices']=[v[:6]for v in p['vertices']];p['alphaMode']='cutout'
  hd2d=[]
  for i,card in enumerate(cards):
   b=bounds(card);a=[(b[k]+b[k+3])/2 for k in range(3)];vs=[];colors=[];indices=[];seen={}
   # Preserve the original front35degree projection on a flat upright card.
   # Source UV/RGB and triangle silhouettes survive; no solid petal geometry
   # is introduced. Runtime yaw billboarding uses the existing native shader.
   for v in card:
    p=[v[0],v[1]-(v[2]-a[2])*math.tan(math.radians(35)),a[2]]
    row=[(p[k]-origin[k])/span for k in range(3)]+v[3:]
    key=tuple(row)
    if key not in seen:seen[key]=len(vs)+1;vs.append(row[:6]);colors.append(row[6:])
    indices.append(seen[key])
   hd2d.append({'name':'source_hd2d_flower_card_'+str(i+1),'vertices':vs,'colors':colors,'indices':indices,'anchor':[(a[k]-origin[k])/span for k in range(3)],'sourceBounds':b})
  data={MODEL:{'parts':parts,'bounds':meta['bounds'],'anchors':anchors,'hd2dCards':hd2d,'nativeDepthBay':{'start':(120.4-origin[2])/span,'finish':(136.7-origin[2])/span,'shorten':8/span}}}
  (output_root/'lib/ImportedHoennShopData.lua').write_text('-- Generated by tools/import_route104_shop.py; source credits in assets/scenery/oras-route104-shop/provenance.json.\nreturn '+lua(data)+'\n')
  report={'asset':364272,'sourcePage':URL,'game':'Pokémon Omega Ruby / Alpha Sapphire','uploadedBy':'MasterPengo','submitted':'2025-06-29','originalGameArt':'Nintendo / Creatures / GAME FREAK',
   'archiveSha256':hashlib.sha256(archive).hexdigest(),'sourceModel':SOURCE,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometrySelection':MATERIALS,'selectedSourceBounds':source_bounds,**meta,'authoredCompletion':completion,'textures':textures,
   'hd2dFlowers':{'cards':19,'sourceTriangles':208,'projectionPitchDegrees':35,'sourceUvRgbRetained':True,'sourceTexture':'r104_dif03.png','placement':'Flat source cards rotate by the existing native cylindrical billboard shader; card anchors clamp by their full yaw radius inside the same96x48blocked rectangle. Architecture and door fit remain unchanged.'},
   'nativeAdaptation':{'unadaptedBounds':meta['bounds'],'plainSideWallBaySourceZ':[120.4,136.7],'shortenedBySourceUnits':8,'rigidSourceSpans':['rear z<=120.4 translates+8','front z>=136.7 unchanged'],'uvsUnchanged':True,'note':'Only the plain central side-wall/roof span changes depth; side window assemblies and front entrance/sign/awning/planter/pot/stool remain rigid.'},
   'processing':['Evaluated original static hierarchy, Z_UP conversion and asset unit using shared DAE converter.','Selected original shop walls, curved roof, awning, architectural flower-emblem sign, windows, empty pot/stool and masonry planter. Separated all19 live leaf/flower components into flat HD2D cards; excluded terrain, water, trees and unrelated route props.','Preserved1509 selected source triangles, original UVs, RGB and PNG bytes; uniform XYZ normalization only.'],
   'nativePlacement':'R/S/E Route104 Pretty Petal Flower Shop only. Native6x4 drawing at3,15; body16..18. Door remains5,18. Entire original building fits inside96x48blocked rectangle, omitting rear-left walkable drawing cell. Native collisions/warps/HD2D flowers never change.'}
  (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
  return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('archive',type=Path);p.add_argument('--output-root',required=True,type=Path);a=p.parse_args();data,report=convert(a.archive,a.output_root);print(json.dumps(report['authoredCompletion']))
