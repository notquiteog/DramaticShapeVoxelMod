#!/usr/bin/env python3
"""Import newer HGSS Pewter ordinary house and its own door, never city ground."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from scenery_closures import hull
ID='hgss_pewter_house'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592849/'
def close_house(parts):
 source=next(p for p in parts if p['texture']=='nbc_h01b.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'}
  p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 def quad(p,pts,uv):poly(p,pts,uv)
 # Rear siding continues the original flat side-wall siding, without windows.
 wall=part('rear_siding');x0,x1=-28.79687,29.47266
 for y0,y1,v0,v1 in [(2,6,.96875,.90625),(6,20,.90625,.6875),(20,32,.6875,.5)]:
  quad(wall,[(x0,y0,-20.015),(x1,y0,-20.015),(x1,y1,-20.015),(x0,y1,-20.015)],[(.9921875,v0),(.9921875,v0),(.9921875,v1),(.9921875,v1)])
 # The source roof has an asymmetric ridge at x8. Continue that actual
 # underside profile, including the taller right side, instead of a box cap.
 left=(-30.42969,31.54687);ridge=(8,58);right=(31.10547,42.44922)
 def roof_y(x):
  a,b=(left,ridge)if x<=8 else(ridge,right)
  return a[1]+(b[1]-a[1])*(x-a[0])/(b[0]-a[0])
 gable=part('rear_gable')
 poly(gable,[(x0,32,-20.015),(x1,32,-20.015),(x1,roof_y(x1),-20.015),(8,58,-20.015),(x0,roof_y(x0),-20.015)],[(.9921875,.5)]*5)
 # Close the measured rear roof thickness and both pitched undersides.
 trim=part('rear_roof_return')
 outer=[(-33,36),(8,64),(33.67578,46.89844)];inner=[left,ridge,right]
 for i in range(2):
  a,b=outer[i:i+2];c,d=inner[i:i+2]
  quad(trim,[(a[0],a[1],-24),(b[0],b[1],-24),(d[0],d[1],-24),(c[0],c[1],-24)],[(.03515625,.5)]*4)
 soffit=part('pitched_roof_soffit')
 for a,b in zip(inner,inner[1:]):
  quad(soffit,[(a[0],a[1],-24),(b[0],b[1],-24),(b[0],b[1],23),(a[0],a[1],23)],[(.03515625,.5)]*4)
 # Original front gable trim has open returns and an inset rear cut at z18.
 front=part('front_gable_returns')
 poly(front,[(-12.69531,48.89844,18),(8,63,18),(29.35937,48.89844,18)],[(.9921875,.5)]*3)
 quad(front,[(-12.69531,44.89844,16),(29.35937,44.89844,16),(29.35937,44.89844,20),(-12.69531,44.89844,20)],[(.03515625,.5)]*4)
 for x in(-12.69531,29.35937):
  quad(front,[(x,44.89844,16),(x,44.89844,20),(x,48.89844,20),(x,48.89844,18)],[(.03515625,.5)]*4)
 # Physical foundation stays just below the source shadow datum and threshold.
 base=part('closed_foundation');pts=hull([v for p in parts if p['role']=='structure'for v in p['vertices']if abs(v[1]-2)<.0001])
 poly(base,[(x,.95,z)for x,z in reversed(pts)],[(.9921875,.96875)]*len(pts))
 for i,a in enumerate(pts):
  b=pts[(i+1)%len(pts)];quad(base,[(a[0],.95,a[1]),(b[0],.95,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(.9921875,.96875)]*4)
 return out

def convert(archive,output,closed=True):
 rawzip=archive.read_bytes();items,repairs=archive_items(rawzip);source=next(n for n in items if n.endswith('.dae'));raw=items[source]
 parts=extract(raw,{ID:'nbc_h01_005-mesh'},{ID:('nbc_dr1_005-mesh',[2,1,13.9385])})[ID]
 for p in parts:
  if 'kage'in p['material']:p['role']='source_shading'
 original=copy.deepcopy(parts)
 parts=[p for p in parts if p['role']!='source_shading']
 if closed:parts.extend(close_house(parts))
 meta=normalize(parts);original_meta=normalize(original);names={PurePosixPath(n).name:n for n in items}
 folder=output/'assets/scenery/pewter-house';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];content=items[names[name]];(folder/name).write_bytes(content)
  textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)};p['texture']='assets/scenery/pewter-house/'+name
 anchors={key:[(v[i]-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i in range(3)]for key,v in {'door':[-8,1,16.000023],'doorHinge':[2,1,13.9385],'chimney':[-17,55.14453,-8]}.items()}
 door_parts=[p for p in parts if p['role']=='source_door']
 data={ID:{'parts':[p for p in parts if p['role']!='source_door'],'doorParts':door_parts,'bounds':meta['bounds'],'anchors':anchors}}
 report={'asset':592849,'sourcePage':URL,'title':'Pewter City ordinary house','game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'nbc_h01_005-mesh','doorGeometry':'nbc_dr1_005-mesh','doorOffset':[2,1,13.9385],'nativeDoorPose':{'hinge':[2,1,13.9385],'degrees':[0,-45,-90],'adaptation':'Authored inward pose around original right rear edge, opposite original left handle; native frames and timing retained. Not an extracted HGSS track.'},'containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'closure':'Measured rear siding and asymmetric gable, original roof-thickness cuts and pitched soffit, front-gable returns, closed foundation. Original source facade, chimney, windows and recessed door unchanged. The21 original source-shading triangles are excluded from processed geometry; renderer live lighting owns illumination.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
 (output/'lib').mkdir(parents=True,exist_ok=True)
 (output/'lib/PewterHouseData.lua').write_text('-- Generated by tools/import_pewter_houses.py; original attribution beside textures.\nreturn '+lua(data)+'\n')
 return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();_,r=convert(a.archive,a.output,not a.source_only);print(r['originalTriangles'],r['processedTriangles'])
