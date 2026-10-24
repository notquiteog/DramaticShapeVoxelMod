#!/usr/bin/env python3
"""Summarize identifier-only native ledgers; never infer visual acceptance."""
import argparse,collections,csv,hashlib,json
from pathlib import Path
SOURCES={
 'hgss_vermilion_gym':'assets/scenery/hgss-kanto-gyms/hgss_vermilion_gym/provenance.json',
 'hgss_fuchsia_gym':'assets/scenery/hgss-kanto-gyms/hgss_fuchsia_gym/provenance.json',
 'hgss_celadon_short_house':'assets/scenery/celadon-short-house/provenance.json',
 'hgss_cerulean_closed_house':'assets/scenery/cerulean-closed-house/provenance.json',
 'hgss_kanto_mart':'assets/scenery/hgss-mart/provenance.json',
 'hgss_celadon_balcony_block':'assets/scenery/celadon-blocks/provenance.json',
 'hgss_saffron_dojo':'assets/scenery/saffron-dojo/provenance.json',
 'hgss_saffron_gym':'assets/scenery/hgss-kanto-gyms/hgss_saffron_gym/provenance.json',
 'hgss_saffron_ordinary_block':'assets/scenery/saffron-blocks/hgss_saffron_ordinary_block/provenance.json',
 'hgss_saffron_tall_block':'assets/scenery/saffron-blocks/hgss_saffron_tall_block/provenance.json',
 'hgss_cerulean_gym':'assets/scenery/hgss-kanto-gyms/hgss_cerulean_gym/provenance.json',
 'hgss_lavender_name_rater':'assets/scenery/lavender-name-rater/provenance.json',
 'hgss_lavender_house':'assets/scenery/lavender-house/provenance.json',
 'hgss_viridian_flower_house':'assets/scenery/viridian-house/provenance.json',
 'hgss_viridian_gym':'assets/scenery/hgss-kanto-gyms/hgss_viridian_gym/provenance.json',
 'hgss_pewter_gym':'assets/scenery/hgss-kanto-gyms/hgss_pewter_gym/provenance.json',
 'hgss_kanto_center':'assets/scenery/hgss-center/provenance.json',
 'hgss_saffron_psychic':'assets/scenery/saffron-psychic/provenance.json',
 'hgss_saffron_copycat':'assets/scenery/saffron-copycat/provenance.json',
 'hgss_pewter_museum':'assets/scenery/pewter-museum/provenance.json',
 'hgss_viridian_house':'assets/scenery/viridian-house/provenance.json',
 'hgss_pewter_house':'assets/scenery/pewter-house/provenance.json',
 **{k:'assets/scenery/pallet-buildings/'+k+'/provenance.json'for k in['hgss_pallet_red','hgss_pallet_rival','hgss_pallet_oak']},
}
def summarize(paths,output,accepted,rejected=None):
 rejected={}if rejected is None else rejected
 root=Path(__file__).resolve().parents[1];sources={}
 for key,path in SOURCES.items():
  p=root/path;d=json.loads(p.read_text());sources[key]={k:d[k]for k in['sourcePage','archiveSha256']};sources[key]['modelSha256']=d.get('sourceModelSha256',d.get('sourceDaeSha256'));sources[key]['provenanceSha256']=hashlib.sha256(p.read_bytes()).hexdigest()
 review_path=root/'docs/coverage/frlg-native-exterior-reviews-2026-10-23.json'
 reviews=json.loads(review_path.read_text())['reviews']if review_path.exists()else[]
 candidates=json.loads((root/'docs/coverage/frlg-exterior-candidates-2026-10-23.json').read_text())['candidates']
 counts=collections.defaultdict(lambda:collections.Counter());families=collections.defaultdict(list);rows=[]
 for path in paths:
  for line in path.read_text().splitlines():
   r=json.loads(line);assert len(r['nativeHash'])==64
   civics=[]
   for g in r['civics']:
    model=g['modernEligible'];accepted_key=(r['edition'],r['map'],g['x'],g['y'])
    q={**g,'source':sources[model]if model else None,'renderedAccepted':accepted_key in accepted,'renderedRuntime':accepted.get(accepted_key,{}).get('runtime','v0.3.95')if accepted_key in accepted else None}
    matched=[v for v in reviews if(v['edition'],v['map'],v['x'],v['y'])==accepted_key and v['nativeHash']==r['nativeHash']and v['sourceModel']==model and v['sourceProvenanceSha256']==sources[model]['provenanceSha256']]
    if matched:q['nativeReview']={'runtime':matched[0]['runtime'],'sourceFootprintVerified':all(v['sourceFootprintVerified']for v in matched),'portals':[{'x':v['x']+v['doorX'],'y':v['y']+v['doorY'],'destination':v['destination'],'returned':v['returned']}for v in matched]}
    if q['renderedAccepted']:
     proof=accepted[accepted_key];assert model,'accepted source must remain eligible'
     assert proof['nativeHash']==r['nativeHash'],'accepted native map hash changed'
     if proof.get('sourceModel'):assert proof['sourceModel']==model,'accepted source family changed'
    q['gap']=None if model else('Matching complete native Mart location/drawing/permission adapter pending.'if g['family']=='mart'else'Matching regional source selection and complete native adapter pending.')
    candidate=next((c for c in candidates if c['map']==r['map']and c['x']==g['x']and c['y']==g['y']),None)
    if candidate and not model:q['sourceCandidate']=candidate;q['gap']=candidate['gap']
    rejected_proof=rejected.get(accepted_key)
    if rejected_proof:
     assert rejected_proof['nativeHash']==r['nativeHash'],'rejected review native map hash changed'
     if rejected_proof.get('sourceModel'):assert rejected_proof['sourceModel']==model,'rejected review source family changed'
    q['renderedGap']=None if not model or q['renderedAccepted']else(rejected_proof['renderedGap']if rejected_proof and rejected_proof.get('renderedGap')else matched[0]['renderedGap']if matched else'Native building/warp review passed; shared native-ground donor assessment pending.'if model in('hgss_cerulean_gym','hgss_saffron_dojo')or model=='hgss_kanto_center'and r['map']in('FR_SAFFRON_CITY','FR_SAFFRON_CITY_CONNECTION')or model=='hgss_kanto_mart'and r['map']in('FR_SAFFRON_CITY','FR_SAFFRON_CITY_CONNECTION')else'Native rendered review not recorded.')
    civics.append(q);families[(r['edition'],g['family'])].append((r['map'],q))
   row={k:r[k]for k in['edition','map','mapType','outdoor','pair','width','height','supported','nativeHash','unclassifiedBlockedCells']}
   row.update(scope='exterior_buildings_only',runtime=r.get('runtime','v0.3.95'),inventoryOnly=True,assemblies=civics,modernEligible=sum(bool(g['modernEligible'])for g in civics),renderedAccepted=sum(g['renderedAccepted']for g in civics),unmatchedAssemblies=sum(not g['modernEligible']for g in civics))
   rows.append(row);counts[r['edition']]['maps']+=1;counts[r['edition']]['outdoor']+=bool(r['outdoor']);counts[r['edition']]['assemblies']+=len(civics);counts[r['edition']]['eligible']+=row['modernEligible'];counts[r['edition']]['accepted']+=row['renderedAccepted'];counts[r['edition']]['unmatched']+=row['unmatchedAssemblies'];counts[r['edition']]['unclassifiedBlockedCells']+=row['unclassifiedBlockedCells']
 assert len({(r['edition'],r['map'])for r in rows})==len(rows),'duplicate native map'
 for ed,summary in counts.items():assert summary['maps']==426,(ed,summary)
 output.mkdir(parents=True,exist_ok=True)
 with(output/'frlg-exterior-sources-2026-10-23.jsonl').open('w')as f:
  for r in sorted(rows,key=lambda r:(r['edition'],r['map'])):f.write(json.dumps(r,separators=(',',':'),sort_keys=True)+'\n')
 with(output/'frlg-exterior-families-2026-10-23.csv').open('w')as f:
  w=csv.writer(f,lineterminator="\n");w.writerow(['edition','family','assemblies','modern_eligible','rendered_accepted','maps','source_models','gap','rendered_gap'])
  for(ed,family),values in sorted(families.items()):
   w.writerow([ed,family,len(values),sum(bool(g['modernEligible'])for _,g in values),sum(g['renderedAccepted']for _,g in values),'|'.join(sorted({m for m,_ in values})),'|'.join(sorted({g['modernEligible']for _,g in values if g['modernEligible']})),'|'.join(sorted({g['gap']for _,g in values if g['gap']})),'|'.join(sorted({g['renderedGap']for _,g in values if g['renderedGap']}))])
 print(json.dumps(counts,sort_keys=True))
