#!/usr/bin/env python3
"""Process the standard HGSS Center source (asset293549), never city variants."""
import argparse,copy,hashlib,io,json,struct,zipfile,zlib
from pathlib import Path,PurePosixPath
from import_scenery_models import obj,materials,normalize
from import_oras_grass import lua
from scenery_closures import hull
from import_pallet_buildings import extract as extract_scene
ID='hgss_kanto_center';URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/293549/'
def archive_items(raw):
 z=zipfile.ZipFile(io.BytesIO(raw));items={};repairs=[]
 if len(z.infolist())>64 or sum(i.file_size for i in z.infolist())>8388608:raise ValueError('archive budget')
 for i in z.infolist():
  if i.is_dir():continue
  path=PurePosixPath(i.filename)
  if path.is_absolute() or '..' in path.parts or i.flag_bits&1 or i.compress_type not in (0,8):raise ValueError('unsafe archive entry')
  head=struct.unpack_from('<4s5H3I2H',raw,i.header_offset);assert head[0]==b'PK\x03\x04';off=i.header_offset+30+head[-2]+head[-1];localname=raw[i.header_offset+30:i.header_offset+30+head[-2]]
  if localname!=i.filename.encode('utf8'):repairs.append({'centralName':i.filename,'localNameBytes':localname.hex(),'repair':'Central-directory name retained; compressed stream and CRC verified.'})
  blob=raw[off:off+i.compress_size];data=zlib.decompress(blob,-15) if i.compress_type==8 else blob
  if len(data)!=i.file_size or zlib.crc32(data)&0xffffffff!=i.CRC:raise ValueError('source ZIP size/CRC mismatch')
  items[i.filename]=data
 return items,repairs

