#!/usr/bin/env python3
"""Adapt the actual HGSS Pewter Museum to the two native FR/LG portals.

Original town/flowers/actors stay out. Adapted hall/wing coordinates, portal
cutouts and authored closure faces are explicit and recorded in provenance.
"""
import argparse,copy,hashlib,json
from pathlib import Path,PurePosixPath
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_scenery_models import normalize
from import_oras_grass import lua
ID='hgss_pewter_museum';URL='https://models.spriters-resource.com/ds_dsi/pokemonheartgoldsoulsilver/asset/592849/'
MASK=[(.25,.25,175.75,95.75),(175.75,32.25,255.75,79.75),(64.25,95.75,111.75,111.75)]
SX=175.5/182
WING_X0=88+86*SX
WY=(47.5/44.17188)
MAIN_Z_KNOTS=[(-62.78906,.25),(16,88),(25.38281,95.75),(48,110)]
def main_z(z):
 knots=MAIN_Z_KNOTS
 for a,b in zip(knots,knots[1:]):
  if z<=b[0]:return a[1]+(z-a[0])*(b[1]-a[1])/(b[0]-a[0])
 a,b=knots[-2:];return b[1]+(z-b[0])*(b[1]-a[1])/(b[0]-a[0])
def wing_z(z):return 32.25+(z+55.4375)*WY
def xmap(x):return 88+x*SX if x<=86 else WING_X0+(x-86)*(255.75-WING_X0)/66

def clip(poly,axis,bound,above):
 out=[]
 for a,b in zip(poly,poly[1:]+poly[:1]):
  aa=(a[axis]>=bound-1e-8)if above else(a[axis]<=bound+1e-8);bb=(b[axis]>=bound-1e-8)if above else(b[axis]<=bound+1e-8)
  if aa:out.append(a)
  if aa!=bb:
   t=(bound-a[axis])/(b[axis]-a[axis]);out.append([a[i]+(b[i]-a[i])*t for i in range(len(a))])
 return out

def rect(poly,axes,bounds):
 for axis,bound,above in [(axes[0],bounds[0],True),(axes[1],bounds[1],True),(axes[0],bounds[2],False),(axes[1],bounds[3],False)]:
  if not poly:return []
  poly=clip(poly,axis,bound,above)
 return poly

def emit(out,poly):
 if len(poly)<3:return
 for i in range(1,len(poly)-1):
  a,b,c=poly[0],poly[i],poly[i+1];u=[b[j]-a[j]for j in range(3)];v=[c[j]-a[j]for j in range(3)];cross=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
  if sum(x*x for x in cross)>1e-12:out.extend([a,b,c])

def subtract(poly,axes,bounds):
 # Four disjoint outside regions preserve original UVs around a true aperture.
 a,b=axes;l,n,r,f=bounds
 out=[]
 emit(out,clip(poly,a,l,False));emit(out,clip(poly,a,r,True))
 mid=clip(clip(poly,a,l,True),a,r,False)
 if mid:emit(out,clip(mid,b,n,False));emit(out,clip(mid,b,f,True))
 return out

