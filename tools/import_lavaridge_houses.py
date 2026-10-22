#!/usr/bin/env python3
"""Prepare both original ORAS Lavaridge home exteriors as separate variants."""
import argparse,copy,hashlib,io,json,zipfile
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image
from import_oras_grass import NS,sources,inputs,lua
from import_scenery_models import dae_static,normalize
from import_route104_tree import bounds,components
SOURCE='world07_02_03.dae'
URL='https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/353301/'
MATERIALS={'polySurface17_13_0-mesh':'t104_object_a_dif02.png','polySurface17_14_0-mesh':'t104_object_a_dif03.png','polySurface17_15_0-mesh':'t104_object_a_dif01.png','polySurface17_16_0-mesh':'chip_mado_a_1.png'}
RECIPES={'oras_lavaridge_herb_shop':{'xmin':72,'xmax':162,'doorX':99,'localOrigin':[11,12],'sideWindow':'left','triangles':[610,266,385,4]},
 'oras_lavaridge_home':{'xmin':162,'xmax':252,'doorX':189,'localOrigin':[15,12],'sideWindow':'right','triangles':[610,264,385,4]}}

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
  pr=mesh.find('c:triangles',NS);pin=inputs(pr);src=sources(mesh);stride=1+max(n[1]for n in pin.values());stream=list(map(int,pr.findtext('c:p',namespaces=NS).split()));colors=src[pin['COLOR'][0]]
  for i,v in enumerate(p['vertices']):v.extend(colors[stream[i*stride+pin['COLOR'][1]]][:3]+[1.])
  assert p['texture']==MATERIALS[p['geometry']]
  p.update(name=p.pop('geometry'),material=p['texture'],opacity=1.,diffuse=[1.,1.,1.],role='structure',authored=False)
  p.pop('triangle_count',None);p.pop('skinned_bind_pose',None)
 selected={}
 for model,r in RECIPES.items():
  out=[]
  for p in parts:
   q={k:copy.deepcopy(v)for k,v in p.items()if k!='vertices'};q['vertices']=[]
   for component in components(p['vertices']):
    b=bounds(component)
    if b[0]>=r['xmin']and b[3]<r['xmax']:q['vertices'].extend(component)
   out.append(q)
  assert[len(p['vertices'])//3 for p in out]==r['triangles'],'source variant selection changed'
  selected[model]=out
 return selected

def complete(parts,r):
 vs=[];dx=r['doorX']-99
 def quad(points,uv):
  q=[[p[0]+dx,p[1],p[2]]+list(t)+[1.,.8,.8,.8,1.]for p,t in zip(points,uv)]
  for i in(0,1,2,0,2,3):vs.append(q[i])
 wood=[[.125,.25]]*4
 # Original frame/posts surround these new flat rear infill panels. The
 # plaster pattern and timber/lattice trim come from the source's own atlas.
 for l,right in[(77.25,103.82),(103.82,130.38),(130.38,156.95)]:
  quad([[l,132.0,94.94],[right,132.0,94.94],[right,87.03,94.94],[l,87.03,94.94]],[[.28,.015],[.70,.015],[.70,.30],[.28,.30]])
 quad([[77.25,132.0,94.93],[156.95,132.0,94.93],[156.95,123,94.93],[77.25,123,94.93]],wood)
 quad([[75.52,87.02,93.62],[158.38,87.02,93.62],[158.38,72.5001,93.62],[75.52,72.5001,93.62]],[[.03,.25]]*4)
 # Continue the actual skirt's timber grid as shallow, flat strips, with
 # a closed backing. This never widens or projects the original footprint.
 for low,high in[(72.5001,74.33),(79.92,80.35),(85.16,87.02)]:
  quad([[75.52,high,93.61],[158.38,high,93.61],[158.38,low,93.61],[75.52,low,93.61]],wood)
 for center in[81.69,93.53,105.37,117.21,129.05,140.89,152.73]:
  quad([[center-.63,85.16,93.61],[center+.63,85.16,93.61],[center+.63,74.33,93.61],[center-.63,74.33,93.61]],wood)
 quad([[75.52,87.02,93.62],[158.38,87.02,93.62],[158.38,87.02,94.94],[75.52,87.02,94.94]],wood)
 quad([[75.52,72.5001,93.62],[158.38,72.5001,93.62],[158.38,72.5001,159.79],[75.52,72.5001,159.79]],wood)
 quad([[77.25,129.54,94.94],[156.95,129.54,94.94],[156.95,129.54,158],[77.25,129.54,158]],wood)
 p={k:copy.deepcopy(v)for k,v in parts[2].items()if k!='vertices'};p.update(name='authored_rear_infill_skirt_floor_ceiling',vertices=vs,authored=True)
 return[p],{'authoredTriangles':len(vs)//3,'notes':'Original roof, ridge ornaments, projecting vent pipe, plaster/timber walls, lattice base, window bars and glass retained. Rear wall infill, backed timber skirt, foundation join, floor and ceiling authored inside source bounds using original atlas crops.'}

def convert(archive_path,output_root):
 archive=Path(archive_path).read_bytes();catalog={};reports={}
 with zipfile.ZipFile(io.BytesIO(archive))as z:
  raw=z.read(SOURCE);selected=extract(raw);folder=output_root/'assets/scenery/oras-lavaridge-houses';folder.mkdir(parents=True,exist_ok=True);textures={}
  for model,parts in selected.items():
   r=RECIPES[model];source_bounds=bounds([v for p in parts for v in p['vertices']]);added,completion=complete(parts,r);parts.extend(added);meta=normalize(parts);origin=meta['sourceOrigin'];span=meta['sourceUnitSpan']
   anchors={name:[(v[i]-origin[i])/span for i in range(3)]for name,v in {'door':[r['doorX'],72.5,158],'doorTop':[r['doorX'],117.5,158],'doorLeft':[r['doorX']-11.417,72.5,158],'doorRight':[r['doorX']+11.417,72.5,158]}.items()}
   for p in parts:
    name=p['texture'];png=z.read(name);(folder/name).write_bytes(png);im=Image.open(io.BytesIO(png)).convert('RGBA');textures[name]={'sha256':hashlib.sha256(png).hexdigest(),'size':list(im.size),'alphaRange':list(im.getextrema()[3])}
    p['texture']='assets/scenery/oras-lavaridge-houses/'+name;p['colors']=[v[6:]for v in p['vertices']];p['vertices']=[v[:6]for v in p['vertices']];p['alphaMode']='cutout'
   bays=[{'start':(a-origin[2])/span,'finish':(b-origin[2])/span,'shorten':4/span}for a,b in[(100.6,105.9),(146.4,152.7)]]
   catalog[model]={'parts':parts,'bounds':meta['bounds'],'anchors':anchors,'nativeDepthBays':bays,'sourceUnitSpan':span}
   reports[model]={'selectedSourceBounds':source_bounds,'sourceTriangles':sum(r['triangles']),'selectionBoundsX':[r['xmin'],r['xmax']],'sideWindow':r['sideWindow'],'nativeLocalOrigin':r['localOrigin'],**meta,'authoredCompletion':completion,
    'nativeAdaptation':{'unadaptedBounds':meta['bounds'],'sourceDepthBays':[[100.6,105.9],[146.4,152.7]],'shortenEach':4,'totalShortening':8,'rigidAssemblies':{'frontDoorFacadePipeFrontCornerPosts':'unchanged','completeSideWindowBarsGlass':'translated4depthunits','rearFacadeCornerPosts':'translated8depthunits'},'sourceUvsColorsUnchanged':True}}
  (output_root/'lib/ImportedLavaridgeData.lua').write_text('-- Generated by tools/import_lavaridge_houses.py; source credits in assets/scenery/oras-lavaridge-houses/provenance.json.\nreturn '+lua(catalog)+'\n')
  report={'asset':353301,'sourcePage':URL,'game':'Pokémon Omega Ruby / Alpha Sapphire','uploadedBy':'MasterPengo','submitted':'2024-06-24','originalGameArt':'Nintendo / Creatures / GAME FREAK',
   'archiveSha256':hashlib.sha256(archive).hexdigest(),'sourceModel':SOURCE,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometrySelection':MATERIALS,'models':reports,'textures':textures,
   'processing':['Evaluated original static hierarchy, Z_UP conversion and asset unit using shared DAE converter.','Selected complete original west Herb Shop and east home separately. Their side-window orientations and a tiny original bar fragment differ; neither is substituted for the other. Excluded every other town object.','Preserved2528 original architectural triangles, source UV/RGBA and PNG bytes. Native adapter shortens two plain depth bays while preserving windows, portal, vent pipe and corner-post assemblies.'],
   'nativePlacement':'R/S/E LavaridgeTown only: HerbShop native origin11,12/door12,15 and home15,12/door16,15. Existinglavaridge_town_home recipe remains authoritative. Map/region-local-coordinate, exact mid/permission, height and boundary guards; all geometry stays inside64x48body rows. Other Hoenn cities and custom-map copies retain native fallback.'}
  (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
  return catalog,report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('archive',type=Path);p.add_argument('--output-root',required=True,type=Path);a=p.parse_args();data,report=convert(a.archive,a.output_root);print(json.dumps({k:{'sourceTriangles':v['sourceTriangles'],**v['authoredCompletion']}for k,v in report['models'].items()}))
