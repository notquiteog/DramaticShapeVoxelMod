#!/usr/bin/env python3
"""Regional HGSS Viridian/Pewter Gym sources. No automatic native placement."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from scenery_closures import hull
SPECS={
 'hgss_viridian_gym':(592881,'to_gym_001-mesh','gym_door_007-mesh',[-.0508,-1.24609,22.8867],'to_gym_b.png'),
 'hgss_pewter_gym':(592849,'nbc_gym_001-mesh','gym_door_005-mesh',[.0059,-.67383,22.88672],'nbc_gym_b.png'),
}
def close_gym(parts,wall_texture):
 source=next(p for p in parts if p['texture']=='kn_gym_a.png');band_source=next(p for p in parts if p['texture']==wall_texture and len(p['vertices'])//3==50);out=[]
 def part(name,base=None):
  p={k:copy.deepcopy(v)for k,v in(base or source).items()if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 def quad(p,pts,uv):poly(p,pts,uv)
 # Continue source wall/blue-belt end sections across the missing back.
 wall=part('rear_wall')
 quad(wall,[(-46.63281,2.226562,-28.17125),(46.91602,2.226562,-28.17125),(46.91602,40.10937,-28.17125),(-46.63281,40.10937,-28.17125)],[(-.207031,.984375),(-.207031,.984375),(-.207031,.015625),(-.207031,.015625)])
 band=part('rear_blue_belt',band_source)
 quad(band,[(-47.55469,13.88867,-30.28062),(46.66016,13.88867,-30.28062),(46.66016,21.13867,-30.28062),(-47.55469,21.13867,-30.28062)],[(-.53125,1.739258),(-.53125,1.739258),(-.53125,1.582031),(-.53125,1.582031)])
 # Exact roof cut follows the original stepped lip and sloping rear panel.
 trim=part('rear_roof_return')
 quad(trim,[(-50.22461,38.39062,-34.33594),(50.50586,38.39062,-34.33594),(50.50586,46.98242,-34.33594),(-50.22461,46.98242,-34.33594)],[(-.728516,.908203),(-.660156,.908203),(-.660156,.763672),(-.728516,.763672)])
 quad(trim,[(-50.22461,46.98242,-34.33594),(50.50586,46.98242,-34.33594),(44.41016,54.73633,-30.23438),(-44.11523,54.73633,-30.23438)],[(-.730469,.162109),(-.703125,.162109),(-.703125,.027344),(-.730469,.027344)])
 # Roof and raised entrance tower retain their measured octagonal outlines.
 soffit=part('roof_soffit');outline=[(-55.66992,-27.8418),(-50.22461,-34.33594),(50.50586,-34.33594),(56.04883,-27.8418),(56.04883,14.86328),(50.50586,21.35742),(-50.22461,21.35742),(-55.66992,14.86328)]
 poly(soffit,[(x,38.39062,z)for x,z in reversed(outline)],[(-.730469,.908203)]*8)
 tower=part('entrance_tower_soffit');outline=[(-16,-41.01562),(16,-41.01562),(20.98047,-30.44922),(20.98047,16.72656),(16,29.01562),(-16,29.01562),(-20.98047,16.72656),(-20.98047,-30.44922)]
 poly(tower,[(x,35.4375,z)for x,z in reversed(outline)],[(-.730469,.908203)]*8)
 base=part('closed_foundation');outline=hull([v for p in parts for v in p['vertices']if v[1]<=2.4]);bottom=1.604297
 poly(base,[(x,bottom,z)for x,z in reversed(outline)],[(-.207031,.984375)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];quad(base,[(a[0],bottom,a[1]),(b[0],bottom,b[1]),(b[0],2.4,b[1]),(a[0],2.4,a[1])],[(-.207031,.984375)]*4)
 return out

def convert(archives,output):
 data={};reports={}
 for key,(asset,body,door,offset,wall_texture)in SPECS.items():
  rawzip=(archives/(str(asset)+'.zip')).read_bytes();items,repairs=archive_items(rawzip);source=next(n for n in items if n.endswith('.dae'));raw=items[source]
  parts=extract(raw,{key:body},{key:(door,offset)})[key];original=copy.deepcopy(parts)
  parts=[p for p in parts if p['texture']!='h_kage.png'];parts.extend(close_gym(parts,wall_texture));meta=normalize(parts);original_meta=normalize(original)
  names={PurePosixPath(n).name:n for n in items};dest=output/'assets/scenery/hgss-kanto-gyms'/key;dest.mkdir(parents=True,exist_ok=True);textures={}
  for p in parts:
   name=p['texture'];blob=items[names[name]];(dest/name).write_bytes(blob);textures[name]={'sha256':hashlib.sha256(blob).hexdigest(),'bytes':len(blob)};p['texture']='assets/scenery/hgss-kanto-gyms/'+key+'/'+name
  door_vertices=[v for p in parts if p['role']=='source_door'for v in p['vertices']];door_anchor=[(min(v[i]for v in door_vertices)+max(v[i]for v in door_vertices))/2 for i in range(3)];door_anchor[1]=min(v[1]for v in door_vertices);door_anchor[2]=max(v[2]for v in door_vertices)
  data[key]={'parts':[p for p in parts if p['role']!='source_door'],'doorParts':[p for p in parts if p['role']=='source_door'],'bounds':meta['bounds'],'anchors':{'door':door_anchor}}
  reports[key]={'asset':asset,'sourcePage':f'https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/{asset}/','game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','sourceFile':source,'geometry':body,'doorGeometry':door,'doorOffset':offset,'archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'excludedTriangles':11,'closure':'Measured rear wall/belt/roof returns, both roof soffits, foundation. No source door/window/sign/roof silhouette removed; original source shadow triangles omitted.','nativePlacement':'Gen3ImportedHGSSGyms exact native drawing/permission adapter, with triangle-mask clearance and original paired door geometry; source eligibility and rendered acceptance are tracked separately.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
  (dest/'provenance.json').write_text(json.dumps(reports[key],indent=2,ensure_ascii=False)+'\n')
 (output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/HGSSKantoGymData.lua').write_text('-- Generated by tools/import_hgss_kanto_gyms.py; source eligibility is separate from native rendered acceptance.\nreturn '+lua(data)+'\n');return data,reports
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archives',type=Path);p.add_argument('output',type=Path);a=p.parse_args();_,r=convert(a.archives,a.output)
 for k,v in r.items():print(k,v['originalTriangles'],v['processedTriangles'])
