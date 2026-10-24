#!/usr/bin/env python3
"""Import the genuine HGSS Saffron Copycat house and close measured rear cuts."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from scenery_closures import hull
ID='hgss_saffron_copycat'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592877/'
def close_house(parts):
 source=next(p for p in parts if p['texture']=='ybc_mm01.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'}
  p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 # Two original side-wall bands carry their pink siding and blue-gray plinth
 # over the missing rear. Finish at the exact inner roof cut, avoiding a
 # coplanar overlap between a full-height wall and the gable closure.
 rear=part('rear_siding')
 for low,high,v0,v1 in[(2,26,1.000976562,.6582031),(26,50.125,.8447266,.496769869)]:
  poly(rear,[(-27,low,-20),(27,low,-20),(27,high,-20),(-27,high,-20)],[(1.938477,v0),(1.938477,v0),(1.938477,v1),(1.938477,v1)])
 gable=part('rear_inner_gable')
 poly(gable,[(-28.125,50.125,-20),(28.125,50.125,-20),(16.96484,56.58984,-20),(-16.96484,56.58984,-20)],[(1.938477,.5)]*4)
 # Copy the original detailed front barrel end to the omitted rear, retaining
 # every measured notch and UV. Reversed winding faces out of the rear cut.
 cap=part('rear_barrel_fascia')
 for start in range(0,len(source['vertices']),3):
  tri=source['vertices'][start:start+3]
  if all(abs(v[2]-20)<.00001 for v in tri)and min(v[1]for v in tri)>50:
   for v in reversed(tri):q=list(v);q[2]-=42;cap['vertices'].append(q)
 assert len(cap['vertices'])==48,'source barrel end changed'
 soffit=part('roof_soffit')
 profile=[(-28.125,50.125),(-16.96484,56.58984),(16.96484,56.58984),(28.125,50.125)]
 for a,b in zip(profile,profile[1:]):poly(soffit,[(a[0],a[1],-22),(a[0],a[1],20),(b[0],b[1],20),(b[0],b[1],-22)],[(.8671875,.2167969)]*4)
 base=part('closed_foundation');outline=hull([v for p in parts for v in p['vertices']if abs(v[1]-2)<1e-6])
 poly(base,[(x,1.95,z)for x,z in reversed(outline)],[(1.938477,.99)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];poly(base,[(a[0],1.95,a[1]),(b[0],1.95,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(1.938477,.99)]*4)
 return out

def close_door(parts):
 p=next(p for p in parts if p['role']=='source_door');out={k:copy.deepcopy(v)for k,v in p.items()if k!='vertices'};out.update(name='authored_door_returns',vertices=[],authored=True)
 v=p['vertices'];x0,x1=min(q[0]for q in v),max(q[0]for q in v);y0,y1=min(q[1]for q in v),max(q[1]for q in v);z0,z1=min(q[2]for q in v),max(q[2]for q in v)
 def quad(pts):
  for i in(0,1,2,0,2,3):out['vertices'].append(list(pts[i])+[.85,.35,1.])
 quad([(x1,y0,z0),(x0,y0,z0),(x0,y1,z0),(x1,y1,z0)])
 quad([(x0,y0,z0),(x0,y0,z1),(x0,y1,z1),(x0,y1,z0)])
 quad([(x0,y1,z1),(x1,y1,z1),(x1,y1,z0),(x0,y1,z0)])
 quad([(x0,y0,z0),(x1,y0,z0),(x1,y0,z1),(x0,y0,z1)])
 return out

def convert(archive,output,closed=True):
 blob=archive.read_bytes();items,repairs=archive_items(blob);source=next(n for n in items if n.endswith('.dae'));raw=items[source]
 parts=extract(raw,{ID:'ybc_mmc-mesh'},{ID:('ybc_dor1-mesh',[2,-.638672,9.45117])})[ID];original=copy.deepcopy(parts);parts=[p for p in parts if p['role']!='source_shading']
 if closed:parts.extend(close_house(parts));parts.append(close_door(parts))
 meta=normalize(parts);original_meta=normalize(original);names={PurePosixPath(n).name:n for n in items};folder=output/'assets/scenery/saffron-copycat';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];b=items[names[name]];(folder/name).write_bytes(b);textures[name]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)};p['texture']='assets/scenery/saffron-copycat/'+name
 anchors={name:[(v-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i,v in enumerate(values)]for name,values in {'door':[-8,2,16],'doorHinge':[2,2,11.511717]}.items()}
 data={ID:{'parts':[p for p in parts if p['role']!='source_door'],'doorParts':[p for p in parts if p['role']=='source_door'],'bounds':meta['bounds'],'anchors':anchors}}
 report={'asset':592877,'sourcePage':URL,'title':'Saffron Copycat house','game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(blob).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'ybc_mmc-mesh','doorGeometry':'ybc_dor1-mesh','doorLocalOffset':[2,-.638672,9.45117],'doorPlacementEvidence':'Source scene matrices: Copycat world(-224,104,30.99999), door(-222,94.54883,30.36132), converted to common Y-up local coordinates. Offset precision keeps exact source floorY2.','containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'entrance':'Genuine separately instanced source door retains original panel and transforms; native FR/LG frames drive authored inward0/42.5/85 degree hinge poses within native blocked cells. Source interior retained. Copycat placements only, never Mr. Psychic despite shared native art.','closure':'Rear two-floor siding/plinth continues measured original side strips; detailed front barrel fascia copied with reverse winding to exact rear cut, recessed inner gable/roof soffit and recessed underside foundation. Source door missing left/back/top/underside closes with measured original panel bounds and plain side paint; closed panel only appears in animated door batches. Original facade/windows/roof fixtures/interior/panel geometry/UV/PNG bytes retained. Source shading excluded.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/SaffronCopycatData.lua').write_text('-- Generated by tools/import_saffron_copycat.py; original attribution beside textures.\nreturn '+lua(data)+'\n');return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();_,r=convert(a.archive,a.output,not a.source_only);print(ID,r['originalTriangles'],r['processedTriangles'])
