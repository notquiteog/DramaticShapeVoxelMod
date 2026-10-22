#!/usr/bin/env python3
"""Extract inspected HGSS Pallet building geometry from asset592847 only.

Original archive stays outside source. Canonical local geometry is Y-up;
scene transforms only position the three objects around the unrelated town.
Every source triangle, UV, sampler, vertex color and material alpha is retained.
"""
import argparse,copy,hashlib,io,json,math,zipfile
import xml.etree.ElementTree as ET
from pathlib import Path,PurePosixPath
from PIL import Image
from import_oras_grass import NS,sources,inputs,lua
from import_scenery_models import normalize
from scenery_closures import close_building,hull
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592847/'
SELECT={'hgss_pallet_red':'mst_rdh-mesh','hgss_pallet_rival':'mst_grh-mesh','hgss_pallet_oak':'mst_okl-mesh'}
DOORS={'hgss_pallet_red':('mst_dr1-mesh',[-6,.01953,17.93848]),'hgss_pallet_rival':('mst_dr1_001-mesh',[-6,.01953,17.93848]),'hgss_pallet_oak':('mst_dr2-mesh',[10,-.63867,18.93848])}

def extract(raw,selection=None,door_specs=None):
 selection=SELECT if selection is None else selection;door_specs=DOORS if door_specs is None else door_specs
 r=ET.fromstring(raw);out={};images={i.get('id'):i.findtext('c:init_from',namespaces=NS) for i in r.findall('c:library_images/c:image',NS)};effects={e.get('id'):e for e in r.findall('c:library_effects/c:effect',NS)}
 materials={m.get('id'):effects[m.find('c:instance_effect',NS).get('url')[1:]] for m in r.findall('c:library_materials/c:material',NS)}
 for model,gid in {**selection,**{k+'_door':v[0] for k,v in door_specs.items()}}.items():
  mesh=r.find('.//c:geometry[@id="'+gid+'"]/c:mesh',NS);src=sources(mesh);vs={v.get('id'):inputs(v) for v in mesh.findall('c:vertices',NS)};parts=[]
  for p in mesh.findall('c:triangles',NS):
   name=p.get('material');e=materials[name];common=e.find('c:profile_COMMON',NS);params={n.get('sid'):n for n in common.findall('c:newparam',NS)};diff=common.find('.//c:diffuse',NS);tex=diff.find('c:texture',NS);texture=None;kd=[1,1,1]
   if tex is not None:
    sampler=params[tex.get('texture')].find('c:sampler2D',NS);surface=sampler.findtext('c:source',namespaces=NS);texture=PurePosixPath(images[params[surface].findtext('c:surface/c:init_from',namespaces=NS)]).name
   else:kd=list(map(float,diff.findtext('c:color',namespaces=NS).split()))[:3]
   transparent=common.find('.//c:transparent',NS);opacity=1.
   if transparent is not None:
    assert transparent.get('opaque')=='A_ONE';opacity=float(transparent.findtext('c:color',namespaces=NS).split()[3])
   pin=inputs(p);stride=1+max(q[1] for q in pin.values());stream=list(map(int,p.findtext('c:p',namespaces=NS).split()));verts=[];colors=[]
   for start in range(0,len(stream),stride):
    vi=stream[start+pin['VERTEX'][1]];bundled=vs[pin['VERTEX'][0]];position=src[bundled['POSITION'][0]][vi][:3];uv=src[pin['TEXCOORD'][0]][stream[start+pin['TEXCOORD'][1]]][:2]
    verts.append(position+[uv[0],1-uv[1],1.])
    ci=pin.get('COLOR');color=src[ci[0]][stream[start+ci[1]]] if ci else src[bundled['COLOR'][0]][vi] if 'COLOR' in bundled else [1,1,1,1]
    colors.append(color+[1]*(4-len(color)))
   assert len(verts)==int(p.get('count'))*3
   part={'name':gid+':'+name,'material':name,'texture':texture,'diffuse':kd,'opacity':opacity,'vertices':verts,'wrapS':'repeat','wrapT':'repeat','role':'source_shading' if 'kage' in name else 'structure','alphaMode':'blend' if opacity<1 else 'cutout'}
   # Source color stream in this export is white; fail rather than drop changes.
   assert all(all(abs(v-1)<1e-8 for v in color) for color in colors),'nonwhite color needs dedup color stream'
   parts.append(part)
  out[model]=parts
 for model,(_,offset) in door_specs.items():
  for p in out.pop(model+'_door'):
   for v in p['vertices']:
    for i in range(3):v[i]+=offset[i]
   p['role']='source_door';out[model].append(p)
 return out

