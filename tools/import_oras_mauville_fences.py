#!/usr/bin/env python3
"""Export the actual ORAS Mauville railing frame and c103 open panel.

Explicit local BCH inputs only. Original source paint/UVs remain unchanged;
absent backs/undersides/endcaps use proven source edge paint. No raw input or
external decoder is bundled. Native family activation requires separate QA.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
from types import SimpleNamespace
from import_oras_fences import primitive, part, box_pixels
from import_oras_grass import lua
from oras_scenery_source import decoder, need


def compact_panel(texture, length):
    """Coalesce front/rear texel rectangles with identical linear source UVs.

    Exposed hole-edge texels retain their exact original edge samples. This
    reduces catalog size without altering opaque pixels or source paint.
    """
    original = box_pixels(texture, length)
    # Existing exporter emits front/rear triangles at z=+/-.06. Those planes
    # share one linear UV mapping, so adjacent opaque texels can be coalesced.
    out = [t for t in original if not all(abs(p[2]-.06)<1e-8 for p in t)
           and not all(abs(p[2]+.06)<1e-8 for p in t)]
    w,h=texture.width,texture.height
    mask={(x,y) for y in range(h) for x in range(w)
          if texture.rgba[(y*w+x)*4+3]>0 and x*.5<length}
    while mask:
        x,y=min(mask,key=lambda p:(p[1],p[0]));right=x+1
        while (right,y) in mask:right+=1
        bottom=y+1
        while all((i,bottom) in mask for i in range(x,right)):bottom+=1
        mask.difference_update((i,j) for j in range(y,bottom) for i in range(x,right))
        xa,xb=x*.5,min(right*.5,length);ya,yb=10-y/32*7,10-bottom/32*7
        ua,ub=xa/16,xb/16;va,vb=1-y/32,1-bottom/32
        front=[[xa,ya,.06,ua,va],[xb,ya,.06,ub,va],[xb,yb,.06,ub,vb],[xa,yb,.06,ua,vb]]
        rear=[[xa,ya,-.06,ua,va],[xa,yb,-.06,ua,vb],[xb,yb,-.06,ub,vb],[xb,ya,-.06,ub,va]]
        for q in (front,rear):out.extend([[q[0],q[1],q[2]],[q[0],q[2],q[3]]])
    return out


def selected(submesh, indices, extra=()):
    s = SimpleNamespace(positions=submesh.positions, uv0=submesh.uv0,
                        triangles=[submesh.triangles[i] for i in indices])
    return primitive(s, 0, len(indices), extra)


def export(model_path, texture_path, decoder_path, output):
    load, textures, png = decoder(decoder_path)
    raw, tex_raw = model_path.read_bytes(), texture_path.read_bytes()
    models = load(raw)
    need(len(models) == 1 and models[0].name == 'c103c_01_02', 'unreviewed Mauville source')
    frame, panel = models[0].submeshes[12:14]
    need(frame.material == 'chip_saku02' and len(frame.triangles) == 250, 'frame source topology changed')
    need(panel.material == 'c103_saku' and len(panel.triangles) == 96, 'panel source topology changed')
    tx = {t.name: t for t in textures(tex_raw)}
    need((tx['chip_saku02'].width, tx['chip_saku02'].height) == (128, 128), 'frame texture changed')
    need((tx['c103_saku'].width, tx['c103_saku'].height) == (32, 32), 'panel texture changed')
    # Source faces0/1 and12/13 are the top/front of the first natural plinth
    # span.4/6 and8/9 are its top cap. Explicit missing lower-back corners
    # follow the exact source front height and original rear top positions.
    base_ids, top_ids = [0, 1, 12, 13], [4, 6, 8, 9]
    y0 = min(frame.positions[i][1] for n in base_ids for i in frame.triangles[n])
    ybase = frame.positions[frame.triangles[0][0]][1]
    ytop = frame.positions[frame.triangles[4][0]][1]
    need(abs(ybase-y0-6)<1e-4 and abs(ytop-y0-22)<1e-4, 'source height changed')
    base_back = [frame.positions[frame.triangles[0][i]] for i in (0, 1)]
    top_back = [frame.positions[frame.triangles[4][i]] for i in (1, 2)]
    base, nb = selected(frame, base_ids, [tuple((p[0], y0, p[2])) for p in base_back])
    top, nt = selected(frame, top_ids, [tuple((p[0], ytop-2, p[2])) for p in top_back])
    # Rigid local basis from the actual panel's first source quad. Only its
    # longitudinal span adapts to a native repeat; height/depth stay at.5.
    a = panel.positions[panel.triangles[1][1]]
    b = panel.positions[panel.triangles[0][0]]
    dx, dz = b[0]-a[0], b[2]-a[2]
    length = math.hypot(dx, dz);ux, uz = dx/length, dz/length
    def local(p):
        x, z = p[0]-a[0], p[2]-a[2]
        cross = (-x*uz+z*ux)*.5
        # BCH f32 rigid transforms leave sub-.0001 noise at exact source
        # frame depths/heights. Canonicalize those physical contact planes.
        for exact in (-2., -1., 0., 1., 2.):
            if abs(cross-exact)<.0001:cross=exact
        return [x*ux+z*uz, round((p[1]-y0)*.5,5), cross] + p[3:]
    bars = [[local(p) for p in tri] for tri in base+top]
    xmin = min(p[0] for t in bars for p in t)
    xmax = max(p[0] for t in bars for p in t)
    # Original thin vertical strip faces192/193, closed in actual depth.
    strip = [[list(frame.positions[i])+list(frame.uv0[i]) for i in t]
             for t in frame.triangles[192:194]]
    strip = [[local(p) for p in t] for t in strip]
    sx = (min(p[0] for t in strip for p in t)+max(p[0] for t in strip for p in t))/2
    edges = {}
    for tri in strip:
        for i in range(3):
            p, q = tri[i], tri[(i+1)%3]
            key = tuple(sorted((tuple(p[:3]),tuple(q[:3]))))
            edges.setdefault(key, []).append((p,q))
    definitions = {}
    for span in (2, 3.5, 4.5, 8, 11.5, 12.5, 14, 16):
        source = [[[((p[0]-xmin)/(xmax-xmin))*span]+p[1:] for p in tri] for tri in bars]
        for cx in (.5, span-.5):
            front = [[[cx+(p[0]-sx)*.5]+p[1:] for p in tri] for tri in strip]
            source.extend(front)
            source.extend([[p[:2]+[p[2]-.12]+p[3:] for p in tri[::-1]] for tri in front])
            for rows in edges.values():
                if len(rows) != 1:
                    continue
                p,q=rows[0];p=[cx+(p[0]-sx)*.5]+p[1:];q=[cx+(q[0]-sx)*.5]+q[1:]
                r,s=p[:2]+[p[2]-.12]+p[3:],q[:2]+[q[2]-.12]+q[3:]
                # Edge samples come from the actual source strip; no UV origin.
                source.extend([[p,q,s],[p,s,r]])
        name='oras_mauville_fence_'+str(span).replace('.','_')
        definitions[name] = dict(parts=[
            part('original_mauville_closed_frame','assets/scenery/oras-fences/chip_saku02.png',source),
            part('original_c103_panel_closed_opaque_pixels','assets/scenery/oras-mauville-fences/c103_saku.png',compact_panel(tx['c103_saku'],span))
        ],anchors={'center':[span/2,0,0]})
    folder=output/'assets/scenery/oras-mauville-fences';folder.mkdir(parents=True,exist_ok=True)
    (folder/'c103_saku.png').write_bytes(png(tx['c103_saku'].rgba,32,32))
    original=output/'assets/scenery/oras-fences/chip_saku02.png'
    need(original.read_bytes()==png(tx['chip_saku02'].rgba,128,128),'shared frame paint must be exact original source bytes')
    (output/'lib/ImportedMauvilleFencePrimitives.lua').write_text('-- Generated from original Mauville GR0739/AD0198; no raw inputs bundled.\nreturn '+lua(definitions)+'\n')
    proof=dict(source='User supplied original Alpha Sapphire RomFS',model='GR0739 slot1 c103c_01_02',
        materials=['chip_saku02','c103_saku'],textures='AD0198 slot11',
        modelSha256=hashlib.sha256(raw).hexdigest(),textureSha256=hashlib.sha256(tex_raw).hexdigest(),
        frameSourceTriangles=base_ids+top_ids+[192,193],panelSourceTriangles=list(range(4)),
        closedBaseTriangles=nb,closedTopTriangles=nt,sourceStripDepth=.12,sourceScale=.5,
        originalOpaquePanelPixels=sum(a>0 for a in tx['c103_saku'].rgba[3::4]),
        status='Original source primitive export; native activation and acceptance evidence tracked separately in docs/ORAS_MAUVILLE_FENCES_2026-10-23.md.')
    (folder/'provenance.json').write_text(json.dumps(proof,indent=2)+'\n')
    return proof


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--model',type=Path,required=True);p.add_argument('--textures',type=Path,required=True)
    p.add_argument('--decoder',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();print(json.dumps(export(a.model,a.textures,a.decoder,a.output),indent=2))
