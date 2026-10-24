#!/usr/bin/env python3
"""Original ORAS reception U-counter with exposed-only top/base unions."""
import argparse, copy, hashlib, json, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_home_furniture import source_part, normalized
from import_oras_oldale_fridge import components
from import_oras_oldale_chair import clip_leg, area
from import_oras_oldale_table import solid_cloth
from import_oras_devon import triangulate
from import_oras_grass import lua


def convert(model_path, texture_path, decoder_path, nitrogen_path, output):
    load, textures, png = decoder(decoder_path)
    raw, blob = model_path.read_bytes(), texture_path.read_bytes()
    need(hashlib.sha256(raw).hexdigest() == '7d566794d839dd481b00316cd955bf471e0981a0a615188fae0c340ae72346fc',
         'reviewed original Center changed')
    model = load(raw)[0]
    need(model.name == 't102pc0101_00_00' and not model.bones, 'reviewed unskinned Center changed')
    sub = model.submeshes[0]
    need(sub.material == 'Comb14' and len(sub.triangles) == 234, 'reviewed counter stream changed')
    sys.path.insert(0, str(nitrogen_path))
    from nitrogen.platforms.ctr.bch import open_bch
    independent = open_bch(raw).models[0].meshes[0]
    need(sub.positions == independent.positions and sub.uv0 == independent.texcoords,
         'independent counter positions/UV differ')
    need(len(independent.submeshes) == 1 and [n for t in sub.triangles for n in t] == independent.submeshes[0].indices,
         'independent counter indices differ')
    need(next(m.base_color_texture for m in model.materials if m.name == sub.material) == 'pc_uke01',
         'original counter texture binding changed')
    groups = {g[0]: g for g in components(sub)}
    selected = {76:56, 90:24, 182:2, 202:2, 232:2}
    need(all(len(groups[k]) == n for k, n in selected.items()), 'reviewed complete counter components changed')
    texture = 'assets/scenery/oras-center-counter/pc_uke01.png'
    parts = []
    for k in selected:
        part = source_part(sub, texture, [sub.triangles[i] for i in groups[k]])
        if k in [90, 182, 202]:
            part = clip_leg(part, 14)
        parts.append(part)
    # Preserve the original service plaque above the actual source top; give
    # its single sheet a thin original-footprint back and rim, still clear of it.
    plaque = solid_cloth(parts[-1], .03, expected_rim=4)
    for p in plaque:
        p['name'] = p['name'].replace('cloth', 'service_plaque')
    parts.extend(plaque)
    caps = copy.deepcopy(parts[0])
    caps.update(name='authored_exact_counter_exposed_union', vertices=[], indices=[], colors=[], authored=True)
    areas = {}

    def close(name, points, uv):
        ranges = [max(v[k] for v in points)-min(v[k] for v in points) for k in range(3)]
        axis = min(range(3), key=ranges.__getitem__)
        need(ranges[axis] < 1e-9, 'counter closure is not an exact source plane')
        dims = [k for k in range(3) if k != axis]
        polygon = [[v[k] for k in dims] for v in points]
        areas[name] = abs(area(polygon))
        for triangle in triangulate(polygon):
            for q in reversed(triangle):
                v = [0, 0, 0]
                v[axis] = points[0][axis]
                for k, x in zip(dims, q):
                    v[k] = x
                caps['vertices'].append(v+uv+[1])
                caps['indices'].append(len(caps['vertices']))
                caps['colors'].append([1, 1, 1, 1])

    white, base = [55.5/64,42.5/64], [5.5/64,43.5/64]
    # Actual shaped source outer rim and source base intersection at Y14.
    top_outer = [(-70,-105.75),(-70,-62),(-68,-58),(-64,-56),(46,-56),(50,-58),(52,-62),(52,-105.75)]
    base_outer = [(-69,-105.75),(-69,-63),(-67,-59),(-63,-57),(45,-57),(49,-59),(51,-63),(51,-105.75)]
    top_inner = [(-56,-105.75),(-56,-72),(-55,-70),(-52,-69),(34,-69),(37,-70),(38,-72),(38,-105.75)]
    base_inner = [(-57,-105.75),(-57,-65.25),(39,-65.25),(39,-105.75)]
    close('underside_outer_overhang', [[x,14,z] for x,z in top_outer+list(reversed(base_outer))], white)
    close('underside_inner_overhang', [[x,14,z] for x,z in top_inner+list(reversed(base_inner))], white)
    close('floor_contact', [[x,0,z] for x,z in base_outer+list(reversed(base_inner))], base)
    close('staff_front', [[-57,0,-65.25],[39,0,-65.25],[39,14,-65.25],[-57,14,-65.25]], base)
    # One rear cap per complete arm, including the real top/base step. No
    # internal cap at their common Y14 join.
    rear_left = [(-69,0),(-57,0),(-57,14),(-56,14),(-56,18),(-68,18),(-70,16.5),(-70,14),(-69,14)]
    rear_right = [(39,0),(51,0),(51,14),(52,14),(52,16.5),(50,18),(38,18),(38,14),(39,14)]
    close('rear_left', [[x,y,-105.75] for x,y in rear_left], base)
    close('rear_right', [[x,y,-105.75] for x,y in rear_right], base)
    parts.append(caps)
    result, meta = normalized(parts)
    t = next(t for t in textures(blob) if t.name == 'pc_uke01')
    need((t.width,t.height) == (64,64) and set(t.rgba[3::4]) == {255}, 'original counter texture changed')
    image = png(t.rgba,t.width,t.height)
    folder = output/'assets/scenery/oras-center-counter'
    folder.mkdir(parents=True,exist_ok=True)
    (folder/'pc_uke01.png').write_bytes(image)
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedCenterCounterData.lua').write_text('-- Original ORAS reception counter; tools/import_oras_center_counter.py.\nreturn '+lua({'oras_center_reception_counter':result})+'\n')
    report = dict(source='User-supplied Pokemon Alpha Sapphire RomFS', originalGameArt='Nintendo / Creatures / GAME FREAK',
        nativeLink='ZO228 -> AD108 -> MM169 -> GR511', model=model.name,submesh=0,material=sub.material,
        selectedComponents=list(selected),selectedOriginalTriangles=sum(selected.values()),
        exposedOriginalTriangles=sum(len(p['indices'])//3 for p in parts[:5]),
        authoredPlaqueThickness=.03,authoredClosureTriangles=sum(len(p['indices'])//3 for p in parts[5:]),
        finalTriangles=sum(len(p['indices'])//3 for p in parts),closureAreas=areas,
        modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),
        rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(image).hexdigest(),**meta,
        processing='Original complete U-counter top, base exterior, staff-facing arms and service plaque selected; separate overhead arch excluded. Source positions/UV/PNG and white vertex lighting retained. Buried base ends clip at the actual top underside Y14. Exact outer and inner underside strips exclude the base joint; bottom/rear/staff-facing openings close on original source bounds. No internal Y14 cap. Plaque retains original top and adds .03-source-unit thickness, clear of counter. Native staff clearance and composite fit require separate runtime acceptance.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return result,report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['model','textures','decoder','nitrogen','output']:
        parser.add_argument(name,type=Path)
    args = parser.parse_args()
    _, report = convert(args.model,args.textures,args.decoder,args.nitrogen,args.output)
    print('oras_center_reception_counter',report['finalTriangles'],report['closureAreas'])