def close_house(parts):
 """Continue measured rear wall/gable and cap source foundation, no new fixtures."""
 base=next(p for p in parts if p['texture']=='mt_rdh01.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v) for k,v in base.items() if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True);out.append(p);return p
 def poly(p,points,uv):
  for i in range(1,len(points)-1):p['vertices'].extend([list(points[j])+list(uv[j])+[1] for j in (0,i,i+1)])
 def quad(p,points,uv):poly(p,points,uv)
 # UV islands measured from the source side wall; repeat siding, never windows.
 rear=part('rear_siding')
 quad(rear,[(-38,2,-26),(38,2,-26),(38,36,-26),(-38,36,-26)],[(.9931641,.2890625),(.9931641,.2890625),(.4619141,.2890625),(.4619141,.2890625)])
 # Original rear wall profile rises to the second-storey roof deck. Existing
 # stepped eaves meet it at y36/42/60/61.58203; planar siding closes that cut.
 quad(rear,[(-38,36,-26),(38,36,-26),(38,61.58203,-26),(-38,61.58203,-26)],[(.7958984,.2890625),(.7958984,.2890625),(.5146484,.2890625),(.5146484,.2890625)])
 # Close the small inner eave cut exactly at its measured asymmetric corners.
 inner=part('rear_inner_eave')
 quad(inner,[(-44,57.55078,-26),(42,57.55078,-26),(44,61.58203,-26),(-44,61.58203,-26)],[(.02539062,.32)]*4)
 for side,outer in [(-1,44),(1,42)]:
  quad(inner,[(side*38,57.55078,-26),(side*outer,57.55078,-26),(side*outer,57.55078,-22.85157),(side*38,57.55078,-22.85157)],[(.02539062,.32)]*4)
 gable=part('rear_gable')
 poly(gable,[(-46,32.71875,-38),(46,32.71875,-38),(0,90.01953,-38)],[(.02539062,.32)]*3)
 # Main roof underside (pitch silhouette remains original); cap source cut
 # between rear gable and inner wall, using the source dark eave sample.
 trim=part('rear_eave_returns')
 quad(trim,[(-46,32.71875,-38),(46,32.71875,-38),(46,32.71875,-26),(-46,32.71875,-26)],[(.02539062,.32)]*4)
 bottom=part('closed_underside');pts=hull([v for p in parts if p['role']=='structure' for v in p['vertices'] if abs(v[1]-2)<.001]);poly(bottom,[(x,1,z) for x,z in reversed(pts)],[(.02539062,.32)]*len(pts))
 for i,a in enumerate(pts):
  b=pts[(i+1)%len(pts)];quad(bottom,[(a[0],1,a[1]),(b[0],1,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(.02539062,.32)]*4)
 return out

def convert(archive,root):
 rawzip=archive.read_bytes();z=zipfile.ZipFile(io.BytesIO(rawzip));names={PurePosixPath(n).name:n for n in z.namelist() if not n.endswith('/')};raw=z.read(names['Pallet Town.dae']);models=extract(raw);reports={}
 for model,parts in models.items():
  source=copy.deepcopy(parts)
  if model.endswith('_oak'):
   # Same measured model dimensions/materials as the2015OBJ, but valid DAE UVs
   # and the original0.29 alpha remove the older material repair requirement.
   closureparts=copy.deepcopy(parts)
   for p in closureparts:p['material']=PurePosixPath(p['texture']).stem if p['texture'] else 'lambert1'
   authored,closure=close_building('hgss_oaks_lab',closureparts)
   for p in authored:p.update(role='structure',alphaMode='cutout')
   door=[0,2,23]
  else:authored=close_house(parts);closure={'description':'Measured rear siding, rear roof cut and foundation closure; original front/recess/fixtures unchanged.'};door=[-16,2,22]
  parts.extend(authored);meta=normalize(parts);source_meta=normalize(source);folder=root/'assets/scenery/pallet-buildings'/model;folder.mkdir(parents=True,exist_ok=True);textures={}
  for p in parts:
   if p['texture']:
    name=PurePosixPath(p['texture']).name;content=z.read(names[name])
   else:
    name='source-kd.png';buf=io.BytesIO();Image.new('RGBA',(1,1),tuple(round(v*255) for v in p['diffuse'])+(255,)).save(buf,format='PNG');content=buf.getvalue()
   (folder/name).write_bytes(content);textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)};p['texture']='assets/scenery/pallet-buildings/'+model+'/'+name
  anchors={'door':[(door[i]-meta['sourceOrigin'][i])/meta['sourceUnitSpan'] for i in range(3)]}
  reports[model]={'sourcePage':URL,'asset':592847,'submitted':'2026-09-01','author':'Kuramapika1','game':'Pokémon HeartGold / SoulSilver','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceDaeSha256':hashlib.sha256(raw).hexdigest(),'geometry':SELECT[model],'sourceLocalUp':'Y','sceneTransforms':'Town-only translation/orientation removed; original local geometry retained.','sourceTriangles':sum(len(p['indices'])//3 for p in source),'triangles':sum(len(p['indices'])//3 for p in parts),'sourceBounds':source_meta['sourceBounds'],'normalization':meta,'authoredClosure':closure,'textures':textures,'parts':[{'name':p['name'],'opacity':p['opacity'],'role':p['role'],'authored':p.get('authored',False),'triangles':p['triangles']} for p in parts],'placement':'Guarded native FR/LG Pallet adapter only. No other regional coverage implied.'}
  (folder/'provenance.json').write_text(json.dumps(reports[model],indent=2,ensure_ascii=False)+'\n');models[model]={'parts':parts,'anchors':anchors,'bounds':meta['bounds']}
 (root/'lib/PalletBuildingData.lua').write_text('-- Generated by tools/import_pallet_buildings.py; attribution beside textures.\nreturn '+lua(models)+'\n')
 return models,reports
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args();_,r=convert(a.archive,a.output)
 for k,v in r.items():print(k,v['sourceTriangles'],v['triangles'])
