#!/usr/bin/env python3
"""Prepare Dewford's original narrow-house family, excluding all route scenery."""
import argparse,collections,copy,hashlib,io,json,math,zipfile
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image
from import_oras_grass import NS,sources,inputs,lua
from import_scenery_models import dae_static,normalize
from import_route104_tree import bounds,components
MODEL='oras_dewford_narrow_house'
SOURCE='world03_04_07.dae'
URL='https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/364274/'
MATERIALS={'_1_0-mesh':'muro_house.png','_3_0-mesh':'muro_waku.png','_23_0-mesh':'chip_mado.png'}

def extract(raw):
 root=ET.fromstring(raw)
 for g in root.findall('c:library_geometries/c:geometry',NS):
  if g.get('id')not in MATERIALS:
   mesh=g.find('c:mesh',NS)
   for p in list(mesh):
    if p.tag.rsplit('}',1)[-1]in('triangles','polylist'):mesh.remove(p)
 parts=dae_static(ET.tostring(root));selection=[]
 for p in parts:
  mesh=next(g.find('c:mesh',NS)for g in root.findall('c:library_geometries/c:geometry',NS)if g.get('id')==p['geometry'])
  pr=mesh.find('c:triangles',NS);pin=inputs(pr);src=sources(mesh);stride=1+max(n[1]for n in pin.values());stream=list(map(int,pr.findtext('c:p',namespaces=NS).split()));colors=src[pin['COLOR'][0]]
  for i,v in enumerate(p['vertices']):v.extend(colors[stream[i*stride+pin['COLOR'][1]]][:3]+[1.])
  assert p['texture']==MATERIALS[p['geometry']]
  groups=components(p['vertices']);selected=[];second=[]
  for c in groups:
   b=bounds(c)
   if b[0]>=-41 and b[3]<=59 and b[2]>=-312 and b[5]<=-229:selected.extend(c)
   if b[0]>=229 and b[3]<=329 and b[2]>=48 and b[5]<=131:second.extend(c)
  # The other original narrow home is the same family translated(270,0,360).
  # Quantized source position/UV/RGB comparison guards against selecting the
  # wide hall, boat dock or an unrelated object sharing the source atlas.
  signature=lambda v:tuple(round(n,5)for n in v[3:])
  shifted=copy.deepcopy(second)
  for v in shifted:v[0]-=270;v[2]-=360
  assert collections.Counter(map(signature,selected))==collections.Counter(map(signature,shifted)),'source narrow UV/RGB copies differ'
  buckets=collections.defaultdict(list)
  for v in shifted:buckets[signature(v)].append(v)
  delta=max(min(math.dist(v[:3],q[:3])for q in buckets[signature(v)])for v in selected)
  assert delta<1,'source narrow geometry differs beyond tiny original offsets'
  selection.append({'geometry':p['geometry'],'selectedTriangles':len(selected)//3,'excludedTriangles':len(p['vertices'])//3-len(selected)//3,'matchingOriginalCopies':2,'matchingCopyMaxPositionDelta':delta})
  p['vertices']=selected;p.update(name=p.pop('geometry'),material=p['texture'],opacity=1.,diffuse=[1.,1.,1.],role='structure',authored=False)
  p.pop('triangle_count',None);p.pop('skinned_bind_pose',None)
 assert [len(p['vertices'])//3 for p in parts]==[938,54,4]
 return parts,selection

def complete(parts):
 vs=[]
 def quad(points,uv):
  q=[list(p)+list(t)+[1.,.8,.8,.8,1.]for p,t in zip(points,uv)]
  for i in(0,1,2,0,2,3):vs.append(q[i])
 # Original back posts and ridge remain. New planes sit slightly inside
 # those source posts and use the source's actual plaster/stone atlas crops.
 l,r,z=-35.7,53.49,-303.15
 for a,b in[(l,-6),( -6,23.75),(23.75,r)]:
  quad([[a,-6,z],[b,-6,z],[b,-17.9999,z],[a,-17.9999,z]],[[.39,.19],[.63,.19],[.63,.46],[.39,.46]])
  quad([[a,37.4,z],[b,37.4,z],[b,-6,z],[a,-6,z]],[[.39,.5],[.63,.5],[.63,.98],[.39,.98]])
 # Horizontal timber joins run behind, never in front of, the flat plaster.
 quad([[l,37.4,z-.01],[r,37.4,z-.01],[r,32.34,z-.01],[l,32.34,z-.01]],[[.89,0],[.97,0],[.97,1],[.89,1]])
 quad([[l,-17.9999,z],[r,-17.9999,z],[r,-17.9999,-236.21],[l,-17.9999,-236.21]],[[.89,0],[.97,0],[.97,2],[.89,2]])
 quad([[l,37.39,z],[r,37.39,z],[r,37.39,-238],[l,37.39,-238]],[[.89,0],[.97,0],[.97,2],[.89,2]])
 p={k:copy.deepcopy(v)for k,v in parts[0].items()if k!='vertices'};p.update(name='authored_rear_wall_floor_ceiling',vertices=vs,authored=True)
 return[p],{'sourceTriangles':996,'authoredTriangles':len(vs)//3,'notes':'Original roof, ridge fixtures, wall elevations, timber posts, cobblestone base, window frames and glass retained. Missing rear wall/floor/ceiling closed inside source bounds with original plaster, stone and timber crops. No floral, tree, actor, dock or hall geometry selected.'}

def convert(archive_path,output_root):
 archive=Path(archive_path).read_bytes()
 with zipfile.ZipFile(io.BytesIO(archive))as z:
  raw=z.read(SOURCE);parts,selection=extract(raw);source_bounds=bounds([v for p in parts for v in p['vertices']]);added,completion=complete(parts);parts.extend(added)
  meta=normalize(parts);origin=meta['sourceOrigin'];span=meta['sourceUnitSpan']
  anchors={name:[(v[i]-origin[i])/span for i in range(3)]for name,v in {'door':[-9,-17.5,-238],'doorTop':[-9,27,-238],'doorLeft':[-21,-17.5,-238],'doorRight':[3,-17.5,-238]}.items()}
  folder=output_root/'assets/scenery/oras-dewford-house';folder.mkdir(parents=True,exist_ok=True);textures={}
  for p in parts:
   name=p['texture'];png=z.read(name);(folder/name).write_bytes(png);im=Image.open(io.BytesIO(png)).convert('RGBA');textures[name]={'sha256':hashlib.sha256(png).hexdigest(),'size':list(im.size),'alphaRange':list(im.getextrema()[3])}
   p['texture']='assets/scenery/oras-dewford-house/'+name;p['colors']=[v[6:]for v in p['vertices']];p['vertices']=[v[:6]for v in p['vertices']];p['alphaMode']='cutout'
  data={MODEL:{'parts':parts,'bounds':meta['bounds'],'anchors':anchors}}
  (output_root/'lib/ImportedDewfordData.lua').write_text('-- Generated by tools/import_dewford_house.py; source credits in assets/scenery/oras-dewford-house/provenance.json.\nreturn '+lua(data)+'\n')
  report={'asset':364274,'sourcePage':URL,'game':'Pokémon Omega Ruby / Alpha Sapphire','uploadedBy':'MasterPengo','submitted':'2025-06-29','originalGameArt':'Nintendo / Creatures / GAME FREAK',
   'archiveSha256':hashlib.sha256(archive).hexdigest(),'sourceModel':SOURCE,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometrySelection':selection,'selectedSourceBounds':source_bounds,**meta,'authoredCompletion':completion,'textures':textures,
   'processing':['Evaluated original static hierarchy, Z_UP conversion and asset unit using shared DAE converter.','Selected the narrow home by complete source connected-component bounds. Verified the other original narrow home matches UV/RGB and XYZ within1sourceunit after its translation (tiny original foundation/glass/entrance-floor offsets retained in selected copy); excluded the distinct wide hall and all route/dock scenery.','Retained996 original source triangles, source RGB, UVs and PNG bytes. Added rear/floor/ceiling completion; uniform XYZ normalization only.'],
   'nativePlacement':'Existing R/S/E dewford_town_home at7,5 and dewford_town_south_home at16,11; native doors8,8and17,14. Six placements across three editions. Model stays inside64x48body rectangle, below native roof-art row; all source doorway/geometry remain rigid. Widehall remains native pending a separate doorway review.'}
  (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
  return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('archive',type=Path);p.add_argument('--output-root',required=True,type=Path);a=p.parse_args();data,report=convert(a.archive,a.output_root);print(json.dumps(report['authoredCompletion']))
