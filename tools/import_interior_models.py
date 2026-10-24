#!/usr/bin/env python3
"""Import selected public interior models; keep original archives in scratch."""
import argparse
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import zipfile
import xml.etree.ElementTree as ET
from PIL import Image
from import_scenery_models import dae_static, normalize, safe_path
from import_oras_grass import lua, NS, sources, inputs

SOURCE = {
    'asset': 297853,
    'sourcePage': 'https://models.spriters-resource.com/3ds/pokemonomegarubyalphasapphire/asset/297853/',
    'game': 'Pokémon Omega Ruby / Alpha Sapphire',
    'title': 'PC', 'author': 'Hallow', 'submitted': '2016-06-02',
    'file': 'ORAS PC/com_bm_pc01.dae',
}


def close_pc():
    """Close the source's open rear/undersides along its original rim only."""
    vertices = []
    # Exact case blue from the original source PNG, not its wallpaper/screen.
    uv = [(16.5 / 32), (30.5 / 64)]
    def polygon(points):
        for i in range(1, len(points)-1):
            for p in [points[0], points[i], points[i+1]]:
                vertices.append(list(p) + uv + [1, 1, 1, 1, 1])
    x = 8.23913
    # Rear casing, stepped base and keyboard underside follow the exported
    # boundary loop. The original open knee space stays open.
    profile = [(-10.3649, 32.4832), (-10.3649, 20.3805),
               (-6.99998, 20.3805), (-6.99998, 18.3569),
               (2.25002, 18.3569), (5.00001, 18.3569),
               (7.42156, 16.5)]
    for (z0, y0), (z1, y1) in zip(profile, profile[1:]):
        polygon([[-x, y0, z0], [x, y0, z0], [x, y1, z1], [-x, y1, z1]])
    polygon([[-x,32.4832,-10.3649],[x,32.4832,-10.3649],
             [x,32.4832,-6.99998],[-x,32.4832,-6.99998]])
    polygon([[-x,32.4832,-6.99998],[x,32.4832,-6.99998],
             [x,33.75,-6.99998],[6.75,35.0104,-6.99998],
             [-6.75,35.0104,-6.99998],[-x,33.75,-6.99998]])
    for a,b in [(-x,-6.75),(6.75,x)]:
        polygon([[a,0,7.42155],[b,0,7.42155],[b,16.5,7.42155],[a,16.5,7.42155]])
        polygon([[a,0,7.42155],[b,0,7.42155],[b,0,9.00002],[a,0,9.00002]])
    for y0,y1 in [(2.25,3.344),(15.75,16.5)]:
        polygon([[-6.75,y0,7.42155],[6.75,y0,7.42155],[6.75,y1,7.42155],[-6.75,y1,7.42155]])
    polygon([[-6.75,2.25,7.42155],[6.75,2.25,7.42155],
             [6.75,2.25,9.00002],[-6.75,2.25,9.00002]])
    return {'geometry':'authored_source_case_closure','texture':'com_bm_pc01_1.png',
            'vertices':vertices,'wrapS':'repeat','wrapT':'repeat','authored':True}