def close_center(parts):
 # Source outer walls end at(+/-36,-28); the two original inner
 # partitions end at(+/-18,-30). Retain that stepped measured rear outline.
 source=next(p for p in parts if p['material']=='gs_pc_a');out=[]
 def part(name):
  p={k:copy.deepcopy(v) for k,v in source.items() if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True);out.append(p);return p
 def poly(p,points,uv):
  for i in range(1,len(points)-1):p['vertices'].extend([list(points[j])+list(uv[j])+[1.] for j in (0,i,i+1)])
 def quad(p,points,uv):poly(p,points,uv)
 rear=part('stepped_rear_wall')
 segments=[((-36,-28),(-18,-28)),((-18,-28),(-18,-30)),((-18,-30),(0,-30)),((0,-30),(18,-30)),((18,-30),(18,-28)),((18,-28),(36,-28))]
 for a,b in segments:
  quad(rear,[(a[0],2,a[1]),(b[0],2,b[1]),(b[0],32,b[1]),(a[0],32,a[1])],[(-.4277344,2.984375),(-.4121094,2.984375),(-.4121094,2.390625),(-.4277344,2.390625)])
  quad(rear,[(a[0],32,a[1]),(b[0],32,b[1]),(b[0],46,b[1]),(a[0],46,a[1])],[(-.375,2.78125),(-.015625,2.78125),(-.015625,2.390625),(-.375,2.390625)])
 soffit=part('rear_roof_soffit')
 for x0,x1,z in [(-36,-18,-28),(-18,18,-30),(18,36,-28)]:
  quad(soffit,[(x0,46,-32),(x1,46,-32),(x1,46,z),(x0,46,z)],[(.1875,2.984375)]*4)
 for side in (-1,1):
  quad(soffit,[(side*36,46,-32),(side*42,46,-26),(side*40,46,-24),(side*36,46,-28)],[(.1875,2.984375)]*4)
 bottom=part('closed_foundation');points=hull([v for p in parts if p['role']=='structure' for v in p['vertices'] if abs(v[1]-2)<1e-6])
 poly(bottom,[(x,1.45,z) for x,z in reversed(points)],[(.58,2.984375)]*len(points))
 for i,a in enumerate(points):
  b=points[(i+1)%len(points)];quad(bottom,[(a[0],1.45,a[1]),(b[0],1.45,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(.58,2.984375)]*4)
 return out

def convert(archive,output,closed=True,scene_archive=None):
 rawzip=archive.read_bytes();items,repairs=archive_items(rawzip);folder='Pokémon Center/';source=folder+'Pokémon Center.obj';mtl=folder+'Pokémon Center.mtl'
 original_obj,original_mtl=items[source],items[mtl]
 names={PurePosixPath(n).name:n for n in items if n.startswith(folder)};parts,fixes=obj(items[source],materials(items[mtl]),names)
 for p in parts:p.update(role='ground_shadow' if p['material']=='h_kage' else 'structure',alphaMode='blend' if p['opacity']<1 else 'cutout')
 scene_report=None
 if scene_archive is not None:
  scene_zip=scene_archive.read_bytes();scene_items,_=archive_items(scene_zip);scene_file=next(n for n in scene_items if n.endswith('.dae'));scene_raw=scene_items[scene_file]
  parts=extract_scene(scene_raw,{ID:'pc_011-mesh'},{ID:('p_door_023-mesh',[0,.50001,26])})[ID]
  for p in parts:
   p['role']='source_door' if p['role']=='source_door' else 'ground_shadow' if 'kage' in p['material'] else 'structure'
   # Canonical source material for the measured closure recipe.
   if p['material']=='gs_pc_a_020-material':p['material']='gs_pc_a'
  scene_names={PurePosixPath(n).name:n for n in scene_items}
  # Geometry and all source texture bytes now come from the newer regional DAE.
  items,names=scene_items,scene_names
  scene_report={'asset':592881,'sourcePage':'https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/','title':'Viridian City','author':'Kuramapika1','submitted':'2026-09-01','sourceFile':scene_file,'archiveSha256':hashlib.sha256(scene_zip).hexdigest(),'sourceModelSha256':hashlib.sha256(scene_raw).hexdigest(),'bodyGeometry':'pc_011-mesh','doorGeometry':'p_door_023-mesh','doorOffset':[0,.50001,26],'comparison':'Same256body triangles/bounds as older standard OBJ; newer scene supplies its original separate2-triangle door.'}
 original=copy.deepcopy(parts);authored=close_center(parts) if closed else [];parts.extend(authored);meta=normalize(parts);original_meta=normalize(original);dest=output/'assets/scenery/hgss-center';dest.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=PurePosixPath(p['texture']).name;content=items[names[name]];(dest/name).write_bytes(content);textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)};p['texture']='assets/scenery/hgss-center/'+name
 door=[.00879,2,26];anchors={'door':[(door[i]-meta['sourceOrigin'][i])/meta['sourceUnitSpan'] for i in range(3)]};data={ID:{'parts':parts,'bounds':meta['bounds'],'anchors':anchors}}
 report={'asset':293549,'sourcePage':URL,'title':'Pokémon Center (standard)','game':'Pokémon HeartGold / SoulSilver','author':'Cheesy Mac n Cheese','submitted':'2015-08-23','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(original_obj).hexdigest(),'sourceMaterialSha256':hashlib.sha256(original_mtl).hexdigest(),'selectedNewerSource':scene_report,'containerRepairs':repairs,'closure':'Authored stepped rear wall follows original outer wall/partition ends; rear soffit joins existing roof; thin closed foundation0.05below source shadow datum. Original front/door recess/roof retained.','sourceRepairs':fixes,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'textures':textures,'originalTriangles':sum(len(p['indices'])//3 for p in original),'processedTriangles':sum(p['triangles'] for p in parts),'parts':[{'name':p['name'],'material':p['material'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']} for p in parts]}
 if scene_report:
  report['comparisonSource']={key:report[key] for key in ['asset','sourcePage','title','author','submitted','archiveSha256','sourceFile','sourceModelSha256','sourceMaterialSha256','containerRepairs']}
  report.update({key:scene_report[key] for key in ['asset','sourcePage','title','author','submitted','archiveSha256','sourceFile','sourceModelSha256']});report['containerRepairs']=[];report.pop('sourceMaterialSha256',None)
 (dest/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib/HGSSCenterData.lua').write_text('-- Generated by tools/import_hgss_center.py; provenance beside source textures.\nreturn '+lua(data)+'\n');return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);p.add_argument('--source-only',action='store_true');p.add_argument('--scene',type=Path);a=p.parse_args();_,r=convert(a.archive,a.output,not a.source_only,a.scene);print(r['originalTriangles'],r['processedTriangles'])
