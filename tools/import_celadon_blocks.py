#!/usr/bin/env python3
"""Import the genuine HGSS Celadon two-storey balcony block with closed cuts."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from scenery_closures import hull
ID='hgss_celadon_balcony_block'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592831/'
def close_block(parts):
 source=next(p for p in parts if p['texture']=='ta_h02.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 t=(57.35547-3.917969)/(65.32422-3.917969);mx=20.62109+(20.58984-20.62109)*t;mz=-18.93359+(-19.16797+18.93359)*t
 wall=part('rear_siding')
 poly(wall,[(-20.62109,3.917969,-18.93359),(20.62109,3.917969,-18.93359),(mx,57.35547,mz),(-mx,57.35547,mz)],[(.6894531,.4638672),(.6894531,.4638672),(.6894531,.0078125),(.6894531,.0078125)])
 poly(wall,[(-mx,57.35547,mz),(mx,57.35547,mz),(20.58984,65.32422,-19.16797),(-20.58984,65.32422,-19.16797)],[(.6894531,.0078125)]*4)
 chamfers=part('rear_chamfer_returns')
 for sign in [-1,1]:
  poly(chamfers,[(sign*28.53125,3.917969,-14.64062),(sign*20.62109,3.917969,-18.93359),(sign*mx,57.35547,mz),(sign*28.53125,57.35547,-14.46875)],[(.6894531,.4638672),(.6894531,.4638672),(.6894531,.0078125),(.6894531,.0078125)])
 cap=part('rear_barrel_cut');profile=[(-20.58984,65.32422,-19.16797),(-16.75,70.65625,-19.16797),(-9.578125,74.47266,-19.16797),(0,75.64063,-19.15625),(9.578125,74.47266,-19.16797),(16.75,70.65625,-19.16797),(20.58984,65.32422,-19.16797)]
 poly(cap,profile,[(.671875,.4257812)]*len(profile))
 eave=part('rear_eave_return');upper=[(-31.62891,58.39844,-17.4375),(-26.87109,58.40234,-24.17188),(0,58.40234,-24.57422),(26.87109,58.40234,-24.17188),(31.62891,58.39844,-17.4375)];lower=[(-31.60547,50.44922,-17.42969),(-26.87109,50.44922,-24.17188),(0,50.44922,-24.57422),(26.87109,50.44922,-24.17188),(31.60547,50.44922,-17.42969)]
 for i in range(4):poly(eave,[upper[i],upper[i+1],lower[i+1],lower[i]],[(.4013672,1.8134766),(.4013672,1.8134766),(.4013672,1.9609375),(.4013672,1.9609375)])
 soffit=part('eave_soffit');outline=hull([v for p in parts for v in p['vertices']if abs(v[1]-50.44922)<1e-5]+[list(v)for v in lower]);poly(soffit,[(x,50.44922,z)for x,z in reversed(outline)],[(.4013672,1.9609375)]*len(outline))
 balconies=part('balcony_undersides')
 for low,high in[(7.410156,7.414062),(39.41016,39.41406)]:
  points=[v for p in parts for v in p['vertices']if low-1e-5<=v[1]<=high+1e-5];outline=hull(points)
  poly(balconies,[(x,low,z)for x,z in reversed(outline)],[(.296875,1.7412109)]*len(outline))
 base=part('closed_foundation');outline=hull([v for p in parts for v in p['vertices']if abs(v[1]-3.917969)<1e-6]);bottom=3.867969
 poly(base,[(x,bottom,z)for x,z in reversed(outline)],[(.671875,.4257812)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];poly(base,[(a[0],bottom,a[1]),(b[0],bottom,b[1]),(b[0],3.917969,b[1]),(a[0],3.917969,a[1])],[(.671875,.4257812)]*4)
 return out

def convert(archive,output):
 blob=archive.read_bytes();items,repairs=archive_items(blob);source=next(k for k in items if k.endswith('.dae'));raw=items[source];parts=extract(raw,{ID:'ta_h02-mesh'},{})[ID];original=copy.deepcopy(parts);parts=[p for p in parts if p['role']!='source_shading'and p['texture']!='h_kage.png'];parts.extend(close_block(parts));meta=normalize(parts);original_meta=normalize(original);names={PurePosixPath(k).name:k for k in items};folder=output/'assets/scenery/celadon-blocks';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];b=items[names[name]];(folder/name).write_bytes(b);textures[name]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)};p['texture']='assets/scenery/celadon-blocks/'+name
 report={'asset':592831,'sourcePage':URL,'game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(blob).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'ta_h02-mesh','containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'entrance':'Original nonenterable two-storey balcony block; no doorway or roof vent invented.','closure':'Measured rear siding/chamfers/barrel cut/eave return, eave and balcony undersides, recessed foundation. Original physical geometry, balconies/windows/roof, UVs and PNG bytes retained; source shadow triangles excluded.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/CeladonBlockData.lua').write_text('-- Generated by tools/import_celadon_blocks.py; original attribution beside textures.\nreturn '+lua({ID:{'parts':parts,'bounds':meta['bounds']}})+'\n');return report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args();r=convert(a.archive,a.output);print(ID,r['originalTriangles'],r['processedTriangles'])
