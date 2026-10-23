#!/usr/bin/env python3
"""Import the original ORAS Flower Shop open bookcase and its twenty books."""
import argparse,collections,hashlib,json,math,sys
from pathlib import Path
from oras_scenery_source import decoder,need
from import_oras_grass import lua
from import_oras_home_furniture import source_part,normalized
from import_oras_oldale_fridge import components,merge_parts
from import_oras_oldale_sink import rims


def cap(part,points,uv,color):
    """Minimum-area triangulation at exact, possibly tilted book-cover rims."""
    def size(a,b,c):
        u=[b[k]-a[k]for k in range(3)];v=[c[k]-a[k]for k in range(3)]
        return math.sqrt(sum(x*x for x in[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]))/2
    n=len(points);cost={(i,i+1):0 for i in range(n-1)};split={}
    for span in range(2,n):
        for i in range(n-span):
            j=i+span;best=math.inf
            for k in range(i+1,j):
                area=size(points[i],points[k],points[j])
                if area<1e-12:continue
                q=cost.get((i,k),math.inf)+cost.get((k,j),math.inf)+area
                if q<best:best=q;split[i,j]=k
            cost[i,j]=best
    need(math.isfinite(cost[0,n-1]),'reviewed rim cannot be closed')
    triangles=[]
    def visit(i,j):
        if j-i<2:return
        k=split[i,j];triangles.extend([i+1,j+1,k+1]);visit(i,k);visit(k,j)
    visit(0,n-1)
    p={k:v for k,v in part.items()if k not in('vertices','indices','colors')}
    p.update(name='authored_exact_bookcase_closures',vertices=[list(v)+uv+[1]for v in points],indices=triangles,colors=[color[:]]*n,authored=True)
    return p


