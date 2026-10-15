#!/usr/bin/env python3
"""Regenerate the two option inventories from their live source of truth."""
import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--check', action='store_true', help='fail if either inventory is stale')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]

def report(*flags):
    return subprocess.check_output(['luajit', 'tools/option-parity-report.lua', *flags], cwd=root, text=True)

outputs = {
    'docs/OPTION_PARITY.tsv': report(),
    'docs/option-support.json': json.dumps(json.loads(report('--json')), indent=2, ensure_ascii=False) + '\n',
}
stale = []
for name, content in outputs.items():
    path = root / name
    if args.check:
        if not path.exists() or path.read_text() != content:
            stale.append(name)
    else:
        path.write_text(content)
if stale:
    parser.exit(1, 'Stale option inventories: ' + ', '.join(stale) + '\nRun tools/update_option_inventory.py\n')
print('Option inventories match live source' if args.check else 'Updated option inventories')
