-- Real Museum approach IDs and source threshold; no cache/ROM dependency.
local function stairs()return assert(loadfile('lib/Gen3Stairs.lua'))({data=function()return {}end})end
local function uv(_,mid)return{{mid,0},{mid+1,0},{mid+1,1},{mid,1}}end
local function collect(S,c)
 local faces={};S.append(c,function(p,t)faces[#faces+1]={p=p,t=t}end,uv);return faces
end
local function exposed(faces)
 -- Axis-aligned coplanar faces may share edges, never positive area.
 for i,a in ipairs(faces)do for j=1,i-1 do local b=faces[j]
  for axis=1,3 do
   local plane=a.p[1][axis];local same=true
   for _,f in ipairs{a,b}do for _,p in ipairs(f.p)do if math.abs(p[axis]-plane)>1e-8 then same=false end end end
   if same then local area=1
    for d=1,3 do if d~=axis then
     local lo,hi={},{};for k,f in ipairs{a,b}do lo[k],hi[k]=math.huge,-math.huge;for _,p in ipairs(f.p)do lo[k]=math.min(lo[k],p[d]);hi[k]=math.max(hi[k],p[d])end end
     area=area*math.max(0,math.min(hi[1],hi[2])-math.max(lo[1],lo[2]))
    end end
    assert(area<1e-8,'overlapping coplanar stair faces')
   end
  end
 end end
end
local function fixture()
 local g={cx=12,cy=0,pair='pewter_outdoor',custom={geometry='pewter_museum'}}
 local cells={}
 for x=0,2 do
  cells[(16+x)..':6']={cx=16+x,cy=6,pair=g.pair,mid=0x2b2+x,civic=g,shape={kind='flat'}}
  cells[(16+x)..':7']={cx=16+x,cy=7,pair=g.pair,mid=0x2ba+x,collision=0,base=0,shape={kind='flat'},ts={}}
 end
 return cells
end
local S=stairs();local cells=fixture();assert(S.prepare(cells)==1)
local owner=cells['16:7'];local f=collect(S,owner);exposed(f)
assert(#f==35,'landing/treads, exposed risers and closed sides changed')
local lo,hi,z0,z1=math.huge,-math.huge,math.huge,-math.huge
for _,a in ipairs(f)do for i,p in ipairs(a.p)do
 lo=math.min(lo,p[2]);hi=math.max(hi,p[2]);z0=math.min(z0,p[3]);z1=math.max(z1,p[3])
 assert(a.t[i][1]>=0x2bb and a.t[i][1]<0x2bc and a.t[i][2]>.5,'facade became stair paint')
end end
assert(lo==0 and hi==1.0125 and z0==110 and z1==128,'native ground/source threshold/boundary changed')
local source=dofile('lib/PewterMuseumData.lua').hgss_pewter_museum
assert(math.abs(source.anchors.door[2]*255.5-hi)<1e-6,'steps no longer meet existing source threshold')
for x=16,18 do local c=cells[x..':7'];assert(c.base==0 and c.shape.kind=='flat' and c.collision==0 and c.mid==0x2ba+x-16,'native support mutated')end
assert(#collect(S,cells['17:7'])==0 and #collect(S,cells['18:7'])==0,'shared approach rendered multiple times')
for _,mutation in ipairs{
 function(c)c['17:7'].mid=1 end,function(c)c['17:7'].collision=7 end,
 function(c)c['17:7'].pair='viridian_outdoor'end,function(c)c['17:7'].prop={}end,
 function(c)c['17:7'].boundary=true end,function(c)c['17:6'].mid=1 end,
 function(c)c['17:6'].civic=nil end,function(c)c['17:7'].shape.kind='steps'end,
 function(c)c['17:7']=nil end,
}do local c=fixture();mutation(c);assert(stairs().prepare(c)==0,'partial/third-party approach claimed')end
for _,reverse in ipairs{false,true}do
 local c={cx=2,cy=3,mid=1,ts={},shape={kind='steps'},floor={low=4,high=12,reverse=reverse}}
 local faces=collect(S,c);assert(#faces==17,'generic terrace has hidden boxes or missing closure');exposed(faces)
 for _,a in ipairs(faces)do for _,p in ipairs(a.p)do assert(p[2]>=0 and p[2]<=8)end end
 assert(c.floor.low==4 and c.floor.high==12 and c.floor.reverse==reverse,'generic native rise mutated')
end
print('PASS Museum exact approach/source threshold, closed shallow treads, single surfaces and native support')
