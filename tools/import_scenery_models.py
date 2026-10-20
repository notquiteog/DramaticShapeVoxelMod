#!/usr/bin/env python3
"""Convert selected public static scenery archives; originals remain outside repo.

Static DAE scene/material parsing shares import_oras_grass.bake_dae. OBJ retains
object/material splits and negative indices; malformed textured UVs fail closed.
"""
import argparse, copy, hashlib, io, json, math, zipfile
import xml.etree.ElementTree as ET
from pathlib import Path, PurePosixPath
from PIL import Image
from import_oras_grass import bake_dae, lua, NS, sources, inputs
from scenery_closures import close_building

CATALOG = {
 'oras_pokemon_center': {'asset':292908,'sourcePage':'https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/292908/','game':'Pokémon Omega Ruby / Alpha Sapphire','title':'Pokémon Center','author':'Fallenleader (RSRazr)','submitted':'2015-06-21','file':'ORAS_Pokemon_Center/Pokemon_Center.obj','mtl':'ORAS_Pokemon_Center/Pokemon_Center.mtl','bindings':{n:n+'.png' for n in ['pc_mado','pokecen00','pokecen_01']}},
 'hgss_oaks_lab': {'asset':294796,'sourcePage':'https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/294796/','game':'Pokémon HeartGold / SoulSilver','title':"Oak's Lab",'author':'CheesyMac nCheese','submitted':'2015-11-07','file':'Oak Pokemon Research Lab.obj','mtl':'Oak Pokemon Research Lab.mtl','solid_fallbacks':['lambert1']},
 'bw2_sign01': {'asset':582551,'sourcePage':'https://models.spriters-resource.com/ds_dsi/pokemonblack2white2/asset/582551/','game':'Pokémon Black 2 / White 2','title':'Sign 01','author':'pentaenix','submitted':'2026-07-30','file':'sign01.dae'},
}

def safe_path(name):
 p=PurePosixPath(name.replace('\\','/'))
 if p.is_absolute() or '..' in p.parts: raise ValueError('Unsafe asset path')
 return str(p)

def materials(data):
 out={};row=None
 for raw in data.decode('utf-8-sig',errors='strict').splitlines():
  line=raw.strip().split(maxsplit=1)
  if not line or line[0].startswith('#'):continue
  key=line[0];value=line[1] if len(line)>1 else ''
  if key=='newmtl':row={'diffuse':[1.,1.,1.],'opacity':1.};out[value]=row
  elif row is not None:
   if key=='Kd':row['diffuse']=[float(x) for x in value.split()]
   elif key=='d':row['opacity']=float(value)
   elif key=='map_Kd':row['texture']=safe_path(value)
 return out

def obj(data,mtl,available,bindings=None,solid_fallbacks=()):
 positions=[];uvs=[];normals=[];parts=[];groups={};group='object';material=None;fixes=[]
 def index(text,items):
  n=int(text);n=n-1 if n>0 else len(items)+n
  if not 0<=n<len(items):raise ValueError('OBJ index out of range')
  return items[n]
 for raw in data.decode('utf-8-sig').splitlines():
  line=raw.strip().split()
  if not line or line[0].startswith('#'):continue
  key=line[0]
  if key=='v':positions.append([float(x) for x in line[1:4]])
  elif key=='vt':uvs.append([float(x) for x in line[1:3]])
  elif key=='vn':normals.append([float(x) for x in line[1:4]])
  elif key in ('o','g'):group=' '.join(line[1:])
  elif key=='usemtl':material=' '.join(line[1:])
  elif key=='f':
   if len(line)<4:raise ValueError('Degenerate OBJ polygon')
   k=(group,material)
   if k not in groups:
    mat=mtl.get(material)
    if not mat:raise ValueError('Unknown OBJ material '+str(material))
    texture=(bindings or {}).get(material,mat.get('texture'))
    if texture and PurePosixPath(texture).name not in available:
     if material not in solid_fallbacks:raise ValueError('Missing source texture '+texture)
     fixes.append('Missing '+texture+': retained source Kd as solid material; invalid UVs not used.')
     texture=None
    part={'name':group,'material':material,'texture':texture,'diffuse':mat['diffuse'],'opacity':mat['opacity'],'vertices':[],'wrapS':'repeat','wrapT':'repeat'}
    groups[k]=part;parts.append(part)
   part=groups[k];face=[]
   for item in line[1:]:
    fields=item.split('/');p=index(fields[0],positions)
    if not all(math.isfinite(v) for v in p):raise ValueError('Nonfinite OBJ position')
    uv=index(fields[1],uvs) if len(fields)>1 and fields[1] else [0.,0.]
    if not all(math.isfinite(v) for v in uv):
     if part['texture']:raise ValueError('Nonfinite UV on textured OBJ material')
     uv=[0.,0.]
    # The source's texture is albedo. Its diffuse factor remains part metadata
    # for consumers whose material pass supports the original DCC lighting.
    face.append(p+[uv[0],1-uv[1],1.])
   if len(face)>3:
    crosses=[]
    for j in range(len(face)):
     a,b,c=face[j],face[(j+1)%len(face)],face[(j+2)%len(face)];u=[b[k]-a[k] for k in range(3)];v=[c[k]-b[k] for k in range(3)]
     crosses.append([u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]])
    normal=next((n for n in crosses if sum(x*x for x in n)>1e-12),[0,0,0])
    if any(sum(a*b for a,b in zip(normal,n)) < -1e-8 for n in crosses):raise ValueError('Concave OBJ polygon needs source triangulation')
   for i in range(1,len(face)-1):part['vertices'].extend([face[0],face[i],face[i+1]])
 return parts,fixes

