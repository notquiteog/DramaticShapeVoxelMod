local data=dofile('lib/ImportedHoennData.lua')
local modules={SceneryModelData={},ImportedHoennData=data,ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
modules.SharedModelMesh=dofile('lib/SharedModelMesh.lua')
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local H=assert(loadfile('lib/Gen3ImportedHoenn.lua'))(V)
assert(H.register());local info=assert(S.info(H.id));assert(info.parts==5 and info.vertices<32768)
local r=H.recipes[1];local g={cx=15,cy=47,width=5,depth=4,kind='house',pair=r.pair,custom=r,groundHeight=0}
local cells={};for y=0,3 do for x=0,4 do
 cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,pair=r.pair,base=0,mid=r.rows[y+1][x+1],collision=r.permissions[y+1][x+1]}
end end
assert(H.eligible(g,cells))
local key='19:49';local c=cells[key]
for _,field in ipairs{'collision','mid','pair','civic'}do
 local old=c[field];c[field]=nil;assert(not H.eligible(g,cells),field);c[field]=old
end
for _,field in ipairs{'boundary','stageHidden'}do c[field]=true;assert(not H.eligible(g,cells),field);c[field]=nil end
c.base=1;assert(not H.eligible(g,cells));c.base=0
cells['15:47'].collision=7;assert(not H.eligible(g,cells),'rear walkable row consumed');cells['15:47'].collision=0
local before={};assert(not H.build(g,cells,function()error('unexpected GPU upload')end,before));assert(not g.importedHoenn and #before==0,'missing resources must retain fallback')
local build=S.buildBatches;S.buildBatches=function(placements,_,opts)
 local p=assert(placements[1]);assert(#placements==1);local parts,fit=assert(S.vertices(p.model,p.fit))
 assert(math.abs(p.x+fit.anchors.door[1]-(17*16+8))<1e-6)
 assert(p.z==48*16 and p.y==0)
 for _,part in ipairs(parts)do for _,v in ipairs(part.vertices)do
  assert(v[1]>=.25-1e-6 and v[1]<=79.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6)
 end end
 assert(fit.bounds[4]-fit.bounds[1]>68,'source house no longer fills native footprint')
 assert(fit.bounds[6]-fit.bounds[3]>42,'source deck compressed')
 return opts.parts
end
assert(H.build(g,cells,function()end,{}));local d=assert(H.doorSurface(g,17,50))
assert(not H.doorSurface(g,16,50));assert(d.w==14 and d.h==18 and d.sourceX==273 and d.sourceY==797)
assert(math.abs((d.vertices[1][1]+d.vertices[2][1])/2-280)<1e-6)
assert(d.vertices[4][2]>0 and d.vertices[1][2]>d.vertices[4][2],'source raised deck opening lost')
for y=0,3 do for x=0,4 do local q=cells[(g.cx+x)..':'..(g.cy+y)];assert(q.mid==r.rows[y+1][x+1]and q.collision==r.permissions[y+1][x+1])end end
S.buildBatches=build
print('PASS source house registration, exact native footprint/permission guards, missing-resource fallback and original raised entrance alignment')
