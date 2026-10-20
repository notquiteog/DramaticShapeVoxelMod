#!/usr/bin/env python3
"""Build an installable release from committed files, excluding source/test packs."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile
import zipfile


def package(root, output):
    manifest = json.loads(subprocess.check_output(
        ['git', 'show', 'HEAD:manifest.json'], cwd=root))
    archive = subprocess.check_output(['git', 'archive', 'HEAD'], cwd=root)
    output.mkdir(parents=True, exist_ok=True)
    target = output / f"{manifest['id']}-{manifest['version']}.zip"
    with tarfile.open(fileobj=io.BytesIO(archive)) as source, zipfile.ZipFile(
            target, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as result:
        for item in source:
            path = Path(item.name)
            if not item.isfile():
                continue
            if path.parts[0] not in {'data', 'lib', 'vendor', 'assets', 'docs'} and item.name not in {
                    'manifest.json', 'main.lua', 'mod.card', 'README.md', 'CHANGELOG.md',
                    'LICENSE', 'LICENSE.md', 'LICENSE.txt'}:
                continue
            if any(part.lower() in {'backup', '_source', '__pycache__'} for part in path.parts):
                continue
            if item.name.startswith(('assets/legendary/', 'assets/docs/', 'assets/_inspect/')):
                continue
            if item.name.startswith('assets/battle/') and path.name != 'README.md':
                continue
            if path.suffix.lower() in {'.zip', '.dae', '.obj', '.mtl', '.fbx', '.blend',
                    '.gba', '.gb', '.gbc', '.sav', '.state', '.exe', '.dll', '.pyc', '.rgba'}:
                continue
            info = zipfile.ZipInfo(item.name, (2026, 10, 20, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            result.writestr(info, source.extractfile(item).read())
    with zipfile.ZipFile(target) as result:
        assert result.testzip() is None
        assert json.loads(result.read('manifest.json')) == manifest
        assert {'manifest.json', 'main.lua', 'lib/WaterBackdrop.lua'} <= set(result.namelist())
    digest = hashlib.sha256(target.read_bytes()).hexdigest()
    (output / 'sha256sums.txt').write_text(f'{digest}  {target.name}\n')
    print(json.dumps({'asset': str(target), 'sha256': digest, 'version': manifest['version']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    package(Path(__file__).resolve().parents[1], args.output.resolve())
