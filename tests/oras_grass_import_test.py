#!/usr/bin/env python3
"""Offline importer checks. Pass the original public asset ZIP explicitly."""
import importlib.util
from pathlib import Path
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("grass_import", ROOT/"tools/import_oras_grass.py")
importer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(importer)

# Explicit independently calculated affine composition: scale, rotate, translate.
node = ET.fromstring('<node xmlns="http://www.collada.org/2005/11/COLLADASchema">'
    '<translate>1 2 3</translate><rotate>0 0 1 90</rotate><scale>2 3 4</scale></node>')
actual = importer.apply(importer.transform(node), [1, 0, 0])
assert max(abs(a-b) for a, b in zip(actual, [1, 4, 3])) < 1e-12

if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 tests/oras_grass_import_test.py /path/to/353363.zip")
archive_path = Path(sys.argv[1])
checked = 0
with zipfile.ZipFile(archive_path) as archive:
    for source in importer.SOURCES.values():
        raw = archive.read(source)
        root = ET.fromstring(raw)
        parts = importer.bake_dae(raw)
        main = next(p for p in parts if p["texture"].startswith("hureai"))
        geometry = next(g for g in root.findall('c:library_geometries/c:geometry', importer.NS)
                        if g.get('id') == main['geometry'])
        mesh = geometry.find('c:mesh', importer.NS)
        primitive = mesh.find('c:triangles', importer.NS)
        pi = importer.inputs(primitive)
        vertex = mesh.find('c:vertices', importer.NS)
        position_source = importer.inputs(vertex)['POSITION'][0]
        positions = importer.sources(mesh)[position_source]
        # These actual files were exported with a bind-shape rotation inverse
        # to the declared Z_UP conversion. Their undeformed main grass must
        # return to the original Y-up positions after full weighted skinning.
        stride = 1+max(offset for _, offset in pi.values())
        indices = [int(x) for x in primitive.findtext('c:p', namespaces=importer.NS).split()]
        for n, baked in enumerate(main['vertices']):
            original = positions[indices[n*stride+pi['VERTEX'][1]]]
            assert max(abs(a-b) for a,b in zip(baked[:3],original[:3])) < .0001, (source,n,baked,original)
            checked += 1
    with tempfile.TemporaryDirectory() as directory:
        target = Path(directory)
        (target/'lib').mkdir()
        models, _ = importer.convert(archive_path,target)
        original_data = (target/'lib/GrassModelData.lua').read_bytes()
        for model in models.values():
            texture = target/model['texture']
            assert texture.read_bytes() == archive.read(texture.name), 'Original texture bytes changed'
            assert model['wrapS'] == 'repeat' and model['wrapT'] == 'repeat'
        importer.convert(archive_path,target)
        assert original_data == (target/'lib/GrassModelData.lua').read_bytes(), 'Import is not deterministic'
print(f'PASS affine hierarchy order, {checked} actual bind-pose triangle vertices, unchanged PNG bytes, source sampler wrap and deterministic conversion')
