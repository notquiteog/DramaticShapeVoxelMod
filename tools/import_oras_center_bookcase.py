#!/usr/bin/env python3
"""Original ORAS Center bookcase, with exact exposed case/book closures."""
import argparse, copy, hashlib, json, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_home_furniture import source_part, normalized
from import_oras_oldale_sink import rims
from import_oras_devon import triangulate
from import_oras_grass import lua


def convert(model_path, texture_path, decoder_path, nitrogen_path, output):
    load, textures, png = decoder(decoder_path)
    raw, blob = model_path.read_bytes(), texture_path.read_bytes()
    need(hashlib.sha256(raw).hexdigest() == '7d566794d839dd481b00316cd955bf471e0981a0a615188fae0c340ae72346fc',
         'reviewed original Center room changed')
    model = load(raw)[0]
    need(model.name == 't102pc0101_00_00' and not model.bones, 'reviewed unskinned Center changed')
    sub = model.submeshes[9]
    need(sub.material == 'Comb26' and len(sub.triangles) == 202, 'original cabinet topology changed')
    sys.path.insert(0, str(nitrogen_path))
    from nitrogen.platforms.ctr.bch import open_bch
    other = open_bch(raw).models[0].meshes[9]
    need(sub.positions == other.positions and sub.uv0 == other.texcoords,
         'independent cabinet positions/UV differ')
    need(len(other.submeshes) == 1 and [n for t in sub.triangles for n in t] == other.submeshes[0].indices,
         'independent cabinet indices differ')
    need(next(m.base_color_texture for m in model.materials if m.name == sub.material) == 'pc_hon01',
         'original cabinet texture binding changed')
    texture = next(t for t in textures(blob) if t.name == 'pc_hon01')
    need((texture.width, texture.height) == (64, 32) and set(texture.rgba[3::4]) == {255},
         'original opaque cabinet texture changed')
    folder = output/'assets/scenery/oras-center-bookcase'
    folder.mkdir(parents=True, exist_ok=True)
    image = png(texture.rgba, texture.width, texture.height)
    (folder/'pc_hon01.png').write_bytes(image)
    original = source_part(sub, 'assets/scenery/oras-center-bookcase/pc_hon01.png')
    loops = rims(original)
    need([len(q) for q in loops] == [6, 4, 26, 22, 22, 6], 'original cabinet rims changed')
    # This original book end lies against the original inner case wall. Keep
    # the wall as the sole plane owner instead of retaining two coplanar faces.
    for index in [150, 151]:
        q = [sub.positions[n] for n in sub.triangles[index]]
        need(all(v[0] == -105.75 for v in q) and min(v[1] for v in q) == 3.75
             and max(v[1] for v in q) == 10.604499816894531,
             'reviewed buried book end changed')
    original = source_part(sub, original['texture'], [t for i, t in enumerate(sub.triangles) if i not in [150, 151]])
    case = copy.deepcopy(original)
    case.update(name='authored_exact_exposed_case', vertices=[], indices=[], colors=[], authored=True)
    books = copy.deepcopy(case)
    books['name'] = 'authored_exact_exposed_book_ends'

    def close(part, q, texel):
        ranges = [max(v[k] for v in q)-min(v[k] for v in q) for k in range(3)]
        axis = min(range(3), key=ranges.__getitem__)
        # The tilted book's bottom is the only non-axis-aligned closure.
        if ranges[axis] < 1e-8:
            dims = [k for k in range(3) if k != axis]
            polygons = []
            for tri in triangulate([[v[k] for k in dims] for v in q]):
                points = []
                for point in tri:
                    v = [0, 0, 0]
                    v[axis] = q[0][axis]
                    for k, n in zip(dims, point):
                        v[k] = n
                    points.append(v)
                polygons.append(points)
        else:
            need(len(q) == 4 and q == [loops[5][i] for i in [0, 1, 2, 5]],
                 'unexpected tilted cabinet closure')
            polygons = [[q[0], q[1], q[2]], [q[0], q[2], q[3]]]
        for tri in polygons:
            for v in reversed(tri):
                part['vertices'].append(v+[texel[0]/64, texel[1]/32, 1])
                part['indices'].append(len(part['vertices']))
                part['colors'].append([1, 1, 1, 1])

    white, blue = (60.5, 5.5), (32.5, 16.5)
    close(case, loops[0], white)
    close(case, loops[1], white)
    # Split the large case rim into its actual rear, feet and board underside.
    # The concave rear preserves the open space between the original two feet.
    close(case, [[x, y, -105.75] for x, y in [(-73, 1), (-73, 22.75), (-107, 22.75),
        (-107, 1), (-105.75, 1), (-105.75, 2.5), (-74.25, 2.5), (-74.25, 1)]], white)
    for left, right, height in [(-107, -105.75, 1), (-74.25, -73, 1), (-105.75, -74.25, 2.5)]:
        close(case, [[left, height, -105.75], [right, height, -105.75],
                     [right, height, -92.25], [left, height, -92.25]], white)
    # Books touch existing case shelves/walls: those contacts get no second cap.
    upper, lower, tilted = loops[3:]
    close(books, [[-105.75, 13.25, -101.25], [-74.25, 13.25, -101.25],
                  [-74.25, upper[0][1], -101.25], [-105.75, upper[0][1], -101.25]], blue)
    close(books, [[-105.75, 3.75, -101.25], [-83.25, 3.75, -101.25],
                  [-83.25, lower[0][1], -101.25], [-105.75, lower[0][1], -101.25]], blue)
    close(books, [tilted[i] for i in [2, 3, 4, 5]], blue)
    close(books, [tilted[i] for i in [0, 1, 2, 5]], blue)
    need(len(case['indices']) == 16*3 and len(books['indices']) == 8*3,
         'reviewed exact cabinet closure count changed')
    result, meta = normalized([original, case, books])
    (output/'lib').mkdir(parents=True, exist_ok=True)
    (output/'lib/ImportedCenterBookcaseData.lua').write_text(
        '-- Original ORAS Center bookcase; tools/import_oras_center_bookcase.py.\nreturn '+
        lua({'oras_center_bookcase': result})+'\n')
    report = dict(source='User-supplied Pokemon Alpha Sapphire RomFS',
        originalGameArt='Nintendo / Creatures / GAME FREAK', nativeLink='ZO228 -> AD108 -> MM169 -> GR511',
        model=model.name, submesh=9, material='Comb26', texture='pc_hon01',
        originalTriangles=202, removedBuriedContactTriangles=[150,151], retainedOriginalTriangles=200,
        authoredClosureTriangles=24, finalTriangles=224,
        originalRims=[len(q) for q in loops], modelBchSha256=hashlib.sha256(raw).hexdigest(),
        textureBchSha256=hashlib.sha256(blob).hexdigest(), rgbaSha256=hashlib.sha256(texture.rgba).hexdigest(),
        pngSha256=hashlib.sha256(image).hexdigest(), **meta,
        processing='All original positions/UV and opaque PNG retained; two original book-end triangles buried coplanar against the inner case wall removed, all other source indices retained. Source vertex lighting white. Exact exposed case, foot, shelf undersides and book rear/end closures. Existing shelf/wall contacts and original exposed book ends receive no duplicate caps. Concave rear preserves the original gap between feet; tilted book bottom follows its original plane. No native room floor or source lighting geometry.')
    (folder/'provenance.json').write_text(json.dumps(report, indent=2)+'\n')
    return result, report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['model', 'textures', 'decoder', 'nitrogen', 'output']:
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    _, report = convert(args.model, args.textures, args.decoder, args.nitrogen, args.output)
    print('oras_center_bookcase', report['finalTriangles'])
