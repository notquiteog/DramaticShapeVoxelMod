#!/usr/bin/env python3
"""Original HGSS Celadon single-floor house, closed cuts and separate HD2D flowers."""
import argparse,copy,hashlib,json,math
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_route104_tree import components,bounds
from import_oras_grass import lua
from scenery_closures import hull
ID='hgss_celadon_short_house'
URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592831/'
def separate(parts):
 source=next(p for p in parts if p['texture']=='ta_h01.png');groups=components(source['vertices']);assert len(groups)==16
 cards=[groups[i]for i in (6,8,9,11,12,13,14,15)]
 assert sum(len(c)//3 for c in cards)==24
 assert all(bounds(c)[1]>=12 and bounds(c)[2]>=18 for c in cards)
 source['vertices']=[v for i,c in enumerate(groups)if i not in(6,8,9,11,12,13,14,15)for v in c]
 return cards

def close_house(parts):
 source=next(p for p in parts if p['texture']=='ta_h01.png');out=[]
 def part(name):
  p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p.update(name='authored_'+name,vertices=[],authored=True,role='structure');out.append(p);return p
 def poly(p,pts,uv):
  for i in range(1,len(pts)-1):p['vertices'].extend([list(pts[j])+list(uv[j])+[1.]for j in(0,i,i+1)])
 # Original asymmetric roof: follow its actual lower/upper rear profile.
 xs=[-35.19922,-8.082032,35.19922];low=[27.90039,45.90039,45.90039];high=[38.69922,56.80078,56.80078]
 fascia=part('rear_roof_fascia')
 for i in range(2):poly(fascia,[(xs[i],low[i],-30.40039),(xs[i+1],low[i+1],-30.40039),(xs[i+1],high[i+1],-30.40039),(xs[i],high[i],-30.40039)],[(.875,.015625)]*4)
 def rearZ(x):return -19.76172+(-23.64649+19.76172)*(x+32)/(34.02539+32)
 # The source owns no roof underside: emit the measured lower edge once.
 soffit=part('roof_soffit');quads=[
  [(-35.19922,27.90039,-30.40039),(-8.082032,45.90039,-30.40039),(-8.082032,46.09961,20.31836),(-35.19922,28.50195,20.23828)],
  [(-8.082032,45.90039,-30.40039),(35.19922,45.90039,-30.40039),(35.19922,45.84961,20.23828),(-8.082032,46.09961,20.31836)],
  [(-35.19922,28.50195,20.23828),(-8.082032,46.09961,20.31836),(-8.082032,46.40039,30.40039),(-35.19922,28.40039,30.40039)]]
 triangles=[]
 for q in quads:
  poly(soffit,q,[(.875,.015625)]*4)
  triangles.extend([[q[i]for i in t]for t in((0,1,2),(0,2,3))])
 def cross(a,b):return a[0]*b[1]-a[1]*b[0]
 def ceiling(x,z):
  for a,b,c in triangles:
   den=cross((b[0]-a[0],b[2]-a[2]),(c[0]-a[0],c[2]-a[2]))
   u=cross((x-a[0],z-a[2]),(c[0]-a[0],c[2]-a[2]))/den
   v=cross((b[0]-a[0],b[2]-a[2]),(x-a[0],z-a[2]))/den
   if u>=-1e-7 and v>=-1e-7 and u+v<=1+1e-7:return a[1]+u*(b[1]-a[1])+v*(c[1]-a[1])
  raise ValueError('rear wall exceeds measured soffit')
 # Split where the rear wall crosses any underside triangle edge, so its
 # entire top meets the actual triangulated ceiling, including the roof kink.
 cuts={-32.,34.02539};p=(-32.,rearZ(-32.));r=(66.02539,rearZ(34.02539)-p[1])
 for t in triangles:
  for a,b in zip(t,t[1:]+t[:1]):
   q=(a[0],a[2]);d=(b[0]-a[0],b[2]-a[2]);den=cross(r,d)
   if abs(den)<1e-10:continue
   qp=(q[0]-p[0],q[1]-p[1]);u,v=cross(qp,d)/den,cross(qp,r)/den
   if 0<u<1 and -1e-7<=v<=1+1e-7:cuts.add(p[0]+u*r[0])
 wall=part('rear_wall');ordered=sorted(cuts);cuts=[]
 for x in ordered:
  if not cuts or x-cuts[-1]>1e-7:cuts.append(x)
 for a,b in zip(cuts,cuts[1:]):poly(wall,[(a,4,rearZ(a)),(b,4,rearZ(b)),(b,ceiling(b,rearZ(b)),rearZ(b)),(a,ceiling(a,rearZ(a)),rearZ(a))],[(.0195312,.0136719)]*4)
 base=part('closed_foundation');outline=hull([v for p in parts for v in p['vertices']if abs(v[1]-4)<1e-6]+[[a,4,rearZ(a)]for a in(-32,34.02539)])
 poly(base,[(x,3.95,z)for x,z in reversed(outline)],[(.0195312,.0136719)]*len(outline))
 for i,a in enumerate(outline):
  b=outline[(i+1)%len(outline)];poly(base,[(a[0],3.95,a[1]),(b[0],3.95,b[1]),(b[0],4,b[1]),(a[0],4,a[1])],[(.0195312,.0136719)]*4)
 return out

def convert(archive,output):
 blob=archive.read_bytes();items,repairs=archive_items(blob);name=next(n for n in items if n.endswith('.dae'));raw=items[name]
 parts=extract(raw,{ID:'ta_h01-mesh'},{})[ID];original=copy.deepcopy(parts);parts=[p for p in parts if p['role']!='source_shading'];assert sum(len(p['vertices'])//3 for p in parts)==130;cards=separate(parts);parts.extend(close_house(parts));meta=normalize(parts);origin,span=meta['sourceOrigin'],meta['sourceUnitSpan'];hd2d=[]
 for i,card in enumerate(cards):
  b=bounds(card);a=[(b[k]+b[k+3])/2 for k in range(3)];vs=[]
  for v in card:
   p=[v[0],v[1]-(v[2]-a[2])*math.tan(math.radians(30)),a[2]]
   vs.append([(p[k]-origin[k])/span for k in range(3)]+v[3:])
  hd2d.append({'name':'source_flower_card_'+str(i+1),'vertices':vs,'indices':list(range(1,len(vs)+1)),'anchor':[(a[k]-origin[k])/span for k in range(3)],'sourceBounds':b})
 folder=output/'assets/scenery/celadon-short-house';folder.mkdir(parents=True,exist_ok=True);names={PurePosixPath(k).name:k for k in items};textures={}
 for p in parts:
  n=p['texture'];png=items[names[n]];(folder/n).write_bytes(png);textures[n]={'sha256':hashlib.sha256(png).hexdigest(),'bytes':len(png)};p['texture']='assets/scenery/celadon-short-house/'+n
 data={ID:{'parts':parts,'bounds':meta['bounds'],'hd2dCards':hd2d}}
 report={'asset':592831,'sourcePage':URL,'game':'Pokémon HeartGold / SoulSilver','originalGameArt':'Nintendo / Creatures / GAME FREAK','archiveSha256':hashlib.sha256(blob).hexdigest(),'sourceFile':name,'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'geometry':'ta_h01-mesh','containerRepairs':repairs,'normalization':meta,'originalBounds':bounds([v for p in original for v in p['vertices']]),'sourceTriangles':sum(len(p['vertices'])//3 for p in original),'physicalSourceTriangles':130,'processedArchitectureTriangles':sum(p['triangles']for p in parts),'hd2dFlowers':{'cards':8,'sourceTriangles':24,'projectionPitchDegrees':30,'sourceUvRetained':True,'originalPngRetained':True},'closure':'Measured asymmetric rear fascia/siding/soffit and recessed underside. Original facade/roof/windows/planter/UVs retained; source shadows omitted. Live leaves/petals separate as flat source cards using native cylindrical billboard shader. No invented portal/sign/vent.','textures':textures,'parts':[{'name':p['name'],'role':p['role'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 (folder/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/CeladonShortHouseData.lua').write_text('-- Generated by tools/import_celadon_short_house.py; original attribution beside textures.\nreturn '+lua(data)+'\n');return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args();_,r=convert(a.archive,a.output);print(ID,r['sourceTriangles'],r['processedArchitectureTriangles'],'+',r['hd2dFlowers']['sourceTriangles'],'HD2D')
