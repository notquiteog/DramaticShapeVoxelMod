#!/usr/bin/env python3
"""Original Oldale backed chair, with exposed foot/seat/spindle contact unions."""
import argparse,copy,hashlib,json,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components,merge_parts
from import_oras_oldale_sink import rims
from import_oras_flower_bookcase import cap
from import_oras_grass import lua


def clip_leg(part,height):
    """Remove only buried leg segments above the original seat underside."""
    out=copy.deepcopy(part);out.update(vertices=[],indices=[],colors=[])
    for at in range(0,len(part['indices']),3):
        poly=[part['vertices'][part['indices'][at+k]-1]for k in range(3)]
        clipped=[];previous=poly[-1]
        for vertex in poly:
            if (vertex[1]<=height)!=(previous[1]<=height):
                t=(height-previous[1])/(vertex[1]-previous[1])
                point=[previous[k]+t*(vertex[k]-previous[k])for k in range(6)]
                point[1]=height;clipped.append(point)
            if vertex[1]<=height:clipped.append(vertex[:])
            previous=vertex
        start=len(out['vertices']);out['vertices']+=clipped;out['colors'] += [[1,1,1,1]for _ in clipped]
        for k in range(1,len(clipped)-1):out['indices'] += [start+1,start+k+1,start+k+2]
    return out


def area(points):
    origin=points[0]
    return sum((a[0]-origin[0])*(b[1]-origin[1])-(a[1]-origin[1])*(b[0]-origin[0])
               for a,b in zip(points,points[1:]+points[:1]))/2


def clip(poly,a,b,inside):
    def distance(point):return ((b[0]-a[0])*(point[1]-a[1])-(b[1]-a[1])*(point[0]-a[0]))*(1 if inside else -1)
    if not poly:return []
    out=[];previous=poly[-1];last=distance(previous)
    for vertex in poly:
        current=distance(vertex)
        if (last>=-1e-9)!=(current>=-1e-9):
            t=last/(last-current);out.append([previous[k]+t*(vertex[k]-previous[k])for k in range(2)])
        if current>=-1e-9:out.append(vertex[:])
        previous,last=vertex,current
    clean=[]
    for vertex in out:
        if not clean or sum(abs(vertex[k]-clean[-1][k])for k in range(2))>1e-8:clean.append(vertex)
    if len(clean)>1 and sum(abs(clean[0][k]-clean[-1][k])for k in range(2))<1e-8:clean.pop()
    return clean if len(clean)>2 and abs(area(clean))>1e-9 else []


def convex(points):
    return all((b[0]-a[0])*(c[1]-b[1])-(b[1]-a[1])*(c[0]-b[0])>=-1e-12
               for a,b,c in zip(points,points[1:]+points[:1],points[2:]+points[:2]))


