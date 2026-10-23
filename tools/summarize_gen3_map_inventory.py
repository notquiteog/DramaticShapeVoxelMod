#!/usr/bin/env python3
"""Publish identifier/count-only native coverage; never infer visual approval."""
import argparse
import collections
import json
from pathlib import Path

EDITIONS = ('emerald', 'ruby', 'sapphire', 'firered', 'leafgreen')


def summarize(inputs, output):
    rows = []
    families = {}
    totals = {}
    for edition, path in zip(EDITIONS, inputs):
        source = [json.loads(line) for line in path.read_text().splitlines()]
        assert source and all(r['edition'] == edition for r in source)
        assert len({r['map'] for r in source}) == len(source)
        total = collections.Counter(maps=len(source))
        for r in sorted(source, key=lambda r: r['map']):
            assert len(r['nativeHash']) == 64 and r['adapterOnly']
            assert r['renderedAcceptance'] is False
            counts = collections.Counter(p['family'] for p in r['furniture'])
            candidates = collections.Counter(p['model'] for p in r['furniture'] if p['model'])
            for p in r['furniture']:
                f = families.setdefault(p['family'], {'kind': p['kind'], 'design': p.get('design'),
                    'editions': {}, 'sourceCandidates': []})
                f['editions'].setdefault(edition, {'count': 0, 'maps': []})
                e = f['editions'][edition]
                e['count'] += 1
                if r['map'] not in e['maps']:
                    e['maps'].append(r['map'])
                if p['model'] and p['model'] not in f['sourceCandidates']:
                    f['sourceCandidates'].append(p['model'])
            room = r['room']
            indoor = bool(room and not room['cave'])
            total['rooms'] += indoor
            total['furniture'] += len(r['furniture'])
            total['candidateFurniture'] += r['importableFurniture']
            total['nativeWallFinishRooms'] += bool(indoor and room['nativeWallFinish'])
            rows.append(dict(edition=edition, map=r['map'], pair=r['pair'],
                primary=r['primary'], secondary=r['secondary'], mapType=r.get('mapType'),
                width=r['width'], height=r['height'], nativeHash=r['nativeHash'],
                supported=r['supported'], room=room,
                furnitureFamilies=dict(sorted(counts.items())),
                sourceCandidates=dict(sorted(candidates.items())),
                renderedAccepted=False))
        totals[edition] = dict(total)
    output.mkdir(parents=True, exist_ok=True)
    (output/'maps.jsonl').write_text(''.join(json.dumps(r, separators=(',', ':'))+'\n' for r in rows))
    summary = dict(schema=1, engine='0.3.95', evidence='native adapter census',
        renderedAccepted=False, totals=totals,
        limitations=['Candidate placement is not proof of successful texture/mesh upload or rendered acceptance.',
            'Furniture extraction does not prove every native object was recognized.',
            'Native continuous room finishes are not claims of imported modern room coverage.'],
        families=dict(sorted(families.items())))
    (output/'families.json').write_text(json.dumps(summary, indent=2)+'\n')
    print(json.dumps(totals, sort_keys=True))


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('inputs', nargs=5, type=Path, metavar='EDITION_JSONL')
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    summarize(args.inputs, args.output)
