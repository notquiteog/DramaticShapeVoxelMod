#!/usr/bin/env python3
"""Original Oldale low sideboard, preserving its runner and recessed doors."""
import argparse,copy,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components
from import_oras_oldale_chair import clip_leg,area
from import_oras_oldale_drawers import cut_panel,subtract
from import_oras_oldale_sink import rims
from import_oras_devon import triangulate
from import_oras_grass import lua


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,textures,png=decoder(decoder_path)
    raw,blob=model_path.read_bytes(),texture_path.read_bytes()
    need(hashlib.sha256(raw).hexdigest()=='93158e5006309bdc48a0b2aa4d06edbd5405ad521398100e19eef3286ed275c0',
         'reviewed original Oldale room changed')
    model=load(raw)[0]
    need(model.name=='t102r0101_00_00' and not model.bones,'reviewed unskinned room changed')
    sub=model.submeshes[9]
    need(sub.material=='t102_shelf01' and len(sub.triangles)==108,'original sideboard topology changed')
    sys.path.insert(0,str(nitrogen_path))
    from nitrogen.platforms.ctr.bch import open_bch
    independent=open_bch(raw).models[0].meshes[9]
    need(sub.positions==independent.positions and sub.uv0==independent.texcoords,'independent sideboard position/UV mismatch')
    need(len(independent.submeshes)==1 and [n for tri in sub.triangles for n in tri]==independent.submeshes[0].indices,
         'independent sideboard indices mismatch')
    need(next(m.base_color_texture for m in model.materials if m.name==sub.material)=='t102_shelf01',
         'original sideboard texture binding changed')
    groups={g[0]:g for g in components(sub)}
    need({k:len(g) for k,g in groups.items()}=={0:64,64:12,68:2,70:2,72:10,90:8,98:6,104:4},
         'complete original runner/case/door components changed')
    texture='assets/scenery/oras-oldale-sideboard/t102_shelf01.png'
    parts={k:source_part(sub,texture,[sub.triangles[i] for i in g]) for k,g in groups.items()}
    for k in [64,90]:
        parts[k]=clip_leg(parts[k],16.5)
    closures=copy.deepcopy(parts[72])
    closures.update(name='authored_exact_sideboard_exposed_contacts',vertices=[],indices=[],colors=[],authored=True)
    uv=[4.5/128,4.5/128]

    def triangle(points):
        for v in points:
            closures['vertices'].append(list(v)+uv+[1])
            closures['indices'].append(len(closures['vertices']))
            closures['colors'].append([1,1,1,1])

    def quad(q):
        triangle([q[0],q[1],q[2]])
        triangle([q[0],q[2],q[3]])

    def horizontal(polys,y):
        for poly in polys:
            for q in triangulate(poly):
                triangle([[x,y,z] for x,z in reversed(q)])

    def back_x(z):
        # Retain the original two rear panels, including their tiny source tilt.
        return -286 if z>=-180 else -286+(z+180)*(-285.9999084472656+286)/(-194.5+180)

    def inner_x(z):
        return back_x(z)+.03

    middle=[ [inner_x(-181),-181],[-272.6191101074219,-181],
             [-272.6191101074219,-179],[inner_x(-179),-179] ]
    # The front remains on its original slightly tilted source plane. Its back
    # joins the existing post/top/base planes; those contact edges gain no caps.
    backs=[]
    for k in [68,70]:
        p=copy.deepcopy(parts[k]);p.update(name='authored_recessed_door_back_'+str(k),authored=True)
        for v in p['vertices']:
            v[0]-=.03
        for at in range(0,len(p['indices']),3):
            p['indices'][at:at+3]=list(reversed(p['indices'][at:at+3]))
        backs.append(p)
    # Complete the original center separator to the actual inner rear face.
    for z in [-181,-179]:
        quad([[inner_x(z),3.5,z],[-285.3564147949219,3.5,z],
              [-285.3564147949219,16.5,z],[inner_x(z),16.5,z]])
    # Only exposed inner rear faces remain; the center joint owns its gap.
    for lo,hi in [(-194.5,-181),(-179,-165.5)]:
        quad([[inner_x(lo),3.5,lo],[inner_x(hi),3.5,hi],
              [inner_x(hi),16.5,hi],[inner_x(lo),16.5,lo]])
    # The original lower board's rear edge stops just before the case. Join
    # that existing recess without moving any source upper surface.
    rear=-285.69140625
    rear_strip=[[inner_x(-194.5),-194.5],[rear,-194.5],[rear,-165.5],[inner_x(-165.5),-165.5]]
    horizontal(subtract([rear_strip],[middle]),3.5)
    board_top=source_part(sub,texture,[sub.triangles[i] for i in groups[104]
        if all(sub.positions[n][1]==3.5 for n in sub.triangles[i])])
    need(len(board_top['indices'])==6,'original lower board top changed')
    other_board=source_part(sub,texture,[sub.triangles[i] for i in groups[104]
        if not all(sub.positions[n][1]==3.5 for n in sub.triangles[i])])
    parts[104]=cut_panel(board_top,middle,(0,2))
    # No duplicate board-top cap beneath the center separator.
    horizontal([[[back_x(-194.5),-194.5],[-271.8172912597656,-194.5],
                 [-271.8172912597656,-165.5],[back_x(-165.5),-165.5]]],2)
    for lo,hi in [(-196.5,-194.5),(-165.5,-163.5)]:
        horizontal([[[-286,lo],[-271.7876892089844,lo],[-271.7876892089844,hi],[-286,hi]]],1)
    # Runner top stays exactly at Y19. Its source case top is Y18.51218;
    # join those existing planes with a real rim, excluding the buried contact
    # from the original wood top instead of adding a coplanar runner bottom.
    runner=rims(parts[0])[0]
    need(len(runner)==20 and all(v[1]==19 for v in runner),'original runner outline changed')
    source_top=18.51218032836914
    footprint=[[min(v[0] for v in runner),min(v[2] for v in runner)],
               [max(v[0] for v in runner),min(v[2] for v in runner)],
               [max(v[0] for v in runner),max(v[2] for v in runner)],
               [min(v[0] for v in runner),max(v[2] for v in runner)]]
    wood=source_part(sub,texture,[sub.triangles[i] for i in groups[72]
        if all(sub.positions[n][1]==source_top for n in sub.triangles[i])])
    need(len(wood['indices'])==6,'original sideboard wood top changed')
    case_sides=source_part(sub,texture,[sub.triangles[i] for i in groups[72]
        if not all(sub.positions[n][1]==source_top for n in sub.triangles[i])])
    parts[72]=cut_panel(wood,footprint,(0,2))
    runner_rim=copy.deepcopy(parts[0])
    runner_rim.update(name='authored_original_runner_contact_rim',vertices=[],indices=[],colors=[],authored=True)
    source_uv={tuple(round(v[k],6) for k in range(3)):v[3:] for v in parts[0]['vertices']}
    for a,b in zip(runner,runner[1:]+runner[:1]):
        ua,ub=source_uv[tuple(round(n,6) for n in a)],source_uv[tuple(round(n,6) for n in b)]
        start=len(runner_rim['vertices'])
        runner_rim['vertices'].extend([a+ua,b+ub,[b[0],source_top,b[2]]+ub,[a[0],source_top,a[2]]+ua])
        runner_rim['indices'].extend(start+n for n in [1,2,3,1,3,4])
        runner_rim['colors'].extend([[1,1,1,1]]*4)
    # Top underside excludes both posts, separator, thin rear and door joints.
    lower_rim=rims(source_part(sub,texture,[sub.triangles[i] for i in groups[72]]))[0]
    under=[[v[0],v[2]] for v in lower_rim]
    contacts=[middle,
        [[-286,-196.5],[-271.7876892089844,-196.5],[-271.7876892089844,-194.5],[-286,-194.5]],
        [[-286,-165.5],[-271.7876892089844,-165.5],[-271.7876892089844,-163.5],[-286,-163.5]]]
    for lo,hi in [(-194.5,-180),(-180,-165.5)]:
        contacts.append([[back_x(lo),lo],[inner_x(lo),lo],[inner_x(hi),hi],[back_x(hi),hi]])
    for k in [68,70]:
        v=parts[k]['vertices'];lo,hi=min(v,key=lambda p:p[2]),max(v,key=lambda p:p[2])
        contacts.append([[lo[0]-.03,lo[2]],[lo[0],lo[2]],[hi[0],hi[2]],[hi[0]-.03,hi[2]]])
    exposed=subtract([under],contacts)
    horizontal(exposed,16.5)
    result,meta=normalized(list(parts.values())+[other_board,case_sides]+backs+[closures,runner_rim])
    tex=next(t for t in textures(blob) if t.name=='t102_shelf01')
    need((tex.width,tex.height)==(128,128) and set(tex.rgba[3::4])=={255},'original sideboard opaque paint changed')
    image=png(tex.rgba,tex.width,tex.height)
    folder=output/'assets/scenery/oras-oldale-sideboard';folder.mkdir(parents=True,exist_ok=True)
    (folder/'t102_shelf01.png').write_bytes(image)
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedOldaleSideboardData.lua').write_text('-- Original ORAS low sideboard; tools/import_oras_oldale_sideboard.py.\nreturn '+lua({'oras_oldale_low_sideboard':result})+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',
        nativeLink='ZO230 -> AD115 -> MM171 -> GR513',model=model.name,submesh=9,material=sub.material,
        originalTriangles=108,exposedSourceTriangles=sum(len(p['indices'])//3 for p in parts.values())+len(other_board['indices'])//3+len(case_sides['indices'])//3,
        authoredClosureTriangles=sum(len(p['indices'])//3 for p in backs)+len(closures['indices'])//3+len(runner_rim['indices'])//3,
        finalTriangles=sum(len(p['indices'])//3 for p in result['parts']),
        sourceRunnerThickness=19-source_top,thinDoorDepth=.03,sourceRearThickness=.03,
        runnerContactArea=abs(area(footprint)),topUndersideExposedArea=sum(abs(area(p)) for p in exposed),
        modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),
        rgbaSha256=hashlib.sha256(tex.rgba).hexdigest(),pngSha256=hashlib.sha256(image).hexdigest(),**meta,
        processing='Original complete low case, recessed doors, central separator and painted runner retained with original UV/opaque PNG; vertex lighting white. Buried post ends clip at source underside. Exact top/base contacts exclude post/separator/rear/door joints. Source runner gains a rim down to the existing case top; its actual contact is subtracted from wood top with interpolated UV, no buried underside cap. Source rear/separator gaps join without moving upper geometry; doors gain thin backs, no duplicate contact edges. No room floor, shadows, source lighting, flowers or vases.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n')
    return result,report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['model','textures','decoder','nitrogen','output']:
        parser.add_argument(name,type=Path)
    args=parser.parse_args()
    _,report=convert(args.model,args.textures,args.decoder,args.nitrogen,args.output)
    print('oras_oldale_low_sideboard',report['finalTriangles'],report['topUndersideExposedArea'])
