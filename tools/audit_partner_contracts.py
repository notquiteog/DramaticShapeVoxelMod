#!/usr/bin/env python3
"""Read-only manifest independence and upstream setting-key inventory audit."""
import json
import re
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[1]
workspace = root.parent
repos = ['DramaticShapeVoxelMod', 'wild-skies-gen2', 'dramatic-sky-ride',
         'double-battles-gen2', 'gen1online-plus', 'overworld-spawn-mod', 'modern-ui']
for name in repos:
    path = workspace / name / 'manifest.json'
    manifest = json.loads(path.read_text())
    assert not manifest.get('dependencies'), f'{name}: mandatory dependencies present'
    print(f"PASS {manifest['id']}: no mandatory manifest dependencies")

ref = 'upstream/master'
files = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', ref], cwd=root, text=True)
keys = set()
for file in files.splitlines():
    if file.startswith('lib/') and file.endswith('.lua'):
        source = subprocess.check_output(['git', 'show', f'{ref}:{file}'], cwd=root, text=True)
        keys.update(re.findall(r'ModSetting\.new\(\s*[\'"]([^\'"]+)', source))
current = set(re.findall(r'key="([^"]+)"', (root / 'lib/SettingsCatalog.lua').read_text()))
assert not keys-current, f'Lost upstream settings: {sorted(keys-current)}'
print(f'PASS all {len(keys)} literal upstream setting keys retained')
print('Inventory only: runtime independence and generation parity need separate tests.')
