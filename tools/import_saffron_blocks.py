#!/usr/bin/env python3
"""Import matching two/three-storey HGSS Saffron nonenterable blocks."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from scenery_closures import hull
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592877/'
SPECS={'hgss_saffron_ordinary_block':'ybc_h03-mesh','hgss_saffron_tall_block':'ybc_h04-mesh'}
def profile_triangles(points):
 # Ear-clip the measured concave barrel steps. A fan would cross its shallow
 # notches, adding overlapping triangles outside the original roof profile.
 def cross(a,b,c):return(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
 winding=1 if sum(a[0]*b[1]-b[0]*a[1]for a,b in zip(points,points[1:]+points[:1]))>0 else-1
 remaining=list(range(len(points)));result=[]
 def inside(p,a,b,c):return all(winding*cross(x,y,p)>=-1e-8 for x,y in[(a,b),(b,c),(c,a)])
 while len(remaining)>3:
  for i,b in enumerate(remaining):
   a,c=remaining[i-1],remaining[(i+1)%len(remaining)]
   if winding*cross(points[a],points[b],points[c])<=1e-8:continue
   if any(inside(points[q],points[a],points[b],points[c])for q in remaining if q not in(a,b,c)):continue
   result.append((a,b,c));remaining.pop(i);break
  else:raise ValueError('unreviewed roof profile')
 result.append(tuple(remaining));return result

def close_block(parts,tall):
 source=next(p for p in parts if p['texture']=='ybc_h1b.png');out=[]
 def part(name,base=None):
  p={k:copy.deepcopy(v)for k,v in(base or source).items()if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 def quad(p,pts,uv):poly(p,pts,uv)
 x,z,top=(35,-28,78.00781)if tall else(27,-20,52)
 # Original side-wall strip carries yellow siding and gray plinth together.
 rear=part('rear_wall');quad(rear,[(-x,2,z),(x,2,z),(x,top,z),(-x,top,z)],[(.90625,1.000976562),(.90625,1.000976562),(.90625,.4697266),(.90625,.4697266)])
 if not tall:
  roof=part('rear_barrel_roof')
  profile=[(-30.125,51),(-29.25781,52.36523),(-26.08203,53.33398),(-25.2168,54.69922),(-22.04102,55.66601),(-21.17578,57.0332),(-18,58),(18,58),(21.17578,57.0332),(22.04102,55.66601),(25.2168,54.69922),(26.08203,53.33398),(29.25781,52.36523),(30.125,51)]
  for tri in profile_triangles(profile):roof['vertices'].extend([[profile[i][0],profile[i][1],-22,.2,.3398437,1.]for i in tri])
  soffit=part('roof_soffit');quad(soffit,[(-30.125,51,-22),(-30.125,51,20),(30.125,51,20),(30.125,51,-22)],[(.2,.3398437)]*4)
 else:
  cap_source=next(p for p in parts if p['texture']=='ybc_h1c.png');fascia=part('rear_roof_fascia',cap_source)
  rear_edge=[(-36.75,-27.11328),(-34.48828,-29.375),(34.48828,-29.375),(36.75,-27.11328)]
  for a,b in zip(rear_edge,rear_edge[1:]):quad(fascia,[(a[0],78.00781,a[1]),(b[0],78.00781,b[1]),(b[0],86.40625,b[1]),(a[0],86.40625,a[1])],[(1.421875,.0273437)]*4)
  points=[v for p in parts if p['texture']=='ybc_h1c.png'for v in p['vertices']if abs(v[1]-78.00781)<1e-6]+[[a,78.00781,b]for a,b in rear_edge]
  outline=hull(points);soffit=part('roof_soffit',cap_source);poly(soffit,[(a,78.00781,b)for a,b in reversed(outline)],[(1.421875,.0273437)]*len(outline))
 low=[v for p in parts if p['role']=='structure'for v in p['vertices']if abs(v[1]-2)<1e-6];outline=hull(low);base=part('closed_foundation')
 poly(base,[(a,1.95,b)for a,b in reversed(outline)],[(.90625,.99)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];quad(base,[(a[0],1.95,a[1]),(b[0],1.95,b[1]),(b[0],2,b[1]),(a[0],2,a[1])],[(.90625,.99)]*4)
 return out

def convert(archive,output,closed=True):
 rawzip=archive.read_bytes();items,repairs=archive_items(rawzip);source=next(n for n in items if n.endswith('.dae'));raw=items[source];names={PurePosixPath(n).name:n for n in items};data={};reports={}
 for key,gid in SPECS.items():
  parts=extract(raw,{key:gid},{})[key];original=copy.deepcopy(parts);parts=[p for p in parts if p['role']!='source_shading']
  if closed:parts.extend(close_block(parts,key.endswith('tall_block')))
  meta=normalize(parts);original_meta=normalize(original);folder=output/'assets/scenery/saffron-blocks'/key;folder.mkdir(parents=True,exist_ok=True);textures={}
  for p in parts:
   name=p['texture'];content=items[names[name]];(folder/name).write_bytes(content);textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)};p['texture']='assets/scenery/saffron-blocks/'+key+'/'+name
  data[key]={'parts':parts,'bounds':meta['bounds']}
  report={'asset':592877,'sourcePage':URL,'title':'Saffron '+('three-storey block'if key.endswith('tall_block')else'two-storey block'),'game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':gid,'entrance':'Original nonenterable building; no source door or native entrance invented.','containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'closure':'Measured side-wall siding/plinth across missing rear, original barrel/flat roof cut with soffit, recessed underside cap. Source front/windows/rooftop fixtures/geometry/UVs/PNG bytes retained; source shading excluded.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
  (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');reports[key]=report
 (output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/SaffronBlockData.lua').write_text('-- Generated by tools/import_saffron_blocks.py; original attribution beside textures.\nreturn '+lua(data)+'\n');return data,reports
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();_,r=convert(a.archive,a.output,not a.source_only)
 for k,v in r.items():print(k,v['originalTriangles'],v['processedTriangles'])
