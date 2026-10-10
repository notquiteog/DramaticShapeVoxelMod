"""Identify missing external fixtures from a failed Lua test, never from its name."""
import os
import re
import sys
from pathlib import Path


def _read_line(path, line):
    """Source line `line` of `path`, resolving Lua-truncated chunk names.

    An absolute dofile path past Lua's error-message budget shows up as
    "...ects/Repo/tests/file.lua"; the classifier then cannot open it and a
    missing ASTRA_* fixture reads as a real failure. Match the visible tail
    against files under the candidate root before giving up.
    """
    try:
        return Path(path).read_text().splitlines()[int(line)-1]
    except (OSError, IndexError):
        pass
    if path.startswith('...'):
        tail = path[3:]
        root = Path(os.getenv('ASTRA_CANDIDATE') or Path.cwd())
        for candidate in root.rglob(Path(tail).name):
            if str(candidate).endswith(tail):
                try:
                    return candidate.read_text().splitlines()[int(line)-1]
                except (OSError, IndexError):
                    continue
    return ''


log = Path(sys.argv[1]).read_text(errors='replace')
# Historical A/B suites require immutable snapshots and private source atlases.
# Only classify the resource which actually failed; assertions remain failures.
match = re.search(r'luajit: ([^\n]+\.lua):(\d+): ([^\n]+)', log)
if match:
    path, line, error = match.groups()
    source = _read_line(path, line)
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