def convert(model_path,texture_path,decoder_path,nitrogen_path,output):
    load,load_textures,png=decoder(decoder_path);raw=model_path.read_bytes();blob=texture_path.read_bytes();m=load(raw)[0]
    need(hashlib.sha256(raw).hexdigest()=='f1f6aa9aa985098cbea64068d9ee3ef33f7e0421491c367cf548195fe82c3657','reviewed Flower Shop source changed')
    need(m.name=='r104ar0101_00_00'and not m.bones,'unreviewed bookcase room')
    sys.path.insert(0,str(nitrogen_path));from nitrogen.platforms.ctr.bch import open_bch
    other=open_bch(raw).models[0];bank={t.name:t for t in load_textures(blob)}
    folder=output/'assets/scenery/oras-flower-bookcase';folder.mkdir(parents=True,exist_ok=True)
    parts=[];closures=[];textures={};book_colors=[]
    for index,material,count in[(25,'books02',312),(26,'bookshelf01',164)]:
        s=m.submeshes[index];q=other.meshes[index]
        need(s.material==material and len(s.triangles)==count,'reviewed bookcase stream changed')
        need(s.positions==q.positions and s.uv0==q.texcoords,'independent original bookcase positions/UV differ')
        need(len(q.submeshes)==1 and [i for t in s.triangles for i in t]==q.submeshes[0].indices,'independent bookcase indices differ')
        texture='assets/scenery/oras-flower-bookcase/'+material+'.png';source=source_part(s,texture);parts.append(source)
        used=sorted({n for t in s.triangles for n in t});lookup={n:i for i,n in enumerate(used)}
        groups=components(s)
        if index==25:
            need(len(groups)==20,'reviewed twenty original books changed')
            for group in groups:
                ids={n for i in group for n in s.triangles[i]}
                # The grayscale atlas is colored by the original per-book
                # vertex paint. Retain each book's brightest original pigment
                # as a flat color, removing directional/ambient vertex shading.
                color=list(max((s.colors[n]for n in ids),key=lambda c:(sum(c[:3]),max(c[:3]))));book_colors.append(color)
                for n in ids:source['colors'][lookup[n]]=color[:]
                p=source_part(s,texture,[s.triangles[i]for i in group]);loops=rims(p)
                need(len(loops)==1 and len(loops[0])in(6,8),'reviewed original book-cover rim changed')
                closures.append(cap(p,loops[0],[.5/64,.5/64],color))
        else:
            need([(g[0],len(g))for g in groups]==[(0,32),(8,16),(12,16),(16,16),(20,16),(96,8),(104,8),(112,8),(120,8),(128,12),(140,8),(148,6),(154,10)],'reviewed case connectivity changed')
            # Two side panels extend 0.0001 source units into the original
            # top plank's bottom plane, causing four real coplanar slivers.
            # Recess only their buried upper rim to the exact plank join.
            top=min(s.positions[n][1]for i in range(128,140)for n in s.triangles[i])
            snap_ids={n for group in groups if group[0]in(0,140)for i in group for n in s.triangles[i]if abs(s.positions[n][1]-36.382)<1e-5}
            for n in snap_ids:source['vertices'][lookup[n]][1]=top
            # Original divider ends and side-panel ends terminate inside the
            # existing horizontal planks. Their internal caps are omitted.
            # Feet have open bottoms and buried tops; close only the bottoms.
            feet=[]
            for g in groups:
                p=source_part(s,texture,[s.triangles[i]for i in g])
                if g[0]in(96,104,112,120):
                    loop=min(rims(p),key=lambda ps:sum(v[1]for v in ps));feet.append(loop)
                    closures.append(cap(p,loop,[24.5/128,24.5/64],[1,1,1,1]))
                elif g[0]==148:
                    loop=rims(p)[0];low=[v for v in loop if v[1]<21]
                    # Long exposed underside; the short ends are buried in
                    # existing case walls. No duplicate side-wall faces.
                    low.sort(key=lambda v:math.atan2(v[2]-(15.4427-32.7335)/2,v[0]-(-36.0041-17.9243)/2))
                    closures.append(cap(p,low,[24.5/128,24.5/64],[1,1,1,1]))
                elif g[0]==154:
                    bottom=rims(p)[0]
            # Partition the tilted lower plank underside around four exact
            # foot footprints. Its authored cap never runs inside a leg.
            xs=sorted({v[0]for v in bottom}|{v[0]for loop in feet for v in loop});zs=sorted({v[2]for v in bottom}|{v[2]for loop in feet for v in loop})
            z0,z1=min(zs),max(zs);y0=min(bottom,key=lambda v:v[2])[1];y1=max(bottom,key=lambda v:v[2])[1]
            for a,b in zip(xs,xs[1:]):
                for c,d in zip(zs,zs[1:]):
                    x,z=(a+b)/2,(c+d)/2
                    if any(min(v[0]for v in foot)<x<max(v[0]for v in foot)and min(v[2]for v in foot)<z<max(v[2]for v in foot)for foot in feet):continue
                    ps=[[u,y0+(y1-y0)*(v-z0)/(z1-z0),v]for u,v in[(a,c),(b,c),(b,d),(a,d)]]
                    closures.append(cap(source,ps,[24.5/128,24.5/64],[1,1,1,1]))
        t=bank[material];need((t.width,t.height)==((64,64)if index==25 else(128,64)),'source bookcase PNG size changed');content=png(t.rgba,t.width,t.height);(folder/(material+'.png')).write_bytes(content)
        textures[material]=dict(rgbaSha256=hashlib.sha256(t.rgba).hexdigest(),pngSha256=hashlib.sha256(content).hexdigest())
    for texture in sorted({p['texture']for p in closures}):
        closure=merge_parts([p for p in closures if p['texture']==texture]);closure['name']='authored_reviewed_bookcase_closures';parts.append(closure)
    model,meta=normalized(parts);data={'oras_flower_bookcase':model}
    (output/'lib').mkdir(parents=True,exist_ok=True);(output/'lib/ImportedFlowerBookcaseData.lua').write_text('-- Original ORAS Flower Shop bookcase; tools/import_oras_flower_bookcase.py.\nreturn '+lua(data)+'\n')
    report=dict(source='User-supplied Pokemon Alpha Sapphire RomFS',originalGameArt='Nintendo / Creatures / GAME FREAK',nativeLink='ZO366 -> AD161 -> MM273 -> GR623',model=m.name,modelBchSha256=hashlib.sha256(raw).hexdigest(),textureBchSha256=hashlib.sha256(blob).hexdigest(),textures=textures,originalTriangles=476,authoredClosureTriangles=sum(len(p['indices'])//3 for p in closures),bookColors=book_colors,sourceFront='-X',nativeQuarterTurn=3,**meta,processing='All original case and twenty books, original UV/PNG. Original per-book pigment is flat brightest source tint; directional/ambient vertex shading removed. Wood uses original texture without source vertex lighting. Book open rims close at exact vertices; exposed foot bottoms and plank undersides closed, buried case/divider/foot-top caps omitted. Four-foot holes partition lower underside. Two original panel upper rims at 36.382 recess to original plank underside, removing actual source coplanar slivers. No floor, source shadow or lighting geometry. Uniform native fit and exact Y0 contact recess.')
    (folder/'provenance.json').write_text(json.dumps(report,indent=2)+'\n');return data

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for n in['model','textures','decoder','nitrogen','output']:p.add_argument(n,type=Path)
    a=p.parse_args()
    for name,m in convert(a.model,a.textures,a.decoder,a.nitrogen,a.output).items():print(name,sum(len(p['indices'])//3 for p in m['parts']))
