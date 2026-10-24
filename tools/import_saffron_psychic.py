#!/usr/bin/env python3
"""Import HGSS Mr Psychic's southeast Saffron house and its original panel."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from import_saffron_copycat import close_door
from scenery_closures import hull
ID='hgss_saffron_psychic'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592877/'
def close_house(parts):
 source=next(p for p in parts if p['texture']=='ybc_eo01.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 # Match the actual inner barrel profile, leaving its rear gable recessed from
 # the detailed outer fascia. Side-wall UVs carry yellow siding and green base.
 low,top=2,37.53516;v0=1.000976562;v1=v0+(top-low)/40*(.4863281-v0)
 rear=part('rear_siding');poly(rear,[(-27,low,-20),(27,low,-20),(27,top,-20),(-27,top,-20)],[(.90625,v0),(.90625,v0),(.90625,v1),(.90625,v1)])
 gable=part('rear_inner_gable');poly(gable,[(-28.125,top,-20),(28.125,top,-20),(16.96484,44,-20),(-16.96484,44,-20)],[(.90625,.5)]*4)
 cap=part('rear_barrel_fascia')
 for n in range(0,len(source['vertices']),3):
  tri=source['vertices'][n:n+3]
  if all(abs(v[2]-20)<1e-6 for v in tri)and min(v[1]for v in tri)>35:
   for v in reversed(tri):q=list(v);q[2]-=42;cap['vertices'].append(q)
 assert len(cap['vertices'])==48,'source barrel end changed'
 soffit=part('roof_soffit');profile=[(-28.125,top),(-16.96484,44),(16.96484,44),(28.125,top)]
 for a,b in zip(profile,profile[1:]):poly(soffit,[(a[0],a[1],-22),(a[0],a[1],20),(b[0],b[1],20),(b[0],b[1],-22)],[(.8671875,.2167969)]*4)
 base=part('closed_foundation');outline=hull([v for p in parts for v in p['vertices']if abs(v[1]-2)<1e-6]);poly(base,[(x,1.95,z)for x,z in reversed(outline)],[(.90625,.99)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];poly(base,[(a[0],1.95,a[1]),(b[0],1.95,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(.90625,.99)]*4)
 return out

def convert(archive,output):
 blob=archive.read_bytes();items,repairs=archive_items(blob);source=next(n for n in items if n.endswith('.dae'));raw=items[source]
 parts=extract(raw,{ID:'ybc_h01-mesh'},{ID:('ybc_dor1_001-mesh',[2,-.638672,9.4512])})[ID];original=copy.deepcopy(parts);parts=[p for p in parts if p['role']!='source_shading'];parts.extend(close_house(parts));parts.append(close_door(parts));meta=normalize(parts);original_meta=normalize(original)
 names={PurePosixPath(n).name:n for n in items};folder=output/'assets/scenery/saffron-psychic';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];b=items[names[name]];(folder/name).write_bytes(b);textures[name]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)};p['texture']='assets/scenery/saffron-psychic/'+name
 anchors={name:[(v-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i,v in enumerate(values)]for name,values in {'door':[-8,2,16],'doorHinge':[2,2,11.511747]}.items()}
 data={ID:{'parts':[p for p in parts if p['role']!='source_door'],'doorParts':[p for p in parts if p['role']=='source_door'],'anchors':anchors,'bounds':meta['bounds']}}
 report={'asset':592877,'sourcePage':URL,'title':'Saffron Mr Psychic house','game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(blob).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'ybc_h01-mesh','doorGeometry':'ybc_dor1_001-mesh','sourcePlacementEvidence':'Southeast regional house world(192,-280,30.99999), panel(194,-289.4512,30.36132); distinct from northwest Copycat(-224,104,30.99999). Common Y-up door offset(2,-.638672,9.4512) preserves exact source floorY2.','containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'closure':'Measured rear yellow siding/green plinth, inset inner gable, original detailed front barrel fascia copied to exact rear cut, three-segment barrel soffit and recessed foundation. Genuine panel receives measured missing left/back/top/bottom returns with original side paint. Original physical geometry/UV/PNG bytes retained; source shadow triangles excluded.','entrance':'Original separately instanced panel; authored native-frame inward hinge0/42.5/85 degrees. Only exact Mr Psychic native city/connection placements, never Copycat or generic one-storey no-door houses. Native permissions/warps/ground remain authoritative.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/SaffronPsychicData.lua').write_text('-- Generated by tools/import_saffron_psychic.py; original attribution beside textures.\nreturn '+lua(data)+'\n');return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args();_,r=convert(a.archive,a.output);print(ID,r['originalTriangles'],r['processedTriangles'])
