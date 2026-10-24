#!/usr/bin/env python3
"""Genuine HGSS Mart with explicit native right-portal/left-sign adaptation."""
import argparse,copy,hashlib,json,xml.etree.ElementTree as ET
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_oras_grass import NS,lua
from import_scenery_models import normalize
from scenery_closures import hull
ID='hgss_kanto_mart';URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592881/'
def close_mart(parts):
 source=next(p for p in parts if p['texture']=='gs_fs_a.png'and min(v[0]for v in p['vertices'])<0 and len(p['vertices'])//3==94);out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 wall=part('rear_wall')
 for lo,hi,uv in[(2,28,[(-.0166016,1.96875),(-.0166016,1.484375)]),(28,32,[(.984375,.4550781),(.984375,.375)]),(32,39.84766,[(-.015625,.359375),(-.015625,.265625)])]:
  poly(wall,[(-30,lo,-21),(32,lo,-21),(32,hi,-21),(-30,hi,-21)],[uv[0],uv[0],uv[1],uv[1]])
 roof=part('rear_roof_returns');edge=[(-32,-23),(-26,-29),(28,-29),(34,-23)]
 for a,b in zip(edge,edge[1:]):poly(roof,[(a[0],39.84766,a[1]),(b[0],39.84766,b[1]),(b[0],51.55078,b[1]),(a[0],51.55078,a[1])],[(.3125,.234375),(.3125,.234375),(.3125,.015625),(.3125,.015625)])
 soffit=part('roof_soffit');outline=[(-32,-23),(-26,-29),(28,-29),(34,-23),(34,9),(28,15),(-26,15),(-32,9)];poly(soffit,[(x,39.84766,z)for x,z in reversed(outline)],[(.140625,.234375)]*len(outline))
 base=part('closed_foundation');outline=hull([v for p in parts if p['role']!='source_door'and min(v[0]for v in p['vertices'])<0 for v in p['vertices']if abs(v[1]-2)<1e-6]);poly(base,[(x,1.95,z)for x,z in reversed(outline)],[(-.0166016,1.96875)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];poly(base,[(a[0],1.95,a[1]),(b[0],1.95,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(-.0166016,1.96875)]*4)
 pole=[(39.73633,13),(42,10.73633),(44.26367,13),(42,15.26367)]
 foot=part('sign_foot');poly(foot,[(x,1.95,z)for x,z in reversed(pole)],[(-.453125,.984375)]*4)
 neck=part('sign_neck')
 for i,a in enumerate(pole):
  b=pole[(i+1)%len(pole)]
  for p,lo,hi in[(foot,1.95,2),(neck,53,54)]:poly(p,[(a[0],lo,a[1]),(b[0],lo,b[1]),(b[0],hi,b[1]),(a[0],hi,a[1])],[(-.984375,.984375)]*4)
 return out

def adapt(parts):
 window_faces=0
 for p in parts:
  if p['role']=='source_door':
   for v in p['vertices']:v[0]+=20
  elif min(v[0]for v in p['vertices'])>25:
   for v in p['vertices']:v[0]-=56;v[2]+=5
  else:
   for i in range(0,len(p['vertices']),3):
    face=p['vertices'][i:i+3]
    if not p.get('authored')and all(6-1e-6<=v[0]<=22+1e-6 and 14-1e-6<=v[1]<=28+1e-6 and abs(v[2]-13)<1e-6 for v in face):
     for v in face:v[0]-=26
     window_faces+=1
    else:
     for v in face:v[0]=2-v[0]
     p['vertices'][i:i+3]=list(reversed(face))
 assert window_faces==2,'unreviewed source window topology'
 return window_faces

def convert(archive,output):
 blob=archive.read_bytes();items,repairs=archive_items(blob);source=next(k for k in items if k.endswith('.dae'));raw=items[source];r=ET.fromstring(raw);mesh=r.find(".//c:geometry[@id='fs_006-mesh']/c:mesh",NS);lighting=[]
 for s in mesh.findall('c:source',NS):
  if 'color'in(s.get('id')or'').lower():
   a=s.find('c:float_array',NS);stride=int(s.find('c:technique_common/c:accessor',NS).get('stride'));values=list(map(float,a.text.split()));colors=[values[i:i+stride]for i in range(0,len(values),stride)];gray=[c for c in colors if c!=[1,1,1,1]]
   assert len(gray)==18 and all(all(abs(c[i]-.7098039)<1e-7 for i in range(3))and c[3]==1 for c in gray),'unreviewed source vertex paint';lighting.append({'source':s.get('id'),'neutralGrayVertices':18,'originalRGBA':[.7098039,.7098039,.7098039,1],'processedRGBA':[1,1,1,1],'reason':'Six fascia triangles carry baked directional neutral-gray light; renderer owns live lighting.'});a.text=' '.join('1'for _ in values)
 parts=extract(ET.tostring(r),{ID:'fs_006-mesh'},{ID:('p_door_020-mesh',[-9,.5,13])})[ID];original=copy.deepcopy(parts);parts=[p for p in parts if p['role']!='source_shading'];parts.extend(close_mart(parts));window_faces=adapt(parts);meta=normalize(parts);original_meta=normalize(original);names={PurePosixPath(k).name:k for k in items};folder=output/'assets/scenery/hgss-mart';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];b=items[names[name]];(folder/name).write_bytes(b);textures[name]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)};p['texture']='assets/scenery/hgss-mart/'+name
 anchors={'door':[(v-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i,v in enumerate([11,2,13])]};data={ID:{'parts':[p for p in parts if p['role']!='source_door'],'doorParts':[p for p in parts if p['role']=='source_door'],'anchors':anchors,'bounds':meta['bounds']}}
 report={'asset':592881,'sourcePage':URL,'game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(blob).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'fs_006-mesh','doorGeometry':'p_door_020-mesh','originalDoorOffset':[-9,.5,13],'containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'vertexLightingRemoved':lighting,'authoredRearRoofUV':{'u':.3125,'vBottom':.234375,'vTop':.015625,'reason':'Continue the original front fascia blue/orange bands around the measured rear cut, without changing any source UV.'},'nativeAdaptation':{'body':'Reflect unlettered symmetric structural body about sourceX1 to exchange doorway/window bays; reverse triangle order to retain outward orientation. Roof and wall proportions retained.','window':'Translate original2 window faces−26X without reflecting image/UV orientation.','door':'Translate complete original panel+20X without reflecting original handle/UVs.','sign':'Translate original complete sign−56X,+5Z; source glyph/UVs/height/shape unchanged. It remains freestanding, forward of the wall and inside native blocked bounds.'},'closure':'Measured rear siding/roof cuts/soffit, recessed body/pole undersides,1-source-unit neck continuing original pole to board bottom; source roof/window/sign/door retained, source shadow overlays excluded.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/HGSSMartData.lua').write_text('-- Generated by tools/import_hgss_mart.py; explicit native portal adaptation and source attribution beside textures.\nreturn '+lua(data)+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args();r=convert(a.archive,a.output);print(ID,r['originalTriangles'],r['processedTriangles'])
