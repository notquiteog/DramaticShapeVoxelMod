"""A later failed native review must invalidate stale visual acceptance."""
import importlib.util,json,tempfile
from pathlib import Path
spec=importlib.util.spec_from_file_location('ledger',Path(__file__).resolve().parents[1]/'tools/summarize_frlg_exterior_sources.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
base={'edition':'firered','map':'FR_SAFFRON_CITY','x':22,'y':34,'sourceModel':'hgss_kanto_center','nativeHash':'a'*64,'runtime':'v0.3.96','returned':True}
with tempfile.TemporaryDirectory()as folder:
 p=Path(folder)/'reviews.json'
 good={**base,'renderedVerified':True};bad={**base,'renderedVerified':False,'renderedGap':'Missing source door draw.'}
 p.write_text(json.dumps([good,bad]));accepted,rejected=m.load_reviews([p]);assert not accepted and len(rejected)==1,'failed current review left stale acceptance'
 p.write_text(json.dumps([bad,good]));accepted,rejected=m.load_reviews([p]);assert len(accepted)==1 and not rejected,'verified later repair did not clear hold'
 p.write_text(json.dumps([good,{**good,'nativeHash':'b'*64}]))
 try:m.load_reviews([p])
 except AssertionError:pass
 else:raise AssertionError('contradictory accepted native maps were combined')
 p.write_text(json.dumps([{**good,'missingAssets':True}]))
 try:m.load_reviews([p])
 except AssertionError:pass
 else:raise AssertionError('fallback became source acceptance')
print('PASS current failed native review clears historical acceptance; later verified repair clears hold; contradictory maps/fallback refuse')
