"""Identify missing external fixtures from a failed Lua test, never from its name."""
import os
import re
import sys
from pathlib import Path

log = Path(sys.argv[1]).read_text(errors='replace')
# Historical A/B suites require immutable snapshots and private source atlases.
# Only classify the resource which actually failed; assertions remain failures.
match = re.search(r'luajit: ([^\n]+\.lua):(\d+): ([^\n]+)', log)
if match:
    path, line, error = match.groups()
    try:
        source = Path(path).read_text().splitlines()[int(line)-1]
    except (OSError, IndexError):
        source = ''
    if 'assert' in source:
        for name in re.findall(r'os\.getenv\([\'"](ASTRA_[A-Z_]+)[\'"]\)', source):
            if not os.getenv(name):
                print(f'requires {name}')
                sys.exit(0)
# Missing named historical snapshots/atlases cannot be manufactured from the
# candidate itself: doing so would make the A/B preservation check meaningless.
if re.search(r'(?:cannot open|:[0-9]+:) [^\n]*artifacts/[^\n]*(?:No such file|cannot open)', log):
    print('requires historical baseline/atlas artifact')
    sys.exit(0)
sys.exit(1)
