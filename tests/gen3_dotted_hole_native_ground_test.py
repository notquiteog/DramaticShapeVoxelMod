"""Actual imported FR/LG pillar projections prove the exact native floor donor."""
import argparse,json
from pathlib import Path
from gen3_civic_native_ground_source_test import atlas
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('roots',type=Path,nargs='+')
for root in parser.parse_args().roots:
 tree=root/'map_tree';census=json.loads((tree/'census.json').read_text());m=next(m for g in census['groups']for m in g['maps']if m['id']=='SixIsland_RuinValley')
 header=json.loads((tree/'maps'/m['slot']/'header.json').read_text());pair='general__rom_'+header['secondaryTileset'].removeprefix('ts_');native=root/'native'/pair
 u,o=atlas(native/'mids.idx'),atlas(native/'mids_over.idx');composite=lambda mid:bytes(b or a for a,b in zip(u[mid],o[mid]))
 assert set(u[198])=={8,12}and not any(o[198])
 assert set(u[1])=={8,13,14}and u[1]!=u[198],'field lawn confused with original court floor'
 for mid in [822,879]:
  assert composite(mid)[128:]==u[198][128:],'lower source pillar projection differs from native court floor'
  assert any(v not in{8,12}for v in composite(mid)[:128]),'projection paint was not present'
 print('PASS',root,'both original pillar lower8px exactly match clean native198 court, distinct from lawn1; no facade pixels reused as floor')
