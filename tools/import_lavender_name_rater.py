#!/usr/bin/env python3
"""Import the actual HGSS Name Rater tent from the newest Lavender source."""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
from scenery_closures import hull
ID='hgss_lavender_name_rater'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592838/'
def close_tent(parts):
 source=next(p for p in parts if p['texture']=='ko_seimei.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'}
  p.update(name='authored_'+name,vertices=[],authored=True,role='structure',alphaMode='cutout');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 def quad(p,pts,uv):poly(p,pts,uv)
 # The rear cloth follows the exact three-height side profile, including the
 # slightly asymmetric original rear coordinates. Original curtains stay open.
 rear=part('rear_tent_cloth')
 levels=[((-34.76562,2.234375,-23.82422),(34.76562,2.234375,-23.92188),.7373047),((-30.09375,11.59375,-22.53516),(30.09766,11.59375,-22.625),.6123047),((-28.02344,31.16016,-19.42969),(28.02344,31.16016,-19.35157),.3652344)]
 for lo,hi in zip(levels,levels[1:]):quad(rear,[lo[0],lo[1],hi[1],hi[0]],[(.02539062,lo[2]),(.02539062,lo[2]),(.02539062,hi[2]),(.02539062,hi[2])])
 # Extend the real stepped roof around the missing rear. The original front
 # roof's band coordinates continue over each half; no pitched box or new trim.
 roof=part('rear_tent_roof')
 rings=[(32.19141,32.28125,-21.50781,-.005859375,.2919922),(17.17188,46.89453,-15.625,.2675781,.1542969),(8.48047,59.6211,-12.5,.4023438,.0703125)]
 for lo,hi in zip(rings,rings[1:]):
  for sign in(-1,1):quad(roof,[(0,lo[1],lo[2]),(sign*lo[0],lo[1],lo[2]),(sign*hi[0],hi[1],hi[2]),(0,hi[1],hi[2])],[(.5546875,lo[4]),(lo[3],lo[4]),(hi[3],hi[4]),(.5546875,hi[4])])
 for sign in(-1,1):poly(roof,[(0,rings[-1][1],rings[-1][2]),(sign*rings[-1][0],rings[-1][1],rings[-1][2]),(0,76.375,-9.472657)],[(.5546875,.06933594),(.4023438,.0703125),(.5546875,.0029296875)])
 soffit=part('rear_eave_return');top=levels[-1]
 quad(soffit,[top[0],top[1],(32.19141,32.28125,-21.50781),(-32.19141,32.28125,-21.50781)],[(.02539062,.953125)]*4)
 # This lower cap stays physically separate from the source threshold plane;
 # only its normalized Y0 contact ring recesses below native ground.
 base=part('closed_foundation');low=[v for p in parts if p['role']=='structure'for v in p['vertices']if abs(v[1]-2.234375)<1e-6];pts=hull(low)
 poly(base,[(x,2.2,z)for x,z in reversed(pts)],[(.02539062,.7373047)]*len(pts))
 for i,a in enumerate(pts):
  b=pts[(i+1)%len(pts)];quad(base,[(a[0],2.2,a[1]),(b[0],2.2,b[1]),(b[0],2.234375,b[1]),(a[0],2.234375,a[1])],[(.02539062,.7373047)]*4)
 return out

def convert(archive,output,closed=True):
 rawzip=archive.read_bytes();items,repairs=archive_items(rawzip);source=next(n for n in items if n.endswith('.dae'));raw=items[source]
 parts=extract(raw,{ID:'ko_seimei-mesh'},{})[ID];original=copy.deepcopy(parts);parts=[p for p in parts if p['role']!='source_shading']
 if closed:parts.extend(close_tent(parts))
 meta=normalize(parts);original_meta=normalize(original);names={PurePosixPath(n).name:n for n in items};folder=output/'assets/scenery/lavender-name-rater';folder.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=p['texture'];content=items[names[name]];(folder/name).write_bytes(content);textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)};p['texture']='assets/scenery/lavender-name-rater/'+name
 anchors={'door':[(v-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i,v in enumerate([0,2.234375,5.05])]}
 data={ID:{'parts':parts,'bounds':meta['bounds'],'anchors':anchors}}
 report={'asset':592838,'sourcePage':URL,'title':'Lavender Name Rater tent','game':'Pokémon HeartGold / SoulSilver','author':'Kuramapika1','submitted':'2026-09-01','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceFile':source,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'ko_seimei-mesh','entrance':'Original open curtains and inset interior back plane; no invented hinged panel or animation. Native FR/LG entrance scripts/timing unchanged.','containerRepairs':repairs,'normalization':meta,'originalBounds':original_meta['sourceBounds'],'originalTriangles':sum(p['triangles']for p in original),'processedTriangles':sum(p['triangles']for p in parts),'closure':'Measured rear cloth at original three-height side profiles, stepped rear tent roof matching original front bands, eave return and recessed underside cap. Original front curtains, window recesses and source threshold unchanged. Source shading excluded.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/LavenderNameRaterData.lua').write_text('-- Generated by tools/import_lavender_name_rater.py; attribution beside textures.\nreturn '+lua(data)+'\n');return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);p.add_argument('--source-only',action='store_true');a=p.parse_args();_,r=convert(a.archive,a.output,not a.source_only);print(r['originalTriangles'],r['processedTriangles'])
