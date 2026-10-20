#!/usr/bin/env python3
"""Extract one original Route 104 broadleaf family, retaining its vertex colors."""
import argparse,collections,copy,hashlib,io,json,math,zipfile
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image
from import_oras_grass import NS,sources,inputs,lua
from import_scenery_models import dae_static,normalize

MODEL='oras_route104_broadleaf'
SOURCE='world03_02_02.dae'
MATERIALS={'_4_0-mesh':'wood_base.png','_5_0-mesh':'forest_wood_a.png'}
URL='https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/364272/'

def bounds(vs):return [min(v[i]for v in vs)for i in range(3)]+[max(v[i]for v in vs)for i in range(3)]
def components(vertices):
 parent=list(range(len(vertices)//3));seen={}
 def find(n):
  while parent[n]!=n:parent[n]=parent[parent[n]];n=parent[n]
  return n
 for i,v in enumerate(vertices):
  key=tuple(round(n,3)for n in v[:3]);t=i//3
  if key in seen:parent[find(t)]=find(seen[key])
  else:seen[key]=t
 groups=collections.defaultdict(list)
 for i in range(0,len(vertices),3):groups[find(i//3)].extend(copy.deepcopy(vertices[i:i+3]))
 return list(groups.values())

def extract(raw):
 root=ET.fromstring(raw)
 # Other materials/route chunks are deliberately excluded, including tree
 # impostor cards. Their geometry and assets do not enter the tree catalog.
 for geom in root.findall('c:library_geometries/c:geometry',NS):
  mesh=geom.find('c:mesh',NS)
  if geom.get('id')not in MATERIALS:
   for p in list(mesh):
    if p.tag.rsplit('}',1)[-1]in ('triangles','polylist'):mesh.remove(p)
 parts=dae_static(ET.tostring(root))
 geoms={g.get('id'):g.find('c:mesh',NS)for g in root.findall('c:library_geometries/c:geometry',NS)}
 for p in parts:
  mesh=geoms[p['geometry']];prims=mesh.findall('c:triangles',NS);assert len(prims)==1
  primitive=prims[0];pin=inputs(primitive);src=sources(mesh)
  stride=1+max(n[1]for n in pin.values());stream=list(map(int,primitive.findtext('c:p',namespaces=NS).split()))
  colors=src[pin['COLOR'][0]]
  for i,v in enumerate(p['vertices']):v.extend(colors[stream[i*stride+pin['COLOR'][1]]][:3]+[1.])
  assert p['texture']==MATERIALS[p['geometry']]
 trunks=components(next(p['vertices']for p in parts if p['texture']=='wood_base.png'))
 leaves=components(next(p['vertices']for p in parts if p['texture']=='forest_wood_a.png'))
 assert len(trunks)==5 and len(leaves)==30
 centers=[[(b[0]+b[3])/2,(b[2]+b[5])/2]for b in map(bounds,trunks)]
 grouped=[[]for _ in trunks]
 for vs in leaves:
  b=bounds(vs);center=[(b[0]+b[3])/2,(b[2]+b[5])/2]
  owner=min(range(len(trunks)),key=lambda i:sum((a-b)**2 for a,b in zip(center,centers[i])))
  grouped[owner].append(vs)
 assert all(len(cs)==6 for cs in grouped),'source canopy ownership is ambiguous'
 selected=[]
 for name,texture,vs in [('trunk','wood_base.png',trunks[0]),('canopy','forest_wood_a.png',[v for c in grouped[0]for v in c])]:
  selected.append({'name':name,'material':texture,'texture':texture,'vertices':vs,'opacity':1.,'diffuse':[1.,1.,1.],
   'wrapS':'repeat','wrapT':'repeat','role':'tree_'+name,'alphaMode':'cutout','authored':False})
 assert [len(p['vertices'])//3 for p in selected]==[60,48]
 return selected,{'trunkComponents':len(trunks),'canopyComponents':len(leaves),'selectedCopy':0,
  'selectedSourceBounds':bounds([v for p in selected for v in p['vertices']]),'sourceTriangles':108}

def complete_tree(parts):
 """Close the bark hull and reuse source leaf shells around its real axis."""
 trunk=parts[0]['vertices'];canopy=parts[1]['vertices'];b=bounds(trunk)
 axis=[(b[0]+b[3])/2,(b[2]+b[5])/2]
 edges=collections.Counter();points={}
 for i in range(0,len(trunk),3):
  q=[]
  for v in trunk[i:i+3]:
   key=tuple(round(n,3)for n in v[:3]);points.setdefault(key,v);q.append(key)
  for a,c in zip(q,q[1:]+q[:1]):edges[tuple(sorted((a,c)))]+=1
 boundary={p for e,n in edges.items()if n==1 for p in e}
 rows=collections.defaultdict(list)
 for key in boundary:rows[key[1]].append(points[key])
 ys=sorted(rows);closure=[]
 def tri(a,c,d):closure.extend(copy.deepcopy([a,c,d]))
 def rear(vs):
  z=min(v[2]for v in vs);rear=[v for v in vs if abs(v[2]-z)<.002]
  assert len(rear)==2,'expected two source rear-strip endpoints'
  return sorted(rear,key=lambda v:v[0])
 for low,high in zip(ys,ys[1:]):
  a,c=rear(rows[low]);d,e=rear(rows[high]);tri(a,c,e);tri(a,e,d)
 for y,reverse in [(ys[0],True),(ys[-1],False)]:
  ring=sorted(rows[y],key=lambda v:math.atan2(v[2]-axis[1],v[0]-axis[0]));assert len(ring)==7
  center=[sum(v[i]for v in ring)/len(ring)for i in range(3)]+[.1,.3,1.,1.,1.,1.,1.]
  for a,c in zip(ring,ring[1:]+ring[:1]):
   a=copy.deepcopy(a);c=copy.deepcopy(c);a[3:5]=c[3:5]=[.1,.3]
   if reverse:tri(center,c,a)
   else:tri(center,a,c)
 hull=collections.Counter()
 for i in range(0,len(trunk+closure),3):
  q=[tuple(round(n,3)for n in v[:3])for v in (trunk+closure)[i:i+3]]
  for a,c in zip(q,q[1:]+q[:1]):hull[tuple(sorted((a,c)))]+=1
 assert set(hull.values())=={2},'authored bark closure leaves an open edge'
 crown=[]
 for rotation in [1,2,3]:
  for v in canopy:
   q=copy.deepcopy(v);x,z=v[0]-axis[0],v[2]-axis[1]
   if rotation==1:x,z=-z,x
   elif rotation==2:x,z=-x,-z
   else:x,z=z,-x
   q[0],q[2]=axis[0]+x,axis[1]+z;crown.append(q)
 additions=[]
 for name,source,vertices in [('bark_closure',parts[0],closure),('canopy_quarter_turns',parts[1],crown)]:
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name=name,vertices=vertices,authored=True);additions.append(p)
 # Original trunk UV cutouts include transparent root pixels. A closed,
 # slightly inset copy with an existing opaque bark texel prevents the new
 # ground cap from showing as a detached ring through those source cutouts.
 # Source outer geometry/UVs stay intact; this adds no footprint or height.
 backing=[];mid=(b[1]+b[4])/2
 for v in trunk+closure:
  q=copy.deepcopy(v);q[0]=axis[0]+(v[0]-axis[0])*.996;q[2]=axis[1]+(v[2]-axis[1])*.996
  q[1]=mid+(v[1]-mid)*.999;q[3:5]=[.1,.3];backing.append(q)
 p={k:copy.deepcopy(v)for k,v in parts[0].items()if k!='vertices'}
 p.update(name='bark_inner_backing',vertices=backing,authored=True);additions.append(p)
 return additions,{'sourceTriangles':108,'barkClosureTriangles':len(closure)//3,'addedCanopyTriangles':len(crown)//3,'insetBarkBackingTriangles':len(backing)//3,
  'canopyRotations':[90,180,270],'trunkAxisXZ':axis,'barkHullEdgesClosed':True,
  'notes':'Original108triangles retained. Source leaf shells remain alpha-cutout foliage; their open leaf edges are intentional, not opaque solid hulls.'}

def convert(archive_path,output_root):
 archive_raw=Path(archive_path).read_bytes()
 with zipfile.ZipFile(io.BytesIO(archive_raw))as z:
  raw=z.read(SOURCE);parts,selection=extract(raw)
  additions,completion=complete_tree(parts);parts.extend(additions)
  meta=normalize(parts)
  canopy_y=min(v[1]for p in parts if p['role']=='tree_canopy'for v in p['vertices'])
  folder=output_root/'assets/scenery/oras-trees';folder.mkdir(parents=True,exist_ok=True)
  textures={}
  for p in parts:
   name=p['texture'];png=z.read(name);(folder/name).write_bytes(png)
   image=Image.open(io.BytesIO(png)).convert('RGBA')
   textures[name]={'sha256':hashlib.sha256(png).hexdigest(),'size':list(image.size),'alphaRange':list(image.getextrema()[3])}
   p['texture']='assets/scenery/oras-trees/'+name
   p['colors']=[v[6:]for v in p['vertices']];p['vertices']=[v[:6]for v in p['vertices']]
  data={MODEL:{'parts':parts,'bounds':meta['bounds'],'anchors':{'canopyBottom':[0.,canopy_y,0.]}}}
  report={'asset':364272,'sourcePage':URL,'game':'Pokémon Omega Ruby / Alpha Sapphire','uploadedBy':'MasterPengo','submitted':'2025-06-29',
   'originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(archive_raw).hexdigest(),
   'sourceModel':SOURCE,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),**selection,**meta,'authoredCompletion':completion,'textures':textures,
   'processing':['Evaluated full static scene hierarchy, declared Z_UP and asset unit through the shared DAE converter.',
    'Selected one connected trunk and its six canopy lobes from five original translation copies; excluded distant tree cards and all unrelated scenery.',
    'Preserved original UVs, per-vertex RGB colors, alpha-cutout textures and repeat samplers; PNG bytes unchanged.',
    'Uniformly scaled XYZ, centered X/Z, grounded actual mesh minimum Y; native adapter must fit complete blocked footprint.'],
   'placement':'Prepared family only; native adapter must review the complete blocked footprint, source family and fallback.'}
  (output_root/'lib/ImportedTreeData.lua').write_text('-- Generated by tools/import_route104_tree.py; source credits/provenance in assets/scenery/oras-trees.\nreturn '+lua(data)+'\n')
  (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
  return data,report
if __name__=='__main__':
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('archive',type=Path);parser.add_argument('--output-root',type=Path,required=True)
 args=parser.parse_args();data,report=convert(args.archive,args.output_root)
 print(json.dumps({'model':MODEL,'parts':len(data[MODEL]['parts']),'triangles':sum(p['triangles']for p in data[MODEL]['parts']),**report['textures'],'sourceBounds':report['selectedSourceBounds']}))
