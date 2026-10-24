#!/usr/bin/env python3
"""Reproduce the genuine HGSS Saffron Fighting Dojo and measured closures."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from import_saffron_blocks import profile_triangles
from scenery_closures import hull
ID='hgss_saffron_dojo'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592877/'
def close_dojo(parts):
 out=[]
 def part(name,texture):
  source=next(p for p in parts if p['texture']==texture);p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 def quad(p,pts,uv):poly(p,pts,uv)
 # Continue the original side plaster/plinth islands across the open rear.
 wall=part('rear_plaster_wall','ybcfg_06.png');quad(wall,[(-46.53906,8,-29.89844),(46.53906,8,-29.89844),(46.53906,41.51562,-29.89844),(-46.53906,41.51562,-29.89844)],[(.984375,.9863281),(.984375,.9863281),(.984375,.015625),(.984375,.015625)])
 plinth=part('rear_plinth','ybcfg_03.png');quad(plinth,[(-46.53906,2,-29.89844),(46.53906,2,-29.89844),(46.53906,8,-29.89844),(-46.53906,8,-29.89844)],[(.23046875,.9296875),(.23046875,.9296875),(.23046875,.0703125),(.23046875,.0703125)])
 fascia=part('rear_eave_returns','ybcfg_04.png')
 for a,b,c,d in [((-52.81641,-34.91406),(-23.01562,-34.91406),(-20.30469,-32.90234),(-49.00781,-32.90234)),((23.01562,-34.91406),(52.81641,-34.91406),(49.00781,-32.90234),(20.30469,-32.90234)),((-23.01562,-46.92969),(23.01562,-46.92969),(20.30469,-43.1211),(-20.30469,-43.1211))]:
  quad(fascia,[(a[0],47.4375,a[1]),(b[0],47.4375,b[1]),(c[0],39.4375,c[1]),(d[0],39.4375,d[1])],[(1.632812,.0625),(1.632812,.0625),(1.632812,.9375),(1.632812,.9375)])
 # Concave cross-shaped roof outline; never bridge its four re-entrant corners.
 profile=[(-49.00781,-32.90234),(-20.30469,-32.90234),(-20.30469,-43.1211),(20.30469,-43.1211),(20.30469,-32.90234),(49.00781,-32.90234),(49.00781,19.87891),(20.30469,19.87891),(20.30469,30.09766),(-20.30469,30.09766),(-20.30469,19.87891),(-49.00781,19.87891)]
 soffit=part('cross_roof_soffit','ybcfg_04.png')
 for tri in profile_triangles(profile):soffit['vertices'].extend([[profile[i][0],39.4375,profile[i][1],1.632812,.9375,1.]for i in tri])
 outline=hull([v for p in parts for v in p['vertices']if abs(v[1]-2)<1e-6]);base=part('closed_foundation','ybcfg_03.png')
 poly(base,[(x,1.95,z)for x,z in reversed(outline)],[(.23,.93)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];quad(base,[(a[0],1.95,a[1]),(b[0],1.95,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(.23,.93)]*4)
 return out

def convert(archive,output):
 rawzip=archive.read_bytes();items,repairs=archive_items(rawzip);source=next(n for n in items if n.endswith('.dae'));raw=items[source];parts=extract(raw,{ID:'ybc_fgm-mesh'},{})[ID];original=copy.deepcopy(parts)
 parts=[p for p in parts if p['role']!='source_shading'];parts.extend(close_dojo(parts));meta=normalize(parts);original_meta=normalize(original);names={PurePosixPath(n).name:n for n in items};folder=output/'assets/scenery/saffron-dojo';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];blob=items[names[name]];(folder/name).write_bytes(blob);textures[name]={'sha256':hashlib.sha256(blob).hexdigest(),'bytes':len(blob)};p['texture']='assets/scenery/saffron-dojo/'+name
 anchors={'door':[(v-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i,v in enumerate([0,2,27])]}
 data={ID:{'parts':parts,'anchors':anchors,'bounds':meta['bounds']}}
 report={'asset':592877,'sourcePage':URL,'game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'ybc_fgm-mesh','containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'entrance':'Original open inset portal and separate flanking plaques retained; no hinged panel invented.','closure':'Original side plaster/plinth across measured rear, three missing sloping rear eave cuts, concave cross-shaped roof soffit, recessed foundation. Original roof/gables/emblem/plaques/window/portal geometry, UVs and PNG bytes retained; source shading excluded.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/SaffronDojoData.lua').write_text('-- Generated by tools/import_saffron_dojo.py; attribution beside original textures.\nreturn '+lua(data)+'\n');return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args();_,r=convert(a.archive,a.output);print(ID,r['originalTriangles'],r['processedTriangles'])
