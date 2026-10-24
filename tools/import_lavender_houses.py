#!/usr/bin/env python3
"""Extract the newest HGSS Lavender ordinary house, with its original door."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from scenery_closures import hull
ID='hgss_lavender_house'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592838/'
OFFSET=[4.1182,-.29492,9.5752]
HINGE=[4.13870781,.83008,9.56055157]
DOOR=[-5.86129219,.83008,10.590824785]
def close_house(parts):
 source=next(p for p in parts if p['texture']=='si_h01.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'}
  p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 def quad(p,pts,uv):poly(p,pts,uv)
 # Source back is absent. Continue the original side-wall purple between its
 # measured rear corners; the original roof slab occludes its upper junction.
 rear=part('rear_wall')
 quad(rear,[(-30.76758,1.9043,-15.90039),(28.76758,1.9043,-15.90039),(28.76758,33.96484,-15.90039),(-30.76758,33.96484,-15.90039)],[(.625,.538)]*4)
 # Match the existing front/side fascia dimensions and the actual flat roof,
 # rather than invent a pitched roof or project facade windows onto the back.
 fascia=part('rear_roof_fascia')
 quad(fascia,[(-31.86133,33.96484,-24.08984),(29.86133,33.96484,-24.08984),(29.86133,45.96484,-24.08984),(-31.86133,45.96484,-24.08984)],[(.0078125,.5908203),(.7216797,.5908203),(.7216797,.4238281),(.0078125,.4238281)])
 soffit=part('roof_soffit')
 quad(soffit,[(-31.86133,33.96484,-24.08984),(-31.86133,33.96484,18.67774),(29.86133,33.96484,18.67774),(29.86133,33.96484,-24.08984)],[(.2246094,.5361328)]*4)
 # A recessed contact cap and the original measured low wall outline close the
 # underside. The tiny source threshold remains behind the original doorway.
 base=part('closed_foundation');low=[v for p in parts if p['role']=='structure'for v in p['vertices']if v[1]<1.905];pts=hull(low)
 def y_at(q):return min(v[1]for v in low if abs(v[0]-q[0])<1e-7 and abs(v[2]-q[1])<1e-7)
 poly(base,[(x,.8,z)for x,z in reversed(pts)],[(.625,.538)]*len(pts))
 for i,a in enumerate(pts):
  b=pts[(i+1)%len(pts)];quad(base,[(a[0],.8,a[1]),(b[0],.8,b[1]),(b[0],y_at(b),b[1]),(a[0],y_at(a),a[1])],[(.625,.538)]*4)
 return out

def convert(archive,output,closed=True):
 rawzip=archive.read_bytes();items,repairs=archive_items(rawzip);source=next(n for n in items if n.endswith('.dae'));raw=items[source]
 parts=extract(raw,{ID:'si_h01-mesh'},{ID:('si_door1-mesh',OFFSET)})[ID];original=copy.deepcopy(parts)
 parts=[p for p in parts if p['role']!='source_shading']
 if closed:parts.extend(close_house(parts))
 meta=normalize(parts);original_meta=normalize(original);names={PurePosixPath(n).name:n for n in items}
 folder=output/'assets/scenery/lavender-house';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];content=items[names[name]];(folder/name).write_bytes(content)
  textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)};p['texture']='assets/scenery/lavender-house/'+name
 anchors={key:[(v[i]-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i in range(3)]for key,v in {'door':DOOR,'doorHinge':HINGE}.items()}
 data={ID:{'parts':[p for p in parts if p['role']!='source_door'],'doorParts':[p for p in parts if p['role']=='source_door'],'bounds':meta['bounds'],'anchors':anchors}}
 report={'asset':592838,'sourcePage':URL,'title':'Lavender Town ordinary house','game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'si_h01-mesh','doorGeometry':'si_door1-mesh','doorOffset':OFFSET,'nativeDoorPose':{'hinge':HINGE,'degrees':[0,-45,-90],'adaptation':'Authored inward pose around original right rear edge, opposite original left handle; native timing retained. Not an extracted HGSS track.'},'containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'closure':'Measured rear wall, rear roof fascia, flat soffit and recessed contact cap. Original front, side columns, inset window, flat roof and separate door retained. Source shading excluded; renderer owns lighting.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True)
 (output/'lib/LavenderHouseData.lua').write_text('-- Generated by tools/import_lavender_houses.py; original attribution beside textures.\nreturn '+lua(data)+'\n')
 return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();_,r=convert(a.archive,a.output,not a.source_only);print(r['originalTriangles'],r['processedTriangles'])