def dae_static(data):
 root=ET.fromstring(data)
 if root.findall('.//c:instance_controller',NS) or root.findall('.//c:animation',NS):raise ValueError('Static scenery DAE must be unanimated/unskinned')
 # COLLADA triangles and convex polylist preserve every material/input stream.
 # Expand the selected source quads before the shared transform/sampler bake.
 for mesh in root.findall('.//c:mesh',NS):
  src=sources(mesh);vs={v.get('id'):inputs(v) for v in mesh.findall('c:vertices',NS)}
  for primitive in list(mesh.findall('c:polylist',NS))+list(mesh.findall('c:triangles',NS)):
   pin=inputs(primitive);v=pin.get('VERTEX')
   if v:
    bundled=vs[v[0]]
    if 'TEXCOORD' not in pin and 'TEXCOORD' in bundled:
     ET.SubElement(primitive,'{'+NS['c']+'}input',semantic='TEXCOORD',source='#'+bundled['TEXCOORD'][0],offset=str(v[1]))
    if 'COLOR' in bundled and any(abs(c-1)>1e-8 for row in src[bundled['COLOR'][0]] for c in row):raise ValueError('Static vertex colors require explicit baking')
  for poly in list(mesh.findall('c:polylist',NS)):
   pin=inputs(poly);stride=1+max(i[1] for i in pin.values());counts=[int(n) for n in poly.findtext('c:vcount',namespaces=NS).split()]
   stream=[int(n) for n in poly.findtext('c:p',namespaces=NS).split()]
   if sum(counts)*stride!=len(stream):raise ValueError('Truncated DAE polylist')
   expanded=[];offset=0
   for count in counts:
    if count not in (3,4):raise ValueError('Only triangular/convex quad DAE polylist is supported')
    rows=[stream[offset+i*stride:offset+(i+1)*stride] for i in range(count)];offset+=count*stride
    positions=[src[vs[pin['VERTEX'][0]]['POSITION'][0]][r[pin['VERTEX'][1]]][:3] for r in rows]
    if count==4:
     def cross(a,b,c):
      u=[b[i]-a[i] for i in range(3)];v=[c[i]-b[i] for i in range(3)];return [u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
     normals=[cross(positions[i],positions[(i+1)%4],positions[(i+2)%4]) for i in range(4)]
     if any(sum(a*b for a,b in zip(normals[0],n)) < -1e-10 for n in normals[1:]):raise ValueError('Concave DAE quad needs source triangulation')
    for i in range(1,count-1):expanded.extend(rows[0]+rows[i]+rows[i+1])
   poly.tag='{'+NS['c']+'}triangles';poly.set('count',str(len(expanded)//stride//3));poly.remove(poly.find('c:vcount',NS));poly.find('c:p',NS).text=' '.join(map(str,expanded))
 return bake_dae(ET.tostring(root))

def normalize(parts):
 all_vertices=[v for p in parts for v in p['vertices']]
 mins=[min(v[i] for v in all_vertices) for i in range(3)];maxs=[max(v[i] for v in all_vertices) for i in range(3)]
 span=max(maxs[0]-mins[0],maxs[2]-mins[2])
 if span<=0:raise ValueError('Static model has no horizontal extent')
 center=[(mins[0]+maxs[0])/2,mins[1],(mins[2]+maxs[2])/2]
 for part in parts:
  verts=[];indices=[];seen={}
  for v in part['vertices']:
   row=[(v[i]-center[i])/span for i in range(3)]+v[3:]
   if not all(math.isfinite(x) for x in row):raise ValueError('Nonfinite output')
   key=tuple(row)
   if key not in seen:seen[key]=len(verts)+1;verts.append(row)
   indices.append(seen[key])
  part['vertices'],part['indices']=verts,indices;part['triangles']=len(indices)//3
  part['bounds']=[min(v[i] for v in verts) for i in range(3)]+[max(v[i] for v in verts) for i in range(3)]
 return {'sourceBounds':mins+maxs,'sourceOrigin':center,'sourceUnitSpan':span,'bounds':[(mins[i]-center[i])/span for i in range(3)]+[(maxs[i]-center[i])/span for i in range(3)]}

def convert(archive_root,output_root):
 catalog={};reports={};assets=output_root/'assets/scenery/catalog';assets.mkdir(parents=True,exist_ok=True)
 for model,recipe in CATALOG.items():
  archive_path=archive_root/(str(recipe['asset'])+'.zip');raw_archive=archive_path.read_bytes()
  with zipfile.ZipFile(io.BytesIO(raw_archive)) as archive:
   if len(archive.infolist())>256 or sum(i.file_size for i in archive.infolist())>67108864 or any(i.file_size>8388608 for i in archive.infolist()):raise ValueError('Static source archive budget exceeded')
   names={PurePosixPath(safe_path(n)).name:n for n in archive.namelist() if not n.endswith('/')}
   raw=archive.read(recipe['file'])
   if recipe['file'].endswith('.obj'):
    parts,fixes=obj(raw,materials(archive.read(recipe['mtl'])),names,recipe.get('bindings'),recipe.get('solid_fallbacks',()))
   else:
    if b'instance_controller' in raw or b'<animation' in raw:raise ValueError('Static scenery DAE must be unanimated/unskinned')
    parts=dae_static(raw);fixes=[]
    for p in parts:p['name']=p.pop('geometry');p['material']=p['texture'];p['opacity']=1.;p['diffuse']=[1.,1.,1.];p.pop('triangle_count',None);p.pop('skinned_bind_pose',None)
   original_meta=normalize(copy.deepcopy(parts));authored,closure=close_building(model,parts);parts.extend(authored)
   meta=normalize(parts);folder=assets/model;folder.mkdir(exist_ok=True);textures={};generated={}
   for part in parts:
    source=part.get('texture')
    if source:
     source=PurePosixPath(source).name;content=archive.read(names[source]);image=Image.open(io.BytesIO(content));image.verify()
     (folder/source).write_bytes(content);part['texture']=f'assets/scenery/catalog/{model}/{source}';textures[source]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)}
    else:
     color=tuple(round(255*max(0,min(1,c))) for c in part['diffuse'])+(255,)
     name=part['material']+'-source-kd.png';path=folder/name
     Image.new('RGBA',(1,1),color).save(path)
     generated[name]={'derivedFrom':'source material Kd','diffuse':part['diffuse'],'rgba':list(color),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
     part['texture']=f'assets/scenery/catalog/{model}/{name}'
    part['role']=('ground_shadow' if part['bounds'][4]<.015 else 'source_shading') if 'kage' in part['material'].lower() else 'structure'
    part['alphaMode']='blend' if part['opacity']<1 or 'kage' in part['material'].lower() else 'cutout'
   anchors={}
   if closure:anchors['door']=[(closure['door'][i]-meta['sourceOrigin'][i])/meta['sourceUnitSpan'] for i in range(3)]
   surfaces={}
   if model=='bw2_sign01':surfaces['message']={'part':2,'triangles':[17,18],'uvBounds':[0,.09375,1,.75],'normal':[0,0,1]}
   catalog[model]={'parts':parts,'bounds':meta['bounds'],'source':recipe['asset'],'anchors':anchors,'surfaces':surfaces,'revision':1}
   report={**{k:v for k,v in recipe.items() if k not in ('bindings','solid_fallbacks')},**meta,'originalSourceBounds':original_meta['sourceBounds'],'sourcePage':recipe['sourcePage'],'archiveSha256':hashlib.sha256(raw_archive).hexdigest(),'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'originalGameArt':'Nintendo / Creatures / GAME FREAK','textureBindings':recipe.get('bindings',{}),'repairs':fixes,'authoredClosure':closure,'textures':textures,'generatedMaterials':generated,'parts':[{'name':p['name'],'authored':bool(p.get('authored')),'material':p['material'],'texture':p['texture'],'triangles':p['triangles'],'opacity':p['opacity'],'role':p['role'],'bounds':p['bounds']} for p in parts],'placement':'Catalog only. No generation/map/footprint compatibility is implied; native adapter review required.'}
   (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');reports[model]=report
 (output_root/'lib/SceneryModelData.lua').write_text('-- Generated by tools/import_scenery_models.py; original source attribution is beside each texture.\nreturn '+lua(catalog)+'\n')
 return catalog,reports

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archives',type=Path);p.add_argument('output',type=Path);a=p.parse_args();models,reports=convert(a.archives,a.output)
 for name,model in models.items():print(name,len(model['parts']),'parts',sum(p['triangles'] for p in model['parts']),'triangles',model['bounds'])