def seat_union(ring,holes):
    """Subtract exact leg rims, including their tiny original concave corners."""
    cutters=[]
    for original in holes:
        hole=copy.deepcopy(original)
        if area(hole)<0:hole.reverse()
        if convex(hole):cutters.append(hole);continue
        split=False
        for i in range(len(hole)):
            for j in range(i+2,len(hole)):
                a,b=hole[i:j+1],hole[j:]+hole[:i+1]
                if len(b)>2 and convex(a)and convex(b):
                    need(abs(area(a)+area(b)-area(hole))<1e-10,'convex decomposition changed original leg rim')
                    cutters.extend([a,b]);split=True;break
            if split:break
        need(split,'unreviewed nonconvex original leg rim')
    need(len(cutters)==6,'reviewed four original leg rims changed')
    polys=[[[v[0],v[2]]for v in ring]]
    for hole in cutters:
        kept=[]
        for poly in polys:
            remaining=poly
            for a,b in zip(hole,hole[1:]+hole[:1]):
                outside=clip(remaining,a,b,False)
                if outside:kept.append(outside)
                remaining=clip(remaining,a,b,True)
                if not remaining:break
        polys=kept
    expected=abs(area([[v[0],v[2]]for v in ring]))-sum(abs(area(hole))for hole in holes)
    actual=sum(abs(area(poly))for poly in polys)
    need(abs(actual-expected)<1e-8 and len(polys)==40,'seat/leg union lost or duplicated exposed area')
    return polys,expected,actual


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,lt,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();model=load(raw)[0]
    need(hashlib.sha256(raw).hexdigest()=='93158e5006309bdc48a0b2aa4d06edbd5405ad521398100e19eef3286ed275c0','reviewed original Oldale room changed')
    need(model.name=='t102r0101_00_00'and not model.bones,'reviewed unskinned source changed')
    sub=model.submeshes[1];need(sub.material=='t102_chair','original chair material changed')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0].meshes[1]
    need(sub.positions==other.positions and sub.uv0==other.texcoords,'independent chair position/UV mismatch')
    need(len(other.submeshes)==1 and [n for tri in sub.triangles for n in tri]==other.submeshes[0].indices,'independent original chair index mismatch')
    groups={group[0]:group for group in components(sub)}
    selected={0:16,48:16,60:16,78:22,94:16,176:44,278:8,280:8,296:4,298:4}
    need(all(len(groups[key])==count for key,count in selected.items()),'reviewed complete chair components changed')
    texture='assets/scenery/oras-oldale-chair/t102_chair.png'
    seat=source_part(sub,texture,[sub.triangles[i]for i in groups[78]])
    loops=rims(seat);need(len(loops)==1 and len(loops[0])==8,'original seat rim changed')
    ring=loops[0];height=ring[0][1];need(all(abs(v[1]-height)<1e-10 for v in ring),'nonplanar source seat underside')
    parts=[];closures=[];holes=[];foot_delta=0
    for key in [0,48,60,94]:
        leg=clip_leg(source_part(sub,texture,[sub.triangles[i]for i in groups[key]]),height)
        loops=rims(leg);need(len(loops)==2 and sorted(map(len,loops))==[4,8],'clipped original leg topology changed')
        low=min(loops,key=lambda q:sum(v[1]for v in q));high=max(loops,key=lambda q:sum(v[1]for v in q))
        holes.append([[v[0],v[2]]for v in high])
        for vertex in leg['vertices']:
            if abs(vertex[1]-1)<.00003:foot_delta=max(foot_delta,abs(vertex[1]-1));vertex[1]=1
        for vertex in low:vertex[1]=1
        closures.append(cap(leg,low,[.5/32,32.5/64],[1,1,1,1]));parts.append(leg)
    parts.append(seat)
    for key in [176,278,280,296,298]:
        part=source_part(sub,texture,[sub.triangles[i]for i in groups[key]]);parts.append(part)
        if key in [296,298]:
            loops=rims(part);need(len(loops)==1 and len(loops[0])==6,'original spindle recess changed')
            closures.append(cap(part,loops[0],[.5/32,32.5/64],[1,1,1,1]))
        # Original open post ends remain buried in the source seat/back.
    polys,expected,actual=seat_union(ring,holes)
    for poly in polys:
        if area(poly)>0:poly.reverse()
        closures.append(cap(seat,[[v[0],height,v[1]]for v in poly],[.5/32,32.5/64],[1,1,1,1]))
    closure=merge_parts(closures);closure['name']='authored_exact_chair_exposed_contact_union';parts.append(closure)
    need(sum(len(p['indices'])//3 for p in parts)==270 and len(closure['indices'])//3==100,'reviewed exposed chair union count changed')
    result,meta=normalized(parts);folder=output/'assets/scenery/oras-oldale-chair';folder.mkdir(parents=True,exist_ok=True)
    t=next(t for t in lt(blob)if t.name=='t102_chair');need((t.width,t.height)==(32,64)and set(t.rgba[3::4])=={255},'original opaque wood texture changed')
    content=png(t.rgba,t.width,t.height);(folder/'t102_chair.png').write_bytes(content)
    (output/'lib').mkdir(parents=True,exist_ok=True)
    (output/'lib/ImportedOldaleChairData.lua').write_text('-- Original ORAS Oldale backed chair; tools/import_oras_oldale_chair.py.\nreturn '+lua({'oras_oldale_backed_chair':result})+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO230 -> AD115 -> MM171 -> GR513',model=model.name,submesh=1,selectedComponents=list(selected),originalTriangles=154,exposedSourceTriangles=170,authoredClosureTriangles=100,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest(),sourceFront='-Z',nativeLeftQuarterTurn=1,nativeRightQuarterTurn=3,seatExposedArea=expected,seatUnionArea=actual,maximumFloorContactSnap=foot_delta,**meta,processing='One complete original chair: four legs, shaped seat, closed back, two posts and two spindles. Original upper geometry/UV/opaque PNG retained, source vertex lighting removed. Buried leg triangles clip exactly at original seat underside; underside partitions around all eight vertices of each actual leg rim. Two slightly concave source intersections decompose without snapping visible vertices or overlapping caps. Four foot contacts unify to sourceY1 by less than .00003 source units. Exposed foot bottoms/spindle recesses close; buried post ends gain no internal caps. No room/floor/shadow/light geometry. Uniform native fit, native left/right orientation, bottom-only contact recess.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['model','textures','decoder','nitrogen','output']:parser.add_argument(name,type=Path)
    args=parser.parse_args();result=convert(args.model,args.textures,args.decoder,args.nitrogen,args.output)
    print('oras_oldale_backed_chair',sum(len(p['indices'])//3 for p in result['parts']))
