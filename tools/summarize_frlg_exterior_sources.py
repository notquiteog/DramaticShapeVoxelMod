#!/usr/bin/env python3
"""Summarize identifier-only native ledgers; never infer visual acceptance."""
import argparse,collections,csv,hashlib,json
from pathlib import Path
SOURCES={
 'hgss_lavender_house':'assets/scenery/lavender-house/provenance.json',
 'hgss_viridian_flower_house':'assets/scenery/viridian-house/provenance.json',
 'hgss_viridian_gym':'assets/scenery/hgss-kanto-gyms/hgss_viridian_gym/provenance.json',
 'hgss_pewter_gym':'assets/scenery/hgss-kanto-gyms/hgss_pewter_gym/provenance.json',
 'hgss_kanto_center':'assets/scenery/hgss-center/provenance.json',
 'hgss_pewter_museum':'assets/scenery/pewter-museum/provenance.json',
 'hgss_viridian_house':'assets/scenery/viridian-house/provenance.json',
 'hgss_pewter_house':'assets/scenery/pewter-house/provenance.json',
 **{k:'assets/scenery/pallet-buildings/'+k+'/provenance.json'for k in['hgss_pallet_red','hgss_pallet_rival','hgss_pallet_oak']},
}
def summarize(paths,output,accepted):
 root=Path(__file__).resolve().parents[1];sources={}
 for key,path in SOURCES.items():
  p=root/path;d=json.loads(p.read_text());sources[key]={k:d[k]for k in['sourcePage','archiveSha256']};sources[key]['modelSha256']=d.get('sourceModelSha256',d.get('sourceDaeSha256'));sources[key]['provenanceSha256']=hashlib.sha256(p.read_bytes()).hexdigest()
 counts=collections.defaultdict(lambda:collections.Counter());families=collections.defaultdict(list);rows=[]
 for path in paths:
  for line in path.read_text().splitlines():
   r=json.loads(line);assert len(r['nativeHash'])==64
   civics=[]
   for g in r['civics']:
    model=g['modernEligible'];accepted_key=(r['edition'],r['map'],g['x'],g['y'])
    q={**g,'source':sources[model]if model else None,'renderedAccepted':accepted_key in accepted}
    q['gap']=None if model else('HGSS Mart left entrance and tall east sign cannot substantially fill native64px body while preserving native right entrance; adapter pending.'if g['family']=='mart'else'Matching regional source selection and complete native adapter pending.')
    civics.append(q);families[(r['edition'],g['family'])].append((r['map'],q))
   row={k:r[k]for k in['edition','map','mapType','outdoor','pair','width','height','supported','nativeHash','unclassifiedBlockedCells']}
   row.update(scope='exterior_buildings_only',runtime='v0.3.95',inventoryOnly=True,assemblies=civics,modernEligible=sum(bool(g['modernEligible'])for g in civics),renderedAccepted=sum(g['renderedAccepted']for g in civics),unmatchedAssemblies=sum(not g['modernEligible']for g in civics))
   rows.append(row);counts[r['edition']]['maps']+=1;counts[r['edition']]['outdoor']+=bool(r['outdoor']);counts[r['edition']]['assemblies']+=len(civics);counts[r['edition']]['eligible']+=row['modernEligible'];counts[r['edition']]['accepted']+=row['renderedAccepted'];counts[r['edition']]['unmatched']+=row['unmatchedAssemblies'];counts[r['edition']]['unclassifiedBlockedCells']+=row['unclassifiedBlockedCells']
 assert len({(r['edition'],r['map'])for r in rows})==len(rows),'duplicate native map'
 for ed,summary in counts.items():assert summary['maps']==426,(ed,summary)
 output.mkdir(parents=True,exist_ok=True)
 with(output/'frlg-exterior-sources-2026-10-23.jsonl').open('w')as f:
  for r in sorted(rows,key=lambda r:(r['edition'],r['map'])):f.write(json.dumps(r,separators=(',',':'),sort_keys=True)+'\n')
 with(output/'frlg-exterior-families-2026-10-23.csv').open('w')as f:
  w=csv.writer(f,lineterminator="\n");w.writerow(['edition','family','assemblies','modern_eligible','rendered_accepted','maps','source_models','gap'])
  for(ed,family),values in sorted(families.items()):
   w.writerow([ed,family,len(values),sum(bool(g['modernEligible'])for _,g in values),sum(g['renderedAccepted']for _,g in values),'|'.join(sorted({m for m,_ in values})),'|'.join(sorted({g['modernEligible']for _,g in values if g['modernEligible']})),'|'.join(sorted({g['gap']for _,g in values if g['gap']}))])
 print(json.dumps(counts,sort_keys=True))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('ledgers',type=Path,nargs='+');p.add_argument('--output',type=Path,default=Path('docs/coverage'));p.add_argument('--accepted',type=Path,nargs='*',default=[]);a=p.parse_args()
 accepted=set()
 for path in a.accepted:
  for r in json.loads(path.read_text()):
   assert r.get('returned')and not r.get('missingAssets');accepted.add((r['edition'],r['map'],r['x'],r['y']))
 summarize(a.ledgers,a.output,accepted)
