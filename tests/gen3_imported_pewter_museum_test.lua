local modules={SceneryModelData=dofile('lib/SceneryModelData.lua'),PewterMuseumData=dofile('lib/PewterMuseumData.lua'),ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
modules.Gen3ImportedGyms=assert(loadfile('lib/Gen3ImportedGyms.lua'))(V)
local P=assert(loadfile('lib/Gen3ImportedPewterMuseum.lua'))(V)
local recipe;for _,r in ipairs(dofile('data/gen3_exteriors.lua'))do if r.name=='pewter_museum'then recipe=r end end
local g={cx=12,cy=0,width=16,depth=7,family=recipe.name,pair=recipe.pair,custom=recipe,groundHeight=2};local cells={}
for y,row in ipairs(P.rows)do for x,mid in ipairs(row)do cells[(g.cx+x-1)..':'..(g.cy+y-1)]={pair=g.pair,mid=mid,base=2,collision=P.permission(x-1,y-1),civic=P.owned(x-1,y-1)and g or nil}end end
assert(P.eligible(g,cells));assert(P.register());local parts=assert(S.vertices(P.id,{width=256,depth=112,padding=.25,groundInset=.05,anchor='door',targetX=88,targetZ=110}));assert(P.clearance(g,cells,parts))
-- A triangle whose vertices are blocked can still cross the native wing's
-- walkable header gap; the exact clipper must reject its interior.
assert(not P.clearance(g,cells,{{vertices={{170,2,20},{240,2,40},{170,2,40}},indices={1,2,3}}}),'triangle cannot bridge native walkable wing header')
local c=cells['12:0']
c.mid=0;assert(not P.eligible(g,cells));c.mid=P.rows[1][1]
c.base=3;assert(not P.eligible(g,cells));c.base=2
c.boundary='mountain';assert(not P.eligible(g,cells));c.boundary=nil
c.civic=nil;assert(not P.eligible(g,cells),'lost native civic ownership');c.civic=g
c.prop={};assert(not P.eligible(g,cells),'prop conflict');c.prop=nil
local rear=cells['23:1'];rear.collision=7;assert(not P.eligible(g,cells),'walkable wing header changed');rear.collision=0
local east=cells['25:4'];east.collision=7;assert(not P.eligible(g,cells),'missing east warp');east.collision=0x71
local main=cells['17:6'];main.collision=7;assert(not P.eligible(g,cells),'missing main warp');main.collision=0x71
assert(not P.build(g,cells,function()error('unexpected GPU upload without PNG')end,{}));assert(not g.importedPewterMuseum)
local old=S.buildBatches;S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);local parts,f=assert(S.vertices(p.model,p.fit));assert(p.y==2 and p.z==0)
 local shadow,recess,foundation=false,false,false
 local function inside(x,z)
  local e=.0001
  return x>=.25-e and x<=175.75+e and z>=.25-e and z<=95.75+e
   or x>=175.75-e and x<=255.75+e and z>=32.25-e and z<=79.75+e
   or x>=64.25-e and x<=111.75+e and z>=95.75-e and z<=111.75+e
 end
 for _,part in ipairs(parts)do
  shadow=shadow or part.role=='ground_shadow' and part.alphaMode=='blend' and math.abs(part.opacity-.2903226)<1e-6
  recess=recess or part.name=='authored_native_staff_portal_recess';foundation=foundation or part.name=='authored_closed_foundations'
  for i=1,#part.indices,3 do
   local a,b,c=part.vertices[part.indices[i]],part.vertices[part.indices[i+1]],part.vertices[part.indices[i+2]]
   -- Sample triangle interiors as well as edges: the allowed footprint is
   -- nonrectangular, so checking its bounding box/vertices is insufficient.
   for aa=0,6 do for bb=0,6-aa do
    local cc=6-aa-bb;local x,z=(a[1]*aa+b[1]*bb+c[1]*cc)/6,(a[3]*aa+b[3]*bb+c[3]*cc)/6
    assert(inside(x,z),'triangle crosses a native walkable gap: '..part.name)
   end end
  end
 end
 assert(shadow and recess and foundation)
 assert(f.bounds[4]-f.bounds[1]>255 and f.bounds[6]-f.bounds[3]>111)
 return opts.parts
end
assert(P.build(g,cells,function()end,{}));assert(g.importedPewterMuseum)
for _,q in ipairs{{17,6,88,110,16},{25,4,216,74.65890924271278,14}}do
 local d=assert(P.doorSurface(g,q[1],q[2]));assert(d.base==2 and d.w==q[5] and d.h==16)
 assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-g.cx*16-q[3])<.0001)
 assert(math.abs(d.vertices[1][3]-q[4]-.025)<.0001)
 assert(d.vertices[1][3]>=q[2]*16 and d.vertices[1][3]<(q[2]+1)*16,'portal must remain in original native warp cell')
 assert(d.vertices[1][2]>d.vertices[4][2])
end
assert(not P.doorSurface(g,24,4));assert(not P.doorSurface(g,18,6));S.buildBatches=old
print('PASS both Museum native portals, full drawing/ownership/permission/base guards, true nonrectangular blocked mask, source alpha, staff recess and fallback')
