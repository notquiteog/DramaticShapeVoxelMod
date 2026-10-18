local L=dofile('lib/SceneLookahead.lua')
local function def(pair,w,h,mid)
 return {midLayout={pair=pair,width=w,height=h,midAt=function(self,x,y)return x>=0 and y>=0 and x<w and y<h and mid or 99 end}}
end
local a,b,c=def('a',20,20,1),def('b',10,12,2),def('c',10,10,3)
local maps={b=b,c=c};local direct={{dir='north',map='b',offset=5},{dir='east',map='c',offset=4}}
local e=L.entry(a,direct,maps,7*16,3*16,5)
assert(e.id=='b'and e.px==32 and e.pz==176,'north entry ignored connection offset')
assert(not L.entry(a,direct,maps,0,3*16,5),'entry outside connected span')
e=L.entry(a,direct,maps,18*16,8*16,5);assert(e.id=='c'and e.px==0 and e.pz==64)
assert(not L.entry(a,direct,maps,10*16,10*16,3),'distant map eagerly prepared')
local neighbors={{dir='north',def=b,offset=5},{dir='east',def=c,offset=4}}
local world={{def=b,ox=5,oy=-12},{def=c,ox=20,oy=4}}
local mid,pair,void=L.sample(a,neighbors,world,7,-1);assert(mid==2 and pair=='b'and not void)
mid,pair,void=L.sample(a,neighbors,world,21,8);assert(mid==3 and pair=='c'and not void)
mid,pair,void=L.sample(a,neighbors,world,2,2);assert(mid==1 and pair=='a'and not void)
mid,pair,void=L.sample(a,neighbors,world,-5,-5);assert(mid==99 and pair=='a'and void)
local far=def('far',10,10,4);world[#world+1]={def=far,ox=30,oy=4}
mid,pair,void=L.sample(a,neighbors,world,31,8);assert(mid==4 and pair=='far'and not void)
print('PASS connected entry prediction, offsets/spans/range, native primary/direct/distant/border sampling')
local candidate={sceneDef=a,distance={bounds={0,0,70,70},radius=32,full=false},terrainKey='0;0;70;70;content'}
local req={def=a,radius=32,budget=512,x0=0,z0=6,x1=70,z1=76,key='0;6;70;76;content'}
assert(L.accept(candidate,req),'native edge interpolation discarded ready neighbor')
req.key='0;6;70;76;changed-atlas';assert(not L.accept(candidate,req),'reloaded provider reused')
req.key='0;6;70;76;content';req.z0=12;assert(not L.accept(candidate,req),'distant warp reused')
req.z0=6;req.def=b;assert(not L.accept(candidate,req),'different map reused')
print('PASS nearby native connection interpolation, changed-provider and distant-warp guards')
e=L.entry(a,{{dir='south',map='b',offset=5}},maps,7*16,19*16,5);assert(e.id=='b'and e.px==32 and e.pz==0)
e=L.entry(a,{{dir='west',map='b',offset=5}},maps,0,7*16,5);assert(e.id=='b'and e.px==144 and e.pz==32)
local south={{dir='south',def=b,offset=5}};mid,pair=L.sample(a,south,{},7,20);assert(mid==2 and pair=='b')
local west={{dir='west',def=b,offset=5}};mid,pair=L.sample(a,west,{},-1,7);assert(mid==2 and pair=='b')
print('PASS south/west entry placement and sampling')

-- At a junction, stage the approached seam rather than a closer side map.
e=L.entry(a,direct,maps,12*16,4*16,24,'right');assert(e.id=='c' and e.distance==7)
e=L.entry(a,direct,maps,12*16,4*16,24,'up');assert(e.id=='b' and e.distance==4)
e=L.entry(a,direct,maps,12*16,4*16,24);assert(e.id=='b','missing direction keeps nearest policy')
e=L.entry(a,direct,maps,12*16,4*16,5,'right');assert(e.id=='b','heading cannot expand prefetch radius')
e=L.entry(a,direct,maps,18*16,8*16,24,'up');assert(e.id=='c','heading cannot ignore connection span')
print('PASS direction-aware prediction preserves bounded range, span and nearest fallback')

assert(L.interpolating(a,-8,32)and L.interpolating(a,320,32))
assert(L.interpolating(a,32,-8)and L.interpolating(a,32,320))
assert(not L.interpolating(a,0,0)and not L.interpolating(a,-32,32))
assert(not L.interpolating(a,-8,-8)and not L.interpolating({},0,0))
print('PASS bounded outside-cell native transition interpolation')

-- At every sub-cell position, including negative native entry interpolation,
-- the complete chosen distance fits inside the immutable build snapshot.
local previous,windows=nil,0
for x=-32,640 do
 local x0,z0,x1,z1=L.window(x,x/2,32)
 assert(x0<=x/16-32 and x1>=x/16+32)
 assert(z0<=x/32-32 and z1>=x/32+32)
 if x0~=previous then windows=windows+1;previous=x0 end
end
assert(windows==5,'running rebuild cadence changed unexpectedly')
req.def=a;req.z0=12;req.z1=82
assert(L.accept(candidate,req),'adjacent complete window was discarded')
req.z0=24;req.z1=94
assert(not L.accept(candidate,req),'two-window warp reused stale scenery')
print('PASS running window cadence, full distance coverage and bounded adjacent reuse')
