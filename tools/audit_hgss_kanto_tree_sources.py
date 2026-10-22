#!/usr/bin/env python3
"""Audit local HGSS town tree identity without promoting source cards to models."""
import argparse,hashlib,json
from pathlib import Path,PurePosixPath
import xml.etree.ElementTree as ET
from import_hgss_center import archive_items
from import_pallet_buildings import extract
from import_route104_tree import components
from import_scenery_models import NS

def inspect(path):
 rawzip=path.read_bytes();items,repairs=archive_items(rawzip)
 source=next(n for n in items if n.lower().endswith('.dae'));raw=items[source];root=ET.fromstring(raw)
 selection={g.get('id'):g.get('id')for g in root.findall('.//c:library_geometries/c:geometry',NS)
  if g.get('id').lower().startswith(('map','tree'))}
 entries=[]
 for geometry,parts in extract(raw,selection,{}).items():
  for p in parts:
   if not(p['texture']and PurePosixPath(p['texture']).name.lower().startswith('tree')):continue
   vs=p['vertices'];cs=components(vs)
   entries.append({'geometry':geometry,'material':p['material'],'texture':p['texture'],
    'triangles':len(vs)//3,'connectedComponents':len(cs),
    'componentTriangles':sorted({len(c)//3 for c in cs}),
    'sourceYLevels':sorted({round(v[1],6)for v in vs}),
    'opacity':p['opacity'],'alphaMode':p['alphaMode']})
 textures={PurePosixPath(n).name:{'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}
  for n,data in items.items()if PurePosixPath(n).name.lower().startswith('tree')and n.lower().endswith('.png')}
 return{'archiveSha256':hashlib.sha256(rawzip).hexdigest(),'source':source,
  'sourceSha256':hashlib.sha256(raw).hexdigest(),'containerRepairs':repairs,
  'textures':textures,'parts':entries,
  'decision':'Town canopy/rear are sloped cards and underside is a repeated flat sheet; these are not complete volumetric replacement trees.'}

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('archives',type=Path,nargs='+');p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 report={path.stem:inspect(path)for path in a.archives};a.output.write_text(json.dumps(report,indent=2)+'\n')