def adapt(parts):
 out=[];counts={'main':0,'wing':0,'portalCuts':0,'shadowTrianglesBefore':0,'shadowTrianglesAfter':0}
 for source in parts:
  groups={}
  for i in range(0,len(source['vertices']),3):
   tri=source['vertices'][i:i+3]
   wing=max(v[0]for v in tri)>91.001 or(all(v[0]>=85.999 for v in tri)and max(v[2]for v in tri)<=-15.999 and max(v[1]for v in tri)<=64.001)
   zone='wing'if wing else'main'
   p=groups.get(zone)
   if p is None:p={k:copy.deepcopy(v)for k,v in source.items()if k!='vertices'};p['name']+=':'+zone;p['vertices']=[];groups[zone]=p
   transformed=[]
   for v in tri:
    x,y,z=xmap(v[0])if wing else 88+v[0]*SX,(v[1]-.95)*SX,wing_z(v[2])if wing else main_z(v[2])
    # Widen only the arch piers around the original one-cell native portal.
    # The original Museum badge remains rigid and centered.
    portal=not wing and abs(v[0])<=24.001 and v[2]>=15.999 and v[1]<=56.001 and 'mm10'not in source['material']
    if portal:
     knots=[(-24,88-24*SX),(-15.86719,80),(15.86719,96),(24,88+24*SX)]
     for a,b in zip(knots,knots[1:]):
      if v[0]<=b[0]:x=a[1]+(v[0]-a[0])*(b[1]-a[1])/(b[0]-a[0]);break
    transformed.append([x,y,z]+v[3:])
   if 'kage'in source['material']:
    p['role']='ground_shadow';counts['shadowTrianglesBefore']+=1
    for bounds in MASK:emit(p['vertices'],rect(transformed,(0,2),bounds))
   else:
    counts['wing'if wing else'main']+=1
    # Remove the old middle-window strip, including its inset surface, where
    # the native Museum's staff entrance must remain accessible.
    if wing and min(v[2]for v in tri)>=-17.001 and max(v[2]for v in tri)<=-15.999 and min(v[1]for v in tri)<32.001:
     before=len(p['vertices']);p['vertices'].extend(subtract(transformed,(0,1),(203.5,(2-.95)*SX,224,(32-.95)*SX)));counts['portalCuts']+=len(p['vertices'])!=before+3
    else:p['vertices'].extend(transformed)
  out.extend(p for p in groups.values()if p['vertices'])
 counts['shadowTrianglesAfter']=sum(len(p['vertices'])//3 for p in out if p['role']=='ground_shadow')
 return out,counts

def authored():
 out=[];floor=(2-.95)*SX
 def part(name,texture):
  p={'name':'authored_'+name,'material':texture[:-4],'texture':texture,'diffuse':[1,1,1],'opacity':1.,'wrapS':'repeat','wrapT':'repeat','role':'structure','alphaMode':'cutout','authored':True,'vertices':[]};out.append(p);return p
 def poly(p,points,uv=None):emit(p['vertices'],[list(v)+list((uv or[(.5625,.5625)]*len(points))[i])+[1.]for i,v in enumerate(points)])
 def quad(p,a,b,c,d,uv=None):poly(p,[a,b,c,d],uv)
 wall=part('rear_walls','nbc_mm05.png')
 # Actual body ends: original main wall z-48, wing wall z-52.
 for l,r,z,h in [(88-86*SX,88+86*SX,main_z(-48),(48-.95)*SX),(WING_X0,xmap(149.4922),wing_z(-52),(48-.95)*SX)]:
  quad(wall,(l,floor,z),(r,floor,z),(r,h,z),(l,h,z),[(0,1),((r-l)/(14*SX),1),((r-l)/(14*SX),0),(0,0)])
 # A closed source-material roof cut follows each measured original inner
 # pitch profile, plus a flat soffit at the native body ceiling.
 cap=part('roof_endcaps','nbc_mm07.png')
 def gable(x,profile,bottom,zfn):
  for (z0,h0),(z1,h1) in zip(profile,profile[1:]):
   quad(cap,(x,(bottom-.95)*SX,zfn(z0)),(x,(bottom-.95)*SX,zfn(z1)),(x,(h1-.95)*SX,zfn(z1)),(x,(h0-.95)*SX,zfn(z0)))
 for side in(-1,1):
  gable(88+side*(91*SX-.025),[(-59.45312,49.39062),(-20,74.74219),(22.04688,49.39062)],48,main_z)
  gable(88+side*(77.625*SX-.025),[(-49.60156,65.71094),(-20.02344,83.52344),(9.554688,65.71094)],65.71094,main_z)
 for x in(WING_X0+.025,xmap(152)-.025):
  gable(x,[(-53.09375,46.23437),(-34,58.53125),(-13.60937,46.23437)],46.23437,wing_z)
 soffit=part('roof_soffits_returns','nbc_mm07.png')
 for l,r,n,f,h in [(.25,175.75,.25,main_z(22.04688),(48-.95)*SX),(88-77.625*SX,88+77.625*SX,main_z(-49.60156),main_z(9.554688),(65.71094-.95)*SX),(WING_X0,xmap(152),wing_z(-53.09375),wing_z(-13.60937),(46.23437-.95)*SX)]:
  quad(soffit,(l,h,n),(r,h,n),(r,h,f),(l,h,f))
 # The original rear fascia profiles have an omitted underside return.
 for l,r,za,ya,zb,yb,zfn in [(88-91*SX,88+91*SX,-62.78906,55.16406,-59.45312,49.39062,main_z),(88-77.625*SX,88+77.625*SX,-51.94531,77.26563,-49.60156,73.21094,main_z),(WING_X0,xmap(152),-55.4375,50.29687,-53.09375,46.23437,wing_z)]:
  quad(soffit,(l,(ya-.95)*SX,zfn(za)),(r,(ya-.95)*SX,zfn(za)),(r,(yb-.95)*SX,zfn(zb)),(l,(yb-.95)*SX,zfn(zb)))
 # Source body/soffit joins and the upper rear clerestory continue flat.
 for l,r,z,lo,hi in [(88-91*SX,88+91*SX,main_z(22.04688),48,49.39062),(88-77.625*SX,88+77.625*SX,main_z(-49.60156),65.71094,73.21094)]:
  quad(soffit,(l,(lo-.95)*SX,z),(r,(lo-.95)*SX,z),(r,(hi-.95)*SX,z),(l,(hi-.95)*SX,z))
 # Native staff portal replaces a window strip. Source palette, true
 # 4px recess, continuous flat wall and original upper crown are retained.
 p=part('native_staff_portal_wall','nbc_mm05.png');z=wing_z(-16);top=floor+24*SX;head=(32-.95)*SX
 for l,r,lo,hi in [(203.5,209,floor,head),(223,224,floor,head),(209,223,top,head)]:
  quad(p,(l,hi,z),(r,hi,z),(r,lo,z),(l,lo,z),[(0,0),((r-l)/14,0),((r-l)/14,(hi-lo)/(30*SX)),(0,(hi-lo)/(30*SX))])
 recess=part('native_staff_portal_recess','nbc_mm07.png')
 quad(recess,(209,top,z-4),(223,top,z-4),(223,floor,z-4),(209,floor,z-4))
 quad(recess,(209,top,z),(209,top,z-4),(209,floor,z-4),(209,floor,z))
 quad(recess,(223,top,z-4),(223,top,z),(223,floor,z),(223,floor,z-4))
 quad(recess,(209,top,z-4),(209,top,z),(223,top,z),(223,top,z-4))
 quad(recess,(209,floor,z),(209,floor,z-4),(223,floor,z-4),(223,floor,z))
 # Thin closed foundations stay inside the original body bases. Their top
 # matches source wall feet; bottom lies below the original source shadow.
 bottom=part('closed_foundations','nbc_mm07.png')
 for l,r,n,f in [(88-86*SX,88+86*SX,main_z(-48),main_z(16)),(WING_X0,xmap(149.4922),wing_z(-52),wing_z(-16)),(88-24*SX,88+24*SX,main_z(16),main_z(48))]:
  quad(bottom,(l,0,f),(r,0,f),(r,0,n),(l,0,n))
  for a,b in [((l,n),(r,n)),((r,n),(r,f)),((r,f),(l,f)),((l,f),(l,n))]:quad(bottom,(a[0],0,a[1]),(b[0],0,b[1]),(b[0],floor,b[1]),(a[0],floor,a[1]))
 return out

def convert(archive,output):
 rawzip=archive.read_bytes();items,repairs=archive_items(rawzip);source=next(n for n in items if n.endswith('.dae'));raw=items[source]
 original=extract(raw,{ID:'nbc_msem_001-mesh'},{} )[ID];parts,adaptation=adapt(original);parts.extend(authored());meta=normalize(parts);origmeta=normalize(copy.deepcopy(original));names={PurePosixPath(n).name:n for n in items};dest=output/'assets/scenery/pewter-museum';dest.mkdir(parents=True,exist_ok=True);textures={}
 for p in parts:
  name=PurePosixPath(p['texture']).name;content=items[names[name]];(dest/name).write_bytes(content);textures[name]={'sha256':hashlib.sha256(content).hexdigest(),'bytes':len(content)};p['texture']='assets/scenery/pewter-museum/'+name
 anchors={key:[(v[i]-meta['sourceOrigin'][i])/meta['sourceUnitSpan']for i in range(3)]for key,v in {'door':[88,(2-.95)*SX,110],'eastDoor':[216,(2-.95)*SX,wing_z(-16)]}.items()}
 data={ID:{'parts':parts,'bounds':meta['bounds'],'anchors':anchors}}
 report={'asset':592849,'sourcePage':URL,'title':'Pewter Museum from Pewter City','author':'Kuramapika1','submitted':'2026-09-01','game':'Pokémon HeartGold / SoulSilver','originalGameArt':'Nintendo / Creatures / GAME FREAK','sourceFile':source,'geometry':'nbc_msem_001-mesh','archiveSha256':hashlib.sha256(rawzip).hexdigest(),'sourceModelSha256':hashlib.sha256(raw).hexdigest(),'containerRepairs':repairs,'originalSourceBounds':origmeta['sourceBounds'],'normalization':meta,'adaptation':adaptation,'nativeMask':MASK,'textures':textures,'parts':[{'name':p['name'],'material':p['material'],'role':p['role'],'opacity':p['opacity'],'authored':p.get('authored',False),'triangles':p['triangles']}for p in parts]}
 report['adaptation'].update({
  'originalTriangles':sum(len(p['vertices'])//3 for p in original),
  'finalTriangles':sum(p['triangles']for p in parts),
  'mainScaleXY':SX,'mainXOrigin':88,'mainZKnots':MAIN_Z_KNOTS,
  'wingSourceBoundsXZ':[86,-55.4375,152,-11.26562],
  'wingTargetBoundsXZ':[WING_X0,32.25,255.75,79.75],
  'sourceYOrigin':.95,'mainOpeningX':[80,96],
  'staffOpening':{'x':[209,223],'facadeZ':wing_z(-16),'height':24*SX,'recess':4},
  'edits':['Move and resize original east wing into native blocked side body.',
   'Compress original main arch aperture to its original one-cell native warp.',
   'Replace middle wing window strip with recessed native staff portal using source wall/trim palette.',
   'Clip flat source shadows to native blocked mask with interpolated original UVs.',
   'Close measured rear, gable, soffit and bottom cuts with source wall/trim textures.'],
  'textureEdits':False})
 (dest/'provenance.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n');(output/'lib/PewterMuseumData.lua').write_text('-- Generated by tools/import_pewter_museum.py; explicit native adaptation/provenance beside textures.\nreturn '+lua(data)+'\n');return data,report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archive',type=Path);p.add_argument('output',type=Path);a=p.parse_args();_,r=convert(a.archive,a.output);print(r['adaptation'],sum(p['triangles']for p in r['parts']))