def convert(archive_path, output):
    raw_archive = archive_path.read_bytes()
    with zipfile.ZipFile(io.BytesIO(raw_archive)) as archive:
        if len(archive.infolist()) > 32 or sum(i.file_size for i in archive.infolist()) > 8388608:
            raise ValueError('Interior archive exceeds budget')
        names = {}
        for info in archive.infolist():
            safe_path(info.filename)
            if not info.is_dir():
                name = PurePosixPath(info.filename).name
                if name in names:
                    raise ValueError('Ambiguous interior archive basename')
                names[name] = info.filename
        raw = archive.read(SOURCE['file'])
        root = ET.fromstring(raw)
        colors = []
        repairs = []
        solid_parts = set()
        for mesh in root.findall('.//c:mesh', NS):
            streams = sources(mesh)
            for primitive in mesh.findall('c:triangles', NS):
                pin = inputs(primitive)
                stride = 1 + max(i[1] for i in pin.values())
                indices = [int(v) for v in primitive.findtext('c:p', namespaces=NS).split()]
                if 'TEXCOORD' not in pin:
                    # The optional glow has source vertex RGB/alpha but no UV
                    # stream. A solid white material preserves that original
                    # RGBA without projecting the unusable declared texture.
                    if primitive.get('material') != 'pasted__room01_pc02':
                        raise ValueError('Required textured source part lacks UVs')
                    solid_parts.add(len(colors))
                    count = max(indices[i + pin['VERTEX'][1]] for i in range(0, len(indices), stride)) + 1
                    ident = pin['VERTEX'][0] + '_solid_uv'
                    tag = lambda n: '{' + NS['c'] + '}' + n
                    source = ET.SubElement(mesh, tag('source'), id=ident)
                    ET.SubElement(source, tag('float_array'), id=ident+'_array', count=str(count*2)).text = '.5 .5 ' * count
                    tech = ET.SubElement(source, tag('technique_common'))
                    acc = ET.SubElement(tech, tag('accessor'), source='#'+ident+'_array', count=str(count), stride='2')
                    ET.SubElement(acc, tag('param'), name='S', type='float')
                    ET.SubElement(acc, tag('param'), name='T', type='float')
                    ET.SubElement(primitive, tag('input'), semantic='TEXCOORD', source='#'+ident, offset=str(pin['VERTEX'][1]))
                    repairs.append({'material': primitive.get('material'),
                                    'triangles': int(primitive.get('count')),
                                    'repair': 'No source TEXCOORD stream. Retained original geometry and white vertex RGB with original alpha on a generated solid white 1px material; declared glow texture is unused. No source UV projection invented.'})
                color = pin.get('COLOR')
                colors.append([streams[color[0]][indices[i + color[1]]][:4]
                               if color else [1, 1, 1, 1] for i in range(0, len(indices), stride)])
        parts = dae_static(ET.tostring(root))
        # The exported dedicated screen is 0.00002 source units behind the
        # casing's screen plane. Separate the two draw surfaces just enough
        # for portable depth buffers while preserving every source triangle.
        for vertex in parts[0]['vertices']:
            vertex[2] += .01
        repairs.append('Dedicated screen moved forward 0.01 source units (0.05% of width) to resolve exported coplanar casing/screen depth fight; UVs/topology unchanged.')
        if len(parts) != len(colors):
            raise ValueError('Interior source instances require explicit color remapping')
        for part, stream in zip(parts, colors):
            if len(part['vertices']) != len(stream):
                raise ValueError('Interior source color count mismatch')
            for v, color in zip(part['vertices'], stream):
                if len(color) != 4 or any(c < 0 or c > 1 for c in color):
                    raise ValueError('Invalid source vertex color')
                v.extend(color)
        parts.append(close_pc())
        repairs.append('Authored blue case rear, keyboard/frame rear and underside closures follow original exported rim; native open knee space retained. Original 170 triangles unchanged.')
        # Include RGBA in deduplication: equal UV/positions may carry different
        # source corner shading. Runtime vertices keep the existing six floats.
        meta = normalize(parts)
        contacts=0
        for part in parts:
            for vertex in part['vertices']:
                if abs(vertex[1])<1e-6:vertex[1]=0;contacts+=1
            part['bounds']=[min(v[k]for v in part['vertices'])for k in range(3)]+[max(v[k]for v in part['vertices'])for k in range(3)]
        if contacts!=20:raise ValueError('Reviewed PC bottom contact stream changed')
        repairs.append('Normalized bottom-plane floating-point noise below 1e-6 is snapped to exact Y0 so physical contact caps share one datum. Upper source positions, UV and RGBA are unchanged.')
        for part in parts:
            part['colors'] = [v[6:] for v in part['vertices']]
            part['vertices'] = [v[:6] for v in part['vertices']]
        folder = output / 'assets/scenery/interiors/oras_center_pc'
        folder.mkdir(parents=True, exist_ok=True)
        textures = {}
        for part_index, part in enumerate(parts):
            name = PurePosixPath(part['texture']).name
            if part_index in solid_parts:
                name = 'source-vertex-rgba.png'
                generated = io.BytesIO()
                Image.new('RGBA', (1, 1), (255, 255, 255, 255)).save(generated, format='PNG')
                content = generated.getvalue()
            else:
                content = archive.read(names[name])
            image = Image.open(io.BytesIO(content))
            if image.width > 2048 or image.height > 2048:
                raise ValueError('Interior texture exceeds budget')
            image.verify()
            (folder / name).write_bytes(content)
            textures[name] = {'sha256': hashlib.sha256(content).hexdigest(), 'bytes': len(content)}
            part['name'] = part.pop('geometry')
            part['material'] = name
            part['texture'] = f'assets/scenery/interiors/oras_center_pc/{name}'
            part['opacity'] = 1
            part['diffuse'] = [1, 1, 1]
            part['role'] = 'structure'
            part['alphaMode'] = 'blend' if any(c[3] < 1 for c in part['colors']) else 'cutout'
            part.pop('triangle_count', None)
            part.pop('skinned_bind_pose', None)
        data = {'oras_center_pc': {'parts': parts, 'anchors': {}, 'revision': 1}}
        (output/'lib').mkdir(parents=True,exist_ok=True)
        (output / 'lib/ImportedInteriorData.lua').write_text(
            '-- Generated by tools/import_interior_models.py; source attribution is beside each texture.\nreturn ' + lua(data) + '\n')
        report = {**SOURCE, **meta, 'archiveSha256': hashlib.sha256(raw_archive).hexdigest(),
                  'sourceModelSha256': hashlib.sha256(raw).hexdigest(), 'textures': textures,
                  'originalGameArt': 'Nintendo / Creatures / GAME FREAK',
                  'processing': 'All 170 source triangles and vertex RGBA retained, body/screen UVs and original PNG bytes retained. Uniform normalization, documented screen depth separation, and separately authored rear/underside closure. Glow without UVs uses a solid vertex-RGBA material.',
                  'repairs': repairs,
                  'parts': [{'name': p['name'], 'texture': p['texture'], 'triangles': p['triangles'], 'authored': bool(p.get('authored'))} for p in parts]}
        (folder / 'provenance.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
        return data


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('archive', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    models = convert(args.archive, args.output)
    for name, model in models.items():
        print(name, len(model['parts']), 'parts', sum(p['triangles'] for p in model['parts']), 'triangles')