def load_reviews(paths):
 accepted={};rejected={}
 for path in paths:
  for r in json.loads(path.read_text()):
   assert not r.get('missingAssets'),'fallback cannot be rendered acceptance'
   key=(r['edition'],r['map'],r['x'],r['y'])
   if r.get('renderedVerified')is False:
    accepted.pop(key,None);rejected[key]=r;continue
   assert r.get('returned')or r.get('nonEnterable')and r.get('renderedVerified')
   if key in accepted:assert accepted[key]['nativeHash']==r['nativeHash'],'contradictory accepted native hashes'
   accepted[key]=r;rejected.pop(key,None)
 return accepted,rejected
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('ledgers',type=Path,nargs='+');p.add_argument('--output',type=Path,default=Path('docs/coverage'));p.add_argument('--accepted',type=Path,nargs='*',default=[]);a=p.parse_args()
 current_holds=Path(__file__).resolve().parents[1]/'docs/coverage/frlg-exterior-render-holds-2026-10-23.json'
 # Checked-in current failures supersede historical screenshots until verified
 # integration removes the matching hold; rerunning an older command cannot
 # silently restore stale acceptance.
 accepted,rejected=load_reviews(a.accepted+([current_holds]if current_holds.exists()else[]))
 summarize(a.ledgers,a.output,accepted,rejected)
