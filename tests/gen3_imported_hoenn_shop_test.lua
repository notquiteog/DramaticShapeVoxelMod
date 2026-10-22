local source=dofile('lib/ImportedHoennShopData.lua').oras_route104_pretty_petal_shop
local modules={SceneryModelData={},ImportedHoennShopData={oras_route104_pretty_petal_shop=source},ModelInstances={},BuildBudget={check=function()end}}
local V={mod={read=function()return nil end}};V.require=function(n)return assert(modules[n],n)end
local S=assert(loadfile('lib/SceneryModels.lua'))(V);modules.SceneryModels=S
local H=assert(loadfile('lib/Gen3ImportedHoenn.lua'))(V);local id=H.shopId
local first=source.parts[1].vertices[1][3];assert(H.register(id));assert(source.parts[1].vertices[1][3]==first,'source module mutated')
assert(S.info(id).parts==7)
local r=H.recipes[2];local g={cx=3,cy=15,width=6,depth=4,kind='house',pair=r.pair,custom=r}
local cells={};for y=0,3 do for x=0,5 do cells[(g.cx+x)..':'..(g.cy+y)]={civic=g,pair=r.pair,mid=r.rows[y+1][x+1],collision=r.permissions[y+1][x+1],base=0}end end
assert(H.eligible(g,cells));local c=cells['3:15'];c.collision=7;assert(not H.eligible(g,cells));c.collision=0
local p={};assert(not H.build(g,cells,function()error('unexpected upload')end,p));assert(#p==0 and not g.importedHoenn)
local captured
S.buildBatches=function(placements,_,opts)
 local q=placements[1];assert(q.model==id and q.x==48 and q.z==256)
 local parts,fit=assert(S.vertices(id,q.fit));captured=fit
 assert(fit.bounds[4]-fit.bounds[1]>75 and fit.bounds[4]-fit.bounds[1]<76,'house no longer mostly fills blocked width')
 assert(fit.bounds[6]-fit.bounds[3]>47 and fit.bounds[6]-fit.bounds[3]<47.5)
 assert(math.abs(fit.anchors.door[1]-40)<1e-6 and math.abs(fit.anchors.door[3]-39.8)<1e-6)
 for i,part in ipairs(parts)do for j,v in ipairs(part.vertices)do
  local old=source.parts[i].vertices[j]
  assert(v[1]>=.25-1e-6 and v[1]<=95.75+1e-6 and v[3]>=.25-1e-6 and v[3]<=47.75+1e-6)
  assert(math.abs((v[1]-fit.x)/fit.scale-old[1])<1e-6 and math.abs(v[2]/fit.scale-old[2])<1e-6)
  assert(math.abs((v[3]-fit.z)/fit.scale-H.shopDepth(old[3],source.nativeDepthBay))<1e-6)
  assert(v[4]==old[4]and v[5]==old[5]and v[6]==old[6],'source UV/shade changed')
  for k=1,4 do assert(v[6+k]==source.parts[i].colors[j][k],'source vertex RGBA changed')end
  -- All triangles lie in this convex three-row blocked rectangle. None
  -- can enter the native walkable rear-left cell or the front approach.
  assert(q.z+v[3]>=(g.cy+1)*16 and q.z+v[3]<(g.cy+4)*16)
 end end
 return opts.parts
end
assert(H.build(g,cells,function()end,{}));local door=assert(H.doorSurface(g,5,18))
assert(not H.doorSurface(g,6,18));assert(math.abs((door.vertices[1][1]+door.vertices[2][1])/2-88)<1e-6)
assert(door.vertices[3][2]>=0 and door.vertices[1][2]>door.vertices[3][2])
local b=source.nativeDepthBay
assert(H.shopDepth(b.start-.1,b)==b.start-.1+b.shorten)
assert(H.shopDepth(b.finish+.1,b)==b.finish+.1)
assert(math.abs(H.shopDepth(b.finish,b)-H.shopDepth(b.start,b)-((b.finish-b.start)-b.shorten))<1e-8)
for y=0,3 do for x=0,5 do local q=cells[(g.cx+x)..':'..(g.cy+y)];assert(q.mid==r.rows[y+1][x+1]and q.collision==r.permissions[y+1][x+1])end end
print(('PASS shop guards, unchanged source UV/RGBA, rigid front/rear assemblies and8unit bay adaptation; fitted%.4fx%.4f within96x48blocked, door%.4f/%.4f'):format(captured.bounds[4]-captured.bounds[1],captured.bounds[6]-captured.bounds[3],captured.anchors.door[1],captured.anchors.door[3]))
