#!/usr/bin/env python3
"""Original ORAS Center healing machine and source-derived animation anchors."""
import argparse, copy, hashlib, json, sys
from pathlib import Path
from oras_scenery_source import decoder, need
from import_oras_home_furniture import source_part, normalized
from import_oras_oldale_fridge import merge_parts
from import_oras_oldale_sink import rims
from import_oras_devon import triangulate
from import_oras_grass import lua


def convert(model_path, texture_path, decoder_path, nitrogen_path, output):
    load, textures, png = decoder(decoder_path)
    raw, blob = model_path.read_bytes(), texture_path.read_bytes()
    need(hashlib.sha256(raw).hexdigest() == '7d566794d839dd481b00316cd955bf471e0981a0a615188fae0c340ae72346fc',
         'reviewed original Center room changed')
    model = load(raw)[0]
    need(model.name == 't102pc0101_00_00' and not model.bones, 'reviewed unskinned room changed')
    sys.path.insert(0,str(nitrogen_path))
    from nitrogen.platforms.ctr.bch import open_bch
    other = open_bch(raw).models[0]
    bank = {t.name:t for t in textures(blob)}
    parts, images = [], {}
    folder = output/'assets/scenery/oras-center-healer'
    folder.mkdir(parents=True,exist_ok=True)
    for index, material, texture, count, size in [(16,'Comb21','pc_mc01',444,(64,64)),(15,'Comb29','pc_mc02',10,(32,64))]:
        sub, independent = model.submeshes[index], other.meshes[index]
        need(sub.material == material and len(sub.triangles) == count, 'original healer material/topology changed')
        need(sub.positions == independent.positions and sub.uv0 == independent.texcoords,
             'independent healer position/UV mismatch')
        need(len(independent.submeshes) == 1 and [n for t in sub.triangles for n in t] == independent.submeshes[0].indices,
             'independent healer indices mismatch')
        need(next(m.base_color_texture for m in model.materials if m.name == material) == texture,
             'original healer texture binding changed')
        t = bank[texture]
        need((t.width,t.height) == size and set(t.rgba[3::4]) == {255}, 'original opaque healer texture changed')
        content = png(t.rgba,t.width,t.height)
        (folder/(texture+'.png')).write_bytes(content)
        images[texture] = dict(size=size,rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest())
        parts.append(source_part(sub,'assets/scenery/oras-center-healer/'+texture+'.png'))
    # The tray and machine share boundary edges. Join their geometric rims
    # before closing them, so their original joint gains no internal caps.
    loops = rims(merge_parts(parts))
    need([len(q) for q in loops] == [12,12,22,38,11,11,8,12,8,12], 'original joined healer boundaries changed')
    closing = []
    for q in loops:
        if len(q) == 38:
            # One original open outline goes around both the floor and rear.
            # Split exactly on their shared existing bottom edge.
            a,b = 13,28
            need(q[a][1] == q[b][1] == -1 and q[a][2] == q[b][2], 'original rear/floor boundary changed')
            closing.extend([q[a:b+1],q[b:]+q[:a+1]])
        else:
            closing.append(q)
    caps = copy.deepcopy(parts[0])
    caps.update(name='authored_exact_healer_exposed_rims',vertices=[],indices=[],colors=[],authored=True)
    for q in closing:
        ranges = [max(v[k] for v in q)-min(v[k] for v in q) for k in range(3)]
        axis = min(range(3),key=ranges.__getitem__)
        need(ranges[axis] < 1e-8, 'nonplanar exposed healer closure')
        dims = [k for k in range(3) if k != axis]
        for triangle in triangulate([[v[k] for k in dims] for v in q]):
            for point in reversed(triangle):
                v = [0,0,0]
                v[axis] = q[0][axis]
                for k,n in zip(dims,point):
                    v[k] = n
                caps['vertices'].append(v+[45.5/64,30.5/64,1])
                caps['indices'].append(len(caps['vertices']))
                caps['colors'].append([1,1,1,1])
    need(len(caps['indices']) == 96*3, 'reviewed exact healer closure count changed')
    parts.append(caps)
    result, meta = normalized(parts)
    tray = model.submeshes[15].positions
    bounds = [min(v[k] for v in tray) for k in range(3)]+[max(v[k] for v in tray) for k in range(3)]
    need(bounds[1] == bounds[4], 'original tray is not flat')
    width, depth = bounds[3]-bounds[0], bounds[5]-bounds[2]
    radius = width*.11
    def anchor(name,point):
        result['anchors'][name] = [(point[k]-meta['origin'][k])/meta['uniformDivisor'] for k in range(3)]
    for name,x,z in [('tray_back_left',bounds[0],bounds[2]),('tray_back_right',bounds[3],bounds[2]),
                     ('tray_front_right',bounds[3],bounds[5]),('tray_front_left',bounds[0],bounds[5])]:
        anchor(name,[x,bounds[1],z])
    for col,fraction in enumerate([.28,.72]):
        for row,along in enumerate([.2,.5,.8]):
            point = [bounds[0]+width*fraction,bounds[1]+radius,bounds[2]+depth*along]
            anchor('ball_'+str(col*3+row+1),point)
            if col == row == 0:
                anchor('ball_radius',[point[0]+radius,point[1],point[2]])
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedCenterHealerData.lua').write_text('-- Original ORAS healer; tools/import_oras_center_healer.py.\nreturn '+lua({'oras_center_healer':result})+'\n')
    report = dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',
        nativeLink='ZO228 -> AD108 -> MM169 -> GR511',model=model.name,submeshes=[16,15],
        originalTriangles=454,authoredClosureTriangles=96,finalTriangles=550,
        modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textures=images,
        originalJoinedRims=[len(q) for q in loops],trayBounds=bounds,authoredBallRadius=radius,
        authoredBallGrid=dict(columns=[.28,.72],rows=[.2,.5,.8]),**meta,
        processing='All original machine/tray vertices, indices, UV and opaque PNG retained; vertex lighting white. Eleven exact exposed planar closures join original rims, including floor/rear split on their shared edge; no separate tray joint cap. Concave rims use nonoverlapping ear triangles. Authored six-ball grid lies within original flat tray bounds, uniformly transformed with the source. No room floor/shadow/light geometry.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return result,report


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['model','textures','decoder','nitrogen','output']:
        parser.add_argument(name,type=Path)
    args=parser.parse_args()
    _,report=convert(args.model,args.textures,args.decoder,args.nitrogen,args.output)
    print('oras_center_healer',report['finalTriangles'])
