#!/usr/bin/env python3
"""Original ORAS Center table, with an exact exposed leg/underside union."""
import argparse, hashlib, json, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_home_furniture import source_part, normalized
from import_oras_oldale_fridge import components, merge_parts
from import_oras_oldale_sink import rims
from import_oras_oldale_chair import clip_leg, area, clip, convex
from import_oras_flower_bookcase import cap
from import_oras_grass import lua


def underside(ring, holes):
    polys = [[[v[0], v[2]] for v in ring]]
    for hole in holes:
        if area(hole) < 0:
            hole.reverse()
        need(convex(hole), 'reviewed original table leg intersection changed')
        kept = []
        for poly in polys:
            remaining = poly
            for a, b in zip(hole, hole[1:]+hole[:1]):
                outside = clip(remaining, a, b, False)
                if outside:
                    kept.append(outside)
                remaining = clip(remaining, a, b, True)
                if not remaining:
                    break
        polys = kept
    expected = abs(area([[v[0], v[2]] for v in ring])) - sum(abs(area(h)) for h in holes)
    actual = sum(abs(area(p)) for p in polys)
    need(abs(expected-actual) < 1e-8, 'table underside lost or duplicated exposed area')
    return polys, expected, actual


def convert(model_path, texture_path, decoder_path, nitrogen_path, output):
    load, textures, png = decoder(decoder_path)
    raw, blob = model_path.read_bytes(), texture_path.read_bytes()
    need(hashlib.sha256(raw).hexdigest() == '7d566794d839dd481b00316cd955bf471e0981a0a615188fae0c340ae72346fc',
         'reviewed original Center room changed')
    model = load(raw)[0]
    need(model.name == 't102pc0101_00_00' and not model.bones, 'reviewed unskinned Center room changed')
    sub = model.submeshes[13]
    need(sub.material == 'Comb25' and len(sub.triangles) == 142, 'reviewed original table changed')
    sys.path.insert(0, str(nitrogen_path))
    from nitrogen.platforms.ctr.bch import open_bch
    other = open_bch(raw).models[0].meshes[13]
    need(sub.positions == other.positions and sub.uv0 == other.texcoords, 'independent table position/UV mismatch')
    need(len(other.submeshes) == 1 and [n for tri in sub.triangles for n in tri] == other.submeshes[0].indices,
         'independent original table indices mismatch')
    groups = {g[0]: g for g in components(sub)}
    selected = {0:78, 46:4, 50:4, 54:4, 86:4, 90:12, 102:12, 114:12, 126:12}
    need({k:len(g) for k,g in groups.items()} == selected, 'complete table source components changed')
    texture = 'assets/scenery/oras-center-table/pc_tbl01.png'
    top = source_part(sub, texture, [sub.triangles[i] for i in groups[0]])
    loops = rims(top)
    need(len(loops) == 1 and len(loops[0]) == 16, 'original table underside rim changed')
    ring = loops[0]
    height = ring[0][1]
    need(all(abs(v[1]-height) < 1e-10 for v in ring), 'nonplanar table underside')
    parts = [top]
    # Preserve the four original, separate reflection ribbons and their actual
    # clearance above the glass. They are material artwork, not room lighting.
    for key in [46,50,54,86]:
        parts.append(source_part(sub, texture, [sub.triangles[i] for i in groups[key]]))
    closures, holes = [], []
    for key in [90,102,114,126]:
        leg = clip_leg(source_part(sub, texture, [sub.triangles[i] for i in groups[key]]), height)
        loops = rims(leg)
        need(sorted(map(len, loops)) == [6,12], 'clipped original table leg changed')
        low = min(loops, key=lambda p:sum(v[1] for v in p)/len(p))
        high = max(loops, key=lambda p:sum(v[1] for v in p)/len(p))
        need(all(v[1] == 1.5 for v in low), 'original table floor contacts changed')
        holes.append([[v[0],v[2]] for v in high])
        closures.append(cap(leg, low, [22.5/32,25.5/32], [1,1,1,1]))
        parts.append(leg)
    polys, expected, actual = underside(ring, holes)
    for poly in polys:
        if area(poly) > 0:
            poly.reverse()
        closures.append(cap(top, [[v[0],height,v[1]] for v in poly], [26.5/32,22.5/32], [1,1,1,1]))
    closed = merge_parts(closures)
    closed['name'] = 'authored_exact_table_exposed_contact_union'
    need(sum(len(p['indices'])//3 for p in parts) == 166 and len(closed['indices'])//3 == 92,
         'reviewed exposed table union counts changed')
    parts.append(closed)
    result, meta = normalized(parts)
    t = next(t for t in textures(blob) if t.name == 'pc_tbl01')
    need((t.width,t.height) == (32,32) and set(t.rgba[3::4]) == {255}, 'original opaque glass artwork changed')
    content = png(t.rgba,t.width,t.height)
    folder = output/'assets/scenery/oras-center-table'
    folder.mkdir(parents=True,exist_ok=True)
    (folder/'pc_tbl01.png').write_bytes(content)
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedCenterTableData.lua').write_text('-- Original ORAS Center table; tools/import_oras_center_table.py.\nreturn '+lua({'oras_center_glass_table':result})+'\n')
    report = dict(source='User-supplied Pokemon Alpha Sapphire RomFS', originalGameArt='Nintendo / Creatures / GAME FREAK',
        nativeLink='ZO228 -> AD108 -> MM169 -> GR511', model=model.name, submesh=13, material=sub.material,
        selectedComponents=list(selected), originalTriangles=142, exposedSourceTriangles=sum(len(p['indices'])//3 for p in parts[:-1]),
        authoredClosureTriangles=len(closed['indices'])//3, finalTriangles=sum(len(p['indices'])//3 for p in parts),
        modelBchSha256=hashlib.sha256(raw).hexdigest(), textureBchSha256=hashlib.sha256(blob).hexdigest(),
        rgbaSha256=hashlib.sha256(t.rgba).hexdigest(), pngSha256=hashlib.sha256(content).hexdigest(),
        undersideExposedArea=expected, undersideUnionArea=actual, **meta,
        processing='Original complete shaped glass top, four separate source reflection ribbons and four hexagonal legs. Original visible geometry/UV/PNG retained, vertex lighting white. Buried leg ends clip exactly at source underside; underside partitions around actual twelve-vertex leg intersections. Exposed leg bottoms close; no buried leg caps or room lighting/floor/shadow geometry. Uniform native fit with bottom-contact-only recess.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return result,report


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['model','textures','decoder','nitrogen','output']:
        parser.add_argument(name,type=Path)
    args=parser.parse_args()
    _,report=convert(args.model,args.textures,args.decoder,args.nitrogen,args.output)
    print('oras_center_glass_table',report['finalTriangles'],report['undersideExposedArea'],report['undersideUnionArea'])
