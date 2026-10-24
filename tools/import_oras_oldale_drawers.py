#!/usr/bin/env python3
"""Original Oldale three-drawer chest, with exposed-only contact closures."""
import argparse, copy, hashlib, json, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_home_furniture import source_part, normalized
from import_oras_oldale_fridge import components
from import_oras_oldale_sink import rims
from import_oras_oldale_chair import area, clip
from import_oras_devon import triangulate
from import_oras_grass import lua


def subtract(polygons, cutters):
    for cutter in cutters:
        if area(cutter) < 0:
            cutter = list(reversed(cutter))
        out = []
        for polygon in polygons:
            remaining = polygon
            for a, b in zip(cutter, cutter[1:]+cutter[:1]):
                outside = clip(remaining, a, b, False)
                if outside:
                    out.append(outside)
                remaining = clip(remaining, a, b, True)
                if not remaining:
                    break
        polygons = out
    return polygons


def cut_panel(part, hole, axes=(0,1)):
    """Subtract a convex contact while interpolating original source UV."""
    if area(hole) < 0:
        hole = list(reversed(hole))
    out = copy.deepcopy(part)
    out.update(vertices=[], indices=[], colors=[])

    def halfspace(poly, a, b, inside):
        def distance(v):
            return ((b[0]-a[0])*(v[axes[1]]-a[1])-(b[1]-a[1])*(v[axes[0]]-a[0]))*(1 if inside else -1)
        result = []
        if not poly:
            return result
        previous, last = poly[-1], distance(poly[-1])
        for v in poly:
            current = distance(v)
            if (last >= -1e-10) != (current >= -1e-10):
                t = last/(last-current)
                result.append([previous[k]+t*(v[k]-previous[k]) for k in range(6)])
            if current >= -1e-10:
                result.append(v[:])
            previous, last = v, current
        clean = []
        for v in result:
            if not clean or sum(abs(v[k]-clean[-1][k]) for k in range(3)) > 1e-8:
                clean.append(v)
        if len(clean) > 1 and sum(abs(clean[0][k]-clean[-1][k]) for k in range(3)) < 1e-8:
            clean.pop()
        return clean if len(clean) > 2 and abs(area([[v[k] for k in axes] for v in clean])) > 1e-9 else []

    for at in range(0,len(part['indices']),3):
        remaining = [part['vertices'][n-1] for n in part['indices'][at:at+3]]
        for a, b in zip(hole,hole[1:]+hole[:1]):
            outside = halfspace(remaining,a,b,False)
            if outside:
                start = len(out['vertices'])
                out['vertices'].extend(outside)
                out['colors'].extend([[1,1,1,1] for _ in outside])
                for i in range(1,len(outside)-1):
                    out['indices'].extend([start+1,start+i+1,start+i+2])
            remaining = halfspace(remaining,a,b,True)
            if not remaining:
                break
    return out


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,textures,png = decoder(decoder_path)
    raw,blob = model_path.read_bytes(),texture_path.read_bytes()
    need(hashlib.sha256(raw).hexdigest() == '93158e5006309bdc48a0b2aa4d06edbd5405ad521398100e19eef3286ed275c0',
         'reviewed original Oldale room changed')
    model = load(raw)[0]
    need(model.name == 't102r0101_00_00' and not model.bones,'reviewed unskinned room changed')
    sub = model.submeshes[11]
    need(sub.material == 't102_shelf04' and len(sub.triangles) == 92,'original chest topology changed')
    sys.path.insert(0,str(nitrogen_path))
    from nitrogen.platforms.ctr.bch import open_bch
    other = open_bch(raw).models[0].meshes[11]
    need(sub.positions == other.positions and sub.uv0 == other.texcoords,'independent chest position/UV mismatch')
    need(len(other.submeshes) == 1 and [n for tri in sub.triangles for n in tri] == other.submeshes[0].indices,
         'independent chest indices mismatch')
    need(next(m.base_color_texture for m in model.materials if m.name == sub.material) == 't102_shelf04',
         'original chest texture binding changed')
    groups = {g[0]:g for g in components(sub)}
    need({k:len(g) for k,g in groups.items()} == {0:6,6:6,12:6,18:8,26:8,34:8,42:8,
        50:14,52:2,54:2,56:2,58:10,80:4,84:4,88:4},'complete original chest components changed')
    texture = 'assets/scenery/oras-oldale-drawers/t102_shelf04.png'
    parts = {k:source_part(sub,texture,[sub.triangles[i] for i in g]) for k,g in groups.items()}
    top_rim = rims(parts[58])[0]
    back,front = min(top_rim,key=lambda v:v[2]),max(top_rim,key=lambda v:v[2])
    def top_y(z):
        return back[1]+(z-back[2])*(front[1]-back[1])/(front[2]-back[2])
    floor = 3.5000059604644775
    seam_delta = 0
    # The original nominally shared joints differ by source export roundoff.
    # Join contact vertices to the actual original tilted cap; do not move it.
    for k,p in parts.items():
        if k == 58:
            continue
        for v in p['vertices']:
            old = v[1]
            if abs(v[1]-27.500009536743164) < 1e-9:
                v[1] = top_y(v[2])
            elif abs(v[1]-3.5) < 1e-9:
                v[1] = floor
            elif k == 56 and abs(v[1]-5.000010013580322) < 1e-9:
                v[1] = 5.0
            seam_delta = max(seam_delta,abs(v[1]-old))
    need(seam_delta < .0016,'original tiny contact roundoff changed')
    closures = copy.deepcopy(parts[50])
    closures.update(name='authored_exact_exposed_chest_contacts',vertices=[],indices=[],colors=[],authored=True)
    bank = {t.name:t for t in textures(blob)}
    tex = bank['t102_shelf04']
    need((tex.width,tex.height) == (128,64) and set(tex.rgba[3::4]) == {255},'original chest paint changed')
    # Original timber texel, checked opaque and flat; no source light values.
    need(tuple(tex.rgba[(4*128+4)*4:(4*128+4)*4+4]) == (178,112,29,255),'original timber texel changed')
    wood_uv = [4.5/128,4.5/64]

    def triangle(points,uv=wood_uv):
        for v in points:
            closures['vertices'].append(list(v)+uv+[1])
            closures['indices'].append(len(closures['vertices']))
            closures['colors'].append([1,1,1,1])

    def horizontal(polys,height):
        for poly in polys:
            for tri in triangulate(poly):
                triangle([[x,height(z) if callable(height) else height,z] for x,z in reversed(tri)])

    def quad(q):
        triangle([q[0],q[1],q[2]])
        triangle([q[0],q[2],q[3]])

    feet,foot_tops = [],[]
    for k in [18,26,34,42]:
        loops = rims(parts[k])
        low,high = sorted(loops,key=lambda q:sum(v[1] for v in q))
        feet.append([[v[0],v[2]] for v in low])
        foot_tops.append([[v[0],v[2]] for v in high])
        horizontal([feet[-1]],1)
    # Follow the actual inset front separator, retaining its original recess.
    front_bar = max(v[2] for v in parts[88]['vertices'])
    bottom = [[-178.5,-287],[-163.5,-287],[-163.5,-271],[-165.5,-271],
              [-165.5,front_bar],[-176.5,front_bar],[-176.5,-271],[-178.5,-271]]
    body_triangles = triangulate(bottom)
    exposed_bottom = subtract(body_triangles,foot_tops)
    horizontal(exposed_bottom,floor)
    exposed_feet = []
    for ring in foot_tops:
        exposed = subtract([ring],body_triangles)
        exposed_feet.extend(exposed)
        horizontal(exposed,floor)
    # Rear inside face joins the real source case side rims.
    quad([[-176.5,floor,-285],[-165.5,floor,-285],[-165.5,top_y(-285),-285],[-176.5,top_y(-285),-285]])
    panel_back,panel_areas = {},{}
    for knob,panel in [(0,52),(6,54),(12,56)]:
        ring = rims(parts[knob])[0]
        original = parts[panel]
        hole = [[v[0],v[1]] for v in ring]
        parts[panel] = cut_panel(original,hole)
        def projected(p):
            return sum(abs(area([[p['vertices'][n-1][0],p['vertices'][n-1][1]]
                for n in p['indices'][at:at+3]])) for at in range(0,len(p['indices']),3))
        expected = projected(original)-abs(area(hole))
        actual = projected(parts[panel])
        need(abs(actual-expected) < 1e-8,'drawer front loses or duplicates exposed area')
        panel_areas[panel] = dict(original=projected(original),knobContact=abs(area(hole)),exposed=actual)
        # Knob collars end exactly at the original panel, with no internal cap.
        z = original['vertices'][0][2]
        for a,b in zip(ring,ring[1:]+ring[:1]):
            quad([a,b,[b[0],b[1],z],[a[0],a[1],z]])
        back_part = copy.deepcopy(original)
        back_part.update(name='authored_drawer_thin_back_'+str(panel),authored=True)
        for v in back_part['vertices']:
            v[2] -= .03
            if panel == 52 and v[1] > 27:
                v[1] = top_y(v[2])
        for at in range(0,len(back_part['indices']),3):
            back_part['indices'][at:at+3] = list(reversed(back_part['indices'][at:at+3]))
        panel_back[panel] = back_part
    # Cap only exposed top underside: case U-walls and upper panel own joints.
    top = [[-179,-287],[-163,-287],[-163,-271],[-179,-271]]
    panel_z = parts[52]['vertices'][0][2]
    contacts = [[[-178.5,-287],[-163.5,-287],[-163.5,-285],[-178.5,-285]],
        [[-178.5,-285],[-176.5,-285],[-176.5,-271],[-178.5,-271]],
        [[-165.5,-285],[-163.5,-285],[-163.5,-271],[-165.5,-271]],
        [[-176.5,panel_z-.03],[-165.5,panel_z-.03],[-165.5,panel_z],[-176.5,panel_z]]]
    top_exposed = subtract([top],contacts)
    horizontal(top_exposed,top_y)
    # Separator ends are owned by the case walls; their undersides/backs remain
    # exposed. The lowest underside already belongs to the single case floor.
    for k in [80,84,88]:
        vs = parts[k]['vertices']
        left,right = min(v[0] for v in vs),max(v[0] for v in vs)
        low,high = min(v[1] for v in vs),max(v[1] for v in vs)
        rear,fore = min(v[2] for v in vs),max(v[2] for v in vs)
        if k != 88:
            horizontal([[[left,rear],[right,rear],[right,fore],[left,fore]]],low)
        quad([[left,low,rear],[right,low,rear],[right,high,rear],[left,high,rear]])
    result,meta = normalized(list(parts.values())+list(panel_back.values())+[closures])
    folder = output/'assets/scenery/oras-oldale-drawers'
    folder.mkdir(parents=True,exist_ok=True)
    image = png(tex.rgba,tex.width,tex.height)
    (folder/'t102_shelf04.png').write_bytes(image)
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedOldaleDrawerData.lua').write_text('-- Original ORAS Oldale drawer chest; tools/import_oras_oldale_drawers.py.\nreturn '+lua({'oras_oldale_drawer_chest':result})+'\n')
    report = dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',
        nativeLink='ZO230 -> AD115 -> MM171 -> GR513',model=model.name,submesh=11,material=sub.material,
        originalTriangles=92,exposedSourceTriangles=sum(len(p['indices'])//3 for p in parts.values()),
        authoredClosureTriangles=sum(len(p['indices'])//3 for p in panel_back.values())+len(closures['indices'])//3,
        finalTriangles=sum(len(p['indices'])//3 for p in result['parts']),
        maxContactRoundoffCorrection=seam_delta,thinPanelDepth=.03,
        panelAreas=panel_areas,
        exposedBottomArea=sum(abs(area(p)) for p in exposed_bottom),exposedFeetTopArea=sum(abs(area(p)) for p in exposed_feet),
        exposedTopUndersideProjectedArea=sum(abs(area(p)) for p in top_exposed),
        modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),
        rgbaSha256=hashlib.sha256(tex.rgba).hexdigest(),pngSha256=hashlib.sha256(image).hexdigest(),**meta,
        processing='Original three drawers, hexagonal knobs, four feet, case, separator recesses and tilted top retained with original UV/opaque PNG; vertex lighting white. Tiny original contact roundoff joins existing cap plane. Front panels subtract exact knob hex contacts with interpolated source UV; collars attach without buried caps. Thin drawer backs touch case-owned sides/separators. Exact feet/case floor union preserves inset front and exposed foot overhangs; top underside excludes case/panel joints. No source room floor, shadows or lighting.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return result,report


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['model','textures','decoder','nitrogen','output']:
        parser.add_argument(name,type=Path)
    args=parser.parse_args()
    _,report=convert(args.model,args.textures,args.decoder,args.nitrogen,args.output)
    print('oras_oldale_drawer_chest',report['finalTriangles'],report['exposedBottomArea'],report['exposedFeetTopArea'])
